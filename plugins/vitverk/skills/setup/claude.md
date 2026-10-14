# Finish connecting Vitverk in Claude

Claude signs in through its own connection controls; there is no helper script to run.
Each Claude surface keeps its own sign-in, and each is a separate connection in Vitverk.

## Claude Code (terminal, IDE or the desktop app's Code tab)

The plugin's server is listed in `/mcp` as `plugin:vitverk:vitverk`. When it needs
authentication, use a supported authenticate action for that server if one is available to you.
Otherwise ask the human to enter `/mcp`, select that server and choose **Authenticate**, then
complete sign-in in the browser. Verify with get_instance afterwards. In the desktop app's Code tab
too, sign in through `/mcp`: the app's connector settings keep a separate sign-in that Code
sessions do not use, so a connection made there can show as connected while this server still asks
for authentication.

If the server is missing, ask the human to check the Vitverk plugin under `/plugin` and run
`/reload-plugins`, or update the plugin from its marketplace. Do not add a second server with
`claude mcp add` while the plugin is installed.

## Claude desktop app and claude.ai chat

Plugins are under **Customize → Plugins**. Open **Vitverk**, then its **Connectors** tab, and
choose **Connect**. Keep the dialog's defaults (**Sign in now** and
**Use Claude's published identity**) and choose **Add**. In the browser, sign in to https://vinnslan.vitverk.is,
review access and choose **Connect**. Tools load in a new chat. A connector added separately under **Customize → Connectors** for the
same address is a second connection; prefer the plugin's own.

If the human needs the steps on screen, share [Finish connecting Claude](https://vinnslan.vitverk.is/external-access/mcp/connect?client=claude&method=manual).
Opening this help page does not start OAuth.
