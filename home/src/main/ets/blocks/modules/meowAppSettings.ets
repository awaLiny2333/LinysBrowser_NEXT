import { BusinessError } from '@kit.BasicServicesKit';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Extra,
  fontSize_Large,
  minimum_card_width,
  url_default_blank
} from '../../hosts/bunch_of_defaults';
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { bunch_of_user_agents } from '../../hosts/bunch_of_user_agents';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { bunch_of_history } from '../../hosts/bunch_of_history';
import {
  add_units_to_size, document_pick_to_text, document_save_text, export_everything, import_everything
} from '../../utils/storage_tools';
import lazy { get_sandbox_folder_size } from '../../utils/any_concurrent_tools';
import { bunch_of_history_index } from '../../hosts/bunch_of_history_index';
import {
  fill_fake_history,
  history_index_full_rebuild_worker,
  history_index_load_from_disk_worker,
  history_index_save_to_disk_worker
} from '../../hosts/bunch_of_history_index_x_functions';
import { bunch_of_history_index_lite } from '../../hosts/bunch_of_history_index_lite';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import bundleManager from '@ohos.bundle.bundleManager';
import meowSEManager from '../panels/meowSEManager';
import meowUAManager from '../panels/meowUAManager';
import meowWhatsNew from '../contents/meowWhatsNew';
import meowColorsManager from '../panels/meowColorsManager';
import meowCreditsRepos from '../contents/meowCreditsRepos';
import meowCreditsUsers from '../contents/meowCreditsUsers';
import meowAnimationManager from '../panels/meowAnimationManager';
import linysLink from '../../components/texts/linysLink';
import linysLockSlider from '../../components/linysLockSlider';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import linysTimeoutButtonWithText from '../../components/buttons/linysTimeoutButtonWithText';
import linysSwitchWithText from '../../components/toggles/linysSwitchWithText';
import linysTextSubtitleDivision from '../../components/texts/linysTextSubtitleDivision';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysTextTitle from '../../components/texts/linysTextTitle';
import linysText from '../../components/texts/linysText';
import lazy woofAdsBlocker from '../../dialogs/managers/woofAdsBlocker';
import lazy woofCookies from '../../dialogs/managers/woofCookies';
import lazy woofGeneralManage from '../../dialogs/managers/woofGeneralManage';
import lazy woofKeyShortcuts from '../../dialogs/managers/woofKeyShortcuts';
import lazy woofHomepageManager from '../../dialogs/managers/woofHomepageManager';
import lazy woofRecentFaultLogs from '../../dialogs/contents/woofRecentFaultLogs';
import lazy woofUpdateHistory from '../../dialogs/contents/woofUpdateHistory';
import lazy woofPromptOK from '../../dialogs/prompts/woofPromptOK';
import lazy woofHistory from '../../dialogs/managers/woofHistory';

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
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageLink('bunch_of_history_index') bunch_of_history_index: bunch_of_history_index = new bunch_of_history_index();
  // Colors
  @StorageProp('color_current_primary') @Watch('on_color_change') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') @Watch('on_color_change') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') @Watch('on_color_change') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Generals
  @StorageProp('screen_width') screen_width: number = 0;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  @State history_length: number = this.bunch_of_history.get_history_this_month().length;
  // Segment Button Options
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }],
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  @State tabs_style_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
      { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }],
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  @State start_up_page_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.Settings_start_up_new_tab') },
      { text: $r('app.string.Settings_start_up_home') },
      { text: $r('app.string.Settings_start_up_continue') }
    ],
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  @State left_or_right: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '󰃊' }, { text: '󰈱' }],
    selectedBackgroundColor: this.color_current_font,
    selectedFontColor: this.color_current_primary
  })
  // Settings
  @StorageLink('DEV_MODE') DEV_MODE: boolean = false;
  @State @Watch('on_title_bar_position_changed') title_bar_position_selected: number[] = [0];
  @State @Watch('on_tabs_style_changed') tabs_style_selected: number[] = [0];
  @State @Watch('on_tabs_style_non_tablet_mode_changed') tabs_style_selected_non_tablet_mode: number[] = [0];
  @State @Watch('on_start_up_page_changed') start_up_page_selected: number[] = [0];
  @State @Watch('on_prefer_hand_left_or_right_changed') left_or_right_selected: number[] = [0];
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
  @StorageLink('continuation_auto_exit') continuation_auto_exit: boolean = false;
  @StorageLink('continuation_auto_close_tab') continuation_auto_close_tab: boolean = true;
  // Downloads
  @StorageLink('direct_download') direct_download: boolean = false;
  @StorageLink('direct_download_auto_open') direct_download_auto_open: boolean = false;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_settings_menu') preferred_hand_reverse_settings_menu: boolean = false;
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  // Edits
  @State new_tab_url_edit: string = "";
  @State home_url_edit: string = "";
  @State lock_bookmark_suggestion_number: boolean = true;
  @State lock_history_suggestion_number: boolean = true;
  // Scroll menu
  @State @Watch('scroll_settings_to') settings_scroll_to: number = 0;
  @State settings_scroll_to_highlight_timeout: number = 0;
  @State scroll_first: number = 0;
  @State scroll_last: number = 0;
  @State menu_text: string[] =
    ['Settings_start_up', 'Settings_general', 'Settings_Experience', 'Settings_Accessibility', 'Settings_appearance',
      'Settings_experience_history', 'Settings_storage', 'Settings_security', 'Settings_toolbox', 'Settings_about', 'Settings_update'];
  // Dialogs
  @StorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({ showing_settings: this.showing_app_settings }),
    alignment: DialogAlignment.Center,
    cornerRadius: 22,
    // showInSubWindow: true,
    width: "90%",
  });
  adsBlocker_control: CustomDialogController = new CustomDialogController({
    builder: woofAdsBlocker(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
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
    // showInSubWindow: true,
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
    // showInSubWindow: true,
    width: "90%",
  });
  cookies_control: CustomDialogController = new CustomDialogController({
    builder: woofCookies(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    width: "90%",
  });
  key_shortcuts_control: CustomDialogController = new CustomDialogController({
    builder: woofKeyShortcuts(),
    alignment: DialogAlignment.Center,
    cornerRadius: 22,
    // showInSubWindow: true,
    width: "90%",
  });
  homepage_shortcuts_control: CustomDialogController = new CustomDialogController({
    builder: woofHomepageManager(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // // showInSubWindow: true,
    // width: "90%",
  });
  recent_fault_logs_control: CustomDialogController = new CustomDialogController({
    builder: woofRecentFaultLogs(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    width: "90%",
  });
  update_history: CustomDialogController = new CustomDialogController({
    builder: woofUpdateHistory(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    width: "90%",
  });
  woofSettingsImportOK_control: CustomDialogController = new CustomDialogController({
    builder: woofPromptOK(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })
  woofEverythingImportOK_control: CustomDialogController = new CustomDialogController({
    builder: woofPromptOK({
      title: $r('app.string.Settings_toolbox_export_everything'),
      desc: $r('app.string.Settings_toolbox_import_everything_ok')
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })
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
  @StorageLink('reindexing_history') reindexing_history: boolean | undefined = undefined;
  @StorageLink('reindexing_history_progress') reindexing_history_progress: number = 100;
  @StorageLink('compressing_output_profile') compressing_output_profile: boolean = false;

  build() {
    Row() {
      menuScrollVertical({
        on_index_first: this.scroll_first,
        on_index_last: this.scroll_last,
        scroll_to_gateway: this.settings_scroll_to,
        menu_text: this.menu_text,
      })// Quick access on the left
        .margin({ left: 15 })
        .visibility(this.visibility_of_left_menu())
        .animation(animation_default())

      Column({ space: 10 }) {
        if (!this.tablet_mode) {
          menuScrollHorizontal({
            on_index_first: this.scroll_first,
            on_index_last: this.scroll_last,
            scroll_to_gateway: this.settings_scroll_to,
            menu_text: this.menu_text,
          })
          // .margin({ left: 15, right: 15 })
        } // Quick access on the top
        WaterFlow({ scroller: this.waterFlow_control }) {
          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_start_up'),
              timeout: this.settings_scroll_to_highlight_timeout,
              highlight: this.settings_scroll_to == 0
            }) {
              settingsSubCard({ timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 0 }) {
                linysText({ text: $r('app.string.Settings_start_up_page') })
                SegmentButton({
                  options: this.start_up_page_tabOptions,
                  selectedIndexes: this.start_up_page_selected
                })
              }
            }
          } // Start up
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_general'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 1
            }) {
              // UA
              settingsSubCard({
                icon: '󰜎',
                title: $r('app.string.Index_surf_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 1
              }) {

                linysText({ text: $r('app.string.Settings_general_custom_ua') })
                meowUAManager()

                linysText({ text: $r('app.string.Settings_general_custom_search_engine') })
                meowSEManager()

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
              } // Surf

              settingsSubCard({
                icon: '󰀧',
                title: $r('app.string.Settings_homepage'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 1
              }) {
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_homepage_customization'),
                  button_text: "  󰀠  ",
                  onExecution: () => {
                    this.homepage_shortcuts_control.open();
                  }
                })
              } // Homepage Customization
            }
          } // General
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_Experience'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 2
            }) {
              settingsSubCard({
                icon: '󰏯',
                title: $r('app.string.Index_downloads_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 2
              }) {
                linysSwitchWithText({
                  text: $r('app.string.Index_downloads_direct'),
                  toggle_state: this.direct_download,
                  onExecution: () => {
                    this.bunch_of_settings.set('direct_download', this.direct_download);
                  }
                }) // Direct Download
                linysSwitchWithText({
                  text: $r('app.string.Index_downloads_direct_auto_open'),
                  toggle_state: this.direct_download_auto_open,
                  onExecution: () => {
                    this.bunch_of_settings.set('direct_download_auto_open', this.direct_download_auto_open);
                  }
                }) // Direct Download auto open
                  .opacity(this.direct_download ? 1 : 0.5)
                  .animation(animation_default())
              } // Downloads

              settingsSubCard({
                icon: '󰊾',
                title: $r('app.string.Index_continuation_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 2
              }) {
                linysSwitchWithText({
                  text: $r('app.string.Settings_experience_continuation_auto_exit'),
                  toggle_state: this.continuation_auto_exit,
                  onExecution: () => {
                    this.bunch_of_settings.set('continuation_auto_exit', this.continuation_auto_exit);
                  }
                }) // continuation_auto_exit
                linysSwitchWithText({
                  text: $r('app.string.Settings_experience_continuation_auto_close_tab'),
                  toggle_state: this.continuation_auto_close_tab,
                  onExecution: () => {
                    this.bunch_of_settings.set('continuation_auto_close_tab', this.continuation_auto_close_tab);
                  }
                }) // continuation_auto_close_tab
                  .opacity(!this.continuation_auto_exit ? 1 : 0.5)
                  .animation(animation_default())
              } // Continuation

              settingsSubCard({
                icon: '󰯏',
                title: $r('app.string.Index_suggestions_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 2
              }) {
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
              } // Suggestion

              settingsSubCard({
                icon: '󰇝',
                title: $r('app.string.Title_advanced'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 2
              }) {
                linysSwitchWithText({
                  text: $r('app.string.Settings_experience_use_adblock'),
                  toggle_state: this.use_adblock,
                  onExecution: () => {
                    this.bunch_of_settings.set('use_adblock', this.use_adblock);
                  }
                }) // Use adblock
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_experience_manage_adblock'),
                  button_text: "  󰀠  ",
                  onExecution: () => {
                    this.adsBlocker_control.open();
                  }
                })
                linysSwitchWithText({
                  text: $r('app.string.Settings_image_disable_image'),
                  toggle_state: this.disable_image,
                  onExecution: () => {
                    this.bunch_of_settings.set('disable_image', this.disable_image);
                  }
                }) // Disable images
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_image_manage'),
                  button_text: "  󰀠  ",
                  onExecution: () => {
                    this.image_manage_control.open();
                  }
                })
                linysSwitchWithText({
                  text: $r('app.string.Settings_js_disable_js'),
                  toggle_state: this.disable_js,
                  onExecution: () => {
                    this.bunch_of_settings.set('disable_js', this.disable_js);
                  }
                }) // JavaScript Manager
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_js_manage'),
                  button_text: '  󰀠  ',
                  onExecution: () => {
                    this.js_manage_control.open();
                  }
                }) // JS management
              } // Advanced
            }
          } // Experience
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_Accessibility'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 3
            }) {
              settingsSubCard({ timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 3 }) {
                linysSwitchWithText({
                  text: $r('app.string.Settings_experience_sys_back_to_access_backward'),
                  toggle_state: this.sys_back_to_access_backward,
                  onExecution: () => {
                    this.bunch_of_settings.set('sys_back_access_backward', this.sys_back_to_access_backward);
                  }
                }) // Use sys back
              }

              settingsSubCard({
                icon: '󰗫',
                title: $r('app.string.Settings_single_hand_preference'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 3
              }) {
                SegmentButton({
                  options: this.left_or_right,
                  selectedIndexes: this.left_or_right_selected
                }) // Single hand usability

                linysText({
                  text: $r('app.string.Settings_Accessibility_preferred_hand_reverse_desc'),
                  max_lines: 20,
                  is_description: true
                }) // Explanation

                linysSwitchWithText({
                  text: $r('app.string.Settings_Accessibility_preferred_hand_reverse_settings_menu'),
                  toggle_state: this.preferred_hand_reverse_settings_menu,
                  onExecution: () => {
                    this.bunch_of_settings.set('preferred_hand_reverse_settings_menu', this.preferred_hand_reverse_settings_menu);
                  }
                }) // Reverse settings menu
                linysSwitchWithText({
                  text: $r('app.string.Settings_Accessibility_preferred_hand_reverse_tabs_panel'),
                  toggle_state: this.preferred_hand_reverse_tabs_panel,
                  onExecution: () => {
                    this.bunch_of_settings.set('preferred_hand_reverse_tabs_panel', this.preferred_hand_reverse_tabs_panel);
                  }
                }) // Reverse settings menu
                linysSwitchWithText({
                  text: $r('app.string.Settings_Accessibility_preferred_hand_reverse_homepage_shortcuts'),
                  toggle_state: this.preferred_hand_reverse_homepage_shortcuts,
                  onExecution: () => {
                    this.bunch_of_settings.set('preferred_hand_reverse_homepage_shortcuts', this.preferred_hand_reverse_homepage_shortcuts);
                  }
                }) // Reverse homepage shortcuts
              } // Single hand

              settingsSubCard({
                icon: '󰌐',
                title: $r('app.string.Key_shortcuts'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 3
              }) {
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Key_shortcuts_manage'),
                  button_text: "  󰀠  ",
                  onExecution: () => {
                    this.key_shortcuts_control.open();
                  }
                })
              } // Keyboard shortcuts
            }
          } // Accessibility
          .width('100%')

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_appearance'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 4
            }) {
              settingsSubCard({ timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 4 }) {
                linysSwitchWithText({
                  text: $r('app.string.Settings_experience_web_force_dark_mode'),
                  toggle_state: this.web_force_dark_mode,
                  onExecution: () => {
                    this.bunch_of_settings.set('web_force_dark_mode', this.web_force_dark_mode);
                  }
                }) // Force dark mode
              }

              settingsSubCard({
                icon: '󰍗',
                title: $r('app.string.Index_layout_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 4
              }) {
                linysText({ text: $r('app.string.Settings_appearance_title_bar_position') }) // Title bar position
                SegmentButton({
                  options: this.title_bar_position_tabOptions,
                  selectedIndexes: this.title_bar_position_selected
                })

                linysText({
                  text: $r('app.string.Settings_appearance_tabs_style'),
                  max_lines: 3
                }) // Tabs Style for tablets and landscape displays
                SegmentButton({
                  options: this.tabs_style_tabOptions,
                  selectedIndexes: this.tabs_style_selected
                })

                linysText({
                  text: $r('app.string.Settings_appearance_tabs_style_non_tablet_mode'),
                  max_lines: 3
                }) // Tabs Style for mobile and portrait displays
                SegmentButton({
                  options: this.tabs_style_tabOptions,
                  selectedIndexes: this.tabs_style_selected_non_tablet_mode
                })
              } // Layout

              settingsSubCard({
                icon: '󰟠',
                title: $r('app.string.Index_animation_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 4
              }) {
                meowAnimationManager() // Animation manager
              } // Animation

              settingsSubCard({
                icon: '󰄥',
                title: $r('app.string.Index_colors_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 4
              }) {
                meowColorsManager() // Colors manager
              } // Colors
            }
          } // Appearance
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_experience_history'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 5
            }) {
              settingsSubCard({
                icon: '󰏕',
                title: $r('app.string.Settings_experience_history'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 5
              }) {
                linysSwitchWithText({
                  text: $r('app.string.Settings_experience_history_record_new'),
                  toggle_state: this.collect_new_history,
                  onExecution: () => {
                    this.bunch_of_settings.set('collect_new_history', this.collect_new_history);
                  }
                }) // Toggle History
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_experience_history_view'),
                  button_text: "  󰀩  ",
                  onExecution: () => {
                    this.woofHistory_control.open();
                  }
                }) // View history

                linysText({ text: $r('app.string.Settings_experience_history_index_desc'), is_description: true }) // index desc
                linysTimeoutButtonWithText({
                  desc_text: $r('app.string.Settings_experience_history_index'),
                  button_text: "  󰀩  ",
                  onExecution: () => {
                    history_index_full_rebuild_worker();
                  }
                })// History Indexing
                  .opacity(this.reindexing_history ? 0.4 : 1)
                  .enabled(!this.reindexing_history)

                if (this.DEV_MODE) {
                  linysTimeoutButton({
                    text: " Fill history 05 - 14 ",
                    onExecution: () => {
                      fill_fake_history(2005, 2014, 750000);
                    }
                  })
                    .opacity(this.reindexing_history ? 0.4 : 1)
                    .enabled(!this.reindexing_history)
                    .animation(animation_default())

                  linysTimeoutButton({
                    text: " Fill history 15 - 24 ",
                    onExecution: () => {
                      fill_fake_history(2015, 2024, 750000);
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
            }
          } // History
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_storage'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 6
            }) {
              settingsSubCard({
                icon: '󰂼',
                title: $r('app.string.Settings_experience_webview_storage'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 6
              }) {
                linysText({ text: $r('app.string.Settings_storage_clear_webview_desc'), is_description: true }) // Cache title
                linysTextTitle({ text: add_units_to_size(this.web_cache_size) }) // data display
                Row({ space: 12 }) {
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
                .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
                .animation(animation_default())
                .width("100%")
              } // Web cache

              settingsSubCard({
                icon: '󰏕',
                title: $r('app.string.Settings_experience_history_index_storage'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 6
              }) {
                linysText({ text: $r('app.string.Settings_experience_history_index_storage_desc'), is_description: true }) // Indexing title
                linysTextTitle({ text: add_units_to_size(this.history_index_size) }) // data display
                Row({ space: 12 }) {
                  linysCapsuleButton({ text: '  󰃈  ' })
                    .onClick(() => {
                      this.refresh_history_index_size();
                    })
                    .opacity(this.calculating_history_index_size ? 0.4 : 1)
                    .enabled(!this.calculating_history_index_size)
                    .animation(animation_default())
                } // buttons
                .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
                .animation(animation_default())
                .width("100%")
              } // Index files
            }
          } // Storage
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_security'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 7
            }) {
              settingsSubCard({
                icon: '󰠝',
                title: $r('app.string.Settings_cookies'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 7
              }) {
                linysText({
                  text: $r('app.string.intelligent_tracking_prevention_desc'),
                  is_description: true
                }) // Desc Intelligent Tracking Prevention
                linysSwitchWithText({
                  text: $r('app.string.intelligent_tracking_prevention'),
                  toggle_state: this.intelligent_tracking_prevention,
                  onExecution: () => {
                    this.bunch_of_settings.set('intelligent_tracking_prevention', this.intelligent_tracking_prevention);
                    for (let index = 0; index < this.bunch_of_tabs.Tabs.length; index++) {
                      try {
                        this.bunch_of_tabs.Tabs[index].controller.enableIntelligentTrackingPrevention(this.intelligent_tracking_prevention);
                        console.log('[Meow][meowAppSettings] Intelligent Tracking Prevention now ' + this.intelligent_tracking_prevention.toString() + '!')
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
                  }
                }) // Intelligent tracking prevention

                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_manage_cookies'),
                  button_text: "  󰀩  ",
                  onExecution: () => {
                    this.cookies_control.open();
                  }
                }) // Cookie management

              } // Cookies
            }
          } // Security
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_toolbox'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 8
            }) {
              settingsSubCard({
                icon: '󰊴',
                title: $r('app.string.Debug'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 8
              }) {
                linysSwitchWithText({
                  text: $r('app.string.Settings_toolbox_resource_monitor'),
                  toggle_state: this.resource_monitor,
                  onExecution: () => {
                    this.bunch_of_settings.set('resource_monitor', this.resource_monitor);
                  }
                }) // Show Resource Monitor
                linysText({ text: $r('app.string.Fault_logs_desc'), is_description: true }) // Fault logs
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Fault_logs'),
                  button_text: '  󰀩  ',
                  onExecution: () => {
                    this.recent_fault_logs_control.open();
                  }
                }) // Fault logs display
              } // Debug

              settingsSubCard({
                icon: '󰀻',
                title: $r('app.string.Index_backup_title'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 8
              }) {
                linysText({ text: $r('app.string.Settings_toolbox_export_settings_desc'), max_lines: 3 })
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_toolbox_export_settings'),
                  button_text: '  󰃋  ',
                  onExecution: () => {
                    // sandbox_save('settings.json', this.bunch_of_settings.toString());
                    document_save_text('settings.json.browsercatsettings', this.bunch_of_settings.toString());
                  }
                }) // Export settings
                linysTimeoutButtonWithText({
                  desc_text: $r('app.string.Settings_toolbox_import_settings'),
                  button_text: '  󰐝  ',
                  onExecution: () => {
                    document_pick_to_text(['browsercatsettings']).then((result) => {
                      let import_result = this.bunch_of_settings.import_json(result);
                      if (!import_result) {
                        this.uni_fail_prompt_gateway = $r("app.string.Fail_select_bad_settings");
                      } else {
                        this.woofSettingsImportOK_control.open();
                      }
                    })
                  }
                }) // Import settings
                linysText({ text: $r('app.string.Settings_toolbox_import_settings_desc'), is_description: true, is_expanded: true })

                linysText({ text: $r('app.string.Settings_toolbox_export_everything_desc'), max_lines: 10 })
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Settings_toolbox_export_everything'),
                  button_text: '  󰃋  ',
                  onExecution: () => {
                    export_everything();
                  }
                }) // Export everything
                  .enabled(!this.compressing_output_profile)
                  .opacity(!this.compressing_output_profile ? 1 : 0.5)
                linysTimeoutButtonWithText({
                  desc_text: $r('app.string.Settings_toolbox_import_everything'),
                  button_text: '  󰐝  ',
                  onExecution: () => {
                    import_everything().then((result) => {
                      if (result) {
                        // Import OK
                        this.woofEverythingImportOK_control.open();
                      } else {
                        this.uni_fail_prompt_gateway = $r("app.string.Fail_select_bad_everything");
                      }
                    });
                  }
                }) // Import settings
                linysText({ text: $r('app.string.Settings_toolbox_import_everything_desc'), is_description: true, is_expanded: true })

                if (this.DEV_MODE) {
                  linysTimeoutButton({
                    text: " Temp Code ",
                    onExecution: () => {

                    }
                  })
                }
              } // Backup
            }
          } // Toolbox / cardboard box
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Settings_about'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 9
            }) {
              settingsSubCard({
                icon: '󰕰',
                title: $r('app.string.Settings_about'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 9
              }) {
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
                meowCreditsRepos()
                meowCreditsUsers()
                linysText({
                  text: $r("app.string.Credits_extra"),
                  max_lines: 6
                }) // And you!
              }
            }
          } // About
          .width("100%")

          FlowItem() {
            settingsCard({
              title: $r('app.string.Whats_new'),
              timeout: this.settings_scroll_to_highlight_timeout, highlight: this.settings_scroll_to == 10
            }) {
              settingsSubCard({
                icon: '󰁦',
                title: $r('app.string.Update_this'),
                timeout: this.settings_scroll_to_highlight_timeout,
                highlight: this.settings_scroll_to == 10
              }) {
                linysText({ text: $r('app.string.Update_this') }) // This update:
                meowWhatsNew() // Whats new contents
                linysText({
                  text: $r("app.string.Whats_new_content_extra"),
                  max_lines: 6
                }) // Perhaps some bugfix?
                linysCapsuleButtonWithText({
                  desc_text: $r('app.string.Update_record'),
                  button_text: '  󰀩  ',
                  onExecution: () => {
                    this.update_history.open();
                  }
                }) // Update history
              }
            }
          } // Update
          .width("100%")

        } // Bottom Bar of App Settings
        .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width / minimum_card_width())))
        .rowsGap(10)
        .columnsGap(10)
        .borderRadius(10)
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
      .padding({ left: 15, right: 15 })
      .layoutWeight(1)
      .height("100%")
      .animation(animation_default())

      menuScrollVertical({
        on_index_first: this.scroll_first,
        on_index_last: this.scroll_last,
        scroll_to_gateway: this.settings_scroll_to,
        menu_text: this.menu_text,
      })// Quick access on the right
        .margin({ right: 15 })
        .visibility(this.visibility_of_right_menu())
        .animation(animation_default())
    }
    .height(this.showing_app_settings ? "75%" : 0)
    .width("100%")
    .animation(animation_default())
    .onAppear(() => {
      // console.log("[Meow][meowAppSettings] App Settings READY")
      this.on_appear();
      setInterval(() => {
        // Deduce timeout for border highlights
        if (this.settings_scroll_to_highlight_timeout < 0) {
          this.settings_scroll_to_highlight_timeout = 0;
        } else {
          this.settings_scroll_to_highlight_timeout -= 100;
        }
        // console.log(this.settings_scroll_to_highlight_timeout.toString())
      }, 100)
    })
  }

  // Events

  async on_appear() {
    // Get app version info
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
      this.versionNo = bundleInfo.versionCode;
    })

    // Get settings of shortcuts on left or right
    this.left_or_right_selected = (this.preferred_hand_left_or_right == 'left') ? [0] : [1];

    // Get whether to show resource monitor
    this.resource_monitor = await this.bunch_of_settings.get('resource_monitor') as boolean;

    // Read webview cache size
    this.web_cache_size = await this.bunch_of_settings.get('webview_cache_size') as number;

    // Read history indexer size
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
    if (this.left_or_right_selected[0] == 0) {
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

  /**
   * Refreshes web cache size and stores the value into settings.
   * */
  refresh_web_cache_size() {
    if (this.calculating_web_cache_size) {
      return;
    }
    this.calculating_web_cache_size = true;
    get_sandbox_folder_size('/data/storage/el2/base/cache/web/', false).then(result => {
      this.web_cache_size = result;
      this.bunch_of_settings.set('webview_cache_size', this.web_cache_size);
      this.calculating_web_cache_size = false;
    })
  }

  /**
   * Refreshes history index size and stores the value into settings.
   * */
  refresh_history_index_size() {
    if (this.calculating_history_index_size) {
      return;
    }
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
    this.settings_scroll_to_highlight_timeout = 1200;
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

  // Kinda constants

  // TODO: optimize duplicate code
  visibility_of_left_menu() {
    if (!this.tablet_mode) {
      // Non tablet mode NO vertical menu!
      return Visibility.None;
    }
    let status = this.preferred_hand_left_or_right == 'left';
    if (this.preferred_hand_reverse_settings_menu) {
      status = !status;
    }
    return status ? Visibility.Visible : Visibility.None;
  }

  visibility_of_right_menu() {
    if (!this.tablet_mode) {
      // Non tablet mode NO vertical menu!
      return Visibility.None;
    }
    let status = this.preferred_hand_left_or_right == 'right';
    if (this.preferred_hand_reverse_settings_menu) {
      status = !status;
    }
    return status ? Visibility.Visible : Visibility.None;
  }
}

export default meowAppSettings

// Cards

@Component
struct settingsCard {
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Contents
  @BuilderParam contents: () => void;
  @Prop title: ResourceStr = $r('app.string.Settings_start_up');
  // Outline
  @Prop highlight: boolean = false;
  @Prop timeout: number = 0;

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontColor(this.color_current_font)
        .fontSize(fontSize_Extra())
        .fontWeight(FontWeight.Bold)
        .opacity((!this.highlight && this.timeout > 0) ? 0.5 : 0.8)
        .animation(animation_default())
        .padding({ left: 5 })

      Column({ space: 10 }) {
        this.contents();
      }
      // .borderColor((this.highlight && this.timeout > 0) ? this.color_current_font : this.color_current_primary)
      // .opacity((!this.highlight && this.timeout > 0) ? 0.5 : 1)
      // .animation(animation_default())
      // .padding(13)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")

      // .borderRadius(10)
      // .borderWidth(2)
      // .backgroundColor(this.color_current_primary)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}

@Component
struct settingsSubCard {
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Contents
  @BuilderParam contents: () => void;
  // Outline
  @Prop highlight: boolean = false;
  @Prop timeout: number = 0;
  // Title
  @Prop icon: ResourceStr | undefined = undefined;
  @Prop title: ResourceStr | undefined = undefined;
  // Stats
  @State show: boolean = false;

  build() {
    Column() {
      if (this.title) {
        linysTextSubtitleDivision({ icon: this.icon, text: this.title }) // Title
          .padding({ top: 12, left: 12, right: 12 })
          .width('100%')
          .clickEffect(click_effect_default())
          .onClick(() => {
            this.show = !this.show;
          })
      }
      Column({ space: 12 }) {
        this.contents();
      }
      .clip(true)
      .padding({ top: 12, left: 12, right: 12 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .visibility((this.title == undefined || this.show) ? Visibility.Visible : Visibility.None)
      .animation(animation_default())
    }
    .padding({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .borderColor((this.highlight && this.timeout > 0) ? this.color_current_font : this.color_current_primary)
    .opacity((!this.highlight && this.timeout > 0) ? 0.5 : 1)
    .animation(animation_default())
    .width("100%")
    .borderRadius(10)
    .borderWidth(2)
    .backgroundColor(this.color_current_primary)
  }
}

// Jump Menu

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
