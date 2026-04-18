import { AppStorageV2 } from '@kit.ArkUI';
import { meowBookmarkItem } from '../../../hosts/data/bookmarks/classes/meowBookmarkItem';
import { meowBookmarkStash } from '../../../hosts/data/bookmarks/classes/meowBookmarkStash';
import { globalMessage, meowAppMessageType } from '../../../hosts/system/windows/scripts/messaging';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { meowAppStatuses } from '../../../hosts/system/windows/classes/meowAppStatuses';
import { defaultAnimation, isPreferRightHand, minimumCardWidth, standardSpacing } from '../../settings';
import { BookmarksColumn } from './BookmarksColumn';

/**
 * Be the most convenient bookmark manager in the industry!!! :O
 */
@ComponentV2
struct MeowBookmarksPanel {
  // Config
  @Param @Once selectMode: boolean = false; // False for normal (display and edit) mode, true for select mode.
  // Hosts
  @Param @Require myUi: meowUiStatuses;
  @Local myBookmarks: meowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!; // For event receiving.
  // UI
  @Local maxColumn: number = 1;
  @Local dialogWidth: number = 0;
  @Local columnWidth: number = 0;
  // Event
  @Event requestVisit: (url: string) => void;
  @Event onSelect: (folder: meowBookmarkItem, path: string) => void;

  aboutToAppear(): void {
    // Initialize
    if (this.myUi.openedStack.length == 0) {
      this.myUi.openedStack = [this.myBookmarks.root];
      this.myUi.openedIndexOfLevels = [undefined];
    }
  }

  build() {
    Scroll() {
      Row({ space: standardSpacing * 0.75 }) {
        Repeat(this.myUi.openedStack)
          .each((item: RepeatItem<meowBookmarkItem>) => {
            BookmarksColumn({
              selectMode: this.selectMode,
              canCloseThis: item.index > 0,
              columnWidth: this.columnWidth,
              avoidBar: this.maxColumn < this.myUi.openedStack.length,
              selectedItem: this.myUi.openedIndexOfLevels[item.index],
              folder: item.item,
              level: item.index,
              onSubLevelOpen: (folder) => {
                animateToImmediately(defaultAnimation(), () => {
                  this.closeAllRightOf(item.index); // Pop all levels on the right
                  this.myUi.openedIndexOfLevels[item.index] = folder; // Set opened index in that level.
                  // Push the new level on the right
                  this.myUi.openedStack.push(folder);
                  this.myUi.openedIndexOfLevels.push(undefined);
                });
                this.recalculateLayout();
              },
              onSubLevelClose: () => {
                this.closeAllRightOfWithAnima(item.index); // Pop all levels on the right
                this.recalculateLayout();
              },
              onCardClose: () => {
                // The base layer folder won't call this. I trust it.
                this.closeAllRightOfWithAnima(item.index - 1); // Pop all levels on the right
                this.recalculateLayout();
              },
              onVisit: (url: string) => {
                this.requestVisit(url);
              },
              onDropReceivedAnOpenedFolder: (fromLayer: number) => {
                this.closeAllRightOfWithAnima(fromLayer); // Pop all levels on the right
                this.recalculateLayout();
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
      .padding(standardSpacing);
    }
    .scrollBar(this.maxColumn < this.myUi.openedStack.length ? BarState.On : BarState.Off)
    .onAreaChange((oldValue, newValue) => {
      if ((oldValue.width as number != newValue.width as number) && (newValue.width as number != this.dialogWidth)) {
        this.dialogWidth = newValue.width as number;
      }
      this.recalculateLayout();
    })
    .direction(isPreferRightHand() ? Direction.Rtl : Direction.Ltr)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Horizontal);
  }

  /**
   * Recalculate the layout of the dialog.
   */
  recalculateLayout() {
    const maxColumn = Math.floor(this.dialogWidth / (minimumCardWidth * 0.5));
    const columnCount = Math.min(maxColumn, this.myUi.openedStack.length);
    const columnSpaceCount = columnCount - 1;
    const frameSpace = 2 * standardSpacing;
    const columnWidth = (this.dialogWidth - columnSpaceCount * standardSpacing * 0.75 - frameSpace) / columnCount;

    animateToImmediately(defaultAnimation(), () => {
      this.maxColumn = columnCount;
      this.columnWidth = columnWidth;
    });
  }

  /**
   * Close all levels on the right of the given index, with animation.
   * The #idx card is safe from this.
   * @param idx The index of the level to close.
   */
  closeAllRightOfWithAnima(idx: number) {
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
