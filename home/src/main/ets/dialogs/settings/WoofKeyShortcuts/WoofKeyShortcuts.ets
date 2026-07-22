import { AppStorageV2 } from "@kit.ArkUI";
import { meow } from "../../../catstypicalframework/utils/catsLogger";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing } from "../../../components/constants";
import { openDialogRequestType } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../hosts/system/dialogs/scripts/dialog";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { meowKeyboardMan } from "../../../hosts/userdata/keyshortcuts/classes/meowKeyboardMan";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct KeyShortcutsPanel {
  @Require @Param myUi: meowUiHost;
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
                  requestDialog(this.myUi.myDialog, openDialogRequestType.KEY_SHORTCUTS_PICKER, [this.myKey.shortcutsStrings[item.index], item.item.toArray()], true);
                }
              }) {
                Row() {
                  Text(this.myKey.shortcutsStrings[item.index]).attributeModifier(new MooTextModifier()).layoutWeight(1);
                  Text(item.item.toResourceStr()).attributeModifier(new MooTextModifier()).opacity(0.75);
                  Text('  󰁫').attributeModifier(new MooTextModifier());
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
      const newBind = this.myUi.localMessageTunnel?.payload as string[];
      if (newBind.length == 0 || this.lastListenerIndex < 0) {
        meow(`No key shortcut picked or no changes made.`, 'WoofKeyShortcuts');
        return;
      }
      meow(`Key shortcut picked: ${newBind} for #${this.lastListenerIndex}`, 'WoofKeyShortcuts');
      // Apply!
      this.myKey.apply(this.lastListenerIndex, newBind);
    }
  }
}

@CustomDialog
struct WoofKeyShortcutsDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({
      controller: this.controller, myUi: this.myUi,
      title: $r('app.string.KeyShortcuts'),
    }) {
      KeyShortcutsPanel({ myUi: this.myUi });
    };
  }
}

export { WoofKeyShortcutsDialog };
