import { copyText } from "../../../catstypicalframework/utils/clipboard";
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

    Text(`→ ${proposedDestination(myUi)}`).attributeModifier(new MooTextModifier())
      .maxLines(2)
      .opacity(0.9)
      .wordBreak(WordBreak.BREAK_ALL)
      .layoutWeight(1);

    // Buttons
    // TODO: Using a nested row here is not good. Solve this one day.
    Row() {
      SymbolButton({
        icon: $r('sys.symbol.plus_square_on_square'),
        clickAction: () => {
          copyText(proposedDestination(myUi));
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
  .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl);
}

/**
 * Get the proposed destination.
 * @param myUi The meowUiHost.
 * @returns myUi.searchUnifyResult.url or the default search engine concated with '' if myUi.searchUnifyResult.url is empty.
 */
function proposedDestination(myUi: meowUiHost) {
  return myUi.searchUnifyResult.url || concatSearchWithEngine('').result;
}
