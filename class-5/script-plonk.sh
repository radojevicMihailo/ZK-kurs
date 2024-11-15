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
# the new command is used to start powers od tau ceremony
# the first parameter after new refers to the type of curve you wish to use
# the second parameter is the power of two of the maximum number of constraints that ceremony can accept
# 2 ^ 12 = 4096 

echo "----- Contribute to the ceremony -----"
snarkjs powersoftau contribute pot${TAU_SIZE}_0000.ptau pot${TAU_SIZE}_0001.ptau --name="marija" -v -e="8YdOZ'bB,z0gr{%ny?x4{*W5Top~VkE_7:P#eB5wY4aM/?R"
# the contribute command creates a ptau file with a new contribution
# contribute takes as input the transcript of the protocol so far and outputs a new transcript whic includes
# the computation carried out by new contributor
# the -e parameter allows contribute to be non-interactive

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
# the beacon command creates ptau file with contribution applied in the form of a random beacon
# a random beacon is a source of public randomness that is not available before a fixed time
# the beacon can be a delayed hash function evaluated on some high entropy and publicly available data
# the closing value of stock market on a certain date in future
# the output of a selected set of national lotteries
# the value of a block at a particular height in one or more blockchains (the hash of the 11 millionth Ethereum block)
# in this example the beacon is essentially a delayed hash function on 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
# next input 10 just tells snarkjs to perform 2^10 iterations of this hash function

echo "----- Prepare phase 2 -----"
snarkjs powersoftau prepare phase2 pot${TAU_SIZE}_beacon.ptau pot${TAU_SIZE}_final.ptau -v
# this command calculates the encrypted evaluation of the Lagrange polynomials at tau for tau, alpha*tau and beta*tau

echo "----- Verify the final ptau -----"
snarkjs powersoftau verify pot${TAU_SIZE}_final.ptau

echo "----- Setup -----"
snarkjs plonk setup ${CIRCUIT_NAME}.r1cs pot${TAU_SIZE}_final.ptau ${CIRCUIT_NAME}_final.zkey
# difference between PLONK/FFPLONK and Groth16
# Groth16 requires a trusted ceremony for each circuit. PLONK and FFPLONK do not require it, it's enough with
# the powers of tau ceremony which is universal 

echo "----- Export the verification key -----"
snarkjs zkey export verificationkey ${CIRCUIT_NAME}_final.zkey verification_key.json
# export verification from circuit_final.zkey into verification_key.json

echo "----- Create the proof -----"
snarkjs plonk prove ${CIRCUIT_NAME}_final.zkey witness.wtns proof.json public.json
# this command generates the files proof.json and public.json
# proof.json contains the actual proof
# public.json contrains the values of the public inputs and outputs

echo "----- Verify the proof -----"
snarkjs plonk verify verification_key.json public.json proof.json

echo "----- Turn the verifier into a smart contract -----"
snarkjs zkey export solidityverifier ${CIRCUIT_NAME}_final.zkey verifier.sol

echo "----- Simulate a verification call -----"
snarkjs zkey export soliditycalldata public.json proof.json