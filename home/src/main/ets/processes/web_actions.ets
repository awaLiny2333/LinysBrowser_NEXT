import lazy { fileIo } from '@kit.CoreFileKit';
import lazy { meowContext } from '../utils/environment_tools';
import lazy { sandbox_read_text_sync, sandbox_save } from '../utils/storage_tools';
import lazy { webview } from '@kit.ArkWeb';

export function apply_EasyList() {
  let lists = get_EasyLists();
  let overall_rules = '';
  for (let index = 0; index < lists.length; index++) {
    let new_paragraph = sandbox_read_text_sync('easylist/' + lists[index]);
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

export function get_EasyLists() {
  let results: string[] = [];
  try {
    results = fileIo.listFileSync(meowContext().filesDir + '/easylist', { recursion: false });
  } catch (e) {
    console.error('[refresh_easy_list] Failed: ' + e);
  }
  return results;
}