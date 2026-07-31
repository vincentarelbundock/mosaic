.PHONY: all clean

all: portfolio.pdf

portfolio.pdf: main.typ assets/*.png
	typst compile --root ../../.. main.typ $@

clean:
	rm -f portfolio.pdf
