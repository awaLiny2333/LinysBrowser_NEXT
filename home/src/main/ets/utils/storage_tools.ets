import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';

let context = AppStorage.get("context") as common.UIAbilityContext;

export function document_save(file_name: string, content: string) {
  let target_uri: string[] = [];

  try {
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [file_name];
    documentSaveOptions.fileSuffixChoices = [".html"]
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

export async function document_open() { // 需确保 context 由 UIAbilityContext 转换而来
  let target_uri: string[] = [];

  try {
    let documentPicker = new picker.DocumentViewPicker(context);
    let contents: string = "";
    await documentPicker.select({ maxSelectNumber: 1, fileSuffixFilters: [".html"] }).then((documentSelectResult) => {
      target_uri = documentSelectResult;
      console.info('[Meow][document_reader] DocumentViewPicker.select successfully, documentSelectResult uri: ' +
      target_uri[0])
      let file = fs.openSync(target_uri[0], fs.OpenMode.READ_WRITE);
      let array_buffer = new ArrayBuffer(4194304);
      fs.readSync(file.fd, array_buffer);
      fs.closeSync(file);
      contents = buffer.from(array_buffer).toString();
    }).catch((err: BusinessError) => {
      console.error('[Meow][document_reader] DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
    });
    return contents;
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('[Meow][document_opener][ERROR] DocumentViewPicker failed with err: ' + JSON.stringify(err));
    return "";
  }
}

export function sandbox_save(file_path_name: string, content: string | ArrayBuffer) {
  let filesDir = getContext().filesDir;
  let full_file_directory = filesDir + '/' + file_path_name;
  if (fs.accessSync(full_file_directory)) {
    fs.unlinkSync(full_file_directory);
  }
  let file = fs.openSync(full_file_directory, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
  let writeLen = fs.writeSync(file.fd, content);
  console.info("[Meow][sandbox_save] write data to file succeed and size is:" + writeLen + " @ " + file_path_name);
  fs.closeSync(file);
}

export async function sandbox_open(file_path_name: string) {
  let filesDir = getContext().filesDir;
  file_path_name = filesDir + "/" + file_path_name
  if (!(await fs.access(file_path_name))) {
    // file doesn't exist
    return "undefined";
  }
  let file = fs.openSync(file_path_name, fs.OpenMode.READ_WRITE);
  let stat = fs.statSync(file_path_name);
  let size = stat.size;
  let buf = new ArrayBuffer(size);
  let readLen = await fs.read(file.fd, buf);
  console.info("[Meow][sandbox_open] read file data succeed, Length: " + readLen.toString());
  let result = buf.slice(0, readLen);
  fs.closeSync(file);
  return buffer.from(result).toString();
}