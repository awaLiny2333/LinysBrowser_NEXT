import { meowLayout } from "../../catstypicalframework/hosts/meowLayout";
import { MooTextModifier } from "../../components/common/MooTextModifier";
import { standardSpacing } from "../../components/constants";
import { meowDialogManager } from "../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../WoofUniFrame";

@ComponentV2
struct WoofAlertPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Info
  @Local data: OnAlertEvent | undefined;

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.data = req.param as OnAlertEvent;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: this.data?.url, myLayout: this.myLayout, myDialog: this.myDialog, showConfirmButton: true,
      onConfirm: () => {
        this.data?.result.handleConfirm();
        this.controller.close();
      },
      aboutToClose: () => {
        this.data?.result.handleCancel();
      }
    }) {
      Text(this.data?.message).attributeModifier(new MooTextModifier()).width('100%')
        .padding(standardSpacing * 1.5);
    };
  }
}

@CustomDialog
export struct WoofAlertDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofAlertPanel({ controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog });
  }
}
