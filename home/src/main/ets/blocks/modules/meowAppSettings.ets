import { BusinessError } from '@kit.BasicServicesKit';
import BuildProfile from 'home/BuildProfile';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  default_new_window_name,
  fontSize_Extra,
  fontSize_Large,
  minimum_card_width,
  url_default_blank
} from '../../hosts/bunch_of_defaults';
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { bunch_of_history } from '../../hosts/bunch_of_history';
import {
  add_units_to_size,
  document_pick_to_text,
  document_pick_to_uri,
  document_save_text,
  export_everything,
  import_everything,
  uri_2_path
} from '../../utils/storage_tools';
import { bunch_of_history_index } from '../../hosts/bunch_of_history_index';
import { history_index_full_rebuild_worker } from '../../hosts/bunch_of_history_index_x_functions';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import lazy { get_sandbox_folder_size } from '../../utils/any_concurrent_tools';
import lazy { new_window, storage_of_id } from '../../utils/ui_tools';
import lazy { common } from '@kit.AbilityKit';
import lazy { webview } from '@kit.ArkWeb';
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
import lazy woofCookies from '../../dialogs/managers/woofCookies';
import lazy woofGeneralManage from '../../dialogs/managers/woofGeneralManage';
import lazy woofKeyShortcuts from '../../dialogs/managers/woofKeyShortcuts';
import lazy woofHomepageManager from '../../dialogs/managers/woofHomepageManager';
import lazy woofRecentFaultLogs from '../../dialogs/contents/woofRecentFaultLogs';
import lazy woofUpdateHistory from '../../dialogs/contents/woofUpdateHistory';
import lazy woofPromptOK from '../../dialogs/prompts/woofPromptOK';
import lazy woofHistory from '../../dialogs/managers/woofHistory';
import lazy woofEasyList from '../../dialogs/managers/woofEasylist';

