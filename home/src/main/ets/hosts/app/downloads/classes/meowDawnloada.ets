import lazy { common } from "@kit.AbilityKit";
import lazy { AppStorageV2, UIContext } from "@kit.ArkUI";
import lazy { webview } from "@kit.ArkWeb";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { fileDirExist, makeFilenameLegal, retrieveDownloadDirectory, showInFiles, uri_2_path } from "../../../../catstypicalframework/utils/storage";
import lazy { defaultAnimation } from "../../../../components/settings";
import lazy { openDialogRequestType } from "../../../system/dialogs/classes/meowDialogManager";
import lazy { requestDialogOnMostRecent } from "../../../system/dialogs/scripts/dialog";
import { getAllWindowIds, getLastWindowId } from "../../../system/windows/scripts/multiwindows";
import { meowTabsBunch } from "../../tabs/classes/meowTabsBunch";
import lazy { isDownloadAutoView } from "../settings";
import lazy { meowDawnloadaItem } from "./meowDawnloadaItem";

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
      return; // Context not found, stop the script. This is not likely to happen...
    }
    return retrieveDownloadDirectory(context!).then(async (dlDir) => {
      // Construct a meowDawnloadaItem and push it to the class-managed list.
      const meowItem = new meowDawnloadaItem(item);
      filename = makeFilenameLegal(filename); // Eliminate illegal chars, e.g. "/" or "?" input by the user.
      meowItem.fileName = filename;
      const targetPath = uri_2_path(`${dlDir}/${filename}`);

      // Check if the file already exists.
      if (await fileDirExist(targetPath)) {
        meow(`File already exists: [${targetPath}]`, 'meowDawnloada][confirmDownload', meowLevel.WARN);
        item.cancel();
        return;
      }

      // LINKSTART
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
      const total = meowItem.item.getTotalBytes();
      if (total > 0) {
        this.totalSize += total;
      } else {
        this.totalSize += meowItem.item.getReceivedBytes(); // For cases in which the server doesn't report Content-Length, getTotalBytes() = -1. We put the receivedBytes instead here.
      }
      this.currentSize += meowItem.item.getReceivedBytes();
      this.currentSpeed += meowItem.item.getCurrentSpeed();
    }
    if (this.totalSize === 0) {
      this.progress = 100;
      return;
    }
    this.progress = Math.round(this.currentSize / this.totalSize * 100);
  }

  /**
   * Start a download task.
   * @param url The url.
   */
  async startDownload(url: string) {
    meow(`startDownload: [${url}]`, 'meowDawnloada][startDownload', meowLevel.WARN);

    const wIds = getAllWindowIds();
    for (const wId of wIds) {
      const theTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${wId}`);
      if (theTabs?.currentTab?.controller) {
        try {
          theTabs.currentTab.controller.startDownload(url);
          return;
        } catch (e) {
          meow(`startDownload failed: ${e}`, 'meowDawnloada][startDownload', meowLevel.ERROR);
          return;
        }
      }
    }

    // Fallback. This is not elegant... :O
    const randomTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${getLastWindowId()}`);
    if (randomTabs) {
      const t = await randomTabs.newTabWrapped();
      setTimeout(() => {
        try {
          t.controller?.startDownload(url);
        } catch (e) {
          meow(`startDownload failed: ${e}`, 'meowDawnloada][startDownload', meowLevel.ERROR);
        }
      }, 100);
    }
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
