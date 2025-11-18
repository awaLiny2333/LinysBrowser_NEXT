import linysSymbol from '../components/texts/linysSymbol';
import linysTextTitle from '../components/texts/linysTextTitle';
import { animation_default } from '../hosts/bunch_of_defaults';

@Component
struct woofControlFrame {
  // Pass in content components
  @BuilderParam content_section: () => void;
  // Information
  @Prop title: ResourceStr = 'Meow';
  // Control
  controller?: CustomDialogController;
  // Color
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // animation
  @State off_y_contents: number = 120;
  @StorageLink('effects') effects: boolean = false;

  build() {
    Column({ space: 10 }) {
      Row() {
        linysTextTitle({ text: this.title, max_lines: 3 })
          .layoutWeight(1)
        linysSymbol({ symbol_glyph_target: 'sys.symbol.xmark', can_hover: true })
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
          })
      }

      // Contents
      this.content_section();
    }
    .offset({ y: this.off_y_contents })
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
    .animation(animation_default())
    .padding(15)
    .backgroundColor(this.color_current_primary)
    .onAppear(() => {
      this.off_y_contents = 0;
    })
  }
}

export default woofControlFrame;