import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import linysImageButton from '../../components/buttons/linysImageButton';
import linysSymbol from '../../components/texts/linysSymbol';
import lazy woofQR from '../../dialogs/contents/woofQR';
import lazy woofEasyList from '../../dialogs/managers/woofEasylist';
import lazy woofHistory from '../../dialogs/managers/woofHistory';
import lazy woofQuickUA from '../../dialogs/quicks/woofQuickUA';
import lazy woofCookies from '../../dialogs/managers/woofCookies';
import lazy woofExtensions from '../../dialogs/contents/woofExtensions';
import lazy woofGeneralManage from '../../dialogs/managers/woofGeneralManage';
import { animation_default, default_title_function_buttons_amount, default_window_orientations } from '../../hosts/bunch_of_defaults';
import lazy { bunch_of_extensions, extension } from '../../hosts/bunch_of_extensions';
import lazy { ExtNodeController } from '../../objects/ExtWebNode';
import lazy { detach_show_extension } from '../../processes/web_actions';
import { set_orientation, storage_of_id } from '../../utils/ui_tools';
import { match_domain } from '../../utils/url_tools';
import lazy { webview } from '@kit.ArkWeb';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import lazy { print_web } from '../../utils/print_tools';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { all_false, boolean_to_string } from '../../utils/data_operation_tools';
import { window } from '@kit.ArkUI';


