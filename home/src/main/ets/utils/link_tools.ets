import { OpenLinkOptions } from '@kit.AbilityKit';
import { meowContext } from './environment_tools';

/**
 * Opens uri with filemanager.
 * @param uri the uri.
 * */
export function open_file_uri(uri: string) {
  // Open folder
  let link: string = 'filemanager://openDirectory';
  let openLinkOptions: OpenLinkOptions = {
    parameters: {
      'fileUri': uri
    }
  };
  try {
    meowContext().openLink(link, openLinkOptions)
  } catch (e) {
    console.error(e);
  }
}