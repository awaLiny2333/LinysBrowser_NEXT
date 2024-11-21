import linysSymbol from '../components/linysSymbol';
import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { webview } from '@kit.ArkWeb';
import linysShowButton from '../components/linysShowButton';
import linysCapsuleButton from '../components/linysCapsuleButton';

@CustomDialog
struct woofAdsBlocker {
  controller: CustomDialogController;
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @Link adblock_exceptions: string[];
  @State add_exception_domain_edit: string = "";
  @State showing_add_panel: boolean = false;
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = this.all_false(this.adblock_exceptions.length);
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
    bottom: { anchor: "controls_ads_blocker", align: VerticalAlign.Top },
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
    top: { anchor: "title_ads_blocker", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls_ads_blocker", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };

  build() {
    RelativeContainer() {
      Scroll() {
        Column({ space: 10 }) {
          linysTitleText({
            text: $r('app.string.Settings_experience_manage_adblock'),
            max_lines: 1
          })
            .width("100%")
            .padding({ bottom: 5 })
          linysText({
            text: $r('app.string.Ads_block_desc_1'),
            max_lines: 6
          })
            .width("100%")
            .opacity(0.9)
          linysText({
            text: $r('app.string.Ads_block_desc_2'),
            max_lines: 6
          })
            .width("100%")
            .opacity(0.9)
          linysText({
            text: $r('app.string.Ads_block_desc_3'),
            max_lines: 6
          })
            .width("100%")
            .opacity(0.9)
          linysText({
            text: $r('app.string.Have_a_Nice_Surf'),
            max_lines: 2
          })
            .width("100%")
            .opacity(0.9)
        } // Title
        .width("100%")
      }
      .scrollBar(BarState.Off)
      .align(Alignment.TopStart)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ top: 5, bottom: 10, right: this.tablet_mode ? 10 : 0 })
      .width(this.tablet_mode ? "35%" : "100%")
      .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
      .animation(animation_default())
      .id("title_ads_blocker")

      Column() {
        linysText({
          text: $r('app.string.Ads_block_dont_block_sites'),
          max_lines: 3
        })
          .width("100%")
          .padding({ bottom: 10 })

        Scroll() {
          Column() {
            ForEach(this.adblock_exceptions, (item: string, index: number) => {
              Domain({
                domain: item,
                index: index,
                selected: this.selected,
                selected_number: this.selected_number,
                selecting: this.selecting
              })
                .width("100%")
            })
            if (this.adblock_exceptions.length == 0) {
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
        .backgroundColor($r('app.color.block_color'))
        .width("100%")
        .layoutWeight(1)
      } // Whitelist
      .width(this.tablet_mode ? "65%" : "100%")
      .height(this.tablet_mode ? "100%" : undefined)
      .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
      .animation(animation_default())

      Column() {
        linysShowButton({
          show: this.showing_add_panel,
          symbol_glyph_target: "sys.symbol.plus",
          text: $r('app.string.Ads_block_add_exception_domain')
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
              .fontColor($r('app.color.font_color_title'))
              .caretColor($r('app.color.font_color_title'))
              .selectedBackgroundColor($r('app.color.font_color_title'))
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
              linysTitleText({ text: $r('app.string.Settings_experience_history_selecting') })
              linysTitleText({ text: " " + this.selected_number.toString() + " " })
              linysTitleText({ text: $r('app.string.Settings_experience_history_selecting_items') })
            }

            Row() {
              linysSymbol({ symbol_glyph_target: 'sys.symbol.list_checkmask' })
                .onClick(() => {
                  this.select_all();
                })
              Blank()
              Button("  󰀁  ")// Delete
                .type(ButtonType.Capsule)
                .backgroundColor(this.delete_confirm > 0 ? $r('app.color.start_window_background') :
                $r("app.color.font_color_title"))
                .fontColor(this.delete_confirm > 0 ? $r('app.color.font_color_title') :
                $r('app.color.start_window_background'))
                .border({
                  width: 2,
                  color: this.delete_confirm > 0 ? $r('app.color.font_color_title') : "transparent"
                })
                .fontSize(fontSize_Large())
                .fontWeight(FontWeight.Medium)
                .height(capsule_bar_height())
                .onClick(() => {
                  this.delete_confirm += 300;
                  if (this.delete_confirm >= 301) {
                    // Delete
                    this.delete_selected();
                  }
                })
                .clickEffect(click_effect_default())
                .animation(animation_default())
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
      .id("controls_ads_blocker")
      .alignRules(this.alignRules_foot)
      .animation(animation_default())
      .width(this.tablet_mode ? "35%" : "100%")
    }
    .padding(15)
    .width("100%")
    .height("100%")
    .backgroundColor($r('app.color.start_window_background'))
    .onAppear(() => {
      setInterval(() => {
        if (this.delete_confirm > 0) {
          this.delete_confirm -= 1;
        }
        // Reset delete confirm
      }, 10)
    })
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
    webview.AdsBlockManager.addAdsBlockDisallowedList([domain]);
    if (this.adblock_exceptions.includes(domain)) {
      // don't add same domains
      return;
    }
    this.adblock_exceptions.push(domain);
    this.bunch_of_settings.set('adblock_exceptions', this.adblock_exceptions.join("\n"))
  }

  delete_selected() {
    let new_exceptions: string[] = [];
    let delete_exceptions: string[] = [];
    for (let index = 0; index < this.selected.length; index++) {
      if (!this.selected[index]) {
        new_exceptions.push(this.adblock_exceptions[index]);
      } else {
        delete_exceptions.push(this.adblock_exceptions[index]);
      }
    }
    try {
      webview.AdsBlockManager.removeAdsBlockDisallowedList(delete_exceptions);
    } catch (e) {
      console.error(e);
    }
    this.adblock_exceptions = new_exceptions;
    this.delete_confirm = 0;
    this.selecting = false;
    this.selected_number = 0;
    this.selected = this.all_false(this.adblock_exceptions.length);
    this.bunch_of_settings.set('adblock_exceptions', this.adblock_exceptions.join("\n"))
  }
}

export default woofAdsBlocker;

@Component
struct Domain {
  @State domain: string = "huawei.com";
  @Prop index: number;
  @Link selected: boolean[];
  @Link selected_number: number;
  @Prop selecting: boolean;

  build() {
    Column() {
      linysText({
        color: this.selected[this.index] ? $r('app.color.block_color') : $r('app.color.font_color_title'),
        text: this.domain
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .backgroundColor(this.selected[this.index] ? $r('app.color.font_color_title') : $r('app.color.block_color'))
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