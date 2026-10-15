const config = {"origin":"https://vinnslan.vitverk.is","server":"vitverk","pluginId":"vitverk@vitverk","helpUrl":"https://vinnslan.vitverk.is/external-access/mcp/connect?method=manual","rpcTimeoutMs":30000,"loginTimeoutMs":300000};

import {spawn} from 'node:child_process';
import {access, lstat, mkdir, open, unlink} from 'node:fs/promises';
import {createHash, randomUUID} from 'node:crypto';
import {constants} from 'node:fs';
import {homedir, tmpdir} from 'node:os';
import {delimiter, join} from 'node:path';

const args = process.argv.slice(2);
const login = args.length === 1 && args[0] === '--login';
const emit = (state, fields = {}) => console.log(JSON.stringify({state, ...fields, helpUrl: config.helpUrl}));
if (args.length > 1 || args.length === 1 && !['--check', '--login'].includes(args[0])) {
  emit('blocked', {reason: 'invalid_arguments'});
  process.exitCode = 1;
} else {
  await connect();
}

async function findCodex() {
  const executable = process.platform === 'win32' ? 'codex.exe' : 'codex';
  const candidates = (process.env.PATH || '').split(delimiter).filter(Boolean).map(path => join(path, executable));
  if (process.platform === 'darwin') {
    for (const directory of ['/Applications', join(homedir(), 'Applications')]) {
      for (const app of ['ChatGPT.app', 'Codex.app']) {
        candidates.push(join(directory, app, 'Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex'));
        candidates.push(join(directory, app, 'Contents/Resources/codex'));
      }
    }
  }
  for (const candidate of candidates) {
    try { await access(candidate, process.platform === 'win32' ? constants.F_OK : constants.X_OK); return candidate; }
    catch {}
  }
  return null;
}

// Ambiguous attempts survive process exit. Never replace an existing receipt automatically.
async function pendingPath(create) {
  const directory = join(tmpdir(), 'codex-connections-' + (process.getuid?.() ?? 'user'));
  if (create) {
    try { await mkdir(directory, {mode: 0o700}); } catch (error) { if (error.code !== 'EEXIST') throw new Error('pending_receipt_unavailable'); }
  }
  let stat;
  try { stat = await lstat(directory); } catch (error) {
    if (error.code !== 'ENOENT' || create) throw new Error('pending_receipt_unavailable');
  }
  if (stat && (!stat.isDirectory() || stat.isSymbolicLink() || process.getuid && (stat.uid !== process.getuid() || (stat.mode & 0o077) !== 0))) {
    throw new Error('unsafe_pending_directory');
  }
  return join(directory, createHash('sha256').update(config.origin + '\n' + config.pluginId).digest('hex') + '.json');
}
async function readPending(path) {
  let handle;
  try {
    handle = await open(path, constants.O_RDONLY | (constants.O_NOFOLLOW ?? 0));
    const stat = await handle.stat();
    if (!stat.isFile() || stat.size > 1024) return {unknown: true};
    const value = JSON.parse(await handle.readFile('utf8'));
    return value?.format === 1 && typeof value.receipt === 'string' && /^[a-f0-9-]{36}$/.test(value.receipt)
      && Number.isFinite(value.expiresAt) ? value : {unknown: true};
  } catch (error) {
    if (error.code === 'ENOENT') return null;
    return {unknown: true};
  } finally { await handle?.close(); }
}
async function acquirePending(path) {
  let handle;
  const receipt = {format: 1, receipt: randomUUID(), expiresAt: Date.now() + config.loginTimeoutMs + 30_000};
  try {
    handle = await open(path, 'wx', 0o600);
    await handle.writeFile(JSON.stringify(receipt));
    return receipt;
  } catch (error) {
    if (error.code === 'EEXIST') return null;
    throw new Error('pending_receipt_unavailable');
  } finally { await handle?.close(); }
}
async function clearPending(path, receipt) {
  const current = await readPending(path);
  if (current?.receipt === receipt.receipt) await unlink(path).catch(() => {});
}
function emitPending(receipt) {
  emit('pending', {reason: 'existing_sign_in_attempt', expired: Number.isFinite(receipt?.expiresAt) && receipt.expiresAt < Date.now(),
    message: 'An earlier sign-in attempt may still be pending. Do not start another; inspect it through the connection help. Expired receipts also require explicit recovery.'});
}

