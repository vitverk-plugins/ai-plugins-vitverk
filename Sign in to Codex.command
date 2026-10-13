#!/bin/sh
set -eu
vinnslan_codex=$(command -v codex || true)
if [ -z "$vinnslan_codex" ]; then
  for vinnslan_app in /Applications/ChatGPT.app /Applications/Codex.app "$HOME/Applications/ChatGPT.app" "$HOME/Applications/Codex.app"; do
    if [ -x "$vinnslan_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex" ]; then vinnslan_codex="$vinnslan_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"; break; fi
    if [ -x "$vinnslan_app/Contents/Resources/codex" ]; then vinnslan_codex="$vinnslan_app/Contents/Resources/codex"; break; fi
  done
fi
if [ -z "$vinnslan_codex" ]; then printf 'Install Codex first, then reopen this sign-in launcher.\n' >&2; exit 1; fi
printf 'Signing Codex in to %s\nKeep this window open. In your browser, sign in and click Connect.\nIf no browser opens, use the authorization URL printed below.\n' 'https://vinnslan.vitverk.is'
vinnslan_status=0
"$vinnslan_codex" mcp login 'vitverk' --oauth-client-registration dcr || vinnslan_status=$?
if [ "$vinnslan_status" -eq 0 ]; then
  printf '\nSign-in complete. Start a new Codex chat and ask to confirm the instance and list accessible resources without changes.\n'
else
  printf '\nSign-in did not finish. Read the error above and reopen this launcher to retry.\n'
fi
if [ -t 0 ]; then printf 'Press Enter to close.'; read -r vinnslan_answer || true; fi
exit "$vinnslan_status"
