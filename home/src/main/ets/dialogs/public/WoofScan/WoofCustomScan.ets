import { common } from "@kit.AbilityKit";
import { customScan, scanBarcode, scanCore } from "@kit.ScanKit";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { copyText } from "../../../catstypicalframework/utils/clipboard";
import { requestUserPermission } from "../../../catstypicalframework/utils/permission";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { isLegalUrl } from "../../../catstypicalframework/utils/url";
import { MooSymbolButton } from "../../../components/common/MooSymbolButton";
import { MooSymbolButtonMeow } from "../../../components/common/MooSymbolButtonMeow";
import { MooSymbolButtonSmall } from "../../../components/common/MooSymbolButtonSmall";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { meowFlexOptions, meowThemeColorType, standardSpacing } from "../../../components/constants";
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from "../../../components/settings";
import { openDialogRequestType } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../hosts/system/dialogs/scripts/dialog";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { getCreateMyApp } from "../../../hosts/system/windows/scripts/helpers";
import { WoofUniFrame } from "../../WoofUniFrame";
import { LengthMetrics } from "@kit.ArkUI";

@ComponentV2
struct WoofCustomScan {
  @Param @Require myUi: meowUiHost;
  // Local
  @Local scanResults: string[] = [];
  @Local scanFinished: boolean = false;
  // XCom
  private mXComponentController: XComponentController = new XComponentController();

  aboutToAppear(): void {
    getCreateMyApp().isCustomScanning = true;
  }

  aboutToDisappear(): void {
    // Stop and release the camera stream.
    try {
      customScan.stop();
      customScan.release();
    } catch (e) {
      meow(`Failed to stop/release customScan: ${e}`, 'WoofCustomScan', meowLevel.ERROR);
    }
    getCreateMyApp().isCustomScanning = false;
  }

  build() {
    Scroll() {
      Column({ space: this.myUi.myLayout.shortMode ? standardSpacing * 0.25 : standardSpacing }) {
        // Camera preview
        Stack() {
          XComponent({
            id: 'customScanSurface',
            type: XComponentType.SURFACE,
            controller: this.mXComponentController
          })
            .aspectRatio(1)
            .onLoad(async () => {
              // Ask for camera permission first, then init and start the camera stream for scanning.
              await requestUserPermission(this.getUIContext().getHostContext() as common.UIAbilityContext, ['ohos.permission.CAMERA']);
              customScan.init({ scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true });
              // The viewfinder renders at 80vw; hand the same size to the view control so the picture is not stretched.
              const viewFinderSize = Math.max(200, Math.round(this.myUi.myLayout.width));
              customScan.start({
                width: viewFinderSize,
                height: viewFinderSize,
                surfaceId: this.mXComponentController.getXComponentSurfaceId()
              }, (err: BusinessError, results: Array<scanBarcode.ScanResult>) => {
                // Error
                if (err) {
                  meow(`Failed to start customScan: ${err.code} ${err.message}`, 'WoofCustomScan', meowLevel.ERROR);
                  return;
                }
                // Collect scan results.
                animateToImmediately(defaultAnimation(), () => {
                  this.scanFinished = true;
                  for (const r of results) {
                    this.scanResults.push(r.originalValue);
                  }
                });
                meow(`Scan finished!`, 'WoofCustomScan');
              });
            });

          if (this.scanFinished) {
            Row()
              .width('100%')
              .height('100%')
              .brightness(0.75);
            MooSymbolButton({
              icon: $r('sys.symbol.arrow_counterclockwise'),
              clickAction: () => {
                this.rescan();
              }
            })
              .scale({ x: 2, y: 2 });
          }
        }
        .width('100%')
        .aspectRatio(1)
        .clip(true)
        .opacity(this.scanFinished ? 0.9 : 1)
        .hoverEffect(this.scanFinished ? HoverEffect.Highlight : HoverEffect.None)
        .border({ radius: defaultInnerRadius + standardSpacing * 0.25, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
        .onClick(() => {
          this.rescan();
        })
        .grayscale(this.scanFinished ? 1 : 0);

        // URLs scanned
        Repeat(this.scanResults)
          .each((i) => {
            Column({ space: standardSpacing }) {
              Text(i.item).attributeModifier(new MooTextModifier());
              Row() {
                MooSymbolButton({
                  icon: $r('sys.symbol.arrow_up_right'),
                  clickAction: () => {
                    this.myUi.openUrlAuto(i.item);
                    this.myUi.myDialog.closeAll();
                  }
                });
                MooSymbolButtonMeow({
                  icon: $r('sys.symbol.plus_square_on_square'),
                  clickAction: () => {
                    copyText(i.item); // Copy
                  }
                });
              };
            }
            .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
            .padding(standardSpacing)
            .backgroundColor(getColor(meowThemeColorType.PRIMARY))
            .border({ radius: defaultInnerRadius + standardSpacing * 0.25, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') });
          });
      }
      .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
      .width('100%')
      .padding(standardSpacing);
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Vertical);
  }

  rescan() {
    if (this.scanFinished) {
      try {
        customScan.rescan();
        animateToImmediately(defaultAnimation(), () => {
          this.scanFinished = false;
        });
      } catch (err) {
        meow(`Failed to rescan: ${err.code} ${err.message}`, 'WoofCustomScan', meowLevel.ERROR);
      }
    }
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
  if (getCreateMyApp().isCustomScanning) {
    return;
  }
  // Calls the dialog.
  requestDialog(myUi.myDialog, openDialogRequestType.SCAN, undefined, true);
}
