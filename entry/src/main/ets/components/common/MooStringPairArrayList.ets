import { defaultInnerRadius, defaultMenuItemRadius } from '../../catstypicalframework/utils/ui';
import { defaultAnimation, getColor, meowThemeColorType, summarizedPreferRightHand, standardSpacing, useEffects } from './constants';
import { MooCapsuleButton } from './MooCapsuleButton';
import { MooSymbolButtonSmall } from './MooSymbolButtonSmall';
import { MooTextInputV2 } from './MooTextInputV2';
import { MooTextModifier } from './MooTextModifier';
import { LengthMetrics } from '@kit.ArkUI';
import { UniRowOfCapsuleButtons } from './UniRowOfCapsuleButtons';

@ComponentV2
struct MooStringPairArrayList {
  // Configs
  @Param @Once allowSelect: boolean = false;
  @Param @Once defaultItem: string[] = ['label', 'link'];
  // Data
  @Param selectedIndex: number = -1;
  @Param array: string[][] = []; // The list.
  // Events
  @Event onEdit: (index: number, newValue: string[]) => void;
  @Event onSelect: (newSelected: number) => void;

  build() {
    Scroll() {
      Flex({
        wrap: summarizedPreferRightHand() ? FlexWrap.WrapReverse : FlexWrap.Wrap,
        space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) },
        alignItems: ItemAlign.Center
      }) {
        // The fixed default item
        StringPairArrayItem({
          selectedIndex: this.selectedIndex,
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
              selectedIndex: this.selectedIndex,
              item: item.item,
              index: item.index,
              allowSelect: this.allowSelect,
              allowEdit: true,
              onEdit: (index, newValue) => {
                this.onEdit(index, newValue);
              },
              onDelete: (index) => {
                this.array.splice(index, 1);
                this.onEdit(index, []);
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
                this.array.push(Array.from(this.defaultItem));
                this.onEdit(this.array.length - 1, this.array[this.array.length - 1]);
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

@ComponentV2
struct StringPairArrayItem {
  // Config
  @Param @Require @Once allowSelect: boolean;
  @Param @Require @Once allowEdit: boolean;
  // Data
  @Param @Require selectedIndex: number;
  @Param @Require index: number;
  @Param @Require item: string[];
  @Local editingLabel: string = this.item[0];
  @Local editingLink: string = this.item[1];
  // Events
  @Event onEdit: (index: number, newValue: string[]) => void;
  @Event onSelect: (selectedIndex: number) => void;
  @Event onDelete: (index: number) => void;
  // UI
  @Local displayLabel: string = this.item[0];
  @Local isEditing: boolean = false;

  build() {
    Column({ space: standardSpacing }) {
      // Label
      Row({ space: standardSpacing }) {
        Text(this.displayLabel).attributeModifier(new MooTextModifier()).maxLines(1).constraintSize({ maxWidth: '80%' });
        MooSymbolButtonSmall({
          icon: this.allowEdit
            ? (this.isEditing ? $r('sys.symbol.chevron_down') : $r('sys.symbol.pencil_line'))
            : $r('sys.symbol.archivebox'),
          clickAction: () => {
            if (this.allowEdit) {
              animateToImmediately(defaultAnimation(), () => {
                this.isEditing = !this.isEditing;
              });
            }
          }
        });
      };

      if (this.isEditing) {
        MooTextInputV2({
          icon: $r('sys.symbol.label'),
          text: this.editingLabel,
          onChange: (c) => {
            if (this.editingLabel == c) {
              return;
            }
            this.editingLabel = c;
          },
          onSubmit: () => {
            this.save();
          }
        });

        MooTextInputV2({
          icon: $r('sys.symbol.link'),
          text: this.editingLink,
          onChange: (c) => {
            if (this.editingLink == c) {
              return;
            }
            this.editingLink = c;
          },
          onSubmit: () => {
            this.save();
          }
        });

        UniRowOfCapsuleButtons() {
          MooCapsuleButton({
            text: $r('app.string.General_save'),
            clickAction: () => {
              this.save();
            },
            needDoubleConfirm: true
          });
          MooCapsuleButton({
            text: $r('app.string.General_delete'),
            clickAction: () => {
              animateToImmediately(defaultAnimation(), () => {
                this.isEditing = false;
                this.onDelete(this.index);
              });
            },
            needDoubleConfirm: true
          });
        };
      }
    }
    .border(this.imSelected()
      ? { width: 2, color: getColor(meowThemeColorType.FONT), radius: defaultMenuItemRadius }
      : { width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultMenuItemRadius })
    .animation(defaultAnimation())
    .alignItems(HorizontalAlign.Start)
    .hoverEffect(this.allowSelect ? HoverEffect.Highlight : undefined)
    .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
    .padding(!this.isEditing
      ? { left: standardSpacing * 1.5, right: standardSpacing * 0.5, top: standardSpacing * 0.5, bottom: standardSpacing * 0.5 }
      : { left: standardSpacing * 1.5, right: standardSpacing * 1.5, top: standardSpacing * 0.5, bottom: standardSpacing * 1.5 })
    .onClick(() => {
      if (this.allowSelect) {
        this.onSelect(this.index);
      }
    });
  }

  /**
   * Check if the item is selected.
   * @returns True if the item is selected, false otherwise.
   */
  imSelected() {
    return this.selectedIndex == this.index;
  }

  /**
   * Save the edited item.
   */
  save() {
    this.displayLabel = this.editingLabel;
    this.item[0] = this.editingLabel;
    this.item[1] = this.editingLink;
    animateToImmediately(defaultAnimation(), () => {
      this.isEditing = false;
    });
    this.onEdit(this.index, this.item);
  }
}