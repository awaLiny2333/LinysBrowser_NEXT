import { animation_default } from '../../hosts/bunch_of_defaults';

@Component
struct linysWindowButton {
  @State hover_on: boolean = false;
  @State press_on: boolean = false;
  @Prop symbol: Resource = $r('sys.symbol.plus');
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Environment
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  @LocalStorageLink('on_focus') on_focus: boolean = true;
  // Actions
  execution?: () => void;

  build() {
    Row() {
      SymbolGlyph(this.symbol)
        .fontWeight(FontWeight.Normal)
        .fontSize(this.hover_on ? 18 : 16)
        .fontColor([this.color_current_font])
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .animation(animation_default())
    .backgroundColor(this.hover_on ? $r('sys.color.comp_background_secondary') : undefined)
    .brightness(this.press_on ? 1.08 : undefined)
    .width(28.5)
    .height(28.5)
    .borderRadius(4)
    .onClick(() => {
      if (this.execution) {
        this.execution();
      }
    })
    .onTouch((e) => {
      if (e.type == TouchType.Down) {
        this.press_on = true;
      } else {
        this.press_on = false;
      }
    })
    .opacity(this.on_focus ? 1 : 0.4)
    .onHover((h) => {
      this.hover_on = h;
    })
  }
}

export default linysWindowButton;