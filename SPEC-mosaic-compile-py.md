# SPEC: `mosaic-compile`

Status: design, no code written. Drafted 2026-08-11, alongside the removal of the pdfpc sidecar.

## Why

Typst's whole PDF-object surface for a package is `pdf.attach`, `pdf.embed`, and `link()` with a URI action. Arbitrary annotations and page labels are an open feature request upstream. Everything a presenter console wants beyond page images — notes, overlay grouping, video, media rectangles — lives in exactly those objects Typst cannot emit. So the emit step has to be post-processing, and this is the tool that does it.

Mosaic used to solve the notes half of this with a pdfpc JSON sidecar. That was removed on 2026-08-11 because it served one application, needed a companion file beside the PDF, and flattened notes to plain text. The replacement is a channel every console already reads. See *Notes* below.

## The tool

**Name:** `mosaic-compile`. It compiles the deck and then stamps it, so the author types one command instead of two, and it mirrors the command they already know (`typst compile talk.typ` -> `mosaic-compile talk.typ`).

The name was chosen against three rejected alternatives, and the reasoning is worth keeping: `mosaic-pdfpc.py` was named after a consumer and died with it; `mosaic-video.py` would name the tool after one of its four stamps; `mosaic-typst.py` names the one thing the tool is not, since it exists precisely to do what Typst cannot; `mosaic-build.py` collides with `make build`, which in this repo means doctor + install + check + website.

Because "compile" hides the stamping — the part that can silently not happen — the tool reports what it did on success: `talk.pdf: 12 slides, 8 notes, 1 video`.

**CLI:**

```bash
mosaic-compile talk.typ                 # -> talk.pdf, stamped
mosaic-compile talk.typ -o out/deck.pdf
mosaic-compile talk.typ --typst /usr/bin/typst
```

The PDF path is inferred from the source, so the common case is one argument. `--typst` shells out to a system binary instead of the bundled wheel, which is the escape hatch for an author on a newer toolchain than the pinned `typst` package. This doubles the compile/query code path — Python API calls on one side, `typst compile` and `typst query --format json` subprocesses on the other — and the two must stay behaviorally identical; keep them behind one internal interface from the first commit.

## Distribution

`uv` is the primary path, and the story is zero-install:

```bash
uvx mosaic-compile talk.typ            # nothing installed, not even typst
uv tool install mosaic-compile         # for people who present often
```

- **Dist name = command name = `mosaic-compile`.** Both are free on PyPI (verified 2026-08-11). They must match, or `uvx` users need `--from`, which nobody remembers.
- **Dependencies:** `pikepdf` and `typst>=0.15,<0.16`. The upper bound matters: an unbounded pin would let a future typst-py silently move `uvx` users onto a newer Typst than the deck's package supports — the `mosaic: tag` check catches package drift, not toolchain drift. `--typst` is the deliberate upgrade path. The latter is messense's typst-py, 0.15.0 on PyPI, matching the Typst version Mosaic requires; it exposes `compile()`, `query()`, `eval()`, and `sys_inputs`, which is the entire surface this needs. No system libraries, no separate Typst install.
- **Repo layout:** `tools/mosaic-compile/`, with its own `pyproject.toml` and `src/mosaic_compile/`. It must not live under `mosaic/`, which `make install` copies into the Typst package index and `make release-stage` stages for Universe — a stray `pyproject.toml` in there would ship. `scripts/` stays what it is: unpublished repo tooling. The repo's own use is `uv run --project tools/mosaic-compile mosaic-compile ...`.
- **Stepping stone:** a PEP 723 single file with inline `# /// script` dependencies, run as `uv run scripts/mosaic-compile.py talk.typ`. No packaging at all, and it converts to the `tools/` layout later without touching the code. Take this route if video is wanted before a PyPI release.
- **Versioning:** its own line, independent of both the development (0.0.2) and released (0.0.1) Typst package versions. It is a separate artifact on a separate registry with its own cadence; coupling would force lockstep releases. Compatibility is checked in the data instead: every Mosaic metadata record carries a `mosaic: tag` field, so the tool fails with a clear message when a deck was built by a package version it does not understand.

## What it stamps

In priority order. Each stamp reads hidden, labelled metadata records the package places, lifted with `typst query`. Labels stay feature-scoped (`<mosaic-speaker-notes>`, `<mosaic-video>`) rather than tool-scoped, so the tool queries several labels rather than one catch-all.

### 1. Notes, as PDF text annotations

This is the replacement for the deleted sidecar, and the highest-value stamp. Both consoles read notes from ordinary `/Text` annotations and remove them before rendering:

- pympress `document.py:356` — `TEXT`, `POPUP`, `FREE_TEXT`: `/Contents` is collected into `page.annotations`, then `self.page.remove_annot(...)`. That list is what the presenter pane shows.
- pdfpc `metadata/pdf.vala:897` — "Fill the slide notes from pdf text annotations", covering `TEXT`, `FREE_TEXT`, `HIGHLIGHT`, `UNDERLINE`, `SQUIGGLY`, then `page.remove_annot(a)`. Called at startup as "Prepopulate notes from annotations".

