import lazy { common } from "@kit.AbilityKit";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { makeFilenameLegal } from "../../../../catstypicalframework/utils/storage";
import { defaultInnerRadius, wideModeThreshold } from "../../../../catstypicalframework/utils/ui";
import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { newWindow } from "../../../../hosts/system/windows/scripts/multiwindows";
import { MooSymbolButton } from "../../../common/MooSymbolButton";
import { MooTextButton } from "../../../common/MooTextButton";
import lazy { MooTextInputV2 } from "../../../common/MooTextInputV2";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { meowThemeColorType, standardSpacing } from "../../../constants";
import { defaultAnimation, getColor, isPreferRightHand, getMySettings, useEffects } from "../../../settings";

@ComponentV2
struct MeowWindowInfoBar {
  @Param @Require myUi: meowUiHost;
  // Local
  @Local isEditing: boolean = false;
  @Local windowAliasEditing: string = this.myUi.windowAlias;
  searchInputId: string = `MeowWindowInfoBar_search_${Date.now().toString(16)}`;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      Row({ space: standardSpacing * 0.125 }) {
        MooTextButton({
          radius: defaultInnerRadius,
          text: `󰁫  ${this.myUi.windowAlias}`,
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.isEditing = !this.isEditing;
            });
          }
        });

        MooSymbolButton({
          icon: $r('sys.symbol.plus'),
          clickAction: () => {
            // New window
            newWindow(this.getUIContext().getHostContext() as common.UIAbilityContext);
          }
        });
      }
      .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);

      if (this.isEditing) {
        MooTextInputV2({
          icon: $r('sys.symbol.rename'),
          text: this.windowAliasEditing,
          myId: this.searchInputId,
          onChange: (value: string) => {
            this.windowAliasEditing = value;
          },
          onSubmit: () => {
            const finalName = makeFilenameLegal(this.windowAliasEditing, '');
            this.windowAliasEditing = finalName;
            this.myUi.setWindowAlias(finalName);
            animateToImmediately(defaultAnimation(), () => {
              this.isEditing = false;
            });
            getMySettings().setByIndex(26, finalName);
          }
        })
          .onAppear(() => {
            this.focusInput();
          });

        // Notice about illegal chars
        Text($r('app.string.WindowAlias_illegalChars')).attributeModifier(new MooTextModifier()).padding(standardSpacing * 0.5);
      }
    }
    .constraintSize({ maxWidth: wideModeThreshold })
    .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
    .padding(this.mySpacing())
    .borderRadius(defaultInnerRadius + (this.isEditing ? standardSpacing * 0.5 : standardSpacing * 0.3))
    .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth') } : { width: 0 })
    .backgroundColor(getColor(meowThemeColorType.PRIMARY));
  }

  mySpacing() {
    return this.isEditing ? standardSpacing * 0.75 : standardSpacing * 0.5;
  }

  /**
   * Focus input!
   */
  focusInput() {
    try {
      this.getUIContext().getFocusController().requestFocus(this.searchInputId);
    } catch (e) {
      meow(`this.getUIContext().getFocusController().requestFocus("${this.searchInputId}"); failed: ${e}`, 'MeowWindowInfoBar', meowLevel.ERROR);
    }
  }
}

export { MeowWindowInfoBar };
