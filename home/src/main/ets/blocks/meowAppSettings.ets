import {
  animation_default,
  capsule_bar_height,
  home_url_default_blank,
  minimum_block_width
} from '../hosts/bunch_of_defaults';
import linysTitleText from '../components/linysTitleText';
import linysText from '../components/linysText';
import bundleManager from '@ohos.bundle.bundleManager';
import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@ohos.arkui.advanced.SegmentButton';
import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';
import meowUAManager from './meowUAManager';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import linysCapsuleButton from '../components/linysCapsuleButton';

@Component
struct meowAppSettings {
  // Functions
  @Link settings_title_bar_position: string;
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  // Generals
  @StorageLink('screen_width') screen_width: number = 0;
  @Prop @Watch('on_open_or_close_panel') show: boolean = false;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  // Settings
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State start_up_page_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.Settings_start_up_new_tab') },
      { text: $r('app.string.Settings_start_up_home') },
      { text: $r('app.string.Settings_start_up_continue') }
    ] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State @Watch('on_title_bar_position_changed') title_bar_position_selected: number[] = [0];
  @State @Watch('on_start_up_page_changed') start_up_page_selected: number[] = [0];
  @Link settings_max_bookmark_suggestions: number;
  // Edits
  @State new_tab_url_edit: string = "";
  @State home_url_edit: string = "";

  build() {
    WaterFlow() {
      FlowItem() {
        Column({ space: 15 }) {
          linysTitleText({ text: $r('app.string.Settings_start_up') })
          linysText({ text: $r('app.string.Settings_start_up_page') })
          SegmentButton({
            options: this.start_up_page_tabOptions,
            selectedIndexes: $start_up_page_selected
          })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))

      } // Start up
      .width("100%")

      FlowItem() {
        Column({ space: 15 }) {
          linysTitleText({ text: $r('app.string.Settings_general') })

          // UA
          linysText({ text: $r('app.string.Settings_general_custom_ua') })
          meowUAManager()

          // New tab URL
          linysText({ text: $r('app.string.Settings_general_new_tab_url') })
          TextInput({
            text: this.new_tab_url_edit,
            placeholder: home_url_default_blank(),
          })
            .onChange((value) => {
              this.new_tab_url_edit = value;
            })
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.font_color_title'))
            .caretColor($r('app.color.font_color_title'))
            .selectedBackgroundColor($r('app.color.font_color_title'))
            .onSubmit(() => {
              this.set_new_tab_url_and_kv_store();
            })
            .height(capsule_bar_height())

          linysCapsuleButton({ text: "  󰀻  " })
            .visibility(this.new_tab_url_edit != this.bunch_of_tabs.new_tab_url ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.set_new_tab_url_and_kv_store();
            })
            .alignSelf(ItemAlign.End)
            .animation(animation_default())

          // Home URL
          linysText({ text: $r('app.string.Settings_general_home_url') })
          TextInput({
            text: this.home_url_edit,
            placeholder: home_url_default_blank(),
          })
            .onChange((value) => {
              this.home_url_edit = value;
            })
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.font_color_title'))
            .caretColor($r('app.color.font_color_title'))
            .selectedBackgroundColor($r('app.color.font_color_title'))
            .onSubmit(() => {
              this.set_home_url_and_kv_store();
            })
            .height(capsule_bar_height())

          linysCapsuleButton({ text: "  󰀻  " })
            .visibility(this.home_url_edit != this.bunch_of_tabs.home_url ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.set_home_url_and_kv_store();
            })
            .alignSelf(ItemAlign.End)
            .animation(animation_default())

        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))

      } // General
      .width("100%")

      FlowItem() {
        Column({ space: 15 }) {
          linysTitleText({ text: $r('app.string.Settings_Experience') })
          linysText({ text: $r('app.string.Settings_experience_max_bookmark_advice'), max_lines: 2 })
          Row({ space: 5 }) {
            Slider({
              min: 0,
              max: 5,
              value: this.settings_max_bookmark_suggestions,
              style: SliderStyle.InSet,
            })
              .layoutWeight(1)
              .blockColor($r('app.color.start_window_background'))
              .selectedColor($r('app.color.font_color_title'))
              .onChange((value) => {
                this.settings_max_bookmark_suggestions = value;
                kv_store_put('settings_max_bookmark_suggestions', value.toString());
              })
            linysText({ text: this.settings_max_bookmark_suggestions.toString() })
              .margin({ right: 5 })
          } // Slider and display of max_bookmark_suggestions
        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))

      } // Experience
      .width("100%")

      FlowItem() {
        Column({ space: 15 }) {
          linysTitleText({ text: $r('app.string.Settings_appearance') })
          linysText({ text: $r('app.string.Settings_appearance_title_bar_position') })
          SegmentButton({
            options: this.title_bar_position_tabOptions,
            selectedIndexes: $title_bar_position_selected
          })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))

      } // Appearance
      .width("100%")

      FlowItem() {
        Column({ space: 15 }) {
          linysTitleText({ text: $r('app.string.Settings_about') })
          linysText({ text: "（ฅ＾・ﻌ・＾）ฅ" })
          linysText({ text: this.versionName + " - " + this.versionNo })

        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))

      } // About
      .width("100%")

    } // Bottom Bar of App Settings
    .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width / minimum_block_width())))
    .rowsGap(10)
    .columnsGap(10)
    .height(this.show ? "75%" : 0)
    .padding({ left: 15, right: 15 })
    .width("100%")
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Auto)
    .animation(animation_default())
    .onAppear(() => {
      console.log("[Meow][meowAppSettings] App Settings READY")
      this.on_appear();
      setInterval(() => {
        this.on_interval();
      }, 10)
    })
  }

  // Events

  async on_appear() {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
      this.versionNo = bundleInfo.versionCode;
    })
    // Get app version info

    this.settings_title_bar_position = await kv_store_get('settings_title_bar_position')
    console.log("[Meow][meowAppSettings] Got settings for Title Bar position: " + this.settings_title_bar_position)
    if (this.settings_title_bar_position == ("undefined")) {
      // First open
      kv_store_put('settings_title_bar_position', "bottom");
      this.settings_title_bar_position = "bottom";
    }
    // Get settings of title bar position

    let got: string = "";
    got = await kv_store_get('settings_max_bookmark_suggestions')
    console.log("[Meow][meowBookmarkRelations] Got max bookmark suggestions: " + got)
    if (got == ("undefined")) {
      // First open
      kv_store_put('settings_max_bookmark_suggestions', "5");
      got = "5";
    }
    this.settings_max_bookmark_suggestions = Number.parseInt(got);
    // Get number of max bookmarks suggestions
  }

  on_interval() {

  }

  on_open_or_close_panel() {
    if (this.show) {
      // Open panel
      this.on_panel_open();
    } else {
      // Close panel
      this.on_panel_close();
    }
  }

  on_panel_open() {
    if (this.settings_title_bar_position == "top") {
      this.title_bar_position_selected = [0];
    } else {
      this.title_bar_position_selected = [1];
    }
    if (this.bunch_of_tabs.new_tab_url !== undefined) {
      this.new_tab_url_edit = this.bunch_of_tabs.new_tab_url;
    }
    if (this.bunch_of_tabs.home_url !== undefined) {
      this.home_url_edit = this.bunch_of_tabs.home_url;
    }
    if (this.bunch_of_tabs.start_up !== undefined) {
      let start_up = this.bunch_of_tabs.start_up;
      if (start_up == "new tab") {
        this.start_up_page_selected = [0];
      }
      if (start_up == "home") {
        this.start_up_page_selected = [1];
      }
      if (start_up == "continue") {
        this.start_up_page_selected = [2];
      }
    }
    // Sync Data
  }

  on_panel_close() {

  }

  // On settings changed

  on_title_bar_position_changed() {
    let result: string = "";
    if (this.title_bar_position_selected[0] == 0) {
      result = 'top';
    } else {
      result = 'bottom';
    }
    this.settings_title_bar_position = result;
    kv_store_put('settings_title_bar_position', result);
  }

  on_start_up_page_changed() {
    let result: string = "";
    if (this.start_up_page_selected[0] == 0) {
      result = "new tab";
    } else if (this.start_up_page_selected[0] == 1) {
      result = "home";
    } else {
      result = "continue";
      // Need modify after update
    }
    this.bunch_of_tabs.start_up = result;
    kv_store_put("start_up_option", result);
  }

  // Operations

  set_new_tab_url_and_kv_store() {
    this.bunch_of_tabs.new_tab_url = this.new_tab_url_edit;
    kv_store_put("new_tab_url", this.new_tab_url_edit);
  }

  set_home_url_and_kv_store() {
    this.bunch_of_tabs.home_url = this.home_url_edit;
    kv_store_put("home_url", this.home_url_edit);
  }
}

export default meowAppSettings