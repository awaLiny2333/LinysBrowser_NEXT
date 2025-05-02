import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';

/**
 * Pass a DragEvent and some of the contents of correct type would be added to meowScratchingBoard
 * @param e DragEvent
 * */
export function drop_to_scratching_board(e: DragEvent) {
  let drop_data = e.getData().getRecords();
  let result_list: string[] = [];
  for (let i = 0; i < drop_data.length; i++) {
    let record = drop_data[i]
    if (record.getType() == uniformTypeDescriptor.UniformDataType.HYPERLINK) {
      let desc = (record as unifiedDataChannel.Hyperlink).description;
      let url = (record as unifiedDataChannel.Hyperlink).url;

      if (desc && !result_list.includes(desc)) {
        // Push link description
        result_list.push(desc);
      }
      if (!result_list.includes(url)) {
        // Push link
        result_list.push(url);
      }

    } else if (record.getType() == uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
      let textContent = (record as unifiedDataChannel.PlainText).textContent;

      if (!result_list.includes(textContent)) {
        // Push text
        result_list.push(textContent);
      }
    }
  }
  // Append to start of original scratching board content
  let original_drop_result_strings = AppStorage.get('drop_result_strings') as string[];
  AppStorage.set('drop_result_strings', result_list.concat(original_drop_result_strings));
  e.setResult(DragResult.DRAG_SUCCESSFUL);
}