#!/bin/bash
set -euo pipefail

# This script requires a patched GMP version to be installed at $(pwd)/gmp/gmp-5.0.1/install
# install_gmp.sh installs a patched GMP version there.
BASE=$(pwd)
cd mpfr
rm -rf mpfr-3.0.0
tar -jxvf mpfr-3.0.0.tar.bz2
cd mpfr-3.0.0
cp ../valgrind_additions.c .
patch -p1 -i ../mpfr-3.0.0.patch
# MPFR 3.0.0 + this patch requires -fcommon on modern GCC/Clang,
# and stack protector must be disabled for static Valgrind tool linkage.
./configure CFLAGS="-fcommon -fno-stack-protector" --prefix="${BASE}"/mpfr/mpfr-3.0.0/install --with-gmp="${BASE}"/gmp/gmp-5.0.1/install
make -j"$(nproc)" install
# running 'make check' would fail because of the patch

