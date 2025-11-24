import { fileIo as fs, } from '@kit.CoreFileKit';
import lazy { fileUri, picker } from '@kit.CoreFileKit';
import { webview } from '@kit.ArkWeb';
import { add_units_to_size, download_save_from_path } from '../utils/storage_tools';
import { common } from '@kit.AbilityKit';
import lazy { BusinessError } from '@kit.BasicServicesKit';
import lazy { open_file_uri } from '../utils/link_tools';

export class bunch_of_downloads {
  list_of_on_going_tasks: webview.WebDownloadItem[] = [];
  list_of_downloaded_size: number[] = [];
  list_of_download_speed: number[] = [];
  list_of_target_folders: string[] = [];
  list_of_full_size: number[] = [];
  list_of_file_names: string[] = [];
  list_of_paused: boolean[] = [];
  list_of_urls: string[] = [];
  list_of_completed: boolean[] = [];
  list_of_additional_info: string[][] = [];
  list_of_failed: boolean[] = [];
  last_action: number = 0;

  /**
   * A class to handle download tasks.
   * Will ENSURE there is a downloads directory in the sandbox directory on creation.
   * @param no_init Will not check directory existence nor do anything else.
   * Usually set true if this object is only created to sit the place of StorageLink initialization.
   */
  constructor() {
    console.log('[Meow][bunch_of_downloads] Init success!');
  }

  /**
   * Initializes the download delegate for blob downloads.
   * Delegate: AppStorage.get('dl_delegate')
   * */
  init_delegate(storage: LocalStorage) {
    // Init blob_delegate
    let dl_delegate = storage.get('dl_delegate') as webview.WebDownloadDelegate;

    dl_delegate.onBeforeDownload((webDownloadItem: webview.WebDownloadItem) => {
      console.log('[bunch_of_downloads][init_delegate] onBeforeDownload: [' + webDownloadItem.getSuggestedFileName() + '][' + webDownloadItem.getUrl() + ']');

      // See meowWebView and woofWantDownload for further handling
      storage.set('uni_webDownloadItem_gateway', webDownloadItem);

      this.update_timestamp();
    })

    dl_delegate.onDownloadUpdated((webDownloadItem: webview.WebDownloadItem) => {
      this.onDownloadUpdated(webDownloadItem);
    })

    dl_delegate.onDownloadFailed((webDownloadItem: webview.WebDownloadItem) => {
      let index = this.index_of_task(webDownloadItem);
      console.error("[bunch_of_downloads] download failed index: " + index);
      console.error("[bunch_of_downloads] download failed guid: " + webDownloadItem.getGuid());
      console.error("[bunch_of_downloads] download failed error: " + webDownloadItem.getLastErrorCode());
      this.list_of_failed[index] = true;
      this.list_of_paused[index] = true;
      this.last_action = Date.now();
    })

    dl_delegate.onDownloadFinish((webDownloadItem: webview.WebDownloadItem) => {
      this.onDownloadFinish(webDownloadItem, storage);
    })
  }

  onDownloadUpdated(webDownloadItem: webview.WebDownloadItem) {
    // console.log("download update guid: " + webDownloadItem.getGuid());

    // Get my index
    let my_index = this.index_of_task(webDownloadItem);

    console.info('[bunch_of_downloads] Download progress of index <' + my_index.toString() + '>: '
      + add_units_to_size(webDownloadItem.getReceivedBytes())
      + ", total: " + add_units_to_size(webDownloadItem.getTotalBytes()));

    this.list_of_downloaded_size[my_index] = webDownloadItem.getReceivedBytes();
    this.list_of_full_size[my_index] = webDownloadItem.getTotalBytes();
    this.list_of_download_speed[my_index] = webDownloadItem.getCurrentSpeed();

    if (webDownloadItem.getState() == webview.WebDownloadState.PAUSED) {
      this.list_of_paused[my_index] = true;
    } else if (webDownloadItem.getState() == webview.WebDownloadState.IN_PROGRESS) {
      this.list_of_paused[my_index] = false;
    }

    // Refresh
    this.last_action = Date.now();
  }

  onDownloadFinish(webDownloadItem: webview.WebDownloadItem, storage: LocalStorage) {
    // console.info('[bunch_of_downloads] Download complete, path: ' + download_target_path);

    // Get my index
    let my_index = this.index_of_task(webDownloadItem);

    // Update list
    this.list_of_full_size[my_index] = this.list_of_downloaded_size[my_index];
    this.list_of_paused[my_index] = false;
    this.list_of_completed[my_index] = true;

    let direct_download = AppStorage.get('direct_download') as boolean;
    let direct_download_auto_open = AppStorage.get('direct_download_auto_open') as boolean;
    if (direct_download) {
      this.save_downloaded_item_to_download(my_index).then((uri) => {
        if (uri && direct_download_auto_open) {
          open_file_uri(uri, storage.get('context') as common.UIAbilityContext);
        }
      });
    }

    // Refresh
    this.last_action = Date.now();
  }