async function connect() {
  const binary = await findCodex();
  if (!binary) { emit('unavailable', {reason: 'cli_unavailable'}); process.exitCode = 1; return; }
  const child = spawn(binary, ['app-server', '--listen', 'stdio://'], {stdio: ['pipe', 'pipe', 'pipe'], windowsHide: true});
  const requests = new Map();
  const completions = [];
  let sequence = 0;
  let buffer = '';
  let failure;
  let completionWait;
  let closing = false;
  let loginRequested = false;
  let ownedReceipt;
  let receiptPath;
  let terminalLogin = false;
  let signalExitCode;
  const fail = reason => {
    failure ||= new Error(reason);
    for (const {reject, timer} of requests.values()) { clearTimeout(timer); reject(failure); }
    requests.clear();
    completionWait?.reject(failure);
  };
  const interrupt = signal => { signalExitCode = signal === 'SIGINT' ? 130 : 143; fail('interrupted'); };
  const onInterrupt = () => interrupt('SIGINT');
  const onTerminate = () => interrupt('SIGTERM');
  process.once('SIGINT', onInterrupt);
  process.once('SIGTERM', onTerminate);
  child.on('error', error => fail(error.code === 'ENOENT' ? 'cli_unavailable' : 'child_exited'));
  child.on('exit', () => { if (!closing) fail('child_exited'); });
  child.stdin.on('error', () => { if (!closing) fail('child_exited'); });
  child.stdout.on('error', () => fail('child_exited'));
  child.stderr.resume(); // Child diagnostics may contain sensitive data; never forward them.
  child.stdout.setEncoding('utf8');
  child.stdout.on('data', chunk => {
    buffer += chunk;
    if (buffer.length > 1_048_576) { fail('unsupported_protocol'); return; }
    let end;
    while ((end = buffer.indexOf('\n')) !== -1) {
      const line = buffer.slice(0, end); buffer = buffer.slice(end + 1);
      let message;
      try { message = JSON.parse(line); } catch { continue; }
      if (!message || typeof message !== 'object') continue;
      const pending = requests.get(message.id);
      if (pending) {
        clearTimeout(pending.timer); requests.delete(message.id);
        if (message.error) pending.reject(new Error(message.error.code === -32601 ? 'unsupported_protocol' : 'status_unavailable'));
        else pending.resolve(message.result);
      } else if (message.method === 'mcpServer/oauthLogin/completed' && message.params && typeof message.params === 'object') {
        if (completions.length < 16) completions.push(message.params);
        completionWait?.notify();
      }
    }
  });
  const request = (method, params) => new Promise((resolve, reject) => {
    if (failure) { reject(failure); return; }
    const id = ++sequence;
    const timer = setTimeout(() => {
      requests.delete(id); reject(new Error('rpc_timeout'));
    }, config.rpcTimeoutMs);
    requests.set(id, {resolve, reject, timer});
    child.stdin.write(JSON.stringify({jsonrpc: '2.0', id, method, params}) + '\n', error => {
      if (error) fail('child_exited');
    });
  });
  const waitForCompletion = loginId => new Promise((resolve, reject) => {
    const timer = setTimeout(() => finish(new Error('sign_in_timeout')), config.loginTimeoutMs);
    const finish = error => {
      clearTimeout(timer); completionWait = undefined;
      if (error) reject(error); else resolve();
    };
    completionWait = {reject: finish, notify: () => {
      const found = completions.find(item => item.name === config.server && item.loginId === loginId);
      if (found && typeof found.success === 'boolean') {
        terminalLogin = true;
        finish(found.success ? undefined : new Error('sign_in_failed'));
      }
    }};
    if (failure) finish(failure); else completionWait.notify();
  });
  try {
    await request('initialize', {clientInfo: {name: 'connection_helper', title: 'Connection helper', version: '1.0.0'}});
    child.stdin.write(JSON.stringify({jsonrpc: '2.0', method: 'initialized'}) + '\n');
    const result = await request('mcpServerStatus/list', {serverName: config.server, detail: 'toolsAndAuthOnly'});
    if (!result || !Array.isArray(result.data)) throw new Error('unsupported_protocol');
    if (result.nextCursor || result.data.length > 1) throw new Error('server_ambiguous');
    if (!result.data.length) throw new Error('server_absent');
    const server = result.data[0];
    if (!server || server.name !== config.server || server.pluginId !== config.pluginId || server.httpOrigin !== config.origin) {
      throw new Error('invalid_server_identity');
    }
    if (server.runtimeStatus === 'disabled' || server.enabled === false) throw new Error('server_disabled');
    if (server.authStatus === 'oAuth' || server.authStatus === 'bearerToken') {
      emit('connected'); return;
    }
    if (server.authStatus !== 'notLoggedIn') throw new Error('auth_unsupported');
    receiptPath = await pendingPath(login);
    const previous = await readPending(receiptPath);
    if (previous) { emitPending(previous); return; }
    if (!login) { emit('authentication_required'); return; }
    ownedReceipt = await acquirePending(receiptPath);
    if (!ownedReceipt) { emitPending(await readPending(receiptPath)); return; }
    loginRequested = true; // An interrupted response may already have started a flow; never replay.
    const started = await request('mcpServer/oauth/login', {name: server.name, clientRegistration: 'dcr', timeoutSecs: Math.ceil(config.loginTimeoutMs / 1000)});
    if (!started || typeof started.loginId !== 'string' || !started.loginId.length || started.loginId.length > 200
        || typeof started.authorizationUrl !== 'string' || started.authorizationUrl.length > 8192) throw new Error('invalid_login_response');
    let url;
    try { url = new URL(started.authorizationUrl); } catch { throw new Error('invalid_authorization_url'); }
    if (url.protocol !== 'https:' || url.origin !== config.origin || url.username || url.password || url.hash) {
      throw new Error('invalid_authorization_url');
    }
    emit('awaiting_sign_in', {authorizationUrl: url.href, loginId: started.loginId});
    await waitForCompletion(started.loginId);
    emit('sign_in_complete');
  } catch (error) {
    const allowedReasons = ['cli_unavailable', 'child_exited', 'unsupported_protocol', 'rpc_timeout', 'status_unavailable',
      'server_absent', 'server_ambiguous', 'invalid_server_identity', 'server_disabled', 'auth_unsupported',
      'pending_receipt_unavailable', 'unsafe_pending_directory', 'invalid_login_response', 'invalid_authorization_url',
      'sign_in_timeout', 'sign_in_failed', 'interrupted'];
    const reason = error instanceof Error && allowedReasons.includes(error.message) ? error.message : 'status_unavailable';
    const blocked = ['server_absent', 'server_ambiguous', 'invalid_server_identity', 'server_disabled', 'auth_unsupported', 'sign_in_failed', 'unsafe_pending_directory'].includes(reason);
    emit(blocked ? 'blocked' : loginRequested ? 'pending' : 'unavailable', {reason,
      ...(loginRequested && !blocked ? {message: 'Sign-in may still be pending. Do not start another attempt; use the connection help to inspect its state.'} : {})});
    process.exitCode = signalExitCode || 1;
  } finally {
    closing = true;
    if (terminalLogin && ownedReceipt) await clearPending(receiptPath, ownedReceipt).catch(() => {});
    for (const {timer} of requests.values()) clearTimeout(timer);
    child.stdin.end();
    if (child.exitCode === null && child.signalCode === null) {
      child.kill('SIGTERM');
      await new Promise(resolve => {
        const timer = setTimeout(() => { child.kill('SIGKILL'); resolve(); }, 1000);
        child.once('exit', () => { clearTimeout(timer); resolve(); });
      });
    }
    child.stdout.destroy(); child.stderr.destroy(); child.stdin.destroy();
    process.removeListener('SIGINT', onInterrupt);
    process.removeListener('SIGTERM', onTerminate);
  }
}
