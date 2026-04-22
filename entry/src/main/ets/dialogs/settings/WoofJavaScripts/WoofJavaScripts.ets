import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { WoofUniFrame } from '../../WoofUniFrame';
import { AppStorageV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { MooStringArrayList } from '../../../components/common/MooStringArrayList';
import { defaultAnimation, standardSpacing } from '../../../components/settings';
import { MooTabSegmentV2 } from '../../../components/common/MooTabSegmentV2';

@ComponentV2
struct JavaScriptsPanel {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    MooStringArrayList({
      list: this.mySettings.settingsData[56].value as string[],
      onEdited: (index: number, newValue: string) => {
        const list = this.mySettings.settingsData[56].value as string[];
        list[index] = newValue;
        this.mySettings.requestSaveToDisk();
      },
      onDelete: (index: number) => {
        const list = this.mySettings.settingsData[56].value as string[];
        list.splice(index, 1);
        this.mySettings.requestSaveToDisk();
      },
      onNew: () => {
        const list = this.mySettings.settingsData[56].value as string[];
        list.push('meow.net');
        this.mySettings.requestSaveToDisk();
      }
    })
      .opacity(this.mySettings.settingsData[55].value as boolean ? 0.5 : 1)
      .animation(defaultAnimation())
      .padding(standardSpacing);

  }
}

@CustomDialog
struct WoofJavaScriptsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiStatuses;


  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.JavaScripts'),
      tutorial: $r('app.string.JavaScripts_tutorial')
    }) {
      JavaScriptsPanel();

      if (!this.myLayout.shortMode) {
        MooTabSegmentV2({
          initSelected: AppStorageV2.connect(meowManagedSettings)!.settingsData[55].value as boolean ? 0 : 1,
          items: new SegmentButtonV2Items([{ text: $r('app.string.General_blockAll') }, { text: $r('app.string.General_blockListed') }]),
          onSelected: (index) => {
            // 'top' | 'bottom'
            const mySettings = AppStorageV2.connect(meowManagedSettings)!;
            switch (index) {
              case 0:
                mySettings.setByIndex(55, true);
                break;
              case 1:
                mySettings.setByIndex(55, false);
                break;
              default:
                break;
            }
          }
        })
          .padding({ left: standardSpacing, right: standardSpacing, bottom: standardSpacing });
      }
    };
  }
}

export { WoofJavaScriptsDialog };
