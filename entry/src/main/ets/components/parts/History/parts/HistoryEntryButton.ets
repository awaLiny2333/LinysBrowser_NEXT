import { meowLayout } from '../../../../catstypicalframework/hosts/meowLayout';
import { isBlank } from '../../../../catstypicalframework/utils/strings';
import { defaultItemRadius } from '../../../../catstypicalframework/utils/ui';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { meowFlexOptions, standardSpacing } from '../../../settings';
import { meowHistoryEntry } from '../../../../hosts/userdata/history/classes/meowHistoryEntry';

@ComponentV2
struct HistoryEntryButton {
  @Param @Require myLayout: meowLayout;
  @Param @Require isSelected: boolean;
  @Param @Require isSelecting: boolean;
  @Param @Require item: meowHistoryEntry;
  @Event clickAction: () => void;

  build() {
    if (this.myLayout.wideMode) {
      this.rowLayout();
    } else {
      this.flexLayout();
    }
  }

  @Builder
  rowLayout() {
    Row({ space: standardSpacing }) {
      if (this.isSelecting) {
        Text(`${this.isSelected ? '󰀒' : '󰁵'}`).attributeModifier(new MooTextModifier());
      }

      if (!isBlank(this.item.title)) {
        // Title
        Text(`${this.item.title}`)
          .attributeModifier(new MooTextModifier())
          .fontWeight(FontWeight.Medium)
          .wordBreak(WordBreak.BREAK_ALL)
          .layoutWeight(0.618)
          .maxLines(1);
        // Url
        if (this.item.title != this.item.url) {
          Text(this.item.url)
            .attributeModifier(new MooTextModifier())
            .wordBreak(WordBreak.BREAK_ALL)
            .layoutWeight(1)
            .maxLines(1)
            .opacity(0.7);
        }

      } else {
        // Url ONLY
        Text(this.item.url)
          .attributeModifier(new MooTextModifier())
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .wordBreak(WordBreak.BREAK_ALL)
          .maxLines(1);
      }

      // Time
      Text(`${new Date(this.item.time).toLocaleTimeString().padStart(11, '0')}`)
        .attributeModifier(new MooTextModifier())
        .maxLines(1)
        .opacity(0.45);
    }
    .onClick(() => {
      this.clickAction();
    })
    .padding(standardSpacing * 0.75)
    .borderRadius(defaultItemRadius)
    .hoverEffect(HoverEffect.Highlight);
  }

  @Builder
  flexLayout() {
    Flex(meowFlexOptions) {
      if (this.isSelecting) {
        Text(`${this.isSelected ? '󰀒' : '󰁵'}`).attributeModifier(new MooTextModifier());
      }

      if (!isBlank(this.item.title)) {
        // Title
        Text(`${this.item.title}`)
          .attributeModifier(new MooTextModifier())
          .wordBreak(WordBreak.BREAK_ALL)
          .maxLines(1);
        // Url
        if (this.item.title != this.item.url) {
          Text(this.item.url)
            .attributeModifier(new MooTextModifier())
            .wordBreak(WordBreak.BREAK_ALL)
            .maxLines(1)
            .opacity(0.7);
        }

      } else {
        // Url ONLY
        Text(this.item.url)
          .attributeModifier(new MooTextModifier())
          .wordBreak(WordBreak.BREAK_ALL)
          .maxLines(1);
      }

      // Time
      Text(`${new Date(this.item.time).toLocaleTimeString().padStart(11, '0')}`)
        .attributeModifier(new MooTextModifier())
        .maxLines(1)
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

export { HistoryEntryButton };
