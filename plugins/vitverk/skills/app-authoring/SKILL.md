---
name: app-authoring
description: Create and edit Vitverk app drafts, outputs and persistent workflow code directly from this chat.
---

# Vitverk — app-authoring

Use only this plugin's Vitverk connection, MCP server `vitverk` at https://vinnslan.vitverk.is/mcp.
Tool names below omit the server's instance prefix; match each tool by its name's ending.
Fetch private context live. Plugin files never confer permissions. Each capability requires separate
native consent at https://vinnslan.vitverk.is/external-access/mcp. Existing gadget consent grants none of these.
Data returned to this chat leaves Vitverk's sandbox; Vitverk cannot restrict its subsequent use.
Never put operational data, private documents, tokens or infrastructure credentials in this package.
Work only through this connection's tools. Never open https://vinnslan.vitverk.is in a browser or drive its interface
with browser or computer-use tools; when no tool covers a step, say what is missing and give the user
the link to do it there.


Before writing or changing an app, read app_guide: Vitverk's own guide for its workspace agent, this
deployment's instructions, and which tool here does what each agent tool it names does. Read its
further topics as the work needs them rather than all at once, and read a platform library's
declarations and documentation with app_library before using that library.
Use app_start_draft in an existing authorized build workspace, or in one made with create_workspace
when the user asks for a new workspace, then app_create for a provisional app or edit an existing gadget. A null model prevents Vitverk's built-in editing agent from starting.
Record returned IDs immediately. Never automatically replay interrupted draft/app creation; inspect
the native workspace first. Read draft_status, pinned commits and exact source before editing.
For write_file preserve clientId and monotonically increasing seq, with only one submission in flight.
Retry transport loss only with the same seq and identical payload. Permanent unpinned gadgets need
the current accepted baseCommit. Native OT handles concurrent changes and rejects invalid history.
Follow any of the Context Library's agent skills that covers the app (see the company skill).
Bind only existing authorized resources, with separate category consent. Run native validation and
hermetic tests at the exact generation/revision. Inspect the app in its native preview sandbox;
a UI bundle URL needs the Vitverk host and is not a standalone public website. Accept the reviewed
position through app_accept; conflicts and native validation remain authoritative.
Output access requires outputs consent. List export formats, then export accepted output contents.
Inline exports are bounded; use the native output link for larger files.
Persistent schedules and portal tools use register_workflow with the accepted callback gadget's
commitId and restore params. Read automation_resource_api for recurrence and options; include an
explicit timezone for calendar schedules. Retain its requestId and inspect its receipt after a lost
reply. Unknown registration never permits a new request ID to repeat it.
Registration remains disabled until the user enables its hook in native Connections. Portal audience
assignment remains native. Do not substitute a client-side scheduled task or automation: execution
belongs in Vitverk and must continue with this chat closed.
