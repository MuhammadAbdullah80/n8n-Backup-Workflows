#!/usr/bin/env bash
#
# Exports every workflow and credential from an n8n instance into a timestamped,
# git-tracked directory. Designed to run unattended from cron, so it fails loudly
# and never leaves a half-written backup behind.

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

usage() {
	cat <<'USAGE'
usage: backup.sh [-o DIR] [-k COUNT] [-n]

  -o DIR    output directory (default: <repo>/backups)
  -k COUNT  keep only the newest COUNT backups (default: 14)
  -n        dry run: show what would happen, write nothing

Requires N8N_HOST and N8N_API_KEY in the environment.
USAGE
}

main() {
	local out_dir="${REPO_ROOT}/backups"
	local keep=14
	local dry_run=0

	while getopts ':o:k:nh' opt; do
		case "${opt}" in
			o) out_dir="${OPTARG}" ;;
			k) keep="${OPTARG}" ;;
			n) dry_run=1 ;;
			h) usage; return 0 ;;
			:) die "option -${OPTARG} requires an argument" ;;
			?) die "unknown option -${OPTARG}" ;;
		esac
	done

	require_command curl
	require_command jq
	require_env N8N_HOST
	require_env N8N_API_KEY

	if ! [[ "${keep}" =~ ^[0-9]+$ ]] || (( keep < 1 )); then
		die "-k expects a positive integer, got '${keep}'"
	fi

	local stamp; stamp="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
	local target="${out_dir}/${stamp}"

	if (( dry_run )); then
		log "dry run: would write ${target}"
		fetch_resource workflows | jq -r '"  would save \(.data | length) workflow(s)"'
		return 0
	fi

	# Assemble in a temp dir and move into place at the end, so an interrupted
	# run never leaves a partial backup that looks complete.
	local staging; staging="$(mktemp -d)"
	trap 'rm -rf "${staging}"' EXIT

	log "exporting from ${N8N_HOST}"
	save_resource workflows "${staging}/workflows.json"
	save_resource credentials "${staging}/credentials.json"
	write_manifest "${staging}" "${stamp}"

	mkdir -p "${out_dir}"
	mv "${staging}" "${target}"
	trap - EXIT
	chmod 700 "${target}"

	log "wrote ${target}"
	prune_old_backups "${out_dir}" "${keep}"
}

main "$@"
