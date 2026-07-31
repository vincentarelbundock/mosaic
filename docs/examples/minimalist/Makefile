.PHONY: all clean

all: minimalist.pdf

minimalist.pdf: main.typ assets/*.png
	typst compile --root ../../.. main.typ $@

clean:
	rm -f minimalist.pdf
