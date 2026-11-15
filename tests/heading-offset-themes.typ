#import "@local/mosaic:0.0.3" as mosaic

// Under `set heading(offset: 1)` a `==` heading still opens a slide, because
// the compiler classifies by source depth, but it resolves to native level 3.
// Every theme selects its slide heading by depth, so the heading keeps the
// theme's slide-heading size instead of falling back to body size. Compiled
// once per theme by the runner (`--input theme=..`), at `--input offset=0`
// and `offset=1`: the runner queries the probes and requires the section and
// slide heading sizes to be the same at both, since a theme states them as
// multiples of the base size rather than in em, which would multiply with
// the native per-level heading scale.
#let theme-name = sys.inputs.at("theme", default: "default")
#let offset = int(sys.inputs.at("offset", default: "1"))
#let theme = dictionary(mosaic.themes).at(theme-name)
#set heading(offset: offset)
#show: theme.setup.with(foreground: none)

#let probe(name) = context [#metadata(text.size) #label(name)]

= Offset section

#mosaic.slide[][
  = In-body section heading #probe("section-size")
]

== Offset slide #probe("slide-size")

#probe("body-size")

=== Deeper heading #probe("deeper-size")

#context {
  let size(name) = query(label(name)).first().value
  assert(
    query(heading).map(it => it.level)
      == (1, 1, 2, 3).map(depth => depth + offset),
  )
  assert(counter(page).final().first() == 3)
  // Native level 3 and below add no scale of their own, so anything above
  // body size is the theme's depth-2 rule.
  assert(
    size("slide-size") > 1.1 * size("body-size"),
    message: theme-name + " " + repr((size("slide-size"), size("body-size"))),
  )
  // The rule is for the heading that opens the slide, not for deeper ones.
  assert(size("deeper-size") < size("slide-size"))
}
