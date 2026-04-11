import { defaultRoundedRadius } from "../../catstypicalframework/utils/ui";
import { defaultAnimation, fontSizeSymbol, getColor, meowThemeColorType, mooTextType, standardSpacing, useEffects } from "./constants";
import { MooTextModifier } from "./MooTextModifier";

/**
 * Container for displaying content with a title (optional) and rounded corners (defaultRoundedRadius).
 */
@ComponentV2
struct UniContentCard {
  @BuilderParam contentsBuilder: () => void;
  // Settings
  @Param title: ResourceStr = '';
  @Param icon: Resource = $r('sys.symbol.gearshape');
  @Param roundedRadius: number = defaultRoundedRadius;
  @Param blurRadius: number = 0;
  // UI
  @Param @Once expanded: boolean = this.title ? false : true;
  @Local isHover: boolean = false;
  @Local contentHeight: number = 0;

  build() {
    Column({ space: standardSpacing }) {
      if (this.title) {
        Row({ space: standardSpacing }) {
          SymbolGlyph(this.icon)
            .fontSize(fontSizeSymbol)
            .fontColor([getColor(meowThemeColorType.FONT)])
            .opacity(0.75);
          Text(this.title)
            .attributeModifier(new MooTextModifier(mooTextType.TITLE))
            .opacity(0.75);
        };
      }

      if (this.expanded) {
        this.contentsBuilder();
      }
    }
    .brightness(this.isHover ? (this.expanded ? 1.02 : 1.05) : 1)
    .animation(defaultAnimation())
    .width('100%')
    .backgroundEffect({ color: $r('app.color.blur_background'), radius: this.blurRadius })
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .border({ radius: this.roundedRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
    .padding(standardSpacing * 1.5)
    .alignItems(HorizontalAlign.Start)
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
    });
  }
}

export { UniContentCard };
