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
import meowUAManager from './meowUAManager';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import linysCapsuleButton from '../components/linysCapsuleButton';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { sandbox_open } from '../utils/storage_tools';
import woofHistory from '../dialogs/woofHistory';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import meowSEManager from './meowSEManager';

@Component
struct meowAppSettings {
  // Functions
  @Link settings_title_bar_position: string;
  @Link settings_tabs_style: string;
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  // Generals
  @StorageLink('screen_width') screen_width: number = 0;
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @Link @Watch('on_open_or_close_panel') show: boolean;
  @StorageLink('animation_response') animation_response: number = 0;
  @StorageLink('animation_damping_coefficient') animation_damping_coefficient: number = 0;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  @State history_length: number = this.bunch_of_history.history_list.length;
  // Settings
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State tabs_style_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
      { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }] as ItemRestriction<SegmentButtonTextItem>,
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
  @State @Watch('on_tabs_style_changed') tabs_style_selected: number[] = [0];
  @State @Watch('on_start_up_page_changed') start_up_page_selected: number[] = [0];
  @Link settings_max_bookmark_suggestions: number;
  @Link settings_max_history_suggestions: number;
  @Link settings_collect_new_history: boolean;
  // Edits
  @State new_tab_url_edit: string = "";
  @State home_url_edit: string = "";
  // Dialogs
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({ showing_settings: this.show }),
    alignment: DialogAlignment.Center,
    cornerRadius: 12,
    width: "90%",
  })

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

          // UA
          linysText({ text: $r('app.string.Settings_general_custom_search_engine') })
          meowSEManager()

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
                this.bunch_of_settings.set_setting_value_of_key('settings_max_bookmark_suggestions', value);
              })
            linysText({ text: this.settings_max_bookmark_suggestions.toString() })
              .margin({ right: 5 })
          } // Slider and display of max_bookmark_suggestions

          linysText({ text: $r('app.string.Settings_experience_max_history_advice'), max_lines: 2 })
          Row({ space: 5 }) {
            Slider({
              min: 0,
              max: 5,
              value: this.settings_max_history_suggestions,
              style: SliderStyle.InSet,
            })
              .layoutWeight(1)
              .blockColor($r('app.color.start_window_background'))
              .selectedColor($r('app.color.font_color_title'))
              .onChange((value) => {
                this.settings_max_history_suggestions = value;
                this.bunch_of_settings.set_setting_value_of_key('settings_max_history_suggestions', value);
              })
            linysText({ text: this.settings_max_history_suggestions.toString() })
              .margin({ right: 5 })
          } // Slider and display of max_history_suggestions

          linysText({ text: $r('app.string.Settings_experience_history') })

          Row() {
            linysText({ text: $r('app.string.Settings_experience_history_record_new') })
            Blank()
            Toggle({ isOn: this.settings_collect_new_history, type: ToggleType.Switch })
              .switchPointColor($r('app.color.block_color'))
              .selectedColor($r('app.color.font_color_title'))
              .onChange(isOn => {
                this.settings_collect_new_history = isOn;
                this.bunch_of_settings.set_setting_value_of_key('settings_collect_new_history', isOn);
              })
          } // Toggle History
          .width("100%")

          Row({ space: 10 }) {
            linysTitleText({ text: "󰏕 " + this.history_length.toString() })
            Blank()
            linysText({ text: $r('app.string.Settings_experience_history_view') })
            linysCapsuleButton({ text: "  󰀩  " })
              .onClick(() => {
                this.woofHistory_control.open();
              })
          } // History management
          .width("100%")

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

          linysText({ text: $r('app.string.Settings_appearance_tabs_style') })
          SegmentButton({
            options: this.tabs_style_tabOptions,
            selectedIndexes: $tabs_style_selected
          })

          linysText({ text: $r('app.string.Settings_appearance_animation_response') })
          Row({ space: 5 }) {
            Slider({
              min: 1,
              max: 100,
              value: this.animation_response,
              style: SliderStyle.InSet,
            })
              .layoutWeight(1)
              .blockColor($r('app.color.start_window_background'))
              .selectedColor($r('app.color.font_color_title'))
              .onChange((value) => {
                this.animation_response = value;
              })
              .onTouch(e => {
                if (e.type == TouchType.Up) {
                  this.bunch_of_settings.set_setting_value_of_key('animation_response', this.animation_response);
                }
              })
            linysText({ text: (this.animation_response / 100).toFixed(2) })
              .margin({ right: 5 })
          } // Slider and display of animation_response

          linysText({ text: $r('app.string.Settings_appearance_animation_damping_coefficient') })
          Row({ space: 5 }) {
            Slider({
              min: 0,
              max: 75,
              value: this.animation_damping_coefficient,
              style: SliderStyle.InSet,
            })
              .layoutWeight(1)
              .blockColor($r('app.color.start_window_background'))
              .selectedColor($r('app.color.font_color_title'))
              .onChange((value) => {
                this.animation_damping_coefficient = value;
              })
              .onTouch(e => {
                if (e.type == TouchType.Up) {
                  this.bunch_of_settings.set_setting_value_of_key('animation_damping_coefficient',
                    this.animation_damping_coefficient);
                }
              })
            linysText({ text: (this.animation_damping_coefficient / 100).toFixed(2) })
              .margin({ right: 5 })
          } // Slider and display of animation damping coefficient
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
    })
  }

  // Events

  async on_appear() {
    // Get app version info
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
      this.versionNo = bundleInfo.versionCode;
    })

    // Get settings of title bar position
    this.settings_title_bar_position =
      await this.bunch_of_settings.get_setting_key('settings_title_bar_position') as string;

    // Get settings of title bar position
    this.settings_tabs_style =
      await this.bunch_of_settings.get_setting_key('settings_tabs_style') as string;

    // Get number of max bookmarks suggestions
    this.settings_max_bookmark_suggestions =
      await this.bunch_of_settings.get_setting_key('settings_max_bookmark_suggestions') as number;

    // Get number of max history suggestions
    this.settings_max_history_suggestions =
      await this.bunch_of_settings.get_setting_key('settings_max_history_suggestions') as number;

    // Get whether to continue to collect new history
    this.settings_collect_new_history =
      await this.bunch_of_settings.get_setting_key('settings_collect_new_history') as boolean;

    let result = await sandbox_open("history.txt");
    if (result as string == "undefined") {
      // no history before
      console.log("[Meow][meowAppSettings] NO HISTORY BEFORE")
    } else {
      this.bunch_of_history.import_string(result as string);
      console.log("[Meow][meowAppSettings] Recovered History, length: " + result.length.toString())
    }
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
    // Sync Data
    if (this.settings_title_bar_position == "top") {
      this.title_bar_position_selected = [0];
    } else {
      this.title_bar_position_selected = [1];
    }
    if (this.settings_tabs_style == "vertical") {
      this.tabs_style_selected = [0];
    } else {
      this.tabs_style_selected = [1];
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
    // Get length properties
    this.history_length = this.bunch_of_history.history_list.length;
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
    this.bunch_of_settings.set_setting_value_of_key('settings_title_bar_position', result);
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
    // kv_store_put("start_up_option", result);
    this.bunch_of_settings.set_setting_value_of_key('start_up_option', result);
  }

  on_tabs_style_changed() {
    let result: string = "";
    if (this.tabs_style_selected[0] == 0) {
      result = 'vertical';
    } else {
      result = 'horizontal';
    }
    this.settings_tabs_style = result;
    this.bunch_of_settings.set_setting_value_of_key('settings_tabs_style', result);
  }

  // Operations

  set_new_tab_url_and_kv_store() {
    this.bunch_of_tabs.new_tab_url = this.new_tab_url_edit;
    // kv_store_put("new_tab_url", this.new_tab_url_edit);
    this.bunch_of_settings.set_setting_value_of_key('new_tab_url', this.new_tab_url_edit);
  }

  set_home_url_and_kv_store() {
    this.bunch_of_tabs.home_url = this.home_url_edit;
    // kv_store_put("home_url", this.home_url_edit);
    this.bunch_of_settings.set_setting_value_of_key('home_url', this.home_url_edit);
  }
}

export default meowAppSettings