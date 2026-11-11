#!/usr/bin/env bash
set -euo pipefail
module="${1:?module}";src="${2:?artifact folder}"
copy_files() { local dest="$1";shift;mkdir -p "$dest";for file in "$@";do cp "$src/$file" "$dest/$file";done; }
case "$module" in
 integrated)
  copy_files assets/integrated agent-memory.json agent-experiments.json benchmark.json benchmark-summary.md model-qualification.json hard-decisions.csv \
    circuit-report.json circuit-tolerances.csv circuit-trace.csv test-report.json app-report.json visual-report.json stream-report.json \
    live-trace.csv summary.json summary.txt konaet-live.gif konaet-live.png konaet-app.png benchmark.png nextpnr-report.json \
    rtl.log i2c.log adc.log ads1115.log top.log KONAET-LICENSE.txt AnomalyNet-LICENSE.txt AnomalyNet-NOTICE.txt NAB-LICENSE.txt konaet-ice40.bin
  cp "$src"/nab-*-decisions.csv assets/integrated/
  mkdir -p assets/integrated/model assets/integrated/rtl state hardware/x02-acquisition
  for file in fc1_weight.f32 fc1_bias.f32 fc2_weight.f32 fc2_bias.f32 konaet-int8.bin quantization.json model-card.json model-bundle.json;do
    cp "$src/model/$file" "assets/integrated/model/$file"
  done
  for file in weights.mem bias.mem input.mem expected.mem konaet_model_params.vh rtl-vectors.json;do cp "$src/rtl/$file" "assets/integrated/rtl/$file";done
  cp "$src/agent-memory.json" state/konaet-research-memory.json
  for file in x02-acquisition.kicad_sch x02-acquisition.kicad_pcb x02-acquisition.kicad_pro KONAET.kicad_sym \
    sym-lib-table fp-lib-table board-source.json eda-report.json geometry.json bom.csv erc.json erc-errors.json drc.json drc-errors.json x02-kicad.png x02-acquisition.stl;do
    cp "$src/hardware/$file" "hardware/x02-acquisition/$file"
  done
  for folder in KONAET_X02.pretty models layers;do mkdir -p "hardware/x02-acquisition/$folder";cp "$src/hardware/$folder/"* "hardware/x02-acquisition/$folder/";done
  dest=assets/integrated
  ;;
 offline)
  copy_files assets/offline tiny-report.json tiny-predictions.csv tiny-evaluation.png anomalynet-int8.bin quantization.json \
    signal-samples.csv signal-decisions.csv signal-chain.json signal-chain.png AnomalyNet-LICENSE.txt AnomalyNet-NOTICE.txt
  mkdir -p hardware/x01-carrier/models hardware/x01-carrier/layers
  for file in board-source.json board-report.json bom.csv x01-rc.cir x01-circuit.svg x01-carrier.kicad_pcb x01-carrier.stl \
    x01-board.png x01-board-motion.gif x01-kicad.png rc-response.csv rc-response.png kicad-report.json kicad-errors.json;do
    cp "$src/board/$file" "hardware/x01-carrier/$file"
  done
  cp "$src/board/models/"*.wrl hardware/x01-carrier/models/
  cp "$src/board/layers/"*.svg hardware/x01-carrier/layers/
  dest=assets/offline
  ;;
 xeno)
  copy_files assets/xeno x01-dashboard.png x01-motion.gif x01-motion-preview.png x01-architecture.png x01-architecture.svg \
    evidence.json parameters.json test-report.json visual-manifest.json x01-app.png app-report.json controller_comparison.csv
  dest=assets/xeno
  ;;
 physics)
  mkdir -p state assets/physics
  cp "$src/konaet_memory.csv" state/konaet_memory.csv
  # Every published image is from the same verified run as the published state.
  cp "$src/realidade-quantica-dashboard.png" assets/realidade-quantica-dashboard.png
  cp "$src/realidade-quantica-viva.gif" assets/realidade-quantica-viva.gif
  cp "$src/summary.txt" assets/physics/summary.txt
  cp "$src/systemverilog.log" assets/physics/systemverilog.log
  dest=assets/physics
  ;;
 *) exit 64;;
esac
if [ "$module" = integrated ] || [ "$module" = offline ];then
  copy_files "$dest" kicad-image.json kicad-container-packages.tsv kicad-version.txt
fi
for file in publication-source.json publication-inputs.sha256 toolchain-lock.json build-provenance.json installed-packages.tsv;do cp "$src/$file" "$dest/$file";done
