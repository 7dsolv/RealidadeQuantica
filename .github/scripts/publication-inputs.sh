#!/usr/bin/env bash
# Infrastructure only: bind generated results to their exact source inputs.
set -euo pipefail
mode="${1:?capture or verify}"; module="${2:?module}"; folder="${3:?artifact folder}"; ref="${4:-HEAD}"
case "$module" in physics|integrated|offline|xeno) ;; *) exit 64;; esac
root="$(git rev-parse --show-toplevel)";cd "$root"
manifest() {
  local file include digest
  while IFS= read -r -d '' file; do
    [[ "$file" != *$'\n'* && "$file" != *$'\r'* ]] || exit 65
    include=false
    case "$file" in
      *.m|*.f90|*.sv|qsharp/*|.github/*|tests/*|.gitattributes|.gitmodules|models/*|datasets/*|hardware/icebreaker/*|LICENSE|THIRD_PARTY_NOTICES.md|integrated/evaluation-protocol.json) include=true;;
    esac
    case "$module:$file" in
      physics:state/konaet_memory.csv|integrated:state/konaet-research-memory.json|integrated:assets/integrated/model/*) include=true;;
    esac
    [ "$include" = true ] || continue
    digest="$(git show "$ref:$file" | sha256sum | cut -d' ' -f1)"
    printf '%s  %s\n' "$digest" "$file"
  done < <(git ls-tree --full-tree -r --name-only -z "$ref" | sort -z)
}
if [ "$mode" = capture ]; then
  mkdir -p "$folder"
  manifest > "$folder/publication-inputs.sha256"
  digest="$(sha256sum "$folder/publication-inputs.sha256" | cut -d' ' -f1)"
  jq -n --arg source "$(git rev-parse "$ref")" --arg module "$module" --arg digest "$digest" \
    --arg run "${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-local}/actions/runs/${GITHUB_RUN_ID:-local}" \
    '{schema_version:1,source_revision:$source,module:$module,input_manifest_sha256:$digest,run_url:$run}' > "$folder/publication-source.json"
elif [ "$mode" = verify ]; then
  [ -f "$folder/publication-inputs.sha256" ] && [ -f "$folder/publication-source.json" ]
  digest="$(sha256sum "$folder/publication-inputs.sha256" | cut -d' ' -f1)"
  jq -e --arg digest "$digest" --arg module "$module" \
    '.schema_version==1 and .module==$module and .input_manifest_sha256==$digest' "$folder/publication-source.json" >/dev/null
  current="$(mktemp)";trap 'rm -f "$current"' EXIT
  manifest > "$current"
  if ! cmp -s "$folder/publication-inputs.sha256" "$current"; then
    echo '::error::Codigo ou estado mudou depois da validacao. Artefatos antigos nao serao publicados.'
    exit 66
  fi
else exit 64;fi
