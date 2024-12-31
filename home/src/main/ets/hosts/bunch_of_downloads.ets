import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';

export class bunch_of_downloads {
  list_of_on_going_tasks: request.DownloadTask[] = [];
  list_of_downloaded_size: number[] = [];
  list_of_target_folders: string[] = [];
  list_of_full_size: number[] = [];
  list_of_file_names: string[] = [];
  list_of_paused: boolean[] = [];
  list_of_urls: string[] = [];
  list_of_additional_info: string[][] = [];
  last_action: number = 0;

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

    let filesDir = getContext().filesDir;
    try {
      fs.mkdirSync(filesDir + '/downloads');
    } catch (e) {
      console.log('[Meow][bunch_of_downloads] Init: E: /downloads already exists.')
    }

    console.log('[Meow][bunch_of_downloads] Init success!')
  }

  /**
   * Start a download task in this bunch_of_downloads.
   * @param url The https:// proxy url of the download target
   * */
  start_download_task(url: string) {
    let file_url_split = url.split("/");
    let file_name_question_mark_split = file_url_split[file_url_split.length-1].split("?");
    let file_name = file_name_question_mark_split[0];
    let file_name_overwrite = false;
    let additional_info: string[] = [];

    // get additional info
    let try_additional_info = AppStorage.get('universal_new_download_additional_info') as string;
    if (try_additional_info) {
      additional_info = try_additional_info.split('\n');
    }

    // file name overwrite
    let try_universal_filename = AppStorage.get('universal_new_download_filename_gateway') as string;
    if (try_universal_filename != '') {
      file_name_overwrite = true;
      file_name = try_universal_filename;
      AppStorage.set('universal_new_download_filename_gateway', '');
    }

    // Produce task directory
    let file_dir = getContext().filesDir + '/downloads/' + file_name + '_' + Date.now().toString() + '/';

    // Create task folder
    try {
      fs.mkdirSync(file_dir);
    } catch (e) {
      console.log('[Meow][bunch_of_downloads] Task folder already created')
    }

    // connect path
    let download_target_path = file_dir + file_name;

    let config: request.DownloadConfig = {
      url: url,
      filePath: download_target_path,
    };

    try {
      request.downloadFile(getContext(), config).then((downloadTask: request.DownloadTask) => {
        this.last_action = Date.now();

        downloadTask.on('complete', () => {
          console.info('[bunch_of_downloads] Download complete, path: ' + download_target_path);

          let my_index = this.list_of_on_going_tasks.indexOf(downloadTask);
          // Get my index

          this.list_of_full_size[my_index] = this.list_of_downloaded_size[my_index];
          this.list_of_paused[my_index] = false;
          // Update list

          downloadTask.delete();
          this.last_action = Date.now();
        })

        downloadTask.on('progress', (progress) => {
          console.info('[bunch_of_downloads] Download progress: ' + (progress).toString() + " Bytes");

          let my_index = this.list_of_on_going_tasks.indexOf(downloadTask);
          // Get my index
          this.list_of_downloaded_size[my_index] = progress;

          downloadTask.getTaskInfo().then((info) => {
            this.list_of_full_size[my_index] = info.downloadTotalBytes;
            this.list_of_file_names[my_index] = file_name_overwrite ? file_name : info.fileName;
            this.list_of_urls[my_index] = info.targetURI;
            // Update related info
            // console.info('[bunch_of_downloads] Download file name: ' + info.downloadTitle);
          })

          this.last_action = Date.now();
          // Refresh
        })

        downloadTask.on('pause', () => {
          console.info('[bunch_of_downloads] Download paused');
          this.last_action = Date.now();
        })

        // Register on download start
        this.list_of_on_going_tasks.push(downloadTask);
        this.list_of_downloaded_size.push(0);
        this.list_of_paused.push(false);
        this.list_of_additional_info.push(additional_info);
        this.list_of_target_folders.push(file_dir);

        downloadTask.getTaskInfo().then((info) => {
          this.list_of_full_size.push(info.downloadTotalBytes);
          this.list_of_file_names.push(file_name_overwrite ? file_name : info.fileName);
          this.list_of_urls.push(info.targetURI);
        })

      }).catch((err: BusinessError) => {
        console.error(`[bunch_of_downloads][ERROR] Meow Invoke downloadTask failed, code is ${err.code}, message is ${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`[bunch_of_downloads][ERROR] Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  /**
   * Pause a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be paused.
   * */
  pause_task(index: number) {
    this.list_of_on_going_tasks[index].suspend();
    this.list_of_paused[index] = true;
  }

  /**
   * Resume a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be resumed.
   * */
  continue_task(index: number) {
    this.list_of_on_going_tasks[index].restore();
    this.list_of_paused[index] = false;
  }

  /**
   * Delete a download task in this bunch_of_downloads.
   * @param index The index of target task in the tasks list to be deleted.
   * */
  delete_task(index: number) {

    this.list_of_on_going_tasks[index].delete();

    try {
      fs.rmdir(this.list_of_target_folders[index]);
    } catch (e) {
      console.error("[ERROR][bunch_of_downloads][delete_task] Unlink file failed. " + e)
    }

    this.list_of_on_going_tasks.splice(index, 1);
    this.list_of_downloaded_size.splice(index, 1);
    this.list_of_target_folders.splice(index, 1);
    this.list_of_full_size.splice(index, 1);
    this.list_of_file_names.splice(index, 1);
    this.list_of_paused.splice(index, 1);
    this.list_of_urls.splice(index, 1);
    this.list_of_additional_info.splice(index, 1);

    this.last_action = Date.now();
  }

  /**
   * Move a downloaded item, specified by the index, from sandbox directory to a device directory.
   * @param index The index of target file in the tasks list to be moved.
   * */
  async save_downloaded_item_to_local(index: number) {
    let info = await this.list_of_on_going_tasks[index].getTaskInfo()

    if (info.status != request.SESSION_SUCCESSFUL) {
      return;
    }

    // Finished task, do job
    let file_path = info.filePath;
    let file_name = info.fileName;
    let file_size = info.downloadTotalBytes;
    let target_uri: string[] = [];

    // Save
    try {
      let documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [file_name];
      let documentPicker = new picker.DocumentViewPicker(getContext());

      await documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
        target_uri = documentSaveResult
        console.log("[bunch_of_downloads][Export] from: " + file_path)
        console.log("[bunch_of_downloads][Export] to: " + target_uri[0])

        // let target_path = (new fileUri.FileUri(target_uri[0])).path;
        // This operation is likely to cause target_path
        // to be identified as unauthorized!

        let writeLen = file_size;
        fs.copy(fileUri.getUriFromPath(file_path), target_uri[0]).then(() => {
          // fs.unlink(this.list_of_target_folders[index]);
          fs.rmdir(this.list_of_target_folders[index])
        });

        console.info("[bunch_of_downloads] write data to file succeed and size is:" + writeLen + " @ " +
        target_uri[0]);

        console.info('[bunch_of_downloads] DocumentViewPicker.save successfully, documentSaveResult uri: ' +
        target_uri[0]);

        this.delete_task(index);

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
   * Delete all downloaded files in sandbox storage,
   * usually executed when the app launches.
   * */
  delete_all_downloaded_files() {
    try {
      let filesDir = getContext().filesDir;
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
}