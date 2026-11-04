#!/usr/bin/env python3
"""Verify Still's example-only render fonts; the existing guard pins the SDK."""
import hashlib
import json
from pathlib import Path
root = Path(__file__).resolve().parents[1]
pins = json.loads((root / 'example/test/goldens/still-home-refined/pins.json').read_text())
for name, digest in pins['fonts'].items():
    assert hashlib.sha256((root / 'example/assets/fonts/still' / name).read_bytes()).hexdigest() == digest, name
assert hashlib.sha256((root / 'example/assets/fonts/Alexandria.ttf').read_bytes()).hexdigest() == pins['Alexandria']
print('Still example font hashes match their pins')
