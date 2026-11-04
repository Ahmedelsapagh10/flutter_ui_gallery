import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_gallery/flutter_ui_gallery.dart';

void main() {
  test('flutter_ui_gallery exports core UiGallery surface APIs', () {
    expect(UiGallerySheetPreset.values.length, 12);
    expect(UiGalleryDialogPreset.values.length, 11);
    expect(UiGalleryToastPreset.values.length, 11);
    expect(UiGalleryAppBarPreset.values.length, 17);
    expect(UiGalleryBottomNavPreset.values.length, 15);
    expect(UiGalleryTokens.touchTarget, 48.0);

    // Verify backwards-compatible aliases
    expect(NovaSheetPreset.values.length, 12);
    expect(NovaDialogPreset.values.length, 11);
    expect(NovaToastPreset.values.length, 11);
    expect(NovaTokens.touchTarget, 48.0);
    expect(UiGallerySheetPreset.values.take(4), [
      UiGallerySheetPreset.orbit,
      UiGallerySheetPreset.fold,
      UiGallerySheetPreset.prism,
      UiGallerySheetPreset.flow,
    ]);
    expect(UiGalleryAppBarPreset.values.take(8), [
      UiGalleryAppBarPreset.adaptiveHorizon,
      UiGalleryAppBarPreset.floatingArc,
      UiGalleryAppBarPreset.compactRail,
      UiGalleryAppBarPreset.splitHeader,
      UiGalleryAppBarPreset.focusBar,
      UiGalleryAppBarPreset.panoramaBar,
      UiGalleryAppBarPreset.layeredNav,
      UiGalleryAppBarPreset.editorialTopbar,
    ]);
  });
}
