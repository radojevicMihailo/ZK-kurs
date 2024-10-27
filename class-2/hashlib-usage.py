import hashlib

# Kreiranje SHA-256 hash-a
data = "Hello, World!"
sha256_hash = hashlib.sha256(data.encode()).hexdigest()

print(f"SHA-256 Hash: {sha256_hash}")

blake2_hash = hashlib.blake2b(data.encode()).hexdigest()

print(f"BLAKE2 Hash: {blake2_hash}")


def hash_file(filepath):
    hash_sha256 = hashlib.sha256()  # SHA-256 hash object init

    with open(filepath, 'rb') as f:  # open file as binary
        # read  andupdate hash object per blocks
        for byte_block in iter(lambda: f.read(4096), b""):
            hash_sha256.update(byte_block)

    return hash_sha256.hexdigest()  # return hex hash

# usage example
file_hash = hash_file("example.txt")
print(f"SHA-256 Hash of the file: {file_hash}")
