import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { webview } from '@kit.ArkWeb';
import { add_units_to_size, download_save_from_path } from '../utils/storage_tools';
import woofWantDownload from '../dialogs/prompts/woofWantDownload';
import { open_file_uri } from '../utils/link_tools';
import { meowContext } from '../utils/environment_tools';

let context = meowContext();

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
  // dialogs
  woofWantDownload_control: CustomDialogController = new CustomDialogController({
    builder: woofWantDownload({
      from: '',
      file_name: '',
      url: '',
      try_additional_info: ''
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })

  /**
   * A class to handle download tasks.
   * Will ENSURE there is a downloads directory in the sandbox directory on creation.
   * @param no_init Will not check directory existence nor do anything else.
   * Usually set true if this object is only created to sit the place of StorageLink initialization.
   */
  constructor(no_init?: boolean) {
    if (no_init == true) {
      return;
    }
    let filesDir = context.filesDir;
    try {
      fs.mkdirSync(filesDir + '/downloads');
    } catch (e) {
      // console.log('[Meow][bunch_of_downloads] Init: E: /downloads already exists.')
    }

    // console.log('[Meow][bunch_of_downloads] Init success!')
  }

  /**
   * Initializes the download delegate for normal http downloads.
   * Delegate: AppStorage.get('dl_delegate')
   * */
  init_dl_delegate() {
    // get additional info
    let additional_info: string[] = [];
    let try_additional_info = AppStorage.get('universal_new_download_additional_info') as string;
    if (try_additional_info) {
      additional_info = try_additional_info.split('\n');
    }

    // Init dl_delegate
    let dl_delegate = AppStorage.get('dl_delegate') as webview.WebDownloadDelegate;
    dl_delegate.onBeforeDownload((webDownloadItem: webview.WebDownloadItem) => {

      // Determine file name
      let file_name = AppStorage.get('universal_new_download_filename_gateway') as string;
      AppStorage.set('universal_new_download_filename_gateway', '');
      if (file_name.length < 3) {
        file_name = webDownloadItem.getSuggestedFileName();
      }
      // Create task folder
      let file_dir = context.filesDir + '/downloads/' + file_name + '_' + Date.now().toString() + '/';
      try {
        fs.mkdirSync(file_dir);
      } catch (e) {
        console.log('[Meow][bunch_of_downloads] Task folder already created')
      }
      // connect path
      let download_target_path = file_dir + file_name;

      // Register on download start
      this.list_of_on_going_tasks.push(webDownloadItem);
      this.list_of_downloaded_size.push(0);
      this.list_of_download_speed.push(0);
      this.list_of_full_size.push(-1);
      this.list_of_paused.push(false);
      this.list_of_completed.push(false);
      this.list_of_additional_info.push(additional_info);
      this.list_of_target_folders.push(file_dir);
      this.list_of_file_names.push(file_name);
      this.list_of_urls.push(webDownloadItem.getUrl());
      this.list_of_failed.push(false);
      // this.list_of_urls.push('url');

      // LINK START!
      try {
        webDownloadItem.start(download_target_path);
      } catch (e) {
        console.error(e);
        return;
      }
      console.log('[bunch_of_downloads] dl_delegate.onBeforeDownload! download_target_path: [' + download_target_path + ']')

      // Update Class
      this.last_action = Date.now();
    })

    dl_delegate.onDownloadUpdated((webDownloadItem: webview.WebDownloadItem) => {
      this.onDownloadUpdated(webDownloadItem);
    })

    dl_delegate.onDownloadFailed((webDownloadItem: webview.WebDownloadItem) => {
      console.error("[bunch_of_downloads] download failed guid: " + webDownloadItem.getGuid());
      console.error("[bunch_of_downloads] download failed error: " + webDownloadItem.getLastErrorCode());
      this.list_of_failed[this.index_of_task(webDownloadItem)] = true;
      this.list_of_paused[this.index_of_task(webDownloadItem)] = true;
      this.last_action = Date.now();
    })

    dl_delegate.onDownloadFinish((webDownloadItem: webview.WebDownloadItem) => {
      this.onDownloadFinish(webDownloadItem);
    })
  }

  /**
   * Initializes the download delegate for blob downloads.
   * Delegate: AppStorage.get('blob_delegate')
   * */
  init_blob_delegate() {
    // Init blob_delegate
    let blob_delegate = AppStorage.get('blob_delegate') as webview.WebDownloadDelegate;

    blob_delegate.onBeforeDownload((webDownloadItem: webview.WebDownloadItem) => {

      if (webDownloadItem.getUrl().substring(0, 5) != 'blob:') {
        return;
      }

      AppStorage.set('universal_new_download_gateway', 'meow');
      AppStorage.set('universal_new_download_gateway', '');

      let additional_info: string[] = [
        'url: ' + webDownloadItem.getUrl(),
        'type: Blob download, so less info here owo.',
        'meow: meow meow meow', // To express my joy after fixing this download logic @ Jun 22 2025!
        'totalBytes: ' + webDownloadItem.getTotalBytes().toString(),
        'mimetype: ' + webDownloadItem.getMimeType(),
      ];

      // Determine file name
      let file_name = webDownloadItem.getSuggestedFileName();

      // Create task folder
      let file_dir = context.filesDir + '/downloads/' + file_name + '_' + Date.now().toString() + '/';
      try {
        fs.mkdirSync(file_dir);
      } catch (e) {
        console.log('[Meow][bunch_of_downloads] Task folder already created')
      }
      // connect path
      let download_target_path = file_dir + file_name;

      // Register on download start
      this.list_of_on_going_tasks.push(webDownloadItem);
      this.list_of_downloaded_size.push(0);
      this.list_of_download_speed.push(0);
      this.list_of_full_size.push(-1);
      this.list_of_paused.push(false);
      this.list_of_completed.push(false);
      this.list_of_additional_info.push(additional_info);
      this.list_of_target_folders.push(file_dir);
      this.list_of_file_names.push(file_name);
      this.list_of_urls.push(webDownloadItem.getUrl());
      this.list_of_failed.push(false);
      // this.list_of_urls.push('url');

      // LINK START!
      try {
        webDownloadItem.start(download_target_path);
      } catch (e) {
        console.error(e);
        return;
      }
      console.log('[bunch_of_downloads] dl_delegate.onBeforeDownload! download_target_path: [' + download_target_path + ']')


      // Update Class
      this.last_action = Date.now();
    })

    blob_delegate.onDownloadUpdated((webDownloadItem: webview.WebDownloadItem) => {
      this.onDownloadUpdated(webDownloadItem);
    })

    blob_delegate.onDownloadFailed((webDownloadItem: webview.WebDownloadItem) => {
      console.error("[bunch_of_downloads] download failed guid: " + webDownloadItem.getGuid());
      console.error("[bunch_of_downloads] download failed error: " + webDownloadItem.getLastErrorCode());
      this.list_of_failed[this.index_of_task(webDownloadItem)] = true;
      this.list_of_paused[this.index_of_task(webDownloadItem)] = true;
      this.last_action = Date.now();
    })

    blob_delegate.onDownloadFinish((webDownloadItem: webview.WebDownloadItem) => {
      this.onDownloadFinish(webDownloadItem);
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

  onDownloadFinish(webDownloadItem: webview.WebDownloadItem) {
    // console.info('[bunch_of_downloads] Download complete, path: ' + download_target_path);

    // Get my index
    let my_index = this.index_of_task(webDownloadItem);

    // Update list
    this.list_of_full_size[my_index] = this.list_of_downloaded_size[my_index];
    this.list_of_paused[my_index] = false;
    this.list_of_completed[my_index] = true;

    // webDownloadItem.stop(); // No longer need this! owo

    let direct_download = AppStorage.get('direct_download') as boolean;
    let direct_download_auto_open = AppStorage.get('direct_download_auto_open') as boolean;
    if (direct_download) {
      this.save_downloaded_item_to_download(my_index).then((uri) => {
        if (uri && direct_download_auto_open) {
          open_file_uri(uri);
        }
      });
    }

    // Refresh
    this.last_action = Date.now();
  }

  /**
   * Start a download task in this bunch_of_downloads.
   * @param url The https:// proxy url of the download target
   * */
  start_download_task(url: string) {
    if (url.substring(0, 5) == 'blob:') {
      return;
    }

    // Init
    this.init_dl_delegate();

    // Invoke download
    console.log('[meow][bunch_of_downloads] Try to invoke download on dl_controller!');
    let dl_controller = AppStorage.get('dl_controller') as webview.WebviewController;

    try {
      dl_controller.startDownload(url);
    } catch (e) {
      console.error(e);
    }
  }

  /**
   * Pause a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be paused.
   * */
  pause_task(index: number) {
    this.list_of_on_going_tasks[index].pause();
    // this.list_of_paused[index] = true;

    // Refresh
    // this.last_action = Date.now();
  }

  /**
   * Resume a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be resumed.
   * */
  continue_task(index: number) {
    this.list_of_on_going_tasks[index].resume();
    // this.list_of_paused[index] = false;

    // Refresh
    // this.last_action = Date.now();
  }

  /**
   * Delete a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be deleted.
   * */
  delete_task(index: number) {

    this.list_of_on_going_tasks[index].cancel();

    try {
      fs.rmdir(this.list_of_target_folders[index]);
    } catch (e) {
      console.error("[ERROR][bunch_of_downloads][delete_task] Delete task file failed. " + e)
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
      let documentPicker = new picker.DocumentViewPicker(context);

      await documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
        target_uri = documentSaveResult
        console.log("[bunch_of_downloads][Export] from: " + file_path + file_name)
        console.log("[bunch_of_downloads][Export] to: " + target_uri[0])

        // let target_path = (new fileUri.FileUri(target_uri[0])).path;
        // This operation is likely to cause target_path
        // to be identified as unauthorized!

        let writeLen = file_size;
        fs.copy(fileUri.getUriFromPath(file_path + file_name), target_uri[0])
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
    let from = file_path + '/' + file_name;
    console.log('[bunch_of_downloads] Trying to save_downloaded_item_to_download: [' + from + ']');
    let uri_back = await download_save_from_path(from);
    return uri_back;
  }

  /**
   * Delete all downloaded files in sandbox storage,
   * usually executed when the app launches.
   * */
  delete_all_downloaded_files() {
    try {
      let filesDir = context.filesDir;
      fs.rmdirSync(filesDir + "/downloads");
      fs.mkdirSync(filesDir + "/downloads")

      // let list = fs.listFileSync(filesDir + "/downloads");
      //
      // for (let index = 0; index < list.length; index++) {
      //   fs.rmdir(filesDir + "/downloads/" + list[index]);
      // }
      // Delete all downloaded files
    } catch (e) {
      console.error(e)
    }
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