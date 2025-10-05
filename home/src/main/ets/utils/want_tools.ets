// Wants
import { storage_of_id } from "./ui_tools";
import { window } from "@kit.ArkUI";

/**
 * Respond to want.
 * @param uri the want uri
 * @param action the want action
 * @param type the want type
 * */
export function check_want(uri: string, action: string, type: string, storage: LocalStorage) {
  if (uri.length == 0) {
    console.log('[Meow][init] Didn\'t load want for an empty want.');
    return;
  }
  console.log('[Meow][want] Load want with action: ' + action + ', type: ' + type);

  // Respond to want
  if (uri.substring(0, 7) == 'file://') {
    want_file(uri);
  } else {
    want_web(action, uri, storage);
  }
  uri = "";
}

function want_file(uri: string) {
  // TODO: Find a more elegant way to open things...
  console.log('[Meow][Want] Want uri is [' + uri + '].');
  // Copy want file
  // try {
  //   let file_content = uri_read_text_sync(this.want_uri);
  //   this.uni_new_tab_gateway = 'data:text/html, ' + encodeURIComponent(file_content);
  //   // let want_file_uri = copy_from_uri_to_sandbox(this.want_uri, '', 'want-cache.html');
  //   // this.uni_new_tab_gateway = want_file_uri;
  // } catch (e) {
  //   console.error(e);
  // }
}

function want_web(action: string, uri: string, storage: LocalStorage) {
  if (action == "ohos.want.action.viewData") {
    setTimeout(() => {
      console.log('[Meow][want] Load want uri: ' + uri);
      storage.set('universal_new_tab_gateway', uri);
    }, 0)
  }
}