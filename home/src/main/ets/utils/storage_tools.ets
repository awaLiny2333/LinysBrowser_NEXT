import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';

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
 * Pick an image file from device storage, pulling up a DocumentViewPicker.
 * @returns A string, of the chosen file's content.
 * */
export async function image_open_to_ArrayBuffer() {
  let selected_uri: string[] = [];

  try {
    let documentPicker = new picker.DocumentViewPicker(context);
    let buf: ArrayBuffer | undefined = undefined;

    await documentPicker.select({
      maxSelectNumber: 1,
      fileSuffixFilters: [".png", ".jpg", ".jpeg", ".JPG", ".JPEG", ".PNG"]
    })
      .then((documentSelectResult) => {
        selected_uri = documentSelectResult;
        console.info('[Meow][image_document_reader] DocumentViewPicker.select successfully, documentSelectResult uri: ' +
        selected_uri[0])
        let file = fs.openSync(selected_uri[0], fs.OpenMode.READ_ONLY);
        // let selected_path = (new fileUri.FileUri(selected_uri[0])).path;
        let target_path = (new fileUri.FileUri(selected_uri[0])).path;
        let stat = fs.statSync(target_path);
        let size = stat.size;
        buf = new ArrayBuffer(size);
        fs.readSync(file.fd, buf)
        fs.closeSync(file);
        // fs.copyFileSync(selected_path, sand_path);

        console.info("[Meow][image_document_reader] Read image from " + selected_uri[0] + " Success!");
      })
      .catch((err: BusinessError) => {
        console.error('[Meow][image_document_reader] DocumentViewPicker.select failed with err: ' +
        JSON.stringify(err));
        return undefined;
      });
    return buf;
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[ERROR][Meow][image_document_reader] DocumentViewPicker failed with err: ' + JSON.stringify(err));
    return undefined;
  }
}

/**
 * Save a text file or ArrayBuffer to sandbox storage, overwrites whatever that was at that place.
 * @param file_name A string, setting the file's name.
 * @param content A string or an ArrayBuffer, fills the file's content.
 * */
export function sandbox_save(file_name: string, content: string | ArrayBuffer, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
  let full_file_directory = filesDir + '/' + file_name;
  if (fs.accessSync(full_file_directory)) {
    fs.unlinkSync(full_file_directory);
  }
  let file = fs.openSync(full_file_directory, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
  let writeLen = fs.writeSync(file.fd, content);
  console.info("[sandbox_save] write to file \"" + file_name + "\" succeed and size: " + writeLen + " @ " + file_name);
  fs.closeSync(file);
}

/**
 * Unlink (delete) a file.
 * @param file_name A string, the path of the file.
 * */
export function sandbox_unlink(file_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
  let full_file_directory = filesDir + '/' + file_name;
  fs.unlink(full_file_directory);
}

/**
 * Unlink (delete) a file in a sync way.
 * @param file_name A string, the path of the file.
 * */
export function sandbox_unlink_sync(file_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
  let full_file_directory = filesDir + '/' + file_name;
  fs.unlinkSync(full_file_directory);
}

/**
 * Read a text file from sandbox storage.
 *
 * If you have a context filesDir already, you can pass it to me.
 * @returns A string, of the requested file's content.
 * */
export function sandbox_open_sync(file_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
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
  console.info("[sandbox_open] read file \"" + file_name + "\" data succeed, Length: " + readLen.toString());
  return buffer.from(result).toString();
}

/**
 * Read an ArrayBuffer file from sandbox storage.
 * @returns An ArrayBuffer, of the requested file's content.
 * */
export function sandbox_open_arrayBuffer_sync(file_path_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || getContext().filesDir;
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
  console.info("[sandbox_open] read file data succeed, Length: " + readLen.toString());
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
 * @param size_in_bytes A number or bigint, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function add_units_to_size(size_in_bytes: number | bigint) {
  let units = ['Bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB']
  let result = BigInt(size_in_bytes);
  let unit = 0;
  while (result > 1024 * 1024 && unit < units.length - 2) {
    result /= 1024n;
    unit += 1;
  }
  // To keep decimal places
  let numberResult = Number(result);
  numberResult /= 1024;
  unit += 1;
  return numberResult.toFixed(2) + " " + units[unit];
}

/**
 * Determines whether filename is legal.
 * @param filename A string, the filename.
 * @returns true or false.
 * */
export function is_legal_filename(filename: string) {
  if (filename.includes('\\')) {
    return false;
  }
  if (filename.includes('/')) {
    return false;
  }
  if (filename.includes(':')) {
    return false;
  }
  if (filename.includes('*')) {
    return false;
  }
  if (filename.includes('?')) {
    return false;
  }
  if (filename.includes('\"')) {
    return false;
  }
  if (filename.includes('<')) {
    return false;
  }
  if (filename.includes('>')) {
    return false;
  }
  if (filename.includes('|')) {
    return false;
  }
  return true;
}

/**
 * Converts an ArrayBuffer to image.PixelMap object.
 * @param buf the ArrayBuffer
 * @returns an image.PixelMap
 * */
export function arrayBuffer_to_pixelMap(buf: ArrayBuffer) {
  // ArrayBuffer => PixelMap
  const imageSource = image.createImageSource(buf);
  console.log('imageSource: ' + JSON.stringify(imageSource));
  let pixelMap = imageSource.createPixelMapSync({});
  imageSource.release();
  return pixelMap;
}

/**
 * Copies a file from rawfile to sandbox
 * @param from
 * @param to
 * */
export function copy_from_rawfile_to_sandbox(from: string, to: string) {
  let boxPath = getContext().filesDir
  let to_split = to.split("/");
  let folderPath = boxPath + "/" + to_split.slice(0, to_split.length - 2).join("/");
  let fullPath = boxPath + "/" + to

  // 获取rawfile资源文件，转换数据
  let uint8Array: Uint8Array = getContext().resourceManager.getRawFileContentSync(from);
  let bf = buffer.from(uint8Array).buffer;

  // 创建沙箱目录
  try {
    fs.mkdirSync(folderPath)
  } catch (e) {
  }

  // 打开文件
  const fsOpen =
    fs.openSync(fullPath, fs.OpenMode.READ_WRITE | fs.OpenMode.READ_ONLY | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)

  // 写入文件
  let destFile = fs.writeSync(fsOpen.fd, bf);
  // 关闭文件
  fs.close(destFile)
}
