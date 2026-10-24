# Circom & snarkjs

Writing circuits in Circom and proving them with snarkjs (Groth16 and PLONK).

## Installation

- macOS / Linux: [installation/macos-linux-installation.txt](installation/macos-linux-installation.txt)
- Windows: [installation/windows-installation.txt](installation/windows-installation.txt)

Then install the dependencies of the examples in this folder:

```bash
npm install
```

## Files

| File | Description |
| --- | --- |
| `ZKP MA - Circom i snarkjs.pdf` / `.pptx` | Presentation |
| `circuit.circom` | Guess the number circuit (Poseidon commitment + `IsEqual`) |
| `generate-inputs.js` | Generates `inputs.json` for `circuit.circom` |
| `script-groth16.sh` / `.ps1` | Compile, witness, Groth16 setup, prove, verify, Solidity verifier |
| `script-plonk.sh` / `.ps1` | Compile, witness, own powers of tau ceremony, PLONK setup, prove, verify |
| `proving-groth16.js` / `proving-plonk.js` | Proving and verifying in JavaScript (run after the scripts) |
| `links.txt` | Links from the presentation |

`script-groth16.*` uses `powersOfTau28_hez_final_12.ptau` (phase 1 of a public ceremony), download it into this folder from the [snarkjs README](https://github.com/iden3/snarkjs?tab=readme-ov-file).

## Running

```bash
node generate-inputs.js
bash script-groth16.sh        # Windows: powershell -ExecutionPolicy Bypass -File .\script-groth16.ps1
bash script-plonk.sh          # Windows: powershell -ExecutionPolicy Bypass -File .\script-plonk.ps1
node proving-groth16.js
node proving-plonk.js
```
