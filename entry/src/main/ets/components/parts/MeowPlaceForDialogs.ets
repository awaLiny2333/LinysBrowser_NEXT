import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import { meowDialogManager, openDialogRequestType } from '../../hosts/env/classes/meowDialogManager';
import { WoofSettingsDialog } from '../dialogs/WoofSettings/WoofSettings';
import { AppStorageV2 } from '@kit.ArkUI';
import { CatsDevDialog } from '../dialogs/CatsDev/CatsDevCards';
import { WoofColorPickerDialog } from '../dialogs/WoofColorPicker/WoofColorPicker';

/**
 * A place for dialogs.
 * Cooperates with meowDialogManager class.
 */
@ComponentV2
struct MeowPlaceForDialogs {
  @Local myMeowDialogManager: meowDialogManager = AppStorageV2.connect(meowDialogManager)!;

  catsDevDialogController: CustomDialogController = new CustomDialogController({
    builder: CatsDevDialog(),
    alignment: DialogAlignment.Center,
    width: '90%',
    // height: '90%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofSettingsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofSettingsDialog(),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofColorPickerController: CustomDialogController = new CustomDialogController({
    builder: WoofColorPickerDialog(),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });

  build() {
    // Nothing
  }

  @Monitor('myMeowDialogManager.lastRequest')
  openRequestedDialog() {
    const lastRequest = this.myMeowDialogManager.lastRequest;
    if (!lastRequest) {
      return;
    }
    switch (lastRequest.target) {
      case openDialogRequestType.DEV:
        this.catsDevDialogController.open();
        break;
      case openDialogRequestType.SETTINGS:
        this.woofSettingsDialogController.open();
        break;
      case openDialogRequestType.COLOR_PICKER:
        this.woofColorPickerController.open();
        break;
      default:
        break;
    }
  }
}

export { MeowPlaceForDialogs };
