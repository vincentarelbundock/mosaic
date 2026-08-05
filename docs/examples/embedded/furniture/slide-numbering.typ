#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  layouts: (content: m.layouts.content(variant: "body")),
  content: (
    foreground: [
      #place(bottom + right, dx: -1.5em, dy: -0.6em)[
        #m.components.progress(variant: "1/1")
      ]
      #place(bottom + left)[
        #m.components.progress(variant: "line", width: 100%, thickness: 3pt)
      ]
    ],
  ),
)
#set text(size: 22pt)
#m.slide[
  == Content-based numbering and progress

  #m.steps.reveal[
    - The logical slide number remains stable across frames.
    - The progress indicator advances between logical slides.
  ]
]
