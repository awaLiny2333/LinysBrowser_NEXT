import { defaultItemRadius } from '../../catstypicalframework/utils/ui';
import { standardSpacing,meowThemeColorType } from '../constants';
import { defaultAnimation, getColor, isPreferRightHand, useEffects } from '../settings';
import { MooCapsuleButton } from './MooCapsuleButton';
import { MooSymbolButtonSmall } from './MooSymbolButtonSmall';
import { MooTextInputV2 } from './MooTextInputV2';
import { MooTextModifier } from './MooTextModifier';
import { UniRowOfCapsuleButtons } from './UniRowOfCapsuleButtons';

@ComponentV2
struct MooStringItem {
  // Config
  @Param @Require clickable: boolean;
  @Param @Require allowEdit: boolean;
  @Param enableLabelField: boolean = true;
  @Param enableLinkField: boolean = true; // For use cases like folders, which don't have links.
  @Param maxLines: number | undefined = 1;
  // Data
  @Param @Require isSelected: boolean;
  @Param @Require index: number;
  @Param @Require item: string[];
  @Param icon: ResourceStr = '';
  @Local editingLabel: string = this.item[0];
  @Local editingLink: string = this.item[1];
  // Events
  /**
   * Called when the item is edited.
   * Returns a NEW string[] object that contains the new [label, link] pair.
   * The upper level of this MooStringItem
   * should do the rest of the backward data syncing / assigning jobs!
   */
  @Event onEdited: (newValues: string[]) => void;
  @Event clickAction: (selectedIndex: number) => void;
  @Event onDelete: (index: number) => void;
  // UI
  @Local displayLabel: string = this.item[0];
  @Local isEditing: boolean = false;

  build() {
    Column({ space: standardSpacing }) {
      // Label
      Row({ space: standardSpacing * 0.25 }) {
        Text(`${this.icon}${this.displayLabel}`).attributeModifier(new MooTextModifier()).wordBreak(WordBreak.BREAK_ALL).maxLines(this.maxLines)
          .constraintSize(this.isEditing ? {} : { maxWidth: '80%' })
          .layoutWeight(this.isEditing ? 1 : undefined)
          .margin({ top: standardSpacing * 0.5, bottom: standardSpacing * 0.5 })
          .padding(isPreferRightHand() ? { left: standardSpacing } : { right: standardSpacing });
        
        // Small button
        if (this.allowEdit) {
          if (this.isEditing) {
            MooSymbolButtonSmall($r('sys.symbol.chevron_down'), () => {
              animateToImmediately(defaultAnimation(), () => {
                this.isEditing = false;
              });
            });
          } else {
            MooSymbolButtonSmall($r('sys.symbol.pencil_line'), () => {
              animateToImmediately(defaultAnimation(), () => {
                this.isEditing = true;
              });
            });
          }
        } else {
          MooSymbolButtonSmall($r('sys.symbol.archivebox'));
        }
      }
      .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);

      if (this.isEditing) {
        if (this.enableLabelField) {
          MooTextInputV2({
            icon: this.enableLinkField ? $r('sys.symbol.label') : $r('sys.symbol.pawprint'),
            text: this.editingLabel,
            onChange: (c) => {
              this.editingLabel = c;
            },
            onSubmit: () => {
              this.save();
            }
          });
        }
        if (this.enableLinkField) {
          MooTextInputV2({
            icon: $r('sys.symbol.link'),
            text: this.editingLink,
            onChange: (c) => {
              this.editingLink = c;
            },
            onSubmit: () => {
              this.save();
            }
          });
        }

        UniRowOfCapsuleButtons() {
          if (this.enableLabelField || this.enableLinkField) {
            MooCapsuleButton({
              text: $r('app.string.General_save'),
              clickAction: () => {
                this.save();
              },
              needDoubleConfirm: true
            });
          }
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
    .border(this.isSelected
      ? { width: 2, color: getColor(meowThemeColorType.FONT), radius: defaultItemRadius }
      : { width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth'), radius: defaultItemRadius })
    .padding(this.isEditing ? standardSpacing : standardSpacing * 0.25)
    .animation(defaultAnimation())
    .alignItems(HorizontalAlign.Start)
    .hoverEffect(this.clickable ? HoverEffect.Highlight : undefined)
    .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
    .onClick(() => {
      if (this.clickable) {
        this.clickAction(this.index);
      }
    });
  }

  /**
   * Save the edited item.
   */
  save() {
    // Set display.
    this.displayLabel = this.editingLabel;

    // meow(`call this.onEdit([${this.editingLabel}, ${this.editingLink}])`, 'MooMooStringItem][save', meowLevel.WARN);
    this.onEdited([this.editingLabel, this.editingLink]); // This works.

    // Close editing.
    animateToImmediately(defaultAnimation(), () => {
      this.isEditing = false;
    });
  }

  @Monitor('item')
  refresh() {
    this.displayLabel = this.item[0];
    this.editingLabel = this.item[0];
    this.editingLink = this.item[1];
  }
}

export { MooStringItem };
