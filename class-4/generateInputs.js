const { buildPoseidonOpt, buildBabyjub } = require("circomlibjs");
const { poseidon1, poseidon2 } = require("poseidon-lite");
const { writeFileSync } = require("fs");
const { IMT } = require("@zk-kit/imt");

async function generateRange(number, lowerLimit, upperLimit) {
    const numberBigInt = BigInt(number);

    const salt = 487126483447248172245n;

    const commit = poseidon2([numberBigInt, salt]);

    writeFileSync("inputsRange.json", JSON.stringify({
        number: numberBigInt.toString(),
        salt: salt.toString(),
        commit: commit.toString(),
        lowerLimit: lowerLimit.toString(),
        upperLimit: upperLimit.toString(),
    }, null, 2));
}

async function generateInclusionProof(numbers, number) {
    const leaf = poseidon1([BigInt(number)]);

    let leaves = [];
    for (let i = 0; i < numbers.length; i++) {
        leaves.push(poseidon1([BigInt(numbers[i])]));
    }

    const tree = new IMT(poseidon2, 3, 0, 2, leaves);
    const proof = tree.createProof(2);
    const { pathIndices: pathIndicesRaw, siblings: siblingsRaw } = proof;

    const root = tree.root;

    const pathIndices = pathIndicesRaw.map(el => el.toString());
    const siblings = siblingsRaw.map(el => el.toString());

    writeFileSync("inputsInclusionProof.json", JSON.stringify({
        leaf: leaf.toString(),
        pathIndices,
        siblings,
        root: root.toString(),
    }, null, 2));
}

async function generateHashString(name) {
    const poseidon = await buildPoseidonOpt();

    const nameUtf8 = Array.from(Buffer.from(name, 'utf-8')).map((byte) => BigInt(byte));

    const nameHash = await poseidon(nameUtf8);

    const nameHashInput = poseidon.F.toObject(nameHash);

    writeFileSync("inputsHashString.json", JSON.stringify({
        nameHash: nameHashInput.toString(),
    }, null, 2));
}

async function generatePubKey(privKey) {
    const privKeyBigInt = BigInt(privKey);

    const babyJub = await buildBabyjub();

    const publicKeyRaw = babyJub.mulPointEscalar(babyJub.Base8, privKeyBigInt);
    const publicKeyObject = publicKeyRaw.map(el => babyJub.F.toObject(el));
    const publicKey = publicKeyObject.map(el => el.toString());

    writeFileSync("inputsPubKey.json", JSON.stringify({
        priv_key: privKeyBigInt.toString(),
        pub_key: publicKey,
    }, null, 2));
}

generateRange(5, 2, 10);
generateInclusionProof([1, 2, 3, 4, 5, 6, 7, 8], 3);
generateHashString("Mihailo");
generatePubKey(5);