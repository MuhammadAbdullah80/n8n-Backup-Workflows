# Contributing

## Getting set up

```sh
bash -n scripts/*.sh
shellcheck scripts/*.sh
```

Bash 4+, with `curl` and `jq` on PATH. Every script uses `set -euo pipefail` — a backup that fails must exit non-zero so cron reports it rather than logging a success it did not achieve.

## Before opening a pull request

- The test command above passes
- New behaviour has a test alongside it
- Public functions carry a comment saying *why*, not restating the signature

## Commit messages

Explain why the change is needed. The diff already says what it does.
