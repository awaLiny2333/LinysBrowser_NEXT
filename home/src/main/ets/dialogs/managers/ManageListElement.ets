import linysText from '../../components/texts/linysText';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';

@Component
struct ManageListElement {
  @State text: string = "huawei.com"; // @Param
  @Prop index: number;
  @Link selected: boolean[];
  @Link selected_number: number;
  @Prop selecting: boolean;
  // Color
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // UI
  @State isHov: boolean = false;

  build() {
    Column() {
      linysText({
        color: this.selected[this.index] && !this.effects ? this.color_current_secondary : this.color_current_font,
        text: this.text,
        font_weight: this.selected[this.index] ? FontWeight.Bold : FontWeight.Regular
      })
    }
    .backgroundColor(this.selected[this.index] ? (this.effects ? this.color_current_secondary : this.color_current_font) : 'transparent')
    .brightness(this.isHov ? 1.1 : 1)
    .animation(animation_default())
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .padding({
      left: 10,
      right: 10,
      top: 5,
      bottom: 5
    })
    .clickEffect(click_effect_default())
    .onClick(() => {
      if (this.selecting) {
        // Select
        this.select_unselect();
      }
    })
    .width("100%")
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.select_unselect();
        })
    )
    .onMouse((e) => {
      if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
        // Right click
        this.select_unselect();
      }
    })
    .onHover((isHv) => {
      this.isHov = isHv;
    })
  }

  /**
   * Toggles the state
   * */
  select_unselect() {
    if (this.selected[this.index]) {
      this.selected_number -= 1;
    } else {
      this.selected_number += 1;
    }
    this.selected[this.index] = !this.selected[this.index];
  }
}

export default ManageListElement;