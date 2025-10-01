import { click_effect_default } from '../../hosts/bunch_of_defaults';

@Component
struct linysTextArea {
  @Link text: string;
  init_text: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    TextArea({ text: this.init_text }) // linysText({ text: this.link, max_lines: 5 })// link
      .fontWeight(FontWeight.Regular)
      .fontColor(this.color_current_font)
      .caretColor(this.color_current_font)
      .selectedBackgroundColor(this.color_current_font)
      .backgroundColor(this.color_current_secondary)
      .width("100%")
      .padding(10)
      .borderRadius(13.5)
      .clickEffect(click_effect_default())
      .onChange((v) => {
        this.text = v;
      })
  }
}

export default linysTextArea;