One stamp therefore serves pympress, pdfpc, and BeamerPresenter, inside the PDF, with no companion file, no rename, no format version, and no `--notes` flag.

Three caveats. First, the annotation is removed only *by presenter consoles*; Adobe and Preview would render a sticky-note icon, so this belongs behind a flag or its own build rather than in every `slides` PDF. The `/F` experiment below can fix the rendering, but not the deeper reason to stay opt-in: hidden is not absent. The note text stays in the file, extractable by `pdftotext`, Adobe's comments sidebar, or any PDF editor, and speaker notes routinely contain things an author does not want the audience reading. Stamping notes into a PDF meant for distribution is a privacy decision, so it never defaults on regardless of how the experiment goes. Second, `/Contents` is a plain string, so the same lossy content-to-Markdown flattening the sidecar needed applies; a note whose layout matters still belongs in the `split` output — the double-width `--notes=right` build where each page carries the slide on the left half and its notes on the right, the pdfpc/beamer convention documented in `docs-src/presenting/notes.typ`. Third, one logical slide spans several physical pages once incremental steps are in play, and the annotation has to land somewhere: on the *last* frame of the logical slide, exactly once. pdfpc groups the frames by page label (stamp 2) and shows one note for the group; pympress shows notes per physical page, and the last frame is the one that stays on screen while the presenter talks.

The notes record the package places must carry the physical page number, read inside a `context` block, because `typst query` returns metadata *values* with no location — the tool cannot otherwise know which page to stamp. The current `note/command.typ` record carries no location, so this is a package-side change, not just a tool.

### 2. Page labels

Both consoles give page labels real semantics, and no Typst slide package exploits this:

- pdfpc (`pdf.vala:1128`) groups *consecutive pages sharing a label* into one logical slide. That is `forcedOverlay` obtained for free: give every frame of a logical slide the same label and incremental builds collapse correctly in the next-slide preview.
- pympress (`document.py:927`, `984`) selects `PdfPage.MAP` when any label starts with `notes:`, pairing a page labelled `X` with a following page labelled `notes:X`.

The second enables a third notes output: interleave a notes page after each frame and label it `notes:<label>`, and pympress maps it automatically, with the slide page keeping its normal size — unlike `split`, whose double-width pages are unusable as a handout in Adobe.

### 3. Video

A Screen annotation carrying a Rendition action, with `/Contents` containing the literal word "video". Read from the sources rather than the docs:

- pdfpc (`action/movie.vala`) takes `ActionType.LAUNCH` (the `run:demo.mp4?autostart&loop&noprogress` route, parsing `autostart`/`loop`/`noprogress`/`noaudio`/`start=`/`stop=`/`srtfile=` off the query string), `AnnotType.SCREEN` — guarded by `if (!("video" in annot.get_contents()))` — and `AnnotType.MOVIE`.
- pympress (`document.py:311`) takes `ANNOT_MOVIE` and `ANNOT_SCREEN` whose action is `ACTION_RENDITION`. Its `ACTION_LAUNCH` handler only opens the file externally, so pdfpc's best-documented route is not an inline-playback path in pympress.

Emit the Movie annotation as well as Screen/Rendition: pympress reads real playback parameters off it — `show_controls`, `poster`, `repeat`, `start_pos`, `duration`.

**Reference, do not embed.** pympress resolves a relative filename against the PDF's directory first and then the cwd (`get_full_path`); pdfpc's `run:` route behaves the same. So `demo.mp4` beside `talk.pdf` just works, and the annotation stays a few hundred bytes of `{rect, filename}`. Embedding is a flag for decks that must travel alone, not the default.

Ruled out: `pdf.attach("demo.mp4", ..)` looks like a native shortcut, but pympress's `ANNOT_FILE_ATTACHMENT` path extracts the file and hands it to an external opener. That is a paperclip, not a video on the slide.

The record the package places needs everything the notes record does (a physical page number) plus **geometry**: it is written inside a `context` reading `here().position()` and the measured poster size, in absolute units. Two conversions belong to the tool, not the package: `here().position()` is top-left-origin layout coordinates while PDF `/Rect` is bottom-left-origin points, so the tool needs the page height (pikepdf reads it from the MediaBox); and the same logical slide spans several physical pages under incremental steps, so the tool stamps the annotation on every frame where the poster is visible — a video paused mid-build should be startable from any frame, and both consoles instantiate media per page anyway.

### 4. GIF

Free with the video stamp. pympress has a dedicated `GifOverlay` backend (`media_overlays/gif_backend.py`) selected by mime type through the same media machinery. `video("loop.gif")` needs no separate feature — same annotation, different extension.

## The `video()` component

`components.video` mirrors `components.image` so an author can swap one for the other without the layout moving. Shared and identical: the `source` positional, `width: 100%`, `height: 100%`, and `scrim: none` (the scrim paints over the poster exactly as it does over an image).

Three arguments cannot mean the same thing:

