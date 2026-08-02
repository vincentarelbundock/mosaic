.PHONY: all clean

SOURCES := $(wildcard *.typ)
DECK_DEPS ?=

all: $(DECK).pdf

$(DECK).pdf: $(SOURCES) $(DECK_DEPS)
	typst compile --root ../../.. main.typ $@

clean:
	rm -f $(DECK).pdf
