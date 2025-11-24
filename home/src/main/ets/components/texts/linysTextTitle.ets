import lazy { animation_default } from '../../hosts/bunch_of_defaults';
import { fontSize_Large } from '../../hosts/bunch_of_defaults';

@Reusable
@Component
struct linysTextTitle {
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceColor = "";
  @Prop max_lines: number = 1;
  @Prop font_size: number | undefined = undefined;
  // UI
  can_hover: boolean = false;
  @State isHov: boolean = false;

  build() {
    Text(this.text)
      .brightness(this.isHov ? 1.1 : 1)
      .fontSize(this.font_size || fontSize_Large())
      .animation(this.can_hover ? animation_default() : { duration: 0 })
      .padding(this.can_hover ? {
        left: 7,
        right: 7,
        top: 5,
        bottom: 5
      } : 0)
      .borderRadius(this.can_hover ? 7.5 : 0)
      .fontColor(this.color == "" ? this.color_current_font : this.color)
      .fontWeight(FontWeight.Bold)
      .maxLines(this.max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onHover((isHv) => {
        if (this.can_hover) {
          this.isHov = isHv;
        }
      })
  }
}

export default linysTextTitle;
