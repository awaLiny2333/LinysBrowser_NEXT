import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { standardSpacing } from "../../../components/constants";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofAlertPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Info
  @Local data: OnAlertEvent | undefined;

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      this.data = req.param as OnAlertEvent;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: this.data?.url, myUi: this.myUi, showConfirmButton: true,
      onConfirm: () => {
        this.data?.result.handleConfirm();
        this.controller.close();
      },
      aboutToClose: () => {
        this.data?.result.handleCancel();
      }
    }) {
      Text(this.data?.message).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 1.5);
    };
  }
}

@CustomDialog
export struct WoofAlertDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofAlertPanel({ controller: this.controller, myUi: this.myUi });
  }
}
