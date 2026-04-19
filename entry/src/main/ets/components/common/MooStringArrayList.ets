import { defaultInnerRadius, defaultMenuItemRadius } from "../../catstypicalframework/utils/ui";
import { meowThemeColorType, getColor, standardSpacing, useEffects, defaultAnimation, isPreferRightHand } from "../settings";
import { StringPairArrayItem } from "./MooStringPairArrayItem";
import { MooTextModifier } from "./MooTextModifier";

@ComponentV2
struct MooStringArrayList {
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
            StringPairArrayItem({
              allowSelect: true,
              allowEdit: true,
              isSelected: false,
              // isSelected: this.selected.has(item.index),
              index: item.index,
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
        Text($r('app.string.General_new')).attributeModifier(new MooTextModifier())
          .padding(standardSpacing * 0.75)
          .borderRadius(defaultMenuItemRadius)
          .hoverEffect(HoverEffect.Highlight)
          .onClick(() => {
            animateToImmediately(defaultAnimation(), () => {
              this.onNew();
            });
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