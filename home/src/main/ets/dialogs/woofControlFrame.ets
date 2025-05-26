import linysSymbol from '../components/texts/linysSymbol';
import linysTextTitle from '../components/texts/linysTextTitle';

@Component
struct woofControlFrame {
  // Pass in content components
  @BuilderParam content_section: () => void;
  // Information
  @Prop title: ResourceStr = 'Meow';
  // Control
  controller?: CustomDialogController;
  // Color
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');

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
        // .borderRadius(20)
        // .padding(6)
        // .backgroundColor($r('sys.color.comp_background_tertiary'))
      }

      // Contents
      this.content_section();
    }
    .padding(15)
    .backgroundColor(this.color_current_primary)
  }
}

export default woofControlFrame;