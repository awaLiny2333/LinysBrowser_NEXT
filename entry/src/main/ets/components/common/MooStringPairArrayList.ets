import { defaultInnerRadius, defaultMenuItemRadius } from '../../catstypicalframework/utils/ui';
import { defaultAnimation, getColor, meowFlexOptions, meowThemeColorType, standardSpacing, useEffects } from './constants';
import { MooCapsuleButton } from './MooCapsuleButton';
import { MooSymbolButtonSmall } from './MooSymbolButtonSmall';
import { MooTextInputV2 } from './MooTextInputV2';
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
  @Event onEdit: (index: number, newValue: string[]) => void;
  @Event onSelect: (newSelected: number) => void;

  build() {
    // List({ space: 5 }) {
    Scroll() {
      Flex(meowFlexOptions) {
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

        Repeat(this.array)
          .each((item) => {
            StringPairArrayItem({
              selectedIndex: this.selectedIndex,
              item: item.item,
              index: item.index,
              allowSelect: this.allowSelect,
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
  @Param @Require selectedIndex: number;
  @Param @Require item: string[];
  @Param @Require index: number;
  @Param @Once allowEdit: boolean = true;
  @Param @Require allowSelect: boolean;
  // Events
  @Event onEdit: (index: number, newValue: string[]) => void;
  @Event onDelete: (index: number) => void;
  @Event onSelect: (selectedIndex: number) => void;
  // UI
  @Local isEditing: boolean = false;

  build() {
    Column({ space: standardSpacing }) {
      Row({ space: standardSpacing }) {
        Text(this.item[0]).attributeModifier(new MooTextModifier()).maxLines(1).constraintSize({ maxWidth: '80%' });
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
          text: this.item[0], onChange: (c) => {
            if (this.item[0] == c) {
              return;
            }
            this.item[0] = c;
            this.onEdit(this.index, this.item);
          }
        });

        MooTextInputV2({
          icon: $r('sys.symbol.link'),
          text: this.item[1], onChange: (c) => {
            if (this.item[1] == c) {
              return;
            }
            this.item[1] = c;
            this.onEdit(this.index, this.item);
          }
        });

        MooCapsuleButton({
          text: $r('app.string.General_delete'),
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.isEditing = false;
              this.onDelete(this.index);
            });
          },
          doubleConfirm: true
        });
        // .alignSelf(ItemAlign.End);
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

  imSelected() {
    return this.selectedIndex == this.index;
  }
}