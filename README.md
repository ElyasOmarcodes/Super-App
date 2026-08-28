# قاموس المعاني — Qamus al-Maani

یو آفلاین عربي–عربي قاموس چې په ډارټ/فلټر کې لیکل شوی دی او د **وینډوز، اندروید او
iOS** لپاره جوړېږي. ټول ۲۱۹٬۷۶۴ مدخلونه له شپږو معاجمو څخه — یو حرف هم نه دی
حذف شوی — په ۱۰ MB کې بند دي. هېڅ انټرنټ ته اړتیا نشته.

An offline Arabic–Arabic dictionary: 219,764 entries from six lexicons, packed
into a 9.9 MB asset with **not one character removed**, and an interface that
speaks Pashto, Persian, Arabic and English.

![the launcher mark](docs/icon.png)

| | |
|---|---|
| ![the dashboard](docs/screens/dashboard.png) | ![search results](docs/screens/search.png) |
| *the dashboard: word of the day, corpus at a glance, the six lexicons* | *live results, collapsed by headword* |
| ![an entry](docs/screens/entry.png) | ![dark](docs/screens/dark.png) |
| *every sense, grouped by its source* | *near-black by night* |

---

## څه شی لري / What it does

| | |
|---|---|
| **څلور ژبې** | عربي (ډیفالټ)، پښتو، فارسي، انګلیسي — هر توری د اپلیکیشن ژباړل کیږي |
| **ژوندی لټون** | له لومړي حرف څخه سمدستي وړاندیزونه؛ ټول شکلونه د یوې کلمې لاندې |
| **د پای لټون** | «ينتهي بـ» — ووایه چې کومې کلمې په «يب» پای ته رسېږي |
| **د کتاب فلټر** | یو معجم، څو، یا ټول شپږ |
| **مشابه کلمې** | د جذر مشتقات او نږدې کلمې، په یو کلیک |
| **د شرحو لټون** | د معناګانو په متن کې لټون |
| **د جذرونو تصفح** | لکه چاپي قاموس: جذر وټاکه، مشتقات یې وګوره |
| **محفوظات** | نښه شوې کلمې او د لوستلو تاریخچه |
| **مډرن ډیزاین** | سپین/تور بک ګراند، رنګین کارټونه، نرم انمیشنونه |

### Six source lexicons

| معجم | مدخلونه |
|---|---|
| معجم اللغة العربية المعاصرة | 53,018 |
| معجم الرائد | 46,764 |
| معجم الوسيط | 43,109 |
| مرادفات وأضداد | 36,906 |
| معجم الغني | 29,681 |
| القاموس المحيط | 10,286 |

---

## هیڅ شی نه دی حذف شوی / Nothing was removed

خام ډېټابیس **۱۷۰.۶ MB** و او د xz په ultra موډ کې **۲۴.۵ MB** کېده. زمونږ فایل
**۹.۹ MB** دی — خو **یو حرف هم کم نه دی**. دا په دې دلیل چې کمپریشن د بیرغونو
(`-9e`, `pb=0`, لوی dictionary) پر ځای د **ترتیب** له لارې ترلاسه شو.

The source is 170.6 MB; `xz -9e` over it is 24.5 MB. The shipped file is 9.9 MB
and every entry survives byte for byte. `tools/verify_db.py` proves it:

```
$ python3 tools/verify_db.py AlmaanyArArV11.db app/assets/db/qamus.corpus.xz
  IDENTICAL — all 219,764 entries and all 28,840,527 characters of
  definition text round-trip byte for byte.
```

### Where the source's 170.6 MB went

| | | |
|---|---:|---|
| definitions | 51.5 MB | **kept in full** |
| headwords | 3.0 MB | **kept in full** |
| roots | 1.3 MB | **kept in full** |
| book attribution | 6.9 MB | **kept**, as a one-byte id per entry |
| `searchword` | 2.0 MB | dropped — it is `word` with its diacritics removed |
| `dict`, `id` | 3.6 MB | dropped — both derivable |
| `Keys` | 12.8 MB | dropped — an autocomplete index. Its 94,302 headwords are the same 93,970 the entries already carry, plus 339 stubs that have **no definition anywhere in the file** |
| the rest | ~89 MB | SQLite page overhead, indexes and free space |

### Where the compression came from

Flags were not the answer. Over the same bytes, `pb=0`, `lc=4` and a 256 MiB
dictionary all land within **0.2%** of the plain `-9e` preset. Layout was:

| | |
|---:|---|
| 15.2 MB | definitions deflated into blocks *before* shipping — already compressed, so xz could not touch them |
| 12.3 MB | definitions stored as plain text inside a SQLite file |
| **9.9 MB** | plain text in a **columnar container** — all the lengths together, then all the headwords, then all the definitions |

A SQLite file interleaves every column of every row across 4 KiB pages. Laid
out columnar instead, xz sees long runs of like-shaped data, and the same
55.8 MB compresses 19% further. Sorting entries by *(book, root, word)* — so
neighbours share vocabulary and formatting — is worth another 9%.

