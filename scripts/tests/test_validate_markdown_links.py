import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "validate_markdown_links.py"
SPEC = importlib.util.spec_from_file_location("validate_markdown_links", SCRIPT_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ValidateMarkdownLinksTests(unittest.TestCase):
    def test_accepts_existing_links_and_ignores_remote_links_and_code_fences(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            (root / "docs").mkdir()
            (root / "docs" / "guide.md").write_text("# Guide\n", encoding="utf-8")
            (root / "README.md").write_text(
                "[Guide](docs/guide.md#guide)\n"
                '<source srcset="docs/guide.md">\n'
                "[Remote](https://example.com/missing)\n"
                "```md\n[Example](missing.md)\n```\n",
                encoding="utf-8",
            )

            self.assertEqual(MODULE.validate_links(root), [])

    def test_reports_missing_links_and_paths_outside_repository(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            (root / "README.md").write_text(
                "![Missing](docs/missing.png)\n[Outside](../private.md)\n",
                encoding="utf-8",
            )

            errors = MODULE.validate_links(root)

            self.assertEqual(len(errors), 2)
            self.assertTrue(any("missing link target" in error for error in errors))
            self.assertTrue(any("link leaves repository" in error for error in errors))
