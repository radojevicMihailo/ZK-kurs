const { readFileSync } = require("fs");
const { groth16 } = require("snarkjs");

async function proving() {
	let inputs = JSON.parse(readFileSync("inputs.json"));

    const { proof, publicSignals } = await groth16.fullProve(inputs, "./artifacts-groth16/circuit_js/circuit.wasm", "./artifacts-groth16/circuit_final.zkey");

    const vKey = JSON.parse(readFileSync("./artifacts-groth16/verification_key.json"));

    let res = await groth16.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }
}

proving().then(() => {
    process.exit(0);
});