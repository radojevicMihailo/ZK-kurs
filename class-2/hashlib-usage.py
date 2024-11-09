import hashlib

# # Kreiranje SHA-256 hash-a
# data = "Hello, World!"
# sha256_hash = hashlib.sha256(data.encode()).hexdigest()

# print(f"SHA-256 Hash: {sha256_hash}")

# blake2_hash = hashlib.blake2b(data.encode()).hexdigest()

# print(f"BLAKE2 Hash: {blake2_hash}")


# def hash_file(filepath):
#     hash_sha256 = hashlib.sha256()  # SHA-256 hash object init

#     with open(filepath, 'rb') as f:  # open file as binary
#         # read  andupdate hash object per blocks
#         for byte_block in iter(lambda: f.read(4096), b""):
#             hash_sha256.update(byte_block)

#     return hash_sha256.hexdigest()  # return hex hash

# # usage example
# file_hash = hash_file("example.txt")
# print(f"SHA-256 Hash of the file: {file_hash}")

data = ["Aleksa", "Prtenjaca", "06.08.2003"]
hash_sha256 = hashlib.sha256()
for i in range(3):
    hash_sha256.update(data[i].encode())
print(hash_sha256.hexdigest())

data = ",".join(data)
sha256_hash = hashlib.sha256(data.encode()).hexdigest()
print(sha256_hash)

ime = "Igor"
prezime = "Antonijevic"
datum_rodjenja = "15.12.2001"
# Kombinujemo podatke u jednu listu
podaci = [ime, prezime, datum_rodjenja]
# Kreiranje SHA-256 heša
hash_obj = hashlib.sha256(str(podaci).encode())
heksadecimalni_hash = hash_obj.hexdigest()
# Prikaz heksadecimalnog heša
print("Heš vrednost u heksadecimalnom formatu:", heksadecimalni_hash)

my_data = ['David', 'Duric', '2001-09-09']
my_data_hashed = []
hash_functions = []

for data in my_data:
    my_data_hashed.append(hashlib.md5(data.encode()).hexdigest())

for data in my_data_hashed:
    print(data)