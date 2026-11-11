#!/usr/bin/env bash
set -euo pipefail
source .github/scripts/retry-network.sh
module="${1:?module}";output="${2:?output}"
lock='.github/toolchain-lock.json'
packages=(gfortran iverilog)
case "$module" in
  integrated) packages+=(yosys yosys-abc nextpnr-ice40 nextpnr-ice40-chipdb fpga-icestorm kicad xvfb xauth);;
  offline) packages+=(kicad xvfb xauth);;
  physics|xeno) ;;
  *) exit 64;;
esac
if [ "$module" = integrated ] || [ "$module" = offline ];then
  # Register the same PPA directly: its control API is not needed to install
  # packages. Authenticate the official key by the full published fingerprint.
  # https://launchpad.net/~kicad/+archive/ubuntu/kicad-10.0-releases
  key_file="${RUNNER_TEMP:?runner temporary directory}/konaet-kicad.asc"
  keyring="${RUNNER_TEMP}/konaet-kicad.gpg"
  konaet_retry_network curl --fail --location --silent --show-error \
    --connect-timeout 10 --max-time 30 "$(jq -er .ppa_key_url "$lock")" --output "$key_file"
  fingerprint="$(gpg --batch --with-colons --show-keys "$key_file" | awk -F: '$1=="fpr"{print $10;exit}')"
  [[ "$fingerprint" == "$(jq -er .ppa_key_fingerprint "$lock")" ]]
  gpg --batch --yes --dearmor --output "$keyring" "$key_file"
  sudo install -m 0644 "$keyring" /usr/share/keyrings/konaet-kicad.gpg
  printf 'deb [signed-by=/usr/share/keyrings/konaet-kicad.gpg] %s noble main\n' \
    "$(jq -er .ppa_repository_url "$lock")" | sudo tee /etc/apt/sources.list.d/konaet-kicad.list >/dev/null
  mkdir -p "$output"
  sha256sum "$key_file" > "$output/kicad-key-observed.sha256"
fi
konaet_retry_network sudo apt-get update -qq --error-on=any
specifications=()
for package in "${packages[@]}";do
  version="$(jq -er --arg package "$package" '.packages[$package]' "$lock")"
  specifications+=("$package=$version")
done
konaet_retry_network sudo apt-get install -y --no-install-recommends "${specifications[@]}"
mkdir -p "$output"
dpkg-query -W -f='${binary:Package}\t${Version}\n' | LC_ALL=C sort > "$output/installed-packages.tsv"
gfortran --version > "$output/gfortran-version.txt"
git --version > "$output/git-version.txt"
gh --version > "$output/gh-version.txt"
cp "$lock" "$output/toolchain-lock.json"
jq -n --arg os "${ImageOS:-unknown}" --arg image "${ImageVersion:-unknown}" \
  --arg run "${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-local}/actions/runs/${GITHUB_RUN_ID:-local}" \
  '{runner_os:$os,runner_image:$image,run_url:$run,physical_hardware_test:false}' > "$output/build-provenance.json"
