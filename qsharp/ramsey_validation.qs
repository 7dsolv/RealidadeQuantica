// Validation entry point used only by the official QDK sample-test harness.
// The production RamseyShot and RamseyCounts operations are compiled unchanged.
@EntryPoint()
operation ValidateKonaet() : Unit {
    if RamseyCounts(0.0, 256) != 0 {
        fail "Phase zero must always return Zero.";
    }
    if RamseyCounts(Std.Math.PI(), 256) != 256 {
        fail "Phase pi must always return One.";
    }
    let shots = 8192;
    let phase = 0.8;
    let p = Std.Math.Sin(phase / 2.0) * Std.Math.Sin(phase / 2.0);
    let expected = Std.Convert.IntAsDouble(shots) * p;
    let sigma = Std.Math.Sqrt(Std.Convert.IntAsDouble(shots) * p * (1.0 - p));
    let observed = Std.Convert.IntAsDouble(RamseyCounts(phase, shots));
    if Std.Math.AbsD(observed - expected) > 6.0 * sigma {
        fail "Ramsey frequencies disagree with the Born rule by more than six sigma.";
    }
}
