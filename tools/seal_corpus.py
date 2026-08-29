#!/usr/bin/env python3
"""
Seals the compressed corpus so it cannot simply be lifted out of the package.

The app ships `qamus.corpus.sealed` rather than a bare `.xz`. Anyone who opens
the APK, the .ipa or the Windows bundle finds 11 MB of noise instead of an
archive they can extract and reuse.

The construction matches `app/lib/src/data/vault.dart` exactly:

    magic  "QVLT1\0"                      6 bytes
    salt   random                        16 bytes
    tag    HMAC-SHA256(key, body)        32 bytes
    body   xz XOR keystream(key, salt)   the rest

    key        = PBKDF2-HMAC-SHA256(passphrase, salt, 20000)
    keystream  = HMAC-SHA256(key, salt || counter) for counter = 0, 1, 2 ...

This is a lock, not a vault: the key travels with the app that opens it, so a
determined reader with a disassembler will find it. It stops copying, not
reading — see the note in vault.dart.

    python3 tools/seal_corpus.py in.xz out.sealed
"""

import hashlib
import hmac
import os
import struct
import sys

MAGIC = b'QVLT1\x00'
SALT_BYTES = 16
ROUNDS = 20000

# Assembled the same way the app assembles it, so neither side carries the
# passphrase as a literal that `strings` would print.
_MASK = 0x5A
_VEILED = [0x1F, 0x36, 0x23, 0x3B, 0x29, 0x15, 0x37, 0x3B, 0x28, 0x67, 0x1E, 0x18]


def passphrase() -> bytes:
    return bytes(b ^ _MASK for b in _VEILED)


def derive_key(secret: bytes, salt: bytes) -> bytes:
    return hashlib.pbkdf2_hmac('sha256', secret, salt, ROUNDS, dklen=32)


def keystream_xor(data: bytes, key: bytes, salt: bytes) -> bytes:
    out = bytearray(len(data))
    for block, offset in enumerate(range(0, len(data), 32)):
        stream = hmac.new(key, salt + struct.pack('>Q', block), hashlib.sha256).digest()
        chunk = data[offset:offset + 32]
        out[offset:offset + len(chunk)] = bytes(a ^ b for a, b in zip(chunk, stream))
    return bytes(out)


def seal(plain: bytes) -> bytes:
    salt = os.urandom(SALT_BYTES)
    key = derive_key(passphrase(), salt)
    body = keystream_xor(plain, key, salt)
    tag = hmac.new(key, body, hashlib.sha256).digest()
    return MAGIC + salt + tag + body


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__.strip())
        return 2
    source, target = sys.argv[1], sys.argv[2]
    plain = open(source, 'rb').read()
    sealed = seal(plain)

    # Prove it round-trips before anything is written.
    salt = sealed[len(MAGIC):len(MAGIC) + SALT_BYTES]
    key = derive_key(passphrase(), salt)
    body = sealed[len(MAGIC) + SALT_BYTES + 32:]
    assert keystream_xor(body, key, salt) == plain, 'seal does not round-trip'

    with open(target, 'wb') as handle:
        handle.write(sealed)
    print(f'{source}  {len(plain):,} bytes')
    print(f'{target}  {len(sealed):,} bytes  (+{len(sealed) - len(plain)} header)')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
