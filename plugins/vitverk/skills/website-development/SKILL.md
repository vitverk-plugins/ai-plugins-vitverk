---
name: website-development
description: Develop the Vitverk website in Vitverk's hosted development boxes from an ordinary chat, without SSH or a local checkout.
---

# Vitverk — website-development

Use only this plugin's Vitverk connection, MCP server `vitverk` at https://os.vitverk.is/mcp.
Tool names below omit the server's instance prefix; match each tool by its name's ending.
Fetch private context live. Plugin files never confer permissions. Each capability requires separate
native consent at https://os.vitverk.is/external-access/mcp. Existing gadget consent grants none of these.
Data returned to this chat leaves Vitverk's sandbox; Vitverk cannot restrict its subsequent use.
Never put operational data, private documents, tokens or infrastructure credentials in this package.
Work only through this connection's tools. Never open https://os.vitverk.is in a browser or drive its interface
with browser or computer-use tools; when no tool covers a step, say what is missing and give the user
the link to do it there.

List currently accessible website projects.
Before changing a website, read website_guide: how Vitverk's own Develop agent works on it, with this
connection's tools, and the instructions its admins wrote. Then list_website_sessions: continue a session
this connection controls by its chatId. To continue one
controlled from another connection or from Develop, ask the user, then website_take_over. Otherwise use
start_website_session with a new request ID, a random UUID you write yourself (no tool is needed), then
status until ready. This external session never starts Vitverk's built-in editing agent. All files, commands, logs and submission use plugin tools.
No SSH session, local checkout, customer cloud login or infrastructure key is needed or appropriate.
Read files with their fileRevision and session revision. Change part of a file with website_edit_file
(exact text), and write whole files with website_write_file (append for files over 32 000 characters),
each against both revisions. Reconcile conflicts by rereading. Keep one mutation in flight; retain every request ID and receipt.
Commands return a tracked job. Poll website_job until terminal, and use cancel_job when necessary.
A disconnected request, timeout, unknown job or missing reply is not permission to rerun a command.
Inspect website_operation and job first. Reuse an ID only with its identical original payload.
A write of unknown outcome is settled by website_operation, which rereads its file; an unknown submission
holds the writer for inspection. Never work around either by replaying under a new ID. An older runtime without commandJobs support must be updated by the operator.
Check your work as a visitor would with website_inspect: its outline gives refs, its steps click, fill,
scroll and follow links, and fullPage shows a whole page; check both phone and desktop. Restart the dev
servers with website_restart_preview when a change needs it. Inspect preview status, logs and every
changed file, including omitted/binary changes. Submit the exact
checkoutRevision returned by changes, with the current session revision. Native automated review
and PR checks still apply. Share the preview and PR for review. After submitting, follow it with
website_status: its review findings to fix and submit again, the needsUser link when people must approve
it (only they can), and once merged, where it is on its way to the live site. website_retry tries a
failed setup or review again. Submission grants no promotion permission. Delivery tools require separate consent and the existing technical-admin group; inspect
promotion_plan for the exact SHA and never bypass review or switch environments to avoid a gate.
