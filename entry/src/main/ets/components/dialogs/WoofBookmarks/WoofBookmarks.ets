import { meowBookmarkStash } from '../../../hosts/bookmarks/classes/meowBookmarkStash';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../../hosts/env/classes/meowDialogManager';
import { WoofUniFrame } from '../common/WoofUniFrame';
import { meowBookmarkItem } from '../../../hosts/bookmarks/classes/meowBookmarkItem';
import { BookmarksColumn } from './parts/BookmarksColumn';
import { defaultAnimation, minimumCardWidth, standardSpacing, summarizedPreferRightHand } from '../../settings';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';

/**
 * Be the most convenient bookmark manager in the industry!!! :O
 */
@ComponentV2
struct WoofBookmarks {
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
                  // Set opened index in that level.
                  this.openedIndexOfLevels[item.index] = folder;
                  // Pop all levels on the right
                  this.openedStack = this.openedStack.slice(0, item.index + 1);
                  this.openedIndexOfLevels = this.openedIndexOfLevels.slice(0, item.index + 1);
                  // Push the new level on the right
                  this.openedStack.push(folder);
                  this.openedIndexOfLevels.push(undefined);
                });
                this.recalculateLayout();
              },
              onSubLevelClose: () => {
                animateToImmediately(defaultAnimation(), () => {
                  // Clear opened index in that level.
                  this.openedIndexOfLevels[item.index] = undefined;
                  // Pop all levels on the right
                  this.openedStack = this.openedStack.slice(0, item.index + 1);
                  this.openedIndexOfLevels = this.openedIndexOfLevels.slice(0, item.index + 1);
                });
                this.recalculateLayout();
              },
              onCardClose: () => {
                if (item.index > 0) {
                  animateToImmediately(defaultAnimation(), () => {
                    // Pop all levels on the right
                    this.openedStack = this.openedStack.slice(0, item.index);
                    this.openedIndexOfLevels = this.openedIndexOfLevels.slice(0, item.index);
                    this.openedIndexOfLevels[item.index - 1] = undefined;
                  });
                  this.recalculateLayout();
                }
              },
              requestSave: () => {
                this.myBookmarks.requestSaveToDisk();
              },
              onVisit: (url: string) => {
                meow(`Visiting: ${url}`, 'BookmarksColumn][onClickAction', meowLevel.INFO);
                this.controller?.close();
              },
              onDropReceivedAnOpenedFolder: (fromLayer: number) => {
                // fromLevel > item.index
                // Pop all levels on the right
                this.openedStack = this.openedStack.slice(0, fromLayer + 1);
                this.openedIndexOfLevels = this.openedIndexOfLevels.slice(0, fromLayer + 1);
                this.openedIndexOfLevels[fromLayer] = undefined;
                this.recalculateLayout();
              }
            });
          });
      }
      .direction(summarizedPreferRightHand() ? Direction.Ltr : Direction.Rtl)
      .justifyContent(summarizedPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
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
    .direction(summarizedPreferRightHand() ? Direction.Rtl : Direction.Ltr)
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Horizontal);
  }

  recalculateLayout() {
    // Calculate layout
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
}


@CustomDialog
struct WoofBookmarksDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Bookmarks'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      WoofBookmarks({ controller: this.controller });
    };
  }
}

export { WoofBookmarksDialog };
