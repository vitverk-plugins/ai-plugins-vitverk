---
name: report
description: Answer a question about Vitverk's company data with a sourced, read-only report.
argument-hint: "<question>"
context: fork
agent: vitverk:analyst
disable-model-invocation: true
---

# Report for Vitverk

Answer this from Vitverk's data, read-only: $ARGUMENTS

If the vitverk:analyst subagent is unavailable, follow this plugin's own workflow skill directly.
