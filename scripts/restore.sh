#!/usr/bin/env bash
#
# Restores workflows from a backup directory produced by backup.sh. Defaults to
# a dry run: nothing is written to the instance unless --apply is passed.

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

usage() {
	cat <<'USAGE'
usage: restore.sh [--apply] BACKUP_DIR

  --apply   actually POST the workflows (default is a dry run)

Requires N8N_HOST and N8N_API_KEY in the environment.
USAGE
}

# Names of workflows that could not be restored, collected across the run.
declare -a FAILED=()

# POSTs one workflow. A failure is recorded and the run continues: aborting
# midway leaves the instance half-populated with no record of what landed.
push_workflow() {
	local payload="$1" name
	name="$(printf '%s' "${payload}" | jq -r '.name // "<unnamed>"')"

	if curl --silent --show-error --fail-with-body \
		--max-time 60 \
		--header "X-N8N-API-KEY: ${N8N_API_KEY}" \
		--header 'Content-Type: application/json' \
		--data "${payload}" \
		"${N8N_HOST%/}/api/v1/workflows" >/dev/null; then
		log "restored ${name}"
	else
		log "FAILED ${name}"
		FAILED+=("${name}")
	fi
}

main() {
	local apply=0

	while (( $# > 0 )); do
		case "$1" in
			--apply) apply=1; shift ;;
			-h|--help) usage; return 0 ;;
			--) shift; break ;;
			-*) die "unknown option $1" ;;
			*) break ;;
		esac
	done

	local backup_dir="${1:-}"
	[[ -n "${backup_dir}" ]] || { usage; die "BACKUP_DIR is required"; }

	local source_file="${backup_dir%/}/workflows.json"
	[[ -f "${source_file}" ]] || die "no workflows.json in ${backup_dir}"

	require_command curl
	require_command jq
	require_host_url
	require_env N8N_API_KEY

	local count; count="$(jq '.data | length' < "${source_file}")"

	if (( ! apply )); then
		log "dry run: ${count} workflow(s) from ${backup_dir} would be restored to ${N8N_HOST}"
		jq -r '.data[] | "  \(.name)"' < "${source_file}"
		log "re-run with --apply to perform the restore"
		return 0
	fi

	log "restoring ${count} workflow(s) to ${N8N_HOST}"
	# The id and timestamps are assigned by the target instance, so they are
	# stripped rather than replayed.
	while IFS= read -r workflow; do
		push_workflow "${workflow}"
	done < <(jq -c '.data[] | del(.id, .createdAt, .updatedAt)' < "${source_file}")

	if (( ${#FAILED[@]} > 0 )); then
		log "restored $(( count - ${#FAILED[@]} )) of ${count}; ${#FAILED[@]} failed:"
		for failed_name in "${FAILED[@]}"; do echo "  ${failed_name}" >&2; done
		return 1
	fi

	log "restore complete: ${count} workflow(s)"
}

main "$@"
