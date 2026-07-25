// Validated author records shared by all title templates.
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
  if type(value) != dictionary or value.at("kind", default: none) != "mosaic-author" {
    fail(subject + " must be created with author()")
  }
  reject-record-keys(value, author-keys, subject)
  if not valid-name(value.at("name", default: none)) {
    fail(subject + " name must be content or a non-empty string")
  }
  let affiliations = value.at("affiliations", default: ())
  if type(affiliations) != array {
    fail(subject + " affiliations must be an array")
  }
  for (index, affiliation) in affiliations.enumerate() {
    validate-affiliation(affiliation, subject + " affiliation " + str(index + 1))
  }
  let email = value.at("email", default: none)
  if email != none and not valid-email(email) {
    fail(subject + " email must be a valid email address")
  }
  let orcid = value.at("orcid", default: none)
  if orcid != none and not valid-orcid(orcid) {
    fail(subject + " orcid must be a valid ORCID iD")
  }
  let corresponding = value.at("corresponding", default: false)
  if type(corresponding) != bool {
    fail(subject + " corresponding must be a boolean")
  }
  if corresponding and email == none and orcid == none {
    fail(subject + " corresponding requires email or orcid")
  }
  value
}

/// Creates a validated author for `templates.title(authors: ...)`.
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
