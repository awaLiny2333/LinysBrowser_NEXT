import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../hosts/userdata/settings/classes/meowManagedSettings';
import { WoofUniFrame } from '../WoofUniFrame';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooStringArrayList } from '../../components/common/MooStringArrayList';
import { defaultAnimation, standardSpacing } from '../../components/settings';
import { MooSwitch } from '../../components/common/MooSwitch';

@ComponentV2
struct WebImagesPanel {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    MooStringArrayList({
      list: this.mySettings.settingsData[59].value as string[],
      onEdited: (index: number, newValue: string) => {
        const list = this.mySettings.settingsData[59].value as string[];
        list[index] = newValue;
        this.mySettings.requestSaveToDisk();
      },
      onDelete: (index: number) => {
        const list = this.mySettings.settingsData[59].value as string[];
        list.splice(index, 1);
        this.mySettings.requestSaveToDisk();
      },
      onNew: () => {
        const list = this.mySettings.settingsData[59].value as string[];
        list.push('meow.net');
        this.mySettings.requestSaveToDisk();
      }
    })
      .opacity(this.mySettings.settingsData[58].value as boolean ? 0.5 : 1)
      .animation(defaultAnimation())
      .padding(standardSpacing);

  }
}

@CustomDialog
struct WoofWebImagesDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiStatuses;


  build() {
    WoofUniFrame({ controller: this.controller, shiftBackgroundColor: true, title: $r('app.string.WebImages'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      WebImagesPanel();

      MooSwitch({
        text: $r('app.string.WebImages_blockAll'),
        isOn: (AppStorageV2.connect(meowManagedSettings)!).settingsData[58].value as boolean,
        onChange: (isOn: boolean) => {
          (AppStorageV2.connect(meowManagedSettings)!).setByIndex(58, isOn);
        }
      })
        .visibility(this.myLayout.shortMode ? Visibility.None : Visibility.Visible) // Save space for short contents
        .animation(defaultAnimation())
        .padding({ left: standardSpacing, right: standardSpacing, bottom: standardSpacing });
    };
  }
}

export { WoofWebImagesDialog };
