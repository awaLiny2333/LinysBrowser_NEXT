import { meowLayout } from '../../../../catstypicalframework/hosts/meowLayout';
import { isBlank } from '../../../../catstypicalframework/utils/strings';
import { defaultItemRadius } from '../../../../catstypicalframework/utils/ui';
import { meowHistoryEntry } from '../../../../hosts/userdata/history/classes/meowHistoryEntry';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { standardSpacing } from '../../../constants';

@ComponentV2
struct HistoryEntry {
  // Params
  @Param @Require item: meowHistoryEntry;
  // Host
  @Param @Require myLayout: meowLayout;
  // Environments
  @Param @Require isSelected: boolean;
  @Param @Require isSelecting: boolean;
  // Events
  @Event clickAction: () => void;

  build() {
    if (this.myLayout.wideMode) {
      this.rowLayout();
    } else {
      this.colLayout();
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

      this.time();
    }
    .width('100%')
    .onClick(() => {
      this.clickAction();
    })
    .padding(standardSpacing * 0.75)
    .borderRadius(defaultItemRadius)
    .hoverEffect(HoverEffect.Highlight);
  }

  @Builder
  colLayout() {
    Column({ space: standardSpacing * 0.5 }) {
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

      this.time();
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.clickAction();
    })
    .padding(standardSpacing * 0.75)
    .borderRadius(defaultItemRadius)
    .hoverEffect(HoverEffect.Highlight);
  }

  @Builder
  time() {
    Text(this.myDate)
      .attributeModifier(new MooTextModifier())
      .maxLines(1)
      .opacity(0.45);
  }

  // @Computed
  get myDate() {
    return new Date(this.item.time).toLocaleTimeString().padStart(11, '0');
  }
}

export { HistoryEntry };
