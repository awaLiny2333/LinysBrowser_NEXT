import { meowLayout } from "../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../components/common/MooTextModifier";
import { UniContentCard } from "../../components/common/UniContentCard";
import { standardSpacing } from "../../components/constants";
import { meowDialogManager } from "../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../WoofUniFrame";

@ComponentV2
struct WoofRequestScreenCapturePanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Info
  @Local data: OnScreenCaptureRequestEvent | undefined;

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.data = req.param as OnScreenCaptureRequestEvent;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.ScreenCapture_title'), myLayout: this.myLayout, myDialog: this.myDialog,
      showConfirmButton: true, showCancelButton: true, doubleConfirm: true,
      onConfirm: () => {
        this.data?.handler.grant({ captureMode: WebCaptureMode.HOME_SCREEN });
        this.controller.close();
      },
      onCancel: () => {
        this.data?.handler.deny();
        this.controller.close();
      },
      aboutToClose: () => {
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
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofRequestScreenCapturePanel({ controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog });
  }
}
