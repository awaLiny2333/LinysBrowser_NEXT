import { SegmentButtonV2Items } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { MooStringArrayList } from '../../../components/common/MooStringArrayList';
import { MooTabSegmentV2, MooTabSegmentV2Height } from '../../../components/common/MooTabSegmentV2';
import { standardSpacing } from '../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../components/settings';
import lazy { applyAdBlockerExceptions } from '../../../hosts/app/tabs/scripts/adBlocker';
import { adBlockExceptions, useAdBlock } from '../../../hosts/app/tabs/settings';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
export struct WoofAdBlockerDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  domain: string = 'meow.net';

  aboutToAppear(): void {
    // If with params (Opened this when browsing something)
    if (this.myDialog.lastRequest && this.myDialog.lastRequest.param) {
      this.domain = this.myDialog.lastRequest.param as string;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.AdBlocker'),
      tutorial: $r('app.string.AdBlocker_tutorial'),
    }) {
      Stack() {
        MooStringArrayList({
          list: adBlockExceptions(),
          onEdited: (index: number, newValue: string) => {
            adBlockExceptions()[index] = newValue;
            getMySettings().requestSaveToDisk();
            applyAdBlockerExceptions();
          },
          onDelete: (index: number) => {
            adBlockExceptions().splice(index, 1);
            getMySettings().requestSaveToDisk();
            applyAdBlockerExceptions();
          },
          onNew: () => {
            adBlockExceptions().push(this.domain);
            getMySettings().requestSaveToDisk();
            applyAdBlockerExceptions();
          }
        })
          .opacity(useAdBlock() ? 1 : 0.5)
          .animation(defaultAnimation())
          .margin({ bottom: MooTabSegmentV2Height + standardSpacing });

        // Bottom bar
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
