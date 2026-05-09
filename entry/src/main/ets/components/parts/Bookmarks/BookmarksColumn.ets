import { unifiedDataChannel } from '@kit.ArkData';
import { AppStorageV2 } from '@kit.ArkUI';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { meowAppStatuses } from '../../../hosts/system/windows/classes/meowAppStatuses';
import { meowAppMessageType } from '../../../hosts/system/windows/scripts/messaging';
import { meowBookmarkItem } from '../../../hosts/userdata/bookmarks/classes/meowBookmarkItem';
import { nowHtmlTimestamp } from '../../../hosts/userdata/bookmarks/scripts/helpers';
import { MooStringItem } from '../../common/MooStringItem';
import { MooSymbolButton } from '../../common/MooSymbolButton';
import { MooTextModifier } from '../../common/MooTextModifier';
import { meowThemeColorType, standardSpacing } from '../../constants';
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from '../../settings';

/**
 * The Unified Type name of bookmark items.
 * This is used to verify the dropped items to the column.
 * See the onDrop() code below!
 */
export const meowBookmarkItemUnifiedType = 'ApplicationDefined.meowBookmarkItem.flag';

@ComponentV2
struct BookmarksColumn {
  // Config
  @Param @Once selectMode: boolean = false; // False for normal (display and edit) mode, true for select mode.
  // Host
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!; // For event receiving.
  // Params
  @Param @Require folder: meowBookmarkItem;
  @Param @Require level: number;
  @Param @Require canCloseThis: boolean;
  @Param @Require selectedItem: meowBookmarkItem;
  @Param @Require columnWidth: number;
  @Param @Require avoidBar: boolean;
  // UI
  @Local inDragMode: boolean = true; // By default true, to allow dragging instead of rearranging. TODO: find an elegant way to have them coexist.
  @Local inMore: boolean = false; // By default false, to allow showing more options.
  @Local refreshFlag: boolean = false;
  listScroller: Scroller = new Scroller();
  // Requests
  @Event requestSaveAndBroadcastSync: () => void; // Request the MeowBookmarksPanel to save changes to disk, and request an app-wide broadcast of refresh to sync bookmarks statuses.
  @Event requestImport: () => void;
  @Event requestExport: () => void;
  // Events
  @Event onSubLevelOpen: (item: meowBookmarkItem) => void; // Open a sub folder
  @Event onSubLevelClose: () => void; // Close the opening sub folder
  @Event onCardClose: () => void; // This card is closed
  @Event onVisit: (url: string) => void;
  @Event onDropReceivedAnOpenedFolder: (fromLayer: number) => void;
  @Event onSelect: (item: meowBookmarkItem) => void; // For select mode only.

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
        meow(`Error handling drag event: ${e}`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
        return;
      }

      // Process after getting the data.
      meow(`onDrop: [${records.length}]`, `BookmarksColumn][onDrop][${this.folder.title}`);
      const result = this.receiveDrop(records);

