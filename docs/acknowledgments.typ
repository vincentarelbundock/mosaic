#import "/.calepin/calepin.typ" as calepin

#set document(title: [Acknowledgments])
#metadata((
  title: "Acknowledgments",
  description: "Projects, authors, and discussions that informed Mosaic.",
)) <website-metadata>

= Acknowledgments

Mosaic is small because it builds on ideas, tools, and design work shared by the Typst community. This page records the sources that directly informed Mosaic's implementation. Full copyright and license notices remain in
#link("https://github.com/vincentarelbundock/mosaic/blob/main/THIRD_PARTY_LICENSES.md")[`THIRD_PARTY_LICENSES.md`].

== Counter and state freezing

Mosaic's selected counter and state freezing was informed by
#link("https://github.com/touying-typ/touying")[Touying] 0.7.4, particularly its
`_rewind-states` helper and subslide preamble at
#link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/core.typ#L5602-L5609")[commit `a8abe0d`].
Credit goes to the Touying project and its contributors for demonstrating the practical pre-slide snapshot and continuation-frame rewind technique.

Mosaic narrows that technique to explicitly selected objects and uses a lexical pre-slide location suited to its own renderer. That avoids freezing unrelated Typst or Mosaic state and keeps repeated logical slides convergence-safe.

The underlying problem and Typst's introspection model are further explained in Laurenz Mädje's article
#link("https://laurmaedje.github.io/posts/frozen-state/")[*Frozen State*].
The community discussion in
#link("https://github.com/typst/typst/issues/1841")[Typst issue #1841] also
helped establish why presentation subframes need deliberate counter and state semantics.

== Fitting utilities

Parts of Mosaic's explicit cell-fitting implementation are adapted from Touying 0.7.4 at the same pinned commit. Touying credits related work to Andreas Kröpelin through
#link("https://github.com/andreasKroepelin/polylux/pull/91")[Polylux PR #91]
and to ntjess. Mosaic preserves these credits in its source and third-party license notices.

== Tutorial colors

The explicit color arrays in several tutorials use the Okabe-Ito Color Universal Design palette. Source attribution is recorded in the full third-party notices.

== Example decks

The example presentations on the #link("examples.html")[Examples] page are each adapted from a freely licensed source. The *Editorial*, *Manifesto*, and *Photojournalist Portfolio* decks are Mosaic/Typst re-creations of designs published by
#link("https://www.slidescarnival.com/")[SlidesCarnival], with photographs
credited on the source templates to Pexels and Pixabay.

SlidesCarnival templates are distributed under the
#link("https://creativecommons.org/licenses/by/4.0/")[Creative Commons
Attribution 4.0 International (CC BY 4.0)] license. The decks have been adapted, and attribution is preserved here and in the full third-party license notices.

The *Metropolis* deck adapts the demonstration slides of the
#link("https://github.com/matze/mtheme")[Metropolis Beamer theme] by Matthias
Vogelgesang, distributed under the
#link("https://creativecommons.org/licenses/by-sa/4.0/")[Creative Commons
Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)] license. The adaptation is offered under the same license.

== Toolchain

Mosaic is built with #link("https://typst.app/")[Typst]. Its documentation site is generated with #link("https://github.com/vincentarelbundock/calepin")[Calepin]. We are grateful to both projects and their contributors.
