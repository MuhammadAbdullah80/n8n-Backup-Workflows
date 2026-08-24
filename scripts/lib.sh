#!/usr/bin/env bash
#
# Shared helpers for the backup and restore scripts. Sourced, never executed.

# Writes a timestamped line to stderr so stdout stays clean for piped data.
log() {
	printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*" >&2
}

# Reports a fatal error and exits non-zero.
die() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

# Aborts unless the named command is on PATH.
require_command() {
	command -v "$1" >/dev/null 2>&1 || die "$1 is required but not installed"
}

# Aborts unless the named variable is set and non-empty.
require_env() {
	local name="$1"
	[[ -n "${!name:-}" ]] || die "${name} is not set"
}

# GETs one paginated n8n API resource and emits the combined JSON.
# n8n returns at most 250 items per page, so this follows the cursor to the end.
fetch_resource() {
	local resource="$1"
	local cursor='' page combined='{"data":[]}'

	while :; do
		local url="${N8N_HOST%/}/api/v1/${resource}?limit=250"
		[[ -n "${cursor}" ]] && url+="&cursor=${cursor}"

		page="$(curl --silent --show-error --fail-with-body \
			--max-time 60 \
			--header "X-N8N-API-KEY: ${N8N_API_KEY}" \
			--header 'Accept: application/json' \
			"${url}")" || die "failed fetching ${resource}"

		combined="$(jq -s '{data: (.[0].data + .[1].data)}' \
			<(printf '%s' "${combined}") <(printf '%s' "${page}"))"

		cursor="$(printf '%s' "${page}" | jq -r '.nextCursor // empty')"
		[[ -z "${cursor}" ]] && break
	done

	printf '%s' "${combined}"
}

# Fetches a resource and writes it to disk with sorted keys, so successive
# backups produce a stable diff instead of noise from key reordering.
save_resource() {
	local resource="$1" dest="$2"
	fetch_resource "${resource}" | jq --sort-keys '.' > "${dest}"
	log "saved $(jq '.data | length' < "${dest}") ${resource}"
}

# Records what was captured, so a restore can be checked against it later.
write_manifest() {
	local dir="$1" stamp="$2"
	jq --null-input \
		--arg stamp "${stamp}" \
		--arg host "${N8N_HOST}" \
		--argjson workflows "$(jq '.data | length' < "${dir}/workflows.json")" \
		--argjson credentials "$(jq '.data | length' < "${dir}/credentials.json")" \
		'{taken_at: $stamp, host: $host, counts: {workflows: $workflows, credentials: $credentials}}' \
		> "${dir}/manifest.json"
}

# Deletes all but the newest COUNT backup directories.
prune_old_backups() {
	local dir="$1" keep="$2" removed=0

	while IFS= read -r old; do
		rm -rf -- "${old}"
		removed=$((removed + 1))
	done < <(find "${dir}" -mindepth 1 -maxdepth 1 -type d | sort -r | tail -n "+$((keep + 1))")

	(( removed > 0 )) && log "pruned ${removed} old backup(s)"
	return 0
}
