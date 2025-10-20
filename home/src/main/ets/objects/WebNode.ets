// 提供动态挂载Web组件能力
// utils/web_tools.ets
import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { bunch_of_tabs, tab_info_packed } from '../hosts/bunch_of_tabs';
import { determine_extra_background, sync_current_tabs_list_info } from '../processes/tabs_actions';
import { window_index_of_id } from '../utils/ui_tools';
import { match_domain, url_meow_to_resource, url_resource_to_meow, viewable_domains } from '../utils/url_tools';

export const defaultUrl: string = 'https://www.example.com';

// @Builder中为动态组件的具体组件内容
@Builder
function WebBuilder(pk: tab_info_packed) {
  // Column() {
  //   Text(pk.tab_force_dark ? 'tab_force_dark!' : 'tab_force_dark NO')
  //   Text(pk.tab_disable_js ? 'tab_disable_js!' : 'tab_disable_js NO')
  //   Text(pk.tab_disable_image ? 'tab_disable_image!' : 'tab_disable_image NO')
  Web({
    src: src_of_tab_index(pk),
    controller: pk?.controller
  })
    .layoutWeight(1)
    .backgroundColor('transparent') // TODO: Why??
    .databaseAccess(true)
    .fileAccess(true)
    .domStorageAccess(true)
    .multiWindowAccess(true)
    .mixedMode(MixedMode.All)
    .allowWindowOpenMethod(true)
    .darkMode(WebDarkMode.Auto)// Dark mode!
    .forceDarkAccess(pk.tab_force_dark)// Force dark mode
    .javaScriptAccess(!pk.tab_disable_js)
    .imageAccess(!pk.tab_disable_image)
    .onlineImageAccess(!pk.tab_disable_image) // TODO: Do these update with change?
    .onSearchResultReceive((result) => {
      pk.storage.set('current_in_page_searching_stats_current', Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1));
      pk.storage.set('current_in_page_searching_stats_total', result.numberOfMatches);
      let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;
      tabs.workingMainTab().searching_keyword_stats_current = Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1);
      tabs.workingMainTab().searching_keyword_stats_total = result.numberOfMatches;
    })
    .onWindowNew((event) => {
      // TODO: Find out why this triggers twice when click once
      let new_target_url = event.targetUrl;
      console.log('[meowWebView] New tab in new window!');
      pk.storage.set('universal_new_tab_gateway', new_target_url);
      event.handler.setWebController(null);
    })
    .onTitleReceive(() => {
      // Ask tab to update its info
      let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

      try {
        let title = pk.update_title();
        let url = pk.update_url();
        tabs.update_backward_forward_access();
        // sync lists
        // sync_tabs_list_info(tab.storage);
        (pk.storage.get('tab_titles') as string[])[pk.index] = title;
        (pk.storage.get('tab_urls') as string[])[pk.index] = url;

        // tabs.sync_web_settings(tab.index);

        if (pk.index == tabs.main_tab_idx) {
          sync_current_tabs_list_info(pk.storage);
        }
      } catch (e) {
        console.error('[meowWebView][onProgressChange] Update bunch_of_tabs error: ' + e);
      }

      // Save history if title is really updated
      let tab_titles = (pk.storage.get('tab_titles') as string[]);
      if (pk.last_saved_title != tab_titles[pk.index]) {
        console.log('[Tabs][onTitleReceive] New title: ' + tab_titles[pk.index]);
        if (!pk.is_loading) {
          pk.check_save_history('[onTitleReceive]');
        }
      }

    })
    .onPageBegin(() => {
      console.log("[ArkWeb] on page begin!");
      let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

      if (pk.index >= tabs.get_tabs_count()) {
        // If not synced, idk why but o(=•ェ•=)m
        return;
      }

      // Ask tab to update its info
      try {
        let url = pk.update_url();
        let is_loading = pk.update_is_loading(true);
        let progress = pk.update_loading_progress(0);

        (pk.storage.get('tab_urls') as string[])[pk.index] = url;
        (pk.storage.get('tab_is_loading') as boolean[])[pk.index] = is_loading;
        (pk.storage.get('tab_loading_progresses') as number[])[pk.index] = progress;

        pk.update_web_settings();
        tabs.NodeControllers[pk.index].update(tabs.Tabs[pk.index]);

        // Get synced lists
        if (pk.index == tabs.main_tab_idx) {
          sync_current_tabs_list_info(pk.storage);
        }

      } catch (e) {
        console.error('[meowWebView][onPageBegin] Update bunch_of_tabs error: ' + e);
      }

      // Update Input Search Box
      // this.update_search_box_text(tab.url);
      if (!(pk.storage.get('is_search_input_typing') as boolean) && pk.index == tabs.main_tab_idx) {
        pk.storage.set('search_input', url_resource_to_meow(pk.url));
        // Update Input Search Box
      }
    })
    .onPageEnd(() => {
      console.log(`[Meow][ArkWeb][${pk.index}] tab on page end! `);
      let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

      // Ask tab to update its info
      try {
        let title = pk.update_title();
        let url = pk.update_url();
        let is_loading = pk.update_is_loading(false);
        tabs.update_backward_forward_access();

        (pk.storage.get('tab_titles') as string[])[pk.index] = title;
        (pk.storage.get('tab_urls') as string[])[pk.index] = url;
        (pk.storage.get('tab_is_loading') as boolean[])[pk.index] = is_loading;

        pk.update_web_settings();
        tabs.NodeControllers[pk.index].update(tabs.Tabs[pk.index]);

        // Get synced lists
        if (pk.index == tabs.main_tab_idx) {
          sync_current_tabs_list_info(pk.storage);
        }
      } catch (e) {
        console.error('[meowWebView][onPageEnd] Update bunch_of_tabs error: ' + e);
      }

      // Get and save web_state
      tabs.update_web_state(pk.index);
      if (window_index_of_id(tabs.my_id) == 0) {
        tabs.save_web_state_to_sandbox(pk.index);
      }

      // Save history
      if (pk.title != '') {
        pk.check_save_history('[onPageEnd]');
      }

      // Mark End Recovery
      if (pk.restore_on_creation) {
        pk.delayed_set_restore_ok(() => {
          console.log('[Tabs] Restore OK for #' + pk.index + ' !');
          (pk.storage.get('tab_restore_on_creations') as boolean[])[pk.index] = false;
        });
      }

      determine_extra_background(pk.storage);
    })
    .onProgressChange((event) => {
      if (!event) {
        return;
      }
      let progress: number = event.newProgress;
      if (progress == 0) {
        return;
      }

      let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

      if (pk.index >= tabs.get_tabs_count()) {
        // If not synced, idk why but o(=•ェ•=)m
        return;
      }

      // Ask tab to update its info
      try {
        let title = pk.update_title();
        let url = pk.update_url();
        pk.update_loading_progress(progress);
        tabs.update_backward_forward_access();


        (pk.storage.get('tab_titles') as string[])[pk.index] = title;
        (pk.storage.get('tab_urls') as string[])[pk.index] = url;
        (pk.storage.get('tab_loading_progresses') as number[])[pk.index] = progress;

        // Get synced lists
        if (pk.index == tabs.main_tab_idx) {
          sync_current_tabs_list_info(pk.storage);
        }
      } catch (e) {
        console.error('[meowWebView][onProgressChange] Update bunch_of_tabs error: ' + e);
      }

      // Update Input Search Box
      // this.update_search_box_text(tab.url);
      if (!(pk.storage.get('is_search_input_typing') as boolean) && pk.index == tabs.main_tab_idx) {
        pk.storage.set('search_input', url_resource_to_meow(pk.url));
        // Update Input Search Box
      }

      // Get and save web_state
      if (!pk.restore_on_creation) {
        tabs.update_web_state(pk.index);
        if (window_index_of_id(tabs.my_id) == 0) {
          tabs.save_web_state_to_sandbox(pk.index);
        }
      }

      determine_extra_background(pk.storage);
    })
    .onFullScreenEnter((event) => {
      pk.storage.set('fullscreen_mode', true);
      pk.storage.set('fullscreen_handler', event.handler);
    })
    .onFullScreenExit(() => {
      pk.storage.set('fullscreen_mode', false);
    })
    .onControllerAttached(async () => {
      // bind download delegate
      try {
        pk.controller.setDownloadDelegate(AppStorage.get('dl_delegate') as webview.WebDownloadDelegate);
      } catch (e) {
        console.error('[meowWebView] onControllerAttached setDownloadDelegate error: ' + e);
      }

      // Set UA
      let now_global_custom_UA = AppStorage.get('universal_global_custom_ua_gateway') as string;
      if (now_global_custom_UA != "") {
        try {
          pk.controller.setCustomUserAgent(now_global_custom_UA);
        } catch (e) {
          console.error('[meowWebView] onControllerAttached setCustomUserAgent error: ' + e);
        }
      }

      // Set Ads Blocker
      let use_adblock = AppStorage.get('use_adblock') as boolean;
      console.log('[meowWebView] enableAdsBlock: ' + (use_adblock ? 'true' : 'false'));
      try {
        pk.controller.enableAdsBlock(use_adblock);
      } catch (e) {
        console.error('[meowWebView] onControllerAttached enableAdsBlock error: ' + e);
      }

      // Set Ads Blocker exception list
      try {
        let adblock_exceptions = AppStorage.get('adblock_exceptions') as string[];
        console.log('[init][meowWebView] Trying to add ads blocker exceptions: [' + adblock_exceptions + '] Operated by meowWebView ~');
        // webview.AdsBlockManager.addAdsBlockDisallowedList(adblock_exceptions);
        webview.AdsBlockManager.addAdsBlockDisallowedList(Array.from(adblock_exceptions)); // wtf??? 做这个接口的人脑子简直有病，直接拿的数组用了报错，还得从头创建 O.o
      } catch (e) {
        console.error('[ERROR][Meow][meowWebView] add Ads Blocker Exceptions error: ' + e);
      }
      // TODO: Find out why this doesn't work sometimes for a recovered webpage :O getting crazy

      // Set intelligent tracking prevention
      try {
        let intelligent_tracking_prevention = AppStorage.get('intelligent_tracking_prevention') as boolean;
        pk.controller.enableIntelligentTrackingPrevention(intelligent_tracking_prevention);
        console.log('[meowWebView] ArkWeb Intelligent Tracking Prevention ' + intelligent_tracking_prevention.toString() + '!');
      } catch (e) {
        console.error('[meowWebView] onControllerAttached enableIntelligentTrackingPrevention error: ' + e);
      }

      // Restore Web State
      setTimeout(() => {
        if (pk?.restore_on_creation) {
          try {
            let web_states = pk.storage.get('restore_web_state_arrays') as Uint8Array[];
            let web_state = web_states[pk.index];
            if (web_state) {
              pk.url = 'uwu';
              pk.title = 'uwu';
              pk.controller.clearHistory();
              pk.controller.restoreWebState(web_state);
              console.log("[Meow][meowWebView] Restore web " + pk.index.toString() + ", state Length: " + web_state.length.toString());
            } else {
              console.error("[Meow][meowWebView] Restore web state failed for an undefined web_state!")
            }
          } catch (e) {
            console.error("[Meow][meowWebView] Restore web state failed! " + e);
          }
        }
      }, 0);
    })
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
          pk.storage.set('potential_jump_link', url);
          return true;
        }
      }
      return false;
    })
    .onPermissionRequest((event) => {
      if (!event) {
        return;
      }
      pk.storage.set('permission_request_event', event);
    })
    .onPrompt((e) => {
      if (e) {
        pk.storage.set('js_prompt_event', e);
      }
      return true;
    })
    .onConfirm((e) => {
      if (e) {
        pk.storage.set('js_confirm_event', e);
      }
      return true;
    })
    .onAlert((e) => {
      if (e) {
        pk.storage.set('js_alert_event', e);
      }
      return true;
    })
  // }
}

