#!/usr/bin/env python3
"""Read-only guard for the 24 approved pre-Notes baselines. Run from any folder."""
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
