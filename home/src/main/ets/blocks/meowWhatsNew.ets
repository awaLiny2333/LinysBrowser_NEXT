import linysText from '../components/linysText';
import { animation_default } from '../hosts/bunch_of_defaults';

@Component
struct meowWhatsNew {
  build() {
    Column({ space: 8 }) {
      linysText({
        text: $r('app.string.Whats_new')
      })
      linysText({
        text: $r('app.string.Whats_new_content_1'),
        max_lines: 6
      })
        .opacity(0.8)
      linysText({
        text: $r('app.string.Whats_new_content_2'),
        max_lines: 6
      })
        .opacity(0.8)
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