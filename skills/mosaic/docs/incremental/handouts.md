# Handouts

A deck with pauses and reveals prints badly: every frame becomes a page, and a reader pages through the same slide several times. Set `handout: true` to render only the final frame of each slide:

```typ
#show: m.setup.with(handout: true)
```

The handout keeps the final state of timed backgrounds and foregrounds, so a slide that builds up furniture across its frames prints with all of it in place.

[Speaker notes](../presenting/notes.md) have their own outputs. They are independent of `handout:`, so a deck can print a handout, a speaker script, or both.
