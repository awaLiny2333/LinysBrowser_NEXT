import { window } from '@kit.ArkUI';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';

/**
 * Gets current tabs style is whether horizontal or not.
 * @returns a boolean. True for is horizontal.
 * */
export function current_tabs_style_is_horizontal(storage: LocalStorage) {
  let tablet_mode = storage.get('tablet_mode') as boolean;
  let tabs_style = AppStorage.get('tabs_style') as string;
  let tabs_style_non_tablet_mode = AppStorage.get('tabs_style_non_tablet_mode') as string;
  if (tablet_mode) {
    return tabs_style == 'horizontal';
  } else {
    return tabs_style_non_tablet_mode == 'horizontal';
  }
}

/**
 * Gets the last LocalStorage.
 * @returns A LocalStorage.
 * */
export function last_storage() {
  return (AppStorage.get('windowStorages') as LocalStorage[])[(AppStorage.get('windowStorages') as LocalStorage[]).length-1];
}

/**
 * Infers the index of window.
 * @param w The windowClass (window.Window).
 * */
export function window_index_of_windowClass(w: window.Window) {
  let windowClasses = AppStorage.get('windows') as window.Window[];
  let window_idx = windowClasses.indexOf(w);
  return window_idx;
}

/**
 * Infers the index of window.
 * @param id The windowClass id (string).
 * */
export function window_index_of_id(id: string) {
  let windowIds = AppStorage.get('windowIds') as string[];
  let window_idx = windowIds.indexOf(id);
  return window_idx;
}

/**
 * Returns window of named by the id.
 * @param id The id.
 * @returns The window.Window.
 * */
export function window_of_id(id: string) {
  let windowClasses = AppStorage.get('windows') as window.Window[];
  let idx = window_index_of_id(id);
  return windowClasses[idx];
}

/**
 * Returns storage of named by the id.
 * @param id The id.
 * @returns The LocalStorage.
 * */
export function storage_of_id(id: string) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  let idx = window_index_of_id(id);
  return windowStorages[idx];
}

/**
 * Infers the id of window.
 * @param w The windowClass (window.Window).
 * */
export function window_id_of_windowClass(w: window.Window) {
  let windowIds = AppStorage.get('windowIds') as string[];
  let window_id = windowIds[window_index_of_windowClass(w)];
  return window_id;
}

/**
 * Retrieves the storage of the specific id window.
 * @param w The windowClass (window.Window).
 * */
export function storage_of_window(w: window.Window) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  let windowStorage = windowStorages[window_index_of_windowClass(w)];
  return windowStorage;
}

/**
 * Retrieves the bunch_of_tabs of the specific id window.
 * @param w The windowClass (window.Window).
 * */
export function bunch_of_tabs_of_window(w: window.Window) {
  let all_bunch_of_tabs = AppStorage.get('all_bunch_of_tabs') as bunch_of_tabs[];
  let tabs = all_bunch_of_tabs[window_index_of_windowClass(w)];
  return tabs;
}