@Component
struct meowTitleFunctionButton {
  // CONFIG
  @StorageLink('title_CONFIG_EXTENSIONS') @Watch('CONFIG_BUTTONS_change') CONFIG_EXTENSIONS: boolean = true;
  @StorageLink('title_CONFIG_BUTTONS') @Watch('CONFIG_BUTTONS_change') CONFIG_BUTTONS: boolean[] = all_false(default_title_function_buttons_amount());
  MODE_EDIT: boolean = false; // If set to true, then clicking these buttons would modify the CONFIG_BUTTONS variables instead of executing the real functions.
  MODE_FULL: boolean = false; // If set to true, then all buttons are shown no matter what their settings are.
  // Env
  @StorageLink('DEV_MODE') DEV_MODE: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('my_windowClass') my_windowClass: window.Window | undefined = undefined;
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @StorageLink('free_window_mode') free_window_mode: boolean = false;
  @LocalStorageLink('fullscreen_mode') fullscreen_mode: boolean = false;
  @LocalStorageLink('fullscreen_mode_immersive') fullscreen_mode_immersive: boolean = true;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('orientation') orientation: window.Orientation = window.Orientation.AUTO_ROTATION_RESTRICTED;
  // UI
  @LocalStorageLink('compact_mode') compact_mode: boolean = false; // Like PuraX
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('showing_ext_id') showing_ext_id: string = '';
  @LocalStorageLink('showing_ext_node_controller') showing_ext_node_controller: ExtNodeController | undefined = undefined;
  // uwu
  @LocalStorageLink('search_input') search_input: string = "ଘ*(੭*ˊᵕˋ)੭*";
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  // Hosts
  @StorageLink('bunch_of_extensions') bunch_of_extensions: bunch_of_extensions = new bunch_of_extensions();
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
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
  // In page search
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
  Extensions_control: CustomDialogController = new CustomDialogController({
    builder: woofExtensions(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });

  @Builder
  OrientationMenu() {
    Menu() {
      ForEach(default_window_orientations(), (ori: window.Orientation, idx: number) => {
        MenuItem({
          content: $r('app.string.orientation_select_'.concat(idx.toString())),
        })
          .onClick(() => {
            set_orientation(this.my_windowClass, ori)?.then((r) => {
              if (r == true) {
                this.orientation = ori;
              }
            })
          })
          .backgroundColor(ori == this.orientation ? this.color_current_secondary : undefined)
      })
    }
    .fontColor(this.color_current_font)
    .backgroundColor(this.color_current_primary)
  }

  @Builder
  FullscreenMenu() {
    Menu() {
      MenuItem({
        content: $r('app.string.fullscreen_select_window'),
      })
        .onClick(() => {
          if (this.free_window_mode) {
            this.fullscreen_mode_immersive = false;
            this.fullscreen_mode = !this.fullscreen_mode;
            this.showing_more_options = false;
          } else {
            // do nothing
          }
        })
        .opacity(this.free_window_mode ? 1 : 0.5)
      MenuItem({
        content: $r('app.string.fullscreen_select_full'),
      })
        .onClick(() => {
          setTimeout(() => {
            this.fullscreen_mode_immersive = true;
            this.fullscreen_mode = !this.fullscreen_mode;
            this.showing_more_options = false;
          }, 200)
        })
    }
    .fontColor(this.color_current_font)
    .backgroundColor(this.color_current_primary)
  }

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
      Row() {
        if (this.DEV_MODE) {
          if (!this.MODE_EDIT && this.CONFIG_EXTENSIONS) {
            ForEach(this.bunch_of_extensions.extensions, (ext: extension, idx: number) => {
              linysImageButton({
                path: ext.path_full + '/' + (ext.action_default_icon_path || ext.icon_path),
                can_hover: true,
                execution: () => {
                  this.get_me_extension_web(ext);
                },
              }).bindTips(ext.action_default_title || ext.name, {
                appearingTime: 1,
                disappearingTime: 1,
                enableArrow: true,
              })
            }, (ext: extension) => {
              return ext.id;
            })
          }

          linysSymbol({
            symbol_glyph_target: 'sys.symbol.root',
            can_hover: true,
          })// Extensions
            .visibility(this.CONFIG_EXTENSIONS || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
            .opacity(this.CONFIG_EXTENSIONS || this.MODE_FULL ? 1 : 0.5)
            .animation(animation_default())
            .onClick(() => {
              if (this.MODE_EDIT) {
                this.CONFIG_EXTENSIONS = !this.CONFIG_EXTENSIONS;
                return;
              }
              this.Extensions_control.open();
            })
        } // Extensions

        linysSymbol({
          symbol_glyph_target: 'sys.symbol.rectangle_portrait_rotate',
          can_hover: true,
        })// Orientation
          .visibility(this.CONFIG_BUTTONS[0] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[0] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .bindMenu(this.MODE_EDIT ? undefined : this.OrientationMenu)
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[0] = !this.CONFIG_BUTTONS[0];
              return;
            }
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.save',
          can_hover: true,
        })// Save Page
          .visibility(this.CONFIG_BUTTONS[1] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[1] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[1] = !this.CONFIG_BUTTONS[1];
              return;
            }
            this.bunch_of_tabs.archive_onWorkingTab(this.getUIContext().getHostContext()?.tempDir);
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.printer',
          can_hover: true,
        })// Print
          .visibility(this.CONFIG_BUTTONS[2] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[2] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[2] = !this.CONFIG_BUTTONS[2];
              return;
            }
            if (this.bunch_of_tabs.workingMainTab().controller) {
              print_web(this.bunch_of_tabs.workingMainTab().controller!, this.getUIContext().getHostContext()!);
            }
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.star_2_moon',
          can_hover: true,
        })// Dark
          .visibility(this.CONFIG_BUTTONS[3] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[3] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[3] = !this.CONFIG_BUTTONS[3];
              return;
            }
            this.woofDarkExempts_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.tracking_cookie_interception',
          can_hover: true,
        })// Cookies
          .visibility(this.CONFIG_BUTTONS[4] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[4] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[4] = !this.CONFIG_BUTTONS[4];
              return;
            }
            this.cookies_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.picture_2',
          can_hover: true,
        })// Image
          .visibility(this.CONFIG_BUTTONS[5] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[5] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[5] = !this.CONFIG_BUTTONS[5];
              return;
            }
            this.image_manage_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.electric_install',
          can_hover: true,
        })// JS
          .visibility(this.CONFIG_BUTTONS[6] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[6] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[6] = !this.CONFIG_BUTTONS[6];
              return;
            }
            this.js_manage_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.ad_circle_slash',
          can_hover: true,
        })// Enable ads blocker
          .visibility(this.CONFIG_BUTTONS[7] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[7] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[7] = !this.CONFIG_BUTTONS[7];
              return;
            }
            this.woofAdsBlocker_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.arrow_counterclockwise_clock',
          can_hover: true,
        })// History
          .visibility(this.CONFIG_BUTTONS[8] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[8] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[8] = !this.CONFIG_BUTTONS[8];
              return;
            }
            this.woofHistory_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.label',
          can_hover: true,
        })// UA
          .visibility(this.CONFIG_BUTTONS[9] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[9] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[9] = !this.CONFIG_BUTTONS[9];
              return;
            }
            this.woofQuickUA_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.qrcode',
          can_hover: true,
        })// QRcode
          .visibility(this.CONFIG_BUTTONS[10] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[10] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[10] = !this.CONFIG_BUTTONS[10];
              return;
            }
            this.woofQR_control.open();
          })
        linysSymbol({
          symbol_glyph_target: this.fullscreen_mode ?
            'sys.symbol.arrow_down_right_and_arrow_up_left' :
            'sys.symbol.arrow_up_left_and_arrow_down_right',
          can_hover: true,
        })// FullScreen
          .visibility(this.CONFIG_BUTTONS[11] || this.MODE_EDIT || this.MODE_FULL ? Visibility.Visible : Visibility.None)
          .opacity(this.CONFIG_BUTTONS[11] || this.MODE_FULL ? 1 : 0.5)
          .animation(animation_default())
          .bindMenu(this.MODE_EDIT ? undefined : this.FullscreenMenu)
          .onClick(() => {
            if (this.MODE_EDIT) {
              this.CONFIG_BUTTONS[11] = !this.CONFIG_BUTTONS[11];
              return;
            }
          })

      } // Small buttons
      .justifyContent(FlexAlign.End)
    } // Buttons
    .borderRadius(8)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())
  }

  visible_when_not_in_page_search() {
    return this.current_in_page_searching_stats_total <= 0 ? Visibility.Visible : Visibility.None;
  }

  // Actions

  /**
   * What happens after clicking on an Extension icon.
   * @param ext The extension clicked on.
   * */
  get_me_extension_web(ext: extension) {
    let idx = this.bunch_of_extensions.index_of_id(ext.id);
    let that_window_id = ext.storage?.get('my_window_id') as string;

    if (ext.is_being_viewed) {
      // Is attached

      // // Detach
      // let nodeCon = ext.storage?.get('showing_ext_node_controller') as ExtNodeController;
      // nodeCon?.detachWeb();
      // nodeCon?.rebuild();
      // ext.storage?.set('showing_ext_id', '');
      // ext.storage?.set('showing_ext_node_controller', undefined);
      // ext.is_being_viewed = false;
      // ext.controller.loadUrl($rawfile('home.html'));
      // ext.storage = undefined;
      // nodeCon?.update(ext);
      // console.log(`[Extension][${ext.name}][${ext.id}] Button clicked ~ Detached Extension Web from [${that_window_id}]!`);
      // // return;

      detach_show_extension(ext);

      if (that_window_id == this.my_window_id) {
        return;
      }
    }

    setTimeout(() => {
      // Not attached
      if (ext.action_default_popup && (idx != undefined)) {
        // Attach
        this.showing_ext_id = ext.id;
        this.showing_ext_node_controller = this.bunch_of_extensions.NodeControllers[idx];
        this.showing_ext_node_controller?.attachWeb();
        this.showing_ext_node_controller?.rebuild();
        ext.storage = this.storage;
        ext.is_being_viewed = true;
        this.showing_ext_node_controller?.update(ext);
        console.log(`[Extension][${ext.name}][${ext.id}] LoadUrl: [${ext.path_full + '/' + ext.action_default_popup}]`);
        try {
          ext.controller.loadUrl(ext.path_full + '/' + ext.action_default_popup);
        } catch (error) {
          console.error(`[Extension][${ext.name}][${ext.id}] LoadUrl: [${ext.path_full + '/' + ext.action_default_popup}] Failed: [${error}]`);
        }
        // Show
        this.showing_more_options = false;
        console.log(`[Extension][${ext.name}][${ext.id}] Button clicked ~ Attached Extension Web to [${this.my_window_id}]`);
      } else {
        this.showing_ext_id = '';
        this.showing_ext_node_controller = undefined;
        console.log(`[Extension][${ext.name}][${ext.id}] Button clicked ~ But no popup. Fire chrome.action.onClicked!`);
        ext.controller.runJavaScriptExt('chrome.action.onClicked.fire();').catch(() => {
          console.error(`[Extension][${ext.name}][${ext.id}] Fire chrome.action.onClicked failed.`);
        })
      }

      // console.log(`[Extension][${ext.name}][${ext.id}][${this.my_window_id}] After click: this.showing_ext_node_controller is ${this.showing_ext_node_controller ?
      //   'valid' : 'undefined'}, and this.showing_ext_id = ${this.showing_ext_id}!`);
    }, 10);
  }

  CONFIG_BUTTONS_change() {
    console.log(`[meowTitleFunctionButton] Ext = ${this.CONFIG_EXTENSIONS}, Buttons = ${this.CONFIG_BUTTONS}`);
    bunch_of_settings.set('title_function_extensions', boolean_to_string(this.CONFIG_EXTENSIONS));
    let config_buttons_str: string = '';
    for (let index = 0; index < this.CONFIG_BUTTONS.length; index++) {
      if (this.CONFIG_BUTTONS[index]) {
        config_buttons_str += '1';
      } else {
        config_buttons_str += '0';
      }
    }
    bunch_of_settings.set('title_function_buttons', config_buttons_str);
    console.log(`[meowTitleFunctionButton] config_buttons_str = ${config_buttons_str}`);
  }
}

export default meowTitleFunctionButton