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
          Write a deck as an ordinary Typst document. Templates supply
          the design, and grids of cells place the content.
        ]
      ]
      #html.elem("img", attrs: (
        class: "mosaic-slide-demo",
        src: "assets/mosaic-slide.svg",
        alt: "Mosaic slide with a slim orange title band above asymmetric blue and green columns",
      ))
    ]
    #html.elem("nav", attrs: (
      class: "mosaic-actions mosaic-home-links",
      "aria-label": "Explore Mosaic",
    ))[
      #html.elem("a", attrs: (
        class: "mosaic-button mosaic-button--secondary",
        href: "getting-started.html",
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
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Beautiful]
          #html.elem("p")[
            Title, section, image, and table templates with matching
            typography and color schemes.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Flexible]
          #html.elem("p")[
            Every slide is a grid: a tree of cells split horizontally or
            vertically, nested as deeply as needed, styled cell by cell.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Typst-native]
          #html.elem("p")[
            A deck is an ordinary Typst document: headings become slides,
            and math, show rules, and diagrams work unchanged.
          ]
        ]
      ]
      #html.elem("div", attrs: (class: "mosaic-showcase-frame"))[
        #html.elem("video", attrs: (
          class: "mosaic-showcase mosaic-showcase--video",
          autoplay: "autoplay",
          loop: "loop",
          muted: "muted",
          playsinline: "playsinline",
          poster: "assets/tutorials/templates/title-1.svg",
          "aria-label": "Animated gallery of Mosaic title slides, image variants, color schemes, and incremental diagrams",
        ))[
          #html.elem("source", attrs: (
            src: "assets/images/showcase.webm",
            type: "video/webm",
          ))
        ]
        #html.elem("img", attrs: (
          class: "mosaic-showcase mosaic-showcase--poster",
          src: "assets/tutorials/templates/title-1.svg",
          alt: "Example of an academic title slide made with Mosaic",
        ))
      ]
    ]
  ],
  fallback: () => [
    = Beautiful slides with Typst

    Write a deck as an ordinary Typst document. Templates supply the
    design, and grids of cells place the content.
  ],
)