// 用于控制和反馈对应的NodeContainer上的节点的行为，需要与NodeContainer一起使用
export class TabNodeController extends NodeController {
  private builderNode: BuilderNode<[tab_info_packed]> | null | undefined = null;
  private rootNode: FrameNode | null = null;

  constructor(builderNode: BuilderNode<[tab_info_packed]> | undefined) {
    super();
    this.builderNode = builderNode;
  }

  // 必须要重写的方法，用于构建节点数、返回节点挂载在对应NodeContainer中
  // 在对应NodeContainer创建的时候调用或者通过rebuild方法调用刷新
  makeNode(uiContext: UIContext): FrameNode | null {
    // 该节点会被挂载在NodeContainer的父节点下
    return this.rootNode;
  }

  // 挂载Webview
  attachWeb(): void {
    if (this.builderNode) {
      let frameNode: FrameNode | null = this.builderNode.getFrameNode();
      if (frameNode?.getParent() != null) {
        // 挂载自定义节点前判断该节点是否已经被挂载
        hilog.error(0x0000, 'testTag', '%{public}s', 'The frameNode is already attached');
        return;
      }
      this.rootNode = this.builderNode.getFrameNode();
    }
  }

  // 卸载Webview
  detachWeb(): void {
    this.rootNode = null;
  }

  // Update?
  update(pk: tab_info_packed) {
    if (this.builderNode) {
      this.builderNode.update(pk);
    }
  }

  // 解除当前builderNode与后端实体的引用关系
  dispose() {
    if (this.builderNode) {
      this.builderNode.dispose();
    }
  }
}

// 初始化需要UIContext对象，UIContext对象可通过窗口或自定义组件的getUIContext方法获取
export const createNWeb = (uiContext: UIContext, tab: tab_info_packed) => {
  // 创建BuilderNode
  let builderNode: BuilderNode<[tab_info_packed]> = new BuilderNode(uiContext);
  // 创建动态Web组件
  builderNode.build(wrapBuilder<[tab_info_packed]>(WebBuilder), tab);
  return builderNode;
}

function src_of_tab_index(target_packed_tab_info: tab_info_packed): string {
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