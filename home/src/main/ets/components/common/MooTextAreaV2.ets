import { defaultInnerRadius } from '../../catstypicalframework/utils/ui';
import { meowThemeColorType } from '../constants';
import { getColor, useEffects } from '../settings';

@ComponentV2
export struct MooTextAreaV2 {
  @Param @Once placeholder: string | undefined = undefined;
  @Param icon: Resource | undefined = undefined;
  @Param text: string = '';
  @Param myId: string | undefined = undefined;
  // Events
  @Event onChange: (c: string) => void;
  @Event onSubmit: () => void;

  build() {
    TextArea({ text: this.text as string, placeholder: this.placeholder })
      .id(this.myId)
      .keyboardAppearance(KeyboardAppearance.IMMERSIVE)
      .fontColor(getColor(meowThemeColorType.FONT))
      .caretColor(getColor(meowThemeColorType.FONT))
      .selectedBackgroundColor(getColor(meowThemeColorType.PRIMARY))
      .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius } : { width: 0, radius: defaultInnerRadius })
      .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.SECONDARY))
      .onChange((c) => {
        this.onChange(c);
      })
      .onSubmit(() => {
        this.onSubmit();
      });
  }
}
