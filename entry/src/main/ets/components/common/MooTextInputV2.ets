import { defaultInnerRadius } from '../../catstypicalframework/utils/ui';
import { heightMeowTitleBar } from '../parts/MeowTitleBar';
import { fontSizeMedium, getColor, meowThemeColorType, standardSpacing, useEffects } from '../settings';

@ComponentV2
struct MooTextInputV2 {
  @Param @Once placeholder: string | undefined = undefined;
  @Param icon: Resource | undefined = undefined;
  @Param text: string = '';
  // Events
  @Event onChange: (c: string) => void;
  @Event onSubmit: () => void;

  build() {
    Row({ space: standardSpacing }) {
      if (this.icon) {
        SymbolGlyph(this.icon)
          .fontColor([getColor(meowThemeColorType.FONT)])
          .fontSize(fontSizeMedium)
          .padding({ left: standardSpacing * 0.5 });
      }
      TextInput({ text: this.text as string, placeholder: this.placeholder })
        .height(heightMeowTitleBar)
        .fontColor(getColor(meowThemeColorType.FONT))
        .caretColor(getColor(meowThemeColorType.FONT))
        .selectedBackgroundColor(getColor(meowThemeColorType.PRIMARY))
        .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius } : { width: 0, radius: defaultInnerRadius })
        .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.SECONDARY))
        .layoutWeight(1)
        .onChange((c) => {
          this.onChange(c);
        })
        .onSubmit(() => {
          this.onSubmit();
        });
    }.height(heightMeowTitleBar);
  }
}

export { MooTextInputV2 };
