import { AppStorageV2 } from '@kit.ArkUI';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { globalMessage, meowAppMessageType } from '../../../hosts/system/windows/scripts/messaging';
import { meowBookmarkItem } from '../../../hosts/userdata/bookmarks/classes/meowBookmarkItem';
import { meowBookmarkStash } from '../../../hosts/userdata/bookmarks/classes/meowBookmarkStash';
import { minimumCardWidth, standardSpacing } from '../../constants';
import { defaultAnimation, isPreferRightHand } from '../../settings';
import { BookmarksColumn } from './BookmarksColumn';

/**
 * Be the most convenient bookmark manager in the industry!!! :O
 */
@ComponentV2
struct MeowBookmarksPanel {
  // Config
  @Param @Once needPadding: boolean = true;
  @Param @Once selectMode: boolean = false; // False for normal (display and edit) mode, true for select mode.
  // Hosts
  @Param @Require myUi: meowUiHost;
  @Local myBookmarks: meowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;
  // UI
  @Param @Once panelWidth: number = 0;
  @Param @Once maxColumn: number = 1;
  @Param @Once columnWidth: number = 0;
  // Events (Drag drop)
  @Event onDragEnterColumn: () => void;
  @Event onDragLeaveColumn: () => void;
  @Event onDropColumn: () => void;
  @Event onItemDragStart: () => void;
  // Events (Panel)
  @Event requestVisit: (url: string) => void;
  @Event onSelect: (folder: meowBookmarkItem, path: string) => void; // Called when this column folder is selected. For select mode only.

  aboutToAppear(): void {
    // Initialize
    if (this.myUi.openedStack.length == 0) {
      this.refreshRoot();
    }
  }

  @Monitor('myBookmarks.root')
  refreshRoot() {
    this.myUi.openedStack = [this.myBookmarks.root];
    this.myUi.openedIndexOfLevels = [undefined];
    meow('REFRESH!', 'MeowBookmarksPanel][refreshRoot', meowLevel.WARN);
  }

  build() {
    Scroll() {
      Row({ space: standardSpacing * 0.75 }) {
        Repeat(this.myUi.openedStack)
          .each((item: RepeatItem<meowBookmarkItem>) => {
            BookmarksColumn({
              myUi: this.myUi,
              selectMode: this.selectMode,
              canCloseThis: item.index > 0,
              columnWidth: this.cWidth,
              avoidBar: this.maxC < this.myUi.openedStack.length,
              selectedItem: this.myUi.openedIndexOfLevels[item.index],
              folder: item.item,
              level: item.index,
              onItemDragStart: () => {
                this.onItemDragStart();
              },
              onDragEnterColumn: () => {
                this.onDragEnterColumn();
              },
              onDragLeaveColumn: () => {
                this.onDragLeaveColumn();
              },
              onDropColumn: () => {
                this.onDropColumn();
              },
              requestSubLevelOpen: (folder) => {
                animateToImmediately(defaultAnimation(), () => {
                  this.closeAllRightOf(item.index); // Pop all levels on the right
                  this.myUi.openedIndexOfLevels[item.index] = folder; // Set opened index in that level.
                  // Push the new level on the right
                  this.myUi.openedStack.push(folder);
                  this.myUi.openedIndexOfLevels.push(undefined);
                });
              },
              requestSubLevelClose: () => {
                this.closeAllRightOf_Animated(item.index); // Pop all levels on the right
              },
              requestCardClose: () => {
                // The base layer folder won't call this. I trust it. :P
                this.closeAllRightOf_Animated(item.index - 1); // Pop all levels on the right
              },
              requestVisit: (url: string) => {
                this.requestVisit(url);
              },
              requestSaveAndBroadcastSync: () => {
                this.myBookmarks.requestSaveToDisk();
                globalMessage(meowAppMessageType.BOOKMARKS_REFRESH);
              },
              requestImport: () => {
                this.myBookmarks.importHTMLfromDocuments(item.item).then(() => {
                  globalMessage(meowAppMessageType.BOOKMARKS_REFRESH);
                });
              },
              requestExport: () => {
                this.myBookmarks.exportHTMLtoDocuments(item.item);
              },
              onSelect: (folder) => {
                // This is only for select mode.
                const position = this.myUi.openedStack.indexOf(folder);
                this.onSelect(folder, `/${this.myUi.openedStack.slice(0, position + 1).join('/')}`);
              }
            });
          });
      }
      .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl)
      .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
      .alignItems(VerticalAlign.Bottom)
      .padding(this.needPadding ? standardSpacing : 0);
    }
    .scrollBar(this.maxC < this.myUi.openedStack.length ? BarState.On : BarState.Off)
    .onAreaChange((oldValue, newValue) => {
      if ((oldValue.width as number != newValue.width as number) && (newValue.width as number != this.panelWidth)) {
        this.panelWidth = newValue.width as number;
      }
    })
    .direction(isPreferRightHand() ? Direction.Rtl : Direction.Ltr)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Horizontal);
  }

  get maxC() {
    const maxColumn = Math.floor(this.panelWidth / (minimumCardWidth * 0.5));
    const columnCount = Math.min(maxColumn, this.myUi.openedStack.length);
    return columnCount;
  }

  get cWidth() {
    const maxColumn = Math.floor(this.panelWidth / (minimumCardWidth * 0.5));
    const columnCount = Math.min(maxColumn, this.myUi.openedStack.length);
    const columnSpaceCount = columnCount - 1;
    const frameSpace = this.needPadding ? 2 * standardSpacing : 0;
    const columnWidth = (this.panelWidth - columnSpaceCount * standardSpacing * 0.75 - frameSpace) / columnCount;
    return columnWidth;
  }

  /**
   * Close all levels on the right of the given index, with animation.
   * The #idx card is safe from this.
   * @param idx The index of the level to close.
   */
  closeAllRightOf_Animated(idx: number) {
    animateToImmediately(defaultAnimation(), () => {
      this.closeAllRightOf(idx);
    });
  }

  /**
   * Close all levels on the right of the given index.
   * The #idx card is safe from this.
   * @param idx The index of the level to close.
   */
  closeAllRightOf(idx: number) {
    this.myUi.openedStack = this.myUi.openedStack.slice(0, idx + 1);
    this.myUi.openedIndexOfLevels = this.myUi.openedIndexOfLevels.slice(0, idx + 1);
    this.myUi.openedIndexOfLevels[idx] = undefined; // Clear opened index in that level.
  }
}

export { MeowBookmarksPanel };
