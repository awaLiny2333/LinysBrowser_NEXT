import { copyText } from "../../../../catstypicalframework/utils/clipboard";
import { defaultItemRadius } from "../../../../catstypicalframework/utils/ui";
import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { MooSymbolButton } from "../../../common/MooSymbolButton";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { standardSpacing } from "../../../constants";
import lazy { defaultAnimation, isPreferRightHand } from "../../../settings";
import { ScratchingBoardCardFrame } from "./Frame";

@Builder
export function UrlCard(myUi: meowUiHost, text?: string) {
  if (text) {
    ListItem() {
      ScratchingBoardCardFrame() {
        Text(text).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            requestVisit(myUi, text);
          });
        Row() {
          MooSymbolButton({
            icon: $r('sys.symbol.plus_square_on_square'),
            clickAction: () => {
              copyText(text); // Copy
            }
          });
          MooSymbolButton({
            icon: $r('sys.symbol.arrow_up_right'),
            clickAction: () => {
              requestVisit(myUi, text);
            }
          });
        }
        .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
        .width('100%');
      };
    };
  }
}

function requestVisit(myUi: meowUiHost, url: string) {
  myUi.submitSearchOrLoad(url);
  animateToImmediately(defaultAnimation(), () => {
    myUi.sideAreaShrunkExpect = true;
  });
}
