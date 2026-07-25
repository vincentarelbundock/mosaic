.PHONY: all clean

all: cream-green-black-mosaic.pdf

cream-green-black-mosaic.pdf: main.typ assets/*
	typst compile --root ../../.. main.typ $@

clean:
	rm -f cream-green-black-mosaic.pdf
