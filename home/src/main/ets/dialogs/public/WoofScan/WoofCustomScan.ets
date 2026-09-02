import { copyText } from "../../../catstypicalframework/utils/clipboard";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { isLegalUrl } from "../../../catstypicalframework/utils/url";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { meowThemeColorType, standardSpacing } from "../../../components/constants";
import { getColor, isPreferRightHand, useEffects } from "../../../components/settings";
import { openDialogRequestType } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../hosts/system/dialogs/scripts/dialog";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofCustomScan {
  @Param @Require myUi: meowUiHost;
  // Local
  @Local scanResults: string[] = ['huawei.com', 'fox', 'afhjskdfhadljakfj;khgafhnflkkas;hhlgfla;efhewofinawupe;anf;ioaweehgowegheihglsagnheao;fjheilufbe'];

  build() {
    Scroll() {
      Column({ space: this.myUi.myLayout.shortMode ? standardSpacing * 0.25 : standardSpacing }) {
        // Components...
        Column()
          .aspectRatio(1)
          .width('100%')
          .padding(standardSpacing * 0.85)
          .backgroundColor(getColor(meowThemeColorType.PRIMARY))
          .border({ radius: defaultInnerRadius + standardSpacing * 0.25, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
          .alignItems(HorizontalAlign.Start);

        // URLs scanned
        Repeat(this.scanResults)
          .each((i) => {
            Text(i.item)
              .attributeModifier(new MooTextModifier())
              .hoverEffect(HoverEffect.Highlight)
              .padding(standardSpacing)
              .backgroundColor(getColor(meowThemeColorType.PRIMARY))
              .border({ radius: defaultInnerRadius + standardSpacing * 0.25, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
              .onClick(() => {
                if (isLegalUrl(i.item)[0]) {
                  this.myUi.openUrlAuto(i.item);
                  this.myUi.myDialog.closeAll();
                } else {
                  copyText(i.item);
                }
              });
          });
      }
      .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
      .width('100%')
      .padding(standardSpacing);
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Vertical);
  }
}

@CustomDialog
struct WoofCustomScanDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.QR_scan'), myUi: this.myUi }) {
      WoofCustomScan({ myUi: this.myUi });
    };
  }
}

export { WoofCustomScanDialog };

/**
 * Scans using the custom dialog interface.
 */
export function scanCustom(myUi: meowUiHost) {
  // Calls the dialog.
  requestDialog(myUi.myDialog, openDialogRequestType.SCAN, undefined, true);
}
