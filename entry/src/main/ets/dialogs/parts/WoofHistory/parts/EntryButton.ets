import { defaultItemRadius } from '../../../../catstypicalframework/utils/ui';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { meowFlexOptions, standardSpacing } from '../../../../components/settings';
import { meowHistoryEntry } from '../../../../hosts/userdata/history/classes/meowHistoryEntry';

@ComponentV2
struct EntryButton {
  @Param @Require isSelected: boolean;
  @Param @Require isSelecting: boolean;
  @Param @Require item: meowHistoryEntry;
  @Event clickAction: () => void;

  build() {
    Flex(meowFlexOptions) {
      if (this.isSelecting) {
        Text(`${this.isSelected ? '󰀒' : '󰁵'}`).attributeModifier(new MooTextModifier());
      }
      Text(`${this.item.title}`)
        .attributeModifier(new MooTextModifier())
        .wordBreak(WordBreak.BREAK_ALL)
        .maxLines(1);
      Text(`${this.item.url}`)
        .attributeModifier(new MooTextModifier())
        .wordBreak(WordBreak.BREAK_ALL)
        .maxLines(1)
        .opacity(0.7);
      Text(`${new Date(this.item.time).toLocaleDateString()}`)
        .attributeModifier(new MooTextModifier())
        .opacity(0.45);
      Text(`${new Date(this.item.time).toLocaleTimeString()}`)
        .attributeModifier(new MooTextModifier())
        .opacity(0.45);
    }
    .onClick(() => {
      this.clickAction();
    })
    .padding(standardSpacing * 0.75)
    .borderRadius(defaultItemRadius)
    .hoverEffect(HoverEffect.Highlight);
  }
}

export { EntryButton };
