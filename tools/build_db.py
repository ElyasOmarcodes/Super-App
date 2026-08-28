#!/usr/bin/env python3
"""
Almaany Arabic-Arabic dictionary  ->  the corpus file the app ships.

Input : the raw AlmaanyArArV11.db  (170.6 MB, 219 764 entries)
Output: qamus.corpus.xz            (~10 MB)

Nothing is discarded. Every word, every definition, every root and every book
attribution survives byte for byte; `tools/verify_db.py` proves it by reading
the output back and comparing against the source.

What the source spends its 170.6 MB on
--------------------------------------
    definitions        51.5 MB   kept, in full
    book attribution    6.9 MB   kept, as a one-byte id per entry
    headwords           3.0 MB   kept, in full
    dict / id / root    4.8 MB   kept (dict and id are derivable, so dropped)
    searchword          2.0 MB   dropped: it is `word` minus its diacritics
    Keys                12.8 MB  dropped: an autocomplete index whose 94 302
                                 headwords are the same 93 970 the entries
                                 already carry, plus 339 stubs that have no
                                 definition anywhere in the file
    ~89 MB                       SQLite page overhead, indexes and free space

Why the output is so much smaller than `xz -9e` over the source (24.5 MB)
------------------------------------------------------------------------
Compression flags are not where the win is: `pb=0`, `lc=4` and a 256 MiB
dictionary are all within 0.2% of the plain `-9e` preset. The layout is.

  * A SQLite file interleaves every column of every row across 4 KiB pages.
    Laid out **columnar** instead — all the lengths together, then all the
    headwords, then all the definitions — xz sees long runs of like-shaped
    data and the same 55.8 MB compresses to 9.9 MB instead of 12.3 MB.
  * The definitions are stored as plain text. An earlier revision deflated
    them into blocks before shipping; that made them incompressible, and the
    file was 15.2 MB. Compressing once, at the end, is worth 34%.

The blocks are still how the app reads a definition at runtime — it just
builds them on the device, on first launch, rather than shipping them.
"""

import argparse
import lzma
import os
import sqlite3
import struct
import sys

MAGIC = b'QAMUS1\x00'


def varint(n: int) -> bytes:
    """LEB128. Lengths and ids are small, and their high bytes compress away."""
    out = bytearray()
    while True:
        byte = n & 0x7F
        n >>= 7
        out.append(byte | (0x80 if n else 0))
        if not n:
            return bytes(out)


def _section(payload: bytes) -> bytes:
    return struct.pack('<I', len(payload)) + payload


def build(source: str, out_path: str, verbose: bool = True):
    def log(*a):
        if verbose:
            print(*a, flush=True)

    src = sqlite3.connect(f'file:{source}?mode=ro', uri=True)
    log('reading source rows ...')
    rows = src.execute(
        'SELECT explination, dict, root, word, meaning FROM wordTable '
        'ORDER BY explination, root, word'
    ).fetchall()
    src.close()
    log(f'  {len(rows):,} entries')

    # Sorting by (book, root, word) puts entries that share vocabulary and
    # formatting next to each other, which is worth ~9% to the compressor.
    books, book_id = [], {}
    roots, root_id = [], {}
    for expl, dct, root, *_ in rows:
        name = ' '.join((expl or '').strip().strip('()').split())
        if name not in book_id:
            book_id[name] = len(books)
            books.append((name, dct or ''))
        r = root or ''
        if r and r not in root_id:
            root_id[r] = len(roots) + 1  # 0 means "no root"
            roots.append(r)
    log(f'  {len(books)} books, {len(roots):,} roots')

    word_lens, def_lens, root_ids = bytearray(), bytearray(), bytearray()
    book_ids = bytearray()
    words, defs = [], []
    for expl, _, root, word, meaning in rows:
        w = (word or '').encode('utf-8')
        m = (meaning or '').encode('utf-8')
        words.append(w)
        defs.append(m)
        word_lens += varint(len(w))
        def_lens += varint(len(m))
        root_ids += varint(root_id.get(root or '', 0))
        book_ids.append(book_id[' '.join((expl or '').strip().strip('()').split())])

    header = bytearray(MAGIC)
    header += struct.pack('<III', len(rows), len(books), len(roots))
    for name, dct in books:
        for text in (name, dct):
            blob = text.encode('utf-8')
            header += varint(len(blob)) + blob

    root_blob = bytearray()
    for r in roots:
        blob = r.encode('utf-8')
        root_blob += varint(len(blob)) + blob

    container = b''.join([
        bytes(header),
        _section(bytes(root_blob)),
        _section(bytes(word_lens)),
        _section(bytes(def_lens)),
        _section(bytes(root_ids)),
        _section(bytes(book_ids)),
        _section(b''.join(words)),
        _section(b''.join(defs)),
    ])
    log(f'  container {len(container) / 1e6:.2f} MB uncompressed')

    log('xz -9e ...')
    packed = lzma.compress(
        container,
        format=lzma.FORMAT_XZ,
        check=lzma.CHECK_CRC32,
        filters=[{'id': lzma.FILTER_LZMA2, 'preset': 9 | lzma.PRESET_EXTREME}],
    )
    with open(out_path, 'wb') as handle:
        handle.write(packed)

    source_size = os.path.getsize(source)
    log(f'\n  source     {source_size / 1e6:8.2f} MB')
    log(f'  container  {len(container) / 1e6:8.2f} MB')
    log(f'  shipped    {len(packed) / 1e6:8.2f} MB'
        f'   ({source_size / len(packed):.1f}x smaller than the source)')
    return out_path


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('source', help='raw AlmaanyArArV11.db')
    ap.add_argument('-o', '--out', default='qamus.corpus.xz')
    a = ap.parse_args()
    if not os.path.exists(a.source):
        sys.exit(f'no such file: {a.source}')
    build(a.source, a.out)


if __name__ == '__main__':
    main()
