#!/usr/bin/env python3
"""Pin the render toolchain and fonts, independently of the package SDK floor."""
import hashlib
import json
import shutil
from pathlib import Path

root = Path(__file__).resolve().parents[1]
pins = json.loads((root / 'example/test/goldens/notes-pass-a/pins.json').read_text())
sdk = Path(shutil.which('flutter')).resolve().parents[1]
version = json.loads((sdk / 'bin/cache/flutter.version.json').read_text())
assert version['flutterVersion'] == pins['flutter'], version
assert version['dartSdkVersion'] == pins['dart'], version
for family, name in [('Roboto', 'Roboto-Regular.ttf'), ('MaterialIcons', 'MaterialIcons-Regular.otf')]:
    path = sdk / 'bin/cache/artifacts/material_fonts' / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == pins['fonts'][family], family
assert hashlib.sha256((root / 'example/assets/fonts/Alexandria.ttf').read_bytes()).hexdigest() == pins['fonts']['Alexandria']
print('Notes render SDK and font hashes match their pins')
