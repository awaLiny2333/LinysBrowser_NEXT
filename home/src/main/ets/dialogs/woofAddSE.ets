import linysCapsuleButton from '../components/linysCapsuleButton';
import linysSymbol from '../components/linysSymbol';
import linysTitleText from '../components/linysTitleText';
import { animation_default, capsule_bar_height } from '../hosts/bunch_of_defaults';
import { bunch_of_search_engines, search_engine } from '../hosts/bunch_of_search_engines';
import { bunch_of_settings } from '../hosts/bunch_of_settings';

@CustomDialog
struct woofAddSE {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop label: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Host
  @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines =
    new bunch_of_search_engines();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);

  build() {
    Scroll() {
      Column({ space: 10 }) {

        linysTitleText({
          text: $r('app.string.AddSE_add_to_search_engines'),
          max_lines: 3
        })
          .width("100%")

        Row({ space: 10 }) {
          linysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
          TextInput({ text: this.label })
            .onChange((value) => {
              this.label = value;
            })
            .fontWeight(FontWeight.Regular)
            .fontColor(this.color_current_font)
            .caretColor(this.color_current_font)
            .selectedBackgroundColor(this.color_current_font)
            .layoutWeight(1)
            .height(capsule_bar_height())

        } // Edit label
        .width("100%")

        Row({ space: 10 }) {
          linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
          TextArea({ text: this.link })
            .onChange((value) => {
              this.link = value;
            })
            .fontWeight(FontWeight.Regular)
            .fontColor(this.color_current_font)
            .caretColor(this.color_current_font)
            .selectedBackgroundColor(this.color_current_font)
            .layoutWeight(1)

        } // Edit content
        .width("100%")
        .animation(animation_default())

        Row() {
          Blank()
          linysCapsuleButton({ text: '  󰀓  ' })
            .onClick(() => {
              this.bunch_of_search_engines.add_search_engine(new search_engine(this.label, this.link));
              this.bunch_of_settings.set('custom_search_engines', this.bunch_of_search_engines.export_string());
              if (this.controller) {
                this.controller.close();
              }
            })
        }
        .width("100%")
      }
      .padding(20)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width("100%")
    }
    .backgroundColor(this.color_current_primary)
    .edgeEffect(EdgeEffect.Spring)
  }
}

export default woofAddSE;