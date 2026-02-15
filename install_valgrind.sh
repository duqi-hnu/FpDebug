#!/bin/bash
set -euo pipefail

# Requires patched versions of GMP and MPFR to be present at the following paths.
BASE=$(pwd)
GMP_INSTALL_DIR="${BASE}"/gmp/gmp-5.0.1/install
MPFR_INSTALL_DIR="${BASE}"/mpfr/mpfr-3.0.0/install
VALGRIND_VERSION="3.22.0"
VALGRIND_TARBALL="valgrind-${VALGRIND_VERSION}.tar.bz2"
VALGRIND_DOWNLOAD_URL="https://sourceware.org/pub/valgrind/${VALGRIND_TARBALL}"
sed -e 's,<GMP_INSTALL_DIR>,'"${GMP_INSTALL_DIR}"',g' valgrind/fpdebug/Makefile_template.in > valgrind/fpdebug/Makefile_tmp.in
sed -e 's,<MPFR_INSTALL_DIR>,'"${MPFR_INSTALL_DIR}"',g' valgrind/fpdebug/Makefile_tmp.in > valgrind/fpdebug/Makefile.in
rm valgrind/fpdebug/Makefile_tmp.in

cd valgrind
if [ ! -f "${VALGRIND_TARBALL}" ]; then
	curl -fsSL "${VALGRIND_DOWNLOAD_URL}" -o "${VALGRIND_TARBALL}"
fi

tar -jxvf "${VALGRIND_TARBALL}" --strip 1

# Add fpdebug Makefile to ac_config_files in configure (once).
if ! grep -q "fpdebug/Makefile" configure; then
	sed -e 's,none/Makefile none/tests/Makefile,fpdebug/Makefile none/Makefile none/tests/Makefile,g' configure > configure_tmp
	mv configure_tmp configure
	chmod +x configure
fi

# Add fpdebug to the tool list. Valgrind versions differ in how tools are grouped.
if ! grep -Eq '(^|[[:space:]])fpdebug([[:space:]]|$)' Makefile.in; then
	if grep -q "exp-dhat" Makefile.in; then
		sed -e 's,exp-dhat,exp-dhat fpdebug,g' Makefile.in > Makefile_tmp.in
	else
		perl -0pe 's/\n\t\tnone\n/\n\t\tnone \\\n\t\tfpdebug\n/' Makefile.in > Makefile_tmp.in
	fi
	mv Makefile_tmp.in Makefile.in
fi

./configure --prefix="${BASE}"/valgrind/install
# The legacy FpDebug Makefile template does not auto-create DEPDIR
# with newer Automake-generated top-level rules.
mkdir -p fpdebug/.deps
make -j"$(nproc)" install

