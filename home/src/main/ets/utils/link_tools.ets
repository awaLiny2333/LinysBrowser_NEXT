import { common, OpenLinkOptions } from "@kit.AbilityKit";

let context = AppStorage.get('context') as common.UIAbilityContext;

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
    context.openLink(link, openLinkOptions)
  } catch (e) {
    console.error(e);
  }
}