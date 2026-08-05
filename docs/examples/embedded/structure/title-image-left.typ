#import "@local/mosaic:0.0.1" as m
#import "_title-info.typ": info, river

#show: m.setup.with(..info)

#m.slide(layout: "title", variant: "image", position: "left", image: river)
