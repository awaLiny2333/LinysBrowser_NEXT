import lazy { UIContext } from "@kit.ArkUI";
import lazy { webview } from "@kit.ArkWeb";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { retrieveDownloadDirectory, showInFiles, uri_2_path } from "../../../../catstypicalframework/utils/storage";
import lazy { defaultAnimation } from "../../../../components/settings";
import lazy { openDialogRequestType } from "../../../system/dialogs/classes/meowDialogManager";
import lazy { requestDialogOnMostRecent } from "../../../system/dialogs/scripts/dialog";
import lazy { isDownloadAutoView } from "../settings";
import lazy { meowDawnloadaItem } from "./meowDawnloadaItem";
import lazy { common } from "@kit.AbilityKit";

@ObservedV2
export class meowDawnloada {
  delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();
  @Trace items: meowDawnloadaItem[] = [];
  // Status
  @Trace totalSize: number = 0;
  @Trace currentSize: number = 0;
  @Trace progress: number = 0;
  @Trace currentSpeed: number = 0;

  constructor() {
    this.delegate.onBeforeDownload((item) => {
      meow(`onBeforeDownload: [${item.getGuid()}][${item.getUrl()}]`, 'meowDawnloada', meowLevel.WARN);
      // Request the dialog to ask if want download.
      requestDialogOnMostRecent(openDialogRequestType.DOWNLOAD_ASK, item, true);
    });
    this.delegate.onDownloadUpdated((item) => {
      meow(`onDownloadUpdated: [${item.getGuid()}][${item.getUrl()}]`, 'meowDawnloada', meowLevel.WARN);
      const meowItem = this.meowItemOf(item);
      if (!meowItem) {
        return;
      }
      meowItem.fetchUpdate(item);
      this.statusUpdate();
    });
    this.delegate.onDownloadFailed((item) => {
      meow(`onDownloadFailed: [${item.getGuid()}][${item.getUrl()}]`, 'meowDawnloada', meowLevel.ERROR);
      const meowItem = this.meowItemOf(item);
      if (!meowItem) {
        return;
      }
      meowItem.fetchUpdate(item);
      this.statusUpdate();
    });
    this.delegate.onDownloadFinish((item) => {
      meow(`onDownloadFinish: [${item.getGuid()}][${item.getUrl()}]`, 'meowDawnloada', meowLevel.WARN);
      const meowItem = this.meowItemOf(item);
      if (!meowItem) {
        return;
      }
      meowItem.fetchUpdate(item);
      this.statusUpdate();
      if (isDownloadAutoView()) {
        const context = UIContext.getLastFocusedUIContext()?.getHostContext() as common.UIAbilityContext;
        if (context) {
          showInFiles(item.getFullPath(), context);
        } else {
          meow(`Fetch UIContext failed for auto view!`, 'meowDawnloada][confirmDownload', meowLevel.ERROR);
        }
      }
    });
  }

  /**
   * Confirm the download of a webview.WebDownloadItem, and "start" the download.
   * @param item The webview.WebDownloadItem.
   */
  confirmDownload(item: webview.WebDownloadItem, filename: string = item.getSuggestedFileName()) {
    // Get download directory.
    const context = UIContext.getCallingScopeUIContext()?.getHostContext();
    if (!context) {
      meow(`Fetch UIContext failed for download item: [${item.getGuid()}][${item.getUrl()}]`, 'meowDawnloada][confirmDownload', meowLevel.ERROR);
      item.cancel();
    }
    return retrieveDownloadDirectory(context!).then((dlDir) => {
      // Construct a meowDawnloadaItem and push it to the class-managed list.
      const meowItem = new meowDawnloadaItem(item);
      meowItem.fileName = filename;
      const targetPath = uri_2_path(`${dlDir}/${filename}`);
      item.start(targetPath);
      meow(`confirmDownload: [${item.getGuid()}][${item.getUrl()}] → [${targetPath}]`, 'meowDawnloada][confirmDownload', meowLevel.WARN);
      setTimeout(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.items.push(meowItem);
        });
      });
    });
  }

  /**
   * Deny the download of a webview.WebDownloadItem, and cancel the download.
   * @param item The webview.WebDownloadItem.
   */
  denyDownload(item: webview.WebDownloadItem) {
    item.cancel();
    meow(`denyDownload: [${item.getGuid()}][${item.getUrl()}]`, 'meowDawnloada][denyDownload', meowLevel.WARN);
  }

  /**
   * Cancel the download of a meowDawnloadaItem, and cancel the download.
   * @param meowItem The meowDawnloadaItem.
   */
  cancelDownload(meowItem: meowDawnloadaItem) {
    meowItem.item.cancel();
    meow(`cancelDownload: [${meowItem.item.getGuid()}][${meowItem.item.getUrl()}]`, 'meowDawnloada][cancelDownload', meowLevel.WARN);
  }

  /**
   * Delete the download of a meowDawnloadaItem, and delete the download from the list.
   * @param meowItem The meowDawnloadaItem.
   */
  deleteDownload(meowItem: meowDawnloadaItem) {
    try {
      meowItem.item.cancel();
    } catch (e) {
      meow(`deleteDownload cancel [${meowItem.item.getGuid()}][${meowItem.item.getUrl()}] failed: ${e}`, 'meowDawnloada][deleteDownload', meowLevel.ERROR);
    }
    animateToImmediately(defaultAnimation(), () => {
      this.items.splice(this.items.indexOf(meowItem), 1);
    });
  }

  /**
   * Updates the overall download statuses by examining all the download items in list.
   */
  statusUpdate() {
    this.totalSize = 0;
    this.currentSize = 0;
    this.currentSpeed = 0;
    for (const meowItem of this.items) {
      if (meowItem.state != webview.WebDownloadState.IN_PROGRESS && meowItem.state != webview.WebDownloadState.PAUSED && meowItem.state != webview.WebDownloadState.COMPLETED) {
        continue; // Skip invalid tasks.
      }
      this.totalSize += meowItem.item.getTotalBytes();
      this.currentSize += meowItem.item.getReceivedBytes();
      this.currentSpeed += meowItem.item.getCurrentSpeed();
    }
    this.progress = Math.round(this.currentSize / this.totalSize * 100);
  }

  /**
   * Get the meowDawnloadaItem of a webview.WebDownloadItem.
   * @param webDlItem The webview.WebDownloadItem.
   * @returns The meowDawnloadaItem or undefined if not found (Which indicates a bug).
   */
  private meowItemOf(webDlItem: webview.WebDownloadItem): meowDawnloadaItem | undefined {
    for (const meowItem of this.items) {
      if (meowItem.item.getGuid() === webDlItem.getGuid()) {
        return meowItem;
      }
    }
    return undefined;
  }
}
