// A list timed with `pause`, `on`, or `reveal` sits exactly where the same
// list sits untimed. The first slide is written plainly; the second is its
// timed twin. scripts/run-tests.py compiles this under every theme
// (`--input theme=..`) and compares word bounding boxes: the twin's last frame
// must equal the plain slide, and every earlier frame must put each word and
// marker it shows where the last frame has it.
#import "@local/mosaic:0.0.3": themes

#let m = dictionary(themes).at(sys.inputs.at("theme", default: "default"))
#show: m.setup

#m.slide(numbered: false)[][
  Intro paragraph.
  - Alpha
  - Beta wraps onto a second line because this item is long enough to need one
    - Nested
  - Gamma
  + first
  + second
  Tail paragraph.

  === Heading
  - Delta

  - Epsilon

  3. third
  4. fourth
]

#m.slide(numbered: false)[][
  Intro paragraph.
  - Alpha
  #m.steps.pause
  - Beta wraps onto a second line because this item is long enough to need one
    - Nested
  #m.steps.pause
  - Gamma
  + first
  #m.steps.on("2-")[+ second]
  Tail paragraph.

  === Heading
  #m.steps.reveal[
    - Delta

    - Epsilon
  ]

  #m.steps.reveal(start: 2)[
    3. third
    4. fourth
  ]
]

#context assert(counter(page).final().first() == 6)
