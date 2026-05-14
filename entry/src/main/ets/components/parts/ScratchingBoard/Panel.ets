import { common } from "@kit.AbilityKit";
import { image } from "@kit.ImageKit";
import { copyImage, copyText } from "../../../catstypicalframework/utils/clipboard";
import { fileDocumentPickSave, saveImageToAlbum } from "../../../catstypicalframework/utils/storage";
import { defaultInnerRadius, defaultItemRadius } from "../../../catstypicalframework/utils/ui";
import { meowBoardHolder, MeowScratchingBoardDataType } from "../../../hosts/app/scratchingboard/classes/meowBoardHolder";
import { getMyBoard } from "../../../hosts/app/scratchingboard/scripts/helpers";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooTextModifier } from "../../common/MooTextModifier";
import { mooTextType, standardComponentHeight, standardSpacing } from "../../constants";
import { defaultAnimation, isPreferRightHand } from "../../settings";
import { ScratchingBoardCardFrame } from "./cards/Frame";

@ComponentV2
export struct ScratchingBoardPanel {
  @Param @Require myUi: meowUiHost;
  @Local myBoard: meowBoardHolder = getMyBoard();

  build() {
    Stack({ alignContent: isPreferRightHand() ? Alignment.BottomEnd : Alignment.BottomStart }) {
      List({ space: standardSpacing * 0.75 }) {
        Repeat(this.myBoard.records)
          .each((item) => {
            ListItem() {
              ScratchingBoardCardFrame() {
                if (item.item.type == MeowScratchingBoardDataType.TEXT) {
                  // Url card
                  Text(item.item.textContent).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
                    .onClick(() => {
                      copyText(item.item.textContent); // Copy
                    });
                } else if (item.item.type == MeowScratchingBoardDataType.URL) {
                  // Url card
                  Text(item.item.textContent).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
                    .fontWeight(FontWeight.Bold)
                    .onClick(() => {
                      this.myUi.submitSearchOrLoad(item.item.textContent);
                    });
                  Row() {
                    MooSymbolButton({
                      icon: $r('sys.symbol.plus_square_on_square'),
                      clickAction: () => {
                        copyText(item.item.textContent); // Copy
                      }
                    });
                    MooSymbolButton({
                      icon: $r('sys.symbol.arrow_up_right'),
                      clickAction: () => {
                        this.myUi.submitSearchOrLoad(item.item.textContent);
                      }
                    });
                  }
                  .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
                  .width('100%');
                } else if (item.item.type == MeowScratchingBoardDataType.IMAGE) {
                  if (item.item.payload) {
                    Image((item.item.payload as [ArrayBuffer, image.PixelMap])[1]).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
                      .onClick(() => {
                        // Copy image
                      });
                  }
                  Text(item.item.textContent).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius).opacity(0.75);
                  Row() {
                    MooSymbolButton({
                      icon: $r('sys.symbol.download'),
                      clickAction: () => {
                        // Download
                        fileDocumentPickSave(item.item.textContent, (item.item.payload as [ArrayBuffer, image.PixelMap])[0]);
                      }
                    });
                    MooSymbolButton({
                      icon: $r('sys.symbol.picture_badge_arrow_down'),
                      clickAction: () => {
                        // Save to Gallery
                        saveImageToAlbum(this.getUIContext().getHostContext()! as common.UIAbilityContext, (item.item.payload as [ArrayBuffer, image.PixelMap])[0], item.item.extraContent);
                      }
                    });
                    MooSymbolButton({
                      icon: $r('sys.symbol.plus_square_on_square'),
                      clickAction: () => {
                        // Copy image
                        copyImage((item.item.payload as [ArrayBuffer, image.PixelMap])[1]);
                      }
                    });
                  }
                  .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
                  .width('100%');
                }
              };
            };
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
