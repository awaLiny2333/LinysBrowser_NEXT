import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { MooTextInputV2 } from "../../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { standardSpacing } from "../../../components/constants";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofHttpAuthPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Info
  @Local data: OnHttpAuthRequestEvent | undefined;
  @Local username: string = '';
  @Local password: string = '';
  // UI
  usernameInputId: string = `WoofHttpAuthPanel_username_${Date.now().toString(16)}`;
  passwordInputId: string = `WoofHttpAuthPanel_password_${Date.now().toString(16)}`;

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.data = req.param as OnHttpAuthRequestEvent;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.HttpAuth_title'), myLayout: this.myLayout, myDialog: this.myDialog, shiftBackgroundColor: true,
      showConfirmButton: true, showCancelButton: true,
      onConfirm: () => {
        this.confirm();
      },
      onCancel: () => {
        this.data?.handler.cancel();
        this.controller.close();
      },
      aboutToClose: () => {
        this.data?.handler.cancel();
      }
    }) {
      Column({ space: standardSpacing }) {
        Text(`Host: ${this.data?.host}`).attributeModifier(new MooTextModifier()).width('100%').padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 });
        Text(`Realm: ${this.data?.host}`).attributeModifier(new MooTextModifier()).width('100%').padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 });
        MooTextInputV2({
          type: InputType.USER_NAME,
          text: this.username,
          myId: this.usernameInputId,
          placeholder: $r('app.string.General_username'),
          onChange: (value) => {
            if (this.data) {
              this.username = value;
            }
          },
          onSubmit: () => {
            focusControl.requestFocus(this.passwordInputId);
          }
        });
        MooTextInputV2({
          type: InputType.Password,
          text: this.password,
          myId: this.passwordInputId,
          placeholder: $r('app.string.General_password'),
          onChange: (value) => {
            if (this.data) {
              this.password = value;
            }
          },
          onSubmit: () => {
            this.confirm();
          }
        });
      }
      .padding(standardSpacing)
      .onAppear(() => {
        focusControl.requestFocus(this.usernameInputId);
      });
    };
  }

  confirm() {
    this.data?.handler.confirm(this.username, this.password);
    this.controller.close();
  }
}

@CustomDialog
export struct WoofHttpAuthDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofHttpAuthPanel({ controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog });
  }
}
