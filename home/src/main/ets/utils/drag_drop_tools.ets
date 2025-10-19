import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import { move_tab } from '../processes/tabs_actions';
import { copy_from_uri_to_sandbox } from './storage_tools';
import { window_index_of_id } from './ui_tools';

/**
 * Pass a DragEvent and some of the contents of correct type would be added to meowScratchingBoard
 * @param e DragEvent
 * */
export function drop_to_scratching_board(e: DragEvent, storage: LocalStorage) {
  let drop_ok = false;
  try {
    let drop_data_records = e.getData().getRecords();
    let result_list_string: string[] = [];
    for (let i = 0; i < drop_data_records.length; i++) {
      let record = drop_data_records[i];
      console.log('[Meow][drop_to_scratching_board][record.getType()][' + i + '] ' + record.getType());
      if (record.getType() == uniformTypeDescriptor.UniformDataType.HYPERLINK) {
        // Push Hyperlink
        let desc = (record as unifiedDataChannel.Hyperlink).description;
        let url = (record as unifiedDataChannel.Hyperlink).url;
        if (desc && !result_list_string.includes(desc)) {
          // Push link description
          result_list_string.push(desc);
          drop_ok = true;
        }
        if (!result_list_string.includes(url)) {
          // Push link
          result_list_string.push(url);
          drop_ok = true;
        }
        console.log("[drop_to_scratching_board] Hyperlink url: [" + url + "]");

      } else if (record.getType() == uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
        // Push text
        let textContent = (record as unifiedDataChannel.PlainText).textContent;
        if (!result_list_string.includes(textContent)) {
          result_list_string.push(textContent);
          drop_ok = true;
        }
        console.log("[drop_to_scratching_board] Plain Text: [" + textContent + "]");

      } else if (record.getType() == uniformTypeDescriptor.UniformDataType.IMAGE) {
        // Push Image
        let image_uri = (record as unifiedDataChannel.Image).imageUri;
        console.log("[drop_to_scratching_board] image uri: [" + image_uri + "]");
        try {
          result_list_string.push(copy_from_uri_to_sandbox(image_uri, 'web-drag-image-cache'));
          drop_ok = true;
        } catch (e) {
          console.error('[drop_to_scratching_board] Plan A of Image drop failed: ' + e);
        }

      } else if (record.getType() == 'ApplicationDefinedType') {
        let re = record as unifiedDataChannel.ApplicationDefinedRecord;
        if (re.applicationDefinedType == 'ApplicationDefinedTabDrag') {
          try {
            let data = Array.from(re.rawData);
            console.log('[drop_to_scratching_board] Got a tab! From: window_index = ' + data[0] + ', tab_index = ' + data[1]);
            move_tab(data[0], data[1], window_index_of_id(storage.get('my_window_id') as string));
          } catch (e) {
            console.error('[drop_to_scratching_board] Tab drop failed: ' + e);
          }
        }
      }
    }
    // Append to start of original scratching board content
    let original_drop_result_strings = storage.get('drop_result_strings') as string[];
    storage.set('drop_result_strings', result_list_string.concat(original_drop_result_strings));
  } catch (e) {
    console.error('[drop_to_scratching_board] Failed: ' + e);
  }
  e.setResult(DragResult.DRAG_SUCCESSFUL);
  return drop_ok;
}
