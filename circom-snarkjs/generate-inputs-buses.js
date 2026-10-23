const { poseidon3 } = require("poseidon-lite");
const { writeFileSync } = require("fs");

async function generate(x, y, z, inputsFilename) {
    const xBigInt = BigInt(x);
    const yBigInt = BigInt(y);
    const zBigInt = BigInt(z);

    const pointHash = poseidon3([xBigInt, yBigInt, zBigInt]);

    writeFileSync(inputsFilename, JSON.stringify({
        inX: xBigInt.toString(),
        inY: yBigInt.toString(),
        inZ: zBigInt.toString(),
        pointHash: pointHash.toString(),
    }, null, 2));
}

generate(15, 15, 15, "inputs-buses.json");