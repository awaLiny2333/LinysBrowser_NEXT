import { meow, meowLevel } from '../../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius, defaultRoundedRadius } from '../../../../catstypicalframework/utils/ui';
import { meowBookmarkItem } from '../../../../hosts/bookmarks/classes/meowBookmarkItem';
import { meowFlexOptions } from '../../../common/constants';
import { SymbolButton } from '../common/SymbolButton';
import { UniContentCard } from '../../../common/UniContentCard';

@ComponentV2
export struct SimpleBookmarksShowcase {
  @Param updateFlag: boolean | undefined = undefined;
  @Param @Require folder: meowBookmarkItem;
  @Local openedFolderStack: meowBookmarkItem[] = [this.folder]; // Including currently opened folder
  @Local currentFolderChildren: meowBookmarkItem[] = Array.from(this.folder.children);
  @Param saveAction: () => void = () => {
  };

  build() {
    UniContentCard({ roundedRadius: defaultInnerRadius }) {
      PathDisplay({
        folderStack: this.openedFolderStack,
        onClickAction: (item) => {
          if (!item.isFolder) {
            return;
          } // How could this happen?

          const index = this.openedFolderStack.findIndex((folder) => folder == item);

          if (index == -1) {
            meow(`Rejected to open folder ${item.name} as there is something wrong with the index. Falling back to root.`, 'SimpleBookmarksShowcase', meowLevel.WARN);
            this.openedFolderStack = [this.folder];
            this.currentFolderChildren = Array.from(this.folder.children);
            return;
          } // Go back to root. Again, how could this happen?

          // Go back to that layer
          this.openedFolderStack.splice(index + 1);
          this.currentFolderChildren = Array.from((item as meowBookmarkItem).children);
          meow(`Opening folder: ${item.name}`, 'SimpleBookmarksShowcase', meowLevel.INFO);
        }
      });

      // List of children under currentFolder
      List() {
        Repeat(this.currentFolderChildren)
          .each((repeatItem) => {
            ListItem() {
              BookmarksItem({
                item: repeatItem.item,
                clickAction: () => {
                  if (repeatItem.item.isFolder) {
                    this.openedFolderStack.push(repeatItem.item as meowBookmarkItem);
                    this.currentFolderChildren = Array.from((repeatItem.item as meowBookmarkItem).children);
                    meow(`Opening folder: ${repeatItem.item.name}`, 'SimpleBookmarksShowcase', meowLevel.INFO);
                  } else {
                    meow(`Opening bookmark: ${repeatItem.item.name}`, 'SimpleBookmarksShowcase', meowLevel.INFO);
                  }
                },
                saveAction: () => {
                  this.saveAction();
                  this.refreshCurrent();
                },
                deleteAction: () => {
                  try {
                    this.folder.children.splice(repeatItem.index, 1);
                    this.saveAction();
                  } catch (e) {
                    meow(`Failed to delete item #${repeatItem.index} in folder ${this.folder.name}: ${e}`, 'SimpleBookmarksShowcase', meowLevel.ERROR);
                  }
                  this.refreshCurrent();
                }
              });
            };
          })
          .key((item) => `${item.name}/${item.date_modified}`)
          .onMove((from: number, to: number) => {
            try {
              // Modify the real object.
              const item = this.openedFolderStack[this.openedFolderStack.length - 1].children.splice(from, 1);
              this.openedFolderStack[this.openedFolderStack.length - 1].children.splice(to, 0, item[0]);
              // Modifying display.
              this.currentFolderChildren.splice(from, 1);
              this.currentFolderChildren.splice(to, 0, item[0]);
              // Save
              this.saveAction();
            } catch (e) {
              meow(`Failed to move item: ${e}`, 'SimpleBookmarksShowcase', meowLevel.ERROR);
            }
          });
      }
      .width('100%')
      .height(200)
      .scrollBar(BarState.Auto);

      Flex(meowFlexOptions) {
        Button('New Folder')
          .onClick(() => {
            this.folder.addFolder('New Folder nya');
            this.saveAction();
            this.refreshCurrent();
          });
        Button('New Bookmark')
          .onClick(() => {
            this.folder.addBookmark('New Bookmark nya', 'meo.w');
            this.saveAction();
            this.refreshCurrent();
          });
      };
    };
  }

