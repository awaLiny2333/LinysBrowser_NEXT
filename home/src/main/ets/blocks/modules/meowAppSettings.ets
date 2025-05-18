import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large,
  minimum_card_width,
  url_default_blank
} from '../../hosts/bunch_of_defaults';
import linysTitleText from '../../components/linysTitleText';
import linysText from '../../components/linysText';
import bundleManager from '@ohos.bundle.bundleManager';
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import meowUAManager from '../panels/meowUAManager';
import { bunch_of_user_agents } from '../../hosts/bunch_of_user_agents';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import linysCapsuleButton from '../../components/linysCapsuleButton';
import { bunch_of_history, fill_fake_history } from '../../hosts/bunch_of_history';
import { add_units_to_size, arrayBuffer_to_pixelMap, get_folder_size_Sync, sandbox_open_arrayBuffer_sync } from '../../utils/storage_tools';
import woofHistory from '../../dialogs/managers/woofHistory';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import meowSEManager from '../panels/meowSEManager';
import linysLink from '../../components/linysLink';
import woofAdsBlocker from '../../dialogs/managers/woofAdsBlocker';
import meowWhatsNew from '../contents/meowWhatsNew';
import meowColorsManager from '../panels/meowColorsManager';
import { BusinessError } from '@kit.BasicServicesKit';
import meowCreditsRepos from '../contents/meowCreditsRepos';
import meowCreditsUsers from '../contents/meowCreditsUsers';
import woofCookies from '../../dialogs/managers/woofCookies';
import woofGeneralManage from '../../dialogs/managers/woofGeneralManage';
import woofKeyShortcuts from '../../dialogs/managers/woofKeyShortcuts';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import woofHomepageManager from '../../dialogs/managers/woofHomepageManager';
import meowAnimationManager from '../panels/meowAnimationManager';
import linysLockSlider from '../../components/linysLockSlider';
import linysTimeoutButton from '../../components/linysTimeoutButton';
import { get_sandbox_folder_size } from '../../utils/any_concurrent_tools';
import woofRecentFaultLogs from '../../dialogs/contents/woofRecentFaultLogs';
import { bunch_of_history_index } from '../../hosts/bunch_of_history_index';
import {
  history_index_full_rebuild_worker,
  history_index_load_from_disk_worker,
  history_index_save_to_disk_worker
} from '../../hosts/bunch_of_history_index_x_functions';
import { bunch_of_history_index_lite } from '../../hosts/bunch_of_history_index_lite';

