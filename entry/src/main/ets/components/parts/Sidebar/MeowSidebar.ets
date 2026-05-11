import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { SymbolButton } from "../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooTextButton } from "../../common/MooTextButton";
import { MooTextInputV2 } from "../../common/MooTextInputV2";
import { MooTextModifier } from "../../common/MooTextModifier";
import { SlotEditButton, symbolIconOptions } from "../../common/SlotEditButton";
import { defaultMooSymbolSize, defaultSidebarShrunkWidth, defaultSidebarWidth, getButtonIcon, meowThemeColorType, sidebarContentIconArray, sidebarContentIconSet, standardSpacing, UnifiedButtonsType } from "../../constants";
import { defaultAnimation, getColor, getMySettings, sideAreaShrinkButton, sidebarButtons, sidebarShouldBeOnTheRight, titleBarPositionBottom, useEffects } from "../../settings";
import { MeowBookmarksPanel } from "../Bookmarks/Panel";
import { HistoryPanel } from "../History/Panel";

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

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      if (this.showShrinkButton && !titleBarPositionBottom()) {
        this.shrinkButton();
      }
      // The panels
      if (this.render) {
        // Look how well they are aligned! Bravo! ヽ（´ー｀）┌
        Column() {
          if (this.myUi.sidebarPage == UnifiedButtonsType.SCRATCHING_BOARD) {
            // TODO: scratching board UI.
          } else if (this.myUi.sidebarPage == UnifiedButtonsType.DOWNLOADS) {
            // TODO: downloads UI.
          } else if (this.myUi.sidebarPage == UnifiedButtonsType.HISTORIES) {
            // History
            HistoryPanel({
              myLayout: this.myLayout, allowEdit: false, needPadding: false, lite: true, autoFocus: false, requestVisit: (url) => {
                this.myUi.submitSearchOrLoad(url);
              }
            });
          } else if (this.myUi.sidebarPage == UnifiedButtonsType.BOOKMARKS) {
            // Bookmarks
            MeowBookmarksPanel({
              myUi: this.myUi, needPadding: false, panelWidth: this.sidebarWidth, columnWidth: this.sidebarWidth, maxColumn: 1, requestVisit: (url) => {
                this.myUi.submitSearchOrLoad(url);
              }
            });
          } else {
            Text(`[${this.myUi.sidebarPage}]`).attributeModifier(new MooTextModifier());
            // TODO: web show url of [this.myUi.sidebarPage]
          }
        }
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
    .width(this.myUi.sideAreaShrunk && !this.myUi.sideAreaShrinkBlock && this.myLayout.wideMode ? defaultSidebarShrunkWidth : this.sidebarWidth)
    .height('100%');
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
          this.shrinkButton();
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
                this.myUi.sideAreaShrinkBlock = true;
              },
              didHideMenu: () => {
                this.myUi.sideAreaShrunk = false;
                setTimeout(() => {
                  animateToImmediately(defaultAnimation(), () => {
                    this.myUi.sideAreaShrinkBlock = false;
                  });
                }, 10);
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
          aboutToDisappear: () => {
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

  @Builder
  shrinkButton() {
    SymbolButton({
      icon: this.myUi.sideAreaShrunk ? $r('sys.symbol.arrow_up_left_and_arrow_down_right') : $r('sys.symbol.arrow_down_right_and_arrow_up_left'),
      clickAction: () => {
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.sideAreaShrunk = !this.myUi.sideAreaShrunk;
        });
      }
    });
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
