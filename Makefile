# version
MAJOR := 1
MINOR := 0
REVIS := 0

# installation settings
DESTDIR ?=
PREFIX  ?= /usr/local
#BINDIR  ?= $(PREFIX)/bin
LIBDIR  ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include
MANDIR  ?= $(PREFIX)/share/man
PKGDIR  ?= $(LIBDIR)/pkgconfig

# Tools (sed must be GNU sed)
SED ?= sed

# initial settings
VERSION := $(MAJOR).$(MINOR).$(REVIS)
SOVER := .$(MAJOR)
SOVEREV := .$(MAJOR).$(MINOR)

HEADERS := libpg.h
SPLITLIB := libpg.so$(SOVEREV)
SPLITPC := libpg.pc
COREOBJS := libpg.o
SINGLEOBJS := $(COREOBJS)
SINGLEFLAGS :=
SINGLELIBS :=
TESTSPECS :=
#ALL := manuals
ALL := libpg.so$(SOVEREV) libpg.pc

# compute targets
#libs ?= all
#ifeq (${libs},split)
# ALL += ${SPLITLIB} ${SPLITPC}
#else ifeq (${libs},single)
# ALL += libpg.so$(SOVEREV) libpg.pc
#else ifeq (${libs},all)
# ALL += libpg.so$(SOVEREV) libpg.pc ${SPLITLIB} ${SPLITPC}
#else ifneq (${libs},none)
# $(error Unknown libs $(libs))
#endif

# display target
#$(info libs    = ${libs})

# settings

override CFLAGS += -fPIC -Wall -Wextra -DVERSION=${VERSION}

ifeq ($(shell uname),Darwin)
 darwin_single = -install_name $(LIBDIR)/libpg.so$(SOVEREV)
endif

# targets

.PHONY: all
all: ${ALL}

libpg.so$(SOVEREV): $(SINGLEOBJS)
	$(CC) -shared -Wl,-soname,libpg.so$(SOVER) $(LDFLAGS) $(darwin_single) -o $@ $^ $(SINGLELIBS)

# pkgconfigs

%.pc: pkgcfgs
	$(SED) -E '/^==.*==$$/{h;d};x;/==$@==/{x;s/VERSION/$(VERSION)/;p;d};x;d' $< > $@

# objects

libpg.o: libpg.c libpg.h
	$(CC) -c $(CFLAGS) -o $@ $<

libpg.c: libpg.re
	re2c $< -o $@ -f

# installing
.PHONY: install
install: all
#	install -d $(DESTDIR)$(INCLUDEDIR)/libpg
#	install -m0644 $(HEADERS)    $(DESTDIR)$(INCLUDEDIR)/libpg
	install -d $(DESTDIR)$(LIBDIR)
	for x in libpg*.so$(SOVEREV); do \
		install -m0755 $$x $(DESTDIR)$(LIBDIR)/ ;\
		ln -sf $$x $(DESTDIR)$(LIBDIR)/$${x%.so.*}.so$(SOVER) ;\
		ln -sf $$x $(DESTDIR)$(LIBDIR)/$${x%.so.*}.so ;\
	done
	install -d $(DESTDIR)/$(PKGDIR)
	install -m0644 libpg*.pc $(DESTDIR)/$(PKGDIR)
#	install -d $(DESTDIR)/$(MANDIR)/man1
#	install -m0644 libpg.1.gz $(DESTDIR)/$(MANDIR)/man1

# deinstalling
.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(LIBDIR)/libpg*.so*
#	rm -rf $(DESTDIR)$(INCLUDEDIR)/libpg

# testing
.PHONY: test test-basic test-specs
test: basic-tests spec-tests

basic-tests: libpg
	@$(MAKE) -C test1 test
	@$(MAKE) -C test2 test
	@$(MAKE) -C test3 test
	@$(MAKE) -C test4 test
	@$(MAKE) -C test5 test
	@$(MAKE) -C test6 test

spec-tests: $(TESTSPECS)

test-specs-%: %-test-specs specs
#	./$< spec/specs/[a-z]*.json > $@.last || true
	diff $@.ref $@.last

libpg-test-specs.o: test-specs.c libpg.h
	$(CC) -c $(CFLAGS) -o $@ $<

.PHONY: specs
specs:
	if test -d spec; then git -C spec pull; else git clone https://github.com/libpg/spec.git; fi

#cleaning
.PHONY: clean
clean:
	rm -f libpg*.so* *.c *.o *.pc
	rm -f *-test-specs test-specs-*.last
	rm -rf *.gcno *.gcda coverage.info gcov-latest
	@$(MAKE) -C test1 clean
	@$(MAKE) -C test2 clean
	@$(MAKE) -C test3 clean
	@$(MAKE) -C test4 clean
	@$(MAKE) -C test5 clean
	@$(MAKE) -C test6 clean

# manpage
.PHONY: manuals
manuals: libpg.1.gz

libpg.1.gz: libpg.1.scd
	if which scdoc >/dev/null 2>&1; then scdoc < libpg.1.scd | gzip > libpg.1.gz; fi

