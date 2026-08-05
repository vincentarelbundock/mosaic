.PHONY: all clean

SOURCES := $(wildcard *.typ)
# The deck imports the installed @local/mosaic package, so a package edit must
# rebuild it; the repository tree is the dependency proxy for the installed
# copy (make install refreshes the latter from the former).
PACKAGE_SOURCES := $(shell find ../../../../mosaic -type f 2>/dev/null | sort)

FIRA_FONT_DIR := $(shell command -v kpsewhich >/dev/null 2>&1 && \
	fira=$$(kpsewhich FiraSans-Regular.otf 2>/dev/null); \
	[ -n "$$fira" ] && dirname "$$fira")
TYPST_FONT_FLAG := $(if $(FIRA_FONT_DIR),--font-path "$(FIRA_FONT_DIR)")

all: metropolis.pdf

metropolis.pdf: $(SOURCES) references.bib $(PACKAGE_SOURCES)
	calepin compile main.typ $@ -- $(TYPST_FONT_FLAG)

clean:
	rm -f metropolis.pdf
