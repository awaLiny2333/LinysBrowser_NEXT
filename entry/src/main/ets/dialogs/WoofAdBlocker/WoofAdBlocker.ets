import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../hosts/userdata/settings/classes/meowManagedSettings';
import { WoofUniFrame } from '../WoofUniFrame';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooStringArrayList } from '../../components/common/MooStringArrayList';
import { standardSpacing } from '../../components/settings';

@ComponentV2
struct AdBlockerPanel {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    MooStringArrayList({
      list: this.mySettings.settingsData[53].value as string[],
      onEdited: (index: number, newValue: string) => {
        const list = this.mySettings.settingsData[53].value as string[];
        list[index] = newValue;
        this.mySettings.requestSaveToDisk();
      },
      onDelete: (index: number) => {
        const list = this.mySettings.settingsData[53].value as string[];
        list.splice(index, 1);
        this.mySettings.requestSaveToDisk();
      },
      onNew: () => {
        const list = this.mySettings.settingsData[53].value as string[];
        list.push('meow.net');
        this.mySettings.requestSaveToDisk();
      }
    })
      .padding(standardSpacing);
  }
}

@CustomDialog
struct WoofAdBlockerDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiStatuses;

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.AdBlocker'),
      tutorial: $r('app.string.AdBlocker_tutorial'),
    }) {
      AdBlockerPanel();
    };
  }
}

export { WoofAdBlockerDialog };
