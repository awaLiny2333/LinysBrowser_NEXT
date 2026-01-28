import { animation_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { is_address_continuable, run_time, set_continuable, storage_of_id } from '../../utils/ui_tools';
import lazy { compress_image_arrayBuffer, sandbox_read_arrayBuffer_sync } from '../../utils/storage_tools';
import lazy { harmonyShare, systemShare } from '@kit.ShareKit';
import lazy { webview } from '@kit.ArkWeb';
import lazy { print } from '@kit.BasicServicesKit';
import lazy { common } from '@kit.AbilityKit';
import lazy { uniformTypeDescriptor } from '@kit.ArkData';
import lazy { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import lazy { init_web } from '../../processes/web_actions';
import lazy woofPrompt from '../../dialogs/web/woofPrompt';
import lazy woofConfirm from '../../dialogs/web/woofConfirm';
import lazy woofAlert from '../../dialogs/web/woofAlert';
import lazy woofHttpAuthPrompt from '../../dialogs/web/woofHttpAuthPrompt';
import lazy woofWantJump from '../../dialogs/prompts/woofWantJump';
import lazy woofWantResources from '../../dialogs/prompts/woofWantProtectedResources';
import lazy woofWantDownload from '../../dialogs/prompts/woofWantDownload';
import linysText from '../../components/texts/linysText';
import { copy } from '../../utils/clipboard_tools';
import linysSymbol from '../../components/texts/linysSymbol';
import { meowPx2vp } from '../../utils/environment_tools';
import { is_legal_ipv4, is_legal_url } from '../../utils/url_tools';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { share_link, share_text } from '../../utils/link_tools';
import linysPreviewWebView from '../../components/misc/linysPreviewWebView';

@Component
struct meowWebView {
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Hosts
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts();
  // Environments
  @StorageLink('currentColorMode') current_color_mode: number = 0;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('free_window_mode') free_window_mode: boolean = false;
  @LocalStorageLink('fullscreen_mode') @Watch('on_fullscreen_change') fullscreen_mode: boolean = false;
  @LocalStorageLink('fullscreen_handler') handler: FullScreenExitHandler | null = null;
  @LocalStorageLink('on_focus') @Watch('on_focus_change') on_focus: boolean = true;
  @LocalStorageLink('sharable_continuable') sharable_continuable: boolean = false;
  @LocalStorageLink('screen_width') screen_width: number = 0;
  @LocalStorageLink('screen_height') screen_height: number = 0;
  /**
   * Controls */
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";
  @LocalStorageLink('current_url') @Watch('on_current_url_change') current_url: string = "=￣ω￣=";
  @LocalStorageLink('current_is_loading') current_is_loading: boolean = true;
  @LocalStorageLink('search_extracted_field_available') search_extracted_field_available: boolean = false;
  // Settings
  @StorageLink('use_adblock') @Watch('on_use_adblock_state_change') use_adblock: boolean = true;
  @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = false;
  /**
   * Visual */
  @LocalStorageLink('potential_jump_link') @Watch('on_potential_jump_link_change') potential_jump_link: string = '';
  @LocalStorageLink('extra_background') extra_background: boolean = false;
  @State my_opacity: number = 0;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  // Download
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
  @LocalStorageLink('js_alert_event') @Watch('on_js_alert_event') js_alert_event: OnAlertEvent | undefined = undefined;
  woofAlert_control: CustomDialogController = new CustomDialogController({
    builder: woofAlert({
      event: this.js_alert_event
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  @LocalStorageLink('ssl_error_event') @Watch('on_ssl_error_event') ssl_error_event: SslErrorEvent | undefined = undefined;
  woof_SSL_error_control: CustomDialogController = new CustomDialogController({
    builder: woofConfirm(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  @LocalStorageLink('http_auth_event') @Watch('on_http_auth_event') http_auth_event: OnHttpAuthRequestEvent | undefined = undefined;
  woof_http_auth_control: CustomDialogController = new CustomDialogController({
    builder: woofHttpAuthPrompt({
      e: this.http_auth_event
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
  // Else
  @LocalStorageLink('meowWebView_init_OK') init_OK: boolean = false;
  // Context menu settings
  @StorageLink('web_context_menu_enabled') web_context_menu_enable: boolean = false;
  @StorageLink('web_context_menu_image_preview') web_context_menu_image_preview: boolean = false;
  @StorageLink('web_context_menu_web_preview') web_context_menu_web_preview: boolean = false;
  // Context menu contents
  @LocalStorageLink('web_context_menu_event') @Watch('on_web_context_menu_event') web_context_menu_event: OnContextMenuShowEvent | undefined = undefined;
  @State web_context_menu_show: boolean = false;
  @State web_context_menu_event_result: WebContextMenuResult | undefined = undefined;
  @State web_context_selected_text: string = 'text'
  @State web_context_selected_url: string = 'url'
  @State web_context_selected_url_unfiltered: string = 'url_unfiltered'
  @State web_context_source_url: string = 'url_unfiltered'
  @State web_context_is_editable: boolean = false;
  @State web_context_has_image: boolean = false;
  @State web_context_menu_x: number = 0;
  @State web_context_menu_y: number = 0;
  // Toasts
  @State show_toast_fullscreen: boolean = false;

  aboutToAppear(): void {
    console.log(' \n[meowWebView][aboutToAppear] this.bunch_of_tabs.my_id: ' + this.bunch_of_tabs.my_id + ' (' + run_time(this.storage) + 'ms)\n ');
    set_continuable(this.getUIContext().getHostContext() as common.UIAbilityContext, false);
  }

  @Builder
  contentCardBuilder(content: string) {
    Flex({
      direction: !(this.tablet_mode || this.free_window_mode) ? FlexDirection.Column : FlexDirection.Row
    }) {
      Column() {
        linysText({ text: content, max_lines: (this.tablet_mode || this.free_window_mode) ? 10 : 3 })
          .onClick(() => {
            if (is_legal_url(content)) {
              this.storage.set('universal_new_tab_gateway', [content, false]);
            }
            copy(content)
          })
          .padding(5)
          .hoverEffect(HoverEffect.Highlight)
          .borderRadius(5)
        Row() {
          linysSymbol({ symbol_glyph_target: 'sys.symbol.text_clipboard', can_hover: true }) // Copy
            .onClick(() => {
              copy(content)
            })
          linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_right', can_hover: true }) // Visit
            .onClick(() => {
              this.storage.set('universal_new_tab_gateway', [content, false]);
            })
            .opacity(is_legal_url(content) || is_legal_ipv4(content) ? 1 : 0.5)
            .enabled(is_legal_url(content) || is_legal_ipv4(content))
          linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass_house', can_hover: true }) // Search Here
            .onClick(() => {
              let se = this.storage.get('search_extracted_engine') as string;
              let target = se.replaceAll('%s', encodeURIComponent(content));
              this.storage.set('universal_new_tab_gateway', [target, false]);
            })
            .opacity(this.search_extracted_field_available ? 1 : 0.5)
            .enabled(this.search_extracted_field_available)
          linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass', can_hover: true }) // Search Default
            .onClick(() => {
              let se = AppStorage.get('search_engine') as string;
              let target = se.replaceAll('%s', encodeURIComponent(content));
              this.storage.set('universal_new_tab_gateway', [target, false]);
            })
          linysSymbol({ symbol_glyph_target: 'sys.symbol.share', can_hover: true }) // Share
            .onClick(() => {
              if (this.getUIContext().getHostContext()) {
                if (is_legal_url(content) || is_legal_ipv4(content)) {
                  share_link(content, content, this.getUIContext().getHostContext()!);
                } else {
                  share_text(content, this.getUIContext().getHostContext()!);
                }
              }
            })
        } // Buttons
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.tablet_mode || this.free_window_mode ? 1 : undefined)

      if ((is_legal_url(content) || is_legal_ipv4(content)) && this.web_context_menu_web_preview) {
        linysPreviewWebView({ storage: this.storage, url: content })
          .hoverEffect(HoverEffect.Highlight)
          .height(this.tablet_mode || this.free_window_mode ? 400 : 0.4 * this.screen_height)
          .padding(5)
          .borderRadius(10)
          .layoutWeight(this.tablet_mode || this.free_window_mode ? 3 : undefined)
      }
    }
  }

  @Builder
  imageCardBuilder(url: string) {
    Column() {
      Row() {
        if (this.web_context_menu_image_preview) {
          Image(url)
            .width(Math.min(200, this.screen_width - 100))
            .borderRadius(6)
        } else {
          linysTextTitle({ text: $r('app.string.Menu_image_preview_placeholder') })
            .opacity(0.6)
        }
      }
      .padding(5)
      .borderRadius(10)
      .hoverEffect(this.web_context_menu_image_preview ? HoverEffect.Highlight : HoverEffect.None)
      .onClick(() => {
        this.storage.set('universal_new_tab_gateway', [url, false]);
      })

      Row() {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.text_clipboard', can_hover: true }) // Copy
          .onClick(() => {
            this.web_context_menu_event_result?.copyImage();
          })
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_right', can_hover: true }) // Visit
          .onClick(() => {
            this.storage.set('universal_new_tab_gateway', [url, false]);
          })
        linysSymbol({ symbol_glyph_target: 'sys.symbol.download', can_hover: true }) // Download
          .onClick(() => {
            try {
              this.bunch_of_tabs.workingMainTab().controller?.startDownload(url);
            } catch (error) {
              this.storage.setOrCreate('universal_fail_prompt_desc_gateway', error.toString());
              console.error(`[ContextMenu] Download image failed: ${error}`);
            }
          })
        // TODO: SHow image size
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  contextMenuBuilder() {
    Column() {
      Row() {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_left', can_hover: true, })// Backward
          .enabled(this.bunch_of_tabs.current_accessBackward)
          .opacity(this.bunch_of_tabs.current_accessBackward ? 1 : 0.5)
          .onClick(() => {
            this.bunch_of_tabs.goBackward_onWorkingTab();
          })
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_right', can_hover: true, })// Forward
          .enabled(this.bunch_of_tabs.current_accessForward)
          .opacity(this.bunch_of_tabs.current_accessForward ? 1 : 0.5)
          .onClick(() => {
            this.bunch_of_tabs.goForward_onWorkingTab();
          })
        linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_clockwise', can_hover: true }) // Refresh
          .onClick(() => {
            if (!this.current_is_loading) {
              this.refresh_page();
            }
          })
          .opacity(!this.current_is_loading ? 1 : 0.5)
          .enabled(!this.current_is_loading)

        // Row().width(10) // Divide?

        Row() {
          linysSymbol({ symbol_glyph_target: 'sys.symbol.selector', can_hover: true }) // Select all
            .onClick(() => {
              this.web_context_menu_event_result?.selectAll();
            })
          linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square_dashed_on_square', can_hover: true }) // Paste
            .onClick(() => {
              this.web_context_menu_event_result?.paste();
            })
          linysSymbol({ symbol_glyph_target: 'sys.symbol.cut', can_hover: true }) // Cut
            .onClick(() => {
              this.web_context_menu_event_result?.cut();
            })
          linysSymbol({ symbol_glyph_target: 'sys.symbol.undo', can_hover: true }) // Undo
            .onClick(() => {
              this.web_context_menu_event_result?.undo();
            })
          linysSymbol({ symbol_glyph_target: 'sys.symbol.redo', can_hover: true }) // Redo
            .onClick(() => {
              this.web_context_menu_event_result?.redo();
            })
        }
        .enabled(this.web_context_is_editable)
        .opacity(this.web_context_is_editable ? 1 : 0.5)
      } // Buttons
      if (this.web_context_selected_text) {
        this.contentCardBuilder(this.web_context_selected_text);
      }
      if (this.web_context_selected_url) {
        this.contentCardBuilder(this.web_context_selected_url);
      }
      if (this.web_context_source_url) {
        this.contentCardBuilder(this.web_context_source_url);
      }
      if (this.web_context_selected_url_unfiltered && this.web_context_selected_url != this.web_context_selected_url_unfiltered) {
        this.contentCardBuilder(this.web_context_selected_url_unfiltered);
      }
      if (this.web_context_has_image) {
        this.imageCardBuilder(this.web_context_source_url);
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(1)

    // .constraintSize(this.free_window_mode ? { maxWidth: this.screen_width * 0.75 } : {})
  }

  build() {
    RelativeContainer() {
      Row() // Background color
        .backgroundColor(this.current_color_mode == 0 ? (this.web_force_dark_mode ? 'black' : 'white') : 'white')
        .height('100%')
        .width('100%')
        .visibility(this.extra_background ? Visibility.Visible : Visibility.Hidden)

      ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
        if (this.bunch_of_tabs.NodeControllers[Label.index_key]) {
          NodeContainer(this.bunch_of_tabs.NodeControllers[Label.index_key])
            .onAppear(() => {
              try {
                this.bunch_of_tabs.NodeControllers[Label.index_key]?.attachWeb();
                this.bunch_of_tabs.NodeControllers[Label.index_key]?.rebuild();
              } catch (e) {
                console.error('[Tab] onAppear Failed: ' + e);
              }
            })
            .width(this.bunch_of_tabs.sub_tab_idx < 0 ? "100%" : this.width_tab())
            .height(this.bunch_of_tabs.sub_tab_idx < 0 ? "100%" : this.height_tab())
            .alignRules(this.bunch_of_tabs.main_tab_idx == Label.index_key ? this.align_rules_main_tab() : this.align_rules_sub_tab())
            .visibility(this.my_visibility(Label.index_key))
        } else {
          Column()
            .onAppear(() => {
              console.log(`[meowWebView] An unloaded tab! #${Label.index_key};`);
            })
        } // Webs
      }, (Label: tab_label, index: number) => {
        let k = Label.timestamp.toString() + (this.bunch_of_tabs.NodeControllers[index] ? 't' : 'f');
        return k;
      })

      // Notices
      Column({ space: (this.show_toast_fullscreen) ? 10 : 0 }) {
        toast({
          show: this.show_toast_fullscreen,
          extra: this.bunch_of_key_shortcuts.get_shortcut_string('fullscreen')
            .reverse()
            .join(' + ')
            .toUpperCase(),
          info: $r('app.string.fullscreen_notice')
        })
      }
      .translate({ y: -20 })
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
      })
      .onAppear(() => {
        this.on_current_url_change();
        // init OK
        this.init_OK = true;
      })
    }
    .opacity(this.my_opacity)
    .animation({ duration: 200 })
    .width("100%")
    .height("100%")
    .onAppear(() => {
      // console.log("[Meow][meowWebView] WebViews READY")
      init_web(this.storage);
      this.my_opacity = 1;
      console.log(`[Meow][meowWebView] onAppear! (${run_time(this.storage)} ms)`);
    })
    .bindContextMenu(this.web_context_menu_show, this.contextMenuBuilder, {
      enableArrow: false,
      placement: Placement.LeftTop,
      anchorPosition: {
        x: this.web_context_menu_x,
        y: this.web_context_menu_y
      },
      onWillDisappear: () => {
        this.web_context_menu_show = false;
      },
      backgroundColor: this.color_current_primary,
      hapticFeedbackMode: HapticFeedbackMode.AUTO,
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
    let e = this.ssl_error_event;
    this.woof_SSL_error_control = new CustomDialogController({
      builder: woofConfirm({
        title: $r('app.string.SSL_error_title'),
        desc: this.human_desc_of_ssl_error(e),
        onConfirm: () => {
          e?.handler.handleConfirm();
        },
        onDeny: () => {
          e?.handler.handleCancel(true);
        }
      }),
      alignment: DialogAlignment.Center,
      cornerRadius: 26
    });
    this.woof_SSL_error_control.open();
  }

  on_http_auth_event() {
    if (this.http_auth_event) {
      if (this.http_auth_event.handler.isHttpAuthInfoSaved()) {
        // Use auto cache
      } else {
        this.woof_http_auth_control.open();
      }
    }
  }

  on_permission_request_event() {
    if (this.permission_request_event) {
      this.request_permission(this.permission_request_event);
    }
  }

  on_potential_jump_link_change() {
    this.woofLinkJumper_control.open();
  }

  /**
   * Enable ads block for all tabs.
   * */
  on_use_adblock_state_change() {
    console.log('[meowWebView] enableAdsBlock: ' + (this.use_adblock ? 'true' : 'false'))
    try {
      for (let index = 0; index < this.bunch_of_tabs.Tabs.length; index++) {
        this.bunch_of_tabs.Tabs[index].controller!.enableAdsBlock(this.use_adblock);
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
    console.log('[Meow][meowWebView] on_download_request!');
  }

  on_web_context_menu_event() {
    if (!this.web_context_menu_event) {
      console.error(`[on_web_context_menu_event] is undefined?`);
      return;
    }
    if (!this.web_context_menu_enable) {
      return;
    }

    // Data extraction
    this.web_context_menu_x = meowPx2vp(this.web_context_menu_event.param.x());
    this.web_context_menu_y = meowPx2vp(this.web_context_menu_event.param.y());
    this.web_context_menu_event_result = this.web_context_menu_event.result;
    this.web_context_selected_text = this.web_context_menu_event.param.getSelectionText();
    this.web_context_selected_url = this.web_context_menu_event.param.getLinkUrl();
    this.web_context_source_url = this.web_context_menu_event.param.getSourceUrl();
    this.web_context_selected_url_unfiltered = this.web_context_menu_event.param.getUnfilteredLinkUrl();
    this.web_context_is_editable = this.web_context_menu_event.param.isEditable();
    this.web_context_has_image = this.web_context_menu_event.param.existsImageContents();

    // Show
    this.web_context_menu_show = true;
    console.log(`[on_web_context_menu_event] text = ${this.web_context_menu_event.param.getSelectionText()}, type = ${this.web_context_menu_event.param.getMediaType()}, `
      + `x = ${this.web_context_menu_x}, y = ${this.web_context_menu_y}`);
  }

  // Operations

  request_permission(event: OnPermissionRequestEvent) {
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

  refresh_page() {
    this.bunch_of_tabs.refresh_onWorkingTab();
    this.bunch_of_tabs.workingMainTab().update_is_loading(true);
    (this.storage.get('tab_is_loading') as boolean[])[this.bunch_of_tabs.main_tab_idx] = true;
  }

  // Sharing

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
struct toast {
  info: ResourceStr = '';
  @Link @Watch('show_toast') show: boolean;
  @Prop extra: ResourceStr = '';
  // Timeout
  timeout_id: number | undefined = undefined;
  // Color
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('effects') effects: boolean = false;

  build() {
    Row() {
      if (this.extra) {
        linysText({
          text: this.extra + ' / ',
          color: this.effects ? this.color_current_font : this.color_current_primary,
          font_weight: FontWeight.Bold
        })
      }
      linysText({
        text: this.info,
        color: this.effects ? this.color_current_font : this.color_current_primary,
        font_weight: FontWeight.Bold
      })
    }
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
    .backgroundColor(this.effects ? undefined : this.color_current_font)
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