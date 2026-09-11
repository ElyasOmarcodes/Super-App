#!/usr/bin/env bash
#
# Signs the unsigned Play bundle with your own upload key.
#
# CI builds the bundle with no signature at all, on purpose: signing a
# bundle that already carries the debug signature leaves both in META-INF,
# and Play rejects that. So the last step is yours, on a machine that has
# the keystore — this script is that step.
#
#   tools/sign_for_play.sh qamus-release.aab upload-keystore.jks upload
#
# Nothing here is stored, echoed or written anywhere: the two passwords are
# read from the terminal with echo off, and the bundle is signed in place.

set -euo pipefail

bundle=${1:-}
keystore=${2:-}
alias=${3:-upload}

if [ -z "$bundle" ] || [ -z "$keystore" ]; then
  sed -n '3,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi
[ -f "$bundle" ]   || { echo "no such bundle: $bundle";   exit 1; }
[ -f "$keystore" ] || { echo "no such keystore: $keystore"; exit 1; }

command -v jarsigner >/dev/null || {
  echo "jarsigner not found — install a JDK (it ships with one)"; exit 1
}

# An .aab is signed with jarsigner, not apksigner: apksigner speaks the APK
# signature schemes, which a bundle does not use.
read -r -s -p "keystore password: " storepass; echo
read -r -s -p "key password for '$alias' (empty = same): " keypass; echo
[ -n "$keypass" ] || keypass=$storepass

jarsigner \
  -keystore "$keystore" \
  -storepass "$storepass" \
  -keypass "$keypass" \
  -sigalg SHA256withRSA \
  -digestalg SHA-256 \
  "$bundle" "$alias"

echo
# Not -strict: an upload key is self-signed by definition, and -strict turns
# that into a failure. What matters is that the signature verifies.
if jarsigner -verify "$bundle" | grep -q 'jar verified'; then
  echo "OK — $bundle is signed and ready to upload."
else
  echo "the signature did not verify — do not upload this file" >&2
  exit 1
fi
