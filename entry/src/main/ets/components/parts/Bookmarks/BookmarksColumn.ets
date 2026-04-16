import { unifiedDataChannel } from '@kit.ArkData';
import { AppStorageV2 } from '@kit.ArkUI';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { meowBookmarkItem } from '../../../hosts/bookmarks/classes/meowBookmarkItem';
import { nowHtmlTimestamp } from '../../../hosts/bookmarks/scripts/helpers';
import { meowAppStatuses } from '../../../hosts/env/classes/meowAppStatuses';
import { StringPairArrayItem } from '../../common/MooStringPairArrayItem';
import { MooSymbolButton } from '../../common/MooSymbolButton';
import { MooTextModifier } from '../../common/MooTextModifier';
import { defaultAnimation, getColor, meowThemeColorType, standardSpacing, isPreferRightHand, useEffects } from '../../settings';

/**
 * 
 */
export const meowBookmarkItemUnifiedType = 'ApplicationDefined.meowBookmarkItem.flag';

@ComponentV2
struct BookmarksColumn {
  @Param @Require folder: meowBookmarkItem;
  @Param @Require level: number;
  @Param @Require canCloseThis: boolean;
  @Param @Require selectedItem: meowBookmarkItem;
  @Param @Require columnWidth: number;
  @Param @Require avoidBar: boolean;
  // Data
  @Local currentFolderChildren: meowBookmarkItem[] = Array.from(this.folder.children); // Maintained through this.refreshRoot().
  // UI
  @Local inDragMode: boolean = true; // By default true, to allow dragging instead of rearranging. TODO: find an elegant way to have them coexist.
  // Events
  @Event requestSave: () => void;
  @Event onSubLevelOpen: (item: meowBookmarkItem) => void; // Open a sub folder
  @Event onSubLevelClose: () => void; // Close the opening sub folder
  @Event onCardClose: () => void; // This card is closed
  @Event onVisit: (url: string) => void;
  @Event onDropReceivedAnOpenedFolder: (fromLayer: number) => void;

  build() {
    Column({ space: standardSpacing }) {
      Row() {
        this.BookmarksList();
      }
      .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
      .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
      .alignItems(VerticalAlign.Bottom)
      .layoutWeight(1);

      this.BottomControl();
    }
    .width(this.columnWidth)
    .onDrop((event: DragEvent) => {
      let records: unifiedDataChannel.UnifiedRecord[];
      try {
        records = event.getData().getRecords();
      } catch (e) {
        meow(`Error handling drag event: ${e}`, `BookmarksColumn][onDrop][${this.folder.name}`, meowLevel.ERROR);
        return;
      }

      // Process after getting the data.
      meow(`onDrop: [${records.length}]`, `BookmarksColumn][onDrop][${this.folder.name}`);
      const result = this.receiveDrop(records);

      // Feedback to determine if the bookmark items are ok to be deleted.
      if (result) {
        event.setResult(DragResult.DRAG_SUCCESSFUL);
      } else {
        event.setResult(DragResult.DRAG_FAILED);
      }
    });
  }

  @Monitor('folder')
  refreshRoot() {
    this.currentFolderChildren = Array.from(this.folder.children);
    meow(`Refreshing folder: ${this.folder.name}`, 'BookmarksColumn][refreshRoot', meowLevel.INFO);
  }

  @Builder
  BookmarksList() {
    List({ space: standardSpacing * 0.75 }) {
      Repeat(this.currentFolderChildren).each((item: RepeatItem<meowBookmarkItem>) => {
        ListItem() {
          StringPairArrayItem({
            allowEdit: true,
            allowSelect: true,
            maxLines: undefined, // Unlimited lines!
            enableLinkField: !item.item.isFolder,
            icon: item.item.isFolder ? '󰃅  ' : '',
            item: [item.item.name, item.item.url],
            index: item.index,
            isSelected: this.selectedItem == item.item,
            onSelect: () => {
              if (this.selectedItem == item.item) {
                // Close this folder
                this.onSubLevelClose();
                return;
              }

              if (item.item.isFolder) {
                // Should open this folder.
                this.onSubLevelOpen(item.item);
              } else {
                // Should visit the web site
                this.onVisit(item.item.url);
              }
            },
            onEdited: (newValues) => {
              item.item.name = newValues[0];
              item.item.url = newValues[1];
              item.item.date_modified = nowHtmlTimestamp();
              // meow(`heard this.onEdit(${index}, [${newValues[0]}, ${newValues[1]}])`, 'BookmarksColumn][onEdit', meowLevel.WARN);
              this.requestSave();
            },
            onDelete: () => {
              try {
                this.folder.children.splice(item.index, 1);
                this.currentFolderChildren.splice(item.index, 1);
                this.requestSave();
              } catch (e) {
                meow(`Error deleting bookmark: ${e}`, 'BookmarksColumn][onDelete', meowLevel.ERROR);
              }
            }
          })
            .draggable(this.inDragMode ? true : undefined)
            .onDragStart((event: DragEvent) => {
              // Put the item (to be sent) in AppStatuses.
              const myApp = AppStorageV2.connect(meowAppStatuses)!;

              // Only report level when the current folder is opened.
              // The entire layer verification design is to ensure that
              // the dragged item won't be dropped into itself (or its sub folders)
              // So for a folder that is not opened, it can be dragged anywhere.
              const reportedLevel = (this.selectedItem == item.item) ? this.level : undefined;
              myApp.crossAppDataTunnel = [reportedLevel, [item.item]]; // [number | undefined, meowBookmarkItem[]]

              // Fill (actually zero) data :P
              let data = new unifiedDataChannel.ApplicationDefinedRecord();
              data.applicationDefinedType = meowBookmarkItemUnifiedType;
              let unifiedData = new unifiedDataChannel.UnifiedData(data);
              event.setData(unifiedData);
            })
            .onDragEnd((event) => {
              if (event.getResult() == DragResult.DRAG_SUCCESSFUL) {
                // Old father's heart finally drop down.
                animateToImmediately(defaultAnimation(), () => {
                  // Splice!
                  try {
                    this.folder.children.splice(item.index, 1);
                    this.currentFolderChildren.splice(item.index, 1);
                    this.requestSave();
                  } catch (e) {
                    meow(`Error deleting bookmark: ${e}`, 'BookmarksColumn][onDelete', meowLevel.ERROR);
                  }
                });
              }
            });
        };
      })
        .onMove((from: number, to: number) => {
          try {
            const item = this.folder.children.splice(from, 1);
            this.folder.children.splice(to, 0, item[0]);
            this.currentFolderChildren.splice(from, 1);
            this.currentFolderChildren.splice(to, 0, item[0]);
            this.requestSave();
          } catch (e) {
            meow(`Error moving item: ${e}`, 'BookmarksColumn][onMove', meowLevel.ERROR);
          }
        });
    }
    .alignListItem(isPreferRightHand() ? ListItemAlign.End : ListItemAlign.Start)
    .width('100%')
    .height('auto')
    .padding(standardSpacing * 0.75);
  }

