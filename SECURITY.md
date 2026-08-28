# Security Policy

Agent Continuity is a documentation workflow and local tooling kit. It should not
collect credentials, require long-lived tokens in command lines, or overwrite
project-owned Markdown without explicit user intent.

## Supported Versions

Security fixes apply to the latest tagged release and to `main`, where a fix may
land before the next release.

| Version | Supported |
|---|---|
| `2026.08.26.1` | Yes |
| Earlier versions | No |

## Reporting A Vulnerability

Please report security issues privately before opening a public issue.

- If GitHub private vulnerability reporting is enabled for this repository, use
  that channel.
- Otherwise, contact the repository owner through a private channel and include
  a minimal reproduction, affected command or file path, and impact.

Do not include secrets, private repository URLs, tokens, or customer data in
public issues, pull requests, logs, or screenshots.

## Security-Sensitive Areas

Reports are especially useful when they involve:

- installer behavior that writes unexpectedly;
- target-path traversal, symlink writes, or writes outside the selected repo;
- commands that expose tokens in shell history, process listings, logs, or docs;
- release archives that accidentally include ignored caches, credentials, or
  machine-local files;
- upgrade behavior that could overwrite project-owned Markdown.

## Safe Defaults

Public install and update flows should remain preview-first. Any write mode
should require explicit user intent, preserve local project truth, and show
actionable diagnostics when safety cannot be proven.
