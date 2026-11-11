#!/usr/bin/env bash
set -euo pipefail
source_script="$(pwd)/.github/scripts/publication-inputs.sh"
source_attributes="$(pwd)/.gitattributes"
fixture="$(mktemp -d)"
trap 'rm -rf -- "$fixture"' EXIT
cd "$fixture";git init -q;git config user.name Test;git config user.email test@example.invalid
mkdir -p matlab/tiny matlab/integrated integrated hardware/icebreaker state assets/integrated/model assets/offline .github tests
printf one > matlab/tiny/tiny_fp32.m
printf one > matlab/integrated/konaet_metrics.m
printf one > hardware/icebreaker/konaet.pcf
printf one > state/konaet-research-memory.json
printf one > state/konaet_memory.csv
printf one > assets/integrated/model/model-bundle.json
printf one > .github/lock.json
cp "$source_attributes" .gitattributes
printf '{"line_endings":"LF"}\n' > assets/integrated/model/model-card.json
printf 'digest  file\n' > assets/integrated/publication-inputs.sha256
printf one > tests/contract.sh
printf one > integrated/qualification-profile.json
git add .;git commit -qm initial
bash "$source_script" capture integrated "$fixture/result"
bash "$source_script" verify integrated "$fixture/result"
base="$(git rev-parse HEAD)";passed=1
git -c core.autocrlf=true checkout-index --prefix="$fixture/windows-checkout/" -a
cmp assets/integrated/model/model-card.json "$fixture/windows-checkout/assets/integrated/model/model-card.json"
cmp assets/integrated/publication-inputs.sha256 "$fixture/windows-checkout/assets/integrated/publication-inputs.sha256"
passed=$((passed+1))
for file in matlab/tiny/tiny_fp32.m matlab/integrated/konaet_metrics.m hardware/icebreaker/konaet.pcf \
  state/konaet-research-memory.json assets/integrated/model/model-bundle.json .github/lock.json .gitattributes tests/contract.sh integrated/qualification-profile.json;do
  printf changed >> "$file";git add "$file";git commit -qm change
  if bash "$source_script" verify integrated "$fixture/result" >/dev/null 2>&1;then
    echo "Stale inputs accepted: $file";exit 1
  fi
  git restore --source="$base" --staged --worktree "$file";git commit -qm restore
  passed=$((passed+1))
done
printf new > matlab/tiny/new_dependency.m;git add matlab/tiny/new_dependency.m;git commit -qm addition
if bash "$source_script" verify integrated "$fixture/result" >/dev/null 2>&1;then exit 1;fi
git rm -q matlab/tiny/new_dependency.m;git commit -qm removal;passed=$((passed+1))
printf image > assets/offline/render.png;printf docs > README.md
git add assets/offline/render.png README.md;git commit -qm unrelated
bash "$source_script" verify integrated "$fixture/result";passed=$((passed+1))
bash "$source_script" capture physics "$fixture/physics"
printf changed >> state/konaet_memory.csv;git add state/konaet_memory.csv;git commit -qm physics
if bash "$source_script" verify physics "$fixture/physics" >/dev/null 2>&1;then exit 1;fi
passed=$((passed+1))
printf tamper >> "$fixture/result/publication-inputs.sha256"
if bash "$source_script" verify integrated "$fixture/result" >/dev/null 2>&1;then exit 1;fi
passed=$((passed+1))
echo "KONAET_SOURCE_GUARD_PASS $passed cases"
