#import "@local/mosaic:0.0.3" as m

#show: m.setup

// `binom` takes its lower terms as an array, which the walk does not rebuild.
#m.slide[][
  $ binom(n, #m.steps.on(2)[$k$]) $
]
