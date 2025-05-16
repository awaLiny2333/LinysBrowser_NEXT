import { animation_default, click_effect_default } from '../hosts/bunch_of_defaults';
import linysText from './linysText';

@Component
struct linysProgressInfo {
  @Prop progress: string = "qwq";
  @Prop notification: ResourceStr = "The task desc.";

  build() {
    Row({ space: 10 }) {
      linysText({ text: this.notification, max_lines: 3 })
        .layoutWeight(1)
      linysText({ text: this.progress })
    } // Reindexing indicator
    .padding({
      left: 15,
      right: 15,
      top: 8,
      bottom: 8
    })
    .alignItems(VerticalAlign.Center)
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .visibility(this.progress != "" ? Visibility.Visible : Visibility.None)
    .animation(animation_default())
    .clickEffect(click_effect_default())
  }
}

export default linysProgressInfo;