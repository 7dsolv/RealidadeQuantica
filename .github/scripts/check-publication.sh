#!/usr/bin/env bash
# Runs on generated pull requests. Compare the producer inputs to the PR BASE,
# because the proposal intentionally contains the next memory/model state.
set -euo pipefail
branch="${PR_BRANCH:?branch}";base="${PR_BASE:?base}"
case "$branch" in konaet/generated-*) module="${branch#konaet/generated-}";; *) exit 0;; esac
case "$module" in physics) folder=assets/physics;;integrated|offline|xeno) folder="assets/$module";;*) exit 64;;esac
bash .github/scripts/publication-inputs.sh verify "$module" "$folder" "$base"
jq -e --arg module "$module" '.module==$module and (.source_revision|test("^[0-9a-f]{40}$"))' "$folder/publication-source.json" >/dev/null
echo 'KONAET_PUBLICATION_SOURCE_PASS'
