import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { UniRowOfCapsuleButtons } from "../../../components/common/UniRowOfCapsuleButtons";
import { standardSpacing, UnifiedButtonsType } from "../../../components/constants";
import { defaultAnimation, getMySettings, isPreferRightHand, meowButtonsAddressBarAlways, meowButtonsAddressBarOnFocus, meowButtonsControl, meowButtonsMore, meowButtonsTitle } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { ButtonSlot } from "./ButtonSlot";

@ComponentV2
struct ButtonsManager {
  @Param @Require controller: CustomDialogController;
  // Temp copies
  @Local tempButtonsControl: UnifiedButtonsType[] = Array.from(meowButtonsControl());
  @Local tempButtonsAddressBarOnFocus: UnifiedButtonsType[] = Array.from(meowButtonsAddressBarOnFocus());
  @Local tempButtonsAddressBar: UnifiedButtonsType[] = Array.from(meowButtonsAddressBarAlways());
  @Local tempButtonsTitle: UnifiedButtonsType[] = Array.from(meowButtonsTitle());
  @Local tempButtonsMore: UnifiedButtonsType[] = Array.from(meowButtonsMore());
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
              getMySettings().setByIndex(76, this.tempButtonsControl);
              getMySettings().setByIndex(77, this.tempButtonsAddressBarOnFocus);
              getMySettings().setByIndex(78, this.tempButtonsAddressBar);
              getMySettings().setByIndex(79, this.tempButtonsTitle);
              getMySettings().setByIndex(80, this.tempButtonsMore);
              // Save
              getMySettings().requestSaveToDisk();
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
    return this.tempButtonsControl.some(button => button === UnifiedButtonsType.SETTINGS) ||
      this.tempButtonsAddressBarOnFocus.some(button => button === UnifiedButtonsType.SETTINGS) ||
      this.tempButtonsAddressBar.some(button => button === UnifiedButtonsType.SETTINGS) ||
      this.tempButtonsTitle.some(button => button === UnifiedButtonsType.SETTINGS) ||
      this.tempButtonsMore.some(button => button === UnifiedButtonsType.SETTINGS);
  }
}

@CustomDialog
struct WoofButtonsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

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
