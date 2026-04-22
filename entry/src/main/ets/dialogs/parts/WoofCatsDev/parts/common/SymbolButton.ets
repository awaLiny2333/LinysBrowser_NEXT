import { defaultInnerRadius } from '../../../../../catstypicalframework/utils/ui';

@ComponentV2
struct SymbolButton {
  @Param icon: Resource = $r('sys.symbol.pencil_and_card');
  @Param radius: number = defaultInnerRadius;
  @Event clickAction: () => void;

  build() {
    SymbolGlyph(this.icon)
      .padding(5)
      .fontSize(20)
      .aspectRatio(1)
      .height(30)
      .borderRadius(this.radius)
      .hoverEffect(HoverEffect.Highlight)
      .fontColor([$r('sys.color.font')])
      .onClick(() => {
        this.clickAction();
      });
  }
}

export { SymbolButton };
