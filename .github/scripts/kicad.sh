#!/usr/bin/env bash
# Official KiCad image, immutable digest; no package-server dependency at runtime.
set -euo pipefail
image="$(jq -er .kicad_image .github/toolchain-lock.json)"
[[ "$image" =~ ^ghcr\.io/kicad/kicad:10\.0\.[0-9]+@sha256:[0-9a-f]{64}$ ]]
root="$(pwd -P)"
args=(run --rm --pull=never --network=none --cap-drop=ALL --security-opt=no-new-privileges
  --read-only --tmpfs '/tmp:rw,nosuid,size=256m' --user "$(id -u):$(id -g)"
  --env HOME=/tmp --env LIBGL_ALWAYS_SOFTWARE=1
  --mount "type=bind,src=$root,dst=$root" --workdir "$root")
if [[ -n "${DISPLAY:-}" ]]; then
  [[ "$DISPLAY" =~ ^:[0-9]+(\.[0-9]+)?$ && -d /tmp/.X11-unix && -f "${XAUTHORITY:-}" ]]
  args+=(--env "DISPLAY=$DISPLAY" --env "XAUTHORITY=$XAUTHORITY"
    --mount 'type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix,readonly'
    --mount "type=bind,src=$XAUTHORITY,dst=$XAUTHORITY,readonly")
fi
exec docker "${args[@]}" --entrypoint /usr/bin/kicad-cli "$image" "$@"
