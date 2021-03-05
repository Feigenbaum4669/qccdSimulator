QCCD functions: split, merge, etc implementation. Keep track of qubits. Call Quest.jl for simulation. Manage and detect conflicts. Resource counting. Parallelism management. Noise.

Convenience layer (maybe not implemented): User functions that will call QCCD functions (CNOT, X, H gates...)

Last layer: With QASM instructions as input we optimize them and then use the QCCD functions to simulate them.