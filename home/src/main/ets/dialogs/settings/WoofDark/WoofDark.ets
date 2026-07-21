import { SegmentButtonV2Items } from '@kit.ArkUI';
import { MooStringArrayList } from '../../../components/common/MooStringArrayList';
import { MooTabSegmentV2, MooTabSegmentV2Height } from '../../../components/common/MooTabSegmentV2';
import { standardSpacing } from '../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../components/settings';
import { forceWebDarkExceptions, forceWebDarkMode } from '../../../hosts/app/tabs/settings';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
struct WoofDarkDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;
  domain: string = 'meow.net';

  aboutToAppear(): void {
    // If with params (Opened this when browsing something)
    if (this.myUi.myDialog.lastRequest && this.myUi.myDialog.lastRequest.param) {
      this.domain = this.myUi.myDialog.lastRequest.param as string;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, myUi: this.myUi, shiftBackgroundColor: true,
      title: $r('app.string.Dark'),
      tutorial: $r('app.string.Dark_tutorial'),
    }) {
      Stack() {
        MooStringArrayList({
          list: forceWebDarkExceptions(),
          onEdited: (index: number, newValue: string) => {
            forceWebDarkExceptions()[index] = newValue;
            getMySettings().requestSaveToDisk();
          },
          onDelete: (index: number) => {
            forceWebDarkExceptions().splice(index, 1);
            getMySettings().requestSaveToDisk();
          },
          onNew: () => {
            forceWebDarkExceptions().push(this.domain);
            getMySettings().requestSaveToDisk();
          }
        })
          .opacity(forceWebDarkMode() ? 1 : 0.5)
          .animation(defaultAnimation())
          .margin({ bottom: MooTabSegmentV2Height + standardSpacing });

        MooTabSegmentV2({
          initSelected: forceWebDarkMode() ? 1 : 0,
          items: new SegmentButtonV2Items([{ text: $r('app.string.General_disabled') }, { text: $r('app.string.General_pardonListed') }]),
          onSelected: (index) => {
            // 'top' | 'bottom'
            switch (index) {
              case 0:
                getMySettings().setByIndex(60, false);
                break;
              case 1:
                getMySettings().setByIndex(60, true);
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

export { WoofDarkDialog };
