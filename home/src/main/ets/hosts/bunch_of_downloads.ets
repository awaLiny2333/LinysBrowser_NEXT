// 方式一:request.downloadFile
// pages/xxx.ets
// 将网络资源文件下载到应用文件目录并读取一段内容
import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';

export class bunch_of_downloads {
  list_of_on_going_tasks: request.DownloadTask[] = [];
  list_of_downloaded_size: number[] = [];
  list_of_full_size: number[] = [];
  list_of_file_names: string[] = [];
  list_of_paused: boolean[] = [];
  list_of_urls: string[] = [];
  last_action: number = 0;
  context = AppStorage.get('context') as common.UIAbilityContext;

  /**
   * @param url The https:// proxy url of the download target
   * */
  start_download_task(url: string) {
    let filesDir = getContext().filesDir;
    try {
      fs.mkdirSync(filesDir + '/downloads');
    } catch (e) {
      console.log('[Meow][bunch_of_downloads] E: /downloads already exists.')
    }

    let file_url_split = url.split("/");
    let file_name_question_mark_split = file_url_split[file_url_split.length-1].split("?");
    let file_name = file_name_question_mark_split[0];
    let download_target_path = filesDir + '/downloads/' + file_name;

    let config: request.DownloadConfig = {
      url: url,
      filePath: download_target_path,
    };

    try {
      request.downloadFile(this.context, config).then((downloadTask: request.DownloadTask) => {
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
            this.list_of_file_names[my_index] = info.fileName;
            this.list_of_urls[my_index] = info.targetURI;
            // Update related info
          })

          this.last_action = Date.now();
          // Refresh
        })

        downloadTask.on('pause', () => {
          console.info('[bunch_of_downloads] Download paused');
          this.last_action = Date.now();
        })

        this.list_of_on_going_tasks.push(downloadTask);
        this.list_of_downloaded_size.push(0);
        this.list_of_paused.push(false);
        downloadTask.getTaskInfo().then((info) => {
          this.list_of_full_size.push(info.downloadTotalBytes);
          this.list_of_file_names.push(info.fileName);
          this.list_of_urls.push(info.targetURI);
        })
        // Register on download start

      })
        .catch((err: BusinessError) => {
          console.error(`[bunch_of_downloads][ERROR] Invoke downloadTask failed, code is ${err.code}, message is ${err.message}`);
        });

    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`[bunch_of_downloads][ERROR] Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  pause_task(index: number) {
    this.list_of_on_going_tasks[index].suspend();
    this.list_of_paused[index] = true;
  }

  continue_task(index: number) {
    this.list_of_on_going_tasks[index].restore();
    this.list_of_paused[index] = false;
  }

  async delete_task(index: number) {

    let file_path = (await this.list_of_on_going_tasks[index].getTaskInfo()).filePath

    try {
      fs.unlink(file_path)
    } catch (e) {
      console.log("[bunch_of_downloads][delete_task] Unlink file failed. " + e)
    }

    this.list_of_on_going_tasks[index].delete();

    this.list_of_on_going_tasks.splice(index, 1);
    this.list_of_downloaded_size.splice(index, 1);
    this.list_of_full_size.splice(index, 1);
    this.list_of_file_names.splice(index, 1);
    this.list_of_paused.splice(index, 1);
    this.list_of_urls.splice(index, 1);

    this.last_action = Date.now();
  }

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

    try {
      let documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [file_name];
      let documentPicker = new picker.DocumentViewPicker(this.context);

      await documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
        target_uri = documentSaveResult
        console.log("[bunch_of_downloads][Export] from: " + file_path)
        console.log("[bunch_of_downloads][Export] to: " + target_uri[0])

        // let file_from = fs.openSync(file_path, fs.OpenMode.READ_WRITE);
        // let array_buffer = new ArrayBuffer(file_size + 256);
        // fs.readSync(file_from.fd, array_buffer);
        // fs.closeSync(file_from);
        // // Read
        // let file = fs.openSync(target_uri[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        // let writeLen = fs.writeSync(file.fd, array_buffer);
        // fs.closeSync(file);

        let target_path = (new fileUri.FileUri(target_uri[0])).path;
        let writeLen = file_size;
        fs.moveFileSync(file_path, target_path);
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
    // Save

  }

  delete_all_downloaded_files() {
    try {
      let filesDir = getContext().filesDir;
      let list = fs.listFileSync(filesDir + "/downloads");

      for (let index = 0; index < list.length; index++) {
        fs.unlink(filesDir + "/downloads/" + list[index]);
      }
      // Delete all downloaded files
    } catch (e) {
      console.log(e)
    }
  }
}