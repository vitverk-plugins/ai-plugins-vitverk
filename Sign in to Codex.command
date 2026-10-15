#!/bin/sh
set -eu
plugin_codex=$(command -v codex || true)
if [ -z "$plugin_codex" ]; then
  for plugin_app in /Applications/ChatGPT.app /Applications/Codex.app "$HOME/Applications/ChatGPT.app" "$HOME/Applications/Codex.app"; do
    if [ -x "$plugin_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex" ]; then plugin_codex="$plugin_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"; break; fi
    if [ -x "$plugin_app/Contents/Resources/codex" ]; then plugin_codex="$plugin_app/Contents/Resources/codex"; break; fi
  done
fi
if [ -z "$plugin_codex" ]; then printf 'Install Codex first, then reopen this sign-in launcher.\n' >&2; exit 1; fi
printf 'Signing Codex in to %s\nKeep this window open. In your browser, sign in and click Connect.\nIf no browser opens, use the authorization URL printed below.\n' 'https://os.vitverk.is'
plugin_status=0
"$plugin_codex" mcp login 'vitverk' --oauth-client-registration dcr || plugin_status=$?
if [ "$plugin_status" -eq 0 ]; then
  printf '\nSign-in complete. Start a new Codex chat and ask to confirm the instance and list accessible resources without changes.\n'
else
  printf '\nSign-in did not finish. Read the error above and reopen this launcher to retry.\n'
fi
if [ -t 0 ]; then printf 'Press Enter to close.'; read -r plugin_answer || true; fi
exit "$plugin_status"