      // Feedback to determine if the bookmark items are ok to be deleted.
      if (result) {
        event.setResult(DragResult.DRAG_SUCCESSFUL);
        this.listScroller.scrollEdge(Edge.Bottom);
      } else {
        event.setResult(DragResult.DRAG_FAILED);
      }
    });
  }

  getFolder() {
    this.refreshFlag; // To refresh!
    return Array.from(this.folder.children);
  }

  @Monitor('folder')
  refreshRoot() {
    this.refreshFlag = !this.refreshFlag;
  }

  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.BOOKMARKS_REFRESH) {
      this.refreshFlag = !this.refreshFlag;
      try {
        if (this.folder.children.indexOf(this.selectedItem) < 0) {
          this.onSubLevelClose();
        }
      } catch (e) {
        // This won't really happen actually.
      }
    }
  }

  @Builder
  BookmarksList() {
    List({ space: standardSpacing * 0.75, scroller: this.listScroller }) {
      Repeat(this.getFolder())
        .each((item: RepeatItem<meowBookmarkItem>) => {
          ListItem() {
            MooStringItem({
              allowEdit: !this.selectMode,
              allowSelect: true,
              maxLines: undefined, // Unlimited lines!
              enableLinkField: !item.item.isFolder,
              icon: item.item.isFolder ? '󰃅  ' : '',
              item: this.getLabelLinkItem(item.item),
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
                } else if (!this.selectMode) {
                  // Should visit the web site
                  this.onVisit(item.item.url);
                }
              },
              onEdited: (newValues) => {
                item.item.title = newValues[0];
                item.item.url = newValues[1];
                item.item.date_modified = nowHtmlTimestamp();
                // meow(`heard this.onEdit(${index}, [${newValues[0]}, ${newValues[1]}])`, 'BookmarksColumn][onEdit', meowLevel.WARN);
                this.requestSaveAndBroadcastSync();
              },
              onDelete: () => {
                try {
                  this.folder.children.splice(item.index, 1);
                  this.requestSaveAndBroadcastSync();
                } catch (e) {
                  meow(`Error deleting bookmark: ${e}`, 'BookmarksColumn][onDelete', meowLevel.ERROR);
                }
              }
            })
              .opacity(this.selectMode && !item.item.isFolder ? 0.5 : 1)
              .draggable(this.inDragMode ? true : undefined)
              .onDragStart((event: DragEvent) => {
                // Put the item (to be sent) in AppStatuses.
                const myApp = AppStorageV2.connect(meowAppStatuses)!;

                // Only report level when the current folder is opened.
                // The entire layer verification design is to ensure that
                // the dragged item won't be dropped into itself (or its sub folders)
                // So for a folder that is not opened, it can be dragged anywhere.
                const reportedLevel = (this.selectedItem == item.item) ? this.level : undefined;
                myApp.dataTunnelForBookmarks = [reportedLevel, [item.item]]; // [number | undefined, meowBookmarkItem[]]

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
                      this.requestSaveAndBroadcastSync();
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
            this.requestSaveAndBroadcastSync();
          } catch (e) {
            meow(`Error moving item: ${e}`, 'BookmarksColumn][onMove', meowLevel.ERROR);
          }
        })
        .virtualScroll();
    }
    .alignListItem(isPreferRightHand() ? ListItemAlign.End : ListItemAlign.Start)
    .width('100%')
    .height('auto')
    .padding(standardSpacing * 0.75);
  }

  @Builder
  BottomControl() {
    Row({ space: standardSpacing * 0.5 }) {
      // More and text title
      if (this.inMore) {
        Blank().layoutWeight(1);

        // Import bookmarks.
        MooSymbolButton({
          icon: $r('sys.symbol.cube_and_arrow_down'),
          clickAction: () => {
            this.requestImport();
          }
        });

        // Export folder.
        MooSymbolButton({
          icon: $r('sys.symbol.rectangle_and_arrowshape_turn_up_right'),
          clickAction: () => {
            this.requestExport();
          }
        });

        // Add folder.
        MooSymbolButton({
          icon: $r('sys.symbol.folder_badge_plus'),
          clickAction: () => {
            // New folder
            const label = `New Folder on ${new Date().toLocaleString()}`;
            const newFolder = new meowBookmarkItem(true, label, '');
            animateToImmediately(defaultAnimation(), () => {
              try {
                this.folder.children.push(newFolder);
                this.requestSaveAndBroadcastSync();
              } catch (e) {
                meow(`Error adding folder: ${e}`, 'BookmarksColumn][onAddFolder', meowLevel.ERROR);
              }
            });
            this.listScroller.scrollEdge(Edge.Bottom);
          }
        });

        // Add bookmark.
        MooSymbolButton({
          icon: $r('sys.symbol.book_closed_right_left_badge_plus'),
          clickAction: () => {
            // New bookmark
            const label = `New Bookmark on ${new Date().toLocaleString()}`;
            const link = '';
            const newBookmark = new meowBookmarkItem(false, label, link); // TODO: grab current page info!
            animateToImmediately(defaultAnimation(), () => {
              try {
                this.folder.children.push(newBookmark);
                this.requestSaveAndBroadcastSync();
              } catch (e) {
                meow(`Error adding bookmark: ${e}`, 'BookmarksColumn][onAddBookmark', meowLevel.ERROR);
              }
            });
            this.listScroller.scrollEdge(Edge.Bottom);
          }
        });

        // Toggle drag mode
        MooSymbolButton({
          icon: this.inDragMode ? $r('sys.symbol.move') : $r('sys.symbol.swap'),
          onHold: true,
          clickAction: () => {
            this.inDragMode = !this.inDragMode;
          }
        });
      } else {
        Text(this.folder.title).attributeModifier(new MooTextModifier()).wordBreak(WordBreak.BREAK_ALL).maxLines(2).padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 }).layoutWeight(1);
      }

      if (this.selectMode) {
        // OK
        MooSymbolButton({
          icon: $r('sys.symbol.checkmark'),
          clickAction: () => {
            this.onSelect(this.folder);
          }
        });
      } else {
        // Toggle More mode
        MooSymbolButton({
          icon: $r('sys.symbol.dot_grid_2x2'),
          onHold: this.inMore,
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.inMore = !this.inMore;
            });
          }
        });
      }

      // Close card.
      if (this.canCloseThis) {
        MooSymbolButton({
          icon: $r('sys.symbol.xmark'),
          clickAction: () => {
            this.onCardClose();
          }
        });
      }
    }
    .padding({ bottom: this.avoidBar ? standardSpacing * 1.25 : 0 }) // Avoid scroller
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
  }

  /**
   * Get label and link of an item.
   * @param item The item.
   * @returns [label, link]
   */
  getLabelLinkItem(item: meowBookmarkItem) {
    this.refreshFlag;
    return [item.title, item.url];
  }

  /**
   * Things to do after receiving a unified drop event on this column.
   * @param records The unifiedRecords.
   * @returns True if succeeded, false if failed.
   */
  receiveDrop(records: unifiedDataChannel.UnifiedRecord[]) {
    // Grab it from AppStatuses
    const myApp = AppStorageV2.connect(meowAppStatuses)!;
    const pack = myApp.dataTunnelForBookmarks as (meowBookmarkItem[] | number)[];
    const fromLevel = pack[0] as number | undefined;
    const item = pack[1] as meowBookmarkItem[];

    // log levels
    meow(`Received drop from level ${fromLevel} to level ${this.level}`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.INFO);

    // Level check.
    if ((fromLevel != undefined) && (fromLevel <= this.level)) {
      meow(`Level check failed!`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
      return false;
    }

    // Boundary check.
    if (records.length > item.length) {
      meow(`Out of bounds!`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
      return false;
    }

    const newItems: meowBookmarkItem[] = [];

    // Traverse data, assuming they are one-one paired.
    for (let i = 0; i < records.length; i++) {
      // Ignore unknown type.
      const type = records[i].getTypes().join('.');
      if (type != meowBookmarkItemUnifiedType) {
        meow(`Unknown record type: ${type}. Accepts only [${meowBookmarkItemUnifiedType}]!`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
        return false;
      }

      newItems.push(item[i]);
    }

    // Dropped an opened folder
    if (fromLevel != undefined) {
      this.onDropReceivedAnOpenedFolder(fromLevel);
    }

    // Push to the real folder
    try {
      this.folder.children.push(...newItems);
    } catch (e) {
      meow(`Error adding item: ${e}`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
      return false;
    }

    // Clear tunnel
    myApp.dataTunnelForBookmarks = [];

    // Save bookmarks
    this.requestSaveAndBroadcastSync();
    return true;
  }
}

export { BookmarksColumn };

