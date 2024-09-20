// 方式一:request.downloadFile
// pages/xxx.ets
// 将网络资源文件下载到应用文件目录并读取一段内容
import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileIo as fs, picker } from '@kit.CoreFileKit';

export class bunch_of_downloads {
  list_of_on_going_tasks: request.DownloadTask[] = [];
  list_of_downloaded_size: number[] = [];
  list_of_full_size: number[] = [];
  list_of_file_names: string[] = [];
  list_of_paused: boolean[] = [];
  last_action: number = 0;
  context = AppStorage.get('context') as common.UIAbilityContext;

  /**
   *
   * @param url The https:// proxy url of the download target
   * */
  start_download_task(url: string) {
    let filesDir = getContext().filesDir;
    let file_url_split = url.split("/")
    let file_name = file_url_split[file_url_split.length-1]
    let download_target_path = filesDir + '/' + file_name;

    let config: request.DownloadConfig = {
      url: url,
      filePath: download_target_path,
    };

    try {
      request.downloadFile(this.context, config).then((downloadTask: request.DownloadTask) => {
        this.last_action = Date.now();

        downloadTask.on('complete', () => {
          console.info('[bunch_of_downloads] Download complete, path: ' + download_target_path);
          // let file = fs.openSync(download_target_path, fs.OpenMode.READ_WRITE);
          // let arrayBuffer = new ArrayBuffer(1024);
          // let readLen = fs.readSync(file.fd, arrayBuffer);
          // let buf = buffer.from(arrayBuffer, 0, readLen);
          // console.info(`The content of file: ${buf.toString()}`);
          // fs.closeSync(file);
          let my_index = this.list_of_on_going_tasks.indexOf(downloadTask);
          this.list_of_full_size[my_index] = this.list_of_downloaded_size[my_index];

          downloadTask.delete();
          this.last_action = Date.now();
        })

        downloadTask.on('progress', (progress) => {
          console.info('[bunch_of_downloads] Download progress: ' + (progress).toString() + " Bytes");

          let my_index = this.list_of_on_going_tasks.indexOf(downloadTask);
          this.list_of_downloaded_size[my_index] = progress;
          downloadTask.getTaskInfo().then((info) => {
            this.list_of_full_size[my_index] = info.downloadTotalBytes;
            // Update full size
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
        })
        console.log(this.list_of_on_going_tasks.length.toString())
        // Register

      })
        .catch((err: BusinessError) => {
          console.error(`[bunch_of_downloads][ERROR] Invoke downloadTask failed, code is ${err.code}, message is ${err.message}`);
        });

    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`[bunch_of_downloads][Error] Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
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

  delete_task(index: number) {
    this.list_of_on_going_tasks[index].delete();
  }

  async get_task_info(index: number) {
    // if (index < 0 || index > this.list_of_on_going_tasks.length - 1) {
    //   return;
    // }
    let task_info_result: request.DownloadInfo;
    task_info_result = await this.list_of_on_going_tasks[index].getTaskInfo()
    return task_info_result;
  }

  save_downloaded_item_to_local(index: number) {
    this.list_of_on_going_tasks[index].getTaskInfo().then(info => {
      if (info.status == request.SESSION_SUCCESSFUL) {
        // Finished task, do job
        let file_path = info.filePath;
        let file_name = info.fileName;
        let file_size = info.downloadTotalBytes;
        let target_uri: string[] = [];

        try {
          let documentSaveOptions = new picker.DocumentSaveOptions();
          documentSaveOptions.newFileNames = [file_name];
          let documentPicker = new picker.DocumentViewPicker(this.context);

          documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
            target_uri = documentSaveResult
            console.log("from: " + file_path)
            console.log("to: " + target_uri[0])

            let file_from = fs.openSync(file_path, fs.OpenMode.READ_WRITE);
            let array_buffer = new ArrayBuffer(file_size + 256);
            fs.readSync(file_from.fd, array_buffer);
            fs.closeSync(file_from);
            // Read

            fs.unlinkSync(file_path);
            // Delete

            let file = fs.openSync(target_uri[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            let writeLen = fs.writeSync(file.fd, array_buffer);
            fs.closeSync(file);

            // let writeLen = fs.moveFileSync(file_path, target_uri[0])
            console.info("[bunch_of_downloads] write data to file succeed and size is:" + writeLen + " @ " +
            target_uri[0]);

            console.info('[bunch_of_downloads] DocumentViewPicker.save successfully, documentSaveResult uri: ' +
            target_uri[0]);

            this.list_of_on_going_tasks.splice(index, 1);
            this.list_of_downloaded_size.splice(index, 1);
            this.list_of_full_size.splice(index, 1);
            this.list_of_file_names.splice(index, 1);
            this.list_of_paused.splice(index, 1);
            this.last_action = Date.now();

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

      } else {
        // Unfinished, no actions
      }
    })
  }

  delete_all_downloaded_files() {
    let list = fs.listFileSync("/data/storage/el2/base/haps/home/files/");
    let filesDir = getContext().filesDir;

    for (let index = 0; index < list.length; index++) {
      fs.unlink(filesDir + "/" + list[index]);
    }
    // Delete all downloaded files
  }
}