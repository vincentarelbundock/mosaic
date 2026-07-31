.PHONY: all clean

all: photojournalist-mosaic.pdf

photojournalist-mosaic.pdf: main.typ assets/*.png
	typst compile --root ../../.. main.typ $@

clean:
	rm -f photojournalist-mosaic.pdf
