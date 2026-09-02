import { common } from "@kit.AbilityKit";
import { jumpExternalUri } from "../../../catstypicalframework/utils/url";
import { MooTextAreaV2 } from "../../../components/common/MooTextAreaV2";
import { standardSpacing } from "../../../components/constants";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofJumpPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Info
  @Local source: string = '';
  @Local uri: string = '';

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      this.source = (req.param as [string, string])[0];
      this.uri = (req.param as [string, string])[1];
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.Jump_title'), myUi: this.myUi, showConfirmButton: true, showCancelButton: true, shiftBackgroundColor: true,
      onConfirm: () => {
        jumpExternalUri(this.uri, this.getUIContext().getHostContext()! as common.UIAbilityContext);
        this.controller.close();
      },
      onCancel: () => {
        this.controller.close();
      }
    }) {
      // Column({ space: standardSpacing }) {
      MooTextAreaV2({
        text: this.uri,
        onChange: (value: string) => {
          this.uri = value;
        }
      })
        // MooCapsuleButton({
        //   text: $r('app.string.General_copyLink'),
        //   clickAction: () => {
        //     copyText(this.uri);
        //   }
        // });
        // }
        .padding(standardSpacing);
    };
  }
}

@CustomDialog
export struct WoofJumpDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofJumpPanel({ controller: this.controller, myUi: this.myUi });
  }
}
