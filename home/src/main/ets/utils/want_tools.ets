// Wants

/**
 * Respond to want.
 * @param uri the want uri
 * @param action the want action
 * @param type the want type
 * @returns True if a want is detected and processed.
 * */
export function check_want(uri: string, action: string, type: string, storage: LocalStorage) {
  if (uri.length == 0) {
    console.log('[Meow][init] Didn\'t load want for an empty want.');
    return false;
  }
  console.log('[Meow][want] Load want with uri: ' + uri + ', action: ' + action + ', type: ' + type + ', storage id: ' + storage.get('my_window_id'));

  // Respond to want
  if (uri.substring(0, 7) == 'file://') {
    want_file(uri, storage);
  } else {
    if (action == 'ohos.want.action.viewData') {
      want_web(uri, storage);
    }
  }
  uri = "";
  return true;
}

function want_file(uri: string, storage: LocalStorage) {
  console.log('[Meow][Want] Want uri is [' + uri + '].');
  storage.set('universal_new_tab_gateway', [uri, false]);
}

function want_web(uri: string, storage: LocalStorage) {
  console.log('[Meow][want] Load want uri: ' + uri);
  storage.set('universal_new_tab_gateway', [uri, false]);
}