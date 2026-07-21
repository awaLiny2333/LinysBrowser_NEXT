import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing, UnifiedButtonsType } from "../../../components/constants";
import { defaultAnimation, getMySettings, isPreferRightHand, meowButtonsAddressBarAlways, meowButtonsAddressBarOnFocus, meowButtonsControl, meowButtonsMore, meowButtonsTitle } from "../../../components/settings";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";
import { ButtonSlot } from "./ButtonSlot";

@ComponentV2
struct ButtonsManager {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Temp copies
  @Local tempButtonsControl: UnifiedButtonsType[] = Array.from(meowButtonsControl());
  @Local tempButtonsAddressBarOnFocus: UnifiedButtonsType[] = Array.from(meowButtonsAddressBarOnFocus());
  @Local tempButtonsAddressBar: UnifiedButtonsType[] = Array.from(meowButtonsAddressBarAlways());
  @Local tempButtonsTitle: UnifiedButtonsType[] = Array.from(meowButtonsTitle());
  @Local tempButtonsMore: UnifiedButtonsType[] = Array.from(meowButtonsMore());
  // Local
  @Local showNotice: boolean = false;

  build() {
    WoofUniFrame({
      controller: this.controller, myUi: this.myUi, shiftBackgroundColor: true,
      title: $r('app.string.Buttons'),
      showConfirmButton: true, showCancelButton: true,
      onConfirm: () => {
        this.confirm();
      },
      onCancel: () => {
        this.cancel();
      }
    }) {
      Scroll() {
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
        }
        .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
        .width('100%')
        .padding(standardSpacing);
      }
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring);
    };
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

  cancel() {
    // Bye
    this.controller.close();
  }

  confirm() {
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
}

@CustomDialog
struct WoofButtonsDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    ButtonsManager({ controller: this.controller, myUi: this.myUi });
  }
}

export { WoofButtonsDialog };
