import linysSymbol from '../../components/texts/linysSymbol';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, capsule_bar_height, click_effect_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { webview } from '@kit.ArkWeb';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import woofControlFrame from '../woofControlFrame';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysSwitchWithText from '../../components/toggles/linysSwitchWithText';

@CustomDialog
struct woofDarkExempts {
  controller: CustomDialogController;
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('web_force_dark_mode') force_dark_mode: boolean = true;
  @StorageLink('web_force_dark_mode_exemptions') web_force_dark_mode_exemptions: string[] = [];
  @State add_exception_domain_edit: string = "";
  @State showing_add_panel: boolean = false;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = this.all_false(this.web_force_dark_mode_exemptions.length);
  @State selecting: boolean = false;
  @State selected_number: number = 0;
  @State delete_confirm: number = 0;
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start }
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    bottom: { anchor: "controls_forced_dark", align: VerticalAlign.Top },
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
    top: { anchor: "title_forced_dark", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls_forced_dark", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Gateways
  @StorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";

  build() {
    woofControlFrame({
      title: $r('app.string.Settings_experience_manage_web_force_dark_mode'),
      controller: this.controller
    }) {
      RelativeContainer() {
        Scroll() {
          Column({ space: 10 }) {
            linysText({
              text: $r('app.string.Web_force_dark_mode_desc_1'),
              max_lines: 6
            })
              .width("100%")
            linysText({
              text: $r('app.string.Web_force_dark_mode_desc_2'),
              max_lines: 6
            })
              .width("100%")
            linysText({
              text: $r('app.string.General_select_guide'),
              max_lines: 6
            })
              .width("100%")
            linysText({
              text: $r('app.string.Have_a_Nice_Surf'),
              max_lines: 2
            })
              .width("100%")
              .opacity(0.9)
          } // Title
          .width("100%")
        }
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: 10, right: 10 })
        .width(this.tablet_mode ? "40%" : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .constraintSize(this.tablet_mode ? {} : { maxHeight: '35%' })
        .animation(animation_default())
        .id("title_forced_dark")

        Column({ space: 10 }) {
          linysText({
            text: $r('app.string.Web_force_dark_mode_exemptions'),
            max_lines: 3
          })
            .padding({ top: this.tablet_mode ? 0 : 10 })
            .width("100%")
            .opacity(!this.force_dark_mode ? 0.5 : 1)
            .animation(animation_default())

          Scroll() {
            Column() {
              ForEach(this.web_force_dark_mode_exemptions, (item: string, index: number) => {
                Domain({
                  domain: item,
                  index: index,
                  selected: this.selected,
                  selected_number: this.selected_number,
                  selecting: this.selecting
                })
                  .width("100%")
              })
              if (this.web_force_dark_mode_exemptions.length == 0) {
                linysTextTitle({
                  text: "¯\\_(ツ)_/¯"
                })
                  .margin(30)
                  .opacity(0.7)
                  .animation(animation_default())
              }
            }
            .width("100%")
          } // domains display list
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .borderRadius(10)
          .backgroundColor(this.color_current_secondary)
          .width("100%")
          .layoutWeight(1)
          .opacity(!this.force_dark_mode ? 0.5 : 1)
          .animation(animation_default())

          linysSwitchWithText({
            text: $r('app.string.Settings_experience_web_force_dark_mode'),
            toggle_state: this.force_dark_mode,
            onExecution: () => {
              this.bunch_of_settings.set('web_force_dark_mode', this.force_dark_mode);
            }
          }) // Reverse settings menu

        } // Whitelist
        .width(this.tablet_mode ? "60%" : "100%")
        .height(this.tablet_mode ? "100%" : undefined)
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
        .animation(animation_default())

        Column() {
          linysShowButton({
            show: this.showing_add_panel,
            symbol_glyph_target: "sys.symbol.plus",
            text: $r('app.string.Web_force_dark_mode_add_exemption_domain')
          })// Add Button
            .onClick(() => {
              this.showing_add_panel = !this.showing_add_panel;
            })

          Scroll() {
            Column({ space: 8 }) {
              TextInput({ text: this.add_exception_domain_edit })// Input domain
                .onChange((value) => {
                  this.add_exception_domain_edit = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
                .width("100%")
                .onSubmit(() => {
                  this.add_exception(this.add_exception_domain_edit);
                  this.add_exception_domain_edit = "";
                  this.showing_add_panel = false;
                })
                .height(capsule_bar_height())
                .animation(animation_default())

              linysCapsuleButton({ text: "  󰀓  " })
                .animation(animation_default())
                .onClick(() => {
                  this.add_exception(this.add_exception_domain_edit);
                  this.add_exception_domain_edit = "";
                  this.showing_add_panel = false;
                })
            }
            .padding({ top: 10 })
            .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
            .animation(animation_default())
            .width("100%")
          } // Add
          .scrollBar(BarState.Off)
          .width("100%")
          .height(this.showing_add_panel ? 90 : 0)
          .animation(animation_default())

          Scroll() {
            Column({ space: 10 }) {
              Row() {
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting") })
                linysTextTitle({ text: " " + this.selected_number.toString() + " " })
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting_items") })
              }

              Row() {
                linysSymbol({ symbol_glyph_target: 'sys.symbol.list_checkmask' })
                  .onClick(() => {
                    this.select_all();
                  })
                Blank()
                linysTimeoutButton({
                  text: "  󰀁  ",
                  onExecution: () => {
                    this.delete_selected();
                  }
                })
              }
              .width("100%")
            }
            .padding({ top: 10 })
            .alignItems(HorizontalAlign.Start)
            .width("100%")
          } // Select controls
          .scrollBar(BarState.Off)
          .width("100%")
          .height(this.selecting ? 80 : 0)
          .animation(animation_default())
        } // Controls
        .padding({ top: 10, right: this.tablet_mode ? 10 : 0 })
        .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
        .alignRules(this.alignRules_foot)
        .opacity(!this.force_dark_mode ? 0.5 : 1)
        .animation(animation_default())
        .width(this.tablet_mode ? "40%" : "100%")
        .id("controls_forced_dark")
        .onAppear(() => {
          setInterval(() => {
            if (this.delete_confirm > 0) {
              this.delete_confirm -= 1;
            }
            // Reset delete confirm
          }, 10)
        })
      }.layoutWeight(1)
    }
  }

  all_false(length: number) {
    let result: boolean[] = [];
    for (let index = 0; index < length; index++) {
      result.push(false);
    }
    return result;
  }

  on_select_change() {
    if (this.selected.includes(true)) {
      this.selecting = true;
    } else {
      this.selecting = false;
    }
    this.delete_confirm = 0;
  }

  select_all() {
    let new_selected: boolean[] = [];
    if (this.selected.includes(false)) {
      for (let index = 0; index < this.selected.length; index++) {
        new_selected.push(true);
      }
      this.selected_number = this.selected.length;
    } else {
      for (let index = 0; index < this.selected.length; index++) {
        new_selected.push(false);
      }
      this.selected_number = 0;
    }
    this.selected = new_selected;
  }

  add_exception(domain: string) {
    if (domain == '') {
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_no_content');
      return;
    }
    if (this.web_force_dark_mode_exemptions.includes(domain)) {
      // don't add same domains
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_duplicate_domain');
      return;
    }
    this.web_force_dark_mode_exemptions.push(domain);
    this.bunch_of_settings.set('web_force_dark_mode_exemptions', this.web_force_dark_mode_exemptions.join("\n"))
  }

  delete_selected() {
    let new_exemptions: string[] = [];
    let delete_exemptions: string[] = [];
    // Traverse
    for (let index = 0; index < this.selected.length; index++) {
      if (!this.selected[index]) {
        new_exemptions.push(this.web_force_dark_mode_exemptions[index]);
      } else {
        delete_exemptions.push(this.web_force_dark_mode_exemptions[index]);
      }
    }
    // Store new exemptions
    this.web_force_dark_mode_exemptions = new_exemptions;
    this.delete_confirm = 0;
    this.selecting = false;
    this.selected_number = 0;
    this.selected = this.all_false(this.web_force_dark_mode_exemptions.length);
    this.bunch_of_settings.set('web_force_dark_mode_exemptions', this.web_force_dark_mode_exemptions.join("\n"))
  }
}

export default woofDarkExempts;

@Component
struct Domain {
  @State domain: string = "huawei.com";
  @Prop index: number;
  @Link selected: boolean[];
  @Link selected_number: number;
  @Prop selecting: boolean;
  // Color
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column() {
      linysText({
        color: this.selected[this.index] ? this.color_current_secondary : this.color_current_font,
        text: this.domain,
        font_weight: this.selected[this.index] ? FontWeight.Bold : FontWeight.Regular
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .backgroundColor(this.selected[this.index] ? this.color_current_font : 'transparent')
    .animation(animation_default())
    .padding(5)
    .clickEffect(click_effect_default())
    .padding({
      left: 12,
      right: 12,
      top: 6,
      bottom: 5
    })
    .onClick(() => {
      if (this.selecting) {
        // Select
        this.select_unselect();
      }
    })
    .width("100%")
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.select_unselect();
        })
    )
    .onMouse((e) => {
      if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
        // Right click
        this.select_unselect();
      }
    })
  }

  select_unselect() {
    if (this.selected[this.index]) {
      this.selected_number -= 1;
    } else {
      this.selected_number += 1;
    }
    this.selected[this.index] = !this.selected[this.index];
  }
}