import { SegmentButtonV2Items } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { MooStringArrayList } from '../../../components/common/MooStringArrayList';
import { MooTabSegmentV2, MooTabSegmentV2Height } from '../../../components/common/MooTabSegmentV2';
import { standardSpacing } from '../../../components/constants';
import { defaultAnimation, getMySettings } from '../../../components/settings';
import { disableWebJavaScriptSites, disableWebJavaScriptsOnAllSites } from '../../../hosts/app/tabs/settings';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { WoofUniFrame } from '../../WoofUniFrame';

@CustomDialog
struct WoofJavaScriptsDialog {
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
      title: $r('app.string.JavaScripts'),
      tutorial: $r('app.string.JavaScripts_tutorial')
    }) {
      Stack() {
        MooStringArrayList({
          list: disableWebJavaScriptSites(),
          onEdited: (index: number, newValue: string) => {
            disableWebJavaScriptSites()[index] = newValue;
            getMySettings().requestSaveToDisk();
          },
          onDelete: (index: number) => {
            disableWebJavaScriptSites().splice(index, 1);
            getMySettings().requestSaveToDisk();
          },
          onNew: () => {
            disableWebJavaScriptSites().push(this.domain);
            getMySettings().requestSaveToDisk();
          }
        })
          .opacity(disableWebJavaScriptsOnAllSites() ? 0.5 : 1)
          .animation(defaultAnimation())
          .margin({ bottom: MooTabSegmentV2Height + standardSpacing });
        
        MooTabSegmentV2({
          initSelected: disableWebJavaScriptsOnAllSites() ? 0 : 1,
          items: new SegmentButtonV2Items([{ text: $r('app.string.General_blockAll') }, { text: $r('app.string.General_blockListed') }]),
          onSelected: (index) => {
            // 'top' | 'bottom'
            switch (index) {
              case 0:
                getMySettings().setByIndex(55, true);
                break;
              case 1:
                getMySettings().setByIndex(55, false);
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

export { WoofJavaScriptsDialog };
