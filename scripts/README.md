# Backup scripts

The JSON exports at the repo root were being produced by hand. These scripts do
it unattended, so the backup is current rather than current as of whenever
someone last remembered.

## Setup

```sh
export N8N_HOST=https://n8n.example.com
export N8N_API_KEY=...        # Settings -> API in the n8n UI
```

Both scripts need `curl` and `jq`.

## Backing up

```sh
./scripts/backup.sh                 # write to ./backups, keep the newest 14
./scripts/backup.sh -o /mnt/nas -k 30
./scripts/backup.sh -n              # dry run
```

Each run writes `backups/<UTC timestamp>/` containing `workflows.json`,
`credentials.json` and a `manifest.json` recording the host and item counts.

Two details that matter for unattended runs:

- The backup is assembled in a temp directory and moved into place at the end,
  so an interrupted run never leaves a partial backup that looks complete.
- Exports are written with `jq --sort-keys`, so successive backups produce a
  readable diff instead of noise from key reordering.

The API paginates at 250 items; `fetch_resource` follows the cursor to the end
rather than silently capturing only the first page.

## Restoring

```sh
./scripts/restore.sh backups/2026-08-25T09-00-00Z            # dry run
./scripts/restore.sh --apply backups/2026-08-25T09-00-00Z
```

Restore is a dry run unless `--apply` is passed. Workflow `id`, `createdAt` and
`updatedAt` are stripped before POSTing, since the target instance assigns them.

## Cron

```cron
0 3 * * * cd /srv/n8n-Backup-Workflows && ./scripts/backup.sh >> /var/log/n8n-backup.log 2>&1
```

`set -euo pipefail` throughout means a failure exits non-zero and cron will
report it rather than logging a success it did not achieve.

## Note on credentials

`credentials.json` contains encrypted credential data from your instance. The
backup directory is created `0700`. Do not commit real backups to a public repo.
