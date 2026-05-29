import { defaultRoundedRadius } from "../../catstypicalframework/utils/ui";
import { fontSizeSymbol, meowThemeColorType, mooTextType, standardSpacing } from "../constants";
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from "../settings";
import { MooTextModifier } from "./MooTextModifier";

/**
 * Container for displaying content with a title (optional) and rounded corners (defaultRoundedRadius).
 */
// @ReusableV2
@ComponentV2
struct UniContentCard {
  @BuilderParam contentsBuilder: () => void;
  // Settings
  @Param title: ResourceStr = '';
  @Param icon: Resource = $r('sys.symbol.gearshape');
  @Param @Once roundedRadius: number = defaultRoundedRadius;
  @Param @Once space: number = standardSpacing;
  // UI
  @Param @Once expanded: boolean = this.title ? false : true;
  @Param shiftBackgroundColor: boolean = false;
  @Local isHover: boolean = false;
  // Events
  @Event clickAction: () => void;

  build() {
    Column({ space: this.space }) {
      if (this.title) {
        Row({ space: standardSpacing }) {
          SymbolGlyph(this.icon)
            .fontSize(fontSizeSymbol)
            .fontColor([getColor(meowThemeColorType.FONT)])
            .opacity(0.75);
          Text(this.title)
            .layoutWeight(1)
            .attributeModifier(new MooTextModifier(mooTextType.TITLE))
            .opacity(0.75);
        }.width('100%');
      }

      if (this.expanded) {
        this.contentsBuilder();
      }
    }
    .brightness(this.isHover ? (this.expanded ? 1.02 : 1.05) : 1)
    .animation(defaultAnimation())
    .width('100%')
    .backgroundColor(this.shiftBackgroundColor ? getColor(meowThemeColorType.SECONDARY) : getColor(meowThemeColorType.PRIMARY))
    .border({ radius: this.roundedRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
    .padding(standardSpacing * 1.25)
    .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
    .onHover((isHover) => {
      if (isHover != this.isHover) {
        this.isHover = isHover;
      }
    })
    .onClick(() => {
      if (this.title) {
        animateToImmediately(defaultAnimation(), () => {
          this.expanded = !this.expanded;
        });
      }
      this.clickAction();
    });
  }
}

export { UniContentCard };
