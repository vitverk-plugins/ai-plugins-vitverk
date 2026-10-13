# Finish connecting Vitverk in Codex

CLI versions differ in plugin support; a negative standalone mcp get/list result does not prove a
plugin-owned server is absent or unauthenticated. Prefer the bundled plugin-aware helper below.

For a discovered server that needs authentication, initiate the host's supported login action when
available. Otherwise use the bundled connection helper when Node is available; it finds the existing
CLI or a bundled macOS app-server executable without requiring a terminal step from the user.
From this installed plugin's root, run `node scripts/connect-codex.mjs --check`; the script is at
`../../scripts/connect-codex.mjs` relative to this skill's directory. An available host runtime tool
can supply Node's path. Do not install a runtime or CLI to complete setup.

The helper checks the installed plugin identity and origin through Codex's public app-server API.
`connected` confirms helper-side authentication; still verify this chat's tools. Only
`authentication_required` calls for running the same helper with `--login`, once. Keep that command
and its subprocess session alive. On `awaiting_sign_in`, open its exact returned authorizationUrl
in the built-in browser and ask the human to sign in, review access and click Connect. Track the
matching completion; then refresh discovery and verify authenticated tools. Never reconstruct a
login URL or automatically replay a pending/interrupted helper. `pending` requires inspecting the
existing command before any restart; an expired receipt still needs manual recovery. `unavailable` or `blocked` calls for the manual page below.
A successful browser approval or helper completion alone does not prove this chat has loaded tools.

If the host exposes only a connection control, guide the user to that installed plugin's
Connect/Authenticate control, using the actual displayed name.

In Codex desktop, when the installed plugin and bundled endpoint are verified but this chat cannot
use its tools or operate connection controls, open [Finish connecting Codex](https://vinnslan.vitverk.is/external-access/mcp/connect?method=manual)
in the built-in browser when no supported login action or helper is available. Use an available
browser-opening tool such as open_in_codex with a browser URL target; reuse this instance's tab when possible. This dedicated page shows only the connection steps.
Give one concrete next action: click [Open Codex settings](codex://settings), choose **MCP servers**,
and find the existing server shown on that page. Select **Authenticate** if offered. Name the plugin
**Vitverk** in the message and keep the help link visible. If the server is missing or disabled,
ask for that state and refresh/enable the existing plugin through supported controls. Missing tools
alone do not prove the user is signed out or denied access. Opening this help page does not start OAuth.

The native Settings link is for the human to click; do not pass it to a tool that only supports web
URLs. If no built-in browser tool is available, provide the help link and the same next action.

Use a CLI login only for an existing separately configured server whose name and endpoint you
have verified. In that case, start and track
`codex mcp login vitverk --oauth-client-registration dcr` if the CLI is already available.
Do not install a CLI or use this command as a probe for plugin-owned servers.
