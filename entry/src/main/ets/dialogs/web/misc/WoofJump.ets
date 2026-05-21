import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { jumpUrl } from "../../../catstypicalframework/utils/url";
import { MooTextAreaV2 } from "../../../components/common/MooTextAreaV2";
import { standardSpacing } from "../../../components/constants";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { common } from "@kit.AbilityKit";

@ComponentV2
struct WoofJumpPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Info
  @Local source: string = '';
  @Local url: string = '';

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.source = (req.param as [string, string])[0];
      this.url = (req.param as [string, string])[1];
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.Jump_title'), myLayout: this.myLayout, myDialog: this.myDialog, showConfirmButton: true, showCancelButton: true, shiftBackgroundColor: true,
      onConfirm: () => {
        jumpUrl(this.url,this.getUIContext().getHostContext()! as common.UIAbilityContext)
        this.controller.close();
      },
      onCancel: () => {
        this.controller.close();
      }
    }) {
      MooTextAreaV2({
        text: this.url,
        onChange: (value: string) => {
          this.url = value;
        }
      })
        .padding(standardSpacing);
    };
  }
}

@CustomDialog
export struct WoofJumpDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofJumpPanel({ controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog });
  }
}
