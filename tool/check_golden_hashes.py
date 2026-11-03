#!/usr/bin/env python3
"""Read-only guard for historical and versioned approved baselines."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'test/goldens/legacy_manifest.json').read_text())
assert len(manifest) == 24, 'The protected baseline set must contain 24 files'
for name, digest in manifest.items():
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
print('24/24 approved golden hashes unchanged')

notes = root / 'example/test/goldens/notes-pass-a/approved_manifest.json'
if notes.exists():
    protected = json.loads(notes.read_text())
    for name, digest in protected.items():
        assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
    print(f'{len(protected)}/{len(protected)} original Notes Pass A baselines unchanged')

hero = root / 'example/test/goldens/hero-calm-v1/approved_manifest.json'
approved = json.loads(hero.read_text())
assert len(approved) == 13, 'Hero Calm v1 must contain exactly 13 approved files'
for name, digest in approved.items():
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
print('13/13 approved Hero Calm v1 baselines unchanged')

dialogs = root / 'example/test/goldens/dialog-calm-v1/approved_manifest.json'
approved_dialogs = json.loads(dialogs.read_text())
assert len(approved_dialogs) == 24, 'Dialog Calm v1 must contain 24 approved files'
for name, digest in approved_dialogs.items():
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
print('24/24 approved Dialog Calm v1 baselines unchanged')

sheets = root / 'example/test/goldens/sheet-calm-v1/approved_manifest.json'
approved_sheets = json.loads(sheets.read_text())
assert len(approved_sheets) == 40, 'Sheet Calm v1 must contain 40 approved files'
for name, digest in approved_sheets.items():
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
print('40/40 approved Sheet Calm v1 baselines unchanged')
