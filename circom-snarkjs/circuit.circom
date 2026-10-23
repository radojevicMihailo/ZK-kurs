pragma circom  2.0.0;

include "./node_modules/circomlib/circuits/poseidon.circom";
include "./node_modules/circomlib/circuits/comparators.circom";

template guessTheNumber() {
    signal input number;
    signal input solution;
    signal input commit;
    signal input salt;

    signal output out;

    component commit_calc = Poseidon(2);
    commit_calc.inputs[0] <== solution;
    commit_calc.inputs[1] <== salt;
    commit === commit_calc.out;

    component eq = IsEqual();
    eq.in[0] <== number;
    eq.in[1] <== solution;

    out <== eq.out;
}

component main { public [number, commit] } = guessTheNumber();