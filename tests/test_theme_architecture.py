from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]
SRC = ROOT / "mosaic" / "src"
STARTER = ROOT / "docs" / "examples" / "embedded" / "appearance"
PORTFOLIO = ROOT / "docs" / "examples" / "decks" / "portfolio"
BUILTINS = ("light", "dark", "cream", "metropolis", "minimalist")
RETIRED_HELPERS = (
    "configured-theme",
    "configured-options",
    "themed-base",
    "setup-common.typ",
)


class ThemeArchitectureTests(unittest.TestCase):
    def test_light_owns_a_concrete_theme_definition(self) -> None:
        light = SRC / "themes" / "light"
        self.assertTrue((light / "definition.typ").is_file())
        self.assertFalse((light / "setup.typ").exists())
        facade = (SRC / "themes" / "light.typ").read_text(encoding="utf-8")
        self.assertIn("_extension.setup(definition)", facade)
        self.assertNotIn('"../setup.typ": setup', facade)

    def test_builtin_definitions_do_not_import_setup_machinery(self) -> None:
        for name in BUILTINS:
            source = (SRC / "themes" / name / "definition.typ").read_text(encoding="utf-8")
            for retired in RETIRED_HELPERS:
                self.assertNotIn(retired, source, f"{name} definition calls setup machinery")

    def test_builtin_bindings_live_in_facades(self) -> None:
        for name in BUILTINS:
            self.assertFalse((SRC / "themes" / name / "setup.typ").exists())
            source = (SRC / "themes" / f"{name}.typ").read_text(encoding="utf-8")
            self.assertIn("_extension.setup(definition)", source)
            for retired in RETIRED_HELPERS:
                self.assertNotIn(retired, source, f"{name} facade retains retired helper {retired}")

    def test_layout_namespaces_do_not_have_forwarding_impl_files(self) -> None:
        for name in BUILTINS:
            self.assertFalse((SRC / "themes" / name / "layouts-impl.typ").exists())

    def test_retired_setup_helper_module_is_deleted(self) -> None:
        self.assertFalse((SRC / "themes" / "setup-common.typ").exists())

    def test_starter_is_a_passive_exact_facade(self) -> None:
        definition = (STARTER / "_starter-definition.typ").read_text(encoding="utf-8")
        facade = (STARTER / "_starter-theme.typ").read_text(encoding="utf-8")
        self.assertNotIn("mosaic.setup", definition)
        self.assertFalse((STARTER / "_starter-setup.typ").exists())
        self.assertFalse((STARTER / "_starter-layouts-impl.typ").exists())
        self.assertFalse((STARTER / "_starter-tokens.typ").exists())
        self.assertIn("themes.setup(definition)", facade)
        for name in ("slide", "note", "fit", "surface", "grids", "steps", "components"):
            self.assertIn(name, facade)

    def test_portfolio_uses_the_same_reduced_structure(self) -> None:
        self.assertFalse((PORTFOLIO / "theme-setup.typ").exists())
        self.assertFalse((PORTFOLIO / "theme-layouts-impl.typ").exists())
        facade = (PORTFOLIO / "theme.typ").read_text(encoding="utf-8")
        self.assertIn("themes.setup(definition)", facade)


if __name__ == "__main__":
    unittest.main()