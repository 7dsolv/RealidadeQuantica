# License and provenance map

The original KONAET MATLAB, Fortran, Q#, SystemVerilog, infrastructure,
documentation, generated drawings, generic CAD geometry and new Sense weights
are provided under the root MIT license. This includes shared `matlab/tiny/`,
the Fortran numerical reference and the earlier scientific/Xeno modules.

| Component | License / source | Scope |
| --- | --- | --- |
| AnomalyNet tensors and original numeric reference | Apache-2.0; [license](models/anomalynet/LICENSE.txt), [notice](models/anomalynet/NOTICE.txt), [pinned source](models/anomalynet/source.json) | Original Eoin Jordan weights; not KONAET-trained |
| NAB dataset and original descriptions/labels | MIT notice in the pinned snapshot; [license](datasets/nab/LICENSE.txt), [source](datasets/nab/source.json) | Copied data and labels; preserve upstream notices |
| KONAET cube brand | Original asset supplied by the owner; provenance in `7dsolv/konaet-bot/visuals/brand/source.json` | Project identity; no third-party trademark rights granted |
| MATLAB, KiCad, FPGA/compiler/QDK tools | Their respective upstream licenses | External tools; not relicensed or bundled by the root MIT license |

The new KONAET Sense weights are initialized and trained independently. Reuse
of a known architecture or numerical method is not a claim to invent that
method. Software licensing does not establish patentability or physical
qualification of a board or material.
