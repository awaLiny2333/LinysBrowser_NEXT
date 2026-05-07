import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooTextModifier } from "../../common/MooTextModifier";
import { getColor, meowThemeColorType, standardSpacing, useEffects } from "../../settings";
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
        Column({ space: standardSpacing }) {
          this.contents();
        };
      }
    }
  }

  @Builder
  contents() {
    if (this.myUi.suggestionsHistories.length > 0) {
      Column({ space: standardSpacing }) {
        Text($r('app.string.Settings_category_history')).attributeModifier(new MooTextModifier()).suggestionTitleModifier();
        Column() {
          Repeat(this.myUi.suggestionsHistories)
            .each((item) => {
              SuggestionEntryButton({
                myLayout: this.myLayout,
                item: item.item,
                clickAction: () => {
                  this.visit(item.item.url);
                }
              });
            });
        }
        .backgroundColor(getColor(meowThemeColorType.PRIMARY))
        .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
        .padding(standardSpacing * 0.75);
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.myLayout.wideMode ? 1 : undefined);
    }

    if (this.myUi.suggestionsBookmarks.length > 0) {
      Column({ space: standardSpacing }) {
        Text($r('app.string.Bookmarks')).attributeModifier(new MooTextModifier()).suggestionTitleModifier();
        Column() {
          Repeat(this.myUi.suggestionsBookmarks)
            .each((item) => {
              SuggestionEntryButton({
                myLayout: this.myLayout,
                item: item.item,
                clickAction: () => {
                  this.visit(item.item.url);
                }
              });
            });
        }
        .backgroundColor(getColor(meowThemeColorType.PRIMARY))
        .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
        .padding(standardSpacing * 0.75);
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(this.myLayout.wideMode ? 1 : undefined);
    }
  }

  visit(url: string) {
    this.myUi.requestAddressBarBlur(this.getUIContext());
    this.myUi.submitSearchOrLoad(url);
  }
}

@Extend(Text)
function suggestionTitleModifier() {
  .padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 })
  .opacity(0.5);
}

export { MeowSuggestions };
