#!/bin/sh
set -eu
umask 077
plugin_source=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
plugin_name='vitverk'
printf 'Installing the plugin for %s\n' 'https://vinnslan.vitverk.is'
plugin_client=codex
if [ "$#" -gt 0 ]; then plugin_client="$1"; fi
case "$plugin_client" in codex|claude) ;; *) printf 'Choose codex or claude.\n' >&2; exit 1;; esac
if [ "$plugin_client" = codex ]; then
plugin_codex=$(command -v codex || true)
if [ -z "$plugin_codex" ]; then
  for plugin_app in /Applications/ChatGPT.app /Applications/Codex.app "$HOME/Applications/ChatGPT.app" "$HOME/Applications/Codex.app"; do
    if [ -x "$plugin_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex" ]; then plugin_codex="$plugin_app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"; break; fi
    if [ -x "$plugin_app/Contents/Resources/codex" ]; then
      plugin_codex="$plugin_app/Contents/Resources/codex"
      break
    fi
  done
fi
if [ -z "$plugin_codex" ]; then
  printf 'Codex was not found. Install Codex first, then run this installer again.\nhttps://learn.chatgpt.com/docs/cli\n' >&2
  exit 1
fi
plugin_cli="$plugin_codex"
else
  plugin_cli=$(command -v claude || true)
  if [ -z "$plugin_cli" ] && [ -x "$HOME/.local/bin/claude" ]; then plugin_cli="$HOME/.local/bin/claude"; fi
  if [ -z "$plugin_cli" ]; then
    printf 'Claude Code was not found. Install Claude Code first, then run this installer again.\nhttps://code.claude.com/docs/en/setup\n' >&2
    exit 1
  fi
fi
plugin_home=$(printenv VINNSLAN_PLUGIN_HOME || true)
if [ -z "$plugin_home" ]; then plugin_home="$HOME/.local/share/vinnslan/plugins"; fi
plugin_target="$plugin_home/$plugin_name"
mkdir -p "$plugin_home"
if [ -e "$plugin_target" ] || [ -L "$plugin_target" ]; then
  if [ -L "$plugin_target" ] || [ ! -f "$plugin_target/.vinnslan-installer" ] || [ "$(cat "$plugin_target/.vinnslan-installer")" != "$plugin_name" ]; then
    printf 'Refusing to replace an unmanaged folder: %s\n' "$plugin_target" >&2
    exit 1
  fi
else
  mkdir "$plugin_target"
  printf '%s\n' "$plugin_name" > "$plugin_target/.vinnslan-installer"
fi
for plugin_path in .agents .claude-plugin plugins README.md "Sign in to Codex.command"; do
  if [ -L "$plugin_target/$plugin_path" ]; then printf 'Refusing a linked installation folder.\n' >&2; exit 1; fi
done
cp -R "$plugin_source/.agents" "$plugin_target/"
cp -R "$plugin_source/.claude-plugin" "$plugin_target/"
cp -R "$plugin_source/plugins" "$plugin_target/"
cp "$plugin_source/README.md" "$plugin_target/README.md"
cp "$plugin_source/Sign in to Codex.command" "$plugin_target/"
if [ "$plugin_client" = codex ]; then
  if [ ! -f "$plugin_target/.codex-registered" ]; then
    "$plugin_cli" plugin marketplace add "$plugin_target"
    : > "$plugin_target/.codex-registered"
  fi
  "$plugin_cli" plugin add "$plugin_name@$plugin_name"
printf '\nInstalled. Open this sign-in launcher to connect your account:\n%s/Sign in to Codex.command\n' "$plugin_target"
printf 'Then start a new Codex task. You can delete the extracted download.\n'
else
  if [ ! -f "$plugin_target/.claude-registered" ]; then
    "$plugin_cli" plugin marketplace add "$plugin_target" --scope user
    : > "$plugin_target/.claude-registered"
  else
    "$plugin_cli" plugin marketplace update "$plugin_name"
  fi
  if [ -f "$plugin_target/.claude-plugin-installed" ]; then
    "$plugin_cli" plugin update "$plugin_name@$plugin_name" --scope user
  else
    "$plugin_cli" plugin install "$plugin_name@$plugin_name" --scope user
    : > "$plugin_target/.claude-plugin-installed"
  fi
  printf '\nInstalled. Restart Claude Code, enter /mcp, select the plugin server containing %s, then choose Authenticate. In the browser, sign in and click Connect.\n' "$plugin_name"
fi
if [ -t 0 ]; then printf '\nPress Enter to close.'; read -r plugin_answer || true; fi
