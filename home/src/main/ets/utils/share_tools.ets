import { common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { meowContext } from './environment_tools';

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

