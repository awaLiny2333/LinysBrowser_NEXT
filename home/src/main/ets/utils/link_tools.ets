import { common, OpenLinkOptions } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * Opens uri with filemanager.
 * @param uri the uri.
 * */
export function open_file_uri(uri: string, context: Context) {
  // Open folder
  let link: string = 'filemanager://openDirectory';
  let openLinkOptions: OpenLinkOptions = {
    parameters: {
      'fileUri': uri
    }
  };
  try {
    (context as common.UIAbilityContext).openLink(link, openLinkOptions)
  } catch (e) {
    console.error('[link_tools] ' + e);
  }
}

/**
 * Shares a link through system share.
 * @param link The link.
 * @param title The title.
 * */
export function share_link(link: string, title: string, context: Context) {
  let data: systemShare.SharedData = new systemShare.SharedData({
    utd: utd.UniformDataType.HYPERLINK,
    description: link,
    title: title,
    content: link
  });
  let controller: systemShare.ShareController = new systemShare.ShareController(data);
  controller.show((context as common.UIAbilityContext), {
    previewMode: systemShare.SharePreviewMode.DEFAULT,
    selectionMode: systemShare.SelectionMode.BATCH
  }).catch((e: BusinessError) => {
    console.error('[share_link] Error: ' + JSON.stringify(e));
  });
}