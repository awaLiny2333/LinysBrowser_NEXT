import { meowTabInfo } from "../../../hosts/app/tabs/classes/meowTabInfo";
import { scanBarcode } from "@kit.ScanKit";
import { oopsPreviewActionsText } from "./oopsPreviewActionsText";
import { MooTextButton } from "../../common/MooTextButton";
import { getMyApp } from "../../../hosts/system/windows/scripts/helpers";

@ComponentV2
export struct oopsPreviewQrResults {
  @Param @Require tabInfo: meowTabInfo;
  // Events
  @Event requestCloseMenu: () => void;
  @Event requestVisit: (link: string) => void;
  @Event requestCopy: (link: string) => void;

  build() {
    Column({ space: 5 }) {
      ForEach(this.tabInfo.imageQrResults, ((res: scanBarcode.ScanResult) => {
        MooTextButton({
          text: '󰄨 ' + res.originalValue, maxLines: this.largeSpace ? 8 : 4, clickAction: () => {
            this.requestVisit(res.originalValue);
          }
        });

        oopsPreviewActionsText({
          text: res.originalValue, requestCloseMenu: () => {
            this.requestCloseMenu();
          }, requestVisit: () => {
            this.requestVisit(res.originalValue);
          }
        });
      }));
    }
    .alignItems(HorizontalAlign.Start)
    .padding(5)
    .margin(5)
    // .opacity(0.75)
    .borderRadius(10)
    .backgroundColor($r('sys.color.comp_background_secondary'));
  }

  /**
   * If the window is in free window or wide mode. We would have many space to put more things!
   */
  get largeSpace() {
    return this.tabInfo.myUi.myLayout.wideMode || getMyApp().freeWindow;
  }
}
