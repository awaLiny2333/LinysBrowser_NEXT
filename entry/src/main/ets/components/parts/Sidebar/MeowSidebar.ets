import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import lazy { MooSymbolButton } from "../../common/MooSymbolButton";
import lazy { MooTextButton } from "../../common/MooTextButton";
import lazy { MooTextInputV2 } from "../../common/MooTextInputV2";
import lazy { MooTextModifier } from "../../common/MooTextModifier";
import lazy { SlotEditButton, symbolIconOptions } from "../../common/SlotEditButton";
import { defaultMooSymbolSize, defaultSidebarShrunkWidth, defaultSidebarWidth, getButtonIcon, meowThemeColorType, sidebarContentIconArray, sidebarContentIconSet, standardSpacing, UnifiedButtonsType } from "../../constants";
import { defaultAnimation, getColor, getMySettings, sideAreaShrinkButton, sidebarButtons, sidebarShouldBeOnTheRight, titleBarPositionBottom, useEffects } from "../../settings";
import lazy { MeowBookmarksPanel } from "../Bookmarks/Panel";
import { DownloadsPanel } from "../Downloads/Panel";
import lazy { HistoryPanel } from "../History/Panel";
import lazy { ScratchingBoardPanel } from "../ScratchingBoard/Panel";
import lazy { shrinkButton } from "./SidebarShrinkButton";

