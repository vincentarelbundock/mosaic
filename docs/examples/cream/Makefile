.PHONY: all clean

all: cream.pdf

cream.pdf: main.typ assets/*
	typst compile --root ../../.. main.typ $@

clean:
	rm -f cream.pdf
