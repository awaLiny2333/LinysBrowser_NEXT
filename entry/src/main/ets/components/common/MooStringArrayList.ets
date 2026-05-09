import { defaultInnerRadius } from "../../catstypicalframework/utils/ui";
import { meowThemeColorType, standardSpacing } from "../constants";
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from "../settings";
import { MooStringItem } from "./MooStringItem";
import { MooTextButton } from "./MooTextButton";

@ComponentV2
struct MooStringArrayList {
  // Config
  @Param @Once enableLabelField: boolean = true;
  // Data
  @Param @Require list: string[];
  // Local
  // @Local selected: Set<number> = new Set();
  // Events
  @Event onEdited: (index: number, newValue: string) => void;
  @Event onDelete: (index: number) => void;
  @Event onNew: () => void;

  build() {
    List({ space: standardSpacing * 0.75 }) {
      Repeat(this.list)
        .each((item) => {
          ListItem() {
            MooStringItem({
              allowSelect: true,
              allowEdit: true,
              isSelected: false,
              // isSelected: this.selected.has(item.index),
              index: item.index,
              enableLabelField: this.enableLabelField,
              enableLinkField: false,
              item: [item.item, ''],
              onEdited: (newValues) => {
                this.onEdited(item.index, newValues[0]);
              },
              onDelete: (index) => {
                this.onDelete(index);
              },
              // onSelect: (index) => {
              //   if (this.selected.has(index)) {
              //     this.selected.delete(index);
              //   } else {
              //     this.selected.add(index);
              //   }
              // }
            });
          };
        })
        .virtualScroll(); // Lazy!

      // New item button
      ListItem() {
        MooTextButton({
          text: $r('app.string.General_new'),
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.onNew();
            });
          }
        });
      };
    }
    .alignListItem(isPreferRightHand() ? ListItemAlign.End : ListItemAlign.Start)
    .padding(standardSpacing * 0.75)
    .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
    .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
    .width('auto')
    .height('auto');
  }
}

export { MooStringArrayList };
