#import "/.calepin/calepin.typ" as calepin

#set document(title: [Mosaic])
#metadata((
  title: "Home",
  layout: "layouts/site-landing.html",
  toc: (enabled: false),
)) <website-metadata>

#calepin.elements.target(
  html: () => [
    #html.elem("section", attrs: (class: "mosaic-hero"))[
      #html.elem("div")[
        #html.elem("h1")[
          Create beautiful
          #html.elem("br")
          slides with
          #html.elem("span", attrs: (
            class: "mosaic-hero__typst-box",
          ))[
            #html.elem("img", attrs: (
              class: "mosaic-hero__typst-logo",
              src: "assets/typst.svg",
              alt: "Typst",
            ))
          ]
        ]
        #html.elem("p")[
          Write your talk as an ordinary Typst document and Mosaic makes beautiful slides for you. Style the slides with standard Typst, as you would any other document. Batteries included: modern themes, ready-made layouts, complex grids with nested rows and columns, incremental reveals, speaker notes, handouts, callouts, cards, quotes, progress indicators, etc.
        ]
      ]
      #html.elem("div", attrs: (class: "mosaic-showcase-frame"))[
        #html.elem("video", attrs: (
          class: "mosaic-showcase mosaic-showcase--video",
          width: "1280",
          height: "720",
          autoplay: "autoplay",
          loop: "loop",
          muted: "muted",
          playsinline: "playsinline",
          controls: "controls",
          preload: "metadata",
          poster: "assets/images/showcase-poster.webp",
          "aria-label": "Slides made with Mosaic: a plain starter deck, three themed decks including a technical talk with a bulleted list, a two-column comparison, and an equation and a diagram built step by step, a nested grid diagram, and title and section variants",
        ))[
          #html.elem("source", attrs: (
            src: "assets/images/showcase.mp4",
            type: "video/mp4",
          ))
          #html.elem("source", attrs: (
            src: "assets/images/showcase.webm",
            type: "video/webm",
          ))
        ]
        #html.elem("img", attrs: (
          class: "mosaic-showcase mosaic-showcase--poster",
          width: "1280",
          height: "720",
          src: "assets/images/showcase-poster.webp",
          alt: "Title slide of a first Mosaic deck",
        ))
      ]
    ]
    #html.elem("nav", attrs: (
      class: "mosaic-actions mosaic-home-links",
      "aria-label": "Explore Mosaic",
    ))[
      #html.elem("a", attrs: (
        class: "mosaic-button mosaic-button--secondary",
        href: "start/first-deck.html",
      ))[Get started]
      #html.elem("a", attrs: (
        class: "mosaic-button mosaic-button--secondary",
        href: "examples.html",
      ))[Examples]
      #html.elem("a", attrs: (
        class: "mosaic-button mosaic-button--secondary",
        href: "api/setup.html",
      ))[API]
    ]
    #html.elem("section", attrs: (class: "mosaic-feature-showcase"))[
      #html.elem("div", attrs: (class: "mosaic-feature-cards"))[
        #html.elem("article", attrs: (
          class: "mosaic-feature-card mosaic-feature-card--mark",
        ))[
          #html.elem("img", attrs: (
            class: "mosaic-slide-demo",
            src: "assets/mosaic-slide.svg",
            alt: "Mosaic slide with a slim orange title band above asymmetric blue and green columns",
          ))
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Layouts and themes]
          #html.elem("p")[
            Ready-made content, title, section, and image layouts, each with
            several variants. Beautiful, modern, and easy-to-customize themes.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Grids]
          #html.elem("p")[
            Every slide is a grid: cells split horizontally or vertically,
            nested as deeply as needed.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Plain Typst]
          #html.elem("p")[
            Cells, background, and foreground are native Typst layers, and
            every cell has a stable label. Style them with ordinary show and
            set rules, not a separate API.
          ]
        ]
      ]
    ]
  ],
  fallback: () => [
    = Slides with Typst

    Write your talk as an ordinary Typst document and Mosaic makes beautiful slides for you. Style the slides with standard Typst, as you would any other document. Batteries included: modern themes, ready-made layouts, complex grids with nested rows and columns, incremental reveals, speaker notes, handouts, callouts, cards, quotes, progress indicators, etc.
  ],
)
