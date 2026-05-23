import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { meow } from '../../../../catstypicalframework/utils/catsLogger';
import { copyText } from '../../../../catstypicalframework/utils/clipboard';
import { defaultInnerRadius, measureTextWidth, meowPx2vp } from '../../../../catstypicalframework/utils/ui';
import { isLegalUrl } from '../../../../catstypicalframework/utils/url';
import { MooSymbolButton } from '../../../../components/common/MooSymbolButton';
import { MooTextButton } from '../../../../components/common/MooTextButton';
import { fontSizeSmall, meowThemeColorType, standardSpacing } from '../../../../components/constants';
import { oopsPreviewActionsImage } from '../../../../components/parts/WebContextMenu/oopsPreviewActionsImage';
import { oopsPreviewActionsText } from '../../../../components/parts/WebContextMenu/oopsPreviewActionsText';
import { oopsPreviewImage } from '../../../../components/parts/WebContextMenu/oopsPreviewImage';
import { MooSoloWeb } from '../../../../components/common/MooSoloWeb';
import { defaultAnimation, getColor, useEffects } from '../../../../components/settings';
import { getMyApp } from '../../../system/windows/scripts/helpers';
import { contextMenuImagePreview, contextMenuStripText, contextMenuWebHeight, contextMenuWebPreview } from '../settings';
import { meowTabInfo } from './meowTabInfo';

@ComponentV2
struct MeowWeb {
  @Param @Require pk: meowTabInfo;
  // Context menu UI
  @Local offsetX: number = 0;
  @Local offsetY: number = 0;
  @Local showMenu: boolean = false;
  // Context menu data
  private contextMenuResult: WebContextMenuResult | undefined = undefined;
  @Local linkUrl: string = '';
  @Local sourceUrl: string = '';
  @Local unfilteredUrl: string = '';
  @Local selectedText: string = '';
  @Local editable: boolean = false;
  @Local hasImage: boolean = false;

