#!/bin/sh
set -eu
umask 077
vinnslan_source=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
vinnslan_name='vitverk'
printf 'Installing Vinnslan for %s\n' 'https://vinnslan.vitverk.is'
vinnslan_client=codex
if [ "$#" -gt 0 ]; then vinnslan_client="$1"; fi
case "$vinnslan_client" in codex|claude) ;; *) printf 'Choose codex or claude.\n' >&2; exit 1;; esac
if [ "$vinnslan_client" = codex ]; then
vinnslan_codex=$(command -v codex || true)
if [ -z "$vinnslan_codex" ]; then
  for vinnslan_app in /Applications/ChatGPT.app /Applications/Codex.app "$HOME/Applications/ChatGPT.app" "$HOME/Applications/Codex.app"; do
    if [ -x "$vinnslan_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex" ]; then vinnslan_codex="$vinnslan_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"; break; fi
    if [ -x "$vinnslan_app/Contents/Resources/codex" ]; then
      vinnslan_codex="$vinnslan_app/Contents/Resources/codex"
      break
    fi
  done
fi
if [ -z "$vinnslan_codex" ]; then
  printf 'Codex was not found. Install Codex first, then run this installer again.\nhttps://learn.chatgpt.com/docs/cli\n' >&2
  exit 1
fi
vinnslan_cli="$vinnslan_codex"
else
  vinnslan_cli=$(command -v claude || true)
  if [ -z "$vinnslan_cli" ] && [ -x "$HOME/.local/bin/claude" ]; then vinnslan_cli="$HOME/.local/bin/claude"; fi
  if [ -z "$vinnslan_cli" ]; then
    printf 'Claude Code was not found. Install Claude Code first, then run this installer again.\nhttps://code.claude.com/docs/en/setup\n' >&2
    exit 1
  fi
fi
vinnslan_home=$(printenv VINNSLAN_PLUGIN_HOME || true)
if [ -z "$vinnslan_home" ]; then vinnslan_home="$HOME/.local/share/vinnslan/plugins"; fi
vinnslan_target="$vinnslan_home/$vinnslan_name"
mkdir -p "$vinnslan_home"
if [ -e "$vinnslan_target" ] || [ -L "$vinnslan_target" ]; then
  if [ -L "$vinnslan_target" ] || [ ! -f "$vinnslan_target/.vinnslan-installer" ] || [ "$(cat "$vinnslan_target/.vinnslan-installer")" != "$vinnslan_name" ]; then
    printf 'Refusing to replace an unmanaged folder: %s\n' "$vinnslan_target" >&2
    exit 1
  fi
else
  mkdir "$vinnslan_target"
  printf '%s\n' "$vinnslan_name" > "$vinnslan_target/.vinnslan-installer"
fi
for vinnslan_path in .agents .claude-plugin plugins README.md "Sign in to Codex.command"; do
  if [ -L "$vinnslan_target/$vinnslan_path" ]; then printf 'Refusing a linked installation folder.\n' >&2; exit 1; fi
done
cp -R "$vinnslan_source/.agents" "$vinnslan_target/"
cp -R "$vinnslan_source/.claude-plugin" "$vinnslan_target/"
cp -R "$vinnslan_source/plugins" "$vinnslan_target/"
cp "$vinnslan_source/README.md" "$vinnslan_target/README.md"
cp "$vinnslan_source/Sign in to Codex.command" "$vinnslan_target/"
if [ "$vinnslan_client" = codex ]; then
  if [ ! -f "$vinnslan_target/.codex-registered" ]; then
    "$vinnslan_cli" plugin marketplace add "$vinnslan_target"
    : > "$vinnslan_target/.codex-registered"
  fi
  "$vinnslan_cli" plugin add "$vinnslan_name@$vinnslan_name"
printf '\nInstalled. Open this sign-in launcher to connect your account:\n%s/Sign in to Codex.command\n' "$vinnslan_target"
printf 'Then start a new Codex task. You can delete the extracted download.\n'
else
  if [ ! -f "$vinnslan_target/.claude-registered" ]; then
    "$vinnslan_cli" plugin marketplace add "$vinnslan_target" --scope user
    : > "$vinnslan_target/.claude-registered"
  else
    "$vinnslan_cli" plugin marketplace update "$vinnslan_name"
  fi
  if [ -f "$vinnslan_target/.claude-plugin-installed" ]; then
    "$vinnslan_cli" plugin update "$vinnslan_name@$vinnslan_name" --scope user
  else
    "$vinnslan_cli" plugin install "$vinnslan_name@$vinnslan_name" --scope user
    : > "$vinnslan_target/.claude-plugin-installed"
  fi
  printf '\nInstalled. Restart Claude Code, enter /mcp, select the plugin server containing %s, then choose Authenticate. In the browser, sign in and click Connect.\n' "$vinnslan_name"
fi
if [ -t 0 ]; then printf '\nPress Enter to close.'; read -r vinnslan_answer || true; fi
