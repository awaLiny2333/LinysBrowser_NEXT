import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import mooMenuButton from "../../../components/common/MooMenuButton";
import { MooSymbolButton } from "../../../components/common/MooSymbolButton";
import { MooTextButton } from "../../../components/common/MooTextButton";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { buttonIconArray, generalButtonHeight, getButtonIcon, meowButtonsType } from "../../../components/parts/Buttons/constants";
import { defaultAnimation, getColor, isPreferRightHand, meowThemeColorType, standardSpacing, useEffects } from "../../../components/settings";

@ComponentV2
struct ButtonSlot {
  // Params
  @Param @Require buttons: meowButtonsType[];
  @Param @Require desc: ResourceStr;
  // Local
  @Local showAdd: boolean = false;
  // Events
  @Event onChange: () => void;

  build() {
    Column({ space: standardSpacing * 0.75 }) {
      Text(this.desc).attributeModifier(new MooTextModifier()).padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 });

      // List
      List({ space: standardSpacing * 0.125 }) {
        Repeat(this.buttons)
          .each((obj: RepeatItem<meowButtonsType>) => {
            ListItem() {
              ButtonSlotButton({
                item: obj.item,
                requestDelete: () => {
                  animateToImmediately(defaultAnimation(), () => {
                    this.buttons.splice(obj.index, 1);
                  });
                  this.onChange();
                }
              });
            };
          })
          .onMove((from: number, to: number) => {
            const temp = this.buttons[from];
            this.buttons.splice(from, 1);
            this.buttons.splice(to, 0, temp); // TODO: Does this causes 2 refreshes on the UI? Is this the source of the flashes?
            this.onChange();
          });

        ListItem() {
          // New item button
          MooTextButton({
            text: $r('app.string.General_new'),
            clickAction: () => {
              animateToImmediately(defaultAnimation(), () => {
                this.showAdd = !this.showAdd;
              });
            }
          })
            .opacity(0.75)
            .bindContextMenu(this.showAdd, this.addMenuBuilder(), {
              aboutToDisappear: () => {
                this.showAdd = false;
              },
              backgroundColor: useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY)
            });
        };
      }
      .padding({ left: standardSpacing * 0.75, right: standardSpacing * 0.75 })
      .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
      .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Horizontal)
      .height(generalButtonHeight + 2 * standardSpacing * 0.75)
      .width('auto')
      .scrollBar(BarState.Off);
    }
    .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start);
  }

  @Builder
  addMenuBuilder() {
    List() {
      Repeat(buttonIconArray)
        .each((obj: RepeatItem<[meowButtonsType, Resource]>) => {
          ListItem() {
            MooSymbolButton({
              icon: obj.item[1], clickAction: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.buttons.push(obj.item[0]);
                });
                this.onChange();
              }
            });
          };
        });
    }
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('auto')
    .height('auto');
  }
}

export { ButtonSlot };

@ComponentV2
struct ButtonSlotButton {
  @Param @Require item: meowButtonsType;
  @Local isMenu: boolean = false;
  // Events
  @Event requestDelete: () => void;

  build() {
    MooSymbolButton({
      icon: getButtonIcon(this.item), clickAction: () => {
        this.isMenu = !this.isMenu;
      }
    })
      .bindContextMenu(this.isMenu, this.contextMenuBuilder(), {
        aboutToDisappear: () => {
          this.isMenu = false;
        },
        backgroundColor: useEffects() ? undefined : getColor(meowThemeColorType.PRIMARY)
      });
  }

  @Builder
  contextMenuBuilder() {
    Column() {
      mooMenuButton({
        text: $r('app.string.General_delete'),
        clickAction: () => {
          this.requestDelete();
        }
      });
    }
    .alignItems(HorizontalAlign.Start);
  }
}
