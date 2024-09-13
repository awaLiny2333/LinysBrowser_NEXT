import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { fileIo as fs, picker } from '@kit.CoreFileKit';

export async function document_save(file_name: string, content: string) {
  let target_uri: string[] = [];
  let context = AppStorage.get("context") as common.UIAbilityContext;

  try {
    let documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [file_name];
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