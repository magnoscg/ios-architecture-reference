import importlib.util
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "select_ios_simulator.py"
SPEC = importlib.util.spec_from_file_location("select_ios_simulator", SCRIPT_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class SelectIOSSimulatorTests(unittest.TestCase):
    def test_selects_available_iphone_from_newest_runtime(self) -> None:
        payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.iOS-18-5": [
                    {"name": "iPhone 16", "udid": "OLDER", "isAvailable": True, "state": "Shutdown"}
                ],
                "com.apple.CoreSimulator.SimRuntime.iOS-26-2": [
                    {"name": "iPad Pro", "udid": "IPAD", "isAvailable": True, "state": "Shutdown"},
                    {"name": "iPhone Unavailable", "udid": "NOPE", "isAvailable": False, "state": "Shutdown"},
                    {"name": "iPhone 17", "udid": "NEWEST", "isAvailable": True, "state": "Shutdown"},
                ],
            }
        }

        self.assertEqual(MODULE.select_simulator(payload), "NEWEST")

    def test_raises_when_no_iphone_is_available(self) -> None:
        payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.iOS-26-2": [
                    {"name": "iPad Pro", "udid": "IPAD", "isAvailable": True, "state": "Shutdown"}
                ]
            }
        }

        with self.assertRaisesRegex(RuntimeError, "No available iPhone simulator"):
            MODULE.select_simulator(payload)
