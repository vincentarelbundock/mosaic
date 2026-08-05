"""Contrast contract for the built-in palette collection.

Every palette Mosaic ships (the light/dark polarity pair and the curated
`palettes` schemes) must stay legible with every theme, in both polarities,
and under `slide(invert: true)`. This test parses the palette literals out of
the package sources and enforces those invariants numerically, so a future
retune cannot quietly break a combination nobody happened to look at.

The thresholds bind only shipped palettes. User palettes passed through
`setup(colors: ..)` are deliberately never validated: the contract is a
promise about what we ship, not a gate on what decks may do.

Invariants, as WCAG relative-luminance contrast ratios:

- text on canvas >= 12: body ink must be unambiguous on a projector.
- muted on canvas >= 4: secondary ink is quieter, still readable.
- accent on canvas >= 4.5: the accent carries meaning, not just decoration.
- line on canvas in [1.1, 3.0]: visible, but furniture rather than ink.
- surface on canvas <= 1.3: a raised panel stays near its ground.

Invertibility. `slide(invert: true)` swaps canvas and text and rebuilds muted
and line as translucent washes of the new ink (see invert-colors in
src/slide/runtime.typ), while accent, warning, and error survive untouched.
So the surviving colors must read on *both* grounds, and the derived washes
must read on the old text color:

- accent on text >= 2.0, warning/error on canvas and on text >= 2.0.
- inverted muted (canvas at 70% over text) on text >= 4.
- inverted line (canvas at 22% over text) on text >= 1.3.
"""

from __future__ import annotations

import re
import unittest
from pathlib import Path

SOURCE = Path(__file__).parents[1] / "mosaic" / "src" / "palettes.typ"

# Palettes the collection must contain. Each is defined in palettes.typ under
# the same name the `palettes` namespace exposes it by.
EXPECTED = frozenset({
    "light",
    "dark",
    "parchment",
    "sage",
    "stone",
    "espresso",
    "forest",
    "slate",
})

KEYS = {"canvas", "surface", "accent", "text", "muted", "line", "warning", "error"}

PALETTE = re.compile(r"#let\s+([a-z-]+)\s*=\s*\((.*?)\n\)", re.S)
ENTRY = re.compile(r"([a-z-]+)\s*:\s*(?:rgb\(\"(#[0-9a-fA-F]{6})\"\)|(white|black))")

NAMED = {"white": "#ffffff", "black": "#000000"}


def parse_palettes() -> dict[str, dict[str, str]]:
    palettes: dict[str, dict[str, str]] = {}
    for name, body in PALETTE.findall(SOURCE.read_text(encoding="utf-8")):
        entries = {
            key: hexcode or NAMED[named]
            for key, hexcode, named in ENTRY.findall(body)
        }
        if entries:
            palettes[name] = entries
    return palettes


def luminance(hexcode: str) -> float:
    def channel(value: int) -> float:
        scaled = value / 255
        return scaled / 12.92 if scaled <= 0.04045 else ((scaled + 0.055) / 1.055) ** 2.4

    digits = hexcode.lstrip("#")
    r, g, b = (int(digits[i:i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)


def contrast(a: str, b: str) -> float:
    lighter, darker = sorted((luminance(a), luminance(b)), reverse=True)
    return (lighter + 0.05) / (darker + 0.05)


def composite(over: str, under: str, alpha: float) -> str:
    over, under = over.lstrip("#"), under.lstrip("#")
    mixed = "#"
    for i in (0, 2, 4):
        top, bottom = int(over[i:i + 2], 16), int(under[i:i + 2], 16)
        mixed += f"{round(alpha * top + (1 - alpha) * bottom):02x}"
    return mixed


class PaletteContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        parsed = parse_palettes()
        cls.palettes = {name: parsed[name] for name in EXPECTED if name in parsed}

    def test_collection_is_complete(self) -> None:
        self.assertEqual(set(self.palettes), set(EXPECTED))

    def test_palettes_carry_exactly_the_eight_keys(self) -> None:
        for name, palette in self.palettes.items():
            self.assertEqual(set(palette), KEYS, f"{name} palette keys")

    def assert_at_least(self, name: str, label: str, value: float, floor: float) -> None:
        self.assertGreaterEqual(
            round(value, 2), floor, f"{name}: {label} contrast {value:.2f} < {floor}"
        )

    def test_ink_reads_on_canvas(self) -> None:
        for name, p in self.palettes.items():
            self.assert_at_least(name, "text/canvas", contrast(p["text"], p["canvas"]), 12.0)
            self.assert_at_least(name, "muted/canvas", contrast(p["muted"], p["canvas"]), 4.0)
            self.assert_at_least(name, "accent/canvas", contrast(p["accent"], p["canvas"]), 4.5)

    def test_furniture_stays_quiet_but_visible(self) -> None:
        for name, p in self.palettes.items():
            line = contrast(p["line"], p["canvas"])
            self.assertGreaterEqual(round(line, 2), 1.1, f"{name}: line invisible on canvas")
            self.assertLessEqual(round(line, 2), 3.0, f"{name}: line too loud on canvas")
            surface = contrast(p["surface"], p["canvas"])
            self.assertLessEqual(round(surface, 2), 1.3, f"{name}: surface drifts from canvas")

    def test_surviving_colors_read_on_both_grounds(self) -> None:
        # slide(invert: true) keeps accent and the status colors while the
        # ground becomes the palette's text color.
        for name, p in self.palettes.items():
            self.assert_at_least(name, "accent/text", contrast(p["accent"], p["text"]), 2.0)
            for role in ("warning", "error"):
                self.assert_at_least(name, f"{role}/canvas", contrast(p[role], p["canvas"]), 2.0)
                self.assert_at_least(name, f"{role}/text", contrast(p[role], p["text"]), 2.0)

    def test_inverted_washes_read_on_the_swapped_ground(self) -> None:
        # Mirrors invert-colors: muted = canvas.transparentize(30%) and
        # line = canvas.transparentize(78%), both painted over the new
        # canvas, which is the palette's text color.
        for name, p in self.palettes.items():
            muted = composite(p["canvas"], p["text"], 0.70)
            line = composite(p["canvas"], p["text"], 0.22)
            self.assert_at_least(name, "inverted muted/text", contrast(muted, p["text"]), 4.0)
            self.assert_at_least(name, "inverted line/text", contrast(line, p["text"]), 1.3)


if __name__ == "__main__":
    unittest.main()
