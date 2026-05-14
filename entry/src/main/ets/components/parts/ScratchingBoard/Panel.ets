import { meowBoardHolder, MeowScratchingBoardDataType } from "../../../hosts/app/scratchingboard/classes/meowBoardHolder";
import { getMyBoard } from "../../../hosts/app/scratchingboard/scripts/helpers";
import { mooTextType, standardComponentHeight, standardSpacing } from "../../constants";
import { TextCard } from "./cards/Text";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { UrlCard } from "./cards/Url";
import { ImageCard } from "./cards/Image";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { defaultAnimation, isPreferRightHand } from "../../settings";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../common/MooTextModifier";

@ComponentV2
export struct ScratchingBoardPanel {
  @Param @Require myUi: meowUiHost;
  @Local myBoard: meowBoardHolder = getMyBoard();

  build() {
    Stack({ alignContent: isPreferRightHand() ? Alignment.BottomEnd : Alignment.BottomStart }) {
      List({ space: standardSpacing * 0.75 }) {
        Repeat(this.myBoard.records)
          .each((item) => {
            if (item.item.type == MeowScratchingBoardDataType.TEXT) {
              TextCard(item.item.content);
            } else if (item.item.type == MeowScratchingBoardDataType.URL) {
              UrlCard(this.myUi, item.item.content);
            } else if (item.item.type == MeowScratchingBoardDataType.IMAGE) {
              ImageCard(item.item.content);
            }
          })
          .virtualScroll();
      }
      .borderRadius(defaultInnerRadius)
      .margin({ bottom: standardSpacing * 0.75 + standardComponentHeight })
      .width('100%')
      .height('auto');

      if (this.myBoard.records.length > 0) {
        // Clear
        MooCapsuleButton({
          text: $r('app.string.General_clear'),
          needDoubleConfirm: true,
          clickAction: () => {
            animateToImmediately(defaultAnimation(), () => {
              this.myBoard.records = [];
            });
          }
        });
      } else {
        // Placeholder for empty
        Text($r('app.string.General_empty')).attributeModifier(new MooTextModifier(mooTextType.TITLE))
          .opacity(0.5)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height('100%');
      }
    }
    .height('auto');
  }
}
