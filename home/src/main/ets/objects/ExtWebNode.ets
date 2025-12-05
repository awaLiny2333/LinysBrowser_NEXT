import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { on_new_window } from '../processes/web_actions';
import lazy { hilog } from '@kit.PerformanceAnalysisKit';
import { extension } from '../hosts/bunch_of_extensions';
import { CatsBridgeMethods } from './CatstensionBridgeObj';
import { text_from_rawfile } from '../utils/storage_tools';

@Builder
function WebBuilder(ext: extension) {
  Web({ controller: ext.controller, src: $rawfile('home.html') })
    .mediaPlayGestureAccess(false)
    .databaseAccess(true)
    .fileAccess(true)
    .domStorageAccess(true)
    .multiWindowAccess(true)
    .mixedMode(MixedMode.All)
    .allowWindowOpenMethod(true)
    .mediaOptions({ audioExclusive: false })
    .darkMode(WebDarkMode.Auto) // Dark mode!
    .javaScriptAccess(true)
    .imageAccess(true)
    .onlineImageAccess(true)
    // .layoutMode(WebLayoutMode.FIT_CONTENT)
    .onWindowNew((event) => {
      if (ext.storage) {
        on_new_window(ext.storage, event);
      } else {
        event.handler.setWebController(null);
      }
    })
    .onPageEnd((e) => {
      console.log(`[Extension][${ext.name}][${ext.id}] Web Loaded! url=${e.url}`);
    })
    .javaScriptProxy({
      object: ext.bridge,
      name: 'CatsBridge',
      methodList: CatsBridgeMethods(),
      controller: ext.controller
    })
    .runJavaScriptOnDocumentStart([
      { script: text_from_rawfile('cathrome/eventListener.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/liny.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/alarms.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/action.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/bookmarks.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/browsingData.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/commands.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/contentSettings.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/contextMenus.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/declarativeNetRequest.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/i18n.js'), scriptRules: ["*"] },
      { script: text_from_rawfile('cathrome/cathrome.js'), scriptRules: ["*"] },
    ])
    .onConsole((e) => {
      let info = `[Extension][${ext.name}][${ext.id}]: ` + e.message.getMessage();
      if (e.message.getMessageLevel() == MessageLevel.Error) {
        console.error(info);
      } else if (e.message.getMessageLevel() == MessageLevel.Warn) {
        console.warn(info);
      } else {
        console.log(info);
      }
      return true;
    })
}

export class ExtNodeController extends NodeController {
  private builderNode: BuilderNode<[extension]> | null | undefined = null;
  private rootNode: FrameNode | null = null;

  constructor(builderNode: BuilderNode<[extension]> | undefined) {
    super();
    this.builderNode = builderNode;
  }

  makeNode(uiContext: UIContext): FrameNode | null {
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

  detachWeb(): void {
    this.rootNode = null;
  }

  // Update?
  update(ext: extension) {
    if (this.builderNode) {
      try {
        this.builderNode.update(ext);
        console.log(`[WebNode][update] ext.storage.get('my_window_id')=${ext.storage?.get('my_window_id') as string}`);
      } catch (e) {
        console.error(`[WebNode][update] Failed: ${e}!`);
      }
    }
  }

  dispose() {
    if (this.builderNode) {
      this.builderNode.dispose();
      console.log(`[WebNode][dispose] OK!`);
    } else {
      console.warn(`[WebNode][dispose] Failed!`);
    }
  }
}

export const createEWeb = (uiContext: UIContext, tab: extension) => {
  let builderNode: BuilderNode<[extension]> = new BuilderNode(uiContext);
  builderNode.build(wrapBuilder<[extension]>(WebBuilder), tab);
  return builderNode;
}