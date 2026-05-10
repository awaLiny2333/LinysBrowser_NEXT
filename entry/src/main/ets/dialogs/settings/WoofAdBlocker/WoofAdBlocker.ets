import { SegmentButtonV2Items } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { MooStringArrayList } from '../../../components/common/MooStringArrayList';
import { MooTabSegmentV2, MooTabSegmentV2Height } from '../../../components/common/MooTabSegmentV2';
import { standardSpacing } from '../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../components/settings';
import { adBlockExceptions, useAdBlock } from '../../../hosts/app/tabs/settings';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { WoofUniFrame } from '../../WoofUniFrame';

@ComponentV2
struct AdBlockerPanel {
  build() {
    MooStringArrayList({
      list: adBlockExceptions(),
      onEdited: (index: number, newValue: string) => {
        adBlockExceptions()[index] = newValue;
        getMySettings().requestSaveToDisk();
      },
      onDelete: (index: number) => {
        adBlockExceptions().splice(index, 1);
        getMySettings().requestSaveToDisk();
      },
      onNew: () => {
        adBlockExceptions().push('meow.net');
        getMySettings().requestSaveToDisk();
      }
    })
      .opacity(useAdBlock() ? 1 : 0.5)
      .animation(defaultAnimation())
      .margin({ bottom: MooTabSegmentV2Height + standardSpacing });
  }
}

@CustomDialog
struct WoofAdBlockerDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.AdBlocker'),
      tutorial: $r('app.string.AdBlocker_tutorial'),
    }) {
      Stack() {
        AdBlockerPanel();
        MooTabSegmentV2({
          initSelected: useAdBlock() ? 1 : 0,
          items: new SegmentButtonV2Items([{ text: $r('app.string.General_disabled') }, { text: $r('app.string.General_pardonListed') }]),
          onSelected: (index) => {
            // 'top' | 'bottom'
            switch (index) {
              case 0:
                getMySettings().setByIndex(52, false);
                break;
              case 1:
                getMySettings().setByIndex(52, true);
                break;
              default:
                break;
            }
          }
        });
      }
      .padding(standardSpacing)
      .alignContent(Alignment.Bottom);
    };
  }
}

export { WoofAdBlockerDialog };
