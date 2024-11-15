#!/bin/bash
set -e

CIRCUIT_NAME="circuit"
INPUT_NAME="inputs"
ARTIFACTS_PATH="artifacts-groth16"
TAU_SIZE="12"

# compile

mkdir -p  ${ARTIFACTS_PATH}

echo "----- Compile the circuit -----"
circom ${CIRCUIT_NAME}.circom --r1cs --wasm --sym --output ${ARTIFACTS_PATH}

# generate witness

cd ${ARTIFACTS_PATH}

echo "----- Calculate the witness -----"
node ${CIRCUIT_NAME}_js/generate_witness.js ${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm ../${INPUT_NAME}.json witness.wtns

# tau ceremony

echo "----- Setup -----"
snarkjs groth16 setup ${CIRCUIT_NAME}.r1cs ../powersOfTau28_hez_final_${TAU_SIZE}.ptau ${CIRCUIT_NAME}_0000.zkey

echo "----- Contribute to the phase 2 of the ceremony -----"
snarkjs zkey contribute ${CIRCUIT_NAME}_0000.zkey ${CIRCUIT_NAME}_final.zkey --name="mihailo" -v

echo "----- Export the verification key -----"
snarkjs zkey export verificationkey ${CIRCUIT_NAME}_final.zkey verification_key.json

echo "----- Create the proof -----"
snarkjs groth16 prove ${CIRCUIT_NAME}_final.zkey witness.wtns proof.json public.json

echo "----- Verify the proof -----"
snarkjs groth16 verify verification_key.json public.json proof.json

echo "----- Turn the verifier into a smart contract -----"
snarkjs zkey export solidityverifier ${CIRCUIT_NAME}_final.zkey verifier.sol

echo "----- Simulate a verification call -----"
snarkjs zkey export soliditycalldata public.json proof.json