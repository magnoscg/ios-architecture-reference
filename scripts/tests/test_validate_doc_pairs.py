import importlib.util
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "validate_doc_pairs.py"
SPEC = importlib.util.spec_from_file_location("validate_doc_pairs", SCRIPT_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ValidateDocPairsTests(unittest.TestCase):
    def test_accepts_translated_copy_with_matching_structure_and_links(self) -> None:
        english = (
            '# Guide\n## Build\n[Architecture](ARCHITECTURE.md)\n<img src="docs/app.png">\n'
            "```bash\nmake build\n```\n"
        )
        spanish = (
            '# Guía\n## Compilar\n[Arquitectura](ARCHITECTURE.es.md)\n<img src="docs/app.png">\n'
            "```bash\nmake build\n```\n"
        )

        self.assertEqual(MODULE.validate_pair(english, spanish, "README"), [])

    def test_reports_heading_code_block_and_link_drift(self) -> None:
        english = "# Guide\n## Build\n[Architecture](ARCHITECTURE.md)\n```bash\nmake build\n```\n"
        spanish = "# Guía\n### Compilar\n[Arquitectura](missing.md)\n```text\nmake build\n```\n"

        errors = MODULE.validate_pair(english, spanish, "README")

        self.assertEqual(len(errors), 3)
