import Std.Measurement.*;

operation RamseyShot(phase : Double) : Result {
    use qubit = Qubit();
    H(qubit);
    R(PauliZ, phase, qubit);
    H(qubit);
    return MResetZ(qubit);
}

@EntryPoint()
operation Main() : Result {
    return RamseyShot(0.8);
}
