#!/usr/bin/env python3
"""
Almaany Arabic-Arabic dictionary  ->  ultra-compact application database.

Input : the raw AlmaanyArArV11.db  (~170 MB, 219 764 rows)
Output: qamus.db          - compact, index-free SQLite database
        qamus.db.xz       - LZMA2/extreme compressed asset that ships in the app

Size strategy
-------------
1.  Everything that can be *derived* on the device is not shipped at all:
      * the search key   `k`  (diacritic-free / hamza-folded form of the word)
      * the reversed key `kr` (used for the "ends with ..." search)
      * every index
    The app rebuilds them once, on first launch.
2.  The definitions (51.5 MB of Arabic text) are stored as *solid* deflate
    blocks of 512 consecutive entries, ordered by (book, root, word) so that
    neighbouring entries share vocabulary and formatting.  Deflate is used - not
    LZMA - because dart:io exposes zlib natively, so a lookup costs ~1 ms and
    needs no third-party runtime dependency.
3.  The resulting file is then compressed once more with xz -9e for shipping.
"""

import argparse
import os
import re
import sqlite3
import sys
import zlib
import lzma

CHUNK = 512           # entries per solid deflate block
LEVEL = 9             # deflate level

# ---------------------------------------------------------------- normalising
# Arabic combining marks: harakat, tanween, shadda, sukun, superscript alef,
# quranic annotation marks, plus tatweel.
_DIACRITICS = re.compile(r'[ؐ-ًؚ-ٰٟۖ-ۭـ]')
_FOLD = str.maketrans({
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا', 'ا': 'ا',
    'ى': 'ي', 'ئ': 'ي',
    'ؤ': 'و',
    'ة': 'ه',
    'ﻻ': 'لا',
})
_NONLETTER = re.compile(r'[^ء-ي]')


def norm_key(word: str) -> str:
    """Loose search key: strip marks, fold hamza/alef/ya/ta-marbuta, drop punctuation."""
    if not word:
        return ''
    s = _DIACRITICS.sub('', word)
    s = s.translate(_FOLD)
    s = _NONLETTER.sub('', s)
    return s


# ------------------------------------------------------------------- building
def build(src_path: str, out_path: str, verbose=True):
    def log(*a):
        if verbose:
            print(*a, flush=True)

    src = sqlite3.connect(f'file:{src_path}?mode=ro', uri=True)

    log('reading source rows ...')
    rows = src.execute(
        'SELECT explination, dict, root, word, meaning '
        'FROM wordTable '
        'ORDER BY explination, root, word'
    ).fetchall()
    log(f'  {len(rows):,} rows')

    # -- books ---------------------------------------------------------------
    books, book_id = [], {}
    for expl, dct, *_ in rows:
        name = (expl or '').strip()
        if name.startswith('(') and name.endswith(')'):
            name = name[1:-1]
        name = ' '.join(name.split())          # collapse the double spaces in the source
        if name not in book_id:
            book_id[name] = len(books) + 1
            books.append((book_id[name], name, dct or ''))

    # -- roots ---------------------------------------------------------------
    roots, root_id = [], {}
    for _, _, root, *_ in rows:
        r = (root or '').strip()
        if r and r not in root_id:
            root_id[r] = len(roots) + 1
            roots.append((root_id[r], r))

    log(f'  {len(books)} books, {len(roots):,} roots')

    if os.path.exists(out_path):
        os.remove(out_path)
    db = sqlite3.connect(out_path)
    db.executescript("""
        PRAGMA journal_mode = OFF;
        PRAGMA synchronous  = OFF;
        PRAGMA page_size    = 4096;

        CREATE TABLE meta   (k TEXT PRIMARY KEY, v TEXT);
        CREATE TABLE books  (id INTEGER PRIMARY KEY, name TEXT NOT NULL,
                             dict TEXT, n INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE roots  (id INTEGER PRIMARY KEY, r TEXT NOT NULL);
        -- k / kr are filled in on the device (they are pure functions of w)
        CREATE TABLE entries(id INTEGER PRIMARY KEY,
                             w TEXT NOT NULL,
                             rid INTEGER,
                             b INTEGER NOT NULL,
                             k TEXT, kr TEXT);
        CREATE TABLE chunks (id INTEGER PRIMARY KEY, z BLOB NOT NULL);
    """)

    db.executemany('INSERT INTO books(id,name,dict) VALUES (?,?,?)', books)
    db.executemany('INSERT INTO roots(id,r)         VALUES (?,?)',   roots)

    log('packing entries + definition chunks ...')
    entries, pending, chunk_id, raw_bytes, comp_bytes = [], [], 0, 0, 0

    def flush():
        nonlocal chunk_id, pending, raw_bytes, comp_bytes
        if not pending:
            return
        blob = b'\x00'.join(pending)
        z = zlib.compress(blob, LEVEL)
        raw_bytes += len(blob)
        comp_bytes += len(z)
        db.execute('INSERT INTO chunks(id,z) VALUES (?,?)', (chunk_id, sqlite3.Binary(z)))
        chunk_id += 1
        pending = []

    for i, (expl, dct, root, word, meaning) in enumerate(rows):
        name = ' '.join((expl or '').strip().strip('()').split())
        entries.append((i,
                        word or '',
                        root_id.get((root or '').strip()),
                        book_id[name]))
        pending.append((meaning or '').encode('utf-8'))
        if len(pending) == CHUNK:
            flush()
    flush()

    db.executemany('INSERT INTO entries(id,w,rid,b) VALUES (?,?,?,?)', entries)
    db.execute('UPDATE books SET n = (SELECT COUNT(*) FROM entries WHERE entries.b = books.id)')
    db.executemany('INSERT INTO meta(k,v) VALUES (?,?)', [
        ('schema',  '1'),
        ('chunk',   str(CHUNK)),
        ('entries', str(len(entries))),
        ('source',  'Almaany Ar-Ar v11'),
    ])
    db.commit()
    db.execute('VACUUM')
    db.commit()
    db.close()
    src.close()

    log(f'  definitions {raw_bytes/1e6:8.2f} MB -> {comp_bytes/1e6:6.2f} MB '
        f'({raw_bytes/max(comp_bytes,1):.2f}x, {chunk_id:,} blocks)')

    # -- ship envelope -------------------------------------------------------
    log('xz -9e ...')
    filt = [{'id': lzma.FILTER_LZMA2, 'preset': 9 | lzma.PRESET_EXTREME}]
    with open(out_path, 'rb') as f:
        data = f.read()
    xz = lzma.compress(data, format=lzma.FORMAT_XZ, check=lzma.CHECK_CRC32, filters=filt)
    with open(out_path + '.xz', 'wb') as f:
        f.write(xz)

    log(f'\n  source   {os.path.getsize(src_path)/1e6:8.2f} MB')
    log(f'  database {len(data)/1e6:8.2f} MB')
    log(f'  shipped  {len(xz)/1e6:8.2f} MB   '
        f'({os.path.getsize(src_path)/len(xz):.1f}x smaller than the source)')
    return out_path + '.xz'


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('source', help='raw AlmaanyArArV11.db')
    ap.add_argument('-o', '--out', default='qamus.db')
    a = ap.parse_args()
    if not os.path.exists(a.source):
        sys.exit(f'no such file: {a.source}')
    build(a.source, a.out)


if __name__ == '__main__':
    main()
