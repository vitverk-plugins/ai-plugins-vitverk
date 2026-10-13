---
name: site
description: Make a change to the Vitverk website in a hosted box and return a review packet, without submitting it.
argument-hint: "<change>"
context: fork
agent: vitverk:website-developer
disable-model-invocation: true
---

# Website change for Vitverk

Make this website change and check it in its preview: $ARGUMENTS

Return the review packet; do not submit.

If the vitverk:website-developer subagent is unavailable, follow this plugin's own workflow skill directly.
