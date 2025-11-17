import { animation_default, capsule_bar_height, click_effect_default, default_new_window_name } from '../../hosts/bunch_of_defaults';
import { print_web } from '../../utils/print_tools';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import { change_window_alias, new_window, storage_of_id } from '../../utils/ui_tools';
import { cancel_in_page_search } from '../../processes/tabs_actions';
import { match_domain } from '../../utils/url_tools';
import { webview } from '@kit.ArkWeb';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import lazy { common } from '@kit.AbilityKit';
import linysText from '../../components/texts/linysText';
import linysSymbol from '../../components/texts/linysSymbol';
import lazy linysProgressInfo from '../../components/linysProgressInfo';
import lazy meowDebug from '../panels/meowDebug';
import lazy woofQR from '../../dialogs/contents/woofQR';
import lazy woofHistory from '../../dialogs/managers/woofHistory';
import lazy woofCookies from '../../dialogs/managers/woofCookies';
import lazy woofQuickUA from '../../dialogs/quicks/woofQuickUA';
import lazy woofGeneralManage from '../../dialogs/managers/woofGeneralManage';
import lazy woofPrompt from '../../dialogs/web/woofPrompt';
import lazy linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import lazy woofEasyList from '../../dialogs/managers/woofEasylist';

@Component
struct meowMoreOptions {
  @StorageLink('windowIds') windowIds: string[] = [];
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Hosts
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // UI Statuses
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  // Logics Statuses
  @LocalStorageLink('search_input') search_input: string = "ଘ*(੭*ˊᵕˋ)੭*";
  @LocalStorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  // History
  @StorageLink('reindexing_history_progress') reindexing_history_progress: string = "";
  @StorageLink('history_index_loading_progress') history_index_loading_progress: string = "";
  @StorageLink('history_index_saving_progress') history_index_saving_progress: string = "";
  // Environments
  @LocalStorageLink('fullscreen_mode') fullscreen_mode: boolean = false;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false; // Like PuraX
  // Settings
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('resource_monitor') resource_monitor: boolean = true;
  // Settings - Web
  @StorageLink('disable_js') disable_js: boolean = true;
  @StorageLink('disable_js_these_sites') disable_js_these_sites: string[] = [];
  @StorageLink('disable_js_all_sites') disable_js_all_sites: boolean = false;
  @StorageLink('disable_image') disable_image: boolean = true;
  @StorageLink('disable_image_these_sites') disable_image_these_sites: string[] = [];
  @StorageLink('disable_image_all_sites') disable_image_all_sites: boolean = false;
  @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = true;
  @StorageLink('web_force_dark_mode_exemptions') web_force_dark_mode_exemptions: string[] = [];
  @StorageLink('use_adblock') use_adblock: boolean = true;
  @StorageLink('adblock_exceptions') adblock_exceptions: string[] = [];
  // In-page search
  @LocalStorageLink('current_in_page_searching_keyword') current_in_page_searching_keyword: string = "";
  @LocalStorageLink('current_in_page_searching_stats_current') current_in_page_searching_stats_current: number = 0;
  @LocalStorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // dialogs
  @State to_fool_woofGeneralManage: boolean = false;
  woofAdsBlocker_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.use_adblock,
      sites_list: this.adblock_exceptions,
      add_site_edit: match_domain(this.search_input)[1],
      showing_add_panel: !this.compact_mode,
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
      full_view: this.compact_mode,
      extra_manage: () => {
        this.EasyList_entry_button();
      }
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  woofDarkExempts_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.web_force_dark_mode,
      sites_list: this.web_force_dark_mode_exemptions,
      add_site_edit: match_domain(this.search_input)[1],
      showing_add_panel: !this.compact_mode,
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
      full_view: this.compact_mode
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  cookies_control: CustomDialogController = new CustomDialogController({
    builder: woofCookies({
      full_view: this.compact_mode
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });
  js_manage_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.disable_js,
      sites_list: this.disable_js_these_sites,
      all_sites_switch: this.disable_js_all_sites,
      add_site_edit: match_domain(this.search_input)[1],
      showing_add_panel: !this.compact_mode,
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
      full_view: this.compact_mode
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
      add_site_edit: match_domain(this.search_input)[1],
      showing_add_panel: !this.compact_mode,
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
      full_view: this.compact_mode
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  @State rename_window_prompt_result: string = '';
  rename_window_woofPrompt_control: CustomDialogController = new CustomDialogController({
    builder: woofPrompt({
      title: $r('app.string.Settings_appearance_windows_rename'),
      message: 'ID: ' + this.my_window_id,
      value: this.my_window_alias,
      promptResult: this.rename_window_prompt_result,
      single_line: true,
      onConfirm: () => {
        change_window_alias(this.my_window_id, this.rename_window_prompt_result);
      },
      onDeny: () => {
        // Nothing happens
      }
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  woofQR_control: CustomDialogController = new CustomDialogController({
    builder: woofQR({
      title: this.current_title,
      link: this.current_url
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
  });
  woofQuickUA_control: CustomDialogController = new CustomDialogController({
    builder: woofQuickUA(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  });
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({
      full_view: this.compact_mode
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });
  EasyList_control: CustomDialogController = new CustomDialogController({
    builder: woofEasyList(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });

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

  build() {
    Scroll() {
      // if (true) {
      Column({ space: 10 }) {
        Row() // To get more space
          .visibility(this.current_in_page_searching_stats_total > 0 ? Visibility.None : Visibility.Visible)
          .animation(animation_default())

        RelativeContainer() {
          Row() {
            linysSymbol({
              symbol_glyph_target: 'sys.symbol.doc_text_badge_magnifyingglass', can_hover: true
            }) // in-page Search

            TextInput({
              text: this.current_in_page_searching_keyword,
              placeholder: $r('app.string.More_in_page_search')
            })
              .onChange((edit) => {
                this.current_in_page_searching_keyword = edit;
                this.bunch_of_tabs.workingMainTab().searching_keyword = edit;
              })
              .visibility(this.showing_scratching_board ? Visibility.Hidden : Visibility.Visible)
              .layoutWeight(1)
              .allowDrop(null)
              .margin({ left: 5, right: 5 })
              .height(capsule_bar_height())
              .fontWeight(FontWeight.Regular)
              .fontColor(this.color_current_font)
              .caretColor(this.color_current_font)
              .selectedBackgroundColor(this.color_current_font)
              .onDragEnter(() => {
                this.showing_scratching_board = false;
              })
              .enabled(this.showing_scratching_board ? false : true)
              .opacity(this.showing_scratching_board ? 0.8 : 1)
              .onSubmit(() => {
                try {
                  this.bunch_of_tabs.workingMainTab().controller!.searchAllAsync(this.current_in_page_searching_keyword);
                } catch (e) {
                  console.error(e);
                }
                focusControl.requestFocus("in_page_search_blank");
              })
              .id('in_page_search_blank')

            linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass', can_hover: true }) // Submit
              .onClick(() => {
                try {
                  this.bunch_of_tabs.workingMainTab().controller!.searchAllAsync(this.current_in_page_searching_keyword);
                } catch (e) {
                  console.error(e);
                }
              })

            linysSymbol({ symbol_glyph_target: 'sys.symbol.xmark', can_hover: true }) // Cancel
              .onClick(() => {
                cancel_in_page_search(this.storage);
              })
              .visibility(this.current_in_page_searching_keyword != "" ? Visibility.Visible : Visibility.None)
              .animation(animation_default())
          } // Search bar
          .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
          .id('in_page_search_bar')
          .alignRules(this.tablet_mode ? {
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "in_page_search_operation_buttons", align: HorizontalAlign.Start }
          } : {
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "__container__", align: HorizontalAlign.End },
            top: { anchor: "__container__", align: VerticalAlign.Top }
          })
          .animation(animation_default())

          Row() {
            linysText({
              text: this.current_in_page_searching_stats_current.toString() + '／' + this.current_in_page_searching_stats_total.toString()
            })
              .padding({ right: 5 })
              .animation(animation_default())
            if (this.showing_more_options) {
              linysSymbol({ symbol_glyph_target: 'sys.symbol.chevron_up', can_hover: true })
                .onClick(() => {
                  try {
                    this.bunch_of_tabs.workingMainTab().controller!.searchNext(false);
                  } catch (e) {
                    console.error(e);
                  }
                })
              linysSymbol({ symbol_glyph_target: 'sys.symbol.chevron_down', can_hover: true })
                .onClick(() => {
                  try {
                    this.bunch_of_tabs.workingMainTab().controller!.searchNext(true);
                  } catch (e) {
                    console.error(e);
                  }
                })
            }
          } // Operation buttons
          .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
          .id('in_page_search_operation_buttons')
          .padding({ left: this.tablet_mode ? 10 : 0 })
          .alignRules(this.tablet_mode ? {
            right: { anchor: "__container__", align: HorizontalAlign.End },
            center: { anchor: "__container__", align: VerticalAlign.Center }
          } : {
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "__container__", align: HorizontalAlign.End },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
          })
          .animation(animation_default())

        } // Search in page
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .width("100%")
        .height(20 + (this.tablet_mode ? capsule_bar_height() : 2 * capsule_bar_height() + 5))
        .backgroundColor(this.color_current_primary)
        .borderRadius(12)
        .padding(10)
        .animation(animation_default())

        if (this.showing_more_options) {
          Row() {
            linysText({
              text: '#' + this.windowIds.indexOf(this.my_window_id) + '｜' + this.my_window_alias
            }) // Current my_window_alias
              .padding({ left: 5, right: 5 })
              .layoutWeight(1)
              .clickEffect(click_effect_default())
              .onClick(() => {
                this.rename_window_woofPrompt_control.open();
              })

            linysSymbol({
              symbol_glyph_target: 'sys.symbol.pencil_and_card', can_hover: true
            }) // Edit window name
              .onClick(() => {
                this.rename_window_woofPrompt_control.open();
              })
            linysSymbol({
              // symbol_glyph_target: 'sys.symbol.plus_square_dashed_on_square',
              symbol_glyph_target: 'sys.symbol.plus', can_hover: true,
            }) // New window
              .onClick(() => {
                new_window(this.getUIContext().getHostContext() as common.UIAbilityContext, Date.now().toString(), default_new_window_name());
              })
          } // Window man
          .visibility(this.visible_when_not_in_page_search())
          .animation(animation_default())
          .opacity(0.8)
          .constraintSize({ maxWidth: 500 })
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(12)
          .padding({
            left: 10,
            right: 6,
            top: 5,
            bottom: 5
          })

          // }

          Scroll() {
            Row() {
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.save',
                can_hover: true,
              })// Save Page
                .onClick(() => {
                  this.bunch_of_tabs.archive_onWorkingTab(this.getUIContext().getHostContext()?.tempDir);
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.printer',
                can_hover: true,
              })// Print
                .onClick(() => {
                  if (this.bunch_of_tabs.workingMainTab().controller) {
                    print_web(this.bunch_of_tabs.workingMainTab().controller!, this.getUIContext().getHostContext()!);
                  }
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.star_2_moon',
                can_hover: true,
              })// Dark
                .onClick(() => {
                  this.woofDarkExempts_control.open();
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.tracking_cookie_interception',
                can_hover: true,
              })// Cookies
                .onClick(() => {
                  this.cookies_control.open();
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.picture_2',
                can_hover: true,
              })// Image
                .onClick(() => {
                  this.image_manage_control.open();
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.electric_install',
                can_hover: true,
              })// JS
                .onClick(() => {
                  this.js_manage_control.open();
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.ad_circle_slash',
                can_hover: true,
              })// Enable ads blocker
                .onClick(() => {
                  this.woofAdsBlocker_control.open();
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.arrow_counterclockwise_clock',
                can_hover: true,
              })// History
                .onClick(() => {
                  this.woofHistory_control.open();
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.label',
                can_hover: true,
              })// UA
                .onClick(() => {
                  this.woofQuickUA_control.open();
                })
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.qrcode',
                can_hover: true,
              })// QRcode
                .onClick(() => {
                  this.woofQR_control.open();
                })
              linysSymbol({
                symbol_glyph_target: this.fullscreen_mode ?
                  'sys.symbol.arrow_down_right_and_arrow_up_left' :
                  'sys.symbol.arrow_up_left_and_arrow_down_right',
                can_hover: true,
              })// FullScreen
                .onClick(() => {
                  this.fullscreen_mode = !this.fullscreen_mode;
                  this.showing_more_options = false;
                })
            } // Small buttons
            .justifyContent(FlexAlign.End)
          } // Buttons
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .visibility(this.visible_when_not_in_page_search())
          .animation(animation_default())

          // if (this.showing_more_options) {
          // Row() {
          meowDebug()
          // } // Debug
            .opacity(0.8)
            .visibility(this.resource_monitor
              ? (this.visible_when_not_in_page_search())
              : Visibility.None)
            .animation(animation_default())

          linysProgressInfo({
            notification: $r('app.string.Settings_experience_history_index_loading_index_from_disk'),
            progress: this.history_index_loading_progress,
          })
            .opacity(0.8)
            .visibility(this.history_index_loading_progress != "" ? (this.visible_when_not_in_page_search()) : Visibility.None)
            .animation(animation_default())

          linysProgressInfo({
            notification: $r('app.string.Settings_experience_history_index_reindexing'),
            progress: this.reindexing_history_progress,
          })
            .opacity(0.8)
            .visibility(this.reindexing_history_progress != "" ? (this.visible_when_not_in_page_search()) : Visibility.None)
            .animation(animation_default())

          linysProgressInfo({
            notification: $r('app.string.Settings_experience_history_index_saving_to_disk'),
            progress: this.history_index_saving_progress,
          })
            .opacity(0.8)
            .visibility(this.history_index_saving_progress != "" ? (this.visible_when_not_in_page_search()) : Visibility.None)
            .animation(animation_default())
        }
      } // Title Bar of More Options
      .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
      .animation(animation_default())
      .width("100%")

      // }
    } // More Options
    .layoutWeight(this.showing_more_options ? 1 : undefined)
    .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
    .animation(animation_default())
    .margin({ left: 15, right: 15 })
    .align(Alignment.Bottom)
    .borderRadius(10)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }

  // Visibility

  visible_when_search_input_is_not_blank() {
    return this.search_input == "" ? Visibility.None : Visibility.Visible
  }

  visible_when_not_in_page_search() {
    return this.current_in_page_searching_stats_total <= 0 ? Visibility.Visible : Visibility.None;
  }
}

export default meowMoreOptions;