@ComponentV2
struct MeowSidebar {
  @Param @Require myLayout: meowLayout;
  @Param @Require myUi: meowUiHost;
  // Local
  @Local showAdd: boolean = false;
  @Local isEditing: boolean = false;
  @Local theList: [string, string][] = sidebarButtons(); // theList would get directly the address, so all modifications are 通透的!
  // Render
  @Local render: boolean = false;
  // Events
  @Event onDropSidebar: () => void;
  @Event onItemDragStart: () => void;
  @Event onDragEnterSidebar: () => void;
  @Event onDragLeaveSidebar: () => void;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      if (this.showShrinkButton && !titleBarPositionBottom()) {
        shrinkButton(this.myUi);
      }
      // The panels
      if (this.render) {
        // Look how well they are aligned! Bravo! ヽ（´ー｀）┌
        Column() {
          if (this.myUi.sidebarPage == UnifiedButtonsType.SCRATCHING_BOARD) {
            ScratchingBoardPanel({ myUi: this.myUi, needPadding: false });
          } else if (this.myUi.sidebarPage == UnifiedButtonsType.DOWNLOADS) {
            DownloadsPanel({
              needPadding: false
            });
          } else if (this.myUi.sidebarPage == UnifiedButtonsType.HISTORIES) {
            // History
            HistoryPanel({
              myLayout: this.myLayout, allowEdit: false, needPadding: false, lite: true, autoFocus: false,
              requestVisit: (url) => {
                this.genericRequestVisit(url);
              },
            });
          } else if (this.myUi.sidebarPage == UnifiedButtonsType.BOOKMARKS) {
            // Bookmarks
            MeowBookmarksPanel({
              myUi: this.myUi, needPadding: false, panelWidth: this.sidebarWidth, columnWidth: this.sidebarWidth, maxColumn: 1,
              requestVisit: (url) => {
                this.genericRequestVisit(url);
              },
              onItemDragStart: () => {
                this.onItemDragStart();
              },
              onDropColumn: () => {
                this.onDropSidebar();
              },
              onDragEnterColumn: () => {
                this.onDragEnterSidebar();
              },
              onDragLeaveColumn: () => {
                this.onDragLeaveSidebar();
              }
            });
          } else {
            Text(`[${this.myUi.sidebarPage}]`).attributeModifier(new MooTextModifier());
            // TODO: web show url of [this.myUi.sidebarPage]
          }
        }
        .justifyContent(FlexAlign.End)
        .enabled(!this.isEditing)
        .opacity(this.isEditing ? 0.5 : 1)
        .layoutWeight(1)
        .width(this.sidebarWidth);

        this.buttonRow();
      }
    }
    .onAppear(() => {
      setTimeout(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.render = true;
        });
      }, 50);
    })
    .alignItems(sidebarShouldBeOnTheRight() ? HorizontalAlign.Start : HorizontalAlign.End)
    .width(this.myUi.sideAreaShrunkSummarized && this.myLayout.wideMode ? defaultSidebarShrunkWidth : this.sidebarWidth)
    .height('100%');
  }

  genericRequestVisit(url: string) {
    this.myUi.submitSearchOrLoad(url);
  }

  /**
   * The width of the sidebar.
   */
  get sidebarWidth() {
    return this.myLayout.wideMode ? defaultSidebarWidth : (this.myLayout.width - 2 * standardSpacing) * 0.9;
  }

  /**
   * Button list content.
   */
  @Builder
  buttonRow() {
    List() {
      // Shrink button
      if (this.showShrinkButton && titleBarPositionBottom()) {
        ListItem() {
          shrinkButton(this.myUi);
        };
      }

      Repeat(this.theList)
        .each((item: RepeatItem<string[]>) => {
          ListItem() {
            SlotEditButton({
              type: item.item[1],
              extraParam: item.item[1],
              extraIcon: item.item[0],
              isEditing: this.isEditing,
              hasParam: !sidebarContentIconSet.has(item.item[1]),
              myOnHold: () => {
                return this.myUi.sidebarPage == item.item[1];
              },
              editParamSubmit: (result) => {
                this.theList[item.index][1] = result;
                getMySettings().requestSaveToDisk();
              },
              clickAction: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.myUi.sidebarPage = item.item[1];
                });
                getMySettings().setByIndex(83, this.myUi.sidebarPage);
              },
              requestDelete: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.theList.splice(item.index, 1);
                });
                getMySettings().requestSaveToDisk();
              },
              aboutToShowMenu: () => {
                this.myUi.sideAreaShrinkBlock_menu = true;
              },
              didHideMenu: () => {
                this.myUi.sideAreaShrunkExpect = false;
                this.myUi.sideAreaShrinkBlock_menu = false;
              },
              menuExtra: sidebarContentIconSet.has(item.item[1]) ? undefined : () => {
                this.iconSelect(item);
              }
            });
          };
        })
        .onMove((from: number, to: number) => {
          // Move
          const item = this.theList[from];
          this.theList.splice(from, 1);
          this.theList.splice(to, 0, item);
          getMySettings().requestSaveToDisk();
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
          aboutToAppear: () => {
            this.myUi.sideAreaShrinkBlock_menu = true;
          },
          onDidDisappear: () => {
            this.myUi.sideAreaShrunkExpect = false;
            this.myUi.sideAreaShrinkBlock_menu = false;
            this.showAdd = false;
          },
          backgroundColor: useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY)
        });
      } else {
        ListItem() {
          Text('|').attributeModifier(new MooTextModifier()).height(defaultMooSymbolSize).opacity(0.5).padding({ left: standardSpacing * 0.7, right: standardSpacing * 0.7 }); // Spacing
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
   * To show shrink button or not.
   */
  get showShrinkButton() {
    return sideAreaShrinkButton() && this.myLayout.wideMode && !this.myUi.showingVerticalTab;
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
                animateToImmediately(defaultAnimation(), () => {
                  this.theList.push(['', obj.item]);
                });
                getMySettings().requestSaveToDisk();
              }
            });
          };
        });
      ListItem() {
        MooSymbolButton({
          icon: $r('sys.symbol.link'), clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.theList.push(['link', '']);
            });
            getMySettings().requestSaveToDisk();
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
   * The panel to select a sidebar button.
   * @param item The item of the button string.
   */
  @Builder
  iconSelect(item: RepeatItem<string[]>) {
    // Icon select
    Flex({ wrap: FlexWrap.Wrap }) {
      Repeat(symbolIconOptions)
        .each((icon) => {
          MooSymbolButton({
            icon: $r('sys.symbol.'.concat(icon.item)),
            clickAction: () => {
              animateToImmediately(defaultAnimation(), () => {
                item.item[0] = icon.item;
              });
              // Will trigger the change event in the text input, so we don't need to request for a save here.
              // getMySettings().requestSaveToDisk();
            }
          });
        });
    }
    .constraintSize({ maxWidth: 10 * defaultMooSymbolSize + standardSpacing + (useEffects() ? 2 : 0) })
    .padding(standardSpacing * 0.5)
    .backgroundColor(getColor(meowThemeColorType.SECONDARY))
    .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') });

    // Other id
    MooTextInputV2({
      text: item.item[0],
      icon: $r('sys.symbol.rename'),
      placeholder: '󰊄',
      autoLength: true,
      onChange: (value) => {
        if (item.item[0] != value) {
          animateToImmediately(defaultAnimation(), () => {
            item.item[0] = value;
          });
        }
        getMySettings().requestSaveToDisk();
      },
    })
      .padding({ left: standardSpacing * 0.5 });
  }
}

export { MeowSidebar };
