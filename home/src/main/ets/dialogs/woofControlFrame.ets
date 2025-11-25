import linysSymbol from '../components/texts/linysSymbol';
import linysTextTitle from '../components/texts/linysTextTitle';
import { animation_default } from '../hosts/bunch_of_defaults';

@Component
struct woofControlFrame {
  // Environment
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false;
  // Pass in content components
  @BuilderParam content_section: () => void;
  // Information
  title: ResourceStr = 'Meow';
  space_column: number = 2;
  @Prop show_title: boolean = true;
  // Control
  controller?: CustomDialogController;
  // Color
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // animation
  @State off_y_contents: number = 120;
  @StorageLink('effects') effects: boolean = false;

  build() {
    Column({ space: this.space_column }) {
      Row() {
        linysTextTitle({
          text: this.title,
          max_lines: 3
        })
          .layoutWeight(1)
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.xmark',
          can_hover: true,
        })
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
          })
      }
      .visibility(this.show_title ? Visibility.Visible : Visibility.None)
      .animation(animation_default())

      // Contents
      this.content_section();
    }
    .offset({ y: this.off_y_contents })
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
    .padding(this.compact_mode ? 10 : 15)
    .animation(animation_default())
    .backgroundColor(this.effects ? undefined : this.color_current_primary)
    .onAppear(() => {
      this.off_y_contents = 0;
    })
  }
}

export default woofControlFrame;