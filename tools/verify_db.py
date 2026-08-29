#!/usr/bin/env python3
"""
Proves that the shipped corpus lost nothing.

Reads qamus.corpus.xz back and compares it against the source database on both
of the source's tables:

  * every (book, root, word, definition) tuple from `wordTable`;
  * every (form -> headword) link from `Keys`, the morphological lookup index.

Anything that does not match is printed.

    python3 tools/verify_db.py AlmaanyArArV11.db app/assets/db/qamus.corpus.xz
"""

import argparse
import lzma
import os
import sqlite3
import struct
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_db import MAGIC, normalize  # noqa: E402


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
    """Returns the entries and the form index, as the app reads them."""
    with open(path, 'rb') as handle:
        blob = lzma.decompress(handle.read())
    r = Reader(blob)
    assert r.b[:len(MAGIC)] == MAGIC, 'not a qamus corpus'
    r.i = len(MAGIC)

    count, book_count, root_count, form_count = (
        r.u32(), r.u32(), r.u32(), r.u32())
    books = [(r.text(), r.text()) for _ in range(book_count)]

    roots_reader = Reader(r.section())
    roots = [roots_reader.text() for _ in range(root_count)]

    word_lens = Reader(r.section())
    def_lens = Reader(r.section())
    root_ids = Reader(r.section())
    book_ids = r.section()
    words_blob = r.section()
    defs_blob = r.section()
    form_lens = Reader(r.section())
    forms_blob = r.section()
    link_counts = Reader(r.section())
    link_ids = Reader(r.section())

    entries = []
    w_at = d_at = 0
    for i in range(count):
        wl, dl = word_lens.varint(), def_lens.varint()
        word = words_blob[w_at:w_at + wl].decode('utf-8')
        meaning = defs_blob[d_at:d_at + dl].decode('utf-8')
        w_at += wl
        d_at += dl
        rid = root_ids.varint()
        entries.append(
            (books[book_ids[i]][0], roots[rid - 1] if rid else '', word, meaning))

    links = defaultdict(set)
    f_at = 0
    for _ in range(form_count):
        fl = form_lens.varint()
        form = forms_blob[f_at:f_at + fl].decode('utf-8')
        f_at += fl
        entry = 0
        for _ in range(link_counts.varint()):
            entry += link_ids.varint()      # delta-coded within each form
            links[form].add(normalize(entries[entry][2]))
    return entries, links


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('source')
    ap.add_argument('corpus')
    a = ap.parse_args()

    print('reading the shipped corpus ...')
    entries, links = unpack(a.corpus)
    packed = defaultdict(int)
    for tup in entries:
        packed[tup] += 1
    print(f'  {len(entries):,} entries, {len(links):,} lookup forms')

    print('reading the source database ...')
    src = sqlite3.connect(f'file:{a.source}?mode=ro', uri=True)
    original = defaultdict(int)
    for expl, root, word, meaning in src.execute(
            'SELECT explination, root, word, meaning FROM wordTable'):
        name = ' '.join((expl or '').strip().strip('()').split())
        original[(name, root or '', word or '', meaning or '')] += 1

    headwords = {normalize(w) for (w,) in src.execute('SELECT word FROM wordTable')}
    headwords.discard('')
    source_links = defaultdict(set)
    stubs = 0
    for form, head in src.execute(
            "SELECT searchwordkey, wordkey FROM Keys WHERE dict <> 'dic'"):
        f, h = normalize(form), normalize(head)
        if not f or not h:
            continue
        if h not in headwords:
            stubs += 1          # no definition anywhere in the source
            continue
        source_links[f].add(h)
    print(f'  {sum(original.values()):,} entries, {len(source_links):,} lookup'
          f' forms ({stubs:,} stub links skipped)')

    failures = 0

    if packed == original:
        chars = sum(len(t[3]) * c for t, c in original.items())
        print(f'\n  ENTRIES IDENTICAL — all {sum(original.values()):,} entries'
              f' and all {chars:,} characters of definition text round-trip'
              f' byte for byte.')
    else:
        failures += 1
        print('\n  ENTRY MISMATCH')
        for tup, n in original.items():
            if packed.get(tup, 0) != n:
                print(f'   source only: {tup[:3]}')
        for tup, n in packed.items():
            if original.get(tup, 0) != n:
                print(f'   corpus only: {tup[:3]}')

    missing = {f: hs - links.get(f, set()) for f, hs in source_links.items()}
    missing = {f: hs for f, hs in missing.items() if hs}
    if not missing:
        pairs = sum(len(v) for v in source_links.values())
        print(f'  INDEX IDENTICAL — all {len(source_links):,} lookup forms and'
              f' all {pairs:,} form-to-headword links survive.')
    else:
        failures += 1
        print(f'\n  INDEX MISMATCH — {len(missing):,} forms lost links')
        for form, heads in list(missing.items())[:10]:
            print(f'   {form}: missing {sorted(heads)}')

    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
