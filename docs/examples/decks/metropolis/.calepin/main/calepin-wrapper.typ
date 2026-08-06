#let _calepin-document-element = document
#import "/.calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "a15f30f370799017-1349cde127705c16"
#let _calepin-verify-generation() = {
  let path = sys.inputs.at("calepin-results", default: none)
  if path != none and path != "" {
    let actual = json(path).at("generation", default: "")
    if actual != _calepin-expected-generation {
      panic("Calepin results changed while this render was starting; Typst will retry with the completed build")
    }
  }
}
#_calepin-verify-generation()



#let _raw-chunk-langs = ("python", "r", "mermaid", "dot", "tikz", "d2")
#show raw.where(block: true, lang: "typ", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "typst", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "python", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("python", it) }
#show raw.where(block: true, lang: "r", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("r", it) }
#show raw.where(block: true, lang: "mermaid", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("mermaid", it) }
#show raw.where(block: true, lang: "dot", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("dot", it) }
#show raw.where(block: true, lang: "tikz", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("tikz", it) }
#show raw.where(block: true, lang: "d2", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("d2", it) }

#show raw.where(block: true, theme: auto): it => {
  if _is-query() {
    it
  } else if _disable-raw-chunk-transforms.get() {
    _html-themed-raw-block(it)
  } else if it.has("lang") and it.lang != none and _raw-chunk-langs.contains(it.lang) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#show heading: it => {
  if _is-html() and "label" in it.fields() {
    std.html.elem("calepin-heading-anchor", attrs: (data-id: str(it.label)))
  }
  it
}

// Notebook theme
#import "/.calepin/calepin.typ": _html-themed-raw-block, _is-query, chunk_from_raw_plain

// Body text size, captured below at document-body level. Code blocks are sized
// relative to this rather than to `1em`, which would compound: a literal
// ```typ block is rendered by replacing its source `raw` element, so it renders
// inside Typst's already-reduced raw text context, whereas executed chunks are
// emitted as ordinary calls at body size. Anchoring to the captured body size
// gives both paths a single, matching reduction instead of shrinking twice.
#let _calepin-body-size = std.state("calepin-body-size", 11pt)

#show raw.where(block: true): it => {
  if it.theme != auto {
    context {
      set text(size: _calepin-body-size.get() * 0.8)
      it
    }
  } else if it.lang != none and (_is-query() or _raw-chunk-langs.contains(it.lang)) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#context _calepin-body-size.update(text.size)

#import "/.calepin/calepin.typ" as calepin
#import "/.calepin/calepin.typ" as calepin_runtime
// ═══════════════════════════════════════════════════════════════════════════
//  Content
//
//  This deck is deliberately bare: it imports the bundled Metropolis theme
//  and writes almost every slide as a `=` or `==` heading. The theme supplies
//  the ruled title page, the section progress bars, the bottom progress line,
//  and all typography. preamble.typ adds Fletcher, CeTZ, Calepin, and the
//  equation-annotation helpers used below.
// ═══════════════════════════════════════════════════════════════════════════
// Root-absolute import: Calepin compiles main.typ from a generated wrapper
// directory, so a relative "preamble.typ" would not resolve. The Calepin root
// is this example directory (cf. the "/references.bib" bibliography below).
#import "/preamble.typ": *

#let ccp = [Centre for Comparative Politics]
#let eis = [European Institute for Social Data]

#show: m.setup.with(
  title: [Technical talk],
  subtitle: [Math, Diagrams, and Executable Code],
  authors: (
    m.layouts.author(
      [Priya Nair],
      affiliations: (ccp, eis),
      email: "priya.nair@example.org",
      orcid: "0000-0001-2345-6789",
      corresponding: true,
    ),
    m.layouts.author([Elena García], affiliations: (eis,)),
    m.layouts.author([Noah Williams], affiliations: (ccp,)),
  ),
  date: [July 30, 2026],
)

#m.slide(layout: "title")

== Roadmap

// `calepin.setup` runs once, inside the first slide's content, to enable the
// R chunks used later in the deck. (Emitted before the first slide it would
// count as stray content ahead of the deck's first heading.)
#calepin.setup(echo: true, eval: true, results: "render")

#set enum(numbering: "1.", spacing: 1.15em)
#enum(
  [Formalize the decision problem],
  [Expose the computation],
  [Explain system structure],
  [Connect results to evidence],
)

= Model

== Sequential decisions under uncertainty

