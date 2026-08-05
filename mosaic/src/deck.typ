// Public read access to the deck metadata declared on setup. Dependencies
// are imported under private aliases so `deck` is this module's only export.
#import "shared.typ" as _shared
#import "deck-state.typ" as _state

/// Reads the deck metadata declared on `setup`, for custom compositions that
/// want the deck's own information without restating it.
///
/// Returns a dictionary with the four deck fields: `title`, `subtitle`,
/// `authors`, and `date`. Each is exactly what `setup` received, except
/// `authors`, which is always an array of resolved author records: every
/// entry carries `name`, `affiliations`, `email`, `orcid`, and
/// `corresponding`, whether the deck wrote a bare name or a full
/// `layouts.author` record.
///
/// The reader is contextual, so call it inside a `context` block (slide
/// bodies, planes, and show rules already are one):
///
/// ```typ
/// #mosaic.slide(
///   background: mosaic.components.image("cover.webp", scrim: black.transparentize(45%)),
/// )[
///   #context {
///     let deck = mosaic.deck()
///     place(top + left, text(size: 2.2em, weight: "bold", deck.title))
///     place(bottom + left, deck.authors.map(author => author.name).join([, ]))
///   }
/// ]
/// ```
///
/// This is the escape hatch for title pages the built-in variants do not
/// draw: declare the information once on `setup`, and a hand-built cover
/// reads it back instead of duplicating it.
///
/// -> dictionary
#let deck() = {
  let record = _state.deck-state.get()
  if record == none or record.settings == none {
    _shared.fail("deck() requires a deck; apply setup before reading its metadata")
  }
  record.settings.deck
}
