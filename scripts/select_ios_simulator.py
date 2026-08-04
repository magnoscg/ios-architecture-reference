#!/usr/bin/env python3
"""Select an available iPhone from the newest installed iOS runtime."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


def runtime_version(identifier: str) -> tuple[int, ...]:
    match = re.search(r"\.iOS-(\d+(?:-\d+)*)$", identifier)
    if match is None:
        return ()
    return tuple(int(component) for component in match.group(1).split("-"))


def select_simulator(payload: dict[str, Any]) -> str:
    candidates: list[tuple[tuple[int, ...], bool, str, str]] = []

    for runtime, devices in payload.get("devices", {}).items():
        version = runtime_version(runtime)
        if not version:
            continue

        for device in devices:
            name = str(device.get("name", ""))
            udid = str(device.get("udid", ""))
            if device.get("isAvailable") is not True or not name.startswith("iPhone") or not udid:
                continue
            candidates.append((version, device.get("state") == "Booted", name, udid))

    if not candidates:
        raise RuntimeError("No available iPhone simulator is installed")

    candidates.sort(reverse=True)
    return candidates[0][3]


def load_devices(devices_json: Path | None) -> dict[str, Any]:
    if devices_json is not None:
        return json.loads(devices_json.read_text(encoding="utf-8"))

    result = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "available", "--json"],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--devices-json", type=Path, help="Read simctl JSON from a fixture")
    arguments = parser.parse_args()

    try:
        print(select_simulator(load_devices(arguments.devices_json)))
    except (OSError, json.JSONDecodeError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Unable to select an iPhone simulator: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
