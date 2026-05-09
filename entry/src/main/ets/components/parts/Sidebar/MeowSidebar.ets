import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowManagedSettings } from "../../../hosts/userdata/settings/classes/meowManagedSettings";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooTextButton } from "../../common/MooTextButton";
import { defaultAnimation, getColor, meowThemeColorType, standardSpacing, useEffects } from "../../settings";
import { MeowBookmarksPanel } from "../Bookmarks/Panel";
import { defaultMooSymbolSize, getButtonIcon } from "../../common/constants";
import { SidebarPageType, sidebarContentIconArray, defaultSidebarWidth } from "./constants";
import { SlotEditButton } from "../../common/SlotEditButton";
import { HistoryPanel } from "../History/Panel";
import { MooTextModifier } from "../../common/MooTextModifier";

@ComponentV2
struct MeowSidebar {
  @Param @Require myLayout: meowLayout;
  @Param @Require myUi: meowUiHost;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  // Local
  @Local showAdd: boolean = false;
  @Local isEditing: boolean = false;
  // Render
  @Local render: boolean = false;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      // The panels
      if (this.render) {
        // Look how well they are aligned! Bravo! ヽ（´ー｀）┌
        Column() {
          if (this.myUi.sidebarPage == SidebarPageType.SCRATCHING_BOARD) {
            // TODO: scratching board UI.
          } else if (this.myUi.sidebarPage == SidebarPageType.DOWNLOADS) {
            // TODO: downloads UI.
          } else if (this.myUi.sidebarPage == SidebarPageType.HISTORIES) {
            // History
            HistoryPanel({ myLayout: this.myLayout, allowEdit: false, needPadding: false });
          } else if (this.myUi.sidebarPage == SidebarPageType.BOOKMARKS) {
            // Bookmarks
            MeowBookmarksPanel({ myUi: this.myUi, needPadding: false, panelWidth: this.sidebarWidth, columnWidth: this.sidebarWidth, maxColumn: 1 });
          } else {
            Text(`[${this.myUi.sidebarPage}]`).attributeModifier(new MooTextModifier());
            // TODO: web show url of [this.myUi.sidebarPage]
          }
        }
        .enabled(!this.isEditing)
        .opacity(this.isEditing ? 0.5 : 1)
        .layoutWeight(1)
        .width('100%');
        
        this.buttonRow();
      }
    }
    .onAppear(() => {
      setTimeout(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.render = true;
        });
      }, 10);
    })
    .width(this.sidebarWidth)
    .height('100%');
  }

  /**
   * Button list content.
   */
  @Builder
  buttonRow() {
    List() {
      Repeat(this.mySettings.settingsData[81].value as string[][])
        .each((item: RepeatItem<string[]>) => {
          ListItem() {
            SlotEditButton({
              type: item.item[1],
              myUi: this.myUi,
              param: item.item[1],
              paramIconId: item.item[0],
              hasParam: !sidebarContentIconArray.includes(item.item[1]),
              myOnHold: () => {
                return this.myUi.sidebarPage == item.item[1];
              },
              isEditing: this.isEditing,
              editParamSubmit: (result) => {
                const list = this.mySettings.settingsData[81].value as string[][];
                list[item.index][1] = result;
                this.mySettings.requestSaveToDisk();
              },
              editParamIconIdSubmit: (result) => {
                const list = this.mySettings.settingsData[81].value as string[][];
                list[item.index][0] = result;
                this.mySettings.requestSaveToDisk();
              },
              clickAction: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.myUi.sidebarPage = item.item[1];
                });
                this.mySettings.setByIndex(83, this.myUi.sidebarPage);
              },
              requestDelete: () => {
                const list = this.mySettings.settingsData[81].value as string[][];
                animateToImmediately(defaultAnimation(), () => {
                  list.splice(item.index, 1);
                });
                this.mySettings.requestSaveToDisk();
              }
            });
          };
        })
        .onMove((from: number, to: number) => {
          // Move
          const list = this.mySettings.settingsData[81].value as string[][];
          const item = list[from];
          list.splice(from, 1);
          list.splice(to, 0, item);
          this.mySettings.requestSaveToDisk();
        });

      // Add button
      if (this.isEditing) {
        ListItem() {
          MooTextButton({
            text: $r('app.string.General_new'),
            clickAction: () => {
              this.showAdd = !this.showAdd;
            }
          });
        }
        .opacity(0.75)
        .bindContextMenu(this.showAdd, this.addMenuBuilder(), {
          aboutToDisappear: () => {
            this.showAdd = false;
          },
          backgroundColor: useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY)
        });
      } else {
        ListItem() {
          Text('|').attributeModifier(new MooTextModifier()).height(defaultMooSymbolSize).opacity(0.5).padding({ left: standardSpacing, right: standardSpacing }); // Spacing
        };
      }

      // Edit toggle button
      ListItem() {
        MooSymbolButton({
          icon: this.isEditing ? $r('sys.symbol.square_and_pencil_fill') : $r('sys.symbol.square_and_pencil'),
          onHold: this.isEditing,
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.isEditing = !this.isEditing;
            });
          }
        });
      };
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
    .height(defaultMooSymbolSize);
  }

  /**
   * The menu content used to add new sidebar button.
   */
  @Builder
  addMenuBuilder() {
    List() {
      Repeat(sidebarContentIconArray)
        .each((obj: RepeatItem<string>) => {
          ListItem() {
            MooSymbolButton({
              icon: getButtonIcon(obj.item, $r('sys.symbol.link')), clickAction: () => {
                const list = this.mySettings.settingsData[81].value as string[][];
                animateToImmediately(defaultAnimation(), () => {
                  list.push(['', obj.item]);
                });
                this.mySettings.requestSaveToDisk();
              }
            });
          };
        });
      ListItem() {
        MooSymbolButton({
          icon: $r('sys.symbol.link'), clickAction: () => {
            const list = this.mySettings.settingsData[81].value as string[][];
            animateToImmediately(defaultAnimation(), () => {
              list.push(['link', '']);
            });
            this.mySettings.requestSaveToDisk();
          }
        });
      };
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('auto')
    .height('auto');
  }

  /**
   * The width of the sidebar.
   */
  get sidebarWidth() {
    return this.myLayout.wideMode ? defaultSidebarWidth : (this.myLayout.width - 2 * standardSpacing) * 0.9;
  }
}

export { MeowSidebar };
