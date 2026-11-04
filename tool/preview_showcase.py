"""Render the real Markdown with Dart markdown into a local, copy-enabled preview."""
import html
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / 'build/doc-preview'
RAW = 'https://raw.githubusercontent.com/Ahmedelsapagh10/flutter_ui_gallery/design-overhaul/'
BLOB = 'https://github.com/Ahmedelsapagh10/flutter_ui_gallery/blob/design-overhaul/'
CSS = '''
*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:24px}
body{margin:0;color:#103445;background:#f3f9fb;font:16px/1.65 system-ui,-apple-system,sans-serif}
header{padding:18px 32px;background:#092d3c;color:#d4f5f7;font-size:14px;letter-spacing:.04em}
header a{color:inherit}main{max-width:1060px;margin:32px auto;padding:42px 56px;background:white;border:1px solid #dfecef;border-radius:24px}
h1{font-size:44px;letter-spacing:-.04em;line-height:1.15;margin:0 0 18px}h2{font-size:30px;letter-spacing:-.03em;margin:50px 0 16px;padding-top:20px;border-top:1px solid #dfecef}h3{margin-top:32px}
a{color:#007c8c;text-underline-offset:3px}img{max-width:100%;height:auto;border-radius:16px;vertical-align:middle}p:has(>a>img[width]){display:flex;gap:14px;flex-wrap:wrap;align-items:center}p:has(>a>img[width]) a{display:flex;align-items:center;background:#edf8fa;min-height:100px;padding:8px;border-radius:14px;border:1px solid #dcebee}
p:has(>img){margin:24px 0}pre{position:relative;background:#102c39;color:#e8f6f8;padding:44px 24px 24px;border-radius:16px;overflow:auto;font:13px/1.6 ui-monospace,SFMono-Regular,monospace;max-height:560px;tab-size:2}pre code{background:none;padding:0;color:inherit;white-space:pre}code{font: .87em ui-monospace,SFMono-Regular,monospace;color:#075e6b;background:#edf6f8;border-radius:5px;padding:3px 5px}.copy{position:absolute;right:12px;top:10px;background:#264b5b;color:white;border:1px solid #547782;border-radius:7px;padding:5px 12px;cursor:pointer}.token-string{color:#a7e6c8}.token-keyword{color:#83c5f5}.token-type{color:#66d7db}blockquote{border-left:3px solid #44b9c3;margin-left:0;padding-left:20px;color:#466977}table{display:block;overflow:auto;border-collapse:collapse}td,th{padding:8px 12px;border:1px solid #dfecef}
.component{display:grid;grid-template-columns:minmax(0,.85fr) minmax(0,1.15fr);column-gap:28px;align-items:start}.component>h2,.component>p:nth-child(2){grid-column:1/-1}.component>img,.component>p:has(>img){grid-column:1;grid-row:3/6;position:sticky;top:22px}.component>p:has(>strong){grid-column:2}.component>pre{grid-column:2;grid-row:4;max-height:550px;margin-top:0}.component>p{grid-column:1/-1}.component>img,.component>p:has(>img) img{width:100%;max-width:440px}
@media(max-width:650px){.component{display:block}.component>img,.component>p:has(>img){position:static}}
@media(max-width:650px){header{padding:14px 18px}main{margin:0;padding:26px 20px;border:0;border-radius:0}h1{font-size:34px}h2{font-size:27px;margin-top:34px}pre{margin-left:-4px;margin-right:-4px;padding:42px 16px 18px;font-size:12px}p:has(>a>img[width]){gap:8px}}
'''
JS = r'''
document.querySelectorAll('pre').forEach(pre=>{
 const code=pre.querySelector('code'); if(!code)return;
 const button=document.createElement('button');button.className='copy';button.textContent='Copy code';
 button.addEventListener('click',async()=>{try{await navigator.clipboard.writeText(code.textContent);button.textContent='Copied';}catch{button.textContent='Select to copy';const range=document.createRange();range.selectNodeContents(code);getSelection().removeAllRanges();getSelection().addRange(range);}});pre.append(button);
 if(code.className.includes('language-dart')){
  const source=code.textContent;code.textContent='';
  const re=/('(\\.|[^'\\])*'|"(\\.|[^"\\])*"|\b(?:import|const|final|return|await|async|void|int|bool|false|true|class|extends|required)\b|\b[A-Z][A-Za-z0-9_]*\b)/g;
  let start=0;for(const m of source.matchAll(re)){code.append(document.createTextNode(source.slice(start,m.index)));const span=document.createElement('span');span.className=m[0][0]==="'"||m[0][0]==='"'?'token-string':/^[A-Z]/.test(m[0])?'token-type':'token-keyword';span.textContent=m[0];code.append(span);start=m.index+m[0].length;}code.append(document.createTextNode(source.slice(start)));
 }
});
'''


