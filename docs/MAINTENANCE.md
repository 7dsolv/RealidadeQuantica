# Maintenance and adoption

KONAET is a reproducible scientific-computing laboratory and a bounded research agent. The GitHub identity/proposal package is maintained separately in [konaet-bot](https://github.com/7dsolv/konaet-bot). The code and engineering evidence do not establish general AI superiority.

## Run and inspect

Use MATLAB R2026b. Open `abrir_konaet` for the interactive simulation, or compile the Fortran reference with the command in `.github/workflows/integrated.yml` and run `executar_konaet`. No neural-network toolbox is needed. For the full native-tool pipeline, use the integrated GitHub Actions workflow.

The Actions files pin external dependencies by commit. `.github/toolchain-lock.json` records exact direct package versions. Changing versions is a reviewed source change; do not silently fall back to whatever an apt repository serves. Runner and transitive-package provenance accompany each artifact.

KiCad 10.0.8 uses the official `ghcr.io/kicad/kicad` image fixed by its
linux/amd64 SHA-256 digest. This removes the operational dependency on the
Launchpad keyserver that failed in the audit. Container digest, package list and
version are archived separately from the Ubuntu host packages. The wrapper runs
without network or extra capabilities, maps the current workspace and uid, and
accepts the temporary Xvfb display only for rendering. It does not receive App
credentials or the Docker socket. [Official image](https://github.com/KiCad/kicad-docker/pkgs/container/kicad).

All PRs run physics, offline, Xenoelement, integrated FPGA/EDA, QSharp and publication-integrity checks. Broad push filters cover shared numerical dependencies, test files, workflow scripts and FPGA pin constraints. Generated-output pushes do not recursively trigger the producers.

## Review and support

Code, data policy, workflow changes and pin constraints belong to `@7dsolv` through CODEOWNERS. Generated results have no code-owner requirement, but still require CI and the publication input check. Keep required check names aligned with workflow job names when updating branch protection.

Use issues for reproducible defects. Include source revision, MATLAB/tool versions, minimal input and observed/expected result. Report security issues through [private vulnerability reporting](../SECURITY.md). No response-time SLA or certification is offered.

Original project source is MIT under the root [LICENSE](../LICENSE). Imported model weights, data and brand assets have separate notices in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). A company should review those terms and its own deployment requirements.

## Performance acceptance

Evaluate all declared methods on the same cases. Keep the two previously observed real series marked retrospective and the four newly selected series under the frozen protocol. Do not tune on future labels or replace difficult series after inspecting their scores.

Report balanced accuracy, recall, false-positive rate, coverage, per-window decisions and uncertainty. A 100% test pass rate establishes only those software contracts. It is not a 100% anomaly-detection score or evidence of performance on every device.

Hardware acceptance requires the [separate bench protocol](../integrated/HARDWARE_VALIDATION.md); simulation and clean DRC do not supply physical measurements.
