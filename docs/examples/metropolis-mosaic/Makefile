.PHONY: all clean

FIRA_FONT_DIR := $(shell dirname $(shell kpsewhich FiraSans-Regular.otf))

all: metropolis-mosaic.pdf

metropolis-mosaic.pdf: main.typ references.bib
	calepin compile main.typ $@ -- --font-path "$(FIRA_FONT_DIR)"

clean:
	rm -f metropolis-mosaic.pdf
