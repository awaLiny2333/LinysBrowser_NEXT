import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow } from "../../../catstypicalframework/utils/catsLogger";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { UniRowOfCapsuleButtons } from "../../../components/common/UniRowOfCapsuleButtons";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { Keyboard } from "./parts/Keyboard";

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
    WoofUniFrame({ controller: this.controller, title: $r('app.string.KeyShortcuts_picker'), myLayout: this.myLayout, myDialog: this.myDialog, shiftBackgroundColor: true }) {
      Scroll() {
        Column({ space: standardSpacing }) {
          Keyboard({
            initialSelected: this.myDialog.lastRequest!.param as string[],
            onKeyChange: (c) => {
              meow(`Keyboard gave ${c}`);
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
}

export { WoofKeyShortcutPickerDialog };
