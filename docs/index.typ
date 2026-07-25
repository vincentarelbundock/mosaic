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
          Write naturally with headings, semantic templates, and composable
          layouts. Mosaic handles the slide mechanics while your typography,
          content, and document structure stay native Typst.
        ]
        #html.elem("div", attrs: (class: "mosaic-actions"))[
          #html.elem("a", attrs: (
            class: "mosaic-button",
            href: "getting-started.html",
          ))[Get started]
          #html.elem("a", attrs: (
            class: "mosaic-button mosaic-button--secondary",
            href: "api/setup.html",
          ))[API reference]
        ]
      ]
      #html.elem("img", attrs: (
        class: "mosaic-slide-demo",
        src: "assets/mosaic-slide.svg",
        alt: "Mosaic slide with a slim orange title band above asymmetric blue and green columns",
      ))
    ]
    #html.elem("section", attrs: (class: "mosaic-feature-showcase"))[
      #html.elem("div", attrs: (class: "mosaic-feature-cards"))[
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Beautiful from the first slide]
          #html.elem("p")[
            Professional templates, typography, and color schemes are built in.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Stay focused on your story]
          #html.elem("p")[
            Write structured content naturally while Mosaic handles the slide mechanics.
          ]
        ]
        #html.elem("article", attrs: (class: "mosaic-feature-card"))[
          #html.elem("h2")[Make every step land]
          #html.elem("p")[
            Reveal content progressively while your layout stays stable.
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
          "aria-label": "Animated gallery of Mosaic title slides, image layouts, color schemes, and incremental diagrams",
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

    Write naturally with headings, semantic templates, and composable layouts.
  ],
)
