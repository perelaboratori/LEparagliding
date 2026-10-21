#!/bin/bash
# Check that the Mac programs only depend on libraries that every Mac has,
# i.e. that they will run on a Mac without gfortran / Homebrew installed.
#
#   ./mac/check-self-contained.sh
#
# Run ./mac/build-mac.sh first. Needs otool (comes with the Xcode command line tools).

set -e
export LC_ALL=C
cd "$(dirname "$0")/.."

ARCH=$(uname -m)
status=0
found=0

for f in lep/lep-*-mac-"$ARCH".out pre/pre-*-mac-"$ARCH".out "au/ac (fortran version)/ac-mac-$ARCH.out"; do
  [ -f "$f" ] || continue
  found=1
  echo "$f"
  otool -L "$f" | tail -n +2 | sed 's/^[[:space:]]*/    /'
  # Everything except macOS's own libraries is a problem (Homebrew's libgfortran, libgcc, libquadmath ...)
  bad=$(otool -L "$f" | tail -n +2 | awk '{print $1}' | grep -v -E '^(/usr/lib/|/System/Library/)' || true)
  if [ -n "$bad" ]; then
    echo "  FAIL: needs libraries that are not part of macOS:"
    echo "$bad" | sed 's/^/    /'
    status=1
  else
    echo "  OK: macOS system libraries only"
  fi
done

[ $found -eq 1 ] || { echo "No Mac programs found for $ARCH - run ./mac/build-mac.sh first" >&2; exit 1; }
if [ $status -eq 0 ]; then echo "PASS"; else echo "FAIL"; exit 1; fi
