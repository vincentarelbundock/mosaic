#import "../mosaic/src/author.typ": plain-name

// Names flatten to the string the PDF author field takes, including the
// punctuation that markup turns into elements of its own.
#assert(plain-name("Ada Lovelace") == "Ada Lovelace")
#assert(plain-name[Ada Lovelace] == "Ada Lovelace")
#assert(plain-name[Conan O'Brien] == "Conan O'Brien")
#assert(plain-name[Dwayne "The Rock" Johnson] == "Dwayne \"The Rock\" Johnson")
#assert(plain-name[Ada~Lovelace] == "Ada Lovelace")
#assert(plain-name[A -- B] == "A – B")
#assert(plain-name[Ada\ Lovelace] == "Ada Lovelace")
#assert(plain-name[José *Bold* Núñez] == "José Bold Núñez")
#assert(plain-name[Jean-Luc Picard] == "Jean-Luc Picard")
// No plain reading: the caller suppresses the author field.
#assert(plain-name[Ada #box(width: 1em)] == none)

// End to end: one apostrophe used to suppress the whole author field.
#import "@local/mosaic:0.0.3" as mosaic
#show: mosaic.setup.with(
  title: [Plain names],
  authors: ([Conan O'Brien], [Ada~Lovelace]),
)

== Slide
