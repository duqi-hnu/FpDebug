#!/bin/bash
set -euo pipefail

BASE=$(pwd)
BUILD_ARCH="$(uname -m)"
GMP_CFLAGS="-fno-stack-protector"
EXTRA_CFLAGS=""
case "${BUILD_ARCH}" in
	x86_64|amd64) BUILD_TRIPLET="x86_64-unknown-linux-gnu" ;;
	aarch64|arm64)
		BUILD_TRIPLET="aarch64-unknown-linux-gnu"
		# Avoid libgcc LSE runtime probing (__getauxval) in static Valgrind tool linkage.
		EXTRA_CFLAGS="-mno-outline-atomics"
		;;
	*) BUILD_TRIPLET="${BUILD_ARCH}-unknown-linux-gnu" ;;
esac
if [ -n "${EXTRA_CFLAGS}" ]; then
	GMP_CFLAGS="${GMP_CFLAGS} ${EXTRA_CFLAGS}"
fi

cd gmp
rm -rf gmp-5.0.1
tar -jxvf gmp-5.0.1.tar.bz2
cd gmp-5.0.1
patch -p1 -i ../gmp-5.0.1.patch
./configure CFLAGS="${GMP_CFLAGS}" --build="${BUILD_TRIPLET}" --prefix="${BASE}"/gmp/gmp-5.0.1/install
make -j"$(nproc)" install
# running 'make check' would fail because of the patch

