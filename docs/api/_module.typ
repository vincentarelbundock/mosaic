#import "@preview/tidy:0.4.3"

#let api-signature(fn, style-args: (:)) = {
  let arguments = ()
  for (name, info) in fn.args {
    if style-args.omit-private-parameters and name.starts-with("_") {
      continue
    }
    let argument = name
    if "types" in info {
      argument += ": " + info.types.join(" | ")
    }
    if "default" in info {
      argument += " = " + info.default
    }
    arguments.push(argument)
  }

  let multiline = arguments.len() > 2
  let signature = if multiline {
    fn.name + "(\n  " + arguments.join(",\n  ") + "\n)"
  } else {
    fn.name + "(" + arguments.join(", ") + ")"
  }
  if "return-types" in fn and fn.return-types != none {
    signature += " -> " + fn.return-types.join(" | ")
  }

  raw(signature, lang: "typ", block: true)
  block(above: 1em, below: 0.5em, strong[Parameters])
}

#let api-parameter-block(
  function-name: none,
  name,
  types,
  content,
  style-args,
  show-default: false,
  default: none,
) = {
  let details = ()
  if types.len() > 0 {
    let shown-types = types.map(t => (style-args.style.show-type)(t, style-args: style-args))
    details.push([Type: #shown-types.join([ or ])])
  }
  if show-default {
    details.push([Default: #raw(lang: "typc", default)])
  }
  if content != none and content != [] {
    details.push(content)
  }

  // Bare list items emitted for consecutive parameters merge into one list.
  list.item({
    raw(name, lang: none)
    if details.len() > 0 {
      list(..details)
    }
  })
}

#let api-outline(module-doc, style-args: (:)) = {
  let function-links = module-doc.functions.map(fn => {
    link("#" + fn.name, raw(fn.name + "()", lang: none))
  })
  let variable-links = module-doc.variables.map(variable => {
    link("#" + variable.name, raw(variable.name, lang: none))
  })

  if function-links.len() > 0 {
    list(..function-links)
  }
  if variable-links.len() > 0 {
    strong[Variables]
    list(..variable-links)
  }
}

#let api-style = (
  show-outline: api-outline,
  show-type: tidy.styles.default.show-type,
  show-function: tidy.styles.default.show-function,
  show-parameter-list: api-signature,
  show-parameter-block: api-parameter-block,
  show-reference: tidy.styles.default.show-reference,
  show-example: tidy.styles.default.show-example,
  show-variable: tidy.styles.default.show-variable,
)

#let api-module(page-title, source) = {
  set document(title: page-title)

  let sources = if type(source) == array { source } else { (source,) }
  let source-label = sources.join(", ")

  // Tidy's default hierarchy assumes that its module heading owns the page.
  // Calepin already supplies the page title, so promote public functions and
  // their parameter sections while keeping individual arguments out of the
  // document outline.
  show heading.where(level: 3): it => heading(level: 1, it.body)
  show heading.where(level: 4): it => block(above: 1.25em, strong[Signature])
  show heading.where(level: 5): it => strong(it.body)
  show stack: it => block(it.children.join(linebreak()))

  let module = tidy.parse-module(sources.map(read).join("\n"))
  [
    #metadata((title: page-title)) <website-metadata>
    #title()

    The overview below links to each definition. Function definitions show
    signatures with parameter and return types; variables show their declared
    types. Descriptions and defaults follow.

    #tidy.show-module(
      module,
      style: api-style,
      show-module-name: false,
      show-outline: true,
      sort-functions: none,
      omit-private-definitions: true,
      // Tidy's label-based forward links are not supported by Typst's current
      // HTML exporter. The overview above uses stable URL fragments instead.
      enable-cross-references: false,
    )
  ]
}
