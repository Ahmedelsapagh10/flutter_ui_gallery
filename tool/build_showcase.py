"""Build the Markdown showcase from the playground's exported public-API snippets."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent
GITHUB = 'https://github.com/Ahmedelsapagh10/flutter_ui_gallery'
BLOB = GITHUB + '/blob/design-overhaul/'
RAW = 'https://raw.githubusercontent.com/Ahmedelsapagh10/flutter_ui_gallery/design-overhaul/'
ASSETS = 'doc/assets/showcase-v021/'
GROUPS = [
    ('header', 'app-bars', 'App Bars', 17, 'header.searchSwitch',
     'Give each screen a clear identity, with headers for search, focused work, and navigation.'),
    ('toasts', 'toasts', 'Toasts', 11, 'toasts.action',
     'Keep people informed with compact feedback, recovery actions, and live progress.'),
    ('sheets', 'bottom-sheets', 'Bottom Sheets', 12, 'sheets.orbit',
     'Bring contextual actions, forms, and useful details into reach without leaving the screen.'),
    ('dialogs', 'dialogs', 'Dialogs', 11, 'dialogs.sideBySideChoice',
     'Make decisions easier with clear choices, searchable commands, and focused results.'),
    ('bottomNav', 'bottom-navigation', 'Bottom Navigation', 15, 'bottomNav.morphingCapsule',
     'Keep primary destinations visible with selection-aware bars, docks, and shelves.'),
]
ENUMS = dict(zip(['header', 'toasts', 'sheets', 'dialogs', 'bottomNav'],
                ['AppBar', 'Toast', 'Sheet', 'Dialog', 'BottomNav']))
CUSTOM = {
    'header': ('`title`, `subtitle`, `leading`, `actions`, `bottom`, `scrollAware`, and `style`.',
               'Search callbacks belong to your screen. Section Tabs needs a `DefaultTabController`; the snippet includes it. Selection Bar receives caller-owned selection.'),
    'toasts': ('`kind`, `position`, `duration`, `actionLabel` / `onAction`, `style`, and `motion`.',
               'Call from a mounted route below a `MaterialApp`. Supply both action label and callback. Route-scoped toasts are cleared when the route closes.'),
    'sheets': ('`header`, `child`, `footer`, `style`, `appearance`, and `motion`.',
               'Use the sheet builder context with `Navigator.pop` to close the correct route. Await the typed result; a dismissed route returns `null`.'),
    'dialogs': ('`title`, `message`, `actions`, `child`, `result`, `style`, and `motion`.',
                'Handle dismissal as `null`. Choice and command helpers return `String?`; confirmation helpers return `bool?`. Check `mounted` before updating state after awaiting.'),
    'bottomNav': ('`items`, `selectedIndex`, `onDestinationSelected`, `centerAction`, `options`, and `style`.',
                  'The caller owns selection and destination content. Disabled items do not navigate. Some labels appear only for the selected destination.'),
}
SPECIAL = {
    'header.selectionBar': 'Own the `Set<int>` in your screen. Toggle, clear, and archive callbacks must update that same selection.',
    'header.editorialTopbar': 'The preferred height stays fixed. At extreme text scales the heading and supporting copy may need reading gestures; see the compatibility notes.',
    'header.sectionTabs': 'The included `DefaultTabController` owns tab state and pairs three tabs with three pages.',
    'sheets.fold': 'Tap the expand handle to reveal more content. The expanded screenshot shows the same retained child.',
    'dialogs.commandPalette': 'Typing filters commands. Disabled commands stay unavailable; Enter selects the highlighted enabled command.',
    'dialogs.timeline': 'Own and dispose the `ValueNotifier<UiGalleryTimelineState>`. Keep currentStep within the steps list. The complete app advances real caller-owned state.',
    'dialogs.milestone': 'Own and dispose the `ValueNotifier<UiGalleryTimelineState>`. Completion is an explicit state change; the dialog does not perform a background task.',
    'dialogs.spotlight': 'Pass the real operation result as `UiGalleryResult`; the preview uses `success`.',
    'dialogs.statusBeacon': 'Pass the real operation result as `UiGalleryResult`; the preview uses `success`.',
    'dialogs.split': 'This example is a destructive confirmation. Treat only `true` as confirmation; both `false` and `null` leave the draft intact.',
    'toasts.progressCard': 'Own and dispose a `ValueNotifier<double>` with values from 0 to 1. Dismiss the returned toast handle before disposing the notifier. Progress does not imply an actual upload.',
    'bottomNav.glassDock': 'The included Scaffold uses `extendBody: true` so body content can appear behind the glass. Blur visibility depends on the content behind it.',
    'bottomNav.scrollDock': 'The included scrollable Scaffold supplies body-scroll notifications for this dock.',
    'bottomNav.concaveNotch': 'Supply a real center action callback. The sample creates an action surface; it does not navigate automatically.',
    'bottomNav.splitIsland': 'Supply a real center action callback independently of destination selection.',
    'bottomNav.overflowDock': 'Extra destinations appear in the overflow menu. Keep the selected index tied to the complete items list.',
}
STATES = {
    'header.searchSwitch': ('expanded', 'Search open'),
    'sheets.fold': ('expanded', 'Expanded'),
    'dialogs.commandPalette': ('filtered', 'Filtered commands'),
    'dialogs.timeline': ('completed', 'Completed'),
    'dialogs.milestone': ('completed', 'Completed'),
    'bottomNav.morphingCapsule': ('selected', 'Saved selected'),
}


def write(path, text, check):
    target = ROOT / path
    if target.suffix == '.md':
        text = text.rstrip() + '\n'
    if check:
        assert target.read_text() == text, f'Stale generated document: {path}'
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    os.chdir(ROOT)
    inventory = json.loads((ROOT / 'doc/catalog/inventory.json').read_text())
    assert len(inventory) == len({e['id'] for e in inventory}) == 66
    items = {e['id']: e for e in inventory}
    dart = shutil.which('dart')
    assert dart, 'Activate the pinned Flutter SDK first.'
    with tempfile.TemporaryDirectory(prefix='gallery-snippets-') as tmp:
        paths = []
        for e in inventory:
            source = Path(tmp) / (e['id'] + '.dart')
            source.write_text(e['source'])
            paths.append(str(source))
        subprocess.run([dart, 'format', '--summary=none', *paths], check=True, stdout=subprocess.DEVNULL)
        for e, source in zip(inventory, paths):
            e['formatted'] = Path(source).read_text()
    for e in inventory:
        write(f"doc/catalog/code/{e['id']}.dart", e['formatted'], args.check)
        # Component-focused, lossless crops; full PNGs remain linked for context.
        category = e['category']
        crop = {'header': (0, 0, 660, 390), 'toasts': (0, 0, 660, 840),
                'bottomNav': (0, 690, 660, 150)}.get(category, (0, 0, 660, 840))
        if category == 'toasts':
            crop = (0, 0, 660, 240) if e['id'] in ['toasts.ribbon', 'toasts.inlinePulse'] else (0, 555, 660, 285)
        if not args.check:
            subprocess.run(['cwebp', '-quiet', '-lossless', '-crop', *map(str, crop),
                            str(ROOT / ASSETS / (e['id'] + '.png')), '-o',
                            str(ROOT / ASSETS / (e['id'] + '.webp'))], check=True)
    for category, slug, title, count, featured, purpose in GROUPS:
        assert sum(e['category'] == category for e in inventory) == count

    nav = ' · '.join(f'[{title} ({count})](#{slug})' for _, slug, title, count, _, _ in GROUPS)
    tiles = '\n'.join(f'<a href="#{slug}"><img src="{RAW}{ASSETS}tile-{slug}.png" alt="{title} — {count} presets" width="128"></a>' for _, slug, title, count, _, _ in GROUPS)
    readme = f'''<!-- Generated by tool/build_showcase.py. Edit the generator or exported examples. -->
# Flutter UI Gallery

**Beautiful Flutter components. Ready to use.**

66 ready-to-use Flutter UI presets across five component categories.
Bring your app's theme and state; choose the surfaces that fit.

![Real Flutter app bar, actionable toast, bottom sheet, dark dialog, and bottom navigation]({RAW}{ASSETS}hero.png)

## Explore components

{nav}

<p>
{tiles}
</p>

## Quick installation

```sh
flutter pub add flutter_ui_gallery
```

[SDK requirements and full runnable setup]({BLOB}doc/QUICK_START.md).

'''
    for category, slug, title, count, featured, purpose in GROUPS:
        e = items[featured]
        source = e['formatted']
        # The compact README keeps imports and the usage function; all complete catalog
        # examples also include the shared Soft/signature theme shown below.
        start = re.search(r'\n(?:Future<[^\n]+|void |Widget |UiGalleryToastHandle )show', source).start()
        imports = "import 'package:flutter/material.dart';\nimport 'package:flutter_ui_gallery/flutter_ui_gallery.dart';\n"
        snippet = imports + source[start:]
        if category == 'header':
            snippet = re.sub(r'    body: ListView\(.*?\n    \),\n', '', snippet, flags=re.S)
        readme += f'''## {title}

{purpose}

<img src="{RAW}{ASSETS}{featured}.webp" alt="{e['name']} — actual Flutter {title.lower()} preview" width="440">

**Copy & Use — {e['name']}**

```dart
{snippet.rstrip()}
```

**Customize:** {CUSTOM[category][0]}

[Category overview]({RAW}{ASSETS}{slug}.png) ·
[Complete stateful example]({BLOB}example/lib/showcase.dart) ·
[Inspect {e['name']}]({BLOB}doc/catalog/{slug}.md#{featured.split('.')[1].lower()}) ·
[Explore all {count} presets →]({BLOB}doc/catalog/{slug}.md)

'''
    readme += f'''## Customization

**Minimal** keeps surfaces precise. **Soft** adds comfortable geometry.
**Spatial** adds restrained depth. Each family uses the host `ColorScheme` and
`TextTheme`. Optional signatures add the family treatment; choosing a family
alone leaves signatures off. These screenshots use Soft with signatures on.

```dart
ThemeData galleryTheme() {{
  final base = ThemeData(colorSchemeSeed: const Color(0xff007f88));
  return base.copyWith(
    extensions: [
      UiGalleryTheme.family(
        UiGalleryDesignFamily.soft,
        theme: base,
        useSignature: true,
      ),
    ],
  );
}}
```

Apply it to `MaterialApp(theme: galleryTheme())`. Configure `darkTheme` from a dark
base theme too. Per-call `style` and `motion` override inherited defaults;
reduced-motion preferences still apply.

[Theme, style, and motion options]({BLOB}doc/USAGE.md) ·
[Signatures and override precedence]({BLOB}doc/FAMILY_SIGNATURES.md)

## Resources

- [Complete visual catalog — all 66 presets]({BLOB}doc/catalog/README.md)
- [Full runnable example and setup]({BLOB}doc/QUICK_START.md)
- [API reference](https://pub.dev/documentation/flutter_ui_gallery/latest/)
- [Advanced customization]({BLOB}doc/USAGE.md)
- [Migration guide]({BLOB}doc/MIGRATION.md)
- [GitHub repository]({GITHUB})

MIT · [Ahmed Mohamed Elsapagh](https://github.com/Ahmedelsapagh10) ·
[License]({BLOB}LICENSE)
'''
    write('README.md', readme, args.check)
    dart_blocks = re.findall(r'```dart\n(.*?)```', readme, re.S)
    fixture_imports = set()
    fixture_bodies = []
    for block in dart_blocks:
        fixture_imports.update(line for line in block.splitlines() if line.startswith('import '))
        fixture_bodies.append('\n'.join(line for line in block.splitlines() if not line.startswith('import ')))
    fixture = '\n'.join(sorted(fixture_imports)) + '\n' + '\n'.join(fixture_bodies)
    fixture = subprocess.run([dart, 'format', '--output=show', '--summary=none'], input=fixture, text=True, capture_output=True, check=True).stdout
    write('tool/readme_examples.dart', fixture, args.check)
    index = '# Visual preset catalog\n\n66 real Flutter presets. Choose a category, inspect the design, and copy the public-API example.\n\n'
    index += '[Package introduction](../../README.md) · [Runnable example](../QUICK_START.md) · [Customization](../USAGE.md)\n\n'
    for category, slug, title, count, featured, purpose in GROUPS:
        index += f'## [{title} — {count} presets]({slug}.md)\n\n{purpose}\n\n[![{title} overview](../assets/showcase-v021/{slug}.png)]({slug}.md)\n\n'
        entries = [e for e in inventory if e['category'] == category]
        toc = ' · '.join(f"[{e['name']}](#{e['id'].split('.')[1].lower()})" for e in entries)
        page = f'''<!-- Generated by tool/build_showcase.py. -->
# {title}

{count} canonical presets. {purpose}

[All categories](README.md) · [Package introduction](../../README.md) · [Theme and setup](../QUICK_START.md)

![{title} overview](../assets/showcase-v021/{slug}.png)

{toc}

The captures below use the included Soft theme with signatures enabled, at a
440 × 560 logical-pixel viewport and 1.5× export resolution. The light preview
matches the example's default theme. Each full example includes its imports and
theme helper. Apply that helper to `MaterialApp.theme` before invoking the widget.

For a complete app with owned state, callbacks, and disposal, use
[`example/lib/showcase.dart`](../../example/lib/showcase.dart):

```sh
cd example
flutter run -t lib/showcase.dart --dart-define=PRESET={featured}
```

Change `PRESET` to the exact ID beside any entry. Helper parameters are supplied
by your screen; the runnable app shows their ownership. Copy uses ordinary Dart
code fences and your Markdown viewer's native copy control where available.

'''
        for e in entries:
            id = e['id']; member = id.split('.')[1]
            enum = 'UiGallery' + ENUMS[category] + 'Preset.' + member
            states = []
            if id in [g[4] for g in GROUPS]:
                states.append(f'[Dark theme](../assets/showcase-v021/{id}-dark.png)')
            if id in STATES:
                suffix, label = STATES[id]
                states.append(f'[{label}](../assets/showcase-v021/{id}-{suffix}.png)')
            extra = ' · '.join(states)
            page += f'''<a id="{member.lower()}"></a>

## {e['name']}

`{enum}` · `PRESET={id}`

{e['purpose']}

[![{e['name']} — actual Flutter render](../assets/showcase-v021/{id}.webp)](../assets/showcase-v021/{id}.png)

{extra}

**Copy & Use**

```dart
{e['formatted'].rstrip()}
```

**Customize:** {CUSTOM[category][0]}

**Interaction:** {SPECIAL.get(id, CUSTOM[category][1])}

[Complete runnable owner](../../example/lib/showcase.dart) · [Dart source](code/{id}.dart) · [Back to category](#{slug})

'''
        write(f'doc/catalog/{slug}.md', page, args.check)
    write('doc/catalog/README.md', index, args.check)
    for e in inventory:
        e['source'] = e['formatted']
    write('doc/catalog/inventory.json', json.dumps([{k: v for k, v in e.items() if k != 'formatted'} for e in inventory], indent=2, ensure_ascii=False) + '\n', args.check)
    files = sorted((ROOT / ASSETS).glob('*.png'))
    manifest = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    write('doc/catalog/captures.json', json.dumps(manifest, indent=2) + '\n', args.check)
    # Check local navigation and every Markdown/HTML asset path, including README absolute links.
    count = 0
    for page in [ROOT / 'README.md', *(ROOT / 'doc/catalog').glob('*.md')]:
        content = page.read_text()
        urls = re.findall(r'\]\(([^)]+)\)|(?:src|href)="([^"]+)"', content)
        for pair in urls:
            url = next(x for x in pair if x)
            if url.startswith(RAW): path = ROOT / url[len(RAW):].split('#')[0]
            elif url.startswith(BLOB): path = ROOT / url[len(BLOB):].split('#')[0]
            elif url.startswith(('http:', 'https:')): continue
            elif url.startswith('#'):
                assert url[1:] in set(re.findall(r'<a id="([^"]+)"', content)) | {re.sub(r'[^\w -]', '', h).lower().replace(' ', '-') for h in re.findall(r'^#+ (.+)', content, re.M)}, (page, url)
                continue
            else: path = page.parent / url.split('#')[0]
            assert path.exists(), (page, url)
            if '#' in url:
                target = path.read_text()
                anchors = set(re.findall(r'<a id="([^"]+)"', target))
                anchors.update(re.sub(r'[^\w -]', '', h).lower().replace(' ', '-') for h in re.findall(r'^#+ (.+)', target, re.M))
                assert url.split('#', 1)[1] in anchors, (page, url)
            count += 1
        assert content.count('```') % 2 == 0, page
    print(f'66 unique presets; category counts 17/11/12/11/15; {count} local link/image targets verified.')


if __name__ == '__main__':
    main()
