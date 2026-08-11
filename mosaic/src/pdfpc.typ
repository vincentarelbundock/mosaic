// pdfpc sidecar metadata, derived from the deck's own speaker notes.
//
// pdfpc reads notes from a JSON file named after the PDF (`talk.pdf` ->
// `talk.pdfpc`) sitting beside it. Typst cannot write a second file, so this
// module produces that file's exact contents and hands them out through the two
// channels Typst does have: a PDF attachment, so the deck carries its own notes
// wherever it goes, and `<mosaic-pdfpc>` metadata, so `typst query` can lift the
// payload out without opening the PDF. `scripts/mosaic-pdfpc.py` is the second
// channel wrapped in one command.
//
// Read the caveat honestly: pdfpc does not look inside the PDF for this, and
// pympress does not read the pdfpc format at all. The attachment is transport,
// not installation — the file still has to land next to the PDF under the right
// name. The `split` output is the route that needs no sidecar and no tool
// configuration.
#import "shared.typ": tag, typst-sequence, typst-space

// The pdfpc JSON schema version. pdfpc refuses a file claiming a version newer
// than the one it knows, so this tracks the format Mosaic writes, not the
// newest pdfpc release.
#let pdfpc-format = 2

// A note's text, as a string.
//
// The sidecar is JSON, so a note written as ordinary content — emphasis, a
// list, inline code — has to be flattened before it can leave Typst, and Typst
// exposes no general content-to-string. This walks the tree the way
// `note/analysis.typ` does and keeps whatever carries a textual reading;
// anything with none (an image, a shape) contributes nothing. The reduction is
// lossy by construction, which is the price of the format: a note whose layout
// matters belongs in the `split` output instead.
#let plain-text(value) = {
  if type(value) == str { return value }
  if type(value) in (int, float) { return str(value) }
  if type(value) == array {
    return value.map(plain-text).fold("", (all, part) => all + part)
  }
  if type(value) != content { return "" }
  let func = value.func()
  if func == typst-space { return " " }
  if func == typst-sequence {
    return value.children.map(plain-text).fold("", (all, part) => all + part)
  }
  if func == text or func == raw { return value.text }
  if func == linebreak { return "\n" }
  // pdfpc renders a note as Markdown, where the blank line is what separates
  // two paragraphs, so a paragraph break has to survive as two breaks.
  if func == parbreak { return "\n\n" }
  if func == smartquote { return if value.double { "\"" } else { "'" } }
  // A note is not a document: nothing structural inside one carries meaning
  // pdfpc could show, and a Mosaic record nested in one would flatten to its
  // internal spelling.
  if func == metadata { return "" }
  // A markup list is not a `list` element until layout: it reaches here as a
  // sequence of bare items separated by spaces. So the line break belongs to
  // the item rather than to any enclosing container, and `normalize-text`
  // below takes the spaces back off.
  if func == terms.item {
    return "\n" + plain-text(value.term) + ": " + plain-text(value.description)
  }
  // Written back as Markdown markers rather than as bare lines, because that is
  // what pdfpc renders the note as: a note that was a list in the deck source
  // stays a list on the presenter screen.
  if func == list.item {
    return "\n- " + plain-text(value.body)
  }
  if func == enum.item {
    let number = value.at("number", default: none)
    return "\n" + (if number == none { "1" } else { str(number) }) + ". " + plain-text(value.body)
  }
  let fields = value.fields()
  if "children" in fields {
    return fields.children.map(plain-text).fold("", (all, part) => all + part)
  }
  for name in ("text", "body", "child") {
    if name in fields { return plain-text(fields.at(name)) }
  }
  ""
}

// Line-level whitespace tidying, applied once to a whole flattened note.
//
// Flattening turns markup that only looked like lines into real ones, and the
// spaces that separated the pieces in the source survive on either side of the
// new breaks. Blank lines are kept: they are the paragraph breaks the note
// actually wrote, and pdfpc renders the note as Markdown.
#let normalize-text(text) = (
  text.split("\n").map(line => line.trim()).join("\n").trim()
)

// One pdfpc page entry per physical frame.
//
// `idx` is the zero-based page index, which is the only addressing pdfpc needs
// here: Mosaic emits no PDF page labels, so pdfpc falls straight through to the
// index rather than trying to match a label. `forcedOverlay` marks every frame
// after a logical slide's first as a continuation of it, which is what lets
// pdfpc's next-slide preview skip past the rest of an incremental build to the
// slide that actually follows.
#let pdfpc-pages(records) = {
  let pages = ()
  for record in records {
    let value = record.value
    let note = value
      .notes
      .map(note => normalize-text(plain-text(note)))
      .filter(text => text != "")
      .join("\n\n")
    let continuation = value.frame > 1
    if note == none and not continuation { continue }
    let entry = (idx: record.location().page() - 1)
    if note != none { entry.insert("note", note) }
    if continuation { entry.insert("forcedOverlay", true) }
    pages.push(entry)
  }
  pages
}

#let pdfpc-payload(records) = json.encode(
  ("pdfpcFormat": pdfpc-format, "pages": pdfpc-pages(records)),
  pretty: true,
)

// Emitted once, after the deck, where every frame has been laid out and the
// note records have settled on their pages.
//
// Nothing is emitted for a deck without notes: an attachment announcing an
// empty sidecar would show up in every reader's file listing and tell the
// presenter nothing.
#let emit-pdfpc() = context {
  let records = query(<mosaic-speaker-notes>)
  let pages = pdfpc-pages(records)
  if pages.len() == 0 { return }
  let payload = pdfpc-payload(records)
  // Placed and hidden, like every other Mosaic record: a deck is free to show
  // rule `metadata`, and an unhidden record would print itself onto the page
  // and add a page of its own to the deck.
  place(hide([
    #metadata((mosaic: tag, kind: "pdfpc", payload: payload)) <mosaic-pdfpc>
  ]))
  // The path is absolute so the attachment is named `speaker-notes.pdfpc`
  // whatever the depth of the package file this call lives in: Typst names an
  // attachment by its path relative to the compilation root, and a relative
  // path here would resolve inside Mosaic's own source tree. Nothing is read
  // from disk, because the data is supplied.
  pdf.attach(
    "/speaker-notes.pdfpc",
    bytes(payload),
    mime-type: "application/json",
    description: "pdfpc speaker notes; rename to match the PDF to use it",
  )
}
