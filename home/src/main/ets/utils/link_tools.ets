import { OpenLinkOptions } from '@kit.AbilityKit';
import { meowContext } from './environment_tools';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';

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
    console.error('[link_tools] ' + e);
  }
}

/**
 * Shares a link through system share.
 * @param link The link.
 * @param title The title.
 * */
export function share_link(link: string, title: string) {
  let data: systemShare.SharedData = new systemShare.SharedData({
    utd: utd.UniformDataType.HYPERLINK,
    description: link,
    title: title,
    content: link
  });
  let controller: systemShare.ShareController = new systemShare.ShareController(data);
  controller.show(meowContext(), {
    previewMode: systemShare.SharePreviewMode.DEFAULT,
    selectionMode: systemShare.SelectionMode.BATCH
  });
}