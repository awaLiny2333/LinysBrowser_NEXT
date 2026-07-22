import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing } from "../../../components/constants";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofRequestScreenCapturePanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Info
  @Local data: OnScreenCaptureRequestEvent | undefined;
  @Local alreadyResolved: boolean = false;

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      this.data = req.param as OnScreenCaptureRequestEvent;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.ScreenCapture_title'), myUi: this.myUi,
      showConfirmButton: true, showCancelButton: true, doubleConfirm: true,
      onConfirm: () => {
        this.data?.handler.grant({ captureMode: WebCaptureMode.HOME_SCREEN });
        this.alreadyResolved = true;
        this.controller.close();
      },
      onCancel: () => {
        this.data?.handler.deny();
        this.alreadyResolved = true;
        this.controller.close();
      },
      aboutToClose: () => {
        if (this.alreadyResolved) return;
        this.data?.handler.deny();
      }
    }) {
      Column() {
        UniContentCard({ roundedRadius: defaultInnerRadius }) {
          Text(`󰕝  ${this.data?.handler.getOrigin()}`).attributeModifier(new MooTextModifier()).width('100%');
        };
      }.padding(standardSpacing);
    };
  }
}

@CustomDialog
export struct WoofRequestScreenCaptureDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofRequestScreenCapturePanel({ controller: this.controller, myUi: this.myUi });
  }
}
