import { webview } from "@kit.ArkWeb";
import { defaultAnimation } from "../../../../components/settings";

@ObservedV2
export class meowDawnloadaItem {
  // Fixed
  item: webview.WebDownloadItem;
  @Trace fileName: string;
  @Trace totalSize: number;
  @Trace url: string;
  @Trace mimeType: string;
  // Dynamic
  @Trace progress: number;
  @Trace state: webview.WebDownloadState;
  @Trace currentSize: number;
  @Trace currentSpeed: number = 0;

  constructor(item: webview.WebDownloadItem) {
    this.item = item;
    this.fileName = item.getSuggestedFileName();
    this.totalSize = item.getTotalBytes();
    this.url = item.getUrl();
    this.mimeType = item.getMimeType();
    this.progress = item.getPercentComplete();
    this.state = item.getState();
    this.currentSize = item.getReceivedBytes();
    this.currentSpeed = item.getCurrentSpeed();
  }

  /**
   * Fetch update from the webview.WebDownloadItem.
   */
  fetchUpdate(item: webview.WebDownloadItem) {
    this.item = item;
    animateToImmediately(defaultAnimation(), () => {
      this.progress = item.getPercentComplete();
      this.state = item.getState();
      this.currentSize = item.getReceivedBytes();
      this.currentSpeed = item.getCurrentSpeed();
    });
    // meow(`DownloadItem: ${this.fileName} - ${this.progress}% (${this.currentSize}/${this.totalSize})`, 'meowDawnloadaItem');
  }
}
