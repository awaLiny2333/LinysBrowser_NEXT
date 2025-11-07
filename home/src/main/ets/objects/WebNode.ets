import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { bunch_of_tabs, tab_info_packed } from '../hosts/bunch_of_tabs';
import { url_meow_to_resource } from '../utils/url_tools';
import { on_controller_attached, on_load_intercept, on_new_window, on_page_begin, on_page_end, on_progress_change, on_title_receive } from '../processes/web_actions';
import lazy { hilog } from '@kit.PerformanceAnalysisKit';

export const defaultUrl: string = 'https://www.example.com';

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
    .backgroundColor('transparent') // Or the web would flash on load
    .databaseAccess(true)
    .fileAccess(true)
    .domStorageAccess(true)
    .multiWindowAccess(true)
    .mixedMode(MixedMode.All)
    .allowWindowOpenMethod(true)
    .mediaOptions({ audioExclusive: false })
    .darkMode(WebDarkMode.Auto) // Dark mode!
    .forceDarkAccess(pk.tab_force_dark) // Force dark mode
    .javaScriptAccess(!pk.tab_disable_js)
    .imageAccess(!pk.tab_disable_image)
    .onlineImageAccess(!pk.tab_disable_image)
    .onActivateContent(() => {
      pk.storage.set('universal_tab_button_click_gateway', pk.index);
      console.log(`[Meow][onActivateContent] Switched to Tab No.${pk.index}!`)
    })
    .onSearchResultReceive((result) => {
      console.log('[Meow][onSearchResultReceive]! ' + Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1));
      console.log('[Meow][onSearchResultReceive]! ' + result.numberOfMatches);
      pk.storage.set('current_in_page_searching_stats_current', Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1));
      pk.storage.set('current_in_page_searching_stats_total', result.numberOfMatches);
      let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;
      tabs.workingMainTab().searching_keyword_stats_current = Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1);
      tabs.workingMainTab().searching_keyword_stats_total = result.numberOfMatches;
    })
    .onWindowNew((event) => {
      on_new_window(pk, event);
    })
    .onTitleReceive(() => {
      on_title_receive(pk);
    })
    .onPageBegin(() => {
      on_page_begin(pk);
    })
    .onPageEnd(() => {
      on_page_end(pk);
    })
    .onProgressChange((event) => {
      on_progress_change(pk, event);
    })
    .onErrorReceive((e) => {
      console.error(`[ArkWeb][onErrorReceive] [${e.request.getRequestUrl()}], isMainFrame=${e.request.isMainFrame()}, ${e.error.getErrorInfo()}, ${JSON.stringify(e.request.getRequestHeader())}`)
    })
    .onFullScreenEnter((event) => {
      pk.storage.set('fullscreen_mode', true);
      pk.storage.set('fullscreen_handler', event.handler);
    })
    .onFullScreenExit(() => {
      pk.storage.set('fullscreen_mode', false);
    })
    .onControllerAttached(() => {
      on_controller_attached(pk);
    })
    .onAdsBlocked((e) => {
      console.log(`[onAdsBlocked] ${e.url}: ${e.adsBlocked}`);
    })
    .onLoadIntercept((event) => {
      return on_load_intercept(pk, pk.storage, event);
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
    .onSslErrorEvent((e) => {
      if (e) {
        pk.storage.set('ssl_error_event', e);
      }
    })
    .onHttpAuthRequest((e) => {
      console.log(`[onHttpAuthRequest] Host: [${e.host}], Realm: [${e.realm}]!`);
      pk.storage.set('http_auth_event', e);
      return true;
    })
}

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

  attachWeb(): void {
    if (this.builderNode) {
      let frameNode: FrameNode | null = this.builderNode.getFrameNode();
      if (frameNode?.getParent() != null) {
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
      try {
        this.builderNode.update(pk);
      } catch (e) {
        console.error(`[WebNode][update] Failed: ${e}!`);
      }
    }
  }

  // 解除当前builderNode与后端实体的引用关系
  dispose() {
    if (this.builderNode) {
      this.builderNode.dispose();
    }
  }
}

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
    if (target_packed_tab_info.pre_restoration_stage) {
      return "";
    } else {
      return url_meow_to_resource(target_packed_tab_info.url);
    }
  }
}