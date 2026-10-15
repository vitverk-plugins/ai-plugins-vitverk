---
name: setup
description: Set up or diagnose the Vitverk plugin, sign in when needed, and verify accessible capabilities without changing customer data.
---

# Set up Vitverk

This is the Vitverk plugin. It targets only https://os.vitverk.is/mcp, with MCP server name `vitverk`.
Tool names below omit the server's instance prefix; match each tool by its name's ending.
A setup request authorizes connection checks and starting sign-in, not choosing permissions,
reading private document contents, changing customer data or granting additional access.

## Check the connection first

Use available host tool discovery (including deferred tools) to find this instance's tools.
Call get_instance when available and verify the returned origin before using other tools. Then
check accessible workspace, website-project and resource metadata as available and consented.
Start workspace discovery with list_workspaces({}). For paginated checks, omit limit
to use the default page size and follow nextCursor until absent.
Keep these checks light: list resources for a few workspaces at a time rather than every workspace
and category at once, and summarize the rest by name. Do not read document contents or run reports
during setup. If connected, say so briefly; reuse that connection instead of starting another login.
Run these checks yourself in this conversation. Do not hand setup to a subagent: it reaches no more
than you do, and its failure hides the cause.

## If tools are missing

In the Claude desktop app or claude.ai chat, a plugin connector that is not connected yet offers no
tools at all, which is the most common cause there. Ask the human to open
**Customize → Plugins → Vitverk → Connectors** and tell you what the `vitverk` connector shows:
- **Connect** or **Not added**: choose **Connect**, keep Claude's defaults in the dialog that opens
  (**Sign in now** and **Use Claude's published identity**) and choose **Add**, then sign in to
  https://os.vitverk.is, review access and choose **Connect**. Updating or reinstalling the plugin does not help here.
- **Connected**: tools load only in a chat started after connecting, so ask them to send their
  request again in a new chat. If tools are still missing there, the server is failing to load:
  follow the recovery below.
- No connector listed: the installed plugin is incomplete; follow the recovery below.

Otherwise, and in Claude Code and Codex, check the installed plugin and its bundled MCP server
through supported host/plugin diagnostics. A plugin can load skills while failing to load its server.
Do not ask the user to authenticate a server you have not found.

If the installed plugin resolves zero servers, refresh its marketplace and update that existing
plugin using supported host controls when available (in Claude chat, **Customize → Plugins → Add →
Manage marketplaces**, then **Check for updates**). Do not add a separate MCP server or reinstall
another copy. Confirm server discovery after the update. If a host refresh or new chat is needed,
ask only for that next action; do not give a sign-in checklist before the server is available.

## Help finish sign-in

Follow the instructions for the client you are running in:

- Codex (the ChatGPT desktop app or the Codex CLI): [codex.md](codex.md)
- Claude (Claude Code, the Claude desktop app or claude.ai): [claude.md](claude.md)

Ask the human to complete account sign-in and review permissions on https://os.vitverk.is. This does not prevent
you from initiating login, checking status or finishing the remaining setup. Request only the user
action currently needed; keep permission selection and the final Connect click with them. Explain
only permissions relevant to their intended work. Returned data leaves Vitverk's sandbox.
Never ask for secrets in chat or manufacture a login URL. Do not create parallel login attempts or
replay a pending login. After approval, a blocked callback can use “finish signing in” on the approval
page; restart only an expired or definitively failed request.

## Verify and finish

Refresh discovery and repeat missing read-only checks. A successful authenticated tool result
verifies access; browser approval alone does not. Preserve successful checks when another fails.
Report the confirmed instance and useful available capabilities briefly.

After a successful first setup, suggest two or three things to try next as prompts the user can send
as written, each using something this connection actually reached. For example:
- with company context: "Search Vitverk's context for <a topic from a collection's title> and summarize it";
- with business data: "Show yesterday's sales by channel";
- with a website project: "Make a small text change on <the project's site> and show me the preview";
- with an enabled app's tools: "List my <the app's items>";
- with workspaces only: "What apps do I have in <a workspace>?".
Prefer safe, read-only first steps. Name real workspaces, collections, projects or apps from the
checks; never invent them. Mention a missing permission,
owner enablement or resource assignment only when it blocks the requested next action; do not present
a long list of unchecked categories. Existing roles, reviews, hook enablement and promotion controls
still apply. When blocked, state the concrete cause and next action instead of quoting this skill's
consent boundaries as a reason to stop helping.
