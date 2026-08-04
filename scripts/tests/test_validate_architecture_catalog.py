import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "validate_architecture_catalog.py"
SPEC = importlib.util.spec_from_file_location("validate_architecture_catalog", SCRIPT_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class ValidateArchitectureCatalogTests(unittest.TestCase):
    def test_detail_catalog_rejects_duplicate_ids(self) -> None:
        feature = {
            "id": "mvvm",
            "name": "MVVM",
            "category": "architecture",
            "isImplemented": True,
            "filesInvolved": [{"name": "ArchitectureView.swift"}],
        }

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "catalog.json"
            path.write_text(json.dumps({"features": [feature, feature]}), encoding="utf-8")
            summaries, _ = MODULE.load_detail_catalog(path)

        original_count = MODULE.EXPECTED_ENTRY_COUNT
        MODULE.EXPECTED_ENTRY_COUNT = 2
        try:
            with self.assertRaisesRegex(ValueError, "duplicate IDs"):
                MODULE.validate_detail_summaries(summaries)
        finally:
            MODULE.EXPECTED_ENTRY_COUNT = original_count

    def test_evidence_matches_real_file_and_directory_suffixes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source_directory = root / "Arquitectura/Domain/Architecture"
            source_directory.mkdir(parents=True)
            source_file = source_directory / "ArchitectureModel.swift"
            source_file.write_text("struct ArchitectureModel {}", encoding="utf-8")

            self.assertEqual(
                MODULE.evidence_matches(root, "ArchitectureModel.swift"),
                [source_file],
            )
            self.assertEqual(
                MODULE.evidence_matches(root, "Domain/Architecture"),
                [source_directory],
            )

    def test_evidence_rejects_parent_traversal(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "unsafe catalogue evidence"):
                MODULE.evidence_matches(Path(directory), "../private.swift")


if __name__ == "__main__":
    unittest.main()
