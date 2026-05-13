import { copyText } from "../../../../catstypicalframework/utils/clipboard";
import { defaultItemRadius } from "../../../../catstypicalframework/utils/ui";
import { MooSymbolButton } from "../../../common/MooSymbolButton";
import { standardSpacing } from "../../../constants";
import { isPreferRightHand } from "../../../settings";
import { ScratchingBoardCardFrame } from "./Frame";

@Builder
export function ImageCard(text?: string) {
  if (text) {
    ListItem() {
      ScratchingBoardCardFrame() {
        Image(text).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
          .onClick(() => {
            clickAction(text);
          });
        
        Row() {
          MooSymbolButton({
            icon: $r('sys.symbol.plus_square_on_square'),
            clickAction: () => {
              clickAction(text);
            }
          });
        }
        .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
        .width('100%');
      };
    };
  }
}

function clickAction(text: string) {
  copyText(text); // Copy
}
