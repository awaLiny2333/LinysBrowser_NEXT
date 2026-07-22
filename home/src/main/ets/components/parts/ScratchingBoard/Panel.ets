import { common } from "@kit.AbilityKit";
import { image } from "@kit.ImageKit";
import { copyImage, copyText } from "../../../catstypicalframework/utils/clipboard";
import { addUnitsToSize, fileDocumentPickSave, saveImageToAlbum } from "../../../catstypicalframework/utils/storage";
import { defaultInnerRadius, defaultItemRadius, measureTextWidth } from "../../../catstypicalframework/utils/ui";
import { meowBoardHolder, MeowScratchingBoardData, MeowScratchingBoardDataType } from "../../../hosts/app/scratchingboard/classes/meowBoardHolder";
import { getMyBoard } from "../../../hosts/app/scratchingboard/scripts/helpers";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooSymbolButton } from "../../common/MooSymbolButton";
import { MooSymbolButtonMeow } from "../../common/MooSymbolButtonMeow";
import { MooTextModifier } from "../../common/MooTextModifier";
import { defaultMooSymbolSize, fontSizeSmall, mooTextType, standardComponentHeight, standardSpacing } from "../../constants";
import { isPreferRightHand } from "../../settings";
import { ScratchingBoardCardFrame } from "./Frame";

@ComponentV2
export struct ScratchingBoardPanel {
  @Param @Require myUi: meowUiHost;
  @Local myBoard: meowBoardHolder = getMyBoard();
  @Param @Once needPadding: boolean = true;
  // Local
  @Local panelWidth: number = 0;
  // Events
  @Event onSearchSubmitOrLoad: () => void; // Majorly to notify the parent level about the event, like to close the dialog or things.

  build() {
    Stack({ alignContent: isPreferRightHand() ? Alignment.BottomEnd : Alignment.BottomStart }) {
      List({ space: standardSpacing * 0.75 }) {
        Repeat(this.myBoard.records)
          .each((item) => {
            ListItem() {
              ScratchingBoardCardFrame() {
                if (item.item.type == MeowScratchingBoardDataType.TEXT) {
                  this.TextCard(item);
                } else if (item.item.type == MeowScratchingBoardDataType.URL) {
                  this.UrlCard(item);
                } else if (item.item.type == MeowScratchingBoardDataType.IMAGE) {
                  this.ImageCard(item);
                }
              };
            };
          })
          .virtualScroll();
      }
      .borderRadius(defaultInnerRadius)
      .direction(isPreferRightHand() ? Direction.Rtl : Direction.Ltr)
      .margin({ bottom: this.myUi.dropHover ? 0 : standardSpacing * 0.75 + standardComponentHeight })
      .opacity(this.myUi.dropHover ? 0.5 : 1)
      .width('100%')
      .height('auto');

      if (this.myUi.dropHover) {
        // Drop notice.
        Text($r('app.string.ScratchingBoard_drop')).attributeModifier(new MooTextModifier(mooTextType.TITLE))
          .width('100%').height('100%').padding(standardSpacing)
          .hitTestBehavior(HitTestMode.Transparent).textAlign(TextAlign.Center);
      } else if (this.myBoard.records.length > 0) {
        // Clear button if there is contents.
        MooCapsuleButton({
          text: $r('app.string.General_clear'),
          needDoubleConfirm: true,
          clickAction: () => {
            this.myBoard.clearBoard();
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
    .padding(this.needPadding ? standardSpacing : 0)
    .onAreaChange((oldValue, newValue) => {
      if (oldValue.width != newValue.width) {
        this.panelWidth = newValue.width as number;
      }
    })
    .height('auto');
  }

  @Builder
  TextCard(item: RepeatItem<MeowScratchingBoardData>) {
    Text(item.item.textContent).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
      .opacity(0.9)
      .onClick(() => {
        copyText(item.item.textContent); // Copy
      });
  }

  @Builder
  UrlCard(item: RepeatItem<MeowScratchingBoardData>) {
    if (measureTextWidth(item.item.textContent, this.getUIContext(), fontSizeSmall, FontWeight.Bold) > (this.panelWidth - standardSpacing * (2 * 0.7 + 2 * 0.5) - (defaultMooSymbolSize) * 2)) {
      Text(item.item.textContent).attributeModifier(new MooTextModifier()).padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
        .width('100%')
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.myUi.submitSearchOrLoad(item.item.textContent);
          this.onSearchSubmitOrLoad();
        });
      Row() {
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_up_right'),
          clickAction: () => {
            this.myUi.submitSearchOrLoad(item.item.textContent);
            this.onSearchSubmitOrLoad();
          }
        });
        MooSymbolButtonMeow({
          icon: $r('sys.symbol.plus_square_on_square'),
          clickAction: () => {
            copyText(item.item.textContent); // Copy
          }
        });
      }
      .justifyContent(isPreferRightHand() ? FlexAlign.End : FlexAlign.Start)
      .width('100%');
    } else {
      Row() {
        Text(item.item.textContent).attributeModifier(new MooTextModifier()).padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
          // .wordBreak(WordBreak.BREAK_ALL)
          .layoutWeight(1)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.myUi.submitSearchOrLoad(item.item.textContent);
            this.onSearchSubmitOrLoad();
          });
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_up_right'),
          clickAction: () => {
            this.myUi.submitSearchOrLoad(item.item.textContent);
            this.onSearchSubmitOrLoad();
          }
        });
        MooSymbolButtonMeow({
          icon: $r('sys.symbol.plus_square_on_square'),
          clickAction: () => {
            copyText(item.item.textContent); // Copy
          }
        });
      }
      .direction(isPreferRightHand() ? Direction.Ltr : Direction.Rtl)
      .width('100%');
    }

  }

  @Builder
  ImageCard(item: RepeatItem<MeowScratchingBoardData>) {
    if (item.item.payload) {
      Image(this.imagePayload(item.item.payload)[2])
        .width('100%').padding(standardSpacing * 0.5).hoverEffect(HoverEffect.Highlight).borderRadius(defaultItemRadius)
        .onClick(() => {
          copyImage(this.imagePayload(item.item.payload)[1]);
        });
    }
    Flex({ wrap: FlexWrap.Wrap, justifyContent: isPreferRightHand() ? FlexAlign.End : FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Text(`${addUnitsToSize(this.imagePayload(item.item.payload)[0].byteLength)} ${this.imagePayload(item.item.payload)[3].mimeType.substring(6).toUpperCase()} - ${this.imagePayload(item.item.payload)[3].size.width} × ${this.imagePayload(item.item.payload)[3].size.height}`)
        .attributeModifier(new MooTextModifier()).opacity(0.9).padding(standardSpacing * 0.5);
      MooSymbolButton({
        icon: $r('sys.symbol.download'),
        clickAction: () => {
          // Download
          fileDocumentPickSave(item.item.textContent, this.imagePayload(item.item.payload)[0]);
        }
      });
      MooSymbolButton({
        icon: $r('sys.symbol.picture_badge_arrow_down'),
        clickAction: () => {
          // Save to Gallery
          saveImageToAlbum(this.imagePayload(item.item.payload)[2], this.getUIContext().getHostContext()! as common.UIAbilityContext);
        }
      });
      MooSymbolButtonMeow({
        icon: $r('sys.symbol.plus_square_on_square'),
        clickAction: () => {
          // Copy image
          copyImage(this.imagePayload(item.item.payload)[1]);
        }
      });
    }
    .width('100%');
  }

  imagePayload(payload: object | undefined) {
    return payload as [ArrayBuffer, image.PixelMap, string, image.ImageInfo]; // We trust this.
  }
}
