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

  build() {
    Column({ space: 15 }) {
      Row() {
        linysTextTitle({ text: this.title, max_lines: 3 })
          .layoutWeight(1)
        linysSymbol({ symbol_glyph_target: 'sys.symbol.xmark' })
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
    .animation(animation_default())
    .padding(15)
    .backgroundColor(this.color_current_primary)
    .onAppear(() => {
      this.off_y_contents = 0;
    })
  }
}

export default woofControlFrame;