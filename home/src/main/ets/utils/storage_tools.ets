import { BusinessError, zlib } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { meowContext } from './environment_tools';

// Pick & Save

/**
 * Save (Copy) any file from a path to download folder.
 * @param path source path of object to be stored.
 * */
export async function download_save_from_path(path: string) {
  let uri: string = '';
  const documentViewPicker = new picker.DocumentViewPicker(meowContext());
  const documentSaveOptions = new picker.DocumentSaveOptions();
  documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
  await documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
    uri = documentSaveResult[0];
    // console.info('documentViewPicker.save succeed and uri is:' + uri);

    let path_split = path.split('/');
    let file_name = path_split[path_split.length-1];
    const save_uri = uri + '/' + file_name;

    fs.copy((fileUri.getUriFromPath(path)), save_uri);

  }).catch((err: BusinessError) => {
    console.error(`[storage_tools][download_save_from_path] Invoke documentViewPicker.save failed, code is ${err.code}, message is ${err.message}`);
  })
  return uri;
}

/**
 * Save a text file to device storage, pulling up a DocumentViewPicker.
 * @param file_name A string, setting the file's name.
 * @param content A string, fills the file's content.
 * */
export function document_save_text(file_name: string, content: string) {
  let target_uri: string[] = [];

  try {
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [file_name];
    // documentSaveOptions.fileSuffixChoices = [".html", ".txt", ".json"];
    let documentPicker = new picker.DocumentViewPicker(meowContext());

    documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      target_uri = documentSaveResult

      let file = fs.openSync(target_uri[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let writeLen = fs.writeSync(file.fd, content);
      console.info("[document_saver] write data to file succeed and size is:" + writeLen + " @ " + target_uri[0]);
      fs.closeSync(file);

      console.info('[document_saver] DocumentViewPicker.save successfully, documentSaveResult uri: ' +
      target_uri[0]);
    }).catch((err: BusinessError) => {
      console.error('[document_saver][ERROR] DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
    });

  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[document_saver][ERROR] DocumentViewPicker failed with err: ' + JSON.stringify(err));
  }
}

/**
 * Save (Copy) any file from a uri (file://...) to a selected position, pulling up a DocumentViewPicker.
 * @param from the uri.
 * */
export async function document_save_from_uri(from: string, file_name_overwrite?: string) {
  // Save
  try {
    // Get file name
    const split_result = from.split('/');
    let file_name = decodeURI(split_result[split_result.length-1]);
    if (file_name_overwrite) {
      file_name = file_name_overwrite;
    }

    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [file_name];
    let documentPicker = new picker.DocumentViewPicker(meowContext());

    await documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      let target_uri = documentSaveResult
      console.log("[document_save_from_uri] file_name: " + file_name + ' - ' + split_result[split_result.length-1])
      console.log("[document_save_from_uri] from: " + from)
      console.log("[document_save_from_uri] to: " + target_uri[0])

      // let target_path = (new fileUri.FileUri(target_uri[0])).path;
      // This operation is likely to cause target_path
      // to be identified as unauthorized!

      fs.copy(from, target_uri[0])
      // .then(() => {
      //   fs.rmdir(this.list_of_target_folders[index]);
      // });

      console.info("[document_save_from_uri] write data to file succeed @ " + target_uri[0]);
      // this.delete_task(index);

    })
      .catch((err: BusinessError) => {
        console.error('[document_save_from_uri][ERROR] DocumentViewPicker.save failed with err: ' +
        JSON.stringify(err));
      });

  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[document_save_from_uri][ERROR] DocumentViewPicker failed with err: ' + JSON.stringify(err));
  }
}

/**
 * Save (Copy) any file from a path to a selected position, pulling up a DocumentViewPicker.
 * @param from the path.
 * */
export async function document_save_from_path(from: string, file_name_overwrite?: string) {
  await document_save_from_uri(fileUri.getUriFromPath(from), file_name_overwrite);
}

/**
 * Save (Copy) an image file from a uri to Gallery.
 * @param from The uri of file.
 * */
