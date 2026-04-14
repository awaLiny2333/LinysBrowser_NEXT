import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { AppStorageV2 } from '@kit.ArkUI';
import { standardSpacing, getColor, meowThemeColorType, fontSizeMedium, useEffects } from '../settings';
import { heightMeowTitleBar } from './MeowTitleBar';

/**
 * The search bar.
 *
 * @todo FLUENT Switch between wide and non-wide mode. (Perhaps with custom node?)
 */
@ComponentV2
struct MeowSearchBar {
  @Param @Once needPadding: boolean = true;
  @Local myMeowAvoid: meowAvoid = AppStorageV2.connect(meowAvoid)!;

  build() {
    Row() {
      AddressInput({
        placeholder: ' 󰀩 ...'
      });
    }
    .padding(this.needPadding ? { left: this.myMeowAvoid.left, right: this.myMeowAvoid.right } : {});
  }
}

export { MeowSearchBar };

/**
 * Basically the same as MooTextInputV2 but with some modifications on color and style.
 *
 * @see entry/src/main/ets/components/common/MooTextInputV2.ets
 */
@ComponentV2
struct AddressInput {
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
          .fontSize(fontSizeMedium);
      }
      TextInput({ text: this.text as string, placeholder: this.placeholder })
        .height(heightMeowTitleBar)
        .fontColor(getColor(meowThemeColorType.FONT))
        .caretColor(getColor(meowThemeColorType.FONT))
        .selectedBackgroundColor(getColor(meowThemeColorType.FONT))
        .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth') } : { width: 0 })
        .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
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