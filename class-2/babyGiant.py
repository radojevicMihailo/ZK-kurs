from math import sqrt, ceil
import time

'''
g - generator of the group
y - goal value
p - prime number, moduo
'''
def bsgs(g, y, p, option = False):
    '''
    Solve for x in y = g^x mod p given a prime p.
    If p is not prime, you shouldn't use BSGS anyway.
    '''

    # calculating size of steps of baby and giant phase
    # two pase of ~sqrt(p) steps => O(p) -> O(sqrt(p))
    k = round(sqrt(p - 1))

    X = [None] * k

    # baby steps
    for i in range(k):
        X[i] = pow(g, i, p) # g^i mod p -> X

    # Calculating inverse of g^k mod p using Fermat's little theorem
    # g^(p-1) ≡ 1 mod p
    inv = pow(g, k * (p - 2), p)

    if option:
        print("X: ")
        for i in range(k): print(i, ":", X[i])
        Y = [None] * k

    # Giant step, search for match in the list
    # y * g^(-j * k) ≡ g^i mod p
    # x = i + j * k
    # => x can be calculated as combination of baby and giant step
    for j in range(k):
        tmp = (y * pow(inv, j, p)) % p
        if option: Y[j] = tmp

        if tmp in X:
            if option: print("Y: ", Y[:j+1])
            return X.index(tmp) + j * k

    # Solution not found
    return None

start_time = time.perf_counter()

# print(bsgs(23, 31, 137, True))
# print(bsgs(5, 3, 23, True))
# print(bsgs(7, 77, 14947, True))
# print(bsgs(11, 1849836, 2097151))
# print(bsgs(9, 711087309, 1073741823))
end_time = time.perf_counter()

execution_time = end_time - start_time
print(f"Execution time: {execution_time} s")

p = 2**512 - 1
mem = int(ceil(sqrt(p - 1)))
print(mem)