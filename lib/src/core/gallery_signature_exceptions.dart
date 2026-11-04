import '../appbars/gallery_appbar.dart';
import '../dialogs/gallery_dialog.dart';
import '../navigation/gallery_bottom_nav.dart';
import '../sheets/gallery_sheet.dart';

/// Explicit structural exceptions to the opt-in recipe; silhouettes are always
/// preserved by the general rule and are not individually counted here.
abstract final class GallerySignatureExceptions {
  static const sheetWells = {UiGallerySheetPreset.neoTray};
  static const dialogWells = {UiGalleryDialogPreset.panelDecision};
  static const headerRules = {UiGalleryAppBarPreset.editorialTopbar};
  static const headerDepth = {
    UiGalleryAppBarPreset.sculptedWave,
    UiGalleryAppBarPreset.foldedCanopy,
    UiGalleryAppBarPreset.parallaxCrest,
    UiGalleryAppBarPreset.orbitCommand,
  };
  static const navDepth = {
    UiGalleryBottomNavPreset.concaveNotch,
    UiGalleryBottomNavPreset.splitIsland,
    UiGalleryBottomNavPreset.orbitDock,
    UiGalleryBottomNavPreset.layeredShelf,
    UiGalleryBottomNavPreset.perspectiveDock,
  };
  static const navComposition = {UiGalleryBottomNavPreset.overflowDock};

  // Count the named Stack Panel/Minimal guarantee conservatively as an
  // exception, even though the generic rule already leaves outer planes alone.
  static const minimal = <Enum>{
    UiGallerySheetPreset.stackPanel,
    ...headerRules,
    ...navComposition,
  };
  static const soft = <Enum>{...sheetWells, ...dialogWells, ...navComposition};
  static const spatial = <Enum>{...headerDepth, ...navDepth, ...navComposition};
}
