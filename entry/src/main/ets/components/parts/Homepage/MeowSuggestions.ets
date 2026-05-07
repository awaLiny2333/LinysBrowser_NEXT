import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius, shortModeThreshold } from "../../../catstypicalframework/utils/ui";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowBookmarkItem } from "../../../hosts/userdata/bookmarks/classes/meowBookmarkItem";
import { meowHistoryEntry } from "../../../hosts/userdata/history/classes/meowHistoryEntry";
import { MooTextModifier } from "../../common/MooTextModifier";
import { getColor, meowThemeColorType, standardSpacing, useEffects } from "../../settings";
import { defaultMeowDestinationHeight } from "./MeowDestination";
import { SuggestionEntryButton } from "./MeowSuggestionEntry";

@ComponentV2
struct MeowSuggestions {
  @Param @Require myUi: meowUiHost;
  @Param @Require myLayout: meowLayout;

  build() {
    if (this.myUi.suggestionsHistories.length + this.myUi.suggestionsBookmarks.length > 0) {
      if (this.myLayout.wideMode) {
        Row({ space: standardSpacing }) {
          this.contents();
        }.alignItems(VerticalAlign.Top);
      } else {
        Scroll() {
          Column({ space: standardSpacing }) {
            this.contents();
          };
        }
        .borderRadius(defaultInnerRadius)
        .edgeEffect(EdgeEffect.Spring)
        .scrollable(ScrollDirection.Vertical)
        .constraintSize({ maxHeight: this.maxHeightNonWideMode });
      }
    }
  }

  @Builder
  contents() {
    SuggestionsFrame({
      needScroll: this.myLayout.wideMode,
      myLayout: this.myLayout, title: $r('app.string.Settings_category_history'), list: this.myUi.suggestionsHistories,
      clickAction: (url) => {
        this.visit(url);
      }
    });
    SuggestionsFrame({
      needScroll: this.myLayout.wideMode,
      myLayout: this.myLayout, title: $r('app.string.Bookmarks'), list: this.myUi.suggestionsBookmarks,
      clickAction: (url) => {
        this.visit(url);
      }
    });
  }

  /**
  * Visit a URL.
  * @param url The url.
  */
  visit(url: string) {
    this.myUi.requestAddressBarBlur(this.getUIContext());
    this.myUi.submitSearchOrLoad(url);
  }

  /**
   * Get the max height of the suggestions frame in non-wide mode.
   */
  get maxHeightNonWideMode() {
    const maxH = this.myLayout.heightTitleArea - this.myLayout.heightTitleBar - defaultMeowDestinationHeight - 2 * standardSpacing;
    if (maxH > shortModeThreshold) {
      return maxH * 0.75;
    }
    return maxH;
  }
}

export { MeowSuggestions };

@ComponentV2
struct SuggestionsFrame {
  // Config
  @Param @Require @Once needScroll: boolean;
  // Params
  @Param @Require title: ResourceStr;
  @Param @Require myLayout: meowLayout;
  @Param @Require list: Array<meowBookmarkItem | meowHistoryEntry>;
  // Event
  @Event clickAction: (url: string) => void;

  build() {
    if (this.list.length > 0) {
      Column({ space: standardSpacing }) {
        Text(this.title).attributeModifier(new MooTextModifier()).padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 }).opacity(0.5).height(20);
        if (this.needScroll) {
          Scroll() {
            this.coreRepeat();
          }
          .borderRadius(defaultInnerRadius)
          .edgeEffect(EdgeEffect.Spring)
          .scrollable(ScrollDirection.Vertical)
          .constraintSize(this.myLayout.wideMode ? { maxHeight: this.maxHeightPart } : undefined);
        } else {
          this.coreRepeat();
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.myLayout.wideMode ? 1 : undefined);
    }
  }

  @Builder
  coreRepeat() {
    Column() {
      Repeat(this.list)
        .each((item) => {
          SuggestionEntryButton({
            myLayout: this.myLayout,
            item: item.item,
            clickAction: () => {
              this.clickAction(item.item.url);
            }
          });
        });
    }
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
    .padding(standardSpacing * 0.75);
  }

  /**
   * Get the max height of the suggestions frame.
   */
  get maxHeightPart() {
    const maxH = this.myLayout.heightTitleArea - this.myLayout.heightTitleBar - defaultMeowDestinationHeight - 20 - 3 * standardSpacing;
    if (maxH > shortModeThreshold) {
      return maxH * 0.75;
    }
    return maxH;
  }
}