  /**
   * In some cases, the root folder is empty when this is rendered.
   * this.folder is replaced later after it is parsed, but that would be too late.
   * At that time, openedFolderStack and currentFolderChildren are already set and they won't be refreshed.
   * That's why we need to do this manually.
   */
  @Monitor('folder')
  refreshRoot() {
    this.openedFolderStack = [this.folder];
    this.currentFolderChildren = Array.from(this.folder.children);
    meow(`Refreshing root folder: ${this.folder.name}`, 'SimpleBookmarksShowcase][refreshRoot', meowLevel.INFO);
  }

  @Monitor('updateFlag')
  refreshCurrent() {
    this.currentFolderChildren = Array.from(this.openedFolderStack[this.openedFolderStack.length - 1].children);
    meow(`Refreshing current folder: ${this.folder.name}`, 'SimpleBookmarksShowcase][refreshCurrent', meowLevel.INFO);
  }
}

@ComponentV2
struct BookmarksItem {
  @Param @Require item: meowBookmarkItem;
  @Event clickAction: () => void;
  @Event saveAction: () => void
  @Event deleteAction: () => void
  // Info
  @Local label: string = this.item.name;
  // Editing
  @Local isEditing: boolean = false;
  @Local labelEditing: string = this.item.name;
  @Local urlEditing: string = this.item.url;

  build() {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        // Edit button
        SymbolButton({
          icon: this.isEditing ? $r('sys.symbol.chevron_up') : $r('sys.symbol.pencil_and_card'),
          clickAction: () => {
            this.isEditing = !this.isEditing;
          }
        });
        // Label
        Text(`${this.item.isFolder ? '󰃅  ' : ''}${this.label}`);
      }
      .padding(this.isEditing ? {} : { left: 5, right: 5, top: 3, bottom: 3 })
      .borderRadius(defaultInnerRadius)
      .hoverEffect(this.isEditing ? undefined : HoverEffect.Highlight)
      .onClick(() => {
        this.clickAction();
      });
      if (this.isEditing) {
        Row({ space: 8 }) {
          Text('  󰈈 ');
          TextInput({ text: this.labelEditing })
            .onChange((value) => {
              this.labelEditing = value;
            })
            .onSubmit(() => {
              this.item.name = this.labelEditing;
              this.label = this.item.name;
              this.saveAction();
            })
            .width('auto');
        };
        if (!this.item.isFolder) {
          Row({ space: 8 }) {
            Text('  󰊡 ');
            TextInput({ text: this.urlEditing })
              .onChange((value) => {
                this.urlEditing = value;
              })
              .onSubmit(() => {
                this.item.url = this.urlEditing;
                this.saveAction();
              })
              .width('auto');
          };
        }
        SymbolButton({
          icon: $r('sys.symbol.trash'),
          clickAction: () => {
            this.deleteAction();
          }
        });
      }
    }
    .padding(this.isEditing ? 8 : 0)
    .backgroundColor(this.isEditing ? $r('app.color.blur_background') : undefined)
    .border(this.isEditing ? { width: 1, radius: defaultRoundedRadius, color: $r('sys.color.icon_fourth') } : { width: 0 })
    .alignItems(HorizontalAlign.Start);
  }

  /**
   * Refreshes url, label and labelEditing
   */
  @Monitor('item')
  refreshLabelUrl() {
    this.label = this.item.name;
    this.labelEditing = this.item.name;
    this.urlEditing = this.item.url;
    this.isEditing = false;
  }
}

@ComponentV2
struct PathDisplay {
  @Param @Require folderStack: meowBookmarkItem[];
  @Event onClickAction: (item: meowBookmarkItem) => void

  build() {
    Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
      Repeat(this.folderStack)
        .each((repeatItem) => {
          Text(`${repeatItem.item.name}`)
            .borderRadius(defaultInnerRadius)
            .padding(5)
            .hoverEffect(HoverEffect.Highlight)
            .onClick(() => {
              this.onClickAction(repeatItem.item);
            });

          Text(`󰃙`);
        })
        .key((item) => JSON.stringify(item));
    };
  }
}