@Reusable
@Component
struct meowAppSettings {
  @StorageLink('showing_my_window_alias') showing_my_window_alias: boolean = false;
  @StorageLink('windowIds') windowIds: string[] = [];
  @StorageLink('free_window_mode') free_window_mode: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @Link @Watch('on_open_or_close_panel') showing_app_settings: boolean;
  // Hosts and environment
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('my_window_alias_position') my_window_alias_position: string = "center";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  @StorageLink('title_bar_position') title_bar_position: string = "";
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageLink('bunch_of_history_index') bunch_of_history_index: bunch_of_history_index = new bunch_of_history_index();
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') @Watch('on_color_change') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') @Watch('on_color_change') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') @Watch('on_color_change') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('color_current_back') @Watch('on_color_change') color_current_back: ResourceColor = $r('app.color.font_color_title');
  // Generals
  @LocalStorageProp('screen_width') screen_width: number = 0;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  @State buildTime: string = BuildProfile.linysBuildTime;
  @State history_length: number = this.bunch_of_history.get_history_this_month().length;
  // Segment Button Options
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }],
    selectedBackgroundColor: this.color_current_back,
    selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
    selectedFontWeight: FontWeight.Medium
  })
  @State tabs_style_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
      { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }],
    selectedBackgroundColor: this.color_current_back,
    selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
    selectedFontWeight: FontWeight.Medium
  })
  @State start_up_page_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.Settings_start_up_new_tab') },
      { text: $r('app.string.Settings_start_up_home') },
      { text: $r('app.string.Settings_start_up_continue') }
    ],
    selectedBackgroundColor: this.color_current_back,
    selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
    selectedFontWeight: FontWeight.Medium
  })
  @State my_window_alias_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: '󰈯' },
      { text: '󰁨' },
      { text: '󰈰' }
    ],
    selectedBackgroundColor: this.color_current_back,
    selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
    selectedFontWeight: FontWeight.Medium
  })
  @State left_or_right_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '󰃊' }, { text: '󰈱' }],
    selectedBackgroundColor: this.color_current_back,
    selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
    selectedFontWeight: FontWeight.Medium
  })
  // Settings
  @StorageLink('DEV_MODE') DEV_MODE: boolean = false;
  @State @Watch('on_title_bar_position_changed') title_bar_position_selected: number[] = [0];
  @State @Watch('on_tabs_style_changed') tabs_style_selected: number[] = [0];
  @State @Watch('on_tabs_style_non_tablet_mode_changed') tabs_style_selected_non_tablet_mode: number[] = [0];
  @State @Watch('on_start_up_option_changed') start_up_page_selected: number[] = [0];
  @State @Watch('on_my_window_alias_position_changed') my_window_alias_position_selected: number[] = [0];
  @State @Watch('on_prefer_hand_left_or_right_changed') left_or_right_selected: number[] = [0];
  @StorageLink('max_bookmark_advice') max_bookmark_advice: number = 5;
  @StorageLink('max_history_advice') max_history_advice: number = 5;
  @StorageLink('history_index_load_quantity') history_index_load_quantity: number = 6;
  @StorageLink('sys_back_to_access_backward') sys_back_to_access_backward: boolean = false;
  @StorageLink('esc_to_access_backward') esc_to_access_backward: boolean = false;
  @StorageLink('bottom_avoid') bottom_avoid: boolean = true;
  @StorageLink('resource_monitor') resource_monitor: boolean = true;
  @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = false;
  @StorageLink('web_force_dark_mode_exemptions') web_force_dark_mode_exemptions: string[] = [];
  @StorageLink('use_adblock') use_adblock: boolean = true;
  @StorageLink('adblock_exceptions') adblock_exceptions: string[] = [];
  @StorageLink('collect_new_history') collect_new_history: boolean = true;
  @StorageLink('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
  @StorageLink('enable_third_party_cookies') enable_third_party_cookies: boolean = false;
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
  @LocalStorageLink('settings_scroll_to') @Watch('scroll_settings_to') settings_scroll_to: number = 0;
  @LocalStorageLink('settings_scroll_to_highlight_timeout') settings_scroll_to_highlight_timeout: number = 0;
  @State scroll_first: number = 0;
  @State scroll_last: number = 0;
  @State menu_text: string[] =
    ['Settings_start_up', 'Settings_general', 'Settings_Experience', 'Settings_Accessibility', 'Settings_appearance',
      'Settings_experience_history', 'Settings_storage', 'Settings_security', 'Settings_toolbox', 'Settings_about', 'Settings_update', 'Settings_dev'];
  // Dialogs
  @LocalStorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });
  @State to_fool_woofGeneralManage: boolean = false;
  dark_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.web_force_dark_mode,
      sites_list: this.web_force_dark_mode_exemptions,
      descriptions: [
        $r('app.string.Web_force_dark_mode_desc_1'),
        $r('app.string.Web_force_dark_mode_desc_2')],
      tips: $r('app.string.Web_force_dark_mode_already_disabled'),
      title: $r('app.string.Settings_experience_manage_web_force_dark_mode'),
      switch_desc: $r('app.string.Settings_experience_web_force_dark_mode'),
      subtitle_sites_list: $r('app.string.Web_force_dark_mode_exemptions'),
      switch_id: 'web_force_dark_mode',
      sites_list_id: 'web_force_dark_mode_exemptions',
      subtitle_all_sites: '',
      all_sites_switch: this.to_fool_woofGeneralManage,
      switch_all_sites_id: '',
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  js_manage_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.disable_js,
      sites_list: this.disable_js_these_sites,
      all_sites_switch: this.disable_js_all_sites,
      descriptions: [
        $r('app.string.Settings_js_desc_1'),
        $r('app.string.Settings_js_desc_2'),
        $r('app.string.Settings_js_desc_3')],
      tips: $r('app.string.Settings_js_already_disabled'),
      title: $r('app.string.Settings_js_manage'),
      switch_desc: $r('app.string.Settings_js_disable_js'),
      subtitle_sites_list: $r('app.string.Settings_js_some_sites'),
      subtitle_all_sites: $r('app.string.Settings_js_all_sites'),
      switch_id: 'disable_js',
      sites_list_id: 'disable_js_these_sites',
      switch_all_sites_id: 'disable_js_all_sites',
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  image_manage_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.disable_image,
      sites_list: this.disable_image_these_sites,
      all_sites_switch: this.disable_image_all_sites,
      descriptions: [
        $r('app.string.Settings_image_desc_1'),
        $r('app.string.Settings_image_desc_2'),
        $r('app.string.Settings_image_desc_3')],
      tips: $r('app.string.Settings_image_already_disabled'),
      title: $r('app.string.Settings_image_manage'),
      switch_desc: $r('app.string.Settings_image_disable_image'),
      subtitle_sites_list: $r('app.string.Settings_image_some_sites'),
      subtitle_all_sites: $r('app.string.Settings_image_all_sites'),
      switch_id: 'disable_image',
      sites_list_id: 'disable_image_these_sites',
      switch_all_sites_id: 'disable_image_all_sites',
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  cookies_control: CustomDialogController = new CustomDialogController({
    builder: woofCookies(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  EasyList_control: CustomDialogController = new CustomDialogController({
    builder: woofEasyList(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });
  adsBlocker_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.use_adblock,
      sites_list: this.adblock_exceptions,
      descriptions: [
        $r('app.string.Ads_block_desc_1'),
        $r('app.string.Ads_block_desc_2')],
      tips: '',
      title: $r('app.string.Settings_experience_manage_adblock'),
      switch_desc: $r('app.string.Settings_experience_use_adblock'),
      subtitle_sites_list: $r('app.string.Ads_block_dont_block_sites'),
      switch_id: 'use_adblock',
      sites_list_id: 'adblock_exceptions',
      subtitle_all_sites: '',
      all_sites_switch: this.to_fool_woofGeneralManage,
      switch_all_sites_id: '',
      onAdd: (added) => {
        try {
          webview.AdsBlockManager.addAdsBlockDisallowedList([added]);
        } catch (e) {
          console.error('[woofAdsBlocker][add_exception] ' + e);
        }
      },
      onDelete: (deleted) => {
        try {
          webview.AdsBlockManager.removeAdsBlockDisallowedList(deleted);
        } catch (e) {
          console.error('[woofAdsBlocker][delete_selected] ' + e);
        }
      },
      extra_manage: () => {
        this.EasyList_entry_button();
      }
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  key_shortcuts_control: CustomDialogController = new CustomDialogController({
    builder: woofKeyShortcuts(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  homepage_shortcuts_control: CustomDialogController = new CustomDialogController({
    builder: woofHomepageManager(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
  });
  recent_fault_logs_control: CustomDialogController = new CustomDialogController({
    builder: woofRecentFaultLogs(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  update_history: CustomDialogController = new CustomDialogController({
    builder: woofUpdateHistory(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  woofSettingsImportOK_control: CustomDialogController = new CustomDialogController({
    builder: woofPromptOK(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  woofEverythingImportOK_control: CustomDialogController = new CustomDialogController({
    builder: woofPromptOK({
      title: $r('app.string.Settings_toolbox_export_everything'),
      desc: $r('app.string.Settings_toolbox_import_everything_ok')
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  waterFlow_control: Scroller = new Scroller();
  // Else
  @State clear_web_cache_confirm: number = 0;
  @State web_cache_size: number = 0;
  @State history_index_size: number = 0;
  version_clicked_times: number = 0;
  // Status
  @State calculating_web_cache_size: boolean = false;
  @State calculating_history_index_size: boolean = false;
  @StorageLink('reindexing_history') reindexing_history: boolean | undefined = undefined;
  @StorageLink('reindexing_history_progress') reindexing_history_progress: number = 100;
  @StorageLink('compressing_output_profile') compressing_output_profile: boolean = false;

  @Builder
  EasyList_entry_button() {
    linysCapsuleButtonWithText({
      desc_text: $r('app.string.Settings_experience_manage_adblock_rules'),
      button_text: "  󰖿  ",
      onExecution: () => {
        this.EasyList_control.open();
      }
    })
  }

  async on_appear() {
    // Get app version info
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
      this.versionNo = bundleInfo.versionCode;
    })

    // Get settings of shortcuts on left or right
    this.left_or_right_selected = (this.preferred_hand_left_or_right == 'left') ? [0] : [1];

    // Read webview cache size
    this.web_cache_size = bunch_of_settings.get('webview_cache_size') as number;

    // Read history indexer size
    this.history_index_size = bunch_of_settings.get('history_index_size') as number;

    // Tag status
    AppStorage.setOrCreate('settings_init_retrieved', true);
    this.storage.setOrCreate('settings_init_retrieved', true);
  }

  build() {
    Row() {
      menuScrollVertical({
        on_index_first: this.scroll_first,
        on_index_last: this.scroll_last,
        scroll_to_gateway: this.settings_scroll_to,
        menu_text: this.menu_text,
      })// Quick access on the left
        .margin({ left: 15 })
        .visibility(this.visibility_of_menu_side('left'))
        .animation(animation_default())

      Column({ space: 10 }) {
        if (!this.tablet_mode) {
          menuScrollHorizontal({
            on_index_first: this.scroll_first,
            on_index_last: this.scroll_last,
            scroll_to_gateway: this.settings_scroll_to,
            menu_text: this.menu_text,
          })
        } // Quick access on the top

        if (this.showing_app_settings) {
          WaterFlow({ scroller: this.waterFlow_control }) {
            FlowItem() {
              settingsModule({
                title: $r('app.string.Settings_start_up'),
                my_index: 0
              }) {
                settingsSubCard({ my_index: 0 }) {
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
              settingsModule({
                title: $r('app.string.Settings_general'),
                my_index: 1
              }) {
                // UA
                settingsSubCard({
                  icon: '󰜎',
                  title: $r('app.string.Index_surf_title'),
                  my_index: 1,
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
                      this.set_save_new_tab_url();
                    })
                    .height(capsule_bar_height())

                  linysCapsuleButton({ text: "  󰀻  " })
                  // (this.new_tab_url_edit != bunch_of_tabs.new_tab_url) doesn't change the UI when bunch_of_tabs.new_tab_url is updated.
                    .visibility(this.new_tab_url_edit != this.bunch_of_tabs.get_new_tab_url() ? Visibility.Visible : Visibility.None)
                    .onClick(() => {
                      this.set_save_new_tab_url();
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
                      this.set_save_home_url();
                    })
                    .height(capsule_bar_height())

                  linysCapsuleButton({ text: "  󰀻  " })
                  // (this.home_url_edit != bunch_of_tabs.home_url) doesn't change the UI when bunch_of_tabs.home_url is updated.
                    .visibility(this.home_url_edit != this.bunch_of_tabs.get_home_url() ? Visibility.Visible : Visibility.None)
                    .onClick(() => {
                      this.set_save_home_url();
                    })
                    .alignSelf(ItemAlign.End)
                    .animation(animation_default())
                } // Surf

                settingsSubCard({
                  icon: '󰀧',
                  title: $r('app.string.Settings_homepage'),
                  my_index: 1,
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
              settingsModule({
                title: $r('app.string.Settings_Experience'),
                my_index: 2,
              }) {
                settingsSubCard({
                  icon: '󰏯',
                  title: $r('app.string.Index_downloads_title'),
                  my_index: 2,
                }) {
                  linysSwitchWithText({
                    text: $r('app.string.Index_downloads_direct'),
                    toggle_state: this.direct_download,
                    onExecution: () => {
                      bunch_of_settings.set('direct_download', this.direct_download);
                    }
                  }) // Direct Download
                  linysSwitchWithText({
                    text: $r('app.string.Index_downloads_direct_auto_open'),
                    toggle_state: this.direct_download_auto_open,
                    onExecution: () => {
                      bunch_of_settings.set('direct_download_auto_open', this.direct_download_auto_open);
                    }
                  }) // Direct Download auto open
                    .opacity(this.direct_download ? 1 : 0.5)
                    .animation(animation_default())
                } // Downloads

                settingsSubCard({
                  icon: '󰊾',
                  title: $r('app.string.Index_continuation_title'),
                  my_index: 2,
                }) {
                  linysSwitchWithText({
                    text: $r('app.string.Settings_experience_continuation_auto_exit'),
                    toggle_state: this.continuation_auto_exit,
                    onExecution: () => {
                      bunch_of_settings.set('continuation_auto_exit', this.continuation_auto_exit);
                    }
                  }) // continuation_auto_exit
                  linysSwitchWithText({
                    text: $r('app.string.Settings_experience_continuation_auto_close_tab'),
                    toggle_state: this.continuation_auto_close_tab,
                    onExecution: () => {
                      bunch_of_settings.set('continuation_auto_close_tab', this.continuation_auto_close_tab);
                    }
                  }) // continuation_auto_close_tab
                    .opacity(!this.continuation_auto_exit ? 1 : 0.5)
                    .animation(animation_default())
                } // Continuation

                settingsSubCard({
                  icon: '󰯏',
                  title: $r('app.string.Index_suggestions_title'),
                  my_index: 2,
                }) {
                  linysText({ text: $r('app.string.Settings_experience_max_bookmark_advice'), max_lines: 2 })
                  linysLockSlider({
                    slider_min: 0,
                    slider_max: 20,
                    slider_value: this.max_bookmark_advice,
                    onTouchUp: () => {
                      bunch_of_settings.set('max_bookmark_suggest', this.max_bookmark_advice);
                    }
                  }) // Slider and display of max_bookmark_suggestions
                  linysText({ text: $r('app.string.Settings_experience_max_history_advice'), max_lines: 2 })
                  linysLockSlider({
                    slider_min: 0,
                    slider_max: 20,
                    slider_value: this.max_history_advice,
                    onTouchUp: () => {
                      bunch_of_settings.set('max_history_suggest', this.max_history_advice);
                    }
                  }) // Slider and display of max_history_suggestions
                } // Suggestion

                settingsSubCard({
                  icon: '󰇝',
                  title: $r('app.string.Title_advanced'),
                  my_index: 2,
                }) {
                  linysSwitchWithText({
                    text: $r('app.string.Settings_experience_use_adblock'),
                    toggle_state: this.use_adblock,
                    onExecution: () => {
                      bunch_of_settings.set('use_adblock', this.use_adblock);
                    }
                  }) // Use adblock
                  linysCapsuleButtonWithText({
                    desc_text: $r('app.string.Settings_experience_manage_adblock'),
                    button_text: "  󰀠  ",
                    onExecution: () => {
                      this.adsBlocker_control.open();
                    }
                  })
                  linysCapsuleButtonWithText({
                    desc_text: $r('app.string.Settings_experience_manage_adblock_rules'),
                    button_text: "  󰖿  ",
                    onExecution: () => {
                      this.EasyList_control.open();
                    }
                  })
                  linysSwitchWithText({
                    text: $r('app.string.Settings_image_disable_image'),
                    toggle_state: this.disable_image,
                    onExecution: () => {
                      bunch_of_settings.set('disable_image', this.disable_image);
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
                      bunch_of_settings.set('disable_js', this.disable_js);
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
              settingsModule({
                title: $r('app.string.Settings_Accessibility'),
                my_index: 3,
              }) {
                settingsSubCard({ my_index: 3, }) {
                  linysSwitchWithText({
                    text: $r('app.string.Settings_experience_sys_back_to_access_backward'),
                    toggle_state: this.sys_back_to_access_backward,
                    onExecution: () => {
                      bunch_of_settings.set('sys_back_access_backward', this.sys_back_to_access_backward);
                    }
                  }) // Use sys back in web
                  linysSwitchWithText({
                    text: $r('app.string.Settings_experience_esc_to_access_backward'),
                    toggle_state: this.esc_to_access_backward,
                    onExecution: () => {
                      bunch_of_settings.set('esc_to_access_backward', this.esc_to_access_backward);
                    }
                  }) // Use sys back in web
                  // linysText({
                  //   text: $r('app.string.Settings_experience_sys_back_to_access_backward_desc'),
                  //   is_description: true
                  // }) // Desc
                }

                settingsSubCard({
                  icon: '󰗫',
                  title: $r('app.string.Settings_single_hand_preference'),
                  my_index: 3,
                }) {
                  SegmentButton({
                    options: this.left_or_right_tabOptions,
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
                      bunch_of_settings.set('preferred_hand_reverse_settings_menu', this.preferred_hand_reverse_settings_menu);
                    }
                  }) // Reverse settings menu
                  linysSwitchWithText({
                    text: $r('app.string.Settings_Accessibility_preferred_hand_reverse_tabs_panel'),
                    toggle_state: this.preferred_hand_reverse_tabs_panel,
                    onExecution: () => {
                      bunch_of_settings.set('preferred_hand_reverse_tabs_panel', this.preferred_hand_reverse_tabs_panel);
                    }
                  }) // Reverse settings menu
                  linysSwitchWithText({
                    text: $r('app.string.Settings_Accessibility_preferred_hand_reverse_homepage_shortcuts'),
                    toggle_state: this.preferred_hand_reverse_homepage_shortcuts,
                    onExecution: () => {
                      bunch_of_settings.set('preferred_hand_reverse_homepage_shortcuts', this.preferred_hand_reverse_homepage_shortcuts);
                    }
                  }) // Reverse homepage shortcuts
                } // Single hand

                settingsSubCard({
                  icon: '󰌐',
                  title: $r('app.string.Key_shortcuts'),
                  my_index: 3,
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
              settingsModule({
                title: $r('app.string.Settings_appearance'),
                my_index: 4,
              }) {
                settingsSubCard({
                  my_index: 4,
                }) {
                  linysSwitchWithText({
                    text: $r('app.string.Settings_appearance_bottom_avoid'),
                    toggle_state: this.bottom_avoid,
                    onExecution: () => {
                      bunch_of_settings.set('bottom_avoid', this.bottom_avoid);
                    }
                  }) // Enable bottom_avoid
                } // Individuals


                settingsSubCard({
                  icon: '󰰽',
                  title: $r('app.string.Index_layout_title'),
                  my_index: 4,
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
                  icon: '󰖃',
                  title: $r('app.string.Settings_appearance_windows'),
                  my_index: 4,
                }) {
                  linysSwitchWithText({
                    text: $r('app.string.Settings_appearance_status_showing_my_windows_alias'),
                    toggle_state: this.showing_my_window_alias,
                    onExecution: () => {
                      bunch_of_settings.set('status_showing_my_windows_alias', this.showing_my_window_alias);
                    }
                  }) // Enable show my_window_alias
                  linysText({ text: $r('app.string.Settings_appearance_windows_alias_position') })
                    .opacity(this.showing_my_window_alias ? 1 : 0.5)
                    .animation(animation_default())
                  SegmentButton({
                    options: this.my_window_alias_position_tabOptions,
                    selectedIndexes: this.my_window_alias_position_selected
                  }) // Position of my_window_alias
                    .opacity(this.showing_my_window_alias ? 1 : 0.5)
                    .animation(animation_default())
                  linysSwitchWithText({
                    text: $r('app.string.Settings_appearance_effects'),
                    toggle_state: this.effects,
                    onExecution: () => {
                      bunch_of_settings.set('effects', this.effects);
                    }
                  }) // Enable advanced effects
                } // Windows

                settingsSubCard({
                  icon: '󰟠',
                  title: $r('app.string.Index_animation_title'),
                  my_index: 4,
                }) {
                  meowAnimationManager() // Animation manager
                } // Animation

                settingsSubCard({
                  icon: '󰄥',
                  title: $r('app.string.Index_colors_title'),
                  my_index: 4,
                }) {
                  meowColorsManager() // Colors manager
                  linysSwitchWithText({
                    text: $r('app.string.Settings_experience_web_force_dark_mode'),
                    toggle_state: this.web_force_dark_mode,
                    onExecution: () => {
                      bunch_of_settings.set('web_force_dark_mode', this.web_force_dark_mode);
                    }
                  }) // Force dark mode
                  linysCapsuleButtonWithText({
                    desc_text: $r('app.string.Settings_experience_manage_web_force_dark_mode'),
                    button_text: "  󰀩  ",
                    onExecution: () => {
                      this.dark_control.open();
                    }
                  }) // Dark management
                } // Colors
              }
            } // Appearance
            .width("100%")

            FlowItem() {
              settingsModule({
                title: $r('app.string.Settings_experience_history'),
                my_index: 5,
              }) {
                settingsSubCard({
                  my_index: 5,
                }) {
                  linysSwitchWithText({
                    text: $r('app.string.Settings_experience_history_record_new'),
                    toggle_state: this.collect_new_history,
                    onExecution: () => {
                      bunch_of_settings.set('collect_new_history', this.collect_new_history);
                    }
                  })
                } // Individuals // Toggle History

                settingsSubCard({
                  icon: '󰏕',
                  title: $r('app.string.Settings_experience_history'),
                  my_index: 5,
                }) {
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
                    .opacity(this.reindexing_history ? 0.5 : 1)
                    .enabled(!this.reindexing_history)
                  linysText({ text: $r('app.string.Settings_experience_history_index_load_quantity') }) // index load quantity
                  linysText({ text: $r('app.string.Settings_experience_history_index_load_quantity_desc'), is_description: true }) // index load quantity desc
                  linysLockSlider({
                    slider_min: 0,
                    slider_max: 24,
                    slider_value: this.history_index_load_quantity,
                    onTouchUp: () => {
                      bunch_of_settings.set('history_index_load_quantity', this.history_index_load_quantity);
                    }
                  }) // Slider and display of history_index_load_quantity
                }
              }
            } // History
            .width("100%")

            FlowItem() {
              settingsModule({
                title: $r('app.string.Settings_storage'),
                my_index: 6,
              }) {
                settingsSubCard({
                  icon: '󰂼',
                  title: $r('app.string.Settings_experience_webview_storage'),
                  my_index: 6,
                }) {
                  linysText({ text: $r('app.string.Settings_storage_clear_webview_desc'), is_description: true }) // Cache title
                  linysTextTitle({ text: add_units_to_size(this.web_cache_size) }) // data display
                  Row({ space: 12 }) {
                    linysCapsuleButton({ text: '  󰃈  ' })
                      .onClick(() => {
                        this.refresh_web_cache_size();
                      })
                      .opacity(this.calculating_web_cache_size ? 0.5 : 1)
                      .enabled(!this.calculating_web_cache_size)
                      .animation(animation_default())

                    linysTimeoutButton({
                      text: '  󰀖  ',
                      onExecution: () => {
                        try {
                          this.bunch_of_tabs.workingMainTab().controller!.removeCache(true);
                          console.log('[Meow][meowAppSettings] Clear webview cache!')
                        } catch (error) {
                          console.error(`[Meow][meowAppSettings] Clear webview cache.
                      ErrorCode: ${(error as BusinessError).code},
                      Message: ${(error as BusinessError).message}`);
                        }
                        this.refresh_web_cache_size();
                      }
                    })// Clear Cache
                      .opacity(this.calculating_web_cache_size ? 0.5 : 1)
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
                  my_index: 6,
                }) {
                  linysText({ text: $r('app.string.Settings_experience_history_index_storage_desc'), is_description: true }) // Indexing title
                  linysTextTitle({ text: add_units_to_size(this.history_index_size) }) // data display
                  Row({ space: 12 }) {
                    linysCapsuleButton({ text: '  󰃈  ' })
                      .onClick(() => {
                        this.refresh_history_index_size();
                      })
                      .opacity(this.calculating_history_index_size ? 0.5 : 1)
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
              settingsModule({
                title: $r('app.string.Settings_security'),
                my_index: 7,
              }) {
                settingsSubCard({
                  icon: '󰠝',
                  title: $r('app.string.Settings_cookies'),
                  my_index: 7,
                }) {
                  linysText({
                    text: $r('app.string.intelligent_tracking_prevention_desc'),
                    is_description: true
                  }) // Desc Intelligent Tracking Prevention
                  linysSwitchWithText({
                    text: $r('app.string.intelligent_tracking_prevention'),
                    toggle_state: this.intelligent_tracking_prevention,
                    onExecution: () => {
                      bunch_of_settings.set('intelligent_tracking_prevention', this.intelligent_tracking_prevention);
                      for (let index = 0; index < this.bunch_of_tabs.Tabs.length; index++) {
                        try {
                          this.bunch_of_tabs.Tabs[index].controller!.enableIntelligentTrackingPrevention(this.intelligent_tracking_prevention);
                          console.log('[Meow][meowAppSettings] Intelligent Tracking Prevention now ' + this.intelligent_tracking_prevention.toString() + '!')
                        } catch (e) {
                          console.error('[Meow][meowAppSettings] Toggle Intelligent Tracking Prevention Failed! ' +
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
                  linysSwitchWithText({
                    text: $r('app.string.enable_third_party_cookies'),
                    toggle_state: this.enable_third_party_cookies,
                    onExecution: () => {
                      bunch_of_settings.set('enable_third_party_cookies', this.enable_third_party_cookies);
                      try {
                        webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(this.enable_third_party_cookies);
                        console.log('[Meow][meowAppSettings] enable_third_party_cookies now ' + this.enable_third_party_cookies + '!')
                      } catch (e) {
                        console.error('[Meow][meowAppSettings] Toggle enable_third_party_cookies Failed! ' + e);
                      }
                    }
                  }) // enable_third_party_cookies

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
              settingsModule({
                title: $r('app.string.Settings_toolbox'),
                my_index: 8,
              }) {
                settingsSubCard({
                  icon: '󰊴',
                  title: $r('app.string.Debug'),
                  my_index: 8,
                }) {
                  linysSwitchWithText({
                    text: $r('app.string.Settings_toolbox_resource_monitor'),
                    toggle_state: this.resource_monitor,
                    onExecution: () => {
                      bunch_of_settings.set('resource_monitor', this.resource_monitor);
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
                  my_index: 8,
                }) {
                  linysText({ text: $r('app.string.Settings_toolbox_export_settings_desc'), max_lines: 3 })
                  linysCapsuleButtonWithText({
                    desc_text: $r('app.string.Settings_toolbox_export_settings'),
                    button_text: '  󰃋  ',
                    onExecution: () => {
                      // sandbox_save('settings.json', bunch_of_settings.toString());
                      document_save_text('settings.json.browsercatsettings', bunch_of_settings.toString());
                    }
                  }) // Export settings
                  linysTimeoutButtonWithText({
                    desc_text: $r('app.string.Settings_toolbox_import_settings'),
                    button_text: '  󰐝  ',
                    onExecution: () => {
                      document_pick_to_text(['browsercatsettings']).then((result) => {
                        let import_result = bunch_of_settings.import_json(result);
                        if (!import_result) {
                          this.uni_fail_prompt_gateway = $r("app.string.Fail_select_bad_settings");
                        } else {
                          bunch_of_settings.set('start_up_option', 'new tab');
                          bunch_of_settings.set('continue_tabs_count', 0);
                          bunch_of_settings.set('continue_tabs_main_on', 0);
                          bunch_of_settings.set('continue_tabs_sub_on', 0);
                          bunch_of_settings.save_to_disk();
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
                      try {
                        import_everything().then((result) => {
                          if (result) {
                            // Import OK
                            this.woofEverythingImportOK_control.open();
                          } else {
                            this.uni_fail_prompt_gateway = $r("app.string.Fail_select_bad_everything");
                          }
                        });
                      } catch (e) {
                        console.error('[Meow][meowAppSettings] Import Everything error: ' + e);
                        this.uni_fail_prompt_gateway = $r("app.string.Fail_select_bad_everything");
                      }
                    }
                  }) // Import settings
                  linysText({ text: $r('app.string.Settings_toolbox_import_everything_desc'), is_description: true, is_expanded: true })
                } // Backup
              }
            } // Toolbox / cardboard box
            .width("100%")

            FlowItem() {
              settingsModule({
                title: $r('app.string.Settings_about'),
                my_index: 9,
              }) {
                settingsSubCard({
                  icon: '󰕰',
                  title: $r('app.string.Settings_about'),
                  my_index: 9,
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
                    text: "（ฅ＾・ﻌ・＾）ฅ  - " + this.versionName + " - " + this.versionNo + ' - ' + this.buildTime,
                    max_lines: 10
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
              settingsModule({
                title: $r('app.string.Whats_new'),
                my_index: 10,
              }) {
                settingsSubCard({
                  icon: '󰁦',
                  title: $r('app.string.Update_this'),
                  my_index: 10,
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

            if (this.DEV_MODE) {
              FlowItem() {
                settingsModule({
                  title: $r('app.string.Settings_dev'),
                  my_index: 11,
                }) {
                  settingsSubCard({
                    icon: '󰊂',
                    title: $r('app.string.Settings_dev'),
                    my_index: 11,
                  }) {
                    linysText({
                      text: $r('app.string.Settings_dev_desc'),
                      max_lines: 99,
                      is_description: true,
                      is_expanded: true
                    }); // Desc

                    linysTextTitle({ text: this.my_window_id });
                    linysText({
                      text: [
                        'Index #' + this.windowIds.indexOf(this.my_window_id),
                        'ID: ' + this.storage.get('my_window_id'),
                        'bunch_of_tabs.my_id: ' + this.bunch_of_tabs.my_id,
                        'Alias: ' + this.my_window_alias,
                      ].join('\n'),
                      max_lines: 99,
                      is_description: true,
                      is_expanded: true
                    });
                    linysCapsuleButtonWithText({
                      desc_text: 'Open New Window',
                      button_text: '  󰅑  ',
                      onExecution: () => {
                        new_window(this.getUIContext().getHostContext() as common.UIAbilityContext, Date.now().toString(), default_new_window_name());
                      }
                    }); // New window

                    linysSwitchWithText({
                      text: 'Switch Free-window Mode',
                      toggle_state: this.free_window_mode
                    }); // Toggle free window mode
                    linysCapsuleButton({
                      text: 'Trim Memory'
                    })
                      .onClick(() => {
                        webview.WebviewController.trimMemoryByPressureLevel(webview.PressureLevel.MEMORY_PRESSURE_LEVEL_CRITICAL);
                      })
                    linysCapsuleButton({
                      text: 'Overwrite Easy List'
                    }) // Load Easy List
                      .onClick(() => {
                        document_pick_to_uri(['txt']).then(result => {
                          if (!result) {
                            this.uni_fail_prompt_gateway = $r('app.string.Fail_select_bad_file');
                            return;
                          }
                          console.log(`[Load Easy List] ${result}`);
                          try {
                            webview.AdsBlockManager.setAdsBlockRules(uri_2_path(result), true);
                            console.log('[Load Easy List] webview.AdsBlockManager.setAdsBlockRules!')
                          } catch (e) {
                            this.uni_fail_prompt_gateway = e.toString();
                          }
                        });
                      })
                  }
                }
              } // Update
              .width("100%")
            } // Deveowloper Options

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
            // Reduce @State / @Link calls on UI refresh
            if (this.scroll_first != first) {
              this.scroll_first = first;
            }
            if (this.scroll_last != last) {
              this.scroll_last = last;
            }
          })
        }
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
        .visibility(this.visibility_of_menu_side('right'))
        .animation(animation_default())
    }
    .width("100%")
    .animation(animation_default())
    .onAppear(() => {
      // console.log("[Meow][meowAppSettings] App Settings READY")
      this.on_appear();
      setInterval(() => {
        if (!this.showing_app_settings) {
          return;
        }
        // Deduce timeout for border highlights
        if (this.settings_scroll_to_highlight_timeout < 0) {
          this.settings_scroll_to_highlight_timeout = 0;
        } else if (this.settings_scroll_to_highlight_timeout == 0) {
          // Do nothing
        } else {
          this.settings_scroll_to_highlight_timeout -= 200;
        }
        // console.log(this.settings_scroll_to_highlight_timeout.toString())
      }, 200);
    })
  }

  // Events

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

    // Tabs
    this.new_tab_url_edit = bunch_of_tabs.new_tab_url;
    this.home_url_edit = bunch_of_tabs.home_url;

    // Start up mode
    let start_up = bunch_of_tabs.start_up;
    if (start_up == "new tab") {
      this.start_up_page_selected = [0];
    } else if (start_up == "home") {
      this.start_up_page_selected = [1];
    } else if (start_up == "continue") {
      this.start_up_page_selected = [2];
    }

    // Window alias position
    let my_window_alias_position = this.my_window_alias_position;
    if (my_window_alias_position == "left") {
      this.my_window_alias_position_selected = [0];
    } else if (my_window_alias_position == "center") {
      this.my_window_alias_position_selected = [1];
    } else if (my_window_alias_position == "right") {
      this.my_window_alias_position_selected = [2];
    }
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
    bunch_of_settings.set('title_bar_position', result);
  }

  on_prefer_hand_left_or_right_changed() {
    if (this.left_or_right_selected[0] == 0) {
      bunch_of_settings.set('preferred_hand_left_or_right', 'left');
      this.preferred_hand_left_or_right = 'left';
    } else {
      bunch_of_settings.set('preferred_hand_left_or_right', 'right');
      this.preferred_hand_left_or_right = 'right';
    }
  }

  on_start_up_option_changed() {
    let result: string = "";
    if (this.start_up_page_selected[0] == 0) {
      result = "new tab";
    } else if (this.start_up_page_selected[0] == 1) {
      result = "home";
    } else {
      result = "continue";
      // Need modify after update
    }
    bunch_of_tabs.start_up = result;
    // kv_store_put("start_up_option", result);
    bunch_of_settings.set('start_up_option', result);
  }

  on_my_window_alias_position_changed() {
    let result: string = "";
    if (this.my_window_alias_position_selected[0] == 0) {
      result = "left";
    } else if (this.my_window_alias_position_selected[0] == 1) {
      result = "center";
    } else {
      result = "right";
    }
    this.my_window_alias_position = result;
    bunch_of_settings.set('my_window_alias_position', result);
  }

  on_tabs_style_changed() {
    let result: string = "";
    if (this.tabs_style_selected[0] == 0) {
      result = 'vertical';
    } else {
      result = 'horizontal';
    }
    this.tabs_style = result;
    bunch_of_settings.set('tabs_style', result);
  }

  on_tabs_style_non_tablet_mode_changed() {
    let result: string = "";
    if (this.tabs_style_selected_non_tablet_mode[0] == 0) {
      result = 'vertical';
    } else {
      result = 'horizontal';
    }
    this.tabs_style_non_tablet_mode = result;
    bunch_of_settings.set('tabs_style_non_tablet_mode', result);
  }

  on_color_change() {
    this.title_bar_position_tabOptions = SegmentButtonOptions.tab({
      buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
      selectedBackgroundColor: this.color_current_back,
      selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
      selectedFontWeight: FontWeight.Medium
    })
    this.tabs_style_tabOptions = SegmentButtonOptions.tab({
      buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
        { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }] as ItemRestriction<SegmentButtonTextItem>,
      selectedBackgroundColor: this.color_current_back,
      selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
      selectedFontWeight: FontWeight.Medium
    })
    this.start_up_page_tabOptions = SegmentButtonOptions.tab({
      buttons: [
        { text: $r('app.string.Settings_start_up_new_tab') },
        { text: $r('app.string.Settings_start_up_home') },
        { text: $r('app.string.Settings_start_up_continue') }
      ] as ItemRestriction<SegmentButtonTextItem>,
      selectedBackgroundColor: this.color_current_back,
      selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
      selectedFontWeight: FontWeight.Medium
    })
    this.my_window_alias_position_tabOptions = SegmentButtonOptions.tab({
      buttons: [
        { text: '󰈯' },
        { text: '󰁨' },
        { text: '󰈰' }
      ],
      selectedBackgroundColor: this.color_current_back,
      selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
      selectedFontWeight: FontWeight.Medium
    })
    this.left_or_right_tabOptions = SegmentButtonOptions.tab({
      buttons: [{ text: '󰃊' }, { text: '󰈱' }],
      selectedBackgroundColor: this.color_current_back,
      selectedFontColor: this.effects ? this.color_current_font : this.color_current_primary,
      selectedFontWeight: FontWeight.Medium
    })
  }

  // Operations

  set_save_new_tab_url() {
    bunch_of_tabs.new_tab_url = this.new_tab_url_edit;
    this.bunch_of_tabs.update_my_timestamp();
    bunch_of_settings.set('new_tab_url', this.new_tab_url_edit);
  }

  set_save_home_url() {
    bunch_of_tabs.home_url = this.home_url_edit;
    this.bunch_of_tabs.update_my_timestamp();
    bunch_of_settings.set('home_url', this.home_url_edit);
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
      bunch_of_settings.set('webview_cache_size', this.web_cache_size);
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
      bunch_of_settings.set('history_index_size', this.history_index_size);
      this.calculating_history_index_size = false;
    })
  }

  /**
   * Scrolls to a specific category of settings.
   *
   * Triggered by @Watch of this.settings_scroll_to.
   * */
  scroll_settings_to() {
    if (this.settings_scroll_to < 0) {
      return;
    }
    this.settings_scroll_to_highlight_timeout = 1200;
    this.waterFlow_control.scrollToIndex(this.settings_scroll_to, true);
  }

  /**
   * Called when clicking the version code in Settings - About.
   *
   * Activates the Devs Ops.
   * */
  version_clicked() {
    this.version_clicked_times += 1;
    if (this.version_clicked_times == 7) {
      // Enter Dev mode
      bunch_of_settings.set('DEV_MODE', true);
    }
  }

  // Kinda constants

  visibility_of_menu_side(side: string) {
    if (!this.tablet_mode) {
      // Non tablet mode NO vertical menu!
      return Visibility.None;
    }
    let status = this.preferred_hand_left_or_right == side;
    if (this.preferred_hand_reverse_settings_menu) {
      status = !status;
    }
    return status ? Visibility.Visible : Visibility.None;
  }
}

export default meowAppSettings

// Cards

// @Reusable
@Component
struct settingsModule {
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Contents
  @BuilderParam contents: () => void;
  title: ResourceStr = $r('app.string.Settings_start_up');
  // Outline
  @LocalStorageLink('settings_scroll_to') settings_scroll_to: number = 0;
  my_index: number = 0;

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontColor(this.color_current_font)
        .fontSize(fontSize_Extra())
        .fontWeight(FontWeight.Bold)
        .opacity(0.8)
        .animation(animation_default())
        .padding({ left: 5 })

      Column({ space: 10 }) {
        this.contents();
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}

// @Reusable
@Component
struct settingsSubCard {
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Contents
  @BuilderParam contents: () => void;
  // Outline
  @LocalStorageLink('settings_scroll_to') settings_scroll_to: number = 0;
  my_index: number = 0;
  @LocalStorageLink('settings_scroll_to_highlight_timeout') timeout: number = 0;
  @StorageLink('effects') effects: boolean = false;
  // Title
  icon: ResourceStr | undefined = undefined;
  title: ResourceStr | undefined = undefined;
  // Stats
  @State show: boolean = false;
  @State isHov: boolean = false;

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
      Column() {
        if (this.title == undefined || this.show) {
          aniContainer() {
            this.contents();
          }
        }
      }
      .visibility((this.title == undefined || this.show) ? Visibility.Visible : Visibility.None)
      .animation(animation_default())
      .clip(true)
      .padding({ top: 12, left: 12, right: 12 })
    }
    .borderColor(this.border_color())
    .opacity((!(this.my_index == this.settings_scroll_to) && this.timeout > 0) ? 0.5 : 1)
    .backgroundColor(this.color_current_primary)
    .brightness(this.isHov ? (this.show ? 1.02 : 1.08) : 1)
    .animation(animation_default())
    .padding({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width("100%")
    .borderRadius(10)
    .borderWidth(2)
    .onHover((isHv) => {
      this.isHov = isHv;
    })
  }

  border_color() {
    let highlight = (this.my_index == this.settings_scroll_to) && this.timeout > 0;
    if (highlight) {
      return this.color_current_font;
    } else if (this.effects) {
      return 'transparent';
    } else {
      return this.color_current_primary;
    }
  }
}

// @Reusable // Is this ok? Nope, animation would be lost
@Component
struct aniContainer {
  // Contents
  @BuilderParam contents: () => void;
  // UI
  @State vis: Visibility = Visibility.None;

  build() {
    Column({ space: 12 }) {
      this.contents();
    }
    .visibility(this.vis)
    .animation(animation_default())
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .onAppear(() => {
      this.vis = Visibility.Visible;
    })
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
  @StorageLink('color_current_back') color_current_back: ResourceColor = $r('app.color.font_color_title');

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
            .backgroundColor(this.on_index_first <= index && index <= this.on_index_last ? this.color_current_back : "transparent")
            .borderRadius(this.border_radius(index))
            .animation(animation_default())
            .clip(true)
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
    if (!(this.on_index_first <= index && index <= this.on_index_last)) {
      // Not in range
      return 10;
    }

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
  @StorageLink('color_current_back') color_current_back: ResourceColor = $r('app.color.font_color_title');

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
              // Refresh button width
              if ((n.width as number) != this.button_Lengths[index]) {
                this.button_Lengths[index] = n.width as number;
              }
            })
            .backgroundColor(this.on_index_first <= index && index <= this.on_index_last ? this.color_current_back : "transparent")
            .borderRadius(this.border_radius(index))
            .clip(true)
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
    if (!(this.on_index_first <= index && index <= this.on_index_last)) {
      // Not in range
      return 10;
    }

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

@Reusable
@Component
struct menuItem {
  @State my_index: number = 0;
  @State my_text: ResourceStr = "";
  @Link on_index_first: number;
  @Link on_index_last: number;
  @Link scroll_to_gateway: number;
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('effects') effects: boolean = false;
  // UI
  @State isHov: boolean = false;

  build() {
    Row() {
      Text(this.my_text)
        .fontColor(this.on_index_first <= this.my_index && this.my_index <= this.on_index_last && !this.effects
          ? this.color_current_secondary : this.color_current_font)
        .fontSize(fontSize_Large() - 2)
    }
    .brightness(this.isHov ? 1.1 : 1)
    .clickEffect(click_effect_default())
    .padding(7)
    .animation(animation_default())
    .onClick(() => {
      this.scroll_to_gateway = -1;
      this.scroll_to_gateway = this.my_index;
    })
    .onHover((isHv) => {
      this.isHov = isHv;
    })
  }
}