We consider an agent that repeatedly observes a state, chooses an action,
and receives a reward.
#v(18pt)
- *State:* $s in cal(S)$ summarizes the information available now.
- *Action:* $a in cal(A)$ changes both reward and the next-state distribution.
- *Objective:* maximize expected discounted return over an indefinite horizon.
#v(18pt)
#m.components.callout(title: [Modeling assumption])[
  The current state is sufficient: conditional on $s_t$ and $a_t$, the
  future is independent of the earlier history.
]

// `m.steps.replace` swaps the same slot's content across reveals: each argument is
// the version shown on successive steps. Here we annotate one term of the
// equation at a time (reward, then discount, then future value) without
// re-flowing the rest of the formula.
== Bellman optimality equation

#show math.equation.where(block: true): set text(size: 1.35em)
$
  V^star(s) = max_a
      #m.steps.replace(
        align: top + center,
        [$R(s, a)$],
        [#explained(red, $R(s, a)$, [immediate reward])],
        [#explained(red, $R(s, a)$, [immediate reward])],
        [#explained(red, $R(s, a)$, [immediate reward])],
      )
      + #m.steps.replace(
        align: top + center,
        [$gamma$],
        [$gamma$],
        [#explained(blue, $gamma$, [discount factor])],
        [#explained(blue, $gamma$, [discount factor])],
      )
      #m.steps.replace(
        align: top + center,
        [$sum_(s') P(s' | s, a) V^star(s')$],
        [$sum_(s') P(s' | s, a) V^star(s')$],
        [$sum_(s') P(s' | s, a) V^star(s')$],
        [#explained(
          green,
          $sum_(s') P(s' | s, a) V^star(s')$,
          [optimal future value],
        )],
      )
$
#v(31pt)
The recursion separates immediate utility from the expected value of all
subsequent decisions #cite(<bellman1957>).

= Computation

// `calepin.chunk` runs R at compile time. The first chunk evaluates the code
// and saves the plot under label "fig-efficiency" (retrieved on the next
// slide with `calepin.results`); the second is eval:false, shown only as code.
== An executable analysis

The source below is executed during compilation. Its figure is cached by
Calepin and placed on the following slide.

#v(10pt)

#calepin_runtime.chunk_from_raw_plain("r", raw("#| label: \"fig-efficiency\"\n#| echo: true\n#| eval: true\n#| message: false\n#| results: \"hide\"\n#| fig-width: 92%\n#| fig-device-width: 6.5\n#| fig-device-height: 4.2\n#| fig-alt-text: \"Fuel efficiency versus horsepower by transmission type\"\nlibrary(ggplot2)\nfit <- lm(mpg ~ hp + factor(am), data = mtcars)\n\nggplot(mtcars, aes(hp, mpg, color = factor(am))) +\n  geom_point(size = 2.6, alpha = 0.85) +\n  geom_smooth(method = \"lm\", se = FALSE, linewidth = 0.9) +\n  scale_color_manual(\n    values = c(\"0\" = \"#657377\", \"1\" = \"#f28e2b\"),\n    labels = c(\"Automatic\", \"Manual\")) +\n  labs(x = \"Horsepower\", y = \"Fuel efficiency (mpg)\", color = \"Transmission\") +\n  theme_minimal(base_family = \"Fira Sans\", base_size = 13) +\n  theme(legend.position = \"top\", panel.grid.minor = element_blank())\n", block: true, lang: "r"))

// A two-column content slide: the theme's own layout, an uneven split.
#m.slide(variant: "header-body", columns: 2, tracks: (1.65fr, 1fr))[
  == Horsepower predicts lower efficiency
][
  #calepin.results("fig-efficiency")
][
  #set text(size: 0.79em)
  - Fuel efficiency declines as horsepower increases.
  - Transmission groups occupy different regions of the sample.
  - The fitted lines summarize association, not causation.
  #v(14pt)
  #text(size: 0.75em, style: "italic")[
    Data: `mtcars`, 32 model-year 1973 to 1974 automobiles.
  ]
]

== Computed model summary

The same R session retains `fit`, so numerical claims can be generated rather
than copied into the deck.
#v(18pt)
#m.components.card[
  #calepin.chunk("r", echo: false, results: "typst")[
      ```r
      b <- coef(summary(fit))
      r2 <- summary(fit)$r.squared
      cat(sprintf(
        "#strong[Estimated association] \
        Holding transmission fixed, an additional 10 horsepower is associated
        with *%.2f fewer mpg*. The model explains *%.1f%%* of the observed
        variation in fuel efficiency.",
        -10 * b["hp", "Estimate"], 100 * r2
      ))
      ```
  ]
]

= Structure

== File-reader state machine

// The scoped `set align` centers the diagram without leaking to later
// slides. A content block stays transparent to Mosaic's step discovery, so
// `m.slide` still sees the reveal steps inside `state-diagram`.
#[
#set align(center)
#state-diagram(
    node-stroke: 0.1em,
    node-fill: rgb("#f28e2b").lighten(75%),
    spacing: 4em,
    fletcher.edge((-1, 0), "r", "-|>", `open(path)`,
      label-pos: 0, label-side: center),
    fletcher.node((0, 0), `reading`, radius: 2em),
    m.steps.on("2-", (
      fletcher.edge(`read()`, "-|>"),
      fletcher.node((1, 0), `eof`, radius: 2em),
      fletcher.edge((0, 0), (0, 0), `read()`, "--|>", bend: 130deg),
    )),
    m.steps.on("3-", (
      fletcher.edge(`close()`, "-|>"),
      fletcher.node((2, 0), `closed`, radius: 2em, extrude: (-2.5, 0)),
      fletcher.edge((0, 0), (2, 0), `close()`, "-|>", bend: -40deg),
    )),
)
]

= Geometry

== A qubit as a Bloch vector

#[
#set align(center)
#canvas(length: 2.15cm, {
    import cetz.draw: circle, content, line
    let rad = 2.5
    let vec-a = (rad / 3, rad / 2)
    let phi-point = (rad / 3, -rad / 5)
    let mark = (end: "stealth", fill: ink)

    circle((0, 0), radius: rad)
    circle((0, 0), radius: (rad, rad / 3),
      stroke: (dash: "dashed"), fill: gray.transparentize(70%))

    (
      m.steps.on("2-", (
        line((0, 0), (-rad / 5 * 1.2, -rad / 3 * 1.2),
          mark: mark, name: "x1"),
        content("x1.end", [$x_1$], anchor: "north"),
        line((0, 0), (1.15 * rad, 0), mark: mark, name: "x2"),
        content("x2.end", [$x_2$], anchor: "west"),
        line((0, 0), (0, 1.15 * rad), mark: mark, name: "x3"),
        content("x3.end", [$x_3$], anchor: "south"),
      )),
    )

    (
      m.steps.on("3-", (
        line((0, 0), vec-a,
          mark: (start: "circle", end: "circle", fill: ink,
            scale: 0.5, anchor: "center")),
        content((rel: (0.08, 0.08), to: vec-a), $arrow(a)$,
          anchor: "south-west"),
        line((0, 0), phi-point, style: "dashed"),
        line(phi-point, vec-a, style: "dashed"),
      )),
    )

    (
      m.steps.on("4-", (
        cetz.angle.angle((0, 0), (-1, -calc.tan(60deg)),
          (1, -calc.tan(30deg)), label: [$phi$],
          stroke: (paint: gray, thickness: 0.5pt),
          mark: (end: "stealth", fill: gray, scale: 0.7)),
        cetz.angle.angle((0, 0), (1, calc.tan(60deg)),
          (1, calc.tan(90deg)), label: [$theta$],
          stroke: (paint: gray, thickness: 0.5pt),
          mark: (start: "stealth", fill: gray, scale: 0.7),
          label-radius: 0.75),
      )),
    )
})
]

= Evidence

#m.slide(variant: "header-body", columns: 2)[
  == What makes a technical slide?
][
  *Include*
  - a question or claim
  - units and definitions
  - reproducible computation
  - a stated interpretation
][
  *Avoid*
  - unlabelled decorative plots
  - numbers copied by hand
  - animation without exposition
  - citations disconnected from claims
]

// One-off closing slide: the theme's inverted ground, one large phrase.
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide(invert: true, cells: (
    body: text(size: 1.6em, weight: "medium")[Questions?],
  ))
]

// A real `==` heading in the header block keeps the same heading show rules
// (and therefore the same size) as the automatic slide headers.
#m.slide(
  "content",
  numbered: false,
  cells: (
    header: [== References],
    body: [
      #set text(size: 0.63em)
      #bibliography("/references.bib", title: none, style: "ieee")
    ],
  ),
)
