#!/bin/bash
set -e

CIRCUIT_NAME="circuit"
INPUT_NAME="inputs"
ARTIFACTS_PATH="artifacts-plonk-2"
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

echo "----- Start a new powers of tau ceremony -----"
snarkjs powersoftau new bn128 ${TAU_SIZE} pot${TAU_SIZE}_0000.ptau -v

echo "----- Contribute to the ceremony -----"
snarkjs powersoftau contribute pot${TAU_SIZE}_0000.ptau pot${TAU_SIZE}_0001.ptau --name="marija" -v -e="8YdOZ'bB,z0gr{%ny?x4{*W5Top~VkE_7:P#eB5wY4aM/?R"

echo "----- Provide a second contribution -----"
snarkjs powersoftau contribute pot${TAU_SIZE}_0001.ptau pot${TAU_SIZE}_0002.ptau --name="mihajlo" -v -e="-YO43eAtDN98bE39E>J8?0V^-6mF4uxB!O9p£-OMI6MvRKt"

echo "----- Provide a third contribution using third party software -----"
snarkjs powersoftau export challenge pot${TAU_SIZE}_0002.ptau challenge_0003
snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="ztvW<L[L@2Wx=K£yI!W?jze[>>S}7=U4385Oaw0<qzCSH£("
snarkjs powersoftau import response pot${TAU_SIZE}_0002.ptau response_0003 pot${TAU_SIZE}_0003.ptau -n="mihailo"

echo "------ Verify the protocol so far (before random beacon) ------"
snarkjs powersoftau verify pot${TAU_SIZE}_0003.ptau

echo "----- Apply a random beacon -----"
snarkjs powersoftau beacon pot${TAU_SIZE}_0003.ptau pot${TAU_SIZE}_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

echo "----- Prepare phase 2 -----"
snarkjs powersoftau prepare phase2 pot${TAU_SIZE}_beacon.ptau pot${TAU_SIZE}_final.ptau -v

echo "----- Verify the final ptau -----"
snarkjs powersoftau verify pot${TAU_SIZE}_final.ptau

echo "----- Setup -----"
snarkjs plonk setup ${CIRCUIT_NAME}.r1cs pot${TAU_SIZE}_final.ptau ${CIRCUIT_NAME}_final.zkey

echo "----- Export the verification key -----"
snarkjs zkey export verificationkey ${CIRCUIT_NAME}_final.zkey verification_key.json

echo "----- Create the proof -----"
snarkjs plonk prove ${CIRCUIT_NAME}_final.zkey witness.wtns proof.json public.json

echo "----- Verify the proof -----"
snarkjs plonk verify verification_key.json public.json proof.json

echo "----- Turn the verifier into a smart contract -----"
snarkjs zkey export solidityverifier ${CIRCUIT_NAME}_final.zkey verifier.sol

echo "----- Simulate a verification call -----"
snarkjs zkey export soliditycalldata public.json proof.json