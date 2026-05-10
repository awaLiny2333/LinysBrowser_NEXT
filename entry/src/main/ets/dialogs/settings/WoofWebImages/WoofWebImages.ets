import { SegmentButtonV2Items } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { MooStringArrayList } from '../../../components/common/MooStringArrayList';
import { MooTabSegmentV2, MooTabSegmentV2Height } from '../../../components/common/MooTabSegmentV2';
import { standardSpacing } from '../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../components/settings';
import { disableWebImagesOnAllSites, disableWebImagesSites } from '../../../hosts/app/tabs/settings';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { WoofUniFrame } from '../../WoofUniFrame';

@ComponentV2
struct WebImagesPanel {
  build() {
    MooStringArrayList({
      list: disableWebImagesSites(),
      onEdited: (index: number, newValue: string) => {
        disableWebImagesSites()[index] = newValue;
        getMySettings().requestSaveToDisk();
      },
      onDelete: (index: number) => {
        disableWebImagesSites().splice(index, 1);
        getMySettings().requestSaveToDisk();
      },
      onNew: () => {
        disableWebImagesSites().push('meow.net');
        getMySettings().requestSaveToDisk();
      }
    })
      .opacity(disableWebImagesOnAllSites() ? 0.5 : 1)
      .animation(defaultAnimation())
      .margin({ bottom: MooTabSegmentV2Height + standardSpacing });
  }
}

@CustomDialog
struct WoofWebImagesDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.WebImages'),
      tutorial: $r('app.string.WebImages_tutorial'),
    }) {
      Stack() {
        WebImagesPanel();
        MooTabSegmentV2({
          initSelected: disableWebImagesOnAllSites() ? 0 : 1,
          items: new SegmentButtonV2Items([{ text: $r('app.string.General_blockAll') }, { text: $r('app.string.General_blockListed') }]),
          onSelected: (index) => {
            // 'top' | 'bottom'
            switch (index) {
              case 0:
                getMySettings().setByIndex(58, true);
                break;
              case 1:
                getMySettings().setByIndex(58, false);
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

export { WoofWebImagesDialog };
