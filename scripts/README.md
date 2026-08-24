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

## Legacy exports

The JSON files at the repository root predate these scripts and were produced by
hand. They are kept for reference but are not written or read by anything here;
`backup.sh` writes to `backups/` instead. See #5.

## Note on credentials

`credentials.json` contains credential data from your instance. It is protected
only by directory permissions (`0700`) — it is **not** encrypted at rest by
these scripts, which is tracked in #2.

Two consequences worth being explicit about:

- `backups/` is in `.gitignore`. Do not force-add it. This repository is public.
- Storing backups anywhere shared (a NAS, object storage, a synced folder) means
  storing credential material there in the clear. Wait for #2, or encrypt the
  directory yourself before it leaves the host.
