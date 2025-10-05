import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import { copy_from_uri_to_sandbox } from './storage_tools';

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
export function drop_to_scratching_board(e: DragEvent, storage: LocalStorage) {
  let drop_data_records = e.getData().getRecords();
  let result_list_string: string[] = [];
  for (let i = 0; i < drop_data_records.length; i++) {
    let record = drop_data_records[i];
    if (record.getType() == uniformTypeDescriptor.UniformDataType.HYPERLINK) {
      // Push Hyperlink
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
      console.log("[drop_to_scratching_board] Hyperlink url: [" + url + "]");

    } else if (record.getType() == uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
      // Push text
      let textContent = (record as unifiedDataChannel.PlainText).textContent;
      if (!result_list_string.includes(textContent)) {
        result_list_string.push(textContent);
      }
      console.log("[drop_to_scratching_board] Plain Text: [" + textContent + "]");

    } else if (record.getType() == uniformTypeDescriptor.UniformDataType.IMAGE) {
      // Push Image
      let image_uri = (record as unifiedDataChannel.Image).imageUri;
      console.log("[drop_to_scratching_board] image uri: [" + image_uri + "]");
      try {
        result_list_string.push(copy_from_uri_to_sandbox(image_uri, 'web-drag-image-cache'));
      } catch (e) {
        console.error('[drag_drop_tools] Plan A of Image drop failed: ' + e);
      }
    }
  }
  // Append to start of original scratching board content
  let original_drop_result_strings = storage.get('drop_result_strings') as string[];
  storage.set('drop_result_strings', result_list_string.concat(original_drop_result_strings));
  e.setResult(DragResult.DRAG_SUCCESSFUL);
}
