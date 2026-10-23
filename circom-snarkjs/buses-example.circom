pragma circom 2.2.0;

include "./node_modules/circomlib/circuits/poseidon.circom";
include "./node_modules/circomlib/circuits/comparators.circom";

bus Point {
    signal x;
    signal y;
    signal z;
}

template PointHasher() {
    Point() input p;
    signal output hash;

    hash <== Poseidon(3)([p.x, p.y, p.z]);
}

template Main() {
    signal input inX;
    signal input inY;
    signal input inZ;
    signal input pointHash;
    
    signal output sameHash;

    Point() myPoint;
    myPoint.x <== inX;
    myPoint.y <== inY;
    myPoint.z <== inZ;

    signal hash;

    hash <== PointHasher()(myPoint);

    sameHash <== IsEqual()([hash, pointHash]);
}

component main = Main();