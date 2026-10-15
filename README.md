# Vitverk

This package connects only to https://os.vitverk.is/mcp. It contains workflow skills and public packaging
metadata, never credentials, private company context, operational data or permissions.
Set up, review connected clients, change permissions or revoke at https://os.vitverk.is/external-access/mcp.
Each instance has a distinct plugin, server and catalog name that stays stable across updates.

## Claude

In claude.ai or the Claude desktop app, open **Customize → Plugins → Add marketplace**, add
https://github.com/vitverk-plugins/ai-plugins-vitverk, and install **Vitverk**. Open the plugin's **Connectors** tab, choose **Connect**,
sign in to https://os.vitverk.is, review permissions and choose **Connect**. A plugin added there also loads in
Claude Code. Then ask `/vitverk` or **Set up my Vitverk connection** in a new chat.

For Claude Code alone, run `/plugin marketplace add` with https://github.com/vitverk-plugins/ai-plugins-vitverk, then
`/plugin install vitverk@vitverk`, and authenticate the server in `/mcp`. Without a repository,
upload this instance's single-plugin ZIP in **Customize → Plugins**, or keep this extracted folder and
run `claude plugin marketplace add . --scope user` and `claude plugin install vitverk@vitverk --scope user`.
Connection help: https://os.vitverk.is/external-access/mcp/connect?client=claude

## Codex

Copy https://github.com/vitverk-plugins/ai-plugins-vitverk, open **Plugins → Add marketplace** and paste it. On the **Personal** tab, install
**Vitverk**, then run its setup skill. If connecting needs help, open https://os.vitverk.is/external-access/mcp/connect, choose **Copy setup prompt**
and send it in a Codex chat, or use https://os.vitverk.is/external-access/mcp/connect?method=manual for the Settings steps.
An agent with Node.js and the Codex CLI can check the connection with
`node plugins/vitverk/scripts/connect-codex.mjs --check`, and only after `authentication_required`
start one sign-in with `--login`. Account sign-in and permission review stay with you.

Without a repository, keep this extracted folder and run `codex plugin marketplace add .` and
`codex plugin add vitverk@vitverk`, or open **Install Codex.command** / **Install Codex.cmd**.
For an existing separately configured server at this exact origin, the DCR fallback is
`codex mcp login vitverk --oauth-client-registration dcr`.

## Permissions

Consent separately to workspace discovery, company context, business reads, development, outputs,
automation, commerce and delivery. Existing gadget access grants none of these automatically, and
consent never changes staff roles or bypasses approvals, review or promotion controls. Refresh tools
or start a new chat after permission changes. Returned data leaves Vitverk's sandbox.
