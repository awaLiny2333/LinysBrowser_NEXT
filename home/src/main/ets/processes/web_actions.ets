import lazy { fileIo } from '@kit.CoreFileKit';
import lazy { meowContext } from '../utils/environment_tools';
import lazy { add_units_to_size, sandbox_read_text_sync, sandbox_save } from '../utils/storage_tools';
import lazy { webview } from '@kit.ArkWeb';

/**
 * Apply all files of EasyList rules in directory of filesDir/easylist.
 */
export function apply_EasyList() {
  let lists = get_EasyLists();
  let overall_rules = '';
  for (let index = 0; index < lists.length; index++) {
    let new_paragraph = sandbox_read_text_sync('easylist/' + lists[index][0]);
    if (new_paragraph != 'undefined') {
      overall_rules += '\n' + new_paragraph;
    }
  }
  sandbox_save('easylist.txt', overall_rules, meowContext().tempDir);
  try {
    webview.AdsBlockManager.setAdsBlockRules(meowContext().tempDir + '/easylist.txt', true);
  } catch (e) {
    console.error('[submit_EasyList] Failed: ' + e);
  }
}

/**
 * Get all file names of EasyList rules in directory of filesDir/easylist.
 */
export function get_EasyLists() {
  let result: string[][] = [];
  try {
    const files = fileIo.listFileSync(meowContext().filesDir + '/easylist', { recursion: false });
    for (let index = 0; index < files.length; index++) {
      const filename = meowContext().filesDir + '/easylist/' + files[index];
      result.push([files[index], add_units_to_size(fileIo.statSync(filename).size)]);
    }
  } catch (e) {
    console.error('[refresh_easy_list] Failed: ' + e);
  }
  return result;
}