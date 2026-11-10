#!/usr/bin/env bash
set -euo pipefail
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
  sudo add-apt-repository --yes "$(jq -r .ppa "$lock")"
fi
sudo apt-get update -qq
specifications=()
for package in "${packages[@]}";do
  version="$(jq -er --arg package "$package" '.packages[$package]' "$lock")"
  specifications+=("$package=$version")
done
sudo apt-get install -y --no-install-recommends "${specifications[@]}"
mkdir -p "$output"
dpkg-query -W -f='${binary:Package}\t${Version}\n' | LC_ALL=C sort > "$output/installed-packages.tsv"
gfortran --version > "$output/gfortran-version.txt"
git --version > "$output/git-version.txt"
gh --version > "$output/gh-version.txt"
cp "$lock" "$output/toolchain-lock.json"
jq -n --arg os "${ImageOS:-unknown}" --arg image "${ImageVersion:-unknown}" \
  --arg run "${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-local}/actions/runs/${GITHUB_RUN_ID:-local}" \
  '{runner_os:$os,runner_image:$image,run_url:$run,physical_hardware_test:false}' > "$output/build-provenance.json"
