import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

void main() {
  test('flutter_ui_gallery exports core UiGallery surface APIs', () {
    expect(UiGallerySheetPreset.values.length, 4);
    expect(UiGalleryDialogPreset.values.length, 4);
    expect(UiGalleryToastPreset.values.length, 3);
    expect(UiGalleryTokens.touchTarget, 48.0);

    // Verify backwards-compatible aliases
    expect(NovaSheetPreset.values.length, 4);
    expect(NovaDialogPreset.values.length, 4);
    expect(NovaToastPreset.values.length, 3);
    expect(NovaTokens.touchTarget, 48.0);
  });
}
