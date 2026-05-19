import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { meow } from '../../../../catstypicalframework/utils/catsLogger';
import { meowTabInfo } from './meowTabInfo';

@Builder
function WebBuilder(pk: meowTabInfo) {
  // Column() {
  //   Text(pk.tab_force_dark ? 'tab_force_dark!' : 'tab_force_dark NO')
  //   Text(pk.tab_disable_js ? 'tab_disable_js!' : 'tab_disable_js NO')
  //   Text(pk.tab_disable_image ? 'tab_disable_image!' : 'tab_disable_image NO')

  Web({
    src: pk.url || '',
    controller: pk.controller
  })
    .mediaPlayGestureAccess(false)
    .layoutWeight(1)
    // .backgroundColor('transparent') // Or the web would flash on load
    .databaseAccess(true)
    .fileAccess(true)
    .domStorageAccess(true)
    .multiWindowAccess(true)
    .mixedMode(MixedMode.All)
    .allowWindowOpenMethod(true)
    .mediaOptions({ audioExclusive: false })
    .darkMode(WebDarkMode.Auto) // Dark mode!
    .forceDarkAccess(pk.forceDark) // Force dark mode
    .javaScriptAccess(!pk.xJS)
    .imageAccess(!pk.xImage)
    .onlineImageAccess(!pk.xImage)
    .onActivateContent(() => {
      meow(`Activate! ${pk.url}`, 'WebNode][onActivateContent');
    })
    .onWindowNew((event) => {
      if (!event) {
        return;
      }
      const result = pk.requestNewTab(event.targetUrl);
      setTimeout(() => {
        event.handler.setWebController(result);
      }, 0); // No idea why we need a timeout... :O
    })
    .onTitleReceive(() => {
      pk.updateTitle();
      pk.updateUrl();
    })
    .onPageBegin(() => {
      pk.progress = 0;
      pk.updateUrl();
    })
    .onPageEnd(() => {
      pk.progress = -1;
      pk.updateUrl();
    })
    .onProgressChange((event) => {
      pk.progress = event.newProgress;
      pk.updateUrl();
    })
    .onSearchResultReceive((result) => {
      meow(`onSearchResultReceive: ${result.activeMatchOrdinal}/${result.numberOfMatches}`, 'WebNode][onSearchResultReceive');
    })
    .onErrorReceive((e) => {
      console.error(`[ArkWeb][onErrorReceive] [${e.request.getRequestUrl()}], isMainFrame=${e.request.isMainFrame()}, ${e.error.getErrorInfo()}, ${JSON.stringify(e.request.getRequestHeader())}`);
    })
    .onFullScreenEnter((event) => {
      pk.requestFullScreen(event);
    })
    .onFullScreenExit(() => {
      pk.requestFullScreenExit();
    })
    .onPrompt((e) => {
      pk.requestPrompt(e);
      return true;
    })
    .onConfirm((e) => {
      pk.requestConfirm(e);
      return true;
    })
    .onAlert((e) => {
      pk.requestAlert(e);
      return true;
    })
    .onLoadIntercept((event) => {
      return pk.requestload(event);
    })
    .onPermissionRequest((event) => {

    })
    .onSslErrorEvent((e) => {

    })
    .onHttpAuthRequest((e) => {

      return true;
    })
    .onContextMenuShow((event) => {

      return true;
    });
  // .onAdsBlocked((e) => {
  //   console.log(`[onAdsBlocked] ${e.url}: ${e.adsBlocked}`);
  // })
  // .onControllerAttached(() => {
  // if (useAdBlock()) {
  //   try {
  //     pk.controller!.enableAdsBlock(true);
  //   } catch (e) {
  //     meow(`newTab.controller?.enableAdsBlock(true); failed: ${e}`, 'meowTabsBunch][newTab', meowLevel.ERROR);
  //   }
  // }
  // });
}

export class TabNodeController extends NodeController {
  private builderNode: BuilderNode<[meowTabInfo]> | null | undefined = null;
  private rootNode: FrameNode | null = null;

  constructor(uiContext: UIContext, tab: meowTabInfo) {
    super();
    let builderNode: BuilderNode<[meowTabInfo]> = new BuilderNode(uiContext); // 创建BuilderNode
    builderNode.build(wrapBuilder<[meowTabInfo]>(WebBuilder), tab); // 创建动态Web组件
    this.builderNode = builderNode;
  }

  // 必须要重写的方法，用于构建节点数、返回节点挂载在对应NodeContainer中
  // 在对应NodeContainer创建的时候调用或者通过rebuild方法调用刷新
  makeNode(uiContext: UIContext): FrameNode | null {
    // 该节点会被挂载在NodeContainer的父节点下
    console.log(`[WebNode][makeNode] OK! uiContext: ${uiContext}`);
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
  update(pk: meowTabInfo) {
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
      console.log(`[WebNode][dispose] OK!`);
    } else {
      console.warn(`[WebNode][dispose] Failed!`);
    }
  }
}
