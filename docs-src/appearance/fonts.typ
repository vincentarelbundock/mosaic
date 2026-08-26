#import "/.calepin/calepin.typ" as calepin

#set document(title: [Fonts])
#metadata((title: "Fonts")) <website-metadata>

#title()

Every built-in theme names its typeface as a list of families rather than a single one, and that list is why a first compile usually prints a few warnings. This page explains where they come from, why they are harmless, and how to choose your own type instead.

= Typst ships no sans font

Typst embeds a small set of fonts so that a document compiles on a machine with nothing installed. Ask for the list and the omission is plain:

```sh
typst fonts --ignore-system-fonts
```

```sh
DejaVu Sans Mono
Libertinus Serif
New Computer Modern
New Computer Modern Math
```

One monospace, two serifs, and a math face. There is no sans among them. A theme whose voice is a sans, which is most of them, therefore cannot name a single family and be sure it exists: whatever it asks for has to be installed on the machine doing the compile.

So each theme names a list instead, in order of preference. The designed face comes first, then the families that a stock Linux, macOS, or Windows machine actually carries, and last a family Typst embeds, which always resolves. Typst walks the list and uses the first family it finds. The result is that the deck renders as designed wherever the designed face is installed, renders in a close cousin where it is not, and never fails to render at all.

= The warnings

Typst reports every family in the list that it cannot find, even when a later family in the same list resolves and the text sets perfectly. Because the lists deliberately name faces belonging to several platforms, no one machine has all of them, and most people see something like this on every compile:

```sh
warning: unknown font family: inter
   ┌─ @preview/mosaic:0.0.1/src/themes/default/definition.typ:21:10
   │
21 │     font: options.font,
   │           ^^^^^^^^^^^^

warning: unknown font family: source sans 3
   ┌─ @preview/mosaic:0.0.1/src/themes/default/definition.typ:21:10
   │
21 │     font: options.font,
   │           ^^^^^^^^^^^^
```

These warnings can be safely ignored. They are not errors, they do not stop the compile, and they say nothing about the slide that is being typeset.

Two things do make them go away: 

1. Installing the family the theme asks for first is one, and gives you the deck exactly as designed. 
2. Naming your own type.

= Choosing your own fonts

`setup` takes the typeface as an option, so one line replaces the theme's list with your own choice:

```typ
#import "@preview/mosaic:0.0.1" as m

#show: m.setup.with(font: "EB Garamond")
```

The value is whatever Typst's own `text` function accepts, so a list works here too, and is worth using for a deck that will be compiled on more than one machine:

```typ
#show: m.setup.with(font: ("EB Garamond", "Libertinus Serif"))
```

One theme sets a second face. `editorial` is the magazine voice, serif display type over a sans body, so it takes its display face as an option of its own:

```typ
#import "@preview/mosaic:0.0.1" as m
#import m.themes.editorial: setup

#show: setup.with(
  font: "Inter",
  font-display: "EB Garamond",
)
```

Naming families that are all present on the machine doing the compile silences the warnings entirely, because nothing on the list is then unknown.

Code is the one thing no option covers, and needs none: Typst pins `raw` to a monospace font it embeds, and a deck-wide font never reaches it. A deck with a favorite monospace writes one ordinary rule, under any theme:

```typ
#show raw: set text(font: "JetBrains Mono")
```

Type that belongs to one slide rather than the whole deck is an ordinary Typst rule after `setup`, and is covered under #link("styling.html")[Styling].