def main():
    dart = shutil.which('dart')
    assert dart, 'Activate Flutter 3.41.9 before building the preview.'
    pages = [ROOT / 'README.md', *(ROOT / 'doc').glob('*.md'), *(ROOT / 'doc/catalog').glob('*.md')]
    OUTPUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='gallery-markdown-') as tmp:
        tmp = Path(tmp)
        (tmp / 'pubspec.yaml').write_text('name: gallery_markdown_preview\nenvironment:\n  sdk: ^3.11.5\ndependencies:\n  markdown: 7.3.0\n')
        subprocess.run([dart, 'pub', 'get', '--offline'], cwd=tmp, check=True, stdout=subprocess.DEVNULL)
        (tmp / 'render.dart').write_text("import 'dart:io';\nimport 'package:markdown/markdown.dart';\nvoid main(List<String> paths) { for (final path in paths) { final f=File(path); f.writeAsStringSync(markdownToHtml(f.readAsStringSync(), extensionSet: ExtensionSet.gitHubWeb)); }}\n")
        inputs = []
        for page in pages:
            target = OUTPUT / page.relative_to(ROOT).with_suffix('.html')
            target.parent.mkdir(parents=True, exist_ok=True)
            content = page.read_text().replace(RAW, '/').replace(BLOB, '/')
            content = re.sub(r'(?<=\]\()([^):]*?\.md)(#[^)]*)?(?=\))',
                lambda m: '/build/doc-preview/' + str((ROOT / m[1].lstrip('/') if m[1].startswith('/') else page.parent / m[1]).resolve().relative_to(ROOT).with_suffix('.html')) + (m[2] or ''), content)
            # Resolve remaining relative image and source links against the repository.
            content = re.sub(r'(?<=\]\()((?![a-z]+:|/|#)[^)]*)(?=\))',
                lambda m: '/' + str((page.parent / m[1].split('#')[0]).resolve().relative_to(ROOT)) + ('#'+m[1].split('#',1)[1] if '#' in m[1] else ''), content)
            target.write_text(content)
            inputs.append(str(target))
        subprocess.run([dart, '--packages=' + str(tmp / '.dart_tool/package_config.json'), str(tmp / 'render.dart'), *inputs], check=True)
    for target in map(Path, inputs):
        body = target.read_text()
        body = re.sub(r'<h([1-6])>(.*?)</h\1>', lambda m: f'<h{m[1]} id="'+re.sub(r'[^\w -]', '', re.sub('<[^>]+>', '', html.unescape(m[2]))).lower().replace(' ', '-')+'">'+m[2]+f'</h{m[1]}>', body)
        if target == OUTPUT / 'README.html':
            for category in ['app-bars', 'toasts', 'bottom-sheets', 'dialogs', 'bottom-navigation']:
                body = re.sub(r'(<h2 id="' + category + r'">.*?)(?=<h2|$)', r'<section class="component">\1</section>', body, flags=re.S)
        target.write_text('<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Flutter UI Gallery · Documentation preview</title><style>'+CSS+'</style><header><a href="/build/doc-preview/README.html">Flutter UI Gallery</a> · Local Markdown preview</header><main>'+body+'</main><script>'+JS+'</script></html>')
    print('Preview: http://localhost:4173/build/doc-preview/README.html')


if __name__ == '__main__':
    main()
