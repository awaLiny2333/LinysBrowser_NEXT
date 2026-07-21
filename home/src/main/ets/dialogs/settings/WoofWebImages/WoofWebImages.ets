import { SegmentButtonV2Items } from '@kit.ArkUI';
import { MooStringArrayList } from '../../../components/common/MooStringArrayList';
import { MooTabSegmentV2, MooTabSegmentV2Height } from '../../../components/common/MooTabSegmentV2';
import { standardSpacing } from '../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../components/settings';
import { disableWebImagesOnAllSites, disableWebImagesSites } from '../../../hosts/app/tabs/settings';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
struct WoofWebImagesDialog {
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
      title: $r('app.string.WebImages'),
      tutorial: $r('app.string.WebImages_tutorial'),
    }) {
      Stack() {
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
            disableWebImagesSites().push(this.domain);
            getMySettings().requestSaveToDisk();
          }
        })
          .opacity(disableWebImagesOnAllSites() ? 0.5 : 1)
          .animation(defaultAnimation())
          .margin({ bottom: MooTabSegmentV2Height + standardSpacing });

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
