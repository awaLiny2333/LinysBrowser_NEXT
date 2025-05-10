import linysSymbol from '../../components/linysSymbol';
import linysText from '../../components/linysText';
import linysTitleText from '../../components/linysTitleText';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { webview } from '@kit.ArkWeb';
import linysShowButton from '../../components/linysShowButton';
import linysCapsuleButton from '../../components/linysCapsuleButton';
import { match_domain } from '../../utils/url_tools';
import woofControlFrame from '../woofControlFrame';
import linysTimeoutButton from '../../components/linysTimeoutButton';

@CustomDialog
struct woofGeneralManage {
  controller: CustomDialogController;
  // Environment and Hosts
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @State add_site_edit: string = "";
  @State showing_add_panel: boolean = false;
  // Generals
  @Link general_switch: boolean;
  @Link general_sites_list: string[];
  @Link general_on_all_sites_switch: boolean;
  @State general_descriptions: ResourceStr[] = [
    $r('app.string.Settings_js_desc_1'),
    $r('app.string.Settings_js_desc_2'),
    $r('app.string.Settings_js_desc_3')
  ];
  @State general_tips: ResourceStr = $r('app.string.Settings_js_already_disabled');
  @State general_title: ResourceStr = $r('app.string.Settings_js_manage');
  @State general_switch_desc: ResourceStr = $r('app.string.Settings_js_disable_js');
  @State general_subtitle_execute_on_these_sites: ResourceStr = $r('app.string.Settings_js_some_sites');
  @State general_subtitle_execute_on_all_sites: ResourceStr = $r('app.string.Settings_js_all_sites');
  @State general_switch_settings_id: string = 'disable_js';
  @State general_sites_list_settings_id: string = 'disable_js_these_sites';
  @State general_switch_all_sites_settings_id: string = 'disable_js_all_sites';
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = this.all_false(this.general_sites_list.length);
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
    bottom: { anchor: "controls", align: VerticalAlign.Top },
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
    top: { anchor: "title", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls", align: VerticalAlign.Top },
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
      title: this.general_title,
      controller: this.controller
    }) {
      RelativeContainer() {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.general_descriptions, (desc: ResourceStr, _index: number) => {
              linysText({
                text: desc,
                max_lines: 10
              })
                .width("100%")
            })

            linysText({
              text: this.general_tips,
              max_lines: 3
            })
              .width("100%")
              .visibility(this.match_this_domain(this.current_url) ? Visibility.None : Visibility.Visible)
              .animation(animation_default())

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
        .constraintSize(this.tablet_mode ? {} : { maxHeight: '35%' })
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .animation(animation_default())
        .id("title")

        Column({ space: 10 }) {
          linysText({
            text: this.general_subtitle_execute_on_these_sites,
            max_lines: 3
          })
            .padding({ top: this.tablet_mode ? 0 : 10 })
            .width("100%")
            .opacity(this.general_on_all_sites_switch || !this.general_switch ? 0.5 : 1)
            .animation(animation_default())

          Scroll() {
            Column() {
              ForEach(this.general_sites_list, (item: string, index: number) => {
                Domain({
                  domain: item,
                  index: index,
                  selected: this.selected,
                  selected_number: this.selected_number,
                  selecting: this.selecting
                })
                  .width("100%")
              })
              if (this.general_sites_list.length == 0) {
                linysTitleText({
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
          .opacity(this.general_on_all_sites_switch || !this.general_switch ? 0.5 : 1)
          .animation(animation_default())

          Row({ space: 10 }) {
            linysText({ text: this.general_subtitle_execute_on_all_sites })
              .layoutWeight(1)

            Toggle({ isOn: this.general_on_all_sites_switch, type: ToggleType.Switch })
              .switchPointColor(this.color_current_secondary)
              .selectedColor(this.color_current_font)
              .onChange(isOn => {
                this.general_on_all_sites_switch = isOn;
                this.bunch_of_settings.set(this.general_switch_all_sites_settings_id, isOn);
              })
          } // Toggle on all sites
          .width("100%")
          .opacity(!this.general_switch ? 0.5 : 1)
          .animation(animation_default())

          Row({ space: 10 }) {
            linysText({ text: this.general_switch_desc })
              .layoutWeight(1)

            Toggle({ isOn: this.general_switch, type: ToggleType.Switch })
              .switchPointColor(this.color_current_secondary)
              .selectedColor(this.color_current_font)
              .onChange(isOn => {
                this.general_switch = isOn;
                this.bunch_of_settings.set(this.general_switch_settings_id, isOn);
              })
          } // Toggle on all sites
          .width("100%")

        } // Whitelist
        .width(this.tablet_mode ? "60%" : "100%")
        .height(this.tablet_mode ? "100%" : undefined)
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
        .animation(animation_default())

        Column() {
          linysShowButton({
            show: this.showing_add_panel,
            symbol_glyph_target: "sys.symbol.plus",
            text: $r("app.string.Settings_woof_add_a_domain")
          })// Add Button
            .onClick(() => {
              this.showing_add_panel = !this.showing_add_panel;
            })

          Scroll() {
            Column({ space: 8 }) {
              TextInput({ text: this.add_site_edit })// Input domain
                .onChange((value) => {
                  this.add_site_edit = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
                .width("100%")
                .onSubmit(() => {
                  this.add_item(this.add_site_edit);
                  this.add_site_edit = "";
                  this.showing_add_panel = false;
                })
                .height(capsule_bar_height())
                .animation(animation_default())

              linysCapsuleButton({ text: "  󰀓  " })
                .animation(animation_default())
                .onClick(() => {
                  this.add_item(this.add_site_edit);
                  this.add_site_edit = "";
                  this.showing_add_panel = false;
                })
            }
            .padding({ top: 10 })
            .alignItems(HorizontalAlign.End)
            .width("100%")
          } // Add
          .scrollBar(BarState.Off)
          .width("100%")
          .height(this.showing_add_panel ? 90 : 0)
          .animation(animation_default())

          Scroll() {
            Column({ space: 10 }) {
              Row() {
                linysTitleText({ text: $r("app.string.Settings_edit_selecting") })
                linysTitleText({ text: " " + this.selected_number.toString() + " " })
                linysTitleText({ text: $r("app.string.Settings_edit_selecting_items") })
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
                }) // Delete
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
        .alignItems(HorizontalAlign.End)
        .alignRules(this.alignRules_foot)
        .opacity(this.general_on_all_sites_switch || !this.general_switch ? 0.5 : 1)
        .animation(animation_default())
        .width(this.tablet_mode ? "40%" : "100%")
        .id("controls")
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

  add_item(domain: string) {
    if (domain == '') {
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_no_content');
      return;
    }
    webview.AdsBlockManager.addAdsBlockDisallowedList([domain]);
    if (this.general_sites_list.includes(domain)) {
      // don't add same domains
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_duplicate_domain');
      return;
    }
    this.general_sites_list.push(domain);
    this.bunch_of_settings.set(this.general_sites_list_settings_id, this.general_sites_list.join("\n"))
  }

  delete_selected() {
    let new_exceptions: string[] = [];
    let delete_exceptions: string[] = [];
    for (let index = 0; index < this.selected.length; index++) {
      if (!this.selected[index]) {
        new_exceptions.push(this.general_sites_list[index]);
      } else {
        delete_exceptions.push(this.general_sites_list[index]);
      }
    }
    this.general_sites_list = new_exceptions;
    this.delete_confirm = 0;
    this.selecting = false;
    this.selected_number = 0;
    this.selected = this.all_false(this.general_sites_list.length);
    this.bunch_of_settings.set(this.general_sites_list_settings_id, this.general_sites_list.join("\n"))
  }

  match_this_domain(address: string) {
    if (!this.general_switch) {
      return true;
    }
    // Disable toggle ON
    if (this.general_on_all_sites_switch) {
      // Disable on all sites
      return false;
    }
    // Disable on some sites
    if (address && this.general_sites_list.includes(match_domain(address)[1])) {
      return false;
    }
    return true;
  }
}

export default woofGeneralManage;

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
        text: this.domain
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .backgroundColor(this.selected[this.index] ? this.color_current_font : 'transparent')
    .animation(animation_default())
    .padding({
      left: 10,
      right: 10,
      top: 5,
      bottom: 5
    })
    .clickEffect(click_effect_default())
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