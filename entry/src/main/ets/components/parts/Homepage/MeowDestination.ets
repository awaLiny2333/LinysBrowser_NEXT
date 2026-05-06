import { UnifyDestinationResultType } from "../../../catstypicalframework/utils/url";
import { SymbolButton } from "../../../dialogs/parts/WoofCatsDev/parts/common/SymbolButton";
import lazy { concatSearchWithEngine } from "../../../hosts/app/tabs/scripts/searchEngines";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooTextModifier } from "../../common/MooTextModifier";
import { isPreferRightHand, standardSpacing, titleBarPositionBottom } from "../../settings";

@Builder
export function MeowDestination(myUi: meowUiHost, uiContext: UIContext) {
  Row({ space: standardSpacing }) {
    if (myUi.searchUnifyResult?.type == UnifyDestinationResultType.URL_UNSCHEMED) {
      MooCapsuleButton({
        text: myUi.preferHttps ? 'HTTPS  󰀈' : 'HTTP  󰓄',
        clickAction: () => {
          myUi.preferHttps = !myUi.preferHttps;
          myUi.refreshDestination();
        }
      });
    }
    Text(`→ ${myUi.searchUnifyResult.url || concatSearchWithEngine('').result}`).attributeModifier(new MooTextModifier())
      .maxLines(2)
      .opacity(0.9)
      .wordBreak(WordBreak.BREAK_ALL)
      .layoutWeight(1);
    SymbolButton({
      icon: titleBarPositionBottom() ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_up'),
      clickAction: () => {
        myUi.requestAddressBarBlur(uiContext);
      }
    });
  }
  .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
}
