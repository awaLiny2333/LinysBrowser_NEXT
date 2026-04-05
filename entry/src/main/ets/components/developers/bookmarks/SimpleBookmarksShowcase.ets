import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { defaultInnerRadius } from '../../../catstypicalframework/utils/ui';
import { meowBookmarkItem } from '../../../hosts/bookmarks/classes/meowBookmarkItem';
import { SymbolButton } from '../common/SymbolButton';
import { UniContentCard } from '../common/UniContentCard';

@ComponentV2
export struct SimpleBookmarksShowcase {
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
                }
              });
            };
          })
          .key((item) => JSON.stringify(item))
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
}

@ComponentV2
struct BookmarksItem {
  @Param @Require item: meowBookmarkItem;
  @Param clickAction: () => void = () => {
  };

  build() {
    Row({ space: 4 }) {
      // Edit button
      SymbolButton({
        icon: $r('sys.symbol.pencil_and_card'),
        clickAction: () => {
          meow(`Editing bookmark: ${this.item.name}`, 'SimpleBookmarksShowcase][BookmarksItem', meowLevel.INFO);
        }
      });
      // Label
      Text(`${this.item.isFolder ? ' 󰃅  ' : ''}${this.item.name}`);
    }
    .padding({ left: 5, right: 5, top: 3, bottom: 3 })
    .borderRadius(defaultInnerRadius)
    .hoverEffect(HoverEffect.Highlight)
    .onClick(() => {
      this.clickAction();
    });
  }
}

@ComponentV2
struct PathDisplay {
  @Param @Require folderStack: meowBookmarkItem[];
  @Param onClickAction: (item: meowBookmarkItem) => void = () => {
  };

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
