import { animation_default, capsule_bar_height, click_effect_default, fontSize_Large } from '../../hosts/bunch_of_defaults';
import { bunch_of_history } from '../../hosts/bunch_of_history';
import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { arrayBuffer_2_pixelMap, compress_image_arrayBuffer, sandbox_read_arrayBuffer, sandbox_read_arrayBuffer_sync } from '../../utils/storage_tools';
import { match_domain, url_meow_to_resource, url_resource_to_meow, viewable_domains } from '../../utils/url_tools';
import { webview } from '@kit.ArkWeb';
import { print } from '@kit.BasicServicesKit';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { bookmark, bunch_of_bookmarks, folder, unified_item } from '../../hosts/bunch_of_bookmarks';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import lazy woofWantJump from '../../dialogs/prompts/woofWantJump';
import lazy woofWantResources from '../../dialogs/prompts/woofWantProtectedResources';
import lazy woofHomepageManager from '../../dialogs/managers/woofHomepageManager';
import lazy woofWantDownload from '../../dialogs/prompts/woofWantDownload';
import { determine_extra_background, sync_tabs_list_info } from '../../processes/tabs_actions';
import woofPrompt from '../../dialogs/web/woofPrompt';
import woofConfirm from '../../dialogs/web/woofConfirm';
import woofAlert from '../../dialogs/web/woofAlert';
import { storage_of_id, window_index_of_id } from '../../utils/ui_tools';
import linysText from '../../components/texts/linysText';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

