import { animation_default, click_effect_default } from '../hosts/bunch_of_defaults';
import linysText from './texts/linysText';

@Component
struct linysProgressInfo {
  @Prop progress: string = "qwq";
  @Prop notification: ResourceStr = "The task desc.";
  @State is_hov: boolean = false;

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
    .brightness(this.is_hov ? 1.1 : 1)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .animation(animation_default())
    .alignItems(VerticalAlign.Center)
    .borderRadius(12)
    .clickEffect(click_effect_default())
    .constraintSize({ maxWidth: 500 })
    .onHover((ish) => {
      this.is_hov = ish;
    })
  }
}

export default linysProgressInfo;