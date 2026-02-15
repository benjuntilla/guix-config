---
name: address-pr-comments
description: Use `~/.local/bin/gh` CLI and its graphQL api to address review comments on PR
---
In the current directory, use `~/.local/bin/gh` CLI and its graphQL api to address review comments on current PR. If user is on main, ask them what PR they'd like to work on. You should use the appropriate graphQL filters to find unresolved review comments. Implement the suggested changes if they're valid, split them up into commits that make sense, push them up, and use graphQL api to resolve the comments.