  build() {
    Web({
      src: this.pk.url || '',
      controller: this.pk.controller
    })
      .mediaPlayGestureAccess(false)
      .layoutWeight(1)
      .geolocationAccess(true)
      .databaseAccess(true)
      .fileAccess(true)
      .domStorageAccess(true)
      .multiWindowAccess(true)
      .mixedMode(MixedMode.All)
      .allowWindowOpenMethod(true)
      .mediaOptions({ audioExclusive: false })
      .darkMode(WebDarkMode.Auto) // Dark mode!
      .forceDarkAccess(this.pk.forceDark) // Force dark mode
      .javaScriptAccess(!this.pk.xJS)
      .imageAccess(!this.pk.xImage)
      .onlineImageAccess(!this.pk.xImage)
      .onDrop(() => {
        clearTimeout(this.pk.myUi.dropHoverFlipTimeoutId);
        animateToImmediately(defaultAnimation(), () => {
          this.pk.myUi.dropHover = false;
        });
      })
      .onControllerAttached(() => {
        this.pk.onControllerAttached();
      })
      .onTitleReceive(() => {
        this.pk.updateTitle();
        this.pk.updateUrl();
      })
      .onPageBegin(() => {
        this.pk.progress = 0;
        this.pk.updateUrl();
        this.pk.onPageBegin();
      })
      .onPageEnd(() => {
        this.pk.progress = -1;
        this.pk.updateUrl();
        this.pk.onPageEnd();
      })
      .onProgressChange((event) => {
        this.pk.progress = event.newProgress;
        if (this.pk.progress == 100) {
          this.pk.progress = -1;
        }
        this.pk.updateUrl();
      })
      .onFullScreenEnter((event) => {
        this.pk.requestFullScreen(event);
      })
      .onFullScreenExit(() => {
        this.pk.requestFullScreenExit();
      })
      .onPrompt((e) => {
        return this.pk.requestPrompt(e);
      })
      .onConfirm((e) => {
        return this.pk.requestConfirm(e);
      })
      .onAlert((e) => {
        return this.pk.requestAlert(e);
      })
      .onSslErrorEvent((e) => {
        this.pk.requestSslError(e);
      })
      .onClientAuthenticationRequest((event) => {
        this.pk.requestClientAuthentication(event);
      })
      .onVerifyPin((event) => {
        this.pk.requestVerifyPin(event);
      })
      .onLoadIntercept((event) => {
        return this.pk.requestload(event);
      })
      .onPermissionRequest((event) => {
        this.pk.requestWebPermissions(event);
      })
      .onScreenCaptureRequest((event) => {
        this.pk.requestScreenCapture(event);
      })
      .onGeolocationShow((event) => {
        this.pk.requestGeolocation(event);
      })
      .onHttpAuthRequest((event) => {
        this.pk.requestHttpAuth(event);
        return true;
      })
      .onSearchResultReceive((result) => {
        this.pk.receiveSearchResult(result);
      })
      .onActivateContent(() => {
        meow(`Activate! ${this.pk.url}`, 'WebNode][onActivateContent');
      })
      .onWindowExit(() => {
        meow(`Exit! ${this.pk.url}`, 'WebNode][onWindowExit');
      })
      .onWindowNew((event) => {
        const result = this.pk.requestNewTab(event.targetUrl);
        setTimeout(() => {
          meow(`onWindowNew: ${event.targetUrl} -> ${result}`, 'WebNode][onWindowNew');
          event.handler.setWebController(this.pk.controller);
        });
        // TODO: This timeout is essential to not block the original web.
        // But this would lead to the original web's misunderstanding that
        // the new popup request failed and no controller was returned.
        // So some sites may think that this browser has no popup permission.
      })
      .onContextMenuShow((event) => {
        if (!event) {
          return false;
        }
        // Data
        this.contextMenuResult = event.result;
        this.linkUrl = event.param.getLinkUrl();
        this.sourceUrl = event.param.getSourceUrl();
        this.unfilteredUrl = event.param.getUnfilteredLinkUrl();
        this.editable = event.param.isEditable();
        this.hasImage = event.param.existsImageContents();
        let t = event.param.getSelectionText();
        this.selectedText = contextMenuStripText() ? t.trim() : t;
        // Ui
        this.offsetX = meowPx2vp(event?.param.x() ?? 0);
        this.offsetY = meowPx2vp(event?.param.y() ?? 0);
        this.showMenu = true;
        return true;
      })
      .bindContextMenu(this.showMenu, this.MenuBuilder, {
        enableArrow: false,
        placement: Placement.BottomRight,
        anchorPosition: { x: this.offsetX, y: this.offsetY },
        onDidDisappear: () => {
          this.showMenu = false;
          this.contextMenuResult!.closeContextMenu();
        },
        backgroundColor: useEffects() ? Color.Transparent : getColor(meowThemeColorType.PRIMARY),
        backgroundBlurStyle: useEffects() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
        hapticFeedbackMode: HapticFeedbackMode.AUTO,
      });
  }

