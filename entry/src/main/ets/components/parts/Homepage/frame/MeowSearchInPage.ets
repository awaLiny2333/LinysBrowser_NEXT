import { SymbolButton } from "../../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowTabsBunch } from "../../../../hosts/app/tabs/classes/meowTabsBunch";
import { MooTextInputV2 } from "../../../common/MooTextInputV2";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { searchInPageInputId, standardSpacing, textInputSlimHeight } from "../../../constants";
import { defaultAnimation, useEffects } from "../../../settings";

@ComponentV2
export struct MeowSearchInPage {
  @Param @Require alignRulesMy: AlignRuleOption;
  @Param @Require translateOptionsMy: TranslateOptions;
  @Param @Require myTabs: meowTabsBunch;

  build() {
    Row({ space: standardSpacing }) {
      if (this.myTabs.currentTabSearchKey == undefined) {
        Text($r('app.string.SearchInPage_noTab')).attributeModifier(new MooTextModifier()).opacity(0.75).layoutWeight(1).textAlign(TextAlign.Center);
      } else {
        MooTextInputV2({
          placeholder: '󰖳  ...',
          undefinedRadius: true,
          outerAutoExpand: true,
          myId: searchInPageInputId,
          shiftBackgroundColor: true,
          myHeight: this.myHeight,
          text: this.myTabs.currentTabSearchKey,
          onChange: (c) => {
            this.myTabs.setCurrentTabSearchKey(c);
          },
          onSubmit: () => {
            this.go();
          }
        });
        Row() {
          SymbolButton({
            icon: $r('sys.symbol.magnifyingglass'),
            clickAction: () => {
              this.go();
            }
          });
          if (this.myTabs.currentTabSearchIsSearching) {
            SymbolButton({
              icon: $r('sys.symbol.xmark'),
              clickAction: () => {
                animateToImmediately(defaultAnimation(), () => {
                  this.myTabs.currentTabSearchCancel(); // Cancel
                });
              }
            });
          }
          SymbolButton({
            icon: $r('sys.symbol.chevron_up'),
            clickAction: () => {
              this.myTabs.currentTabSearchLast(); // Last one
            }
          });
          Text(`${(this.myTabs.currentTabSearchIdx || 0) + 1}/${this.myTabs.currentTabSearchResultCount}`).attributeModifier(new MooTextModifier()).padding(standardSpacing * 0.75);
          SymbolButton({
            icon: $r('sys.symbol.chevron_down'),
            clickAction: () => {
              this.myTabs.currentTabSearchNext(); // Next one
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
    if (this.myTabs.currentTabSearchKey == this.myTabs.currentTabSearchedSearchKey) {
      this.myTabs.currentTabSearchNext(); // Go for next one.
    } else {
      this.myTabs.submitCurrentTabSearchKey(); // Search new.
    }
    setTimeout(() => {
      focusControl.requestFocus(searchInPageInputId);
    });
  }
  
  get myHeight() {
    return textInputSlimHeight - (useEffects() ? 2 : 0)
  }
}
