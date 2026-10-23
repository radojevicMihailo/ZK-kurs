const { readFileSync } = require("fs");
const { groth16 } = require("snarkjs");

async function proving() {
    let inputs = JSON.parse(readFileSync("inputs-buses.json"));

    const { proof, publicSignals } = await groth16.fullProve(inputs, "./artifacts-buses-groth16/buses-example_js/buses-example.wasm", "./artifacts-buses-groth16/buses-example_final.zkey");

    const vKey = JSON.parse(readFileSync("./artifacts-buses-groth16/verification_key.json"));

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