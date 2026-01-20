import linysText from '../../components/texts/linysText';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { resource_to_string } from '../../utils/resource_tools';

@Component
struct meowWhatsNew {
  new_things_resource: Resource = $r("app.string.Whats_new_content");
  new_things: string = resource_to_string(this.new_things_resource);
  new_things_list: string[] = this.new_things.split('\n');

  build() {
    Column({ space: 8 }) {
      ForEach(this.new_things_list, (text: string, index: number) => {
        Row({ space: 5 }) {
          linysText({ text: (index + 1).toString() + '.' })
          linysText({
            text: text,
            max_lines: 48
          })
            .opacity(0.8)
            .layoutWeight(1)
        }
        // .width('90%')
        .alignItems(VerticalAlign.Top)
      })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .borderRadius(13.5)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width("100%")
    .animation(animation_default())
  }
}

export default meowWhatsNew;