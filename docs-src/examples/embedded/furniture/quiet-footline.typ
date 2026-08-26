#import "@local/mosaic:0.0.2" as m

#show: m.setup.with(
  title: [Quarterly review],
  subtitle: [A footline that skips covers and dividers],
  foreground: align(bottom + right, block(
    inset: (right: 1.2em, bottom: 0.9em),
    text(size: 0.65em, m.components.progress()),
  )),
)
#set text(size: 22pt)

#m.slide(layout: "title")

= Findings

== Revenue

The counter reads 1/2 in the corner.

== Costs

Now 2/2. The title and section pages carried no counter at all.
