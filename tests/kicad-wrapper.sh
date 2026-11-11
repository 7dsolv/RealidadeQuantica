#!/usr/bin/env bash
set -euo pipefail
source_script="$(pwd)/.github/scripts/kicad.sh"
lock="$(pwd)/.github/toolchain-lock.json"
fixture="$(mktemp -d)"
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/workspace with spaces/.github"
cp "$lock" "$fixture/workspace with spaces/.github/toolchain-lock.json"
cat > "$fixture/bin/docker" <<'DOCKER'
#!/usr/bin/env bash
printf '%s\0' "$@" > "$MOCK_DOCKER_LOG"
exit "${MOCK_DOCKER_EXIT:-0}"
DOCKER
chmod +x "$fixture/bin/docker"
export PATH="$fixture/bin:$PATH" MOCK_DOCKER_LOG="$fixture/args"
unset DISPLAY XAUTHORITY
cd "$fixture/workspace with spaces"
bash "$source_script" pcb drc --output 'result with spaces.json' 'board with spaces.kicad_pcb'
mapfile -d '' -t args < "$MOCK_DOCKER_LOG"
expected=(--pull=never --network=none --cap-drop=ALL --security-opt=no-new-privileges --read-only)
checks=0
for option in "${expected[@]}"; do
  found=false
  for arg in "${args[@]}"; do [[ "$arg" != "$option" ]] || found=true; done
  [[ "$found" == true ]]; checks=$((checks+1))
done
[[ "${args[${#args[@]}-1]}" == 'board with spaces.kicad_pcb' ]]; checks=$((checks+1))
[[ "${args[${#args[@]}-2]}" == 'result with spaces.json' ]]; checks=$((checks+1))
export MOCK_DOCKER_EXIT=37
if bash "$source_script" version; then exit 1; else [[ $? == 37 ]]; fi
checks=$((checks+1)); unset MOCK_DOCKER_EXIT
export DISPLAY='remote:0'
if bash "$source_script" version; then echo 'Remote X display accepted' >&2; exit 1; fi
checks=$((checks+1)); unset DISPLAY
jq '.kicad_image="untrusted/image:latest"' .github/toolchain-lock.json > changed.json
cp changed.json .github/toolchain-lock.json
if bash "$source_script" version; then echo 'Unpinned image accepted' >&2; exit 1; fi
checks=$((checks+1))
printf 'KONAET_KICAD_WRAPPER_PASS %d contract checks; Docker fixture only.\n' "$checks"