- **`source`** is a compile-time read for `image` and a runtime filename for `video`. `path("demo.mp4")` is the right spelling for symmetry, but the filename the viewers resolve is relative to the *output PDF*, and only the tool knows where that is (`-o out/deck.pdf` is a CLI concern the package cannot see). So the record carries the Typst-root-relative path, and `mosaic-compile` rewrites it relative to the directory it writes the PDF into at stamp time. A `video()` whose file is missing compiles fine and fails on stage, which is why the poster-first default matters — and why the tool warns when the referenced file does not exist next to the output.
- **`..native`** has no native video element to forward to. It forwards to the poster's `image()` call instead, so `alt` and `scaling` keep working.
- **`fit`** governs the poster only. A video annotation is a bare `/Rect` and the viewer scales the stream into it, so `fit: "cover"` would crop the poster while the player filled the rect differently. Default `video()` to `"contain"`: letterboxing is better than a silent disagreement between the static and presented builds.

Then video-only additions: `poster:`, plus playback options as named booleans per `CONVENTIONS.md`, mapping onto what the viewers accept (pympress's `show_controls`/`repeat`/`start_pos`/`duration`, pdfpc's query-string flags).

Caveat for the eventual docs page: the deck is only video-enabled after the stamp runs, which is why `video()` alone degrading to a poster is the safe default.

## Interactive plots and HTML widgets

Not inline, and this is a hard limit rather than a missing feature. pympress renders exclusively through poppler and cairo — no WebKit anywhere in the module, and its media backends are only `gif`, `gst`, and `vlc`. pdfpc is the same. PDF's own rich-media annotations (Flash, U3D/PRC) are Acrobat-only and poppler ignores them.

Click-to-open-in-browser is achievable, but the viewers diverge for a *local* file: pympress's URI handler passes the string straight to `webbrowser.open_new_tab`, which needs a scheme, while pdfpc's `launch_for_uri` (`link_action.vala:124`) guesses the MIME type and resolves a relative path against the PDF's directory. No single action satisfies both.

So the supported shape is a hosted widget: a static export on the page wrapped in `link("https://...")`, which is pure layout on Typst's native URI action, needs no stamping, and degrades in Adobe to an ordinary clickable figure. An offline deck could use pympress's `FILE_ATTACHMENT` extraction path, but that is pympress-only and belongs behind a flag, not in the design.

## Out of scope

- **Links generally.** Typst already emits GoTo and URI actions and both consoles handle them natively. Stamping would only add `Launch` and pdfpc's `run:` query string. Low value; pympress explicitly refuses Rendition and Movie *link* actions (`document.py:454-457`), so only the annotation forms work there anyway.
- **File attachments**, `GOTO_REMOTE`, `OCG_STATE`, `JAVASCRIPT` — all logged as unsupported by pympress.
- **Our own presenter app.** The rendering is the easy part; what would have to be rebuilt is dual-screen management across three platforms, timers and pacing, the overview, scribbling, pointer modes, the REST server and remote control, notes modes, media backends, and a decade of projector-quirk handling. A year of work to reach where a backend PR reaches in a week, at the cost of fragmenting Mosaic's story from "works with the consoles people already use" into "requires our app".

## Future, not now

- **A WebKit backend for pympress.** `media_overlays/base.py` is a clean pluggable abstraction — the machinery hands a backend a rect in page coordinates (`relative_margins`), a mime type, a file, and lifecycle hooks (`show`, `do_hide`, `resize`, `handle_embed`, `do_play`, `do_stop`). `GifOverlay` is the precedent for a non-video backend reusing it. A `WebviewOverlay` wrapping `WebKit2.WebView` would render a live widget in place, selected by `text/html` mime, from the same Screen annotation this tool already stamps. Upstreamable rather than a fork. The open design problem is input: a WebView wants clicks and scrolls, pympress wants them for navigation and scribbling, so a focus convention (click to activate, Escape to release) needs agreeing with upstream before code.
- **Typst HTML export** as a second rendering target, where widgets, video, and links are all natively live and the browser is the console. A much larger piece of work, and a different product from the PDF deck.

## To verify before building

1. **Hidden annotations.** Setting `/F` bit 2 (`Hidden`) should make a text annotation invisible in Adobe while both consoles still read it, since they reach annotations through `page.get_annot_mapping()` — which enumerates `/Annots` irrespective of flags — and remove them before rendering anyway. Test `/F` bit 6 (`NoView`) in the same sitting: the PDF spec gives the two different comments-sidebar semantics in Adobe, and one of them may be exactly "invisible on the page, listed in the sidebar", which for deliberately shared notes is desirable. Ten minutes with pikepdf against both viewers. Whatever the outcome, this decides *rendering*, not the default: the notes stamp stays opt-in because the text remains extractable (see the caveats under stamp 1).
2. **Page labels from Typst.** Whether `set page(numbering: ...)` can emit arbitrary or repeated labels; pattern-based labels probably cannot repeat a value across pages. If not, pikepdf writes `/PageLabels` directly, which is the reliable route regardless.
3. **pdfpc `--notes=right` longevity.** pdfpc RFC #472 proposed dropping beamer-notes support and is closed against milestone v4.5.0, but `notes_position` and `beamerNotePosition` are alive in current master, so the `split` route works today. The maintainer has expressed a preference for annotations over split pages, which is one more reason stamp 1 is the strategic one.
