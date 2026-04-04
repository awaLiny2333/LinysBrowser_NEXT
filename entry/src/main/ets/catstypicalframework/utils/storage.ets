import lazy { fileIo, fileUri, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import lazy { taskpool } from '@kit.ArkTS';
import { common, OpenLinkOptions } from '@kit.AbilityKit';
import { meow, meowLevel } from './catsLogger';
export interface meowReadPickResult {
  succeed: boolean;
  sourcePaths?: string[];
}

// Picker

/**
 * Retrieve the download directory.
 * @returns The download directory path.
 */
export async function retrieveDownloadDirectory(context: Context) {
  const documentSaveOptions = new picker.DocumentSaveOptions();
  documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
  const documentViewPicker = new picker.DocumentViewPicker(context);
  return documentViewPicker.save(documentSaveOptions)
    .then((uris: Array<string>) => {
      console.log(`[retrieveDownloadDirectory] DocumentViewPicker.save successfully, uris[0]: ${uris[0]}`);
      return uris[0];
    })
    .catch((e: BusinessError) => {
      console.error(`[retrieveDownloadDirectory] DocumentViewPicker.save failed with err: ${e}`);
      return undefined;
    });
}

/**
 * Pick a file from device storage, pulling up a DocumentViewPicker.
 * @returns Majorly the path.
 * */
export async function fileDocumentPick2Path(fileSuffixFilters: string[] = [".meow"], maxSelectNumber: number = 1): Promise<meowReadPickResult> {
  if (canIUse("SystemCapability.FileManagement.UserFileService")) {
    return (new picker.DocumentViewPicker())
      .select({
        maxSelectNumber: maxSelectNumber,
        fileSuffixFilters: fileSuffixFilters
      })
      .then((documentSelectResult) => {
        let sourcePaths: string[] = [];

        if (documentSelectResult.length == 0) {
          console.info(`[fileDocumentPick2Path] DocumentViewPicker.select Selected nothing. documentSelectResult = ${documentSelectResult}`);
          return { succeed: false } as meowReadPickResult;
        }

        for (let index = 0; index < documentSelectResult.length; index++) {
          const sourcePath = uri_2_path(documentSelectResult[index]);
          console.info(`[fileDocumentPick2Path] DocumentViewPicker.select successfully, documentSelectResult sourcePath[${index}]: ${sourcePath}`);
          sourcePaths.push(sourcePath);
        }

        return {
          succeed: true,
          sourcePaths: sourcePaths,
        } as meowReadPickResult;
      })
      .catch((e: BusinessError) => {
        console.error(`[fileDocumentPick2Path] DocumentViewPicker.select failed with err: ${e}`);
        return { succeed: false } as meowReadPickResult;
      });

  } else {
    console.error('[fileDocumentPick2Path] DocumentViewPicker.select failed. canIUse("SystemCapability.FileManagement.UserFileService") is false!');
    return { succeed: false } as meowReadPickResult;
  }
}

/**
 * Picks a directory and returns the path.
 * @returns The path or undefined if ran into errors.
 * */
export async function pickDirectory(): Promise<string | undefined> {
  if (canIUse("SystemCapability.FileManagement.UserFileService.FolderSelection")) {
    let DocumentSelectOptions = new picker.DocumentSelectOptions();
    DocumentSelectOptions.selectMode = picker.DocumentSelectMode.FOLDER;
    let documentPicker = new picker.DocumentViewPicker();
    try {
      let uris = await documentPicker.select(DocumentSelectOptions);
      return uri_2_path(uris[0]);
    } catch (e) {
      console.error(`[pickDirectory] Failed! ${e}`);
      return undefined;
    }
  } else {
    console.error('[pickDirectory] failed. canIUse("SystemCapability.FileManagement.UserFileService.FolderSelection") is false!');
  }
  return undefined;
}

// Save

/**
 * Save a text file or ArrayBuffer to sandbox storage, overwrites whatever that was at that place.
 * @param fullFilePath A string, setting the file's name.
 * @param context The content.
 * @param content A string or an ArrayBuffer, fills the file's content.
 * @param overwrite overwrite or not. Default is false.
 * */
export async function saveHybrid(fullFilePath: string, content: string | ArrayBuffer, overwrite = false) {
  const startTime = Date.now();

  try {
    if (await fileIo.access(fullFilePath)) {
      if (overwrite) {
        await fileIo.unlink(fullFilePath);
      } else {
        console.warn(`[saveHybrid] file ${fullFilePath} exist! Returned. (${Date.now() - startTime} ms)`);
        return undefined;
      }
    }

    // if (typeof content == 'string') {
    //   console.info(`[saveHybrid] about to write to file ${fullFilePath}, content length = ${content.length}`);
    // } else {
    //   console.info(`[saveHybrid] about to write to file ${fullFilePath}, content length = ${content.byteLength}`);
    // }

    let file = fileIo.openSync(fullFilePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    return fileIo.write(file.fd, content)
      .then((writeLen) => {
        console.info(`[saveHybrid] write to file ${fullFilePath} succeed, size = ${writeLen} (${Date.now() - startTime} ms)`);
        return true;
      })
      .catch((e: BusinessError) => {
        console.error(`[saveHybrid] fileIo.write(file.fd, content) to file ${fullFilePath} failed: ${e} (${Date.now() - startTime} ms)`);
        return false;
      })
      .finally(() => {
        fileIo.close(file)
          .catch((e: BusinessError) => {
            console.error(`[saveHybrid] fileIo.close(file) file ${fullFilePath} failed: ${e} (${Date.now() - startTime} ms)`);
          });
      });
  } catch (e) {
    console.error(`[saveHybrid] write to file ${fullFilePath} failed: ${e} (${Date.now() - startTime} ms)`);
    return false;
  }
}

/**
 * Copy a file.
 * @param fullSourcePath The source path.
 * @param fullDestPath The destination path.
 * @param overwrite Whether to overwrite the destination file if it exists.
 * @returns true if succeed, false if failed.
 */
export async function fileCopy(fullSourcePath: string, fullDestPath: string, overwrite: boolean) {
  try {
    if (fileIo.accessSync(fullDestPath)) {
      if (!overwrite) {
        return undefined;
      }
    }
  } catch (e) {
    console.error(`[fileCopy] fileIo.copyFile(${fullSourcePath}, ${fullDestPath}, ${overwrite}) test accessSync failed: ${e}`);
  }
  return fileIo.copyFile(fullSourcePath, fullDestPath)
    .catch((e: BusinessError) => {
      console.error(`[fileCopy] fileIo.copyFile(${fullSourcePath}, ${fullDestPath}, ${overwrite}) failed: ${e}`);
      return false;
    })
    .then(() => {
      return true;
    });
}

/**
 * Append a string to the end of a file.
 * @param filePath The file path.
 * @param str The string to append.
 * @returns true if succeed, false if failed.
 */
export async function appendTextToEndOfFile(filePath: string, str: string) {
  try {
    let file = await fileIo.open(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.APPEND | fileIo.OpenMode.CREATE); // 设置以追加方式打开文件
    let writeLen = await fileIo.write(file.fd, str); // 向文件内写入内容，返回值为写入内容的长度
    console.log(`[appendTextToEndOfFile] appended content [${str}] to file ${filePath}, length = ${writeLen}`);
    await fileIo.close(file); // 关闭文件
    return true;
  } catch (e) {
    console.error(`[appendTextToEndOfFile] fileIo.write(file.fd, ${str}) of file ${filePath} failed: ${e}`);
    return false;
  }
}

/**
 * Ensure a directory exists.
 * @param dirPath The folder path.
 */
export async function ensureDirectoryExist(dirPath: string) {
  try {
    if (!(await fileIo.access(dirPath))) {
      await fileIo.mkdir(dirPath, true);
      meow(`dir ${dirPath} created`, 'ensureDirectoryExist');
    }
  } catch (e) {
    console.error(`[ensureDirectoryExist] fileIo.mkdir(${dirPath}) failed: ${e}`);
  }
}

/**
 * Clear a directory.
 * @param dirPath The folder path.
 */
export async function clearDirectory(dirPath: string) {
  try {
    if (!(await fileIo.access(dirPath))) {
      // dir doesn't exist
      meow(`dir ${dirPath} doesn't exist`, 'clearDirectory', meowLevel.ERROR);
      return true;
    }
  } catch (e) {
    console.error(`[clearDirectory] await fileIo.access(dirPath) check failed: ${e}`);
    return false;
  }

  try {
    await fileIo.rmdir(dirPath);
    await fileIo.mkdir(dirPath, true);
    meow(`dir ${dirPath} cleared`, 'clearDirectory');
    return true;
  } catch (e) {
    console.error(`[clearDirectory] fileIo.rmdir(dirPath) failed: ${e}`);
    return false;
  }
}

/**
 * Unlink a file.
 * @param filePath The file path.
 * @returns true if succeed (the file just, doesn't exist there :D), false if failed.
 */
export async function unlinkFile(filePath: string) {
  if (!(await fileExist(filePath))) {
    console.log(`[unlinkFile] file [${filePath}] doesn't exist at all! Nevertheless your goal is achieved, isn't it?`);
    return true;
  }
  try {
    await fileIo.unlink(filePath);
    console.log(`[unlinkFile] unlinked [${filePath}]`);
    return true;
  } catch (e) {
    console.error(`[unlinkFile] fileIo.unlink(${filePath}) failed: ${e}`);
    return false;
  }
}

// Read

/**
 * Check if a file exists.
 * @param path The file path.
 * @returns true if the file exists, false if not.
 */
export async function fileExist(path: string) {
  try {
    const result = await fileIo.access(path);
    return result;
  } catch (e) {
    console.error(`[fileExist] fileIo.access(${path}) failed: ${e}`);
    return false;
  }
}

/**
 * List all files under a directory.
 * @param dirPath The folder path.
 * @returns A list of filenames.
 */
export async function listFilesUnderDir(dirPath: string) {
  try {
    if (!(await fileIo.access(dirPath))) {
      // dir doesn't exist
      meow(`dir ${dirPath} doesn't exist`, 'listFilesUnderDir', meowLevel.ERROR);
      return undefined;
    }
  } catch (error) {
    meow(`access dir ${dirPath} failed: ${error}`, 'listFilesUnderDir', meowLevel.ERROR);
    return undefined;
  }

  try {
    let files = await fileIo.listFile(dirPath);
    return files;
  } catch (e) {
    meow(`fileIo.listFileSync(${dirPath}) failed: ${e}`, 'listFilesUnderDir', meowLevel.ERROR);
    return undefined;
  }
}

/**
 * Read an ArrayBuffer file from storage in a sync way.
 * @param fullFilePath the file path
 * @param context the context
 * @returns An ArrayBuffer, of the requested file's content or undefined if the file doesn't exist.
 * */
@Concurrent
export async function readArrayBuffer(fullFilePath: string, offset?: number, length?: number) {
  const startTime: number = Date.now();

  try {
    if (!(await fileIo.access(fullFilePath))) {
      // file doesn't exist
      console.warn(`[readArrayBuffer][${fullFilePath}] doesn't exist`);
      return undefined;
    }
  } catch (e) {
    console.error(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] fileIo.accessSync(filePath) check failed: ${e}`);
    return undefined;
  }

  try {
    let file = await fileIo.open(fullFilePath, fileIo.OpenMode.READ_WRITE);
    let stat = await fileIo.stat(fullFilePath);

    // Read to ArrayBuffer
    let buf: ArrayBuffer = new ArrayBuffer(length || stat.size);
    let readLen = await fileIo.read(file.fd, buf, { offset: offset, length: length });

    // TODO: Is this optimizable?
    let result = (length || stat.size) == readLen ? buf : buf.slice(0, readLen); // Copy?
    fileIo.close(file)
      .catch((e: BusinessError) => {
        console.error(`[readArrayBuffer] fileIo.close(file) failed: ${e}`);
      });

    console.info(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] OK. ArrayBuffer size = ${length || stat.size}, readLen = ${readLen}, (length || stat.size) == readLen: ${readLen == (length || stat.size)} (${Date.now() - startTime} ms)`);
    return result;
  } catch (e) {
    console.error(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] file operation failed: ${e}. Return undefined.`);
    return undefined;
  }
}

/**
 * Read an ArrayBuffer file from storage in a task pool way.
 * @param fullFilePath the file path
 * @param context the context
 * @returns An ArrayBuffer, of the requested file's content or undefined if the file doesn't exist.
 * */
export async function readArrayBufferConcurrent(fullFilePath: string, offset?: number, length?: number) {
  // const startTime: number = Date.now();
  let task: taskpool.Task;
  if (offset) {
    task = new taskpool.Task(readArrayBuffer, fullFilePath, offset!, length!);
  } else {
    task = new taskpool.Task(readArrayBuffer, fullFilePath);
  }
  try {
    const result = await taskpool.execute(task);
    // console.info(`[readArrayBufferConcurrent][${fullFilePath}][${offset}, ${length}] succeed! (${Date.now() - startTime} ms)`);
    return result as ArrayBuffer;
  } catch (e) {
    console.error(`[readArrayBufferConcurrent][${fullFilePath}][${offset}, ${length}] const result = await taskpool.execute(task); Failed: ${e}`);
    return undefined;
  }
}

// Operations

/**
 * Creates a directory in sandbox directory
 * @param dirPath The folder path
 * @param context The context
 * @param overwrite Overwrite or not, default false
 * @returns The promise?
 * */
export function sandboxCreateDir(dirPath: string, context: Context, overwrite = false) {
  let filesDir: string = context.filesDir;
  let fullFilePath = filesDir + '/' + dirPath;
  if (fullFilePath.substring(fullFilePath.length - 1) != '/') {
    fullFilePath = fullFilePath + '/';
  }
  console.log(`[sandboxCreateDir] mkdirSync ${fullFilePath} GO.`);

  return fileIo.access(fullFilePath, fileIo.AccessModeType.EXIST)
    .then((r) => {
      if (r) {
        if (overwrite) {
          return fileIo.rmdir(fullFilePath)
            .then(() => {
              return fileIo.mkdir(fullFilePath)
                .then(() => {
                  console.log(`[sandboxCreateDir][r] mkdirSync ${dirPath} OK.`);
                })
                .catch((e: BusinessError) => {
                  console.error(`[sandboxCreateDir][r] mkdirSync ${dirPath} return fileIo.mkdir(fullFilePath) failed: ${e}`);
                });
            })
            .catch((e: BusinessError) => {
              console.error(`[sandboxCreateDir][r] mkdirSync ${dirPath} return fileIo.rmdir(fullFilePath) failed: ${e}`);
            });
        } else {
          console.warn(`[sandboxCreateDir][r] directory ${dirPath} exist! Returned.`);
          return;
        }
      } else {
        return fileIo.mkdir(fullFilePath)
          .then(() => {
            console.log(`[sandboxCreateDir][new] mkdirSync ${dirPath} OK.`);
          })
          .catch((e: BusinessError) => {
            console.error(`[sandboxCreateDir][new] mkdirSync ${dirPath} return fileIo.mkdir(fullFilePath) failed: ${e}`);
          });
      }
    })
    .catch((e: BusinessError) => {
      console.error(`[sandboxCreateDir] mkdirSync ${dirPath} fileIo.access(fullFilePath, fileIo.AccessModeType.EXIST) failed: ${e}`);
    });
}

// Utils

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
 * Adds a unit to a size in bytes.
 * @param size_in_bytes A number or bigint, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function addUnitsToSize(size_in_bytes: number | bigint) {
  if (size_in_bytes == undefined || size_in_bytes == null) {
    return 'No Bytes!';
  }
  let units = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  let result = BigInt(size_in_bytes);
  let unit = 0;
  while (result > 1000 * 1000 && unit < units.length - 2) {
    result /= 1000n;
    unit += 1;
  }
  // To keep decimal places
  let numberResult = Number(result);
  numberResult /= 1000;
  unit += 1;
  return numberResult.toFixed(2) + " " + units[unit];
}

/**
 * 根据文件名或路径获取对应的 MIME 类型。
 * @description
 * 1. 自动处理大小写（如 .JPG -> image/jpeg）。
 * 2. 能够正确处理包含路径的字符串（如 /path/to/file.txt）。
 * 3. 排除无后缀或隐藏文件（如 .gitignore）。
 * 4. 匹配失败时默认返回 'application/octet-stream'。
 * @param {string} fileName - 文件名或完整路径 (例如: "image.png" 或 "/home/user/data.json")
 * @returns {string} 对应的 MIME 类型字符串
 * @example
 * mimeOfFileName('vacation.jpg');     // 'image/jpeg'
 * mimeOfFileName('INDEX.HTML');      // 'text/html'
 * mimeOfFileName('config');          // 'application/octet-stream'
 * mimeOfFileName('.hidden-file');    // 'application/octet-stream'
 *
 * @author Gemini web @ Feb 8 2026
 */
export function mimeOfFileName(fileName: string): string {
  if (!fileName) {
    return 'application/octet-stream';
  }

  // 1. 只取文件名部分，防止路径中的点号干扰 (例如 /path.to/my-file)
  const baseName = fileName.split(/[\\/]/)
    .pop() || '';

  // 2. 提取后缀名
  const lastDotIndex = baseName.lastIndexOf('.');

  // 如果点号不存在，或者点号在开头（如 .gitignore），通常视为无后缀
  if (lastDotIndex <= 0) {
    return 'application/octet-stream';
  }

  const ext = baseName.slice(lastDotIndex + 1)
    .toLowerCase();

  // 3. 扩展后的 MIME 映射表
  const mimeMap: Record<string, string> = {
    // 文本
    'txt': 'text/plain',
    'html': 'text/html',
    'htm': 'text/html',
    'css': 'text/css',
    'csv': 'text/csv',
    'xml': 'application/xml',

    // 脚本 & 数据
    'js': 'application/javascript',
    'mjs': 'application/javascript',
    'ts': 'text/typescript',
    'json': 'application/json',
    'yaml': 'text/yaml',
    'yml': 'text/yaml',

    // 图片
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'svg': 'image/svg+xml',
    'webp': 'image/webp',
    'ico': 'image/x-icon',

    // 视频 & 音频
    'mp4': 'video/mp4',
    'webm': 'video/webm',
    'ogg': 'video/ogg',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'flac': 'audio/flac',

    // 文档
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',

    // 压缩包
    'zip': 'application/zip',
    'rar': 'application/x-rar-compressed',
    '7z': 'application/x-7z-compressed',
    'gz': 'application/gzip',
    'tar': 'application/x-tar',
  };

  return mimeMap[ext] || 'application/octet-stream';
}

/**
 * Gets the file name from a path.
 * @param path The path.
 * @returns The file name.
 */
export function fileNameOfPath(path: string) {
  const sp = path.split('/');
  return sp[sp.length - 1];
}

// Others

export function showInFiles(path: string, context: common.UIAbilityContext) {
  // Open folder
  let link: string = 'filemanager://openDirectory';
  let openLinkOptions: OpenLinkOptions = {
    parameters: {
      'fileUri': path_2_uri(path)
    }
  };
  try {
    context.openLink(link, openLinkOptions);
  } catch (e) {
    console.error(e);
  }
}