import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { resource2String } from "../../../catstypicalframework/utils/resource";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { UniRowOfCapsuleButtons } from "../../../components/common/UniRowOfCapsuleButtons";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { Keyboard } from "./parts/Keyboard";
import { Context } from "@ohos.abilityAccessCtrl";

@CustomDialog
struct WoofKeyShortcutPickerDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  selected: string[] = [];
  onConfirm: (bind: string[]) => void = () => {
    // Do nothing by default;
  };

  build() {
    WoofUniFrame({ controller: this.controller, title: this.getTitle(), myLayout: this.myLayout, myDialog: this.myDialog, shiftBackgroundColor: true }) {
      Scroll() {
        Column({ space: standardSpacing }) {
          Keyboard({
            initialSelected: (this.myDialog.lastRequest!.param as object[])[1] as string[], // How ugly
            onKeyChange: (c) => {
              // meow(`Keyboard gave ${c}`);
              this.selected = c;
            }
          });

          // Control buttons
          UniRowOfCapsuleButtons() {
            MooCapsuleButton({
              text: $r('app.string.General_cancel'),
              clickAction: () => {
                this.controller.close();
              }
            });
            MooCapsuleButton({
              text: $r('app.string.General_confirm'),
              clickAction: () => {
                this.onConfirm(this.selected);
                this.controller.close();
              }
            });
          };
        }
        .width('100%')
        .padding(standardSpacing);
      }
      .height('auto')
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring);
    };
  }

  getTitle() {
    const context: Context = this.getUIContext().getHostContext()!;
    // const dialogTitle = resource2String($r('app.string.KeyShortcuts_picker'), this.context);
    const shortcutName = resource2String((this.myDialog.lastRequest!.param as object[])[0] as ResourceStr as Resource, context);
    return `${shortcutName}`;
  }
}

export { WoofKeyShortcutPickerDialog };
