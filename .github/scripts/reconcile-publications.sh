#!/usr/bin/env bash
set -euo pipefail
netgit() { git -c http.https://github.com/.extraheader= -c credential.helper= -c 'credential.helper=!gh auth git-credential' "$@"; }
netgit fetch --no-tags origin 'refs/heads/main:refs/remotes/origin/main'
temporary="$(mktemp -d)";trap 'rm -rf -- "$temporary"' EXIT
gh api --paginate "repos/$GITHUB_REPOSITORY/pulls?state=open&per_page=100" \
  --jq '.[] | select(.user.id==352182232 and .base.ref=="main") | [.number,.head.ref,.head.sha,.head.repo.full_name] | @tsv' > "$temporary/prs"
while IFS=$'\t' read -r number branch head repo;do
  [ "$repo" = "$GITHUB_REPOSITORY" ] || continue
  [[ "$head" =~ ^[0-9a-f]{40}$ && "$number" =~ ^[0-9]+$ ]] || exit 65
  case "$branch" in konaet/generated-*) module="${branch#konaet/generated-}";;*)continue;;esac
  case "$module" in physics) folder=assets/physics;;integrated|offline|xeno) folder="assets/$module";;*)continue;;esac
  netgit fetch --no-tags origin "$head"
  for file in publication-source.json publication-inputs.sha256;do git show "$head:$folder/$file" > "$temporary/$file";done
  if ! bash .github/scripts/publication-inputs.sh verify "$module" "$temporary" refs/remotes/origin/main;then
    printf 'PR #%s: aguardando nova rodada; inputs mudaram.\n' "$number" >> "$GITHUB_STEP_SUMMARY"
    continue
  fi
  if git merge-base --is-ancestor refs/remotes/origin/main "$head";then continue;fi
  jq -n --arg sha "$head" '{expected_head_sha:$sha}' > "$temporary/request.json"
  gh api --method PUT "repos/$GITHUB_REPOSITORY/pulls/$number/update-branch" --input "$temporary/request.json"
done < "$temporary/prs"
