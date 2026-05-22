import lazy { webview } from "@kit.ArkWeb";
import lazy { meow } from "../../../catstypicalframework/utils/catsLogger";
import lazy { copyText } from "../../../catstypicalframework/utils/clipboard";
import lazy { resource2String, symbolForFileType } from "../../../catstypicalframework/utils/resource";
import lazy { addUnitsToSize } from "../../../catstypicalframework/utils/storage";
import lazy { addUnitsToSeconds } from "../../../catstypicalframework/utils/strings";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { meowDawnloada } from "../../../hosts/app/downloads/classes/meowDawnloada";
import lazy { getMyDawn } from "../../../hosts/app/downloads/scripts/helper";
import lazy { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooProgress } from "../../common/MooProgress";
import { MooTextModifier } from "../../common/MooTextModifier";
import lazy { UniContentCard } from "../../common/UniContentCard";
import lazy { UniRowOfCapsuleButtons } from "../../common/UniRowOfCapsuleButtons";
import { mooTextType, standardSpacing } from "../../constants";
import lazy { useEffects } from "../../settings";

@ComponentV2
export struct DownloadsPanel {
  @Param @Once needPadding: boolean = true;
  // Hosts
  @Local myDawn: meowDawnloada = getMyDawn();

  build() {
    Column({ space: standardSpacing }) {
      Scroll() {
        Column({ space: standardSpacing }) {
          if (this.myDawn.items.length == 0) {
            Text($r('app.string.General_empty')).attributeModifier(new MooTextModifier(mooTextType.TITLE))
              .layoutWeight(1).width('100%')
              .opacity(0.5).textAlign(TextAlign.Center).padding(standardSpacing * 2);
          } else {
            Repeat(this.myDawn.items)
              .each((item) => {
                UniContentCard({
                  title: `${item.item.fileName} (${item.item.progress}%)`, icon: symbolForFileType(item.item.mimeType),
                  roundedRadius: defaultInnerRadius, shiftBackgroundColor: !useEffects(), expanded: true
                }) {
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
                          this.myDawn.deleteDownload(item.item); // Delete
                        }
                      });
                      if (item.item.state == webview.WebDownloadState.IN_PROGRESS || item.item.state == webview.WebDownloadState.PAUSED) {
                        MooCapsuleButton({
                          text: $r('app.string.General_cancel'),
                          needDoubleConfirm: true,
                          clickAction: () => {
                            this.myDawn.cancelDownload(item.item); // Cancel
                          }
                        });
                      }
                      MooCapsuleButton({
                        text: $r('app.string.General_copyLink'),
                        clickAction: () => {
                          copyText(item.item.url); // Copy
                        }
                      });
                      if (item.item.state == webview.WebDownloadState.IN_PROGRESS) {
                        MooCapsuleButton({
                          text: $r('app.string.General_pause'),
                          clickAction: () => {
                            try {
                              item.item.item.pause(); // Pause
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
                            try {
                              item.item.item.resume(); // Continue
                            } catch (e) {
                              meow(`Failed to resume download #${item.index} (${item.item.fileName}): ${e}`, 'DownloadsPanel');
                            }
                          }
                        });
                      }
                    };
                  }
                  .borderRadius(defaultInnerRadius)
                  .edgeEffect(EdgeEffect.Spring)
                  .scrollBar(BarState.Off)
                  .scrollable(ScrollDirection.Horizontal);
                  // Progress
                  MooProgress({
                    show: item.item.state == webview.WebDownloadState.IN_PROGRESS || item.item.state == webview.WebDownloadState.PAUSED,
                    percentage: item.item.progress,
                    rounded: true
                  });
                };
              });
          }
        };
      }
      .layoutWeight(1)
      .borderRadius(defaultInnerRadius)
      .align(Alignment.BottomStart)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%');

      // Overview
      UniContentCard({
        title: `${resource2String($r('app.string.Downloads_overview'), this.getUIContext().getHostContext()!)} (${this.myDawn.progress}%)`,
        icon: $r('sys.symbol.download'), roundedRadius: defaultInnerRadius, shiftBackgroundColor: !useEffects(), expanded: true
      }) {
        Text(this.estTime(this.myDawn.totalSize - this.myDawn.currentSize, this.myDawn.currentSpeed)).width('100%').attributeModifier(new MooTextModifier());
        if (this.myDawn.totalSize > 0) {
          Text(`󰙧  ${addUnitsToSize(this.myDawn.currentSize)}/${addUnitsToSize(this.myDawn.totalSize)}`).width('100%').attributeModifier(new MooTextModifier());
          Text(`󰚩  ${addUnitsToSize(this.myDawn.currentSpeed)}/s`).width('100%').attributeModifier(new MooTextModifier());
        }
        // Progress
        MooProgress({
          show: this.myDawn.totalSize > 0,
          percentage: this.myDawn.progress,
          rounded: true
        });
      };
    }
    .padding(this.needPadding ? standardSpacing : 0)
    .layoutWeight(1);
  }

  /**
   * Human-readable descriptions for download state.
   * @param state The webview.WebDownloadState.
   * @returns The ResourceStr of description.
   */
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
