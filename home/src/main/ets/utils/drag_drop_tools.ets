import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import { uri_copy_sandbox } from './storage_tools';

export function allow_drop_types() {
  return [uniformTypeDescriptor.UniformDataType.TEXT,
    uniformTypeDescriptor.UniformDataType.HYPERLINK,
    uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
    uniformTypeDescriptor.UniformDataType.IMAGE]
}

/**
 * Pass a DragEvent and some of the contents of correct type would be added to meowScratchingBoard
 * @param e DragEvent
 * */
export function drop_to_scratching_board(e: DragEvent) {
  let drop_data = e.getData().getRecords();
  let result_list_string: string[] = [];
  for (let i = 0; i < drop_data.length; i++) {
    let record = drop_data[i]
    if (record.getType() == uniformTypeDescriptor.UniformDataType.HYPERLINK) {
      let desc = (record as unifiedDataChannel.Hyperlink).description;
      let url = (record as unifiedDataChannel.Hyperlink).url;

      if (desc && !result_list_string.includes(desc)) {
        // Push link description
        result_list_string.push(desc);
      }
      if (!result_list_string.includes(url)) {
        // Push link
        result_list_string.push(url);
      }

    } else if (record.getType() == uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
      let textContent = (record as unifiedDataChannel.PlainText).textContent;

      if (!result_list_string.includes(textContent)) {
        // Push text
        result_list_string.push(textContent);
      }
    } else if (record.getType() == uniformTypeDescriptor.UniformDataType.IMAGE) {
      let image_uri = (record as unifiedDataChannel.Image).imageUri;
      console.log("[drop_to_scratching_board] image uri: [" + image_uri + "]");
      result_list_string.push(uri_copy_sandbox(image_uri, 'web-drag-image-cache'));
    }
  }
  // Append to start of original scratching board content
  let original_drop_result_strings = AppStorage.get('drop_result_strings') as string[];
  AppStorage.set('drop_result_strings', result_list_string.concat(original_drop_result_strings));
  e.setResult(DragResult.DRAG_SUCCESSFUL);
}
