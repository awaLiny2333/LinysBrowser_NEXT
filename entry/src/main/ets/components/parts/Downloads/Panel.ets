import { copyText } from "../../../catstypicalframework/utils/clipboard";
import { addUnitsToSize } from "../../../catstypicalframework/utils/storage";
import { meowDawnloada } from "../../../hosts/app/downloads/classes/meowDawnloada";
import { getMyDawn } from "../../../hosts/app/downloads/scripts/helper";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooTextModifier } from "../../common/MooTextModifier";
import { UniContentCard } from "../../common/UniContentCard";
import { UniRowOfCapsuleButtons } from "../../common/UniRowOfCapsuleButtons";
import { mooTextType, standardSpacing } from "../../constants";
import { webview } from "@kit.ArkWeb";
import { resource2String, symbolForFileType } from "../../../catstypicalframework/utils/resource";
import { meow } from "../../../catstypicalframework/utils/catsLogger";
import { defaultRoundedRadius } from "../../../catstypicalframework/utils/ui";
import { addUnitsToSeconds } from "../../../catstypicalframework/utils/strings";
import { useEffects } from "../../settings";

@ComponentV2
export struct DownloadsPanel {
  @Param @Once needPadding: boolean = true;
  @Param @Once needLayoutWeightFull: boolean = false;
  // Hosts
  @Local myDawn: meowDawnloada = getMyDawn();

  build() {
    Scroll() {
      Column({ space: standardSpacing }) {
        if (this.myDawn.items.length == 0) {
          Text($r('app.string.General_empty')).attributeModifier(new MooTextModifier(mooTextType.TITLE))
            .layoutWeight(1).width('100%')
            .opacity(0.5).textAlign(TextAlign.Center).padding(standardSpacing * 2);
        } else {
          Repeat(this.myDawn.items)
            .each((item) => {
              UniContentCard({ title: `${item.item.fileName} (${item.item.progress}%)`, icon: symbolForFileType(item.item.mimeType), shiftBackgroundColor: !useEffects(), expanded: true }) {
                Text(resource2String(this.humanWordState(item.item.state), this.getUIContext().getHostContext()!)).width('100%').attributeModifier(new MooTextModifier());
                Text(this.estTime(item.item.totalSize - item.item.currentSize, item.item.currentSpeed)).width('100%').attributeModifier(new MooTextModifier());
                Text(`󰙧  ${addUnitsToSize(item.item.currentSize)}/${addUnitsToSize(item.item.totalSize)}`).width('100%').attributeModifier(new MooTextModifier());
                Text(`󰚩  ${addUnitsToSize(item.item.currentSpeed)}/s`).width('100%').attributeModifier(new MooTextModifier());
                Text(`󰊡  ${item.item.url}`).width('100%').attributeModifier(new MooTextModifier()).opacity(0.75).maxLines(3);
                Text(`󰕖  ${item.item.mimeType}`).width('100%').attributeModifier(new MooTextModifier()).opacity(0.5);
                // Control buttons
                Scroll() {
                  UniRowOfCapsuleButtons() {
                    MooCapsuleButton({
                      text: $r('app.string.General_delete'),
                      needDoubleConfirm: true,
                      clickAction: () => {
                        // Delete
                        this.myDawn.deleteDownload(item.item);
                      }
                    });
                    if (item.item.state == webview.WebDownloadState.IN_PROGRESS || item.item.state == webview.WebDownloadState.PAUSED) {
                      MooCapsuleButton({
                        text: $r('app.string.General_cancel'),
                        needDoubleConfirm: true,
                        clickAction: () => {
                          // Cancel
                          this.myDawn.cancelDownload(item.item);
                        }
                      });
                    }
                    MooCapsuleButton({
                      text: $r('app.string.General_copyLink'),
                      clickAction: () => {
                        // Copy
                        copyText(item.item.url);
                      }
                    });
                    if (item.item.state == webview.WebDownloadState.IN_PROGRESS) {
                      MooCapsuleButton({
                        text: $r('app.string.General_pause'),
                        clickAction: () => {
                          // Pause
                          try {
                            item.item.item.pause();
                          } catch (e) {
                            meow(`Failed to pause download #${item.index} (${item.item.fileName}): ${e}`, 'DownloadsPanel');
                          }
                        }
                      });
                    }
                    if (item.item.state == webview.WebDownloadState.PAUSED) {
                      MooCapsuleButton({
                        text: $r('app.string.General_continue'),
                        clickAction: () => {
                          // Continue
                          try {
                            item.item.item.resume();
                          } catch (e) {
                            meow(`Failed to resume download #${item.index} (${item.item.fileName}): ${e}`, 'DownloadsPanel');
                          }
                        }
                      });
                    }
                  };
                }
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar(BarState.Off)
                .scrollable(ScrollDirection.Horizontal);
              };
            });
        }
      };
    }
    .borderRadius(defaultRoundedRadius)
    .align(Alignment.BottomStart)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(this.needLayoutWeightFull ? 1 : undefined)
    .padding(this.needPadding ? standardSpacing : 0)
    .width('100%');
  }

  humanWordState(state: webview.WebDownloadState) {
    switch (state) {
      case webview.WebDownloadState.IN_PROGRESS:
        return $r('app.string.Downloads_state_in_progress');
      case webview.WebDownloadState.COMPLETED:
        return $r('app.string.Downloads_state_completed');
      case webview.WebDownloadState.CANCELED:
        return $r('app.string.Downloads_state_canceled');
      case webview.WebDownloadState.INTERRUPTED:
        return $r('app.string.Downloads_state_interrupted');
      case webview.WebDownloadState.PENDING:
        return $r('app.string.Downloads_state_pending');
      case webview.WebDownloadState.PAUSED:
        return $r('app.string.Downloads_state_paused');
      case webview.WebDownloadState.UNKNOWN:
        return $r('app.string.Downloads_state_unknown');
      default:
        return $r('app.string.General_wait');
    }
  }

  /**
   * Estimate time remaining.
   * @param remaining The remaining part.
   * @param speed The speed.
   * @returns A string.
   */
  estTime(remaining: number, speed: number) {
    if (remaining == 0) return '󰏝  ヽ(°◇° )ノ';
    if (speed == 0) return '󰏝  ∞';
    return '󰏝  ' + addUnitsToSeconds(Math.ceil(remaining / speed));
  }
}
