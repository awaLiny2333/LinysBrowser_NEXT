import { defaultInnerRadius } from '../../catstypicalframework/utils/ui';
import { fontSizeMedium, meowThemeColorType, standardComponentHeight, standardSpacing } from '../constants';
import { getColor, useEffects } from '../settings';

@ComponentV2
struct MooTextInputV2 {
  @Param @Once placeholder: ResourceStr | undefined = undefined;
  @Param @Once type: InputType = InputType.Normal;
  @Param @Once shiftBackgroundColor: boolean = false;
  @Param @Once undefinedRadius: boolean = false;
  @Param icon: Resource | undefined = undefined;
  @Param text: string = '';
  @Param myId: string | undefined = undefined;
  @Param outerAutoExpand: boolean = false;
  @Param autoLength: boolean = false;
  @Param myHeight: number = standardComponentHeight;
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
        .id(this.myId)
        .type(this.type)
        .enableAutoFill(true)
        .keyboardAppearance(KeyboardAppearance.IMMERSIVE)
        .height(this.myHeight)
        .fontColor(getColor(meowThemeColorType.FONT))
        .caretColor(getColor(meowThemeColorType.FONT))
        .selectedBackgroundColor(getColor(meowThemeColorType.PRIMARY))
        .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth'), radius: this.undefinedRadius ? undefined : defaultInnerRadius } : { width: 0, radius: this.undefinedRadius ? undefined : defaultInnerRadius })
        .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(this.shiftBackgroundColor ? meowThemeColorType.PRIMARY : meowThemeColorType.SECONDARY))
        .layoutWeight(this.autoLength ? undefined : 1)
        .width(this.autoLength ? 'auto' : undefined)
        .onChange((c) => {
          this.onChange(c);
        })
        .onSubmit(() => {
          this.onSubmit();
        });
    }
    .layoutWeight(this.outerAutoExpand ? 1 : undefined)
    .height(this.myHeight);
  }
}

export { MooTextInputV2 };
