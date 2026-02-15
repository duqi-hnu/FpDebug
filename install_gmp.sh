#!/bin/bash
set -euo pipefail

BASE=$(pwd)
BUILD_ARCH="$(uname -m)"
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

cd gmp
rm -rf gmp-5.0.1
tar -jxvf gmp-5.0.1.tar.bz2
cd gmp-5.0.1
patch -p1 -i ../gmp-5.0.1.patch
if [ -n "${EXTRA_CFLAGS}" ]; then
	./configure CFLAGS="${EXTRA_CFLAGS}" --build="${BUILD_TRIPLET}" --prefix="${BASE}"/gmp/gmp-5.0.1/install
else
	./configure --build="${BUILD_TRIPLET}" --prefix="${BASE}"/gmp/gmp-5.0.1/install
fi
make -j"$(nproc)" install
# running 'make check' would fail because of the patch

