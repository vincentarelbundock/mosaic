// Validated author records shared by all title layouts.
#import "shared.typ": fail

#let author-keys = (
  "affiliations",
  "corresponding",
  "email",
  "kind",
  "name",
  "orcid",
)
#let affiliation-keys = ("id", "name")

#let reject-record-keys(record, allowed, subject) = {
  let unknown = record.keys().filter(key => key not in allowed)
  if unknown.len() > 0 {
    fail(subject + " does not accept " + repr(unknown.first()))
  }
}

#let valid-name(value) = value != none and (
  type(value) == content
    or (type(value) == str and value != "")
)

#let validate-affiliation(record, subject) = {
  if type(record) != dictionary {
    fail(subject + " must be a dictionary with id and name")
  }
  reject-record-keys(record, affiliation-keys, subject)
  let id = record.at("id", default: none)
  let name = record.at("name", default: none)
  if type(id) != str or id == "" {
    fail(subject + " id must be a non-empty string")
  }
  if not valid-name(name) {
    fail(subject + " name must be content or a non-empty string")
  }
}

#let valid-email(value) = type(value) == str and value.match(
  regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"),
) != none

#let valid-orcid(value) = {
  if type(value) != str or value.match(
    regex("^\\d{4}-\\d{4}-\\d{4}-\\d{3}[\\dX]$"),
  ) == none {
    return false
  }
  let compact = value.replace("-", "")
  let total = 0
  for digit in compact.slice(0, 15) {
    total = (total + int(digit)) * 2
  }
  let result = calc.rem(12 - calc.rem(total, 11), 11)
  let expected = if result == 10 { "X" } else { str(result) }
  compact.last() == expected
}

#let validate-author(value, subject: "author") = {
  if (
    type(value) != dictionary
      or value.keys().sorted() != author-keys
      or value.kind != "mosaic-author"
  ) {
    fail(subject + " must be created with author()")
  }
  if not valid-name(value.name) {
    fail(subject + " name must be content or a non-empty string")
  }
  let affiliations = value.affiliations
  if type(affiliations) != array {
    fail(subject + " affiliations must be an array")
  }
  for (index, affiliation) in affiliations.enumerate() {
    validate-affiliation(affiliation, subject + " affiliation " + str(index + 1))
  }
  let email = value.email
  if email != none and not valid-email(email) {
    fail(subject + " email must be a valid email address")
  }
  let orcid = value.orcid
  if orcid != none and not valid-orcid(orcid) {
    fail(subject + " orcid must be a valid ORCID iD")
  }
  let corresponding = value.corresponding
  if type(corresponding) != bool {
    fail(subject + " corresponding must be a boolean")
  }
  if corresponding and email == none and orcid == none {
    fail(subject + " corresponding requires email or orcid")
  }
  value
}

// Canonical relationship analysis shared by validation and title renderers.
#let analyze-authors(values, subject: "layout \"title\" author") = {
  let known = (:)
  let affiliations = ()
  let authors = ()
  for (author-index, value) in values.enumerate() {
    let author = validate-author(
      value,
      subject: subject + " " + str(author-index + 1),
    )
    let numbers = ()
    for affiliation in author.affiliations {
      let id = affiliation.id
      if id in known {
        let existing = known.at(id)
        if repr(existing.name) != repr(affiliation.name) {
          fail(
            "layout \"title\" affiliation id " + repr(id)
              + " has conflicting names",
          )
        }
        numbers.push(existing.index + 1)
      } else {
        let index = affiliations.len()
        known.insert(id, (index: index, name: affiliation.name))
        affiliations.push(affiliation)
        numbers.push(index + 1)
      }
    }
    authors.push(author + (numbers: numbers,))
  }
  (authors: authors, affiliations: affiliations)
}

/// Creates a validated author for `layouts.title(authors: ...)`.
///
/// `email` and `orcid` are independent optional fields. `affiliations` is an
/// array of `(id: ..., name: ...)` dictionaries. A corresponding author must
/// provide at least one of `email` or `orcid`.
#let author(
  name,
  affiliations: (),
  email: none,
  orcid: none,
  corresponding: false,
) = validate-author((
  kind: "mosaic-author",
  name: name,
  affiliations: affiliations,
  email: email,
  orcid: orcid,
  corresponding: corresponding,
))
