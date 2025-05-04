import { fontSize_Large } from '../hosts/bunch_of_defaults';

@Component
struct linysLockToggle {
  @Link locked: boolean;
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @State color: ResourceColor | undefined = undefined;
  // animation
  @State triggerValueReplace: number = 0;

  build() {
    SymbolGlyph(this.locked ? $r('sys.symbol.lock') : $r('sys.symbol.lock_open'))
      .onClick(() => {
        this.locked = !this.locked;
        this.triggerValueReplace += 1;
      })// .clickEffect(click_effect_default())
      .fontSize(fontSize_Large())
      .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.triggerValueReplace)
      .fontColor([this.color ? this.color : this.color_current_font])
  }
}

export default linysLockToggle