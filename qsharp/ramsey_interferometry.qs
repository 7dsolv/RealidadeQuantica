import Std.Measurement.*;

operation RamseyShot(phase : Double) : Result {
    use qubit = Qubit();
    H(qubit);
    R(PauliZ, phase, qubit);
    H(qubit);
    return MResetZ(qubit);
}

operation RamseyCounts(phase : Double, shots : Int) : Int {
    mutable ones = 0;
    for shot in 1..shots {
        if RamseyShot(phase) == One {
            set ones += 1;
        }
    }
    return ones;
}

@EntryPoint()
operation Main() : Int {
    return RamseyCounts(0.8, 1024);
}
