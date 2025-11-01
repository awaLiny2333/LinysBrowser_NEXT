import { animation_default, capsule_bar_height } from '../../hosts/bunch_of_defaults';
import { bunch_of_history } from '../../hosts/bunch_of_history';
import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { compress_image_arrayBuffer, sandbox_read_arrayBuffer_sync } from '../../utils/storage_tools';
import { url_resource_to_meow } from '../../utils/url_tools';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { bookmark, bunch_of_bookmarks, folder, unified_item } from '../../hosts/bunch_of_bookmarks';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import { window } from '@kit.ArkUI';
import { is_address_continuable, run_time, set_continuable, storage_of_id } from '../../utils/ui_tools';
import lazy { harmonyShare, systemShare } from '@kit.ShareKit';
import lazy { webview } from '@kit.ArkWeb';
import lazy { print } from '@kit.BasicServicesKit';
import lazy { common } from '@kit.AbilityKit';
import lazy { uniformTypeDescriptor } from '@kit.ArkData';
import woofPrompt from '../../dialogs/web/woofPrompt';
import woofConfirm from '../../dialogs/web/woofConfirm';
import woofAlert from '../../dialogs/web/woofAlert';
import linysText from '../../components/texts/linysText';
import lazy woofWantJump from '../../dialogs/prompts/woofWantJump';
import lazy woofWantResources from '../../dialogs/prompts/woofWantProtectedResources';
import lazy woofHomepageManager from '../../dialogs/managers/woofHomepageManager';
import lazy woofWantDownload from '../../dialogs/prompts/woofWantDownload';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';

