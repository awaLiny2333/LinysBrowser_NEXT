import { copyText } from "../../../../catstypicalframework/utils/clipboard";
import { defaultItemRadius } from "../../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { standardSpacing } from "../../../constants";
import { ScratchingBoardCardFrame } from "./Frame";

@Builder
export function TextCard(text?: string) {
  if (text) {
    ListItem() {
      ScratchingBoardCardFrame() {
        Text(text).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
          .onClick(() => {
            clickAction(text);
          });
        
        // Clicking on the text is the same as clicking on this button.
        // So this button is useless.
        
        // Row() {
        //   MooSymbolButton({
        //     icon: $r('sys.symbol.plus_square_on_square'),
        //     clickAction: () => {
        //       clickAction(text);
        //     }
        //   });
        // }
        // .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
        // .width('100%');
      };
    };
  }
}

function clickAction(text: string) {
  copyText(text); // Copy
}
