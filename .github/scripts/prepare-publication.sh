#!/usr/bin/env bash
set -euo pipefail
module="${1:?module}";folder="${2:?artifact folder}"
case "$module" in
  integrated) allowed=('assets/integrated' 'hardware/x02-acquisition' 'state/konaet-research-memory.json');;
  physics) allowed=('assets/physics' 'assets/realidade-quantica-dashboard.png' 'assets/realidade-quantica-viva.gif' 'state/konaet_memory.csv');;
  offline) allowed=('assets/offline' 'hardware/x01-carrier');;
  xeno) allowed=('assets/xeno');;
  *) exit 64;;
esac
branch="konaet/generated-$module"
expected="https://github.com/$GITHUB_REPOSITORY"
for url in "$(git remote get-url origin)" "$(git remote get-url --push origin)";do
  [ "$url" = "$expected" ] || [ "$url" = "$expected.git" ] || exit 65
done
netgit() { git -c http.https://github.com/.extraheader= -c credential.helper= -c 'credential.helper=!gh auth git-credential' "$@"; }
netgit fetch --no-tags origin 'refs/heads/main:refs/remotes/origin/main'
bash .github/scripts/publication-inputs.sh verify "$module" "$folder" refs/remotes/origin/main
git config user.name 'konaet[bot]'
git config user.email '352182232+konaet[bot]@users.noreply.github.com'
remote="$(netgit ls-remote --heads origin "refs/heads/$branch" | cut -f1)"
if [ -n "$remote" ];then
  netgit fetch --no-tags origin "refs/heads/$branch:refs/remotes/origin/$branch"
  # Only the module's own generated paths may exist on an old proposal.
  while IFS= read -r -d '' file;do
    permitted=false
    for path in "${allowed[@]}";do
      if [[ "$file" = "$path" || "$file" = "$path/"* ]];then permitted=true;break;fi
    done
    [ "$permitted" = true ] || { echo '::error::Branch gerada contem alteracoes externas ao modulo.';exit 66; }
  done < <(git diff --no-renames --name-only -z "refs/remotes/origin/main...refs/remotes/origin/$branch")
  git switch --detach "refs/remotes/origin/$branch"
  # Conflicts can only involve the allowed generated paths checked above.
  # The latest main wins; newly validated artifacts replace generated data next.
  git merge --no-edit -X theirs refs/remotes/origin/main
else
  git switch --detach refs/remotes/origin/main
fi
printf 'branch=%s\n' "$branch" >> "$GITHUB_OUTPUT"