The definition blocks still exist; the app just builds them on the device on
first launch instead of shipping them, along with the search keys and the four
indexes. Everything that can be recomputed is, because recomputing is free and
downloading is not.

```
app/assets/db/qamus.corpus.xz   9.9 MB   shipped
        │  xz -9e
        ▼
   container  55.8 MB           lengths │ headwords │ definitions
        │  one pass on first launch
        ▼
    qamus.db  ~37 MB            + normalised keys, reversed keys, 4 indexes,
                                  definitions in deflate blocks of 512
```

Rebuild it from a source corpus with:

```bash
python3 tools/build_db.py /path/to/AlmaanyArArV11.db -o app/assets/db/qamus.corpus.xz
python3 tools/verify_db.py /path/to/AlmaanyArArV11.db app/assets/db/qamus.corpus.xz
```

### Searching

Arabic readers type without diacritics and rarely agree on hamza seats, so every
query and every headword is folded through one normaliser
(`lib/src/data/arabic.dart`): marks and tatweel stripped, `أإآٱ→ا`, `ىئ→ي`,
`ؤ→و`, `ة→ه`, standalone hamza dropped, everything non-letter discarded. `شَيْء`
and `شي` land on the same key; so do `ذِئْب` and `ذيب`.

That single fold gives all five modes off two B-tree indexes:

| Mode | Query |
|---|---|
| يبدأ بـ | `k >= key AND k < key+￿` |
| ينتهي بـ | the same range scan over `kr`, the reversed key |
| يحتوي على | `k LIKE '%key%'` |
| مطابق تمامًا | `k = key` |
| الجذر | join through `roots` |

Prefix search lands in well under a millisecond; suffix search in about two.
The definition sweep ("بحث في المعاني") has no index to lean on — it inflates
all 430 blocks — so it runs in its own isolate and streams hits as it finds them.

---

## Design

A neutral ground and saturated accents, not a tinted one: `#F7F7FB` by day and
`#0B0B12` by night, with six accent hues carrying the colour through gradient
cards, the lexicon strip and the section headers. One typeface —
**Vazirmatn**, subset to the Arabic ranges plus Latin, 284 KB across four
weights — serves all four interface languages and the Arabic corpus, so nothing
on screen ever falls back to a system font.

Every looping animation (the rosette, the aurora wash) stops when the system
asks for reduced motion, which also makes them testable.

---

## جوړول / Building

```bash
cd app
flutter pub get
flutter test                       # 40 tests, run against the real corpus
flutter run -d windows             # or android, or ios
```

Release builds, all with obfuscation, split debug symbols and icon tree-shaking:

```bash
flutter build apk       --release --split-per-abi --obfuscate --split-debug-info=build/symbols --tree-shake-icons
flutter build windows   --release --obfuscate --split-debug-info=build/symbols --tree-shake-icons
flutter build ios       --release --no-codesign --obfuscate --split-debug-info=build/symbols --tree-shake-icons
```

Regenerate the launcher icons after changing the mark:

```bash
python3 tools/make_icons.py
```

> **Flutter 3.47 or newer** is required to build for Windows. Current toolchains
> ship Visual Studio 2026, and only 3.47+ maps that major version to the
> `Visual Studio 18 2026` CMake generator; older Flutter detects the install,
> then emits the 2019 generator and fails at configure time.
>
> Building for **Linux** additionally downloads the SQLite amalgamation through
> CMake `FetchContent`, so that target needs network access at configure time.
> Android, Windows and iOS use prebuilt or vendored SQLite and do not.

---

## CI artifacts

`.github/workflows/build.yml` analyzes, tests, then builds all three targets.
Each output is compressed with `xz -9e` and uploaded with
`compression-level: 0` — GitHub always wraps artifacts in a zip, and
re-deflating an LZMA stream only makes it bigger.

| Artifact | Contents |
|---|---|
| `qamus-arm64-apk` | **`app-arm64-v8a-release.apk.xz`** — on its own, since it is what almost every phone needs |
| `qamus-android-other` | the armeabi-v7a and x86_64 APKs, and the AAB |
| `qamus-windows` | the release bundle |
| `qamus-ios` | unsigned `.ipa` |

Pushing a `v*` tag additionally publishes them as a GitHub release.

---

## Layout

```
app/
  lib/src/data/     arabic · corpus · bootstrap · dictionary · models · settings
  lib/src/l10n/     locales · strings          four languages, one table
  lib/src/ui/       shell · dashboard · home · entry · roots · deep_search
                    library · settings · about · onboarding/
  lib/src/theme.dart
  assets/db/        qamus.corpus.xz            the packed corpus
  assets/fonts/     Vazirmatn                  subset to the Arabic ranges
  test/             arabic · dictionary · app
tools/
  build_db.py       corpus   ->  shipped container
  verify_db.py      container -> proof that nothing was lost
  make_icons.py     the launcher mark, for every platform slot
```

## Licences

Vazirmatn is used under the SIL Open Font License 1.1; its licence text ships in
`app/assets/licenses/` and is reachable from the app's settings screen. The
dictionary content belongs to its respective publishers.
