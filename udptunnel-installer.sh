#!/bin/sh

set -eu

SRCDIR=${SRCDIR:-$(CDPATH='' cd -- "$(dirname -- "${0:?}")" && pwd -P)}
cd -- "${SRCDIR:?}"

export CFLAGS='-O2 -fPIC -fPIE -fstack-protector-strong -frandom-seed=42 -Wformat -Werror=format-security'
if [ "$(uname -m)" = 'x86_64' ]; then export CFLAGS="${CFLAGS-} -fstack-clash-protection -fcf-protection=full"; fi
export CPPFLAGS='-Wdate-time -D_FORTIFY_SOURCE=2'
export LDFLAGS='-Wl,-pie -Wl,-z,defs -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack'
export LC_ALL=C TZ=UTC SOURCE_DATE_EPOCH=1

make clean
make install "$@"
