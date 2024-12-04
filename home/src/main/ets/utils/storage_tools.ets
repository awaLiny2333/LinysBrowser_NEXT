import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';

let context = AppStorage.get("context") as common.UIAbilityContext;

/**
 * Save a text file to device storage, pulling up a DocumentViewPicker.
 * @param file_name A string, setting the file's name.
 * @param content A string, fills the file's content.
 * */
export function document_save(file_name: string, content: string) {
  let target_uri: string[] = [];

  try {
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [file_name];
    documentSaveOptions.fileSuffixChoices = [".html", ".txt"];
    let documentPicker = new picker.DocumentViewPicker(context);

    documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      target_uri = documentSaveResult

      let file = fs.openSync(target_uri[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let writeLen = fs.writeSync(file.fd, content);
      console.info("[Meow][document_saver] write data to file succeed and size is:" + writeLen + " @ " + target_uri[0]);
      fs.closeSync(file);

      console.info('[Meow][document_saver] DocumentViewPicker.save successfully, documentSaveResult uri: ' +
      target_uri[0]);
    }).catch((err: BusinessError) => {
      console.error('[Meow][document_saver][ERROR] DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
    });

  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[Meow][document_saver][ERROR] DocumentViewPicker failed with err: ' + JSON.stringify(err));
  }
}

/**
 * Pick a text file from device storage, pulling up a DocumentViewPicker.
 * @returns A string, of the chosen file's content.
 * */
export async function document_open() {
  let target_uri: string[] = [];

  try {
    let documentPicker = new picker.DocumentViewPicker(context);
    let contents: string = "";
    await documentPicker.select({ maxSelectNumber: 1, fileSuffixFilters: [".html", ".txt"] })
      .then((documentSelectResult) => {
        target_uri = documentSelectResult;
        let file = fs.openSync(target_uri[0], fs.OpenMode.READ_WRITE);
        console.info('[Meow][document_reader] DocumentViewPicker.select successfully, documentSelectResult uri: ' +
        target_uri[0])
        let target_path = (new fileUri.FileUri(target_uri[0])).path;
        let stat = fs.statSync(target_path);
        let size = stat.size;
        let buf = new ArrayBuffer(size);
        let readLen = fs.readSync(file.fd, buf);
        fs.closeSync(file);
        let result = buf.slice(0, readLen);
        console.info("[Meow][document_reader] read file data succeed, Length: " + readLen.toString());
        contents = buffer.from(result).toString();
      })
      .catch((err: BusinessError) => {
        console.error('[Meow][document_reader] DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
      });
    return contents;
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[ERROR][Meow][document_reader] DocumentViewPicker failed with err: ' + JSON.stringify(err));
    return "";
  }
}

/**
 * Save a text file or ArrayBuffer to sandbox storage, overwrites whatever that was at that place.
 * @param file_name A string, setting the file's name.
 * @param content A string or an ArrayBuffer, fills the file's content.
 * */
export function sandbox_save(file_name: string, content: string | ArrayBuffer) {
  let filesDir = getContext().filesDir;
  let full_file_directory = filesDir + '/' + file_name;
  if (fs.accessSync(full_file_directory)) {
    fs.unlinkSync(full_file_directory);
  }
  let file = fs.openSync(full_file_directory, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
  let writeLen = fs.writeSync(file.fd, content);
  console.info("[sandbox_save] write data to file succeed and size is:" + writeLen + " @ " + file_name);
  fs.closeSync(file);
}

/**
 * Read a text file from sandbox storage.
 * @returns A string, of the requested file's content.
 * */
export function sandbox_open_sync(file_name: string) {
  let filesDir = getContext().filesDir;
  file_name = filesDir + "/" + file_name
  if (!(fs.accessSync(file_name))) {
    // file doesn't exist
    return "undefined";
  }
  let file = fs.openSync(file_name, fs.OpenMode.READ_WRITE);
  let stat = fs.statSync(file_name);
  let size = stat.size;
  let buf = new ArrayBuffer(size);
  let readLen = fs.readSync(file.fd, buf);
  fs.closeSync(file);
  let result = buf.slice(0, readLen);
  console.info("[Meow][sandbox_open] read file data succeed, Length: " + readLen.toString());
  return buffer.from(result).toString();
}

/**
 * Read an ArrayBuffer file from sandbox storage.
 * @returns An ArrayBuffer, of the requested file's content.
 * */
export function sandbox_open_array_sync(file_path_name: string) {
  let filesDir = getContext().filesDir;
  file_path_name = filesDir + "/" + file_path_name
  if (!(fs.accessSync(file_path_name))) {
    // file doesn't exist
    return undefined;
  }
  let file = fs.openSync(file_path_name, fs.OpenMode.READ_WRITE);
  let stat = fs.statSync(file_path_name);
  let size = stat.size;
  let buf = new ArrayBuffer(size);
  let readLen = fs.readSync(file.fd, buf);
  console.info("[Meow][sandbox_open] read file data succeed, Length: " + readLen.toString());
  fs.closeSync(file);
  let result = buf.slice(0, readLen);
  return result;
}

/**
 * Calculate the size of a folder and its containing items recursively in a sync way.
 * @param path A string, the path of the folder.
 * @returns A number, the size of that folder.
 * */
export function get_folder_size_Sync(path: string, log: boolean) {
  let sum = fs.statSync(path).size;
  try {
    let dir_list = fs.listFileSync(path);
    for (let index = 0; index < dir_list.length; index++) {
      sum += get_folder_size_Sync(path + '/' + dir_list[index], false)
    }
  } catch (e) {

  }
  if (log) {
    console.log('[Meow][storage_tools] Calculated folder size: ' + sum.toString())
  }
  return sum;
}

/**
 * Adds a unit to a size in bytes.
 * @param size_in_bytes A number, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function add_units_to_size(size_in_bytes: number) {
  let units = ['Bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB']
  let result = size_in_bytes;
  let unit = 0;
  while (result > 1024) {
    result /= 1024;
    unit += 1;
  }
  return result.toFixed(3) + units[unit];
}
