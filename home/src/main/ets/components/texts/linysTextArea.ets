@Component
struct linysTextArea {
  @Link text: string;
  init_text: string = '';
  max_lines: number | undefined = undefined;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Actions
  onSubmitAction?: (enterKey: EnterKeyType) => void;

  build() {
    TextArea({ text: this.init_text }) // linysText({ text: this.link, max_lines: 5 })// link
      .maxLines(this.max_lines)
      .fontWeight(FontWeight.Regular)
      .fontColor(this.color_current_font)
      .caretColor(this.color_current_font)
      .selectedBackgroundColor(this.color_current_font)
      .width("100%")
      .padding(10)
      .onSubmit((enterKey) => {
        if (this.onSubmitAction) {
          this.onSubmitAction(enterKey);
        }
      })
      .onChange((v) => {
        this.text = v;
      })
  }
}

export default linysTextArea;