  /**
   * Pause a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be paused.
   * */
  pause_task(index: number) {
    try {
      this.list_of_on_going_tasks[index].pause();
    } catch (e) {
      console.error('[pause_task] Failed: ' + e);
    }
    // this.list_of_paused[index] = true;

    // Refresh
    // this.last_action = Date.now();
  }

  /**
   * Resume a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be resumed.
   * */
  continue_task(index: number) {
    try {
      this.list_of_on_going_tasks[index].resume();
    } catch (e) {
      console.error('[pause_task] Failed: ' + e);
    }
    // this.list_of_paused[index] = false;

    // Refresh
    // this.last_action = Date.now();
  }

  /**
   * Delete a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be deleted.
   * */
  delete_task(index: number) {
    try {
      this.list_of_on_going_tasks[index].cancel();
    } catch (e) {
      console.error('[bunch_of_downloads][delete_task] Cancel task failed: ' + e);
    }

    try {
      fs.rmdir(this.list_of_target_folders[index]).catch((e: BusinessError) => {
        console.error("[ERROR][bunch_of_downloads][delete_task] Delete task file failed. " + e);
      });
    } catch (e) {
      console.error("[ERROR][bunch_of_downloads][delete_task] Delete task file failed. " + e);
    }

    this.list_of_on_going_tasks.splice(index, 1);
    this.list_of_downloaded_size.splice(index, 1);
    this.list_of_download_speed.splice(index, 1);
    this.list_of_target_folders.splice(index, 1);
    this.list_of_full_size.splice(index, 1);
    this.list_of_file_names.splice(index, 1);
    this.list_of_paused.splice(index, 1);
    this.list_of_urls.splice(index, 1);
    this.list_of_completed.splice(index, 1);
    this.list_of_additional_info.splice(index, 1);
    this.list_of_failed.splice(index, 1);

    this.last_action = Date.now();
  }

  /**
   * Move a downloaded item, specified by the index, from sandbox directory to a device directory.
   * @param index The index of target file in the tasks list to be moved.
   * */
  async save_downloaded_item_to_local(index: number) {
    if (!this.list_of_completed[index]) {
      return;
    }

    // Finished task, do job
    let file_path = this.list_of_target_folders[index];
    let file_name = this.list_of_file_names[index];
    let file_size = this.list_of_full_size[index];
    let target_uri: string[] = [];

    // Save
    try {
      let documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [file_name];
      let documentPicker = new picker.DocumentViewPicker();

      await documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
        target_uri = documentSaveResult
        console.log("[bunch_of_downloads][Export] from: " + file_path + file_name)
        console.log("[bunch_of_downloads][Export] to: " + target_uri[0])

        // let target_path = (new fileUri.FileUri(target_uri[0])).path;
        // This operation is likely to cause target_path
        // to be identified as unauthorized!

        let writeLen = file_size;
        fs.copy(fileUri.getUriFromPath(file_path + file_name), target_uri[0]).catch((e: BusinessError) => {
          console.error('[save_downloaded_item_to_local][fs.copy] Failed: ' + e);
        })
        // .then(() => {
        //   fs.rmdir(this.list_of_target_folders[index]);
        // });

        console.info("[bunch_of_downloads] write data to file succeed and size is:" + writeLen + " @ " + target_uri[0]);
        // this.delete_task(index);

      })
        .catch((err: BusinessError) => {
          console.error('[bunch_of_downloads][ERROR] DocumentViewPicker.save failed with err: ' +
          JSON.stringify(err));
        });

    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error('[bunch_of_downloads][ERROR] DocumentViewPicker failed with err: ' + JSON.stringify(err));
    }
  }

  /**
   * Copies a downloaded item, specified by the index, from sandbox directory to device's DOWNLOAD folder.
   * @param index The index of target file in the task list to be moved.
   * */
  async save_downloaded_item_to_download(index: number) {
    if (!this.list_of_completed[index]) {
      return;
    }

    let file_path = this.list_of_target_folders[index];
    let file_name = this.list_of_file_names[index];
    let from_path = file_path + '/' + file_name;
    console.log('[bunch_of_downloads] Trying to save_downloaded_item_to_download: [' + from_path + ']');
    let uri_back = await download_save_from_path(from_path);
    return uri_back;
  }

  /**
   * Updates the timestamp to trigger @Watch refresh
   * */
  update_timestamp() {
    // Update Class
    this.last_action = Date.now();
  }

  private index_of_task(webDownloadItem: webview.WebDownloadItem) {
    for (let index = 0; index < this.list_of_on_going_tasks.length; index++) {
      const t = this.list_of_on_going_tasks[index];
      // console.log('[bunch_of_downloads] index_of_task: testing guid t.Guid(): ' + t.getGuid()
      //   + ', webDownloadItem.getGuid(): ' + webDownloadItem.getGuid() + '.');
      if (t.getGuid() == webDownloadItem.getGuid()) {
        return index;
      }
    }
    return -1;
  }
}