/**
 * Modified from HistoryEntry.
 *
 * @see entry/src/main/ets/dialogs/parts/WoofHistory/parts/HistoryEntry.ets
 */
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { isBlank } from "../../../catstypicalframework/utils/strings";
import { defaultItemRadius } from "../../../catstypicalframework/utils/ui";
import { meowBookmarkItem } from "../../../hosts/userdata/bookmarks/classes/meowBookmarkItem";
import { meowHistoryEntry } from "../../../hosts/userdata/history/classes/meowHistoryEntry";
import { MooTextModifier } from "../../common/MooTextModifier";
import { standardSpacing, meowFlexOptions } from "../../constants";

@ComponentV2
struct SuggestionEntryButton {
  @Param @Require myLayout: meowLayout;
  @Param @Require item: meowHistoryEntry | meowBookmarkItem;
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
      if (!isBlank(this.item.title)) {
        // Title
        Text(`${this.item.title}`)
          .attributeModifier(new MooTextModifier())
          .fontWeight(FontWeight.Medium)
          .wordBreak(WordBreak.BREAK_ALL)
          .layoutWeight(1.618)
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
    }
    .onClick(() => {
      this.clickAction();
    })
    .padding(standardSpacing * 0.75)
    .borderRadius(defaultItemRadius)
    .hoverEffect(HoverEffect.Highlight);
  }
}

export { SuggestionEntryButton };
