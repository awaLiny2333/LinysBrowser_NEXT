import { meowBoardHolder, MeowScratchingBoardDataType } from "../../../hosts/app/scratchingboard/classes/meowBoardHolder";
import { getMyBoard } from "../../../hosts/app/scratchingboard/scripts/helpers";
import { standardSpacing } from "../../constants";
import { TextCard } from "./cards/Text";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { UrlCard } from "./cards/Url";
import { ImageCard } from "./cards/Image";

@ComponentV2
export struct ScratchingBoardPanel {
  @Param @Require myUi: meowUiHost;
  @Local myBoard: meowBoardHolder = getMyBoard();

  build() {
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
        });
    }
    .width('100%')
    .height('auto');
  }
}
