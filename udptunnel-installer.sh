#!/bin/sh

set -eu

SRCDIR=${SRCDIR:-$(dirname "$(readlink -f "$0")")}
cd "${SRCDIR:?}"

export CFLAGS="${CFLAGS-} -O2 -fPIC -fPIE -fstack-protector-strong -frandom-seed=42 -Wformat -Werror=format-security"
if [ "$(uname -m)" = 'x86_64' ]; then export CFLAGS="${CFLAGS-} -fstack-clash-protection -fcf-protection=full"; fi
export CPPFLAGS="${CPPFLAGS-} -Wdate-time -D_FORTIFY_SOURCE=2"
export LDFLAGS="${LDFLAGS-} -Wl,-pie -Wl,-z,defs -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack"
export SOURCE_DATE_EPOCH=1

make clean
make -j"$(nproc)"
make install
