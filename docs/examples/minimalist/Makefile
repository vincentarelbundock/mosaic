.PHONY: all clean

all: minimalist-white-mosaic.pdf

minimalist-white-mosaic.pdf: main.typ assets/*.png
	typst compile --root ../../.. main.typ $@

clean:
	rm -f minimalist-white-mosaic.pdf
