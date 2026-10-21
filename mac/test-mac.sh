#!/bin/bash
# Run the example design (lep/leparagliding.txt) with the Mac build and compare
# the results with the output files that are committed next to it in lep/
# (lines.txt, leparagliding.dxf, lep-3d.dxf, run-log.txt, made by the 3.29.1 release).
#
#   ./mac/test-mac.sh [tolerance]      default relative tolerance 1e-6
#
# Run ./mac/build-mac.sh first, and run this on an unmodified lep/ folder
# (the committed output files are the reference).

set -e
# Same reason as in build-mac.sh: macOS sed/awk reject ISO-8859 bytes in a UTF-8 locale.
export LC_ALL=C
cd "$(dirname "$0")/.."

TOL=${1:-1e-6}
ARCH=$(uname -m)
VERSION=$(sed -n 's/^ *lepv *= *"\([^"]*\)".*/\1/p' lep/leparagliding.f | head -1)
[ -n "$VERSION" ] || { echo "Could not read the version (lepv) from lep/leparagliding.f" >&2; exit 1; }
BIN="$PWD/lep/lep-$VERSION-mac-$ARCH.out"

[ -x "$BIN" ] || { echo "Missing $BIN - run ./mac/build-mac.sh first" >&2; exit 1; }

# The program reads its input from the current folder and writes ../xflr5, ../stl,
# so run it in a scratch copy: <tmp>/lep
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
mkdir "$WORK/lep"
cp lep/leparagliding.txt lep/gnuReflex.txt "$WORK/lep/"
# The program creates ../xflr5 and ../stl itself (system "mkdir -p"). Only for trying
# this script on a non-Unix shell: TEST_PRECREATE_DIRS=1 creates them beforehand.
[ -n "$TEST_PRECREATE_DIRS" ] && mkdir -p "$WORK/xflr5" "$WORK/stl"

echo "Running the example design ($(basename "$BIN"))..."
( cd "$WORK/lep" && "$BIN" < /dev/null > console.txt 2>&1 ) || { tail -20 "$WORK/lep/console.txt"; echo "FAIL: program returned an error" >&2; exit 1; }

[ -s "$WORK/lep/lep-out.txt" ] || { echo "FAIL: lep-out.txt was not written" >&2; exit 1; }

# compare <file>: identical bytes, or numbers within the tolerance and all other text identical.
compare() {
  local f=$1 got="$WORK/lep/$1" ref="lep/$1"
  [ -s "$got" ] || { echo "FAIL: $f was not written" >&2; return 1; }
  if cmp -s "$got" "$ref"; then echo "  $f: identical"; return 0; fi
  awk -v tol="$TOL" -v name="$f" '
    function isnum(s) { return s ~ /^[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eEdD][-+]?[0-9]+)?$/ }
    function val(s)   { gsub(/[dD]/, "e", s); return s + 0 }
    function abs(x)   { return x < 0 ? -x : x }
    NR == FNR { gsub(/^[ \t]+|[ \t\r]+$/, ""); ref[FNR] = $0; nref = FNR; next }
    {
      gsub(/^[ \t]+|[ \t\r]+$/, "")
      n = split($0, a, /[ \t]+/); m = split(ref[FNR], b, /[ \t]+/)
      bad = (n != m)
      for (i = 1; i <= n && i <= m && !bad; i++) {
        if (a[i] == b[i]) continue
        if (isnum(a[i]) && isnum(b[i])) {
          x = val(a[i]); y = val(b[i]); d = abs(x - y); s = (abs(y) > 1e-9 ? abs(y) : 1e-9)
          if (d / s > maxrel) maxrel = d / s
          if (d / s > tol) bad = 1
        } else bad = 1
      }
      if (bad) { nbad++; if (nbad <= 3) printf "    line %d:\n      got: %s\n      ref: %s\n", FNR, $0, ref[FNR] }
      nlines = FNR
    }
    END {
      if (nlines != nref) { printf "  %s: FAIL, %d lines, reference has %d\n", name, nlines, nref; exit 1 }
      if (nbad) { printf "  %s: FAIL, %d of %d lines differ\n", name, nbad, nlines; exit 1 }
      printf "  %s: same within tolerance (largest relative difference %.1e)\n", name, maxrel
    }' "$ref" "$got"
}

status=0
for f in lines.txt run-log.txt lep-3d.dxf leparagliding.dxf; do compare "$f" || status=1; done

if [ $status -eq 0 ]; then echo "PASS"; else echo "FAIL"; exit 1; fi
