#!/usr/bin/env python3
"""
Proves that the shipped corpus lost nothing.

Reads qamus.corpus.xz back into (book, root, word, definition) tuples and
compares them against the same tuples read straight out of the source
database. Anything that does not match byte for byte is printed.

    python3 tools/verify_db.py AlmaanyArArV11.db app/assets/db/qamus.corpus.xz
"""

import argparse
import lzma
import sqlite3
import struct
import sys

MAGIC = b'QAMUS1\x00'


class Reader:
    """The mirror image of build_db.py's writer."""

    def __init__(self, blob: bytes):
        self.b = blob
        self.i = 0

    def u32(self) -> int:
        value, = struct.unpack_from('<I', self.b, self.i)
        self.i += 4
        return value

    def varint(self) -> int:
        value = shift = 0
        while True:
            byte = self.b[self.i]
            self.i += 1
            value |= (byte & 0x7F) << shift
            if not byte & 0x80:
                return value
            shift += 7

    def text(self) -> str:
        n = self.varint()
        out = self.b[self.i:self.i + n].decode('utf-8')
        self.i += n
        return out

    def section(self) -> bytes:
        n = self.u32()
        out = self.b[self.i:self.i + n]
        self.i += n
        return out


def unpack(path: str):
    with open(path, 'rb') as handle:
        blob = lzma.decompress(handle.read())
    r = Reader(blob)
    assert r.b[:len(MAGIC)] == MAGIC, 'not a qamus corpus'
    r.i = len(MAGIC)

    count, book_count, root_count = r.u32(), r.u32(), r.u32()
    books = [(r.text(), r.text()) for _ in range(book_count)]

    roots_reader = Reader(r.section())
    roots = [roots_reader.text() for _ in range(root_count)]

    word_lens = Reader(r.section())
    def_lens = Reader(r.section())
    root_ids = Reader(r.section())
    book_ids = r.section()
    words_blob = r.section()
    defs_blob = r.section()

    w_at = d_at = 0
    for i in range(count):
        wl, dl = word_lens.varint(), def_lens.varint()
        word = words_blob[w_at:w_at + wl].decode('utf-8')
        meaning = defs_blob[d_at:d_at + dl].decode('utf-8')
        w_at += wl
        d_at += dl
        rid = root_ids.varint()
        yield (books[book_ids[i]][0], roots[rid - 1] if rid else '', word, meaning)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('source')
    ap.add_argument('corpus')
    a = ap.parse_args()

    print('reading the shipped corpus ...')
    packed = {}
    for tup in unpack(a.corpus):
        packed[tup] = packed.get(tup, 0) + 1
    print(f'  {sum(packed.values()):,} entries')

    print('reading the source database ...')
    src = sqlite3.connect(f'file:{a.source}?mode=ro', uri=True)
    original = {}
    for expl, root, word, meaning in src.execute(
            'SELECT explination, root, word, meaning FROM wordTable'):
        name = ' '.join((expl or '').strip().strip('()').split())
        tup = (name, root or '', word or '', meaning or '')
        original[tup] = original.get(tup, 0) + 1
    print(f'  {sum(original.values()):,} entries')

    if packed == original:
        chars = sum(len(t[3]) * c for t, c in original.items())
        print(f'\n  IDENTICAL — all {sum(original.values()):,} entries and all '
              f'{chars:,} characters of definition text round-trip byte for byte.')
        return 0

    print('\n  MISMATCH')
    for tup, n in original.items():
        if packed.get(tup, 0) != n:
            print(f'   source only: {tup[:3]}')
    for tup, n in packed.items():
        if original.get(tup, 0) != n:
            print(f'   corpus only: {tup[:3]}')
    return 1


if __name__ == '__main__':
    sys.exit(main())
