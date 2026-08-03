// Stable extension surface for engine-consumed theme definitions.
#import "engine.typ": theme-setup as _theme-setup

/// Binds a passive theme definition to Mosaic's setup engine.
///
/// A definition is a dictionary containing a complete six-role `colors`
/// dictionary and optional `name`, `defaults`, `options`, `text`,
/// `normalize-lists`, `layouts`, and `apply` entries. `text` is either a static
/// dictionary of native text arguments or a function receiving the resolved
/// theme options and returning that dictionary. `apply(body, colors:, options:)`
/// contains native theme rules and returns the body. The optional `layouts`
/// value is a complete dictionary containing `content`, `title`, and `section`
/// layouts. Explicit and automatic slides select from the same dictionary.
///
/// Theme-specific option defaults belong in `options`; matching arguments to
/// the returned setup function are consumed before ordinary setup validation.
/// All other named arguments are Mosaic's ordinary setup options.
///
/// -> function
#let setup(theme) = _theme-setup.with(theme: theme)