@Component
struct meowAppSettings {
  @Link @Watch('on_open_or_close_panel') showing_app_settings: boolean;
  // Hosts and environment
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  @StorageLink('title_bar_position') title_bar_position: string = "";
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts =
    new bunch_of_key_shortcuts(true);
  @StorageLink('bunch_of_history_index') bunch_of_history_index: bunch_of_history_index = new bunch_of_history_index();
  @StorageLink('homepage_background') homepage_background: PixelMap | undefined = undefined;
  // Colors
  @StorageProp('color_current_primary') @Watch('on_color_change') color_current_primary: ResourceColor =
    $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') @Watch('on_color_change') color_current_secondary: ResourceColor =
    $r('app.color.block_color');
  @StorageProp('color_current_font') @Watch('on_color_change') color_current_font: ResourceColor =
    $r('app.color.font_color_title');
  // Generals
  @StorageProp('screen_width') screen_width: number = 0;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  @State history_length: number = this.bunch_of_history.get_history_this_month().length;
  // Segment Button Options
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  @State tabs_style_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
      { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  @State tabs_style_tabOptions_non_tablet_mode: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
      { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  @State start_up_page_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.Settings_start_up_new_tab') },
      { text: $r('app.string.Settings_start_up_home') },
      { text: $r('app.string.Settings_start_up_continue') }
    ] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  @State left_or_right: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '󰃊' }, { text: '󰈱' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  // Settings
  @StorageLink('DEV_MODE') DEV_MODE: boolean = false;
  @State @Watch('on_title_bar_position_changed') title_bar_position_selected: number[] = [0];
  @State @Watch('on_tabs_style_changed') tabs_style_selected: number[] = [0];
  @State @Watch('on_tabs_style_non_tablet_mode_changed') tabs_style_selected_non_tablet_mode: number[] = [0];
  @State @Watch('on_start_up_page_changed') start_up_page_selected: number[] = [0];
  @State @Watch('on_prefer_hand_left_or_right_changed') prefer_hand_left_or_right_selected: number[] = [0];
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('max_bookmark_advice') max_bookmark_advice: number = 5;
  @StorageLink('max_history_advice') max_history_advice: number = 5;
  @StorageLink('sys_back_to_access_backward') sys_back_to_access_backward: boolean = false;
  @StorageLink('resource_monitor') resource_monitor: boolean = true;
  @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = false;
  @StorageLink('use_adblock') use_adblock: boolean = true;
  @StorageLink('collect_new_history') collect_new_history: boolean = true;
  @StorageLink('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
  @StorageLink('disable_js') disable_js: boolean = true;
  @StorageLink('disable_js_these_sites') disable_js_these_sites: string[] = [];
  @StorageLink('disable_js_all_sites') disable_js_all_sites: boolean = false;
  @StorageLink('disable_image') disable_image: boolean = true;
  @StorageLink('disable_image_these_sites') disable_image_these_sites: string[] = [];
  @StorageLink('disable_image_all_sites') disable_image_all_sites: boolean = false;
  // Edits
  @State new_tab_url_edit: string = "";
  @State home_url_edit: string = "";
  @State lock_bookmark_suggestion_number: boolean = true;
  @State lock_history_suggestion_number: boolean = true;
  // Scroll menu
  @State @Watch('scroll_settings_to') settings_scroll_to: number = 0;
  @State scroll_first: number = 0;
  @State scroll_last: number = 0;
  @State menu_text: string[] =
    ['Settings_start_up', 'Settings_general', 'Settings_Experience', 'Settings_appearance',
      'Settings_experience_history', 'Settings_storage', 'Settings_security', 'Settings_toolbox', 'Settings_about'];
  // Dialogs
  @StorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({ showing_settings: this.showing_app_settings }),
    alignment: DialogAlignment.Center,
    cornerRadius: 22,
    showInSubWindow: true,
    width: "90%",
  });
  adsBlocker_control: CustomDialogController = new CustomDialogController({
    builder: woofAdsBlocker(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });
  js_manage_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.disable_js,
      general_on_all_sites_switch: this.disable_js_all_sites,
      general_sites_list: this.disable_js_these_sites
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });
  image_manage_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.disable_image,
      general_sites_list: this.disable_image_these_sites,
      general_on_all_sites_switch: this.disable_image_all_sites,
      general_descriptions: [
        $r('app.string.Settings_image_desc_1'),
        $r('app.string.Settings_image_desc_2'),
        $r('app.string.Settings_image_desc_3')],
      general_tips: $r('app.string.Settings_image_already_disabled'),
      general_title: $r('app.string.Settings_image_manage'),
      general_switch_desc: $r('app.string.Settings_image_disable_image'),
      general_subtitle_execute_on_these_sites: $r('app.string.Settings_image_some_sites'),
      general_subtitle_execute_on_all_sites: $r('app.string.Settings_image_all_sites'),
      general_switch_settings_id: 'disable_image',
      general_sites_list_settings_id: 'disable_image_these_sites',
      general_switch_all_sites_settings_id: 'disable_image_all_sites',
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });
  cookies_control: CustomDialogController = new CustomDialogController({
    builder: woofCookies(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });
  key_shortcuts_control: CustomDialogController = new CustomDialogController({
    builder: woofKeyShortcuts(),
    alignment: DialogAlignment.Center,
    cornerRadius: 22,
    showInSubWindow: true,
    width: "90%",
  });
  homepage_shortcuts_control: CustomDialogController = new CustomDialogController({
    builder: woofHomepageManager(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    // width: "90%",
  });
  recent_fault_logs_control: CustomDialogController = new CustomDialogController({
    builder: woofRecentFaultLogs(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });
  waterFlow_control: Scroller = new Scroller();
  // Else
  @State clear_web_cache_confirm: number = 0;
  @State web_cache_size: number = 0;
  @State history_index_size: number = 0;
  @State version_clicked_times: number = 0;
  // Status
  @StorageLink('settings_init_retrieved') settings_init_retrieved: boolean = false;
  @State calculating_web_cache_size: boolean = false;
  @State calculating_history_index_size: boolean = false;
  @StorageLink('reindexing_history') reindexing_history: boolean = false;
  @StorageLink('reindexing_history_progress') reindexing_history_progress: number = 100;

  build() {
    Row() {
      if (this.tablet_mode) {
        menuScrollVertical({
          on_index_first: this.scroll_first,
          on_index_last: this.scroll_last,
          scroll_to_gateway: this.settings_scroll_to,
          menu_text: this.menu_text,
        })
          .margin({ left: 15 })
      } // Quick access on the left
      Column({ space: 10 }) {
        if (!this.tablet_mode) {
          menuScrollHorizontal({
            on_index_first: this.scroll_first,
            on_index_last: this.scroll_last,
            scroll_to_gateway: this.settings_scroll_to,
            menu_text: this.menu_text,
          })
            .margin({ left: 15, right: 15 })
        } // Quick access on the top
        WaterFlow({ scroller: this.waterFlow_control }) {
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
            .backgroundColor(this.color_current_primary)

          } // Start up
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_general') })

              // UA
              linysText({ text: $r('app.string.Settings_general_custom_ua') })
              meowUAManager()

              // Search Engine
              linysText({ text: $r('app.string.Settings_general_custom_search_engine') })
              meowSEManager()

              // New tab URL
              linysText({ text: $r('app.string.Settings_general_new_tab_url') })
              TextInput({
                text: this.new_tab_url_edit,
                placeholder: url_default_blank(),
              })
                .onChange((value) => {
                  this.new_tab_url_edit = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
                .onSubmit(() => {
                  this.set_new_tab_url_and_kv_store();
                })
                .height(capsule_bar_height())

              linysCapsuleButton({ text: "  󰀻  " })
                .visibility(this.new_tab_url_edit != this.bunch_of_tabs.new_tab_url ? Visibility.Visible :
                Visibility.None)
                .onClick(() => {
                  this.set_new_tab_url_and_kv_store();
                })
                .alignSelf(ItemAlign.End)
                .animation(animation_default())

              // Home URL
              linysText({ text: $r('app.string.Settings_general_home_url') })
              TextInput({
                text: this.home_url_edit,
                placeholder: url_default_blank(),
              })
                .onChange((value) => {
                  this.home_url_edit = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
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
            .backgroundColor(this.color_current_primary)

          } // General
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_Experience') })

              linysText({ text: $r('app.string.Settings_single_hand_preference'), max_lines: 3 })
                .width("100%")
              SegmentButton({
                options: this.left_or_right,
                selectedIndexes: $prefer_hand_left_or_right_selected
              }) // Single hand usability

              Row() {
                linysText({ text: $r('app.string.Settings_experience_web_force_dark_mode'), max_lines: 3 })
                  .layoutWeight(1)
                Toggle({ isOn: this.web_force_dark_mode, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.web_force_dark_mode = isOn;
                    this.bunch_of_settings.set('web_force_dark_mode', isOn);
                  })
              } // Force dark mode
              .width("100%")

              Row() {
                linysText({ text: $r('app.string.Settings_experience_sys_back_to_access_backward'), max_lines: 3 })
                  .layoutWeight(1)
                Toggle({ isOn: this.sys_back_to_access_backward, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.sys_back_to_access_backward = isOn;
                    this.bunch_of_settings.set('sys_back_access_backward', isOn);
                  })
              } // Use sys back
              .width("100%")

              Row() {
                linysText({ text: $r('app.string.Settings_experience_use_adblock'), max_lines: 1 })
                  .layoutWeight(1)
                Toggle({ isOn: this.use_adblock, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.use_adblock = isOn;
                    this.bunch_of_settings.set('use_adblock', isOn);
                  })
              } // Use adblock
              .width("100%")

              Row({ space: 10 }) {
                linysText({
                  text: $r('app.string.Settings_experience_manage_adblock'),
                  max_lines: 3,
                  align_another_side: true
                })
                  .layoutWeight(1)
                linysCapsuleButton({ text: "  󰀠  " })
                  .onClick(() => {
                    this.adsBlocker_control.open();
                  })
              } // Ads Blocker management
              .width("100%")

              Row() {
                linysText({ text: $r('app.string.Settings_image_disable_image'), max_lines: 1 })
                  .layoutWeight(1)
                Toggle({ isOn: this.disable_image, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.disable_image = isOn;
                    this.bunch_of_settings.set('disable_image', isOn);
                  })
              } // Disable images
              .width("100%")

              Row({ space: 10 }) {
                linysText({ text: $r('app.string.Settings_image_manage'), max_lines: 3, align_another_side: true })
                  .layoutWeight(1)
                linysCapsuleButton({ text: "  󰀠  " })
                  .onClick(() => {
                    this.image_manage_control.open();
                  })
              } // Disable image management
              .width("100%")

              linysText({ text: $r('app.string.Key_shortcuts') })
                .width('100%')
              Row({ space: 10 }) {
                linysText({ text: $r('app.string.Key_shortcuts_manage'), max_lines: 3, align_another_side: true })
                  .layoutWeight(1)
                linysCapsuleButton({ text: "  󰀠  " })
                  .onClick(() => {
                    this.key_shortcuts_control.open();
                  })
              } // Keyboard shortcuts management
              .width("100%")

              linysText({ text: $r('app.string.Settings_homepage'), max_lines: 3 }) // Homepage Customization
              Row({ space: 10 }) {
                linysText({
                  text: $r('app.string.Settings_homepage_customization'),
                  max_lines: 3,
                  align_another_side: true
                })
                  .layoutWeight(1)
                linysCapsuleButton({ text: "  󰀠  " })
                  .onClick(() => {
                    this.homepage_shortcuts_control.open();
                  })
              }
              .width("100%")

              linysText({ text: $r('app.string.Settings_experience_max_bookmark_advice'), max_lines: 2 })
              linysLockSlider({
                slider_min: 0,
                slider_max: 20,
                slider_value: this.max_bookmark_advice,
                onTouchUp: () => {
                  this.bunch_of_settings.set('max_bookmark_suggest', this.max_bookmark_advice);
                }
              }) // Slider and display of max_bookmark_suggestions

              linysText({ text: $r('app.string.Settings_experience_max_history_advice'), max_lines: 2 })
              linysLockSlider({
                slider_min: 0,
                slider_max: 20,
                slider_value: this.max_history_advice,
                onTouchUp: () => {
                  this.bunch_of_settings.set('max_history_suggest', this.max_history_advice);
                }
              }) // Slider and display of max_history_suggestions

            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor(this.color_current_primary)

          } // Experience
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_appearance') }) // Appearance Title

              linysText({ text: $r('app.string.Settings_appearance_title_bar_position') }) // Title bar position
              SegmentButton({
                options: this.title_bar_position_tabOptions,
                selectedIndexes: $title_bar_position_selected
              })

              linysText({
                text: $r('app.string.Settings_appearance_tabs_style')
              }) // Tabs Style for tablets and landscape displays
              SegmentButton({
                options: this.tabs_style_tabOptions,
                selectedIndexes: $tabs_style_selected
              })

              linysText({
                text: $r('app.string.Settings_appearance_tabs_style_non_tablet_mode')
              }) // Tabs Style for mobile and portrait displays
              SegmentButton({
                options: this.tabs_style_tabOptions_non_tablet_mode,
                selectedIndexes: $tabs_style_selected_non_tablet_mode
              })

              meowAnimationManager() // Animation manager

              meowColorsManager() // Colors manager
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor(this.color_current_primary)

          } // Appearance
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {

              linysTitleText({ text: $r('app.string.Settings_experience_history') }) // History

              Row() {
                linysText({ text: $r('app.string.Settings_experience_history_record_new') })
                Blank()
                Toggle({ isOn: this.collect_new_history, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.collect_new_history = isOn;
                    this.bunch_of_settings.set('collect_new_history', isOn);
                  })
              } // Toggle History
              .width("100%")

              Row({ space: 10 }) {
                // linysTitleText({ text: "󰏕 " + this.history_length.toString() })
                linysText({
                  text: $r('app.string.Settings_experience_history_view'),
                  max_lines: 3,
                  align_another_side: true
                })
                  .layoutWeight(1)
                linysCapsuleButton({ text: "  󰀩  " })
                  .onClick(() => {
                    this.woofHistory_control.open();
                  })
                  .keyboardShortcut(this.bunch_of_key_shortcuts.history.main_key,
                    this.bunch_of_key_shortcuts.history.modifier)
              } // History management
              .width("100%")

              linysText({ text: $r('app.string.Settings_experience_history_index_desc'), max_lines: 20 })

              Row({ space: 10 }) {
                // linysTitleText({ text: "󰏕 " + this.history_length.toString() })
                linysText({
                  text: $r('app.string.Settings_experience_history_index'),
                  max_lines: 3,
                  align_another_side: true
                })
                  .layoutWeight(1)

                linysTimeoutButton({
                  text: "  󰏕  ",
                  onExecution: () => {
                    history_index_full_rebuild_worker();
                  }
                })
                  .opacity(this.reindexing_history ? 0.4 : 1)
                  .enabled(!this.reindexing_history)
              } // History indexing
              .width("100%")

              if (this.DEV_MODE) {
                linysTimeoutButton({
                  text: " Fill test data ",
                  onExecution: () => {
                    fill_fake_history(500000);
                  }
                })
                  .opacity(this.reindexing_history ? 0.4 : 1)
                  .enabled(!this.reindexing_history)
                  .animation(animation_default())

                linysCapsuleButton({ text: ' Load from disk ' })
                  .onClick(() => {
                    history_index_load_from_disk_worker("normal");
                  })
                  .opacity(this.reindexing_history ? 0.4 : 1)
                  .enabled(!this.reindexing_history)
                  .animation(animation_default())

                linysCapsuleButton({ text: ' Save Month to disk ' })
                  .onClick(() => {
                    history_index_save_to_disk_worker(bunch_of_history_index_lite.index_map, bunch_of_history_index_lite.this_file_name(), false);
                  })
                  .opacity(this.reindexing_history ? 0.4 : 1)
                  .enabled(!this.reindexing_history)
                  .animation(animation_default())
              }
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor(this.color_current_primary)

          } // History
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_storage') }) // Storage Title

              linysText({ text: $r('app.string.Settings_storage_clear_webview') })
              linysText({ text: $r('app.string.Settings_storage_clear_webview_desc'), max_lines: 6 })

              Column({ space: 10 }) {
                linysTitleText({ text: "󰂼 " + add_units_to_size(this.web_cache_size) })// data display
                  .clickEffect(click_effect_default())

                Row({ space: 12 }) {
                  Blank()
                  linysCapsuleButton({ text: '  󰃈  ' })
                    .onClick(() => {
                      this.refresh_web_cache_size();
                    })
                    .opacity(this.calculating_web_cache_size ? 0.4 : 1)
                    .enabled(!this.calculating_web_cache_size)
                    .animation(animation_default())

                  linysTimeoutButton({
                    text: '  󰀖  ',
                    onExecution: () => {
                      try {
                        this.bunch_of_tabs.Tabs[0].controller.removeCache(true);
                        console.log('[Meow][meowAppSettings] Clear webview cache!')
                      } catch (error) {
                        console.error(`[Meow][meowAppSettings] Clear webview cache.
                      ErrorCode: ${(error as BusinessError).code},
                      Message: ${(error as BusinessError).message}`);
                      }
                      this.refresh_web_cache_size();
                    }
                  })// Clear Cache
                    .opacity(this.calculating_web_cache_size ? 0.4 : 1)
                    .enabled(!this.calculating_web_cache_size)
                    .animation(animation_default())

                } // buttons
                .width("100%")
              } // Web Cache data display and button
              .alignItems(HorizontalAlign.Start)

              linysText({ text: $r('app.string.Settings_experience_history_index_storage_desc'), max_lines: 6 })

              Column({ space: 10 }) {
                linysTitleText({ text: "󰏕 " + add_units_to_size(this.history_index_size) })// data display
                  .clickEffect(click_effect_default())

                Row({ space: 12 }) {
                  Blank()
                  linysCapsuleButton({ text: '  󰃈  ' })
                    .onClick(() => {
                      this.refresh_history_index_size();
                    })
                    .opacity(this.calculating_history_index_size ? 0.4 : 1)
                    .enabled(!this.calculating_history_index_size)
                    .animation(animation_default())
                } // buttons
                .width("100%")
              } // History Index data display and button
              .alignItems(HorizontalAlign.Start)
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor(this.color_current_primary)
          } // Storage
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_security') }) // Security Title

              linysText({
                text: $r('app.string.intelligent_tracking_prevention_desc'),
                max_lines: 10
              })
                .width("100%")

              Row({ space: 10 }) {
                linysText({ text: $r('app.string.intelligent_tracking_prevention'), max_lines: 4 })
                  .layoutWeight(1)

                Toggle({ isOn: this.intelligent_tracking_prevention, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.intelligent_tracking_prevention = isOn;
                    this.bunch_of_settings.set('intelligent_tracking_prevention', isOn);
                    for (let index = 0; index < this.bunch_of_tabs.Tabs.length; index++) {
                      try {
                        this.bunch_of_tabs.Tabs[index].controller.enableIntelligentTrackingPrevention(isOn);
                        console.log('[Meow][meowAppSettings] Intelligent Tracking Prevention now ' + isOn.toString() +
                          '!')
                      } catch (e) {
                        console.log('[Meow][meowAppSettings] Toggle Intelligent Tracking Prevention Failed! ' +
                          'But perhaps this doesn\'t really matter?')
                        // In most cases this fails on app launch, because the webViews are not initialized.
                        // If the user has set this settings to true, then this will be triggered since the default is false
                        // But at that moment webViews are not initialized, with controllers linked accordingly
                        // So this would cause 'Init error. The WebviewController must be associated with a Web component'
                        // I guess :O
                        // Let's see if this works
                      }
                    }
                  })
              } // Toggle Intelligent Tracking Prevention
              .width("100%")

              Row({ space: 10 }) {
                linysText({ text: $r('app.string.Settings_manage_cookies'), max_lines: 3, align_another_side: true })
                  .layoutWeight(1)
                linysCapsuleButton({ text: '  󰀩  ' })
                  .onClick(() => {
                    this.cookies_control.open();
                  })
              } // Cookie management
              .width("100%")

              Row() {
                linysText({ text: $r('app.string.Settings_js_disable_js'), max_lines: 4 })
                  .layoutWeight(1)
                Toggle({ isOn: this.disable_js, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.disable_js = isOn;
                    this.bunch_of_settings.set('disable_js', isOn);
                  })
              } // Toggle Disable JS
              .width("100%")

              Row({ space: 10 }) {
                Blank()
                linysText({ text: $r('app.string.Settings_js_manage') })
                linysCapsuleButton({ text: '  󰀠  ' })
                  .onClick(() => {
                    this.js_manage_control.open();
                  })
              } // JS management
              .width("100%")
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor(this.color_current_primary)
          } // Security
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_toolbox') })
              Row({ space: 5 }) {
                linysText({ text: $r('app.string.Settings_toolbox_resource_monitor'), max_lines: 3 })
                  .layoutWeight(1)
                Toggle({ isOn: this.resource_monitor, type: ToggleType.Switch })
                  .switchPointColor(this.color_current_secondary)
                  .selectedColor(this.color_current_font)
                  .onChange(isOn => {
                    this.resource_monitor = isOn;
                    this.bunch_of_settings.set('resource_monitor', isOn);
                  })
              } // Show Resource Monitor
              .width("100%")

              linysText({ text: $r('app.string.Fault_logs_desc'), max_lines: 10 })
              Row({ space: 10 }) {
                Blank()
                linysText({ text: $r('app.string.Fault_logs') })
                linysCapsuleButton({ text: '  󰀩  ' })
                  .onClick(() => {
                    this.recent_fault_logs_control.open();
                  })
              } // Fault logs display
              .width("100%")

              if (this.DEV_MODE) {
                linysTimeoutButton({
                  text: " Temp Code ",
                  onExecution: () => {

                  }
                })
              }
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor(this.color_current_primary)
          } // Toolbox cardboard box
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_about') })
              linysLink({
                will_be_reversed_boolean: this.showing_app_settings,
                text: $r('app.string.About_bilibili'),
                link: "https://space.bilibili.com/678438347",
              }) // bili
              linysLink({
                will_be_reversed_boolean: this.showing_app_settings,
                text: $r('app.string.About_GitHub'),
                link: "https://github.com/awaLiny2333/LinysBrowser_NEXT",
              }) // GitHub
              linysLink({
                will_be_reversed_boolean: this.showing_app_settings,
                text: $r('app.string.About_Gitee'),
                link: "https://gitee.com/awa_Liny/LinysBrowser_NEXT",
              }) // Gitee
              linysText({
                text: "（ฅ＾・ﻌ・＾）ฅ  - " + this.versionName + " - " + this.versionNo,
                max_lines: 3
              })// Version Info
                .onClick(() => {
                  this.version_clicked();
                })
              meowWhatsNew()
              meowCreditsRepos()
              meowCreditsUsers()
              linysText({
                text: $r("app.string.Credits_extra"),
                max_lines: 6
              })
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor(this.color_current_primary)
          } // About
          .width("100%")

        } // Bottom Bar of App Settings
        .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width / minimum_card_width())))
        .rowsGap(10)
        .columnsGap(10)
        .padding({ left: 15, right: 15 })
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Auto)
        .width("100%")
        .layoutWeight(1)
        .animation(animation_default())
        .onScrollIndex((first, last) => {
          this.scroll_first = first;
          this.scroll_last = last;
        })
      } // Main
      .layoutWeight(1)
      .height("100%")
      .animation(animation_default())
    }
    .height(this.showing_app_settings ? "75%" : 0)
    .width("100%")
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

    // Get DEV_MODE
    this.DEV_MODE = await this.bunch_of_settings.get('DEV_MODE') as boolean;

    // Get settings of title bar position
    this.title_bar_position = await this.bunch_of_settings.get('title_bar_position') as string;

    // Get settings of tabs style
    this.tabs_style = await this.bunch_of_settings.get('tabs_style') as string;

    // Get settings of tabs style
    this.tabs_style_non_tablet_mode = await this.bunch_of_settings.get('tabs_style_non_tablet_mode') as string;

    // Get number of max bookmarks suggestions
    this.max_bookmark_advice = await this.bunch_of_settings.get('max_bookmark_suggest') as number;

    // Get number of max history suggestions
    this.max_history_advice = await this.bunch_of_settings.get('max_history_suggest') as number;

    // Get whether to continue to collect new history
    this.collect_new_history = await this.bunch_of_settings.get('collect_new_history') as boolean;

    // Get whether to continue to enable intelligent_tracking_prevention
    this.intelligent_tracking_prevention = await this.bunch_of_settings.get('intelligent_tracking_prevention') as boolean;

    // Get whether to use system back to access backward
    this.sys_back_to_access_backward = await this.bunch_of_settings.get('sys_back_access_backward') as boolean;

    // Get whether to enable forced webs dark mode
    this.web_force_dark_mode = await this.bunch_of_settings.get('web_force_dark_mode') as boolean;

    // Read history
    bunch_of_history.check_disk_month(new Date().getUTCFullYear(), new Date().getUTCMonth() + 1);

    // Read webview cache
    this.web_cache_size = await this.bunch_of_settings.get('webview_cache_size') as number;
    if (this.web_cache_size == -1) {
      this.web_cache_size = get_folder_size_Sync('/data/storage/el2/base/cache/web', true);
      this.bunch_of_settings.set('webview_cache_size', this.web_cache_size);
    }

    // Set homepage background
    let homepage_background_array_buffer = sandbox_open_arrayBuffer_sync('homepage_background_arrayBuffer');
    // Set image for homepage
    if (homepage_background_array_buffer) {
      this.homepage_background = arrayBuffer_to_pixelMap(homepage_background_array_buffer);
      console.log("[Meow][meowAppSettings] Finished loading homepage background!");
    }

    // Get settings of shortcuts on left or right
    this.preferred_hand_left_or_right = await this.bunch_of_settings.get('preferred_hand_left_or_right') as string;
    if (this.preferred_hand_left_or_right == 'left') {
      this.prefer_hand_left_or_right_selected = [0];
    } else {
      this.prefer_hand_left_or_right_selected = [1];
    }

    // Get Homepage shortcut directory
    let homepage_shortcuts_bookmarks_dir = await this.bunch_of_settings.get('homepage_shortcuts_bookmarks_dir') as string;
    AppStorage.set('homepage_shortcuts_bookmarks_dir', homepage_shortcuts_bookmarks_dir);
    console.log("[Meow][meowAppSettings] Finished loading homepage shortcuts dir: " + homepage_shortcuts_bookmarks_dir);

    // Get whether to show resource monitor
    this.resource_monitor = await this.bunch_of_settings.get('resource_monitor') as boolean;

    // History indexer
    this.history_index_size = await this.bunch_of_settings.get('history_index_size') as number;

    // Tag status
    this.settings_init_retrieved = true;
  }

  on_open_or_close_panel() {
    if (this.showing_app_settings) {
      // Open panel
      this.on_panel_open();
    } else {
      // Close panel
      this.on_panel_close();
    }
    // Get length properties
    this.history_length = this.bunch_of_history.get_history_this_month().length;
  }

  on_panel_open() {
    // Sync Data
    if (this.title_bar_position == "top") {
      this.title_bar_position_selected = [0];
    } else {
      this.title_bar_position_selected = [1];
    }
    if (this.tabs_style == "vertical") {
      this.tabs_style_selected = [0];
    } else {
      this.tabs_style_selected = [1];
    }
    if (this.tabs_style_non_tablet_mode == "vertical") {
      this.tabs_style_selected_non_tablet_mode = [0];
    } else {
      this.tabs_style_selected_non_tablet_mode = [1];
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
    // Calculate web cache size
    // this.web_cache_size = get_folder_size_Sync('/data/storage/el2/base/cache/web/Cache', true)
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
    this.title_bar_position = result;
    this.bunch_of_settings.set('title_bar_position', result);
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
    this.bunch_of_settings.set('start_up_option', result);
  }

  on_tabs_style_changed() {
    let result: string = "";
    if (this.tabs_style_selected[0] == 0) {
      result = 'vertical';
    } else {
      result = 'horizontal';
    }
    this.tabs_style = result;
    this.bunch_of_settings.set('tabs_style', result);
  }

  on_tabs_style_non_tablet_mode_changed() {
    let result: string = "";
    if (this.tabs_style_selected_non_tablet_mode[0] == 0) {
      result = 'vertical';
    } else {
      result = 'horizontal';
    }
    this.tabs_style_non_tablet_mode = result;
    this.bunch_of_settings.set('tabs_style_non_tablet_mode', result);
  }

  on_color_change() {
    this.title_bar_position_tabOptions = SegmentButtonOptions.tab({
      buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
      selectedBackgroundColor: this.color_current_font,
      selectedFontColor: this.color_current_primary
    })
    this.tabs_style_tabOptions = SegmentButtonOptions.tab({
      buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
        { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }] as ItemRestriction<SegmentButtonTextItem>,
      selectedBackgroundColor: this.color_current_font,
      selectedFontColor: this.color_current_primary
    })
    this.start_up_page_tabOptions = SegmentButtonOptions.tab({
      buttons: [
        { text: $r('app.string.Settings_start_up_new_tab') },
        { text: $r('app.string.Settings_start_up_home') },
        { text: $r('app.string.Settings_start_up_continue') }
      ] as ItemRestriction<SegmentButtonTextItem>,
      selectedBackgroundColor: this.color_current_font,
      selectedFontColor: this.color_current_primary
    })
  }

  // Events

  on_prefer_hand_left_or_right_changed() {
    if (this.prefer_hand_left_or_right_selected[0] == 0) {
      this.bunch_of_settings.set('preferred_hand_left_or_right', 'left');
      this.preferred_hand_left_or_right = 'left';
    } else {
      this.bunch_of_settings.set('preferred_hand_left_or_right', 'right');
      this.preferred_hand_left_or_right = 'right';
    }
  }

  // Operations

  set_new_tab_url_and_kv_store() {
    this.bunch_of_tabs.new_tab_url = this.new_tab_url_edit;
    // kv_store_put("new_tab_url", this.new_tab_url_edit);
    this.bunch_of_settings.set('new_tab_url', this.new_tab_url_edit);
  }

  set_home_url_and_kv_store() {
    this.bunch_of_tabs.home_url = this.home_url_edit;
    // kv_store_put("home_url", this.home_url_edit);
    this.bunch_of_settings.set('home_url', this.home_url_edit);
  }

  refresh_web_cache_size() {
    this.calculating_web_cache_size = true;
    get_sandbox_folder_size('/data/storage/el2/base/cache/web/', false).then(result => {
      this.web_cache_size = result;
      this.bunch_of_settings.set('webview_cache_size', this.web_cache_size);
      this.calculating_web_cache_size = false;
    })
  }

  refresh_history_index_size() {
    this.calculating_history_index_size = true;
    get_sandbox_folder_size('history-index', true).then(result => {
      this.history_index_size = result;
      this.bunch_of_settings.set('history_index_size', this.history_index_size);
      this.calculating_history_index_size = false;
    })
  }

  scroll_settings_to() {
    if (this.settings_scroll_to < 0) {
      return;
    }
    this.waterFlow_control.scrollToIndex(this.settings_scroll_to, true);
  }

  version_clicked() {
    this.version_clicked_times += 1;
    if (this.version_clicked_times == 7) {
      // Enter Dev mode
      this.version_clicked_times += 1;
      this.bunch_of_settings.set('DEV_MODE', true);
    }
  }
}

