from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "scripts" / "check-api-exports.py"
SPEC = importlib.util.spec_from_file_location("check_api_exports", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)


class ExportScannerTests(unittest.TestCase):
    def exports(self, source: str, dependencies: dict[str, str] | None = None) -> set[str]:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            owner = root / "facade.typ"
            owner.write_text(source, encoding="utf-8")
            for name, content in (dependencies or {}).items():
                (root / name).write_text(content, encoding="utf-8")
            return CHECKER.exports(owner)

    def test_ignores_line_and_nested_block_comments(self) -> None:
        actual = self.exports(
            """
// #let line-ghost = none
/*
#import "missing.typ": imported-ghost
#let block-ghost = none
/* #let nested-ghost = none */
*/
#let real = none
"""
        )
        self.assertEqual(actual, {"real"})

    def test_preserves_comment_markers_inside_strings(self) -> None:
        actual = self.exports(
            '''#let url = "https://example.com/path"
#let marker = "/* not a comment */"
'''
        )
        self.assertEqual(actual, {"url", "marker"})

    def test_resolves_multiline_alias_selected_and_wildcard_imports(self) -> None:
        actual = self.exports(
            '''#import "dependency.typ": (
  one,
  two as renamed,
)
#import "wildcard.typ": *
#import "namespace.typ" as tools
''',
            {
                "dependency.typ": "#let one = 1\n#let two = 2\n",
                "wildcard.typ": "#let three = 3\n",
                "namespace.typ": "#let hidden = 4\n",
            },
        )
        self.assertEqual(actual, {"one", "renamed", "three", "tools"})

    def test_private_module_alias_is_not_exported(self) -> None:
        actual = self.exports(
            '#import "dependency.typ" as _private\n#let public = 1\n',
            {"dependency.typ": "#let internal = 1\n"},
        )
        self.assertEqual(actual, {"public"})


if __name__ == "__main__":
    unittest.main()
