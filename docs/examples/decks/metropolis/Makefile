.PHONY: all clean

SOURCES := $(wildcard *.typ)

FIRA_FONT_DIR := $(shell command -v kpsewhich >/dev/null 2>&1 && \
	fira=$$(kpsewhich FiraSans-Regular.otf 2>/dev/null); \
	[ -n "$$fira" ] && dirname "$$fira")
TYPST_FONT_FLAG := $(if $(FIRA_FONT_DIR),--font-path "$(FIRA_FONT_DIR)")

all: metropolis.pdf

metropolis.pdf: $(SOURCES) references.bib
	calepin compile main.typ $@ -- $(TYPST_FONT_FLAG)

clean:
	rm -f metropolis.pdf
