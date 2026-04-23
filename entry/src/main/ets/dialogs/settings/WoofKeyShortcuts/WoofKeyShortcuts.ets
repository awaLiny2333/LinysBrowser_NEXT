import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meow } from "../../../catstypicalframework/utils/catsLogger";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager, openDialogRequestType } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../hosts/system/dialogs/scripts/dialog";
import { meowUiStatuses } from "../../../hosts/system/windows/classes/meowUiStatuses";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { meowKeyboardMan } from "../../../hosts/userdata/keyshortcuts/classes/meowKeyboardMan";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct KeyShortcutsPanel {
  @Require @Param myDialog: meowDialogManager;
  @Require @Param myUi: meowUiStatuses;
  @Local myKey: meowKeyboardMan = AppStorageV2.connect(meowKeyboardMan)!;
  @Local lastListenerIndex: number = -1;

  build() {
    Scroll() {
      List({ space: standardSpacing * 0.75 }) {
        Repeat(this.myKey.shortcuts)
          .each((item) => {
            ListItem() {
              UniContentCard({
                roundedRadius: defaultInnerRadius, clickAction: () => {
                  this.lastListenerIndex = item.index;
                  requestDialog(this.myDialog, openDialogRequestType.KEY_SHORTCUTS_PICKER, item.item.toArray(), true);
                }
              }) {
                Row() {
                  Text(this.myKey.shortcutsStrings[item.index]).attributeModifier(new MooTextModifier()).layoutWeight(1);
                  Text(item.item.toString() + '  󰁫').attributeModifier(new MooTextModifier()).opacity(0.75);
                };
              };
            };
          });
      }
      .width('auto')
      .height('auto');
    }
    .edgeEffect(EdgeEffect.Spring)
    .padding(standardSpacing);
  }

  /**
   * Listener for picker return.
   */
  @Monitor('myUi.localMessageTunnel')
  receiveMessage() {
    if (this.myUi.localMessageTunnel?.type == meowAppMessageType.KEY_SHORTCUTS_PICKED) {
      this.myKey.shortcuts[this.lastListenerIndex].fromArray(this.myUi.localMessageTunnel?.payload as string[]);
      meow(`Key shortcut picked: ${this.myKey.shortcuts[this.lastListenerIndex].toString()} for #${this.lastListenerIndex}`);
      this.myKey.saveToSettings();
    }
  }
}

@CustomDialog
struct WoofKeyShortcutsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myUi: meowUiStatuses;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout,
      title: $r('app.string.KeyShortcuts'),
    }) {
      KeyShortcutsPanel({ myDialog: this.myDialog, myUi: this.myUi });
    };
  }
}

export { WoofKeyShortcutsDialog };
