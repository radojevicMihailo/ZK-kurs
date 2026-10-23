const { poseidon2 } = require("poseidon-lite");
const { writeFileSync } = require("fs");

async function generate(number, solution, inputsFilename) {
    const numberBigInt = BigInt(number);
    const solutionBigInt = BigInt(solution);

    const salt = BigInt(123543578123736283);
    const commit = poseidon2([solutionBigInt, salt]);

    writeFileSync(inputsFilename, JSON.stringify({
        number: numberBigInt.toString(),
        solution: solutionBigInt.toString(),
        commit: commit.toString(),
        salt: salt.toString(),
    }, null, 2));
}

generate(15, 15, "inputs.json");