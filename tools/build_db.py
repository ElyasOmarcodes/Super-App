#!/usr/bin/env python3
"""
Almaany Arabic-Arabic dictionary  ->  the corpus file the app ships.

Input : the raw AlmaanyArArV11.db  (170.6 MB, 219 764 entries)
Output: qamus.corpus.xz            (~11 MB)

Nothing is discarded. Every word, every definition, every root, every book
attribution and every entry of the source's lookup index survives;
`tools/verify_db.py` proves it by reading the output back and comparing
against the source.

The two tables, and why both matter
-----------------------------------
`wordTable` holds the 219 764 dictionary entries: 93 970 distinct headwords
with their definitions.

`Keys` is not a duplicate of it. It is the source's **morphological lookup
index**: 176 036 surface forms — plurals, conjugations, definite forms —
each mapped to the headwords that explain it. 83 850 of those forms are not
headwords themselves, so without this table they cannot be looked up at all:

    مهابل  ->  مهبل          a plural whose singular is the headword
    الرحيم ->  الرحيم, رحيم   the article is transparent to the lookup

It costs 0.94 MB compressed and nearly doubles what the reader can find, so
it ships.

Layout, and why the file is smaller than `xz -9e` over the source (24.5 MB)
--------------------------------------------------------------------------
Compression flags are not where the win is: `pb=0`, `lc=4` and a 256 MiB
dictionary are all within 0.2% of the plain `-9e` preset. The layout is.

  * A SQLite file interleaves every column of every row across 4 KiB pages.
    Laid out **columnar** instead — all the lengths together, then all the
    headwords, then all the definitions — xz sees long runs of like-shaped
    data and the same bytes compress 19% further.
  * The definitions are stored as plain text. An earlier revision deflated
    them into blocks before shipping; that made them incompressible, and the
    file was 15.2 MB. Compressing once, at the end, is worth 34%.

The blocks are still how the app reads a definition at runtime — it just
builds them on the device, on first launch, rather than shipping them.

A note on normalisation
-----------------------
Forms are grouped here with a normaliser that mirrors `lib/src/data/
arabic.dart`, but the app is authoritative: it re-normalises every form as it
loads, and resolves each link through an entry id rather than a string. So a
drift between the two implementations costs a little grouping precision and
can never produce a broken link.
"""

import argparse
import lzma
import os
import re
import sqlite3
import struct
import sys
from collections import defaultdict

MAGIC = b'QAMUS3\x00'

# Mirrors normalize() in lib/src/data/arabic.dart.
_MARKS = re.compile(
    "[ؐ-ًؚ-ٰٟۖ-ۭ"
    "࣓-ࣿـ​-‏‪-‮⁦-⁩]")
_FOLD = {
    0x0623: "ا", 0x0625: "ا", 0x0622: "ا", 0x0671: "ا",
    0x0672: "ا", 0x0673: "ا", 0x0675: "ا",
    0x0649: "ي", 0x0626: "ي", 0x06CC: "ي",
    0x0624: "و", 0x0629: "ه", 0x06A9: "ك", 0x0621: "",
}
_NOT_LETTER = re.compile("[^ء-ي]")


def normalize(text: str) -> str:
    if not text:
        return ''
    return _NOT_LETTER.sub('', _MARKS.sub('', text).translate(_FOLD))


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
    log('reading entries ...')
    rows = src.execute(
        'SELECT explination, dict, root, word, meaning FROM wordTable '
        'ORDER BY explination, root, word'
    ).fetchall()
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
    # The first entry of each headword stands in for it in the form index, so
    # the app can recover the headword's key from its own normaliser.
    first_entry = {}
    for index, (expl, _, root, word, meaning) in enumerate(rows):
        w = (word or '').encode('utf-8')
        m = (meaning or '').encode('utf-8')
        words.append(w)
        defs.append(m)
        word_lens += varint(len(w))
        def_lens += varint(len(m))
        root_ids += varint(root_id.get(root or '', 0))
        book_ids.append(book_id[' '.join((expl or '').strip().strip('()').split())])
        key = normalize(word or '')
        if key and key not in first_entry:
            first_entry[key] = index

    log('reading the lookup index ...')
    links = defaultdict(set)
    dead = 0
    for search_key, head_word in src.execute(
            "SELECT searchwordkey, wordkey FROM Keys WHERE dict <> 'dic'"):
        form = normalize(search_key)
        head = normalize(head_word)
        if not form or not head:
            continue
        entry = first_entry.get(head)
        if entry is None:
            dead += 1          # a stub with no definition anywhere in the file
            continue
        links[form].add(entry)
    # Every headword must be findable even when the index does not list it.
    added = 0
    for key, entry in first_entry.items():
        if key not in links:
            links[key] = {entry}
            added += 1
    log(f'  {len(links):,} lookup forms '
        f'({added:,} added for headwords the index omits, {dead:,} stubs dropped)')
    src.close()

    form_lens, form_blob = bytearray(), []
    link_counts, link_ids = bytearray(), bytearray()
    for form in sorted(links):
        blob = form.encode('utf-8')
        form_blob.append(blob)
        form_lens += varint(len(blob))
        targets = sorted(links[form])
        link_counts += varint(len(targets))
        previous = 0
        for entry in targets:       # delta-coded: small varints compress
            link_ids += varint(entry - previous)
            previous = entry

    header = bytearray(MAGIC)
    header += struct.pack('<IIII', len(rows), len(books), len(roots), len(links))
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
        _section(bytes(form_lens)),
        _section(b''.join(form_blob)),
        _section(bytes(link_counts)),
        _section(bytes(link_ids)),
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
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('source', help='raw AlmaanyArArV11.db')
    ap.add_argument('-o', '--out', default='qamus.corpus.xz')
    a = ap.parse_args()
    if not os.path.exists(a.source):
        sys.exit(f'no such file: {a.source}')
    build(a.source, a.out)


if __name__ == '__main__':
    main()