@Component
struct meowWebView {
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('my_windowClass') my_windowClass: window.Window | undefined = undefined;
  // Hosts
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('bunch_of_bookmarks') @Watch('refresh_homepage_shortcuts') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks('Bookmarks~Meow');
  @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads(true);
  // Environments
  @StorageLink('currentColorMode') current_color_mode: number = 0;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('fullscreen_mode') fullscreen_mode: boolean = false;
  @LocalStorageLink('fullscreen_handler') handler: FullScreenExitHandler | null = null;
  @LocalStorageLink('restore_web_state_arrays') restore_web_state_arrays: Uint8Array[] = [];
  @LocalStorageProp('screen_height') screen_height: number = 100;
  // In-Page Searching
  @LocalStorageLink('current_in_page_searching_stats_current') current_in_page_searching_stats_current: number = 0;
  @LocalStorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  /**
   * Controls */
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";
  @LocalStorageLink('tab_urls') tab_urls: string[] = []
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageLink('tab_match_domains') tab_match_domains: string[][] = [];
  @LocalStorageLink('tab_disable_js') tab_disable_js: boolean[] = [false];
  @LocalStorageLink('tab_disable_image') tab_disable_image: boolean[] = [false];
  @LocalStorageLink('tab_force_dark') tab_force_dark: boolean[] = [false];
  @LocalStorageLink('tab_restore_on_creations') tab_restore_on_creations: boolean[] = [false];
  /**
   * Web control statuses */
  @LocalStorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  // Settings
  @StorageLink('collect_new_history') collect_new_history: boolean = true;
  @StorageLink('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
  @StorageLink('use_adblock') @Watch('on_use_adblock_state_change') use_adblock: boolean = true;
  @StorageLink('adblock_exceptions') adblock_exceptions: string[] = [];
  @StorageLink('homepage_shortcuts_bookmarks_dir') @Watch('refresh_homepage_shortcuts') homepage_shortcuts_dir: string = '/';
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = false;
  @StorageLink('web_force_dark_mode_exemptions') web_force_dark_mode_exemptions: string[] = [];
  @StorageLink('disable_js') disable_js: boolean = false;
  @StorageLink('disable_js_these_sites') disable_js_these_sites: string[] = [];
  @StorageLink('disable_js_all_sites') disable_js_all_sites: boolean = true;
  @StorageLink('disable_image') disable_image: boolean = false;
  @StorageLink('disable_image_these_sites') disable_image_these_sites: string[] = [];
  @StorageLink('disable_image_all_sites') disable_image_all_sites: boolean = true;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  /**
   * Stuffs */
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  /**
   * Visual */
  @StorageLink('homepage_background') homepage_background: PixelMap | undefined = undefined;
  @State last_timeout_id: number | undefined = undefined;
  @State shortcut_scroll_offset: number = 0;
  @State homepage_shortcuts: unified_item[] = [];
  @State potential_jump_link: string = '';
  @LocalStorageLink('extra_background') extra_background: boolean = false;
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
  @State js_prompt_event: OnPromptEvent | undefined = undefined;
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
  @State js_confirm_event: OnConfirmEvent | undefined = undefined;
  woofConfirm_control: CustomDialogController = new CustomDialogController({
    builder: woofConfirm({
      event: this.js_confirm_event
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  @State js_alert_event: OnAlertEvent | undefined = undefined;
  woofAlert_control: CustomDialogController = new CustomDialogController({
    builder: woofAlert({
      event: this.js_alert_event
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
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
  woofHomepageManager_control: CustomDialogController = new CustomDialogController({
    builder: woofHomepageManager(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
  });
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Else
  @LocalStorageLink('meowWebView_init_OK') init_OK: boolean = false;
  shortcut_scroller: Scroller = new Scroller();
  httpAuth: boolean = false;

  // // Menu contents
  // @State menu_linkUrl: string = '';
  // @State menu_offsetX: number = 0;
  // @State menu_offsetY: number = 0;
  // @State menu_has_link: boolean = false;
  // @State menu_editable: boolean = false;
  // @State menu_has_image: boolean = false;
  // @State menu_imageLink: string = '';
  // @State menu_mediaType: ContextMenuMediaType | undefined = undefined;
  // // Menu
  // private menu_result: WebContextMenuResult | undefined = undefined;
  // @State menu_showMenu: boolean = false;
  //
  // /**
  //  * Adapted from Huawei HarmonyOS Dev website example code
  //  * https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-web#oncontextmenushow9
  //  * */
  // @Builder
  // // 构建自定义菜单及触发功能接口
  // MenuBuilder() {
  //   // 以垂直列表形式显示的菜单。
  //   Menu() {
  //     // 展示菜单Menu中具体的item菜单项。
  //     MenuItem({
  //       content: $r('app.string.Menu_copy'),
  //     })
  //       .width(100)
  //       .height(50)
  //       .onClick(() => {
  //         this.menu_result?.copy();
  //         this.menu_showMenu = false;
  //       })
  //     MenuItem({
  //       content: $r('app.string.Menu_select_all'),
  //     })
  //       .width(100)
  //       .height(50)
  //       .onClick(() => {
  //         this.menu_result?.selectAll();
  //         this.menu_showMenu = false;
  //       })
  //     MenuItem({
  //       content: $r('app.string.Menu_cut'),
  //     })
  //       .width(100)
  //       .height(50)
  //       .onClick(() => {
  //         this.menu_result?.cut();
  //         this.menu_showMenu = false;
  //       })
  //       .enabled(this.menu_editable)
  //     MenuItem({
  //       content: $r('app.string.Menu_paste'),
  //     })
  //       .width(100)
  //       .height(50)
  //       .onClick(() => {
  //         this.menu_result?.paste();
  //         this.menu_showMenu = false;
  //       })
  //       .enabled(this.menu_editable)
  //     MenuItem({
  //       content: $r('app.string.Menu_copy_link'),
  //     })
  //       .width(100)
  //       .height(50)
  //       .onClick(() => {
  //         copy(this.menu_linkUrl);
  //         this.menu_showMenu = false;
  //       })
  //       .enabled(this.menu_has_link)
  //     MenuItem({
  //       content: $r('app.string.Menu_copy_image'),
  //     })
  //       .width(100)
  //       .height(50)
  //       .onClick(() => {
  //         this.menu_result?.copyImage();
  //         this.menu_showMenu = false;
  //       })
  //       .enabled(this.menu_has_image)
  //     MenuItem({
  //       content: $r('app.string.Menu_download_image'),
  //     })
  //       .width(100)
  //       .height(50)
  //       .onClick(() => {
  //         // Download menu
  //         this.download(this.menu_imageLink, this.now_global_custom_UA, '', -1, 'image');
  //         this.menu_showMenu = false;
  //       })
  //       .enabled(this.menu_has_image)
  //   }
  //
  //   // .width(150)
  //   // .height(350)
  // }

  aboutToAppear(): void {
    console.log(' \n[meowWebView][aboutToAppear] this.bunch_of_tabs.my_id: ' + this.bunch_of_tabs.my_id + '\n ');

    // Init download delegate
    this.bunch_of_downloads.init_delegate(this.storage);

    // Set image for homepage
    sandbox_read_arrayBuffer('homepage_background_arrayBuffer')?.then((homepage_background_array_buffer) => {
      if (homepage_background_array_buffer) {
        this.homepage_background = arrayBuffer_2_pixelMap(homepage_background_array_buffer);
        console.log("[Meow][meowAppSettings] Finished loading homepage background!");
      }
    });

    // init OK
    setTimeout(() => {
      this.init_OK = true;
    }, 10);

    // Refresh shortcuts
    setTimeout(() => {
      this.refresh_homepage_shortcuts();
    }, 10);

    this.register_harmonyShare_gesture_sender();

    this.register_harmonyShare_knock_sender();

    this.register_harmonyShare_receiver();
  }

  build() {
    RelativeContainer() {
      if (this.homepage_background) {
        Image(this.homepage_background)
          .visibility(this.current_url == 'meow://home' && this.bunch_of_tabs.sub_tab_idx == -1 ? Visibility.Visible : Visibility.Hidden)
          .transition(TransitionEffect.OPACITY.animation({ duration: 400 }))
          .opacity(Math.max(1 - this.shortcut_scroll_offset / this.screen_height, 0.5))
      } // Background

      Row() // Background color
        .backgroundColor(this.current_color_mode == 0 ? (this.web_force_dark_mode ? 'black' : 'white') : 'white')
        .height('100%')
        .width('100%')
        .visibility(this.extra_background ? Visibility.Visible : Visibility.Hidden)
      // .animation(animation_default())

      ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
        Column() {
          Web({
            src: this.src_of_tab_index(Label.index_key),
            controller: this.bunch_of_tabs.Tabs[Label.index_key] !== undefined
              ? this.bunch_of_tabs.Tabs[Label.index_key].controller
              : undefined,
            // renderMode: RenderMode.SYNC_RENDER
          })// Main WEB
            .width("100%")
            .layoutWeight(1)
            .backgroundColor('transparent')
            .databaseAccess(true)
            .javaScriptAccess(!this.tab_disable_js[Label.index_key])
            .imageAccess(!this.tab_disable_image[Label.index_key])
            .onlineImageAccess(!this.tab_disable_image[Label.index_key])
            .fileAccess(true)
            .domStorageAccess(true)
            .multiWindowAccess(true)
            .mixedMode(MixedMode.All)
            .allowWindowOpenMethod(true)
            .onSearchResultReceive((result) => {
              this.current_in_page_searching_stats_current =
                Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1);
              this.current_in_page_searching_stats_total = result.numberOfMatches;
              this.bunch_of_tabs.workingMainTab().searching_keyword_stats_current =
                Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1);
              this.bunch_of_tabs.workingMainTab().searching_keyword_stats_total = result.numberOfMatches;
            })
            .onWindowNew((event) => {
              // TODO: Find out why this triggers twice when click once
              let new_target_url = event.targetUrl;
              console.log('[meowWebView] New tab in new window!');
              this.storage.set('universal_new_tab_gateway', new_target_url);
              event.handler.setWebController(null);
            })
            .onTitleReceive(() => {
              try {
                // Ask tab to update its info
                this.bunch_of_tabs.Tabs[Label.index_key].update_title();
                this.bunch_of_tabs.Tabs[Label.index_key].update_url();
                this.bunch_of_tabs.update_backward_forward_access();
                // Get synced lists
                sync_tabs_list_info(this.storage);
              } catch (e) {
                console.error('[meowWebView][onProgressChange] Update bunch_of_tabs error: ' + e);
              }

              // Save history if title is really updated
              if (this.bunch_of_tabs.Tabs[Label.index_key].last_saved_title != this.tab_titles[Label.index_key]) {
                console.log('[Tabs][onTitleReceive] New title: ' + this.tab_titles[Label.index_key]);
                if (!this.bunch_of_tabs.Tabs[Label.index_key].is_loading) {
                  this.bunch_of_tabs.Tabs[Label.index_key].check_save_history('[onTitleReceive]');
                }
              }

            })
            .onPageBegin(() => {
              console.log("[ArkWeb] on page begin!");

              if (Label.index_key >= this.bunch_of_tabs.get_tabs_count()) {
                // If not synced, idk why but o(=•ェ•=)m
                return;
              }

              try {
                // Ask tab to update its info (Reset)
                // this.bunch_of_tabs.Tabs[Label.index_key].update_title();
                this.bunch_of_tabs.Tabs[Label.index_key].update_url();
                this.bunch_of_tabs.Tabs[Label.index_key].update_is_loading(true)
                this.bunch_of_tabs.Tabs[Label.index_key].update_loading_progress(0)
              } catch (e) {
                console.error('[meowWebView][onPageBegin] Update bunch_of_tabs error: ' + e);
              }

              // Get synced lists
              sync_tabs_list_info(this.storage)
              // Update Input Search Box
              this.update_search_box_text(this.current_url)
            })
            .onPageEnd(() => {
              console.log("[Meow][ArkWeb] on page end!");

              try {
                this.bunch_of_tabs.Tabs[Label.index_key].update_title();
                this.bunch_of_tabs.Tabs[Label.index_key].update_url();
                this.bunch_of_tabs.update_backward_forward_access();
                this.bunch_of_tabs.Tabs[Label.index_key].update_is_loading(false);
              } catch (e) {
                console.error('[meowWebView][onPageEnd] Update bunch_of_tabs error: ' + e);
              }

              sync_tabs_list_info(this.storage);

              this.bunch_of_tabs.update_web_state(Label.index_key);
              // Get and save web_state
              if (window_index_of_id(this.my_window_id) == 0) {
                this.bunch_of_tabs.save_web_state_to_sandbox(Label.index_key);
              }

              if (this.bunch_of_tabs.Tabs[Label.index_key].title != '') {
                this.bunch_of_tabs.Tabs[Label.index_key].check_save_history('[onPageEnd]');
              }

              // Mark End Recovery
              if (this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation) {
                setTimeout(() => {
                  console.log('[Tabs] Restore OK for #' + Label.index_key + ' !');
                  this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation = false;
                  this.tab_restore_on_creations = this.bunch_of_tabs.get_all_restore_on_creations();
                }, 500)
              }

              determine_extra_background(this.storage);
            })
            .onProgressChange((event) => {
              if (!event) {
                return;
              }

              let progress: number = event.newProgress;
              // console.log("[Meow][ArkWeb] on progress change: " + progress.toString())
              // Update current loading progress
              if (progress == 0) {
                return;
              }

              if (Label.index_key >= this.bunch_of_tabs.get_tabs_count()) {
                // If not synced, idk why but o(=•ェ•=)m
                return;
              }

              try {
                // Ask tab to update its info
                this.bunch_of_tabs.Tabs[Label.index_key].update_title();
                this.bunch_of_tabs.Tabs[Label.index_key].update_url();
                this.bunch_of_tabs.Tabs[Label.index_key].update_loading_progress(progress);
                this.bunch_of_tabs.update_backward_forward_access();
              } catch (e) {
                console.error('[meowWebView][onProgressChange] Update bunch_of_tabs error: ' + e);
              }

              sync_tabs_list_info(this.storage); // Get synced lists

              // this.bunch_of_tabs.Tabs[Label.index_key].check_save_history();

              // Update Input Search Box
              this.update_search_box_text(this.current_url);

              if (this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation) {
                return;
              }

              this.bunch_of_tabs.update_web_state(Label.index_key);
              // Get and save web_state
              if (window_index_of_id(this.my_window_id) == 0) {
                this.bunch_of_tabs.save_web_state_to_sandbox(Label.index_key);
              }

              determine_extra_background(this.storage);
            })
            .onFullScreenEnter((event) => {
              this.fullscreen_mode = true;
              this.handler = event.handler;
            })
            .onFullScreenExit(() => {
              this.fullscreen_mode = false;
            })
            .onControllerAttached(async () => {
              // bind download delegate
              try {
                this.bunch_of_tabs.Tabs[Label.index_key].controller.setDownloadDelegate(this.dl_delegate);
              } catch (e) {
                console.error('[meowWebView] onControllerAttached setDownloadDelegate error: ' + e);
              }

              // Set UA
              if (this.now_global_custom_UA != "") {
                try {
                  this.bunch_of_tabs.Tabs[Label.index_key].controller.setCustomUserAgent(this.now_global_custom_UA);
                } catch (e) {
                  console.error('[meowWebView] onControllerAttached setCustomUserAgent error: ' + e);
                }
              }

              // Set Ads Blocker
              console.log('[meowWebView] enableAdsBlock: ' + (this.use_adblock ? 'true' : 'false'));
              try {
                this.bunch_of_tabs.Tabs[Label.index_key].controller.enableAdsBlock(this.use_adblock);
              } catch (e) {
                console.error('[meowWebView] onControllerAttached enableAdsBlock error: ' + e);
              }

              // TODO: Find out why this doesn't work sometimes for a recovered webpage :O getting crazy
              // Set Ads Blocker exception list
              try {
                console.log('[init][meowWebView] Trying to add ads blocker exceptions: [' + this.adblock_exceptions + '] Operated by meowWebView ~');
                webview.AdsBlockManager.addAdsBlockDisallowedList(this.adblock_exceptions);
              } catch (e) {
                console.error('[ERROR][Meow][meowWebView] add Ads Blocker Exceptions error: ' + e);
              }

              // Set intelligent tracking prevention
              try {
                this.bunch_of_tabs.Tabs[Label.index_key].controller.enableIntelligentTrackingPrevention(this.intelligent_tracking_prevention);
                console.log('[meowWebView] ArkWeb Intelligent Tracking Prevention ' + this.intelligent_tracking_prevention.toString() + '!');
              } catch (e) {
                console.error('[meowWebView] onControllerAttached enableIntelligentTrackingPrevention error: ' + e);
              }
              // Restore Web State
              setTimeout(() => {
                if (this.bunch_of_tabs.Tabs[Label.index_key]?.restore_on_creation) {
                  if (Label.index_key < this.restore_web_state_arrays.length) {
                    this.bunch_of_tabs.restore_web_state(this.restore_web_state_arrays[Label.index_key],
                      Label.index_key);
                  } else {
                    console.error('[ERROR][Meow][meowWebView] Restore web state failed ' +
                      'for an out-of-bound index in restore_web_state_arrays.')
                  }
                }
              }, 0);

              // Set allowed resources
              try {
                let allowed = [
                  this.getUIContext().getHostContext()!.resourceDir,
                  // this.getUIContext().getHostContext()!.filesDir,
                  // '/data/storage/el2/base/haps/cache'
                ]
                this.bunch_of_tabs.Tabs[Label.index_key].controller.setPathAllowingUniversalAccess(allowed);
                console.log('[meowWebView] Init set allowed resources: [' + allowed.join(", ") + ']');
              } catch (e) {
                console.error('[meowWebView] Init set allowed resources error: ' + e);
              }
            })
            .darkMode(WebDarkMode.Auto)// Dark mode!
            .forceDarkAccess(this.tab_force_dark[Label.index_key])// Force dark mode
            .onLoadIntercept((event) => {
              if (event) {
                let url: string = event.data.getRequestUrl();
                // Do not intercept data:
                if (url.substring(0, 5) == 'data:') {
                  return false;
                }
                // Do not intercept blob:
                if (url.substring(0, 5) == 'blob:') {
                  return false;
                }
                // Links or urls
                let match_domain_result = match_domain(url);
                if (viewable_domains().includes(match_domain_result[0])) {
                  // Viewable
                  return false;
                } else {
                  // Not viewable, perhaps is a link that can jump?
                  this.potential_jump_link = url;
                  this.woofLinkJumper_control.open();
                  return true;
                }
              }
              return false;
            })
            .onPermissionRequest((event) => {
              if (!event) {
                return;
              }
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
            })
            .onClientAuthenticationRequest((event) => {
              console.log('[meowWebView] onClientAuthenticationRequest event.host: ' + event.host);
              console.log('[meowWebView] onClientAuthenticationRequest event.port ' + event.port);
              console.log('[meowWebView] onClientAuthenticationRequest event.keyTypes: ' + event.keyTypes.join('\n'));
              console.log('[meowWebView] onClientAuthenticationRequest event.issuers: ' + event.issuers.join('\n'));
            })
            .onOverScroll(() => {
              // console.log('[meowWebView] Over scrolled!')
            })
            .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
            .onPrompt((e) => {
              if (e) {
                this.js_prompt_event = e;
                this.woofPrompt_control.open();
              }
              return true;
            })
            .onConfirm((e) => {
              if (e) {
                this.js_confirm_event = e;
                this.woofConfirm_control.open();
              }
              return true;
            })
            .onAlert((e) => {
              if (e) {
                this.js_alert_event = e;
                this.woofAlert_control.open();
              }
              return true;
            })

          Column() {
            linysText({
              text: $r('app.string.Tabs_recovering'),
              color: this.color_current_secondary,
              font_weight: FontWeight.Medium
            })
              .padding(6)
          } // Restore tag notice
          .height(this.tab_restore_on_creations[Label.index_key] ? undefined : 0)
          .animation(animation_default())
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .backgroundColor(this.color_current_font)
          .opacity(0.9)
          .clip(true)

        } // Webs
        .clip(true)
        .borderColor(this.color_current_secondary)
        .width(this.bunch_of_tabs.sub_tab_idx < 0 ? "100%" : this.width_tab())
        .height(this.bunch_of_tabs.sub_tab_idx < 0 ? "100%" : this.height_tab())
        .alignRules(this.bunch_of_tabs.main_tab_idx == Label.index_key ? this.align_rules_main_tab() : this.align_rules_sub_tab())
        .visibility(this.my_visibility(Label.index_key))
      }, (Label: tab_label) => Label.timestamp.toString())

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
    .width("100%")
    .height("100%")
    .onAppear(() => {
      // console.log("[Meow][meowWebView] WebViews READY")
    })
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
      if (this.homepage_shortcuts_dir != '/') {
        this.homepage_shortcuts_dir = '';
      }
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
      console.log('[meowWebView] harmonyShare: URL: ' + this.current_url);
    } else {
      console.error('[meowWebView] harmonyShare FAILED: URL: ' + this.current_url);
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

  register_harmonyShare_receiver() {
    try {
      let capabilityRegistry: harmonyShare.RecvCapabilityRegistry = {
        windowId: this.my_windowClass!.getWindowProperties().id,
        capabilities: [{
          utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
          maxSupportedCount: 1
        }]
      }

      harmonyShare.on('dataReceive', capabilityRegistry, (receivableTarget: harmonyShare.ReceivableTarget) => {
        let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        receivableTarget.receive(context.filesDir + '/harmonyShare_temp', {
          onDataReceived: (sharedData: systemShare.SharedData) => {
            let sharedRecords = sharedData.getRecords();
            sharedRecords.forEach((record: systemShare.SharedRecord) => {
              let url = record.content as string;
              console.log('[meowWebView] harmonyShare received content: ' + url);
            });
          },
          // onResult(resultCode: harmonyShare.ShareResultCode) {
          //   if (resultCode === harmonyShare.ShareResultCode.SHARE_SUCCESS) {
          //     // To do things.
          //   }
          // }
        });
      });
      console.log('[meowWebView] Register harmonyShare receive OK!');
    } catch (e) {
      console.error('[meowWebView] Register harmonyShare receive failed: ' + e);
    }
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

  shortcut_alignItems() {
    let status = this.preferred_hand_left_or_right == 'right';
    if (this.preferred_hand_reverse_homepage_shortcuts) {
      status = !status;
    }
    return status ? HorizontalAlign.End : HorizontalAlign.Start;
  }

  // Ladders

  private src_of_tab_index(index: number): string {
    let target_packed_tab_info = this.bunch_of_tabs.Tabs[index];
    if (target_packed_tab_info == undefined) {
      return "";
    } else {
      if (target_packed_tab_info.restore_on_creation) {
        return "";
      } else {
        return url_meow_to_resource(target_packed_tab_info.url);
      }
    }
  }
}

export default meowWebView;

@Reusable
@Component
struct shortcutButton {
  @Prop my_index: number;
  @Prop bookmark: unified_item;
  // Environment
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks('Bookmarks~Meow');
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_homepage_shortcuts') preferred_hand_reverse_homepage_shortcuts: boolean = false;
  // Gateways
  @LocalStorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // SHow
  @State show_contents: Visibility = Visibility.None;
  @State show: Visibility = Visibility.Hidden;
  @State offset_y: number = 50;

  build() {
    Column({ space: 10 }) {
      Button((this.bookmark.get_item().get_type() == 'folder' ? (this.show_contents == Visibility.Visible ? '󰃆  ' : '󰃅  ') : '')
        + this.bookmark.get_item().get_label())// Shortcut "󰄏"
        .type(ButtonType.Capsule)
        .backgroundColor(this.color_current_secondary)
        .fontColor(this.color_current_font)
        .border({
          width: 2,
          color: "transparent"
        })
        .fontSize(fontSize_Large())
        .fontWeight(FontWeight.Regular)
        .height(capsule_bar_height())
        .visibility(this.show)
        .offset({ y: this.offset_y })
        .clickEffect(click_effect_default())
        .animation(animation_default())
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
            if (this.show_contents == Visibility.None) {
              this.show_contents = Visibility.Visible;
            } else {
              this.show_contents = Visibility.None;
            }
          }
        })

      if (this.bookmark.get_item().get_type() == 'folder') {
        Column({ space: 10 }) {
          ForEach((this.bookmark.get_item() as folder).get_content(), (shortcut: unified_item, key: number) => {
            shortcutButton({
              bookmark: shortcut,
              my_index: key,
            })
          })
        }
        .alignItems(this.get_alignItems())
        .visibility(this.show_contents)
        .animation(animation_default())
      }
    }
    .alignItems(this.get_alignItems())
    .padding(this.show_contents == Visibility.Visible ? (this.is_right_align() ? { right: 30 } : { left: 30 }) : {})
    .animation(animation_default())
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
    let unit_interval = 40;
    if (this.my_index < 5) {
      unit_interval = 80;
    } else if (this.my_index < 10) {
      unit_interval = 70;
    } else {
      unit_interval = 60;
    }
    return this.my_index * unit_interval + 0;
  }
}