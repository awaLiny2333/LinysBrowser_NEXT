import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { UniRowOfCapsuleButtons } from "../../../components/common/UniRowOfCapsuleButtons";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { defaultAnimation, isPreferRightHand, standardSpacing } from "../../../components/settings";
import { ButtonSlot } from "./WoofButtonSlot";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { AppStorageV2 } from "@kit.ArkUI";
import { meowButtons } from "../../../components/common/MeowButtons";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../components/common/MooTextModifier";

@ComponentV2
struct ButtonsManager {
  @Param @Require controller: CustomDialogController;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  // Temp copies
  @Local tempButtonsControl: meowButtons[] = Array.from(this.mySettings.settingsData[76].value as meowButtons[]);
  @Local tempButtonsAddressBarOnFocus: meowButtons[] = Array.from(this.mySettings.settingsData[77].value as meowButtons[]);
  @Local tempButtonsAddressBar: meowButtons[] = Array.from(this.mySettings.settingsData[78].value as meowButtons[]);
  @Local tempButtonsTitle: meowButtons[] = Array.from(this.mySettings.settingsData[79].value as meowButtons[]);
  @Local tempButtonsMore: meowButtons[] = Array.from(this.mySettings.settingsData[80].value as meowButtons[]);
  // Local
  @Local showNotice: boolean = false;

  build() {
    Column({ space: standardSpacing }) {
      ButtonSlot({
        buttons: this.tempButtonsControl, // Copy one
        desc: $r('app.string.Buttons_control'),
      });
      ButtonSlot({
        buttons: this.tempButtonsAddressBarOnFocus,
        desc: $r('app.string.Buttons_addressBarOnFocus'),
      });
      ButtonSlot({
        buttons: this.tempButtonsAddressBar,
        desc: $r('app.string.Buttons_addressBar'),
      });
      ButtonSlot({
        buttons: this.tempButtonsTitle,
        desc: $r('app.string.Buttons_title'),
      });
      ButtonSlot({
        buttons: this.tempButtonsMore,
        desc: $r('app.string.Buttons_more'),
      });

      if (this.showNotice) {
        UniContentCard({ roundedRadius: defaultInnerRadius }) {
          Text($r('app.string.Buttons_notice')).attributeModifier(new MooTextModifier()).width('100%');
        };
      }

      // Control buttons
      UniRowOfCapsuleButtons() {
        MooCapsuleButton({
          text: $r('app.string.General_cancel'),
          clickAction: () => {
            // Bye
            this.controller.close();
          }
        });
        MooCapsuleButton({
          text: $r('app.string.General_confirm'),
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.showNotice = false;
            });
            // Confirm
            if (this.verifyLegal()) {
              // Fill the data
              this.mySettings.settingsData[76].value = this.tempButtonsControl;
              this.mySettings.settingsData[77].value = this.tempButtonsAddressBarOnFocus;
              this.mySettings.settingsData[78].value = this.tempButtonsAddressBar;
              this.mySettings.settingsData[79].value = this.tempButtonsTitle;
              this.mySettings.settingsData[80].value = this.tempButtonsMore;
              // Save
              this.mySettings.requestSaveToDisk();
              this.controller.close();
            } else {
              // Show notice.
              setTimeout(() => {
                animateToImmediately(defaultAnimation(), () => {
                  this.showNotice = true;
                });
              }, 100);
            }
          }
        });
      };
    }
    .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
    .width('100%')
    .padding(standardSpacing);
  }

  /**
   * Returns true if there is at least ONE meowButtons.SETTINGS item in any of the temp lists.
   * @returns ...
   * @author CodeGenie in DevEco Studio Preview 6.0.5.433 @ Apr 26 2026.
   */
  verifyLegal(): boolean {
    return this.tempButtonsControl.some(button => button === meowButtons.SETTINGS) ||
      this.tempButtonsAddressBarOnFocus.some(button => button === meowButtons.SETTINGS) ||
      this.tempButtonsAddressBar.some(button => button === meowButtons.SETTINGS) ||
      this.tempButtonsTitle.some(button => button === meowButtons.SETTINGS) ||
      this.tempButtonsMore.some(button => button === meowButtons.SETTINGS);
  }
}

@CustomDialog
struct WoofButtonsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  // Params

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.Buttons'),
    }) {
      Scroll() {
        ButtonsManager({ controller: this.controller });
      }
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring);
    };
  }
}

export { WoofButtonsDialog };
