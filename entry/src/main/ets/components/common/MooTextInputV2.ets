import { defaultInnerRadius } from '../../catstypicalframework/utils/ui';
import { fontSizeMedium, getColor, meowThemeColorType, standardSpacing, useEffects } from './constants';

@ComponentV2
struct MooTextInputV2 {
  @Param text: string = '';
  @Param @Once placeholder: string | undefined = undefined;
  @Param icon: Resource | undefined = undefined;
  @Event onChange: (c: string) => void;

  build() {
    Row({ space: standardSpacing }) {
      if (this.icon) {
        SymbolGlyph(this.icon)
          .fontColor([getColor(meowThemeColorType.FONT)])
          .fontSize(fontSizeMedium);
      }
      TextInput({ text: this.text as string, placeholder: this.placeholder })
        .fontColor(getColor(meowThemeColorType.FONT))
        .caretColor(getColor(meowThemeColorType.FONT))
        .selectedBackgroundColor(getColor(meowThemeColorType.PRIMARY))
        .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius } : { width: 0 })
        .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.SECONDARY))
        .layoutWeight(1)
        .onChange((c) => {
          this.onChange(c);
        });
    };
  }
}

export { MooTextInputV2 };
