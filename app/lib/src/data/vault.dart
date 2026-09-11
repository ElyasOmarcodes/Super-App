import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Unseals the shipped corpus.
///
/// The asset is not a plain `.xz` any more: it is a sealed container that has
/// to be opened with a passphrase before the LZMA stream inside it appears.
/// Somebody who pulls the file out of the package gets 11 MB of noise.
///
/// ### What this does and does not buy
///
/// It stops the asset being *lifted* — copied out of the package and shipped
/// in somebody else's dictionary, which is the thing worth stopping. It does
/// not make the corpus secret from the person holding the device: the key has
/// to travel with the app that opens it, so a determined reader with a
/// disassembler will find it, and the unsealed database is on disk after the
/// first launch regardless. Encryption whose key ships alongside the
/// ciphertext is a lock on a door, not a vault — worth having, and worth
/// being honest about.
///
/// ### The construction
///
/// A standard one, rather than a homemade one:
///
///  * the key is PBKDF2-HMAC-SHA256 over the passphrase and the file's own
///    salt, so two builds never share a key stream;
///  * the keystream is HMAC-SHA256 in counter mode — a PRF run over a
///    counter, which is how CTR mode is defined — and the ciphertext is the
///    plaintext XOR that stream;
///  * an HMAC-SHA256 tag over the whole sealed body is checked *before* a
///    single byte is decrypted, so a tampered or truncated asset is refused
///    rather than half-inflated into a crash.
class CorpusVault {
  const CorpusVault._();

  /// `QVLT1\0` — tells a sealed asset from a bare `.xz` at a glance.
  static const _magic = [0x51, 0x56, 0x4C, 0x54, 0x31, 0x00];

  static const _saltBytes = 16;
  static const _tagBytes = 32;

  /// Deliberately modest. The passphrase is not a human secret being guarded
  /// against an offline cracker — it ships in the binary — so the only job of
  /// the iteration count is to make the derived key well-mixed. Paying a
  /// second of a reader's first launch for theatre would be worse than
  /// useless.
  static const _rounds = 20000;

  /// Opens [sealed], returning the `.xz` stream inside it.
  ///
  /// Throws [FormatException] if the file is not a sealed corpus, or
  /// [StateError] if it has been altered.
  static Uint8List open(Uint8List sealed, List<int> passphrase) {
    if (sealed.length < _magic.length + _saltBytes + _tagBytes) {
      throw const FormatException('corpus asset is truncated');
    }
    for (var i = 0; i < _magic.length; i++) {
      if (sealed[i] != _magic[i]) {
        throw const FormatException('corpus asset is not a sealed container');
      }
    }

    var at = _magic.length;
    final salt = Uint8List.sublistView(sealed, at, at + _saltBytes);
    at += _saltBytes;
    final tag = Uint8List.sublistView(sealed, at, at + _tagBytes);
    at += _tagBytes;
    final body = Uint8List.sublistView(sealed, at);

    final key = _deriveKey(passphrase, salt);

    // Verify before decrypting: a wrong key or a doctored file should be a
    // clean refusal, not a corrupt stream handed to the decompressor.
    final expected = Hmac(sha256, key).convert(body).bytes;
    if (!_constantTimeEquals(expected, tag)) {
      throw StateError('corpus asset failed its integrity check');
    }

    return _xorKeystream(body, key, salt);
  }

  /// PBKDF2-HMAC-SHA256, one output block — 32 bytes is exactly one.
  static Uint8List _deriveKey(List<int> passphrase, List<int> salt) {
    final mac = Hmac(sha256, passphrase);
    var block = mac.convert([...salt, 0, 0, 0, 1]).bytes;
    final result = Uint8List.fromList(block);
    for (var round = 1; round < _rounds; round++) {
      block = mac.convert(block).bytes;
      for (var i = 0; i < result.length; i++) {
        result[i] ^= block[i];
      }
    }
    return result;
  }

  /// CTR mode: HMAC(key, salt ‖ counter) gives block *n* of the keystream.
  static Uint8List _xorKeystream(
    Uint8List body,
    Uint8List key,
    Uint8List salt,
  ) {
    final out = Uint8List(body.length);
    final mac = Hmac(sha256, key);
    final counter = Uint8List(salt.length + 8)..setRange(0, salt.length, salt);
    final view = ByteData.sublistView(counter, salt.length);

    for (
      var offset = 0, block = 0;
      offset < body.length;
      offset += 32, block++
    ) {
      view.setUint64(0, block);
      final stream = mac.convert(counter).bytes;
      final end = offset + 32 <= body.length ? 32 : body.length - offset;
      for (var i = 0; i < end; i++) {
        out[offset + i] = body[offset + i] ^ stream[i];
      }
    }
    return out;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}

/// The passphrase, assembled at the moment of use.
///
/// Never a string literal: a literal survives compilation verbatim and any
/// `strings` over the binary would print it. These are the bytes with a fixed
/// mask applied, so the constant in the binary is not the passphrase and the
/// passphrase exists only for the microseconds it takes to derive the key.
///
/// This is obfuscation, not secrecy — see [CorpusVault] on why nothing more
/// is achievable when the key has to ship with the lock.
List<int> corpusPassphrase() {
  const mask = 0x5A;
  const veiled = <int>[
    0x1F,
    0x36,
    0x23,
    0x3B,
    0x29,
    0x15,
    0x37,
    0x3B,
    0x28,
    0x67,
    0x1E,
    0x18,
  ];
  return [for (final byte in veiled) byte ^ mask];
}

/// A sanity check the build runs, so a mangled table is caught at test time
/// rather than on a reader's first launch.
String debugPassphraseFingerprint() =>
    sha256.convert(corpusPassphrase()).toString().substring(0, 16);

/// The passphrase as text, for the packing tool's own use only.
String debugPassphraseText() => utf8.decode(corpusPassphrase());
