import { LengthMetrics } from '@kit.ArkUI';
import { defaultInnerRadius, defaultMenuItemRadius } from '../../catstypicalframework/utils/ui';
import { defaultAnimation, getColor, meowThemeColorType, standardSpacing, isPreferRightHand, useEffects } from '../settings';
import { StringPairArrayItem } from './MooStringPairArrayItem';
import { MooTextModifier } from './MooTextModifier';

@ComponentV2
struct MooStringPairArrayList {
  // Configs
  @Param @Once allowSelect: boolean = false;
  @Param @Once defaultItem: string[] = ['label', 'link'];
  // Data
  @Param selectedIndex: number = -1;
  @Param array: string[][] = []; // The list.
  // Events
  @Event onEdited: (index: number, newValue: string[]) => void;
  @Event onNew: () => void;
  @Event onDelete: (index: number) => void;
  @Event onSelect: (newSelected: number) => void;
  @Event requestResetSelected: () => void; // Called when the selected index needs to be reset. E.g. when the item selected is deleted.

  build() {
    Scroll() {
      Flex({
        wrap: isPreferRightHand() ? FlexWrap.WrapReverse : FlexWrap.Wrap,
        space: { main: LengthMetrics.vp(standardSpacing * 0.75), cross: LengthMetrics.vp(standardSpacing * 0.75) },
        alignItems: ItemAlign.Center
      }) {
        // The fixed default item
        StringPairArrayItem({
          isSelected: this.selectedIndex == -1,
          allowSelect: this.allowSelect,
          item: this.defaultItem,
          index: -1,
          allowEdit: false,
          onSelect: (n) => {
            this.onSelect(n);
          }
        });

        // Main list
        Repeat(this.array)
          .each((item) => {
            StringPairArrayItem({
              isSelected: this.selectedIndex == item.index,
              item: item.item,
              index: item.index,
              allowSelect: this.allowSelect,
              allowEdit: true,
              onEdited: (newValues) => {
                // Notice upper level.
                this.onEdited(item.index, newValues);
              },
              onDelete: (index) => {
                if (this.selectedIndex == index) {
                  this.requestResetSelected();
                }
                this.onDelete(index);
              },
              onSelect: (n) => {
                this.onSelect(n);
              }
            });
          })
          .key((item) => item[0] + '\\' + item[1]);

        // New item button
        Row() {
          Text($r('app.string.General_new')).attributeModifier(new MooTextModifier())
            .padding(standardSpacing * 0.75)
            .borderRadius(defaultMenuItemRadius)
            .hoverEffect(HoverEffect.Highlight)
            .onClick(() => {
              animateToImmediately(defaultAnimation(), () => {
                this.onNew();
              });
            });
        }.justifyContent(FlexAlign.End).width('100%');
      };
    }
    .padding(standardSpacing * 0.75)
    .backgroundColor(useEffects() ? getColor(meowThemeColorType.PRIMARY) : getColor(meowThemeColorType.SECONDARY))
    .border({ width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius })
    .constraintSize({ maxHeight: 240 })
    .height('auto')
    .width('auto')
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring);
  }
}

export { MooStringPairArrayList };
