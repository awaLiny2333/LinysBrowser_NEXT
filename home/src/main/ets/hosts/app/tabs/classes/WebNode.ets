import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import lazy { meow, meowLevel } from '../../../../catstypicalframework/utils/catsLogger';
import lazy { copyText } from '../../../../catstypicalframework/utils/clipboard';
import lazy { defaultInnerRadius, measureTextWidth, meowPx2vp } from '../../../../catstypicalframework/utils/ui';
import lazy { isLegalUrl } from '../../../../catstypicalframework/utils/url';
import lazy { MooSoloWeb } from '../../../../components/common/MooSoloWeb';
import lazy { MooSymbolButton } from '../../../../components/common/MooSymbolButton';
import lazy { MooTextButton } from '../../../../components/common/MooTextButton';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import lazy { fontSizeSmall, meowThemeColorType, mooTextType, standardSpacing } from '../../../../components/constants';
import lazy { oopsPreviewActionsImage } from '../../../../components/parts/WebContextMenu/oopsPreviewActionsImage';
import lazy { oopsPreviewActionsText } from '../../../../components/parts/WebContextMenu/oopsPreviewActionsText';
import lazy { oopsPreviewImage } from '../../../../components/parts/WebContextMenu/oopsPreviewImage';
import lazy { oopsPreviewQrResults } from '../../../../components/parts/WebContextMenu/oopsPreviewQrResults';
import lazy { defaultAnimation, getColor, getMySettings, isPreferRightHand, useEffects } from '../../../../components/settings';
import lazy { getCreateMyApp } from '../../../system/windows/scripts/helpers';
import lazy { contextMenuImagePreview, contextMenuStripText, contextMenuWebHeight, contextMenuWebPreview } from '../settings';
import { meowTabInfo } from './meowTabInfo';

