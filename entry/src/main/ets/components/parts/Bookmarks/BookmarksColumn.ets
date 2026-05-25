import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { meowAppHost } from '../../../hosts/system/windows/classes/meowAppHost';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
import { getMyApp } from '../../../hosts/system/windows/scripts/helpers';
import { globalMessage, meowAppMessageType } from '../../../hosts/system/windows/scripts/messaging';
import { meowBookmarkItem } from '../../../hosts/userdata/bookmarks/classes/meowBookmarkItem';
import { nowHtmlTimestamp } from '../../../hosts/userdata/bookmarks/scripts/helpers';
import { MooStringItem } from '../../common/MooStringItem';
import { MooSymbolButton } from '../../common/MooSymbolButton';
import { MooTextModifier } from '../../common/MooTextModifier';
import { meowThemeColorType, mooTextType, standardSpacing } from '../../constants';
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
  // Hosts
  @Param @Require myUi: meowUiHost;
  @Local myApp: meowAppHost = getMyApp(); // For event receiving.
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
  @Local somethingDraggingAboveMe: boolean = false;
  // Requests
  @Event requestSaveAndBroadcastSync: () => void; // Request the MeowBookmarksPanel to save changes to disk, and request an app-wide broadcast of refresh to sync bookmarks statuses.
  @Event requestImport: () => void;
  @Event requestExport: () => void;
  // Events (Drag drop)
  @Event onDragEnterColumn: () => void;
  @Event onDragLeaveColumn: () => void;
  @Event onDropColumn: () => void;
  @Event onItemDragStart: () => void;
  // Events (Panel)
  @Event requestSubLevelOpen: (item: meowBookmarkItem) => void; // Open a sub folder
  @Event requestSubLevelClose: () => void; // Close the opening sub folder
  @Event requestCardClose: () => void; // This card is closed
  @Event requestVisit: (url: string) => void;
  @Event onSelect: (item: meowBookmarkItem) => void; // Called when this column folder is selected. For select mode only.

  build() {
    Column({ space: standardSpacing }) {
      Stack({ alignContent: Alignment.Bottom }) {
        this.BookmarksList();
        if (this.somethingDraggingAboveMe) {
          Text($r('app.string.Bookmarks_drop')).attributeModifier(new MooTextModifier(mooTextType.TITLE))
            .width('100%').height('100%').padding(standardSpacing)
            .hitTestBehavior(HitTestMode.Transparent).textAlign(TextAlign.Center);
        }
      }
      .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
      .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
      // .alignItems(VerticalAlign.Bottom)
      .layoutWeight(1);

      this.BottomControl();
    }
    .width(this.columnWidth)
    .animation(defaultAnimation())
    .onDragEnter(() => {
      this.onDragEnterColumn();
      animateToImmediately(defaultAnimation(), () => {
        this.somethingDraggingAboveMe = true;
      });
    })
    .onDragLeave(() => {
      this.onDragLeaveColumn();
      animateToImmediately(defaultAnimation(), () => {
        this.somethingDraggingAboveMe = false;
      });
    })
    .onDrop((event: DragEvent) => {
      this.onDropColumn(); // Simply report to upper level panel. E.g. to notify an extention of the sidebar.
      animateToImmediately(defaultAnimation(), () => {
        this.somethingDraggingAboveMe = false;
      });

      // Deal with the drops
      let records: unifiedDataChannel.UnifiedRecord[];
      try {
        records = event.getData().getRecords();
      } catch (e) {
        meow(`Error handling drag event: ${e}`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
        return;
      }

      // Process after getting the data.
      const result = this.receiveDrop(records);

      // Feedback to determine if the bookmark items are ok to be deleted.
      if (result) {
        event.setResult(DragResult.DRAG_SUCCESSFUL);
        setTimeout(() => {
          this.listScroller.scrollEdge(Edge.Bottom);
        }, 10);
      } else {
        event.setResult(DragResult.DRAG_FAILED);
      }
    });
  }

  getFolderChildren() {
    this.refreshFlag; // To refresh!
    return Array.from(this.folder.children);
  }

  @Monitor('folder')
  refreshRoot() {
    this.refreshFlag = !this.refreshFlag;
  }

  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    if (this.myApp.crossAppMessageTunnel == undefined) {
      return;
    }
    const msg = this.myApp.crossAppMessageTunnel;
    if (msg.type == meowAppMessageType.BOOKMARKS_REFRESH) {
      this.refreshFlag = !this.refreshFlag;
      try {
        if (this.folder.children.indexOf(this.selectedItem) < 0) {
          this.requestSubLevelClose();
        }
      } catch (e) {
        // This won't really happen actually.
      }
    }
  }

  @Builder
  BookmarksList() {
    List({ space: standardSpacing * 0.75, scroller: this.listScroller }) {
      Repeat(this.getFolderChildren())
        .each((item: RepeatItem<meowBookmarkItem>) => {
          ListItem() {
            MooStringItem({
              allowEdit: !this.selectMode,
              clickable: true,
              maxLines: undefined, // Unlimited lines!
              enableLinkField: !item.item.isFolder,
              icon: item.item.isFolder ? '󰃅  ' : '',
              item: this.getLabelLinkItem(item.item),
              index: item.index,
              isSelected: this.selectedItem == item.item,
              clickAction: () => {
                // If is dragging a folder, and the user tries to open the folder that is exactly being dragged, we reject this opening!
                if (this.myApp.dataTunnelForBookmarks?.item == item.item) {
                  meow('Trying to open the folder dragged?? No way!', 'BookmarksColumn][onSelect', meowLevel.WARN);
                  return;
                }
                if (this.selectedItem == item.item) {
                  this.requestSubLevelClose(); // Close this folder
                  return;
                }
                if (item.item.isFolder) {
                  this.requestSubLevelOpen(item.item); // Folder: Should open this folder.
                } else if (!this.selectMode) {
                  this.requestVisit(item.item.url); // Bookmark: Should visit the web site
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
              .opacity((this.selectMode && !item.item.isFolder) || (this.myApp.dataTunnelForBookmarks?.item == item.item) ? 0.5 : 1) // This might be potentially a performance throttle, but it works for now... :P
              .draggable(this.inDragMode && !this.selectMode ? true : undefined)
              .onDragStart((event: DragEvent) => {
                if (this.selectedItem == item.item) {
                  this.requestSubLevelClose();
                }
                // This would call all bookmark panels across all windows to close the folder
                // and therefore ensure that the folder dragged is not an "opened" folder:
                globalMessage(meowAppMessageType.BOOKMARKS_DRAGGED, item.item);
                // Drag.
                this.onItemDragStart();
                this.sendDrag(event, item.item);
              })
              .onDragEnd(() => {
                this.endDrag();
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
    .opacity(this.somethingDraggingAboveMe ? 0.5 : 1)
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
            const autoLabel = `New Bookmark on ${new Date().toLocaleString()}`;
            const canFetch = this.myUi.myTabs.currentTab?.url;
            const label = canFetch ? this.myUi.myTabs.currentTab?.title || autoLabel : autoLabel;
            const link = canFetch ? this.myUi.myTabs.currentTab?.url || '' : '';
            const newBookmark = new meowBookmarkItem(false, label, link);
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
            this.requestCardClose();
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
   * Send drag event.
   * @param event The event to process and be sent.
   * @param item The meowBookmarkItem to be sent in the event.
   */
  sendDrag(event: DragEvent, item: meowBookmarkItem) {
    // Put the item (to be sent) in meowAppHost.

    getMyApp().dataTunnelForBookmarks = { item: item, parent: this.folder };

    // Fill data :P
    let unifiedData = new unifiedDataChannel.UnifiedData();

    if (!item.isFolder) {
      // URL record
      let hyperlinkRecord: unifiedDataChannel.Hyperlink = new unifiedDataChannel.Hyperlink();
      hyperlinkRecord.url = item.url;
      hyperlinkRecord.description = item.title;
      unifiedData.addRecord(hyperlinkRecord);
      // Text in MD
      let textRecord: unifiedDataChannel.PlainText = new unifiedDataChannel.PlainText();
      textRecord.textContent = `[${item.title}](${item.url})`;
      unifiedData.addRecord(textRecord);
    }

    // Application defined bookmark item record
    let bookmarkItemRecord = new unifiedDataChannel.ApplicationDefinedRecord();
    bookmarkItemRecord.applicationDefinedType = meowBookmarkItemUnifiedType;
    unifiedData.addRecord(bookmarkItemRecord);

    // Set!
    event.setData(unifiedData);
  }

  /**
   * Things to do after receiving a unified drop event on this column.
   * @param records The unifiedRecords.
   * @returns True if succeeded, false if failed.
   */
  receiveDrop(records: unifiedDataChannel.UnifiedRecord[]) {
    console.log(' ');
    meow(`onDrop: [${records.length}]`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.WARN);

    // GOAL: verify that this is a drop of meowBookmarkItemUnifiedType.
    // So as long as we find one meowBookmarkItemUnifiedType, this drop is from bookmark folder to bookmark folder.
    // If not, we just pick the addable ones (hyperlinks)
    let legalMeowBookmarkItemUnifiedType = false;
    const usableBookmarks: meowBookmarkItem[] = [];
    for (let i = 0; i < records.length; i++) {
      // Ignore unknown type.
      const type = records[i].getTypes().join('.');
      if (type == meowBookmarkItemUnifiedType) {
        legalMeowBookmarkItemUnifiedType = true;
        meow(`[${i}] Record type: ${type}. Meowy meowBookmarkItemUnifiedType!`, `BookmarksColumn][onDrop][${this.folder.title}`);
      } else if (type == uniformTypeDescriptor.UniformDataType.HYPERLINK) {
        meow(`[${i}] Record type: ${type}. Meowy hyperlink!`, `BookmarksColumn][onDrop][${this.folder.title}`);
        const thisRecord = records[i] as unifiedDataChannel.Hyperlink;
        usableBookmarks.push(new meowBookmarkItem(false, thisRecord.description || 'Meow', thisRecord.url));
      } else {
        meow(`[${i}] Rejected. Unknown record type: ${type}. Accepts only [${meowBookmarkItemUnifiedType}] or [${uniformTypeDescriptor.UniformDataType.HYPERLINK}]!`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
      }
    }

    // ILLEGAL: PUSH USABLE BOOKMARKS (GAINDED FROM HYPERLINKS)

    if (!legalMeowBookmarkItemUnifiedType) {
      // Push the usable links to the folder.
      try {
        if (usableBookmarks.length > 0) {
          this.folder.children.push(...usableBookmarks);
          this.requestSaveAndBroadcastSync();
        } else {
          meow(`No usable bookmarks discovered. No actions taken.`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.WARN);
        }
      } catch (e) {
        meow(`Error adding bookmarks: ${e}`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
      }
      return true;
    }

    // NOW THIS IS A LEGAL DROP FROM FOLDER TO FOLDER!

    // Grab info from AppStatuses
    const pack = getMyApp().dataTunnelForBookmarks;
    if (pack == undefined) {
      meow(`getMyApp().dataTunnelForBookmarks is undefined. Rejected!`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
      return false;
    }

    // Data operations.
    try {
      this.folder.children.push(pack.item); // Push into new folder.
      pack.parent.children.splice(pack.parent.children.indexOf(pack.item), 1); // Remove original! — Delete the item.
    } catch (e) {
      meow(`Error adding item: ${e}`, `BookmarksColumn][onDrop][${this.folder.title}`, meowLevel.ERROR);
      return false;
    }
    this.requestSaveAndBroadcastSync(); // Save bookmarks

    return true;
  }

  /**
   * Called on the end of drag. Clears this.myApp.dataTunnelForBookmarks tunnel.
   */
  endDrag() {
    meow(`onDragEnd! Clear this.myApp.dataTunnelForBookmarks!`, 'BookmarksColumn][onDragEnd', meowLevel.WARN);
    console.log(' ');
    this.myApp.dataTunnelForBookmarks = undefined; // Clear!
  }
}

export { BookmarksColumn };
