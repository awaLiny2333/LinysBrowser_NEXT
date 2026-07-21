import { SymbolButton } from "../../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { MooTextInputV2 } from "../../../common/MooTextInputV2";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { searchInPageInputId, standardSpacing, textInputSlimHeight } from "../../../constants";
import { defaultAnimation, useEffects } from "../../../settings";

@ComponentV2
export struct MeowSearchInPage {
  @Param @Require alignRulesMy: AlignRuleOption;
  @Param @Require translateOptionsMy: TranslateOptions;
  @Param @Require myUi: meowUiHost;

  build() {
    Row({ space: standardSpacing }) {
      if (this.myUi.myTabs.currentTabSearchInputKey == undefined) {
        Text($r('app.string.SearchInPage_noTab')).attributeModifier(new MooTextModifier()).opacity(0.75).layoutWeight(1).textAlign(TextAlign.Center);
      } else {
        MooTextInputV2({
          placeholder: '󰖳  ...',
          undefinedRadius: true,
          outerAutoExpand: true,
          myId: searchInPageInputId,
          shiftBackgroundColor: true,
          myHeight: this.myHeight,
          text: this.myUi.myTabs.currentTabSearchInputKey,
          onChange: (c) => {
            this.myUi.myTabs.currentTabSearchSetKey(c);
          },
          onSubmit: () => {
            this.go();
          }
        });
        // Controls
        Row() {
          SymbolButton({
            icon: $r('sys.symbol.magnifyingglass'),
            clickAction: () => {
              this.go();
            }
          });
          if (this.myUi.myTabs.currentTabSearchIsSearching) {
            SymbolButton({
              icon: $r('sys.symbol.xmark'),
              clickAction: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.myUi.myTabs.currentTabSearchCancel(); // Cancel
                });
              }
            });
          }
          SymbolButton({
            icon: $r('sys.symbol.chevron_up'),
            clickAction: () => {
              this.myUi.myTabs.currentTabSearchLast(); // Last one
            }
          });
          // Index indicator
          Text(`${(this.myUi.myTabs.currentTabSearchIdx || 0) + 1}/${this.myUi.myTabs.currentTabSearchResultCount}`).attributeModifier(new MooTextModifier()).padding(standardSpacing * 0.75);
          SymbolButton({
            icon: $r('sys.symbol.chevron_down'),
            clickAction: () => {
              this.myUi.myTabs.currentTabSearchNext(); // Next one
            }
          });
        };
      }
    }
    .onAppear(() => {
      focusControl.requestFocus(searchInPageInputId);
    })
    .padding({ left: standardSpacing, right: standardSpacing })
    .height(this.myHeight)
    .alignRules(this.alignRulesMy)
    .translate(this.translateOptionsMy)
    .width('100%');
  }

  go() {
    if (this.myUi.myTabs.currentTabSearchInputKey == this.myUi.myTabs.currentTabSearchSearchedKey) {
      this.myUi.myTabs.currentTabSearchNext(); // Go for next one.
    } else {
      this.myUi.myTabs.currentTabSearchSubmit(); // Search new.
    }
    setTimeout(() => {
      focusControl.requestFocus(searchInPageInputId);
    });
  }
  
  get myHeight() {
    return textInputSlimHeight - (useEffects() ? 2 : 0)
  }
}
