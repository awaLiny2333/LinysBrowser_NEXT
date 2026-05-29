import { copyText } from "../../../../catstypicalframework/utils/clipboard";
import { UnifiedDestinationResultType } from "../../../../catstypicalframework/utils/url";
import { SymbolButton } from "../../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { MooCapsuleButton } from "../../../common/MooCapsuleButton";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { standardComponentHeight, standardSpacing } from "../../../constants";
import { isPreferRightHand, titleBarPositionBottom } from "../../../settings";

@Builder
export function MeowDestination(myUi: meowUiHost, uiContext: UIContext) {
  Row({ space: standardSpacing }) {
    if (myUi.searchUnifyResult?.type == UnifiedDestinationResultType.URL_UNSCHEMED) {
      MooCapsuleButton({
        text: myUi.addressBarPreferHttps ? 'HTTPS  󰀈' : 'HTTP  󰓄',
        clickAction: () => {
          myUi.addressBarPreferHttps = !myUi.addressBarPreferHttps;
          myUi.refreshDestination();
        }
      });
    }

    Text(`→ ${myUi.searchUnifyResult.url}`).attributeModifier(new MooTextModifier())
      .maxLines(2)
      .opacity(0.9)
      .wordBreak(WordBreak.BREAK_ALL)
      .layoutWeight(1);

    // Buttons
    // Using a nested row here is not good. But rendering an extra Row isn't really a big problem... Is it :P
    Row() {
      SymbolButton({
        icon: $r('sys.symbol.plus_square_on_square'),
        clickAction: () => {
          copyText(myUi.searchUnifyResult.url);
        }
      });
      SymbolButton({
        icon: titleBarPositionBottom() ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_up'),
        clickAction: () => {
          myUi.requestAddressBarBlur(uiContext);
        }
      });
    }
    .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
  }
  .height(standardComponentHeight)
  .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
}
