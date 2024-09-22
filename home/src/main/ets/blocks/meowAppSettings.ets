import { animation_default, animation_popup_duration, capsule_bar_height, home_url } from '../hosts/bunch_of_settings';
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

@Component
struct meowAppSettings {
  // Functions
  @Link settings_title_bar_position: string;
  @Link now_global_custom_UA: string;
  @Link bunch_of_user_agents: bunch_of_user_agents;
  @Link bunch_of_tabs: bunch_of_tabs;
  // Generals
  @Prop @Watch('on_open_or_close_panel') show: boolean = false;
  @Prop screen_width: number;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  // Settings
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State @Watch('on_title_bar_position_changed') title_bar_position_selected: number[] = [0];
  @State new_tab_url_edit: string = "";
  @State save_new_tab_url_count_down: number = 0;
  @State new_tab_url_saved_popup: number = 0;

  build() {
    WaterFlow() {
      FlowItem() {
        Column({ space: 15 }) {
          linysTitleText({ text: $r('app.string.Settings_start_up') })
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
          linysText({ text: $r('app.string.Settings_general_custom_ua') })
          meowUAManager({
            now_global_custom_UA: this.now_global_custom_UA,
            bunch_of_user_agents: this.bunch_of_user_agents,
          })
          linysText({ text: $r('app.string.Settings_general_new_tab_url') })
          TextInput({
            text: this.new_tab_url_edit,
            placeholder: home_url(),
          })
            .onChange((value) => {
              this.new_tab_url_edit = value;
              this.save_new_tab_url_count_down = 100;
            })
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.font_color_title'))
            .caretColor($r('app.color.font_color_title'))
            .selectedBackgroundColor($r('app.color.font_color_title'))
            .onSubmit(() => {
              this.save_new_tab_url_count_down = 3;
            })
            .height(capsule_bar_height())

          linysText({ text: $r('app.string.Settings_general_new_tab_url_saved') })
            .visibility(this.new_tab_url_saved_popup > 0 ? Visibility.Visible : Visibility.None)
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
    .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width / 430)))
    .rowsGap(10)
    .columnsGap(10)
    .height(this.show ? "75%" : 0)
    .padding({ left: 15, right: 15 })
    .width("100%")
    .edgeEffect(EdgeEffect.Spring)
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
      this.versionName = bundleInfo.versionName; //应用版本名
      this.versionNo = bundleInfo.versionCode; //应用版本号
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

    let new_tab_url_got = await kv_store_get('new_tab_url');
    if (new_tab_url_got == "undefined" || "error") {

    } else {
      this.new_tab_url_edit = new_tab_url_got;
    }
    // Get new tab url
  }

  on_interval() {
    if (this.save_new_tab_url_count_down > 0) {
      this.save_new_tab_url_count_down -= 1;
    }
    if (this.new_tab_url_saved_popup > 0) {
      this.new_tab_url_saved_popup -= 1;
    }
    if (this.save_new_tab_url_count_down == 1) {
      // Save
      this.set_new_tab_url();
    }
  }

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
    // Sync Data
  }

  on_panel_close() {

  }

  // Operations

  set_new_tab_url() {
    this.bunch_of_tabs.new_tab_url = this.new_tab_url_edit;
    this.new_tab_url_saved_popup = animation_popup_duration();
    kv_store_put("new_tab_url", this.new_tab_url_edit);
  }
}

export default meowAppSettings