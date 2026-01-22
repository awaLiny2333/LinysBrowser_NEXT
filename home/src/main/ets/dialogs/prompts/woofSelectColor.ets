import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import linysText from '../../components/texts/linysText';
import { animation_default, capsule_bar_height } from '../../hosts/bunch_of_defaults';
import { hex2hsv, hsv2hex, is_legal_hex } from '../../utils/color_tools';
import lazy woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofSelectColor {
  controller: CustomDialogController;
  @Link color: ResourceColor;
  @Prop color_theme_id: string = 'color_light_font';
  @State dark_mode_color: boolean = false;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @StorageProp('color_light_primary') color_light_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_light_secondary') color_light_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_light_font') color_light_font: ResourceColor = $r('app.color.font_color_title');
  @StorageProp('color_dark_primary') color_dark_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_dark_secondary') color_dark_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_dark_font') color_dark_font: ResourceColor = $r('app.color.font_color_title');
  // Edit
  @State @Watch('on_color_change') color_hex_display: ResourceColor = this.color;
  @State color_hsv: number[] = hex2hsv(this.color);
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @State dialog_width: number = 0;
  @State dialog_height: number = 0;
  @State max_square_size: number = 0;
  @State color_input: string = this.color as string;
  @State focus_on_code_input: boolean = false;
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    bottom: { anchor: "controls_color", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_foot: AlignRuleOption = {
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
    left: { anchor: "__container__", align: HorizontalAlign.Start }
  };
  alignRules_body_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  alignRules_body_non_tablet: AlignRuleOption = {
    top: { anchor: "title_color", align: VerticalAlign.Bottom },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    woofControlFrame({
      title: $r('app.string.Appearance_color_panel'),
      controller: this.controller
    }) {
      RelativeContainer() {
        Column({ space: 10 }) {
          linysText({
            text: $r('app.string.Color_desc_'.concat(this.color_theme_id))
          })
            .width("100%")
        } // Title
        .width("100%")
        .align(Alignment.TopStart)
        .padding({ top: 5, bottom: 10, right: this.tablet_mode ? 12 : 0 })
        .width(this.tablet_mode ? "40%" : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .animation(animation_default())
        .id("title_color")

        Column() {
          Scroll() {
            Column({ space: 10 }) {
              Column({ space: 10 }) {
                linysText({
                  text: $r('app.string.Example_text'),
                  color: this.dark_mode_color ? this.color_dark_font : this.color_light_font,
                  max_lines: 10,
                })
                linysText({
                  text: $r('app.string.Example_text'),
                  color: this.dark_mode_color ? this.color_dark_font : this.color_light_font,
                  max_lines: 10,
                })
                linysText({
                  text: $r('app.string.Example_text'),
                  color: this.dark_mode_color ? this.color_dark_font : this.color_light_font,
                  max_lines: 10,
                })
                linysCapsuleButton({
                  text: "  󰊂  ",
                  color_button: this.dark_mode_color ? this.color_dark_font : this.color_light_font,
                  color_text: this.dark_mode_color ? this.color_dark_primary : this.color_light_primary
                })
                  .alignSelf(ItemAlign.End)
              } // Example
              .width("80%")
              .alignItems(HorizontalAlign.Start)
              .padding(15)
              .backgroundColor(this.dark_mode_color ? this.color_dark_primary : this.color_light_primary)
              .borderRadius(10)
              .animation(animation_default())

              Column() {
              } // Color
              .width("55%")
              .height(100)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.End)
              .padding(15)
              .backgroundColor(this.color_hex_display)
              .borderRadius(10)
              .animation(animation_default())
            }
            .alignItems(HorizontalAlign.Start)
          }
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.TopStart)
          .padding(15)
          .width("100%")
          .height("100%")
          .backgroundColor(this.dark_mode_color ? this.color_dark_secondary : this.color_light_secondary)
          .borderRadius(16)
          .animation(animation_default())

        } // Color board
        .animation(animation_default())
        .alignItems(HorizontalAlign.End)
        .width(this.tablet_mode ? "40%" : "100%")
        .height(this.tablet_mode ? "100%" : "40%")
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)

        Scroll() {
          Column({ space: 10 }) {
            linysText({
              text: $r('app.string.Color_hue')
            })
              .width("100%")
            Slider({
              min: 0,
              max: 360,
              value: this.color_hsv[0],
              style: SliderStyle.InSet,
            })
              .blockColor(this.color_current_primary)
              .selectedColor(this.color_current_font)
              .onChange((value) => {
                this.color_hsv[0] = value;
                this.color_input = hsv2hex(this.color_hsv);
                this.color_hex_display = this.color_input;
              })

            linysText({
              text: $r('app.string.Color_saturation')
            })
              .width("100%")
            Slider({
              min: 0,
              max: 100,
              value: this.color_hsv[1],
              style: SliderStyle.InSet,
            })
              .blockColor(this.color_current_primary)
              .selectedColor(this.color_current_font)
              .onChange((value) => {
                this.color_hsv[1] = value;
                this.color_input = hsv2hex(this.color_hsv);
                this.color_hex_display = this.color_input;
              })

            linysText({
              text: $r('app.string.Color_value')
            })
              .width("100%")
            Slider({
              min: 0,
              max: 100,
              value: this.color_hsv[2],
              style: SliderStyle.InSet,
            })
              .blockColor(this.color_current_primary)
              .selectedColor(this.color_current_font)
              .onChange((value) => {
                this.color_hsv[2] = value;
                this.color_input = hsv2hex(this.color_hsv);
                this.color_hex_display = this.color_input;
              })

            linysText({
              text: $r('app.string.Color_hex')
            })
              .width("100%")
            TextInput({ text: this.color_input })
              .onClick(() => {
                this.focus_on_code_input = true;
              })
              .onBlur(() => {
                this.focus_on_code_input = false;
              })
              .onChange((value) => {
                if (value[0] != "#") {
                  value = "#" + value;
                }
                this.color_input = value;
                if (is_legal_hex(value) && this.focus_on_code_input) {
                  this.color_hex_display = value.toUpperCase();
                  this.color_hsv = hex2hsv(value);
                }
              })
              .fontWeight(FontWeight.Regular)
              .fontColor(this.color_current_font)
              .caretColor(this.color_current_font)
              .selectedBackgroundColor(this.color_current_font)
              .selectAll(true)
              .onSubmit(() => {
              })
              .height(capsule_bar_height())
              .keyboardAppearance(KeyboardAppearance.IMMERSIVE)
            Blank()
            linysConfirmDenyButtons({
              onConfirm: () => {
                if (this.controller) {
                  this.color = this.color_hex_display;
                  this.controller.close();
                }
              },
              onDeny: () => {
                if (this.controller) {
                  this.controller.close();
                }
              }
            }) // Confirm deny buttons
          }
          .width("100%")
        } // Operations
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .padding({ right: this.tablet_mode ? 12 : 0 })
        .borderRadius(10)
        .id("controls_color")
        .alignRules(this.alignRules_foot)
        .animation(animation_default())
        .height(this.tablet_mode ? undefined : "50%")
        .width(this.tablet_mode ? "60%" : "100%")
      }
      .onAreaChange((_old, n) => {
        this.dialog_width = n.width as number;
        this.dialog_height = n.height as number;
        this.max_square_size =
          (this.tablet_mode ? Math.min(this.dialog_height, this.dialog_width * 0.5) : this.dialog_width) - 30;
      })
      .layoutWeight(1)
    }
  }

  on_color_change() {
    if (this.color_theme_id == 'color_light_font') {
      this.color_light_font = this.color_hex_display;
    } else if (this.color_theme_id == 'color_light_primary') {
      this.color_light_primary = this.color_hex_display;
    } else if (this.color_theme_id == 'color_light_secondary') {
      this.color_light_secondary = this.color_hex_display;
    } else if (this.color_theme_id == 'color_dark_font') {
      this.color_dark_font = this.color_hex_display;
    } else if (this.color_theme_id == 'color_dark_primary') {
      this.color_dark_primary = this.color_hex_display;
    } else if (this.color_theme_id == 'color_dark_secondary') {
      this.color_dark_secondary = this.color_hex_display;
    }
  }
}

export default woofSelectColor;