  @Builder
  MenuBuilder() {
    Column() {
      Row() {
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_left'), isEnabled: this.pk.myUi.myTabs.currentTabCanBack, clickAction: () => {
            this.pk.myUi.myTabs.goBackCurrent();
            this.showMenu = false;
          }
        }); // Backward
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_right'), isEnabled: this.pk.myUi.myTabs.currentTabCanForw, clickAction: () => {
            this.pk.myUi.myTabs.goForwardCurrent();
            this.showMenu = false;
          }
        }); // Forward
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_clockwise'), clickAction: () => {
            this.pk.myUi.myTabs.refreshCurrent();
            this.showMenu = false;
          }
        }); // Refresh
        MooSymbolButton({
          icon: $r('sys.symbol.selector'), isEnabled: this.editable, clickAction: () => {
            this.contextMenuResult?.selectAll();
            this.showMenu = false;
          }
        }); // Select all
        MooSymbolButton({
          icon: $r('sys.symbol.plus_square_dashed_on_square'), isEnabled: this.editable, clickAction: () => {
            this.contextMenuResult?.paste();
            this.showMenu = false;
          }
        }); // Paste
        MooSymbolButton({
          icon: $r('sys.symbol.cut'), isEnabled: this.editable, clickAction: () => {
            this.contextMenuResult?.cut();
            this.showMenu = false;
          }
        }); // Cut
        MooSymbolButton({
          icon: $r('sys.symbol.undo'), isEnabled: this.editable, clickAction: () => {
            this.contextMenuResult?.undo();
            this.showMenu = false;
          }
        }); // Undo
        MooSymbolButton({
          icon: $r('sys.symbol.redo'), isEnabled: this.editable, clickAction: () => {
            this.contextMenuResult?.redo();
            this.showMenu = false;
          }
        }); // Redo
      }; // Always-on buttons of web control and edit.
      // Specific panels
      if (this.selectedText) {
        this.contentCardBuilder(this.selectedText);
      }
      if (this.linkUrl) {
        this.contentCardBuilder(this.linkUrl);
      }
      if (this.sourceUrl && !this.hasImage) {
        this.contentCardBuilder(this.sourceUrl); // If has image, then don't show this duplicated url address.
      }
      if (this.unfilteredUrl && this.linkUrl != this.unfilteredUrl) {
        this.contentCardBuilder(this.unfilteredUrl);
      }
      if (this.hasImage) {
        this.imageCardBuilder(this.sourceUrl);
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(1)
    .onTouch((event) => {
      // Stop the menu from being closed.
      event.stopPropagation();
    });
  }

  /**
   * If the window is in free window or wide mode. We would have many space to put more things!
   */
  get largeSpace() {
    return this.pk.myUi.myLayout.wideMode || getMyApp().freeWindow;
  }

  @Builder
  contentCardBuilder(content: string) {
    Flex({ direction: !this.largeSpace ? FlexDirection.Column : FlexDirection.Row }) {
      Column() {
        MooTextButton({
          text: content, maxLines: this.largeSpace ? 5 : 3,
          clickAction: () => {
            if (isLegalUrl(content)[0]) {
              this.pk.myUi.openNewTab(content);
            } else {
              copyText(content);
            }
            this.showMenu = false;
          }
        });

        oopsPreviewActionsText({
          content: content, requestCloseMenu: () => {
            this.showMenu = false;
          }, requestVisit: (u) => {
            this.pk.myUi.openNewTab(u);
          }
        });
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.largeSpace && isLegalUrl(content)[0] && contextMenuWebPreview() ? 1 : undefined);

      if (isLegalUrl(content)[0] && contextMenuWebPreview()) {
        MooSoloWeb({ url: content, radius: defaultInnerRadius - standardSpacing * 0.25 })
          .hoverEffect(HoverEffect.Highlight)
          .height(contextMenuWebHeight())
          .padding(standardSpacing * 0.5)
          .borderRadius(defaultInnerRadius)
          .layoutWeight(getMyApp().freeWindow ? 3 : this.pk.myUi.myLayout.wideMode ? 2 : undefined);
      }
    }.width('auto');
  }

  @Builder
  imageCardBuilder(url: string) {
    Flex({
      direction: !this.largeSpace ? FlexDirection.Column : FlexDirection.Row
    }) {
      Column() {
        MooTextButton({
          text: url, maxLines: this.largeSpace ? 5 : 3,
          clickAction: () => {
            this.pk.myUi.openNewTab(url);
            this.showMenu = false;
          }
        });
        oopsPreviewActionsImage({
          content: url,
          requestVisit: (url) => {
            this.pk.myUi.openNewTab(url);
          },
          requestCloseMenu: () => {
            this.showMenu = false;
          },
          requestCopyImage: () => {
            this.contextMenuResult?.copyImage();
          }
        });

        // linysPreviewQrResults();
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.largeSpace ? 1 : undefined)
      .constraintSize(!this.largeSpace || (this.linkUrl && (this.linkUrl != this.sourceUrl))
        ? {} : { maxWidth: measureTextWidth(url, this.getUIContext(), fontSizeSmall, FontWeight.Normal) / 2 + 20 });

      if (contextMenuImagePreview()) {
        oopsPreviewImage({
          url: url,
          requestVisit: (url) => {
            this.pk.myUi.openNewTab(url);
          },
          requestCloseMenu: () => {
            this.showMenu = false;
          }
        });
      }
    }.width('auto');
  }
}

@Builder
function WebBuilder(pk: meowTabInfo) {
  MeowWeb({ pk: pk });
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

  // Update
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
