LEparagliding for macOS
=======================

The Fortran sources compile unchanged on macOS (Apple Silicon and Intel).
This folder only adds a build script, two check scripts and a CI workflow;
no program source is modified.

Status - please read
--------------------
Built and tested automatically on GitHub's Mac machines (Apple Silicon and Intel):
the three programs build, the example design gives the same result files as the
Linux/Windows version, and the programs need no extra libraries.

NOT yet tested by a person on their own Mac. If it does not work for you, please tell us:
  * open an issue: https://github.com/perelaboratori/LEparagliding/issues  ("New issue")
  * or write to Pere: pere@laboratoridenvol.com
Please include: your Mac (Apple menu > About This Mac: the chip or processor, and the
macOS version), what you typed, the exact message shown in Terminal (copy and paste it),
and the file run-log.txt if the program wrote one.

Ready-made programs (nothing to build)
--------------------------------------
The finished Mac programs are in this repository, next to the Linux and Windows ones:

    lep/lep-3.29.1-mac-arm64.out      pre/pre-1.6-mac-arm64.out      au/ac (fortran version)/ac-mac-arm64.out
    lep/lep-3.29.1-mac-x86_64.out     pre/pre-1.6-mac-x86_64.out     au/ac (fortran version)/ac-mac-x86_64.out

arm64 = a Mac with an Apple M chip, x86_64 = an Intel Mac (Apple menu > About This Mac).
They were built by GitHub's automatic build from the sources in this repository.
They are not signed by Apple, so after downloading, macOS may refuse to open them. Once, in
Terminal, in the folder with the program:

    xattr -d com.apple.quarantine lep-3.29.1-mac-arm64.out
    chmod +x lep-3.29.1-mac-arm64.out

Then run it as described under "Run" below. To build the programs yourself, read on.

Build on your Mac
-----------------
1. Install gfortran (once). With Homebrew (https://brew.sh):

       brew install gcc

2. In Terminal, from the main folder of this repository:

       ./mac/build-mac.sh

   This creates, next to each source file:

       lep/lep-3.29.1-mac-arm64.out      (Apple Silicon)   or   ...-mac-x86_64.out  (Intel)
       pre/pre-1.6-mac-<arch>.out
       au/ac (fortran version)/ac-mac-<arch>.out

   Options:  ./mac/build-mac.sh lep   (only the main program; also: pre, ac)

3. Check the build against the example design:

       ./mac/test-mac.sh

   It runs lep/leparagliding.txt in a scratch folder and compares the results
   (lines.txt, run-log.txt, lep-3d.dxf, leparagliding.dxf) with the files of the
   same names committed in lep/, which were made by the 3.29.1 release. Numbers
   may differ in the last digits (tolerance 1e-6). It prints PASS or FAIL.
   Use it on an unmodified lep/ folder.

4. Optional: check the programs run on a Mac without gfortran installed:

       ./mac/check-self-contained.sh

   It lists the libraries each program needs (otool -L) and fails if any of them
   is not part of macOS.

Run
---
Like the Linux version: put your design file named leparagliding.txt, and the
airfoil files it names, in the same folder as the program, and run it from
that folder:

    cd lep
    ./lep-3.29.1-mac-arm64.out

The outputs (leparagliding.dxf, lep-out.txt, lines.txt, run-log.txt) are
written to the same folder; xflr5/ and stl/ are created one level up.

Notes
-----
* The program reserves about 0.9 GB of memory for its arrays (the Linux
  program does the same). macOS gives it only what it actually uses.
* A program built on your own Mac runs directly. A program downloaded from
  somewhere else (including the CI artifact) is not signed by Apple: macOS may
  refuse to open it. Remove the block once with
      xattr -d com.apple.quarantine <file>
* Mac Terminal users can repair NaN values in the DXF with noNaN/noNaN.sh.
  On macOS, sed needs an empty suffix:   sed -i '' 's/NaN/0.0/g' leparagliding.dxf

Manual
------
The manual is in this repository, in the folder "LEP-manual (html)": open manual.en.html
(English; manual.fr.html and manual.ru.html are the French and Russian versions) in your
browser. Keep the whole folder together, the pictures are in the sub-folders next to the page.
On GitHub's website an .html file only shows its source code. To read it: Code > Download ZIP,
unzip, then double-click manual.en.html (or in Terminal:  open "LEP-manual (html)/manual.en.html").
Online version: http://laboratoridenvol.com/leparagliding/manual.en.html
What is new in 3.29: man/lep-3.29-update.pdf and man/Updates_log.txt.

Automatic builds
----------------
.github/workflows/mac-build.yml builds both architectures on GitHub's macOS
machines, runs the check above, and attaches the programs to the run
(Actions tab, "Build for macOS", Artifacts).
