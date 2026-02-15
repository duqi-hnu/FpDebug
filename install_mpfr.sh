#!/bin/bash
set -euo pipefail

# This script requires a patched GMP version to be installed at $(pwd)/gmp/gmp-5.0.1/install
# install_gmp.sh installs a patched GMP version there.
BASE=$(pwd)
BUILD_ARCH="$(uname -m)"
case "${BUILD_ARCH}" in
	x86_64|amd64) BUILD_TRIPLET="x86_64-unknown-linux-gnu" ;;
	aarch64|arm64) BUILD_TRIPLET="aarch64-unknown-linux-gnu" ;;
	*) BUILD_TRIPLET="${BUILD_ARCH}-unknown-linux-gnu" ;;
esac

cd mpfr
rm -rf mpfr-3.0.0
tar -jxvf mpfr-3.0.0.tar.bz2
cd mpfr-3.0.0
cp ../valgrind_additions.c .
patch -p1 -i ../mpfr-3.0.0.patch
# MPFR 3.0.0 + this patch requires -fcommon on modern GCC/Clang,
# and stack protector must be disabled for static Valgrind tool linkage.
./configure CFLAGS="-fcommon -fno-stack-protector" --build="${BUILD_TRIPLET}" --prefix="${BASE}"/mpfr/mpfr-3.0.0/install --with-gmp="${BASE}"/gmp/gmp-5.0.1/install
make -j"$(nproc)" install
# running 'make check' would fail because of the patch