  @Builder
  BottomControl() {
    Row({ space: standardSpacing * 0.5 }) {
      Text(this.folder.name).attributeModifier(new MooTextModifier()).wordBreak(WordBreak.BREAK_ALL).maxLines(2).layoutWeight(1);

      // Toggle drag mode
      MooSymbolButton({
        icon: this.inDragMode ? $r('sys.symbol.move') : $r('sys.symbol.swap'),
        onHold: true,
        clickAction: () => {
          this.inDragMode = !this.inDragMode;
        }
      });

      // Add folder.
      MooSymbolButton({
        icon: $r('sys.symbol.folder_badge_plus'),
        clickAction: () => {
          // New folder
          const newFolder = new meowBookmarkItem(true, `New Folder on ${new Date().toLocaleString()}`, '');
          animateToImmediately(defaultAnimation(), () => {
            try {
              this.folder.children.push(newFolder);
              this.currentFolderChildren.push(newFolder);
              this.requestSave();
            } catch (e) {
              meow(`Error adding folder: ${e}`, 'BookmarksColumn][onAddFolder', meowLevel.ERROR);
            }
          });
        }
      });

      // Add bookmark.
      MooSymbolButton({
        icon: $r('sys.symbol.book_closed_right_left_badge_plus'),
        clickAction: () => {
          // New bookmark
          const newBookmark = new meowBookmarkItem(false, `New Bookmark on ${new Date().toLocaleString()}`, ''); // TODO: grab current page info!
          animateToImmediately(defaultAnimation(), () => {
            try {
              this.folder.children.push(newBookmark);
              this.currentFolderChildren.push(newBookmark);
              this.requestSave();
            } catch (e) {
              meow(`Error adding bookmark: ${e}`, 'BookmarksColumn][onAddBookmark', meowLevel.ERROR);
            }
          });
        }
      });

      // Close card.
      MooSymbolButton({
        icon: this.canCloseThis ? $r('sys.symbol.xmark') : $r('sys.symbol.archivebox'),
        clickAction: () => {
          if (this.canCloseThis) {
            this.onCardClose();
          }
        }
      });
    }
    .padding({ bottom: this.avoidBar ? standardSpacing : 0 }) // Avoid scroller
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
  }

  receiveDrop(records: unifiedDataChannel.UnifiedRecord[]) {
    // Grab it from AppStatuses
    const myApp = AppStorageV2.connect(meowAppStatuses)!;
    const pack = myApp.crossAppDataTunnel as (meowBookmarkItem[] | number)[];
    const fromLevel = pack[0] as number | undefined;
    const item = pack[1] as meowBookmarkItem[];

    // log levels
    meow(`Received drop from level ${fromLevel} to level ${this.level}`, `BookmarksColumn][onDrop][${this.folder.name}`, meowLevel.INFO);

    // Level check.
    if ((fromLevel != undefined) && (fromLevel <= this.level)) {
      meow(`Level check failed!`, `BookmarksColumn][onDrop][${this.folder.name}`, meowLevel.ERROR);
      return false;
    }

    // Boundary check.
    if (records.length > item.length) {
      meow(`Out of bounds!`, `BookmarksColumn][onDrop][${this.folder.name}`, meowLevel.ERROR);
      return false;
    }

    const newItems: meowBookmarkItem[] = [];

    // Traverse data, assuming they are one-one paired.
    for (let i = 0; i < records.length; i++) {
      // Ignore unknown type.
      const type = records[i].getTypes().join('.');
      if (type != meowBookmarkItemUnifiedType) {
        meow(`Unknown record type: ${type}. Accepts only [${meowBookmarkItemUnifiedType}]!`, `BookmarksColumn][onDrop][${this.folder.name}`, meowLevel.ERROR);
        return false;
      }

      newItems.push(item[i]);
    }

    // Dropped an opened folder
    if (fromLevel != undefined) {
      this.onDropReceivedAnOpenedFolder(fromLevel);
    }

    // Push to the real folder
    animateToImmediately(defaultAnimation(), () => {
      try {
        this.folder.children.push(...newItems);
        this.currentFolderChildren.push(...newItems);
      } catch (e) {
        meow(`Error adding item: ${e}`, `BookmarksColumn][onDrop][${this.folder.name}`, meowLevel.ERROR);
        // return false;
      }
    });
    
    // Clear tunnel
    myApp.crossAppDataTunnel = [];

    // Save bookmarks
    this.requestSave();
    return true;
  }
}

export { BookmarksColumn };