@ComponentV2
struct MeowWeb {
  @Param @Require pk: meowTabInfo;
  // Local
  @Local areaChangeTimeout: number | undefined = undefined;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Web({ src: this.pk.url || '', controller: this.pk.controller })
        .scale({ x: this.pk.webScale / 100, y: this.pk.webScale / 100, z: 1, centerX: 0, centerY: 0 })
        .width(`${10000 / this.pk.webScale}%`)
        .height(`${10000 / this.pk.webScale}%`)
        .mediaPlayGestureAccess(false)
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
        .zoomControlAccess(getMySettings().settingsData[87].value as boolean) // Block Ctrl + - and mouse wheel
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
          this.pk.onTitle();
        })
        .onPageBegin(() => {
          this.pk.onPageBegin();
        })
        .onPageEnd(() => {
          this.pk.onPageEndLoadFinished();
        })
        .onLoadFinished(() => {
          this.pk.onPageEndLoadFinished();
        })
        .onProgressChange((event) => {
          this.pk.progress = event.newProgress;
          if (this.pk.progress == 100) {
            this.pk.progress = -1;
            // onPageEnd or onLoadFinished (duringLoad()) will be triggered, so we don't need to do anything here.
          } else {
            this.pk.onProgressChange();
          }
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
          return this.pk.requestLoad(event);
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
          this.pk.requestActivateContent();
        })
        .onWindowExit(() => {
          this.pk.requestExit();
        })
        .onWindowNew((event) => {
          if (!event) {
            return;
          }

          // Overlay alert / dialog
          if (event.isAlert) {
            this.pk.requestNewPopup(event);
            return;
          }

          // Non-alert webs
          let popController: webview.WebviewController = new webview.WebviewController();
          event.handler.setWebController(popController);
          this.pk.requestNewTab(event.targetUrl, popController, true);

          // Meow
          meow(`onWindowNew: ${event.targetUrl} -> ${popController}`, 'WebNode][onWindowNew');
        })
        .onContextMenuShow((event) => {
          if (!event) {
            return false;
          }
          // Data
          this.pk.contextMenuResult = event.result;
          this.pk.linkUrl = event.param.getLinkUrl();
          this.pk.sourceUrl = event.param.getSourceUrl();
          this.pk.unfilteredUrl = event.param.getUnfilteredLinkUrl();
          this.pk.isEditable = event.param.isEditable();
          this.pk.hasImage = event.param.existsImageContents();
          let t = event.param.getSelectionText();
          this.pk.selectedText = contextMenuStripText() ? t.trim() : t;
          // Ui
          this.pk.offsetX = meowPx2vp(event?.param.x() ?? 0);
          this.pk.offsetY = meowPx2vp(event?.param.y() ?? 0);
          this.pk.showMenu = true;
          return true;
        })
        .bindContextMenu(this.pk.showMenu, this.MenuBuilder, {
          enableArrow: false,
          placement: Placement.BottomRight,
          anchorPosition: { x: this.pk.offsetX, y: this.pk.offsetY },
          onDidDisappear: () => {
            this.pk.showMenu = false;
            this.pk.contextMenuResult!.closeContextMenu();
          },
          backgroundColor: useEffects() ? Color.Transparent : getColor(meowThemeColorType.PRIMARY),
          backgroundBlurStyle: useEffects() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
          hapticFeedbackMode: HapticFeedbackMode.AUTO,
        });

      // Popup
      if (this.pk.showingPopup) {
        Stack() {
          // Background padding.
          Column()
            .backgroundColor(Color.Black)
            .opacity(0.75)
            .width('100%')
            .height('100%');

          Column({ space: standardSpacing }) {
            // Web.
            MooSoloWeb({
              myUi: this.pk.myUi,
              url: '', controllerMeow: this.pk.popupController, onUrlUpdate: (url) => {
                this.pk.popupUrl = url;
                try {
                  this.pk.popupTitle = this.pk.popupController?.getTitle() || '...';
                } catch (e) {
                  meow(`Error getting title: ${e}`, 'WebNode][onWindowNew', meowLevel.ERROR);
                }
              }, onWindowExit: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.pk.showingPopup = false;
                });
              }
            })
              .clip(true)
              .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
              .layoutWeight(1);

            // Info & Control.
            Row() {
              Column({ space: standardSpacing * 0.75 }) {
                Text(this.pk.popupTitle).attributeModifier(new MooTextModifier(mooTextType.TITLE)).maxLines(1).wordBreak(WordBreak.BREAK_ALL);
                Text(this.pk.popupUrl).attributeModifier(new MooTextModifier()).maxLines(1).wordBreak(WordBreak.BREAK_ALL);
              }
              .padding(standardSpacing * 0.5)
              .alignItems(isPreferRightHand() ? HorizontalAlign.Start : HorizontalAlign.End)
              .layoutWeight(1);

              MooSymbolButton({
                icon: $r('sys.symbol.xmark'),
                clickAction: () => {
                  animateToImmediately(defaultAnimation(), () => {
                    this.pk.showingPopup = false;
                  });
                }
              });
            }
            .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl)
            .useEffect(useEffects(), EffectType.WINDOW_EFFECT)
            .backgroundColor(getColor(meowThemeColorType.PRIMARY))
            .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
            .padding(standardSpacing);
          }
          .margin(this.pk.myUi.myLayout.wideMode ? standardSpacing * 6 : standardSpacing);
        }
        .width('100%')
        .height('100%');
      }
    }
    .onAreaChange((o, n) => {
      if ((o.width as number) == (n.width as number)) {
        return;
      }
      clearTimeout(this.areaChangeTimeout);
      this.areaChangeTimeout = setTimeout(() => {
        this.pk.updateSlimUA();
      }, 1000);
    });
  }

  @Builder
  MenuBuilder() {
    Column() {
      Row() {
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_left'), isEnabled: this.pk.myUi.myTabs.currentTabCanBack, clickAction: () => {
            this.pk.myUi.myTabs.goBackCurrent();
            this.pk.showMenu = false;
          }
        }); // Backward
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_right'), isEnabled: this.pk.myUi.myTabs.currentTabCanForw, clickAction: () => {
            this.pk.myUi.myTabs.goForwardCurrent();
            this.pk.showMenu = false;
          }
        }); // Forward
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_clockwise'), clickAction: () => {
            this.pk.myUi.myTabs.refreshCurrent();
            this.pk.showMenu = false;
          }
        }); // Refresh
        MooSymbolButton({
          icon: $r('sys.symbol.selector'), isEnabled: this.pk.isEditable, clickAction: () => {
            this.pk.contextMenuResult?.selectAll();
            this.pk.showMenu = false;
          }
        }); // Select all
        MooSymbolButton({
          icon: $r('sys.symbol.plus_square_dashed_on_square'), isEnabled: this.pk.isEditable, clickAction: () => {
            this.pk.contextMenuResult?.paste();
            this.pk.showMenu = false;
          }
        }); // Paste
        MooSymbolButton({
          icon: $r('sys.symbol.cut'), isEnabled: this.pk.isEditable, clickAction: () => {
            this.pk.contextMenuResult?.cut();
            this.pk.showMenu = false;
          }
        }); // Cut
        MooSymbolButton({
          icon: $r('sys.symbol.undo'), isEnabled: this.pk.isEditable, clickAction: () => {
            this.pk.contextMenuResult?.undo();
            this.pk.showMenu = false;
          }
        }); // Undo
        MooSymbolButton({
          icon: $r('sys.symbol.redo'), isEnabled: this.pk.isEditable, clickAction: () => {
            this.pk.contextMenuResult?.redo();
            this.pk.showMenu = false;
          }
        }); // Redo
      }; // Always-on buttons of web control and edit.
      // Specific panels
      if (this.pk.selectedText) {
        this.contentCardBuilder(this.pk.selectedText);
      }
      if (this.pk.linkUrl) {
        this.contentCardBuilder(this.pk.linkUrl);
      }
      if (this.pk.sourceUrl && !this.pk.hasImage) {
        this.contentCardBuilder(this.pk.sourceUrl); // If has image, then don't show this duplicated url address.
      }
      if (this.pk.unfilteredUrl && this.pk.linkUrl != this.pk.unfilteredUrl) {
        this.contentCardBuilder(this.pk.unfilteredUrl);
      }
      if (this.pk.hasImage) {
        this.imageCardBuilder(this.pk.sourceUrl);
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
    return this.pk.myUi.myLayout.wideMode || getCreateMyApp().freeWindow;
  }

  @Builder
  contentCardBuilder(content: string) {
    Flex({ direction: this.largeSpace ? FlexDirection.Row : FlexDirection.Column }) {
      Column() {
        // The text
        MooTextButton({
          text: content, maxLines: this.largeSpace ? 5 : 3,
          clickAction: () => {
            if (isLegalUrl(content)[0]) {
              this.pk.myUi.openNewTab(content);
            } else {
              copyText(content);
            }
            this.pk.showMenu = false;
          }
        });

        // The row of copy, visit and things.
        oopsPreviewActionsText({
          text: content, requestCloseMenu: () => {
            this.pk.showMenu = false;
          }, requestVisit: (u) => {
            this.pk.myUi.openNewTab(u);
          }
        });
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.largeSpace && isLegalUrl(content)[0] && contextMenuWebPreview() ? 1 : undefined);

      // Web preview
      if (isLegalUrl(content)[0] && contextMenuWebPreview()) {
        MooSoloWeb({myUi: this.pk.myUi, url: content, radius: defaultInnerRadius - standardSpacing * 0.25 })
          .hoverEffect(HoverEffect.Highlight)
          .height(contextMenuWebHeight())
          .padding(standardSpacing * 0.5)
          .borderRadius(defaultInnerRadius)
          .layoutWeight(getCreateMyApp().freeWindow ? 3 : this.pk.myUi.myLayout.wideMode ? 2 : undefined);
      }
    }.width('auto');
  }

  @Builder
  imageCardBuilder(source: string) {
    Flex({ direction: this.largeSpace ? FlexDirection.Row : FlexDirection.Column }) {
      Column() {
        MooTextButton({
          text: source, maxLines: this.largeSpace ? 5 : 3, clickAction: () => {
            this.pk.myUi.openNewTab(source);
            this.pk.showMenu = false;
          }
        });

        // The row of copu image, save and things.s
        oopsPreviewActionsImage({
          tabInfo: this.pk, content: source,
          requestVisit: (url) => {
            this.pk.myUi.openNewTab(url);
          },
          requestCloseMenu: () => {
            this.pk.showMenu = false;
          },
          requestCopyImage: () => {
            this.pk.contextMenuResult?.copyImage();
          }
        });

        // The QR scan results.
        oopsPreviewQrResults({
          tabInfo: this.pk,
          requestVisit: (url) => {
            this.pk.myUi.openNewTab(url);
          },
          requestCloseMenu: () => {
            this.pk.showMenu = false;
          },
          requestCopy: (url) => {
            copyText(url);
          }
        });
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.largeSpace ? 1 : undefined)
      .constraintSize(!this.largeSpace || (this.pk.linkUrl && (this.pk.linkUrl != this.pk.sourceUrl))
        ? {} : { maxWidth: measureTextWidth(source, this.getUIContext(), fontSizeSmall, FontWeight.Normal) / 2 + 20 });

      // Image display
      if (contextMenuImagePreview()) {
        oopsPreviewImage({
          source: source,
          localImagePath: this.pk.imagePath,
          requestVisit: (url) => {
            this.pk.myUi.openNewTab(url);
          },
          requestCloseMenu: () => {
            this.pk.showMenu = false;
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
    let builderNode: BuilderNode<[meowTabInfo]> = new BuilderNode(uiContext); // 创建 BuilderNode
    builderNode.build(wrapBuilder<[meowTabInfo]>(WebBuilder), tab); // 创建动态 Web 组件
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
        console.error(`[WebNode][attachWeb] Failed! FrameNode already has a parent!`);
        return;
      }
      this.rootNode = this.builderNode.getFrameNode();
    }
  }

  // 卸载Webview
  detachWeb(): void {
    this.rootNode = null;
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