export async function image_save_from_uri(from: string) {
  try {
    let srcFileUris: Array<string> = [from];
    let photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [{
      fileNameExtension: get_file_suffix(from),
      photoType: photoAccessHelper.PhotoType.IMAGE,
    }];
    let context = meowContext();
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let desFileUris: Array<string> = await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
    console.info('[storage_tools][image_save_from_uri] showAssetsCreationDialog success, data is ' + desFileUris);
    try {
      let srcFile = fs.openSync(srcFileUris[0], fs.OpenMode.READ_ONLY)
      let desFile = fs.openSync(desFileUris[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      fs.copyFileSync(srcFile.fd, desFile.fd)
      fs.closeSync(srcFile);
      fs.closeSync(desFile);
    } catch (e) {
      console.error('[storage_tools][image_save_from_uri] ' + e);
    }
  } catch (err) {
    console.error('[storage_tools][image_save_from_uri] showAssetsCreationDialog failed, errCode is ' + err.code + ', errMsg is ' + err.message);
  }
}

// Pick & Read

/**
 * Pick a text file from device storage, pulling up a DocumentViewPicker.
 * @returns A string, of the chosen file's content.
 * */
export async function document_pick_to_text(suffixFilters?: string[]) {
  let target_uri: string[] = [];

  try {
    let documentPicker = new picker.DocumentViewPicker(meowContext());
    let contents: string = "";
    await documentPicker.select({ maxSelectNumber: 1, fileSuffixFilters: suffixFilters || [".html", ".txt"] })
      .then((documentSelectResult) => {
        target_uri = documentSelectResult;
        let file = fs.openSync(target_uri[0], fs.OpenMode.READ_WRITE);
        console.info('[document_reader] DocumentViewPicker.select successfully, documentSelectResult uri: ' +
        target_uri[0])
        let target_path = (new fileUri.FileUri(target_uri[0])).path;
        let stat = fs.statSync(target_path);
        let size = stat.size;
        let buf = new ArrayBuffer(size);
        let readLen = fs.readSync(file.fd, buf);
        fs.closeSync(file);
        let result = buf.slice(0, readLen);
        console.info("[document_reader] read file data succeed, Length: " + readLen.toString());
        contents = buffer.from(result).toString();
      })
      .catch((err: BusinessError) => {
        console.error('[document_reader] DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
      });
    return contents;
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[ERROR][document_reader] DocumentViewPicker failed with err: ' + JSON.stringify(err));
    return "";
  }
}

/**
 * Pick an image file from device storage, pulling up a DocumentViewPicker.
 * @returns A string, of the chosen file's content.
 * */
export async function image_pick_to_ArrayBuffer() {
  let selected_uri: string[] = [];

  try {
    let documentPicker = new picker.DocumentViewPicker(meowContext());
    let buf: ArrayBuffer | undefined = undefined;

    await documentPicker.select({
      maxSelectNumber: 1,
      fileSuffixFilters: [".png", ".jpg", ".jpeg"]
    })
      .then((documentSelectResult) => {
        selected_uri = documentSelectResult;
        console.info('[image_document_reader] DocumentViewPicker.select successfully, documentSelectResult uri: ' +
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

        console.info("[image_document_reader] Read image from " + selected_uri[0] + " Success!");
      })
      .catch((err: BusinessError) => {
        console.error('[image_document_reader] DocumentViewPicker.select failed with err: ' +
        JSON.stringify(err));
        return undefined;
      });
    return buf;
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[ERROR][image_document_reader] DocumentViewPicker failed with err: ' + JSON.stringify(err));
    return undefined;
  }
}

// Sandbox Operations

/**
 * Save a text file or ArrayBuffer to sandbox storage, overwrites whatever that was at that place.
 * @param file_name A string, setting the file's name.
 * @param content A string or an ArrayBuffer, fills the file's content.
 * */
export function sandbox_save(file_name: string, content: string | ArrayBuffer, context_filesDir?: string) {
  let filesDir: string = context_filesDir || meowContext().filesDir;
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
  let filesDir: string = context_filesDir || meowContext().filesDir;
  let full_file_directory = filesDir + '/' + file_name;
  try {
    fs.unlink(full_file_directory);
  } catch (e) {
    console.error('[storage_tools][sandbox_unlink] [' + file_name + ']' + e);
    return false;
  }
  return true;
}

/**
 * Unlink (delete) a file in a sync way.
 * @param file_name A string, the path of the file.
 * */
export function sandbox_unlink_sync(file_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || meowContext().filesDir;
  let full_file_directory = filesDir + '/' + file_name;
  try {
    fs.unlinkSync(full_file_directory);
  } catch (e) {
    console.error('[storage_tools][sandbox_unlink_sync] [' + file_name + ']' + e);
    return false;
  }
  return true;
}

/**
 * Unlink (delete) a directory in a sync way.
 * @param dir_name A string, the path of the file.
 * */
export function sandbox_rmdir_sync(dir_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || meowContext().filesDir;
  let full_dir_directory = filesDir + '/' + dir_name;
  try {
    fs.rmdirSync(full_dir_directory);
  } catch (e) {
    console.error('[storage_tools][sandbox_rmdir_sync] [' + dir_name + ']' + e);
    return false;
  }
  return true;
}

/**
 * Read a text file from sandbox storage.
 *
 * If you have a context filesDir already, you can pass it to me.
 * @returns A string, of the requested file's content.
 * */
export function sandbox_read_text_sync(file_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || meowContext().filesDir;
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
 * Read a text file from file uri.
 *
 * If you have a context filesDir already, you can pass it to me.
 * @returns A string, of the requested file's content.
 * */
export function uri_read_text_sync(file_uri: string) {
  console.log('[storage_tools][uri_read_text_sync] ' + file_uri);
  let path = uri_2_path(file_uri);
  if (!(fs.accessSync(path))) {
    // file doesn't exist
    console.log('[storage_tools][uri_read_text_sync][' + path + '] Doesn\'t exist!');
    return "undefined";
  }
  let file = fs.openSync(path, fs.OpenMode.READ_WRITE);
  let stat = fs.statSync(path);
  let size = stat.size;
  let buf = new ArrayBuffer(size);
  let readLen = fs.readSync(file.fd, buf);
  fs.closeSync(file);
  let result = buf.slice(0, readLen);
  console.info("[sandbox_open] read file \"" + file_uri + "\" data succeed, Length: " + readLen.toString());
  return buffer.from(result).toString();
}

/**
 * Read an ArrayBuffer file from sandbox storage in a synchronous way.
 * @returns An ArrayBuffer, of the requested file's content or undefined if the file doesn't exist.
 * */
export function sandbox_read_arrayBuffer_sync(file_path_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || meowContext().filesDir;
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
 * Read an ArrayBuffer file from sandbox storage in an asynchronous way.
 * @returns An ArrayBuffer, of the requested file's content or undefined if the file doesn't exist.
 * */
export function sandbox_read_arrayBuffer(file_path_name: string, context_filesDir?: string) {
  let filesDir: string = context_filesDir || meowContext().filesDir;
  file_path_name = filesDir + "/" + file_path_name
  if (!(fs.accessSync(file_path_name))) {
    // file doesn't exist
    return undefined;
  }
  let file = fs.openSync(file_path_name, fs.OpenMode.READ_WRITE);
  let stat = fs.statSync(file_path_name);
  let size = stat.size;
  let buf = new ArrayBuffer(size);
  return fs.read(file.fd, buf).then((l) => {
    let readLen = l;
    console.info("[sandbox_open] read file data succeed, Length: " + readLen.toString());
    fs.close(file);
    let result = buf.slice(0, readLen);
    return result;
  })
}

/**
 * Copy a text file to sandbox storage, overwrites whatever that was at that place.
 *
 * THIS IS A SYNC FUNCTION
 * @param from from a uri (file://).
 * @param to a sandbox directory, the new parent folder of this file (in sandbox).
 * @returns a sandbox uri, root is meowContext().filesDir.
 * */
export function copy_from_uri_to_sandbox(from: string, to: string, max_name_length?: number): string {
  let filesDir: string = meowContext().filesDir;
  let max_name_l: number = max_name_length || 64;
  // Get from path
  const from_path = new fileUri.FileUri(from).path;
  // Get file name
  const split_result = from.split('/');
  let file_name = decodeURI(split_result[split_result.length-1]);
  if (file_name.length > max_name_l) {
    file_name = file_name.substring(file_name.length - max_name_l, file_name.length + 1);
  }
  // Try to prevent collision
  file_name = Date.now().toString() + '-' + file_name;
  // Combine target path
  let target_path = filesDir + '/' + to + '/' + file_name;
  console.log('[uri_copy_sandbox] Copy from [' + from_path + '] to [' + target_path + '] return [' + to + '/' + file_name + ']');
  fs.copyFileSync(from_path, target_path);
  return path_2_uri(target_path);
}

/**
 * Copies a file from rawfile to sandbox
 * @param from
 * @param to
 * */
export function copy_from_rawfile_to_sandbox(from: string, to: string) {
  let boxPath = meowContext().filesDir
  let to_split = to.split("/");
  let folderPath = boxPath + "/" + to_split.slice(0, to_split.length - 2).join("/");
  let fullPath = boxPath + "/" + to

  // 获取rawfile资源文件，转换数据
  let uint8Array: Uint8Array = meowContext().resourceManager.getRawFileContentSync(from);
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

// Info

/**
 * Returns the download folder uri.
 * @returns DOWNLOADS uri
 * */
export async function get_download_uri() {
  let uri: string = '';
  const documentViewPicker = new picker.DocumentViewPicker(meowContext());
  const documentSaveOptions = new picker.DocumentSaveOptions();
  documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
  await documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
    uri = documentSaveResult[0];
  }).catch((err: BusinessError) => {
    console.error(`[storage_tools][download_save_from_path] Invoke documentViewPicker.save failed, code is ${err.code}, message is ${err.message}`);
  })
  return uri;
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
    console.log('[storage_tools] Calculated folder size: ' + sum.toString())
  }
  return sum;
}

/**
 * Gets the size of a file
 * @param path the path or uri
 * @returns the size in number
 * */
export function get_file_size_Sync(path: string) {
  let file = fs.openSync(path);
  let filestat = fs.statSync(file.fd);
  fs.close(file);
  return filestat.size;
}

/**
 * Returns the suffix of a file name.
 * @param file for example, 'qwq.txt.awa'
 * @returns the suffix. e.g. 'awa'
 * */
export function get_file_suffix(file: string) {
  let s = file.split('.');
  return s[s.length-1].toUpperCase();
}

/**
 * Adds a unit to a size in bytes.
 * @param size_in_bytes A number or bigint, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function add_units_to_size(size_in_bytes: number | bigint) {
  if (size_in_bytes == undefined || size_in_bytes == null) {
    return 'No Bytes!';
  }
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
 * @returns an integer 0 ~ 10.
 * */
export function is_legal_filename(filename: string) {
  if (filename.length > 255) {
    return 1;
  }
  if (filename.includes('\\')) {
    return 2;
  }
  if (filename.includes('/')) {
    return 3;
  }
  if (filename.includes(':')) {
    return 4;
  }
  if (filename.includes('*')) {
    return 5;
  }
  if (filename.includes('?')) {
    return 6;
  }
  if (filename.includes('\"')) {
    return 7;
  }
  if (filename.includes('<')) {
    return 8;
  }
  if (filename.includes('>')) {
    return 9;
  }
  if (filename.includes('|')) {
    return 10;
  }
  return 0;
}

// Conversions

/**
 * Converts a uri to path.
 * @param uri The uri.
 * @returns Its path.
 * */
export function uri_2_path(uri: string) {
  return new fileUri.FileUri(uri).path;
}

/**
 * Converts a path to uri.
 * @param path The path.
 * @returns Its uri.
 * */
export function path_2_uri(path: string) {
  return fileUri.getUriFromPath(path);
}

/**
 * Converts an ArrayBuffer to image.PixelMap object.
 * @param buf the ArrayBuffer
 * @returns an image.PixelMap
 * */
export function arrayBuffer_2_pixelMap(buf: ArrayBuffer) {
  // ArrayBuffer => PixelMap
  const imageSource = image.createImageSource(buf);
  console.log('imageSource: ' + JSON.stringify(imageSource));
  let pixelMap = imageSource.createPixelMapSync({});
  imageSource.release();
  return pixelMap;
}

// Global Data

/**
 * Exports everything, ALL USER DATA.
 * */
export async function export_everything() {
  bunch_of_settings.save_to_disk();
  // sandbox_save('kv_store.json.browsercatstore.txt', await export_json_kv_store());
  sandbox_unlink_sync('kv_store.json.browsercatstore.txt');
  sandbox_unlink_sync('profile.zip');
  sandbox_rmdir_sync('temp');

  let inFile = meowContext().filesDir;
  let outFile = meowContext().filesDir + '/profile.zip';

  let options: zlib.Options = {
    level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
    memLevel: zlib.MemLevel.MEM_LEVEL_DEFAULT,
    strategy: zlib.CompressStrategy.COMPRESS_STRATEGY_DEFAULT_STRATEGY
  };

  try {
    zlib.compressFile(inFile, outFile, options).then((data: void) => {
      console.info('compressFile success. data: ' + JSON.stringify(data));
      // SAVE
      document_save_from_path(outFile, 'profile.zip.browsercatprofile').then(() => {
        // sandbox_unlink_sync('settings.json.browsercatsettings.txt');
        // sandbox_unlink_sync('profile.zip');
        AppStorage.set('compressing_output_profile', false);
      })
    }).catch((errData: BusinessError) => {
      console.error(`errData is errCode:${errData.code}  message:${errData.message}`);
    })

  } catch (errData) {
    let code = (errData as BusinessError).code;
    let message = (errData as BusinessError).message;
    console.error(`errData is errCode:${code}  message:${message}`);
  }
}

/**
 * Imports everything, overwriting all current user data.
 * */
export async function import_everything() {
  try {
    fs.mkdirSync(meowContext().filesDir + '/temp')
  } catch (e) {
    console.error('[storage_tools][import_everything] Create temp dir error: ' + e);
  }

  try {
    let selected_uri: string[] = [];
    let documentPicker = new picker.DocumentViewPicker(meowContext());

    await documentPicker.select({
      maxSelectNumber: 1,
      fileSuffixFilters: ["browsercatprofile"]
    })
      .then((documentSelectResult) => {
        selected_uri = documentSelectResult;
        console.info('[import_everything] DocumentViewPicker.select successfully, documentSelectResult uri: ' + selected_uri[0]);
      })
      .catch((err: BusinessError) => {
        console.error('[import_everything] DocumentViewPicker.select failed with err: ' +
        JSON.stringify(err));
        return false;
      });

    // Decompress
    let inFile = new fileUri.FileUri(selected_uri[0]).path;
    let outFileDir = meowContext().filesDir + '/temp';
    let options: zlib.Options = {
      level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
      // parallel: zlib.ParallelStrategy.PARALLEL_STRATEGY_PARALLEL_DECOMPRESSION
    };

    try {
      await zlib.decompressFile(inFile, outFileDir, options).then(() => {

        // Traverse all files and folders
        // Clear sandbox
        fs.listFileSync(meowContext().filesDir).forEach((item) => {
          const fullPath = meowContext().filesDir + '/' + item;
          const stat = fs.statSync(fullPath);
          if (stat.isDirectory()) {
            if (item !== 'temp') {
              sandbox_rmdir_sync(item);
            }
          } else {
            sandbox_unlink_sync(item);
          }
        });

        // Traverse temp and copy
        fs.listFileSync(meowContext().filesDir + '/temp').forEach((item) => {
          const fullPath = meowContext().filesDir + '/temp/' + item;
          const target = meowContext().filesDir + '/' + item;
          // console.log(fullPath);
          const stat = fs.statSync(fullPath);
          if (stat.isDirectory()) {
            fs.copyDirSync(fullPath, meowContext().filesDir);
            console.log('[storage_tools][import_everything] copyDirSync from ' + fullPath + ', to ' + meowContext().filesDir + '/' + item);
          } else {
            fs.copyFileSync(fullPath, target);
            console.log('[storage_tools][import_everything] copyFileSync from ' + fullPath + ', to ' + meowContext().filesDir + '/' + item);
          }
        });

        sandbox_rmdir_sync('temp');

        // Import settings
        bunch_of_settings.import_json(sandbox_read_text_sync('settings.json.browsercatsettings.txt'));

        // Deal with kvStore
        let original_kv = sandbox_read_text_sync('kv_store.json.browsercatstore.txt');
        if (original_kv != 'undefined') {
          sandbox_unlink_sync('kv_store.json.browsercatstore.txt');
          bunch_of_settings.set('start_up_option', 'new tab');
          bunch_of_settings.set('continue_tabs_count', 0);
          bunch_of_settings.set('continue_tabs_main_on', 0);
          bunch_of_settings.set('continue_tabs_sub_on', 0);
        } else {
          bunch_of_settings.save_to_disk();
        }
        // Delete
        // sandbox_unlink_sync('settings.json.browsercatsettings.txt');

      }).catch((errData: BusinessError) => {
        console.error(`errData is errCode:${errData.code}  message:${errData.message}`);
        return false;
      })
    } catch (e) {
      console.error('[import_everything] ' + e);
      return false;
    }

    console.info("[import_everything] Read zip from " + selected_uri[0] + " Success!");
    return true;
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[ERROR][import_everything] DocumentViewPicker failed with err: ' + JSON.stringify(err));
    return false;
  }
}