@Component
struct meowWebView {
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('my_windowClass') my_windowClass: window.Window | undefined = undefined;
  // Hosts
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads(true);
  // Environments
  @StorageLink('currentColorMode') current_color_mode: number = 0;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('fullscreen_mode') @Watch('on_fullscreen_change') fullscreen_mode: boolean = false;
  @LocalStorageLink('fullscreen_handler') handler: FullScreenExitHandler | null = null;
  @LocalStorageLink('restore_web_state_arrays') restore_web_state_arrays: Uint8Array[] = [];
  @LocalStorageProp('screen_height') screen_height: number = 100;
  @LocalStorageLink('on_focus') @Watch('on_focus_change') on_focus: boolean = true;
  @LocalStorageLink('sharable_continuable') sharable_continuable: boolean = false;
  // In-Page Searching
  @LocalStorageLink('current_in_page_searching_stats_current') current_in_page_searching_stats_current: number = 0;
  @LocalStorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  /**
   * Controls */
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";
  @LocalStorageLink('tab_urls') tab_urls: string[] = []
  @LocalStorageLink('current_url') @Watch('on_current_url_change') current_url: string = "=￣ω￣=";
  @LocalStorageLink('tab_match_domains') tab_match_domains: string[][] = [];
  @LocalStorageLink('tab_restore_on_creations') tab_restore_on_creations: boolean[] = [false];
  /**
   * Web control statuses */
  @LocalStorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  // Settings
  @StorageLink('use_adblock') @Watch('on_use_adblock_state_change') use_adblock: boolean = true;
  @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = false;
  @StorageLink('web_force_dark_mode_exemptions') web_force_dark_mode_exemptions: string[] = [];
  /**
   * Stuffs */
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  /**
   * Visual */
  @StorageLink('homepage_background') homepage_background: PixelMap | undefined = undefined;
  @State last_timeout_id: number | undefined = undefined;
  @State shortcut_scroll_offset: number = 0;
  @LocalStorageLink('potential_jump_link') @Watch('on_potential_jump_link_change') potential_jump_link: string = '';
  @LocalStorageLink('extra_background') extra_background: boolean = false;
  @State my_opacity: number = 0;
  // Delay
  @LocalStorageLink('delayed_load_p0') delayed_load_p0: boolean = false;
  @LocalStorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  // Download
  @StorageLink('dl_delegate') dl_delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();
  @LocalStorageLink('uni_webDownloadItem_gateway') @Watch('on_download_request') uni_webDownloadItem_gateway: webview.WebDownloadItem | undefined = undefined;
  @StorageLink('print_adapter') print_adapter: print.PrintDocumentAdapter | undefined = undefined;
  // dialogs
  woofWantDownload_control: CustomDialogController = new CustomDialogController({
    builder: woofWantDownload({
      from: this.current_url,
      file_name: '',
      url: '',
      try_additional_info: []
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  });
  woofLinkJumper_control: CustomDialogController = new CustomDialogController({
    builder: woofWantJump({
      link: this.potential_jump_link,
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%"
  });
  @LocalStorageLink('js_prompt_event') @Watch('on_js_prompt_event') js_prompt_event: OnPromptEvent | undefined = undefined;
  @State js_prompt_result: string = '';
  woofPrompt_control: CustomDialogController = new CustomDialogController({
    builder: woofPrompt({
      title: this.js_prompt_event?.url,
      message: this.js_prompt_event?.message,
      value: this.js_prompt_event?.value,
      promptResult: this.js_prompt_result,
      onConfirm: () => {
        this.js_prompt_event?.result.handlePromptConfirm(this.js_prompt_result);
      },
      onDeny: () => {
        this.js_prompt_event?.result.handleCancel();
      }
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  @LocalStorageLink('js_confirm_event') @Watch('on_js_confirm_event') js_confirm_event: OnConfirmEvent | undefined = undefined;
  woofConfirm_control: CustomDialogController = new CustomDialogController({
    builder: woofConfirm(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  @LocalStorageLink('ssl_error_event') @Watch('on_ssl_error_event') ssl_error_event: SslErrorEvent | undefined = undefined;
  woof_SSL_error_control: CustomDialogController = new CustomDialogController({
    builder: woofConfirm(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  @LocalStorageLink('js_alert_event') @Watch('on_js_alert_event') js_alert_event: OnAlertEvent | undefined = undefined;
  woofAlert_control: CustomDialogController = new CustomDialogController({
    builder: woofAlert({
      event: this.js_alert_event
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  @LocalStorageLink('permission_request_event') @Watch('on_permission_request_event') permission_request_event: OnPermissionRequestEvent | undefined = undefined;
  onPermit?: () => void;
  onDeny?: () => void;
  ask_resources: string[] = [];
  source: string = '';
  woofWantProtectedResources_control: CustomDialogController = new CustomDialogController({
    builder: woofWantResources({
      protected_resource_types: this.ask_resources,
      onPermit: this.onPermit,
      onDeny: this.onDeny,
      source: this.source
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  });
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Else
  @LocalStorageLink('meowWebView_init_OK') init_OK: boolean = false;
  httpAuth: boolean = false;
  // Toasts
  @State show_toast_fullscreen: boolean = false;

  aboutToAppear(): void {
    console.log(' \n[meowWebView][aboutToAppear] this.bunch_of_tabs.my_id: ' + this.bunch_of_tabs.my_id + '\n ');

    set_continuable(this.getUIContext().getHostContext() as common.UIAbilityContext, false);
  }

  build() {
    RelativeContainer() {
      if (this.homepage_background) {
        Image(this.homepage_background)
          .visibility((this.current_url == 'meow://home') && this.bunch_of_tabs.sub_tab_idx == -1 ? Visibility.Visible : Visibility.Hidden)
          .opacity(Math.max(1 - this.shortcut_scroll_offset / this.screen_height, 0.5))
      } // Background

      Row() // Background color
        .backgroundColor(this.current_color_mode == 0 ? (this.web_force_dark_mode ? 'black' : 'white') : 'white')
        .height('100%')
        .width('100%')
        .visibility(this.extra_background ? Visibility.Visible : Visibility.Hidden)

      if (this.delayed_load_p1) {
        ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
          NodeContainer(this.bunch_of_tabs.NodeControllers[Label.index_key])
            .onAppear(() => {
              try {
                this.bunch_of_tabs.NodeControllers[Label.index_key].attachWeb();
                this.bunch_of_tabs.NodeControllers[Label.index_key].rebuild();
              } catch (e) {
                console.error('[Tab] onAppear Failed: ' + e);
              }
            })
            .width(this.bunch_of_tabs.sub_tab_idx < 0 ? "100%" : this.width_tab())
            .height(this.bunch_of_tabs.sub_tab_idx < 0 ? "100%" : this.height_tab())
            .alignRules(this.bunch_of_tabs.main_tab_idx == Label.index_key ? this.align_rules_main_tab() : this.align_rules_sub_tab())
            .visibility(this.my_visibility(Label.index_key))
          // Webs
        }, (Label: tab_label) => Label.timestamp.toString())
      }

      shortcuts({
        shortcut_scroll_offset: this.shortcut_scroll_offset,
      })

      // Notices
      if (this.delayed_load_p1) {
        Column({ space: (this.show_toast_fullscreen) ? 10 : 0 }) {
          toast({
            show: this.show_toast_fullscreen,
            info: $r('app.string.fullscreen_notice')
          })
        }
        .translate({ y: -20 })
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
        })
        .onAppear(() => {
          // Init download delegate
          this.bunch_of_downloads.init_delegate(this.storage);

          // init OK
          this.on_current_url_change();

          this.init_OK = true;
        })
      }
    }
    .opacity(this.my_opacity)
    .animation({ duration: 200 })
    .width("100%")
    .height("100%")
    .onAppear(() => {
      // console.log("[Meow][meowWebView] WebViews READY")
      this.my_opacity = 1;
      console.log(`[Meow][meowWebView] onAppear! (${run_time(this.storage)} ms)`);
    })
  }

  // Events

  /**
   * Manage continuable and sharing statuses.
   * */
  on_current_url_change() {
    try {
      // Update continuable state.
      let original_sharable_continuable = this.sharable_continuable;
      is_address_continuable(this.current_url, this.storage);

      if (this.sharable_continuable == original_sharable_continuable) {
        // Nothing changed;
      } else {
        set_continuable(this.getUIContext().getHostContext() as common.UIAbilityContext, this.sharable_continuable);
        if (this.sharable_continuable) {
          this.register_harmonyShare_gesture_sender();
          this.register_harmonyShare_knock_sender();
        } else {
          this.off_harmonyShare_gesture_sender();
          this.off_harmonyShare_knock_sender();
        }
      }
    } catch (e) {
      console.error('[on_current_url_change] Failed: ' + e);
    }
  }

  on_fullscreen_change() {
    if (this.fullscreen_mode) {
      this.show_toast_fullscreen = true;
    }
  }

  on_focus_change() {
    if (this.on_focus) {
      set_continuable(this.getUIContext().getHostContext() as common.UIAbilityContext, is_address_continuable(this.current_url || ''));
    } else {
      set_continuable(this.getUIContext().getHostContext() as common.UIAbilityContext, false);
    }
  }

  on_js_prompt_event() {
    this.woofPrompt_control.open();
  }

  on_js_alert_event() {
    this.woofAlert_control.open();
  }

  on_js_confirm_event() {
    this.woofConfirm_control = new CustomDialogController({
      builder: woofConfirm({
        title: this.js_confirm_event?.url,
        desc: this.js_confirm_event?.message,
        onConfirm: () => {
          this.js_confirm_event?.result.handleConfirm();
        },
        onDeny: () => {
          this.js_confirm_event?.result.handleCancel();
        }
      }),
      alignment: DialogAlignment.Center,
      cornerRadius: 26
    });
    this.woofConfirm_control.open();
  }

  on_ssl_error_event() {
    if (this.ssl_error_event == undefined) {
      return;
    }
    this.woof_SSL_error_control = new CustomDialogController({
      builder: woofConfirm({
        title: $r('app.string.SSL_error_title'),
        desc: this.human_desc_of_ssl_error(this.ssl_error_event),
        onConfirm: () => {
          this.ssl_error_event?.handler.handleConfirm();
        },
        onDeny: () => {
          this.ssl_error_event?.handler.handleCancel(true);
        }
      }),
      alignment: DialogAlignment.Center,
      cornerRadius: 26
    });
    this.woof_SSL_error_control.open();
  }

  on_permission_request_event() {
    if (this.permission_request_event) {
      this.process_permission_request(this.permission_request_event);
    }
  }

  on_potential_jump_link_change() {
    this.woofLinkJumper_control.open();
  }

  // Operations

  update_search_box_text(text: string) {
    if (!this.is_search_input_typing) {
      this.storage.set('search_input', url_resource_to_meow(text));
      // Update Input Search Box
    }
    // Update Input Search Box when new page loaded
  }

  /**
   * Enable ads block for all tabs.
   * */
  on_use_adblock_state_change() {
    console.log('[meowWebView] enableAdsBlock: ' + (this.use_adblock ? 'true' : 'false'))
    try {
      for (let index = 0; index < this.bunch_of_tabs.Tabs.length; index++) {
        this.bunch_of_tabs.Tabs[index].controller.enableAdsBlock(this.use_adblock);
      }
    } catch (e) {
      console.error('[meowWebView][on_use_adblock_state_change] enableAdsBlock error: ' + e);
    }
  }

  on_download_request() {
    if (!this.uni_webDownloadItem_gateway) {
      return;
    }

    let file_name = this.uni_webDownloadItem_gateway!.getSuggestedFileName();
    let file_url = this.uni_webDownloadItem_gateway!.getUrl();
    // Call popup
    this.woofWantDownload_control = new CustomDialogController({
      builder: woofWantDownload({
        from: this.current_url,
        file_name: file_name,
        url: file_url,
        item: this.uni_webDownloadItem_gateway,
      }),
      alignment: DialogAlignment.Center,
      cornerRadius: 26
    });
    this.woofWantDownload_control.open();
    console.log('[Meow][meowWebView] on_download_request because I AM on top! (' + this.my_window_id + ')');
  }

  async general_harmonyShare_current_tab(sharableTarget: harmonyShare.SharableTarget) {
    let t0 = Date.now();

    let img_buffer = sandbox_read_arrayBuffer_sync('homepage_background_arrayBuffer');
    let thumbnail_buffer: ArrayBuffer = new ArrayBuffer(8);

    // Compress image
    if (img_buffer) {
      thumbnail_buffer = await compress_image_arrayBuffer(img_buffer);
    }

    let share_success = true;
    // Try to share with or without thumbnail
    try {
      let shareData_with_thumbnail: systemShare.SharedData = new systemShare.SharedData({
        utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
        content: this.current_url,
        title: this.current_title,
        description: this.current_url,
        thumbnail: new Uint8Array(thumbnail_buffer)
      });
      sharableTarget.share(shareData_with_thumbnail);
    } catch (e) {
      try {
        let shareData: systemShare.SharedData = new systemShare.SharedData({
          utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
          content: this.current_url,
          title: this.current_title,
          description: this.current_url,
        });
        sharableTarget.share(shareData);
      } catch (e) {
        share_success = false;
      }
    }

    if (share_success) {
      console.log('[meowWebView] harmonyShare: URL: ' + this.current_url + ' (' + (Date.now() - t0) + ' ms)');
    } else {
      console.error('[meowWebView] harmonyShare FAILED: URL: ' + this.current_url + ' (' + (Date.now() - t0) + ' ms)');
    }
  }

  register_harmonyShare_gesture_sender() {
    try {
      harmonyShare.on('gesturesShare', async (sharableTarget: harmonyShare.SharableTarget) => {
        console.log('[meowWebView] harmonyShare - gesturesShare!');
        await this.general_harmonyShare_current_tab(sharableTarget);
      });

      console.log('[meowWebView] Register harmonyShare of gesturesShare!');
    } catch (e) {
      console.error('[meowWebView] Register harmonyShare of gesturesShare failed: ' + e);
    }
  }

  off_harmonyShare_gesture_sender() {
    try {
      harmonyShare.off('gesturesShare');
    } catch (e) {
      console.error('[off_harmonyShare_gesture_sender] Failed: ' + e);
    }
  }

  register_harmonyShare_knock_sender() {
    try {
      harmonyShare.on('knockShare', async (sharableTarget: harmonyShare.SharableTarget) => {
        console.log('[meowWebView] harmonyShare - knockShare!');
        await this.general_harmonyShare_current_tab(sharableTarget);
      });

      console.log('[meowWebView] Register harmonyShare of knockShare!');
    } catch (e) {
      console.error('[meowWebView] Register harmonyShare of knockShare failed: ' + e);
    }
  }

  off_harmonyShare_knock_sender() {
    try {
      harmonyShare.off('knockShare');
    } catch (e) {
      console.error('[off_harmonyShare_gesture_sender] Failed: ' + e);
    }
  }

  process_permission_request(event: OnPermissionRequestEvent) {
    this.onPermit = () => {
      event.request.grant(event.request.getAccessibleResource());
    }
    this.onDeny = () => {
      event.request.deny();
    }
    this.ask_resources = event.request.getAccessibleResource();
    this.source = event.request.getOrigin();
    console.log('[Meow][meowWebView] Requesting Protected Resources: ' + event.request.getAccessibleResource());

    // TODO: work out a workable permission manager!

    if (this.ask_resources.length == 0) {
      this.onPermit();
      console.log('[Meow][meowWebView] Permitted empty request list automatically!');
      return;
    }

    if (this.ask_resources.length == 1 && this.ask_resources[0] == 'TYPE_SENSOR') {
      this.onPermit();
      console.log('[Meow][meowWebView] Permitted TYPE_SENSOR automatically!');
      return;
    }

    this.woofWantProtectedResources_control.open();
  }

  // Kind of constants

  align_rules_main_tab() {
    let align: AlignRuleOption;
    if (this.tablet_mode) {
      align = { left: { anchor: "__container__", align: HorizontalAlign.Start } }
    } else {
      align = { top: { anchor: "__container__", align: VerticalAlign.Top } }
    }
    return align;
  }

  align_rules_sub_tab() {
    let align: AlignRuleOption;
    if (this.tablet_mode) {
      align = { right: { anchor: "__container__", align: HorizontalAlign.End } }
    } else {
      align = { bottom: { anchor: "__container__", align: VerticalAlign.Bottom } }
    }
    return align;
  }

  width_tab() {
    if (this.tablet_mode) {
      return "50%";
    } else {
      return "100%";
    }
  }

  height_tab() {
    if (this.tablet_mode) {
      return "100%";
    } else {
      return "50%";
    }
  }

  my_visibility(index: number) {
    if (!(this.bunch_of_tabs.main_tab_idx == index || this.bunch_of_tabs.sub_tab_idx == index)) {
      // Not present
      return Visibility.None;
    }
    return Visibility.Visible;
  }

  human_desc_of_ssl_error(e: SslErrorEvent) {
    let error_descs: string[] = ['Invalid', 'HostMismatch', 'DateInvalid', 'Untrusted'];
    return `(　o=^•ェ•)o : ${error_descs[e.error as number]}
url: ${e.url}
originalUrl: ${e.originalUrl}
referrer: ${e.referrer}
isFatalError: ${e.isFatalError}
isMainFrame: ${e.isMainFrame}`;
  }
}

export default meowWebView;

@Component
struct shortcuts {
  shortcut_scroller: Scroller = new Scroller();
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_bookmarks') @Watch('refresh_homepage_shortcuts') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks('Bookmarks~Meow');
  @StorageLink('homepage_shortcuts_bookmarks_dir') @Watch('refresh_homepage_shortcuts') homepage_shortcuts_dir: string = '/';
  // Environment
  @LocalStorageProp('screen_height') screen_height: number = 100;
  // Statuses
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @Link shortcut_scroll_offset: number;
  @State homepage_shortcuts: unified_item[] = [];
  // Settings
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  // Popups
  woofHomepageManager_control: CustomDialogController = new CustomDialogController({
    builder: woofHomepageManager(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
  });

  aboutToAppear(): void {
    this.refresh_homepage_shortcuts();
  }

  build() {
    Scroll(this.shortcut_scroller) {
      Column({ space: 10 }) {
        ForEach(this.homepage_shortcuts, (shortcut: unified_item, key: number) => {
          shortcutButton({
            bookmark: shortcut,
            my_index: key,
          })
        })
      }
      .alignItems(this.shortcut_alignItems())
      .padding({ top: Math.max(18, this.screen_height * (1 - this.homepage_shortcuts_init_height * 0.01)) })
      .animation(animation_default())
      .width('100%')
    } // Shortcuts
    .padding({ right: 14, left: 14, bottom: 18 })
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
    .align(Alignment.Bottom)
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())
    .scrollBar(BarState.Off)
    .visibility((this.current_url == 'meow://home' && this.bunch_of_tabs.sub_tab_idx == -1) ? Visibility.Visible : Visibility.None)
    .onDidScroll(() => {
      this.shortcut_scroll_offset = this.shortcut_scroller.currentOffset().yOffset;
    })
    .onClick(() => {
      this.woofHomepageManager_control.open();
    })
  }

  // Values

  shortcut_alignItems() {
    let status = this.preferred_hand_left_or_right == 'right';
    if (this.preferred_hand_reverse_homepage_shortcuts) {
      status = !status;
    }
    return status ? HorizontalAlign.End : HorizontalAlign.Start;
  }

  // Actions

  /**
   * Tries to retrieve homepage shortcuts from bunch_of_bookmarks.
   * */
  refresh_homepage_shortcuts() {
    if (this.homepage_shortcuts_dir == '') {
      return;
    }
    // let result = this.bunch_of_bookmarks.get_folder(this.homepage_shortcuts_dir)?.get_only_bookmarks_content();
    let result = this.bunch_of_bookmarks.get_folder(this.homepage_shortcuts_dir)?.get_content();
    if (result) {
      console.log('[Meow][meowWebView] Directory selected / refreshed for shortcuts: [' + this.homepage_shortcuts_dir + ']');
      this.homepage_shortcuts = result;
      bunch_of_settings.set('homepage_shortcuts_bookmarks_dir', this.homepage_shortcuts_dir);
    } else {
      // directory doesn't exist
      console.log('[Meow][meowWebView] Directory selected for shortcuts doesn\'t exist! [' + this.homepage_shortcuts_dir + ']');
      this.homepage_shortcuts = [];
      // if (this.homepage_shortcuts_dir != '/') {
      //   this.homepage_shortcuts_dir = '';
      // }
    }
  }
}

// @Reusable // Lost of animation
@Component
struct shortcutButton {
  @Prop my_index: number;
  @Prop bookmark: unified_item;
  // Environment
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageProp('screen_height') screen_height: number = 100;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  // Gateways
  @LocalStorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // SHow
  @State vis_contents: Visibility = Visibility.None;
  @State render_contents: boolean = false;
  render_contents_timeout_id: number | undefined = undefined;
  @State show: Visibility = Visibility.None;
  @State offset_y: number = 50;

  build() {
    Column({ space: 10 }) {
      linysCapsuleButton({
        text: this.get_label_name(),
        color_button: this.color_current_secondary,
        color_text: this.color_current_font,
        opa: 1
      })
        .visibility(this.show)
        .animation(animation_default())
        .offset({ y: this.offset_y })
        .onAppear(() => {
          setTimeout(() => {
            this.show = Visibility.Visible;
            this.offset_y = 0;
            // Animation of floating up
          }, this.get_animation_timeout())
        })
        .onClick(() => {
          let item = this.bookmark.get_item();
          if (item.get_type() == 'bookmark') {
            // Is bookmark, access website
            setTimeout(() => {
              this.new_tab_gateway = (item as bookmark).get_link();
              this.current_url = (item as bookmark).get_link();
            }, 100)
          } else {
            // Is folder, expand contents
            clearTimeout(this.render_contents_timeout_id);
            if (this.vis_contents == Visibility.None) {
              this.vis_contents = Visibility.Visible;
              this.render_contents = true;
            } else {
              this.vis_contents = Visibility.None;
              this.render_contents_timeout_id = setTimeout(() => {
                this.render_contents = false;
              }, 300)
            }
          }
        })

      if (this.bookmark.get_item().get_type() == 'folder') {
        Column({ space: 10 }) {
          if (this.render_contents) {
            ForEach((this.bookmark.get_item() as folder).get_content(), (shortcut: unified_item, key: number) => {
              shortcutButton({
                bookmark: shortcut,
                my_index: key,
              })
            })
          }
        }
        .alignItems(this.get_alignItems())
        .visibility(this.vis_contents)
        .animation(animation_default())
      }
    }
    .alignItems(this.get_alignItems())
    .padding(this.vis_contents == Visibility.Visible ? (this.is_right_align() ? { right: 30 } : { left: 30 }) : {})
    .animation(animation_default())
  }

  get_label_name() {
    let name = '';
    if (this.bookmark.get_item().get_type() == 'folder') {
      name = (this.vis_contents == Visibility.Visible ? '󰃆  ' : '󰃅  ');
    }
    let label = this.bookmark.get_item().get_label();
    name += label;
    return name;
  }

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_homepage_shortcuts) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_homepage_shortcuts);
  }

  get_alignItems() {
    if (this.is_right_align()) {
      return HorizontalAlign.End;
    } else {
      return HorizontalAlign.Start
    }
  }

  get_animation_timeout() {
    let interval = 800 / (this.screen_height / (capsule_bar_height() + 10));
    return (this.my_index + 0) * interval;
  }
}

@Component
struct toast {
  info: ResourceStr = '';
  my_id: string = '';
  @Link @Watch('show_toast') show: boolean;
  // Timeout
  timeout_id: number | undefined = undefined;
  // Color
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Row() {
      linysText({
        text: this.info,
        color: this.color_current_primary,
        font_weight: FontWeight.Bold
      })
    }
    .backgroundColor(this.color_current_font)
    .height(this.show ? undefined : 0)
    .width(this.show ? undefined : 0)
    .padding(this.show ? 15 : 0)
    .animation(animation_default())
    .borderRadius(13.5)
    .onClick(() => {
      // Close toast
      this.show = false;
    })
    .clip(true)
  }

  show_toast() {
    if (this.show) {
      clearTimeout(this.timeout_id);
      this.timeout_id = setTimeout(() => {
        this.show = false;
      }, 2000)
    }
  }
}