export default meowAppSettings

@Component
struct menuScrollHorizontal {
  @Link on_index_first: number;
  @Link on_index_last: number;
  @Link scroll_to_gateway: number;
  @State menu_text: string[] = [];
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Scroll() {
      Row() {
        ForEach(this.menu_text, (item: string, index: number) => {
          menuItem({
            my_text: $r('app.string.'.concat(item)),
            my_index: index,
            on_index_first: this.on_index_first,
            on_index_last: this.on_index_last,
            scroll_to_gateway: this.scroll_to_gateway,
          })
            .backgroundColor(this.on_index_first <= index && index <= this.on_index_last ?
            this.color_current_font : "transparent")
            .borderRadius(this.border_radius(index))
            .animation(animation_default())
        })
      }
    }
    .align(Alignment.End)
    .edgeEffect(EdgeEffect.Spring)
    .width("100%")
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  border_radius(index: number) {
    if (index == this.on_index_first && index == this.on_index_last) {
      return 10;
    }
    if (index == this.on_index_first) {
      let ra: BorderRadiuses = { topLeft: 10, bottomLeft: 10 };
      return ra;
    }
    if (index == this.on_index_last) {
      let ra: BorderRadiuses = { topRight: 10, bottomRight: 10 };
      return ra;
    }
    return 0;
  }
}

@Component
struct menuScrollVertical {
  @Link on_index_first: number;
  @Link on_index_last: number;
  @Link scroll_to_gateway: number;
  @State menu_text: string[] = [];
  @State button_Lengths: number[] = new Array(this.menu_text.length).fill(0);
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Scroll() {
      Column() {
        ForEach(this.menu_text, (item: string, index: number) => {
          menuItem({
            my_text: $r('app.string.'.concat(item)),
            my_index: index,
            on_index_first: this.on_index_first,
            on_index_last: this.on_index_last,
            scroll_to_gateway: this.scroll_to_gateway,
          })
            .onAreaChange((_old, n) => {
              // Record button
              this.button_Lengths[index] = n.width as number;
            })
            .backgroundColor(this.on_index_first <= index && index <= this.on_index_last ?
            this.color_current_font : "transparent")
            .borderRadius(this.border_radius(index))
            .animation(animation_default())
        })
      }
      .alignItems(HorizontalAlign.End)
    }
    .align(Alignment.Top)
    .edgeEffect(EdgeEffect.Spring)
    .height("100%")
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
  }

  border_radius(index: number) {
    if (index == this.on_index_first && index == this.on_index_last) {
      // If I am the only one in range
      return 10;
    }

    let topLeft = 0;
    let topRight = 0;
    let bottomLeft = 0;
    let bottomRight = 0;

    if (index == this.on_index_first) {
      topLeft = 10;
      topRight = 10;
    }
    if (index == this.on_index_last) {
      bottomLeft = 10;
      bottomRight = 10;
    }

    if (index + 1 < this.menu_text.length) {
      if (this.button_Lengths[index] != this.button_Lengths[index + 1] &&
        this.button_Lengths[index] + 10 > this.button_Lengths[index + 1]) {
        bottomLeft = 10;
      }
    }

    if (index - 1 >= 0) {
      if (this.button_Lengths[index] != this.button_Lengths[index - 1] &&
        this.button_Lengths[index] + 10 > this.button_Lengths[index - 1]) {
        topLeft = 10;
      }
    }

    let ra: BorderRadiuses = {
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight
    };
    return ra;
  }
}

@Component
struct menuItem {
  @State my_index: number = 0;
  @State my_text: ResourceStr = "";
  @Link on_index_first: number;
  @Link on_index_last: number;
  @Link scroll_to_gateway: number;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Row() {
      Text(this.my_text)
        .fontColor(this.on_index_first <= this.my_index && this.my_index <= this.on_index_last ?
        this.color_current_secondary : this.color_current_font)
        .fontSize(fontSize_Large() - 2)
    }
    .clickEffect(click_effect_default())
    .padding(7)
    .animation(animation_default())
    .onClick(() => {
      this.scroll_to_gateway = -1;
      this.scroll_to_gateway = this.my_index;
    })
  }
}
