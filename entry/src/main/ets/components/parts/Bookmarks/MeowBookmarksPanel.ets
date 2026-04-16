import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { meowBookmarkItem } from '../../../hosts/bookmarks/classes/meowBookmarkItem';
import { meowBookmarkStash } from '../../../hosts/bookmarks/classes/meowBookmarkStash';
import { standardSpacing, defaultAnimation, isPreferRightHand, minimumCardWidth } from '../../settings';
import { BookmarksColumn } from './BookmarksColumn';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * Be the most convenient bookmark manager in the industry!!! :O
 */
@ComponentV2
struct MeowBookmarksPanel {
  @Param @Require controller: CustomDialogController;
  // Data
  @Local myBookmarks: meowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;
  @Local openedStack: meowBookmarkItem[] = [this.myBookmarks.root];
  @Local openedIndexOfLevels: (meowBookmarkItem | undefined)[] = [];
  // UI
  @Local maxColumn: number = 1;
  @Local dialogWidth: number = 0;
  @Local columnWidth: number = 0;

  build() {
    Scroll() {
      Row({ space: standardSpacing * 0.75 }) {
        Repeat(this.openedStack)
          .each((item: RepeatItem<meowBookmarkItem>) => {
            BookmarksColumn({
              canCloseThis: item.index > 0,
              columnWidth: this.columnWidth,
              avoidBar: this.maxColumn < this.openedStack.length,
              selectedItem: this.openedIndexOfLevels[item.index],
              folder: item.item,
              level: item.index,
              onSubLevelOpen: (folder) => {
                animateToImmediately(defaultAnimation(), () => {
                  this.closeAllRightOf(item.index); // Pop all levels on the right
                  this.openedIndexOfLevels[item.index] = folder; // Set opened index in that level.
                  // Push the new level on the right
                  this.openedStack.push(folder);
                  this.openedIndexOfLevels.push(undefined);
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
                meow(`Visiting: ${url}`, 'BookmarksColumn][onClickAction', meowLevel.INFO);
                this.controller?.close();
              },
              onDropReceivedAnOpenedFolder: (fromLayer: number) => {
                this.closeAllRightOfWithAnima(fromLayer); // Pop all levels on the right
                this.recalculateLayout();
              },
              requestSave: () => {
                this.myBookmarks.requestSaveToDisk();
              },
            });
          });
      }
      .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl)
      .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
      .alignItems(VerticalAlign.Bottom)
      .padding(standardSpacing);
    }
    .scrollBar(this.maxColumn < this.openedStack.length ? BarState.On : BarState.Off)
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
    const columnCount = Math.min(maxColumn, this.openedStack.length);
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
    this.openedStack = this.openedStack.slice(0, idx + 1);
    this.openedIndexOfLevels = this.openedIndexOfLevels.slice(0, idx + 1);
    this.openedIndexOfLevels[idx] = undefined; // Clear opened index in that level.
  }
}

export { MeowBookmarksPanel };
