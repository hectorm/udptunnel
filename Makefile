PREFIX ?= /usr/local
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
CFLAGS ?= -O2 -frandom-seed=42 -fstack-protector-strong \
	$(if $(shell [ $$($(UNAME) -m) != x86_64 ] || echo YES),-fstack-clash-protection -fcf-protection=full)
CPPFLAGS ?= -Wdate-time -D_FORTIFY_SOURCE=2
LDFLAGS ?= -Wl,-z,defs -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack \
	$(if $(STATIC),-static)
SOURCE_DATE_EPOCH ?= 1
INSTALL ?= install
INSTALL_PROGRAM ?= $(INSTALL)
PKG_CONFIG ?= pkg-config
UNAME ?= uname

ifeq ($(shell $(PKG_CONFIG) --exists libsystemd || echo NO),)
CPPFLAGS += -DHAVE_SYSTEMD_SD_DAEMON_H $(shell $(PKG_CONFIG) --cflags libsystemd)
LDLIBS += $(shell $(PKG_CONFIG) --libs libsystemd)
endif

CFLAGS += -MMD -MP
CFLAGS += -Wall -Wextra

OBJECTS := log.o network.o utils.o udptunnel.o

ifneq ($(V),1)
BUILT_IN_LINK.o := $(LINK.o)
LINK.o = @echo "  LD      $@";
LINK.o += $(BUILT_IN_LINK.o)
BUILT_IN_COMPILE.c := $(COMPILE.c)
COMPILE.c = @echo "  CC      $@";
COMPILE.c += $(BUILT_IN_COMPILE.c)
endif

all: udptunnel

install: udptunnel
	@$(INSTALL) -v -d "$(DESTDIR)$(BINDIR)"
	@$(INSTALL_PROGRAM) -v -m 0755 udptunnel "$(DESTDIR)$(BINDIR)/udptunnel"

install-strip:
	$(MAKE) INSTALL_PROGRAM='$(INSTALL_PROGRAM) -s' install

clean:
	@$(RM) -vf $(OBJECTS) $(OBJECTS:%.o=%.d) udptunnel

udptunnel: $(OBJECTS)

.PHONY: all install clean
-include *.d
