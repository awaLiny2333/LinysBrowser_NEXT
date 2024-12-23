@Component
struct linysProgress {
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @State bar_height: Length = 8;
  @State bar_width: Length = "100%";
  @Watch('on_update') @Prop is_loading: boolean = false;
  @Watch('on_update') @Prop percentage: number = 0;
  @State display_rate: number = 0.0;
  @State color_progress: ResourceColor = "";
  @State color_undone: ResourceColor = "";
  @State show: boolean = false;

  build() {
    Row() {
      Row()
        .height("100%")
        .layoutWeight(this.display_rate)
        .backgroundColor(this.color_progress == "" ? this.color_current_font : this.color_progress)
        .animation({ duration: this.show ? 500 : 0, curve: Curve.EaseInOut })

      Row()
        .height("100%")
        .layoutWeight(1 - (this.display_rate))
        .backgroundColor(this.color_undone == "" ? this.color_current_primary : this.color_undone)
        .animation({ duration: this.show ? 500 : 0, curve: Curve.EaseInOut })
    }
    .height(this.show ? this.bar_height : 0)
    .width(this.bar_width)
    .animation({ duration: 200, curve: Curve.ExtremeDeceleration })
    .accessibilityText(this.percentage.toString() + "%")
    .accessibilityDescription($r('app.string.Accessibility_desc_linysProgress'))
    .accessibilityGroup(true)
  }

  on_update() {
    this.display_rate = this.percentage / 100
    if (this.is_loading) {
      this.show = true;
    } else {
      setTimeout(() => {
        // Auto hide after is not loading
        this.show = false;
      }, 500)
      setTimeout(() => {
        // Reset progress bar
        this.display_rate = 0;
      }, 800)
    }
  }
}

export default linysProgress