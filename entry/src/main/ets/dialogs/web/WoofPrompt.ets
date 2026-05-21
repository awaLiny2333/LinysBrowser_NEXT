import { meowLayout } from "../../catstypicalframework/hosts/meowLayout";
import { MooTextInputV2 } from "../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../components/common/MooTextModifier";
import { standardSpacing } from "../../components/constants";
import { meowDialogManager } from "../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../WoofUniFrame";

@ComponentV2
struct WoofPromptPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Info
  @Local data: OnPromptEvent | undefined;

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.data = req.param as OnPromptEvent;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: this.data?.url, myLayout: this.myLayout, myDialog: this.myDialog, shiftBackgroundColor: true,
      showConfirmButton: true, showCancelButton: true, doubleConfirm: true,
      onConfirm: () => {
        this.data?.result.handlePromptConfirm(this.data?.value || '');
        this.controller.close();
      },
      onCancel: () => {
        this.data?.result.handleCancel();
        this.controller.close();
      },
      aboutToClose: () => {
        this.data?.result.handleCancel();
      }
    }) {
      Column({ space: standardSpacing }) {
        Text(this.data?.message).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5);
        MooTextInputV2({
          text: this.data?.value || '',
          onChange: (value) => {
            if (this.data) {
              this.data.value = value;
            }
          },
          onSubmit: () => {
            this.data?.result.handlePromptConfirm(this.data?.value || '');
            this.controller.close();
          }
        });
      }.padding(standardSpacing);
    };
  }
}

@CustomDialog
export struct WoofPromptDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofPromptPanel({ controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog });
  }
}
