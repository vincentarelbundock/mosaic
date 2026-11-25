// Issue #10: in handout mode a slide that reveals in steps is drawn from its
// last step, and that step must carry the real heading, styled by the theme.
// 0.0.1 kept the real heading on step 1, so a handout drew a stand-in in body
// text. The runner checks that the heading of the revealing slide is as tall
// as the heading of a slide without steps.
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(handout: true)

== Revealhead
#m.steps.reveal[
  - First item
  - Second item
]

== Plainhead
- Only item
