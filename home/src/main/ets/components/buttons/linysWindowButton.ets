@Component
struct linysWindowButton {
  @State hover_on_new_window_button: boolean = false;
  @State press_on_new_window_button: boolean = false;
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Environment
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  @LocalStorageLink('on_focus') on_focus: boolean = true;
  // Actions
  execution?: () => void;

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.plus'))
        .fontWeight(FontWeight.Medium)
        .fontSize(this.hover_on_new_window_button ? 18 : 16)
        .fontColor([this.color_current_font])
    }
    .backgroundColor(this.hover_on_new_window_button ? $r('sys.color.comp_background_secondary') : undefined)
    .brightness(this.press_on_new_window_button ? 1.08 : undefined)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
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
        this.press_on_new_window_button = true;
      } else {
        this.press_on_new_window_button = false;
      }
    })
    .opacity(this.on_focus ? 1 : 0.4)
    .onHover((h) => {
      this.hover_on_new_window_button = h;
    })
  }
}

export default linysWindowButton;