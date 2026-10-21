#!/bin/bash
# Build LEparagliding for macOS (Apple Silicon or Intel) from the Fortran sources.
#
#   ./mac/build-mac.sh          build lep, pre and ac
#   ./mac/build-mac.sh lep      build only the main program
#   ./mac/build-mac.sh pre|ac   build only the pre-processor / airfoil converter
#
# Needs gfortran. With Homebrew (https://brew.sh):   brew install gcc
#
# Output (next to each source file):
#   lep/lep-<version>-mac-<arch>.out
#   pre/pre-<version>-mac-<arch>.out
#   au/ac (fortran version)/ac-mac-<arch>.out
# where <arch> is arm64 (Apple Silicon) or x86_64 (Intel).
#
# The compile options follow the Linux build described in lep/Compilation.txt
# (plain gfortran, no optimisation, so results match the reference output).

set -e
# The Fortran sources contain ISO-8859 characters; macOS sed/awk reject them in a UTF-8 locale.
export LC_ALL=C
cd "$(dirname "$0")/.."

ARCH=$(uname -m)
WHAT=${1:-all}

# Find gfortran: plain name first, then Homebrew's versioned names (gfortran-14 ...)
FC=${FC:-}
if [ -z "$FC" ]; then
  for c in gfortran /opt/homebrew/bin/gfortran /usr/local/bin/gfortran \
           $(ls /opt/homebrew/bin/gfortran-* /usr/local/bin/gfortran-* 2>/dev/null | sort -rV); do
    if command -v "$c" >/dev/null 2>&1; then FC=$c; break; fi
  done
fi
if [ -z "$FC" ]; then
  echo "gfortran not found. Install it with:  brew install gcc" >&2
  exit 1
fi
echo "Using $($FC --version | head -1)  [$ARCH]"

# Old-style Fortran. -std=legacy and -fallow-argument-mismatch are safety flags for older or
# newer gfortran versions (gfortran 16 also compiles the three sources without them);
# -ffp-contract=off keeps the arithmetic the same on Apple Silicon and Intel.
BASE="-std=legacy -fallow-argument-mismatch -ffp-contract=off"

# Link the Fortran runtime (libgfortran, libgcc and libquadmath) statically so the program also
# runs on Macs without gfortran. mac/check-self-contained.sh verifies this with otool -L.
# If the static libraries are not available, fall back to the normal dynamic link.
build() {   # build <source.f> <output>
  echo "  $1  ->  $2"
  if ! $FC $BASE -static-libgfortran -static-libgcc -static-libquadmath "$1" -o "$2" 2>/dev/null; then
    echo "    (static runtime not available, linking dynamically: needs Homebrew gcc at run time)"
    $FC $BASE "$1" -o "$2"
  fi
}

VERSION=$(sed -n 's/^ *lepv *= *"\([^"]*\)".*/\1/p' lep/leparagliding.f | head -1)
[ -n "$VERSION" ] || { echo "Could not read the version (lepv) from lep/leparagliding.f" >&2; exit 1; }

if [ "$WHAT" = all ] || [ "$WHAT" = lep ]; then
  build lep/leparagliding.f "lep/lep-$VERSION-mac-$ARCH.out"
fi
if [ "$WHAT" = all ] || [ "$WHAT" = pre ]; then
  build pre/pre-processor.f "pre/pre-1.6-mac-$ARCH.out"
fi
if [ "$WHAT" = all ] || [ "$WHAT" = ac ]; then
  build "au/ac (fortran version)/ac.f" "au/ac (fortran version)/ac-mac-$ARCH.out"
fi

echo "Done."
