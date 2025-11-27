import lazy { fileIo } from '@kit.CoreFileKit';
import lazy { BusinessError } from '@kit.BasicServicesKit';
import lazy { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import lazy { meowContext } from '../utils/environment_tools';
import {
  sandbox_mkdir_sync,
  sandbox_read_arrayBuffer_sync,
  sandbox_read_text_sync,
  sandbox_rename_sync,
  sandbox_rmdir_sync,
  sandbox_save
} from '../utils/storage_tools';
import lazy { storage_of_id, window_of_id } from '../utils/ui_tools';

/**
 * Checks and discover saved zones on disk.
 * @returns The list of zone names.
 * */
export function scan_zones() {
  let opened: boolean[] = [];
  let zones: string[] = [];
  try {
    zones = fileIo.listFileSync(meowContext().filesDir + '/zones', { recursion: false });
  } catch (error) {
    return [[], []];
  }
  console.log('[zone_actions][scan_zones] Result: ' + zones);
  try {
    for (let index = 0; index < zones.length; index++) {
      opened.push(zone_opened(zones[index]));
    }
  } catch (e) {
    console.error('[zone_actions][scan_zones] Failed: ' + e);
  }
  return [zones, opened];
}

/**
 * Modifies the zone's name, renaming the folder on disk.
 * @param original Original name.
 * @param after New name.
 * */
export function modify_zone_name(original: string, after: string) {
  sandbox_rename_sync('zones/' + original, 'zones/' + after);
  refresh_AppStorage_zones();
}

/**
 * Marks the zone open state in AppStorage. Usually used to update shortcut button statuses.
 * @param alias The alias of window / zone.
 * @param stat The status to be put.
 * */
export function mark_zone_opened(alias: string, stat: boolean) {
  let zones = AppStorage.get('zones') as string[];
  let idx = zones.indexOf(alias);
  let zones_opened = AppStorage.get('zones_opened') as boolean[];
  zones_opened[idx] = stat;
}

/**
 * Refreshes the zones entries in AppStorage.
 * */
export function refresh_AppStorage_zones() {
  let zones = scan_zones();
  AppStorage.setOrCreate('zones', zones[0] as string[]);
  AppStorage.setOrCreate('zones_opened', zones[1] as boolean[]);
}

/**
 * Checks if a zone is opened.
 * @param zone_alias The alias of zone / window.
 * */
export function zone_opened(zone_alias: string) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  if (windowStorages) {
    // windowStorages may be undefined, if is called before any window creation
    for (let index = 0; index < windowStorages.length; index++) {
      let is_zone = windowStorages[index].get('is_zone') as boolean;
      let alias = windowStorages[index].get('my_window_alias') as string;
      if (is_zone && alias == zone_alias) {
        return true;
      }
    }
  }
  return false;
}

/**
 * Marks a window to be a zone.
 * @param window_id The id of zone / window.
 * @returns True if success, false if duplicate alias, undefined if already is zone.
 * */
export function set_zone(window_id: string) {
  let storage = storage_of_id(window_id);
  let alias = storage.get('my_window_alias') as string;

  // Do not allow duplicate aliases
  if ((scan_zones()[0] as string[]).includes(alias)) {
    console.log(`[zone_actions][set_zone] Failed, duplicated alias!`);
    return false;
  }

  // Save
  let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
  let lord = AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string;
  sandbox_mkdir_sync('zones/' + alias);
  if (window_id == lord) {
    // If is lord, Clean current continue file;
    let src = meowContext().filesDir + '/continue/';
    let des = meowContext().filesDir + '/zones/' + alias + '/';
    console.log(`[set_zone] About to copyDirSync! src=${src}, des=${des}`);
    fileIo.copyDirSync(src, des, 1);
    sandbox_rmdir_sync('continue');
    sandbox_mkdir_sync('continue');
  } else {
    // If is other window, then directly save web states to /zone/name
    tabs.re_save_web_state(0, 'zones/' + alias);
  }
  sandbox_save(web_state_dir(storage) + '/stat', tabs.main_tab_idx + ' ' + tabs.sub_tab_idx);

  // Mark
  storage.setOrCreate('is_zone', true);
  refresh_AppStorage_zones();

  // Window Title
  let windowClass = window_of_id(window_id);
  if (windowClass) {
    windowClass.setWindowTitle('󰙟 ' + alias).catch((e: BusinessError) => {
      console.error('[set_zone][change_window_alias] Set alias failed! ' + JSON.stringify(e));
    });
  }
  return true;
}

/**
 * Marks a window to be NO LONGER a zone.
 * @param window_id The id of zone / window.
 * @returns True if success, undefined if is already NOT a zone.
 * */
export function off_zone(window_id: string) {
  let storage = storage_of_id(window_id);
  let alias = storage.get('my_window_alias') as string;

  // Read all web_states out
  let zone_dir = meowContext().filesDir + '/' + 'zones/' + alias;
  console.log('[off_zone] zone_dir: ' + zone_dir);
  let tabs_list = fileIo.listFileSync(zone_dir);
  let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
  for (let index = 0; index < Math.floor(tabs_list.length / 2); index++) {
    if (tabs.Tabs[index].web_state_array) {
      // Already loaded, do nothing
    } else {
      try {
        let state_file = 'zones/' + alias + "/continue_tabs_web_state_array_" + index.toString();
        let array_buffer = sandbox_read_arrayBuffer_sync(state_file); // State of that tab
        if (array_buffer) {
          tabs.Tabs[index].web_state_array = new Uint8Array(array_buffer);
        } else {
          console.error("[off_zone] Read web state failed! Read NOTHING from disk???");
        }
      } catch (e) {
        console.error('[off_zone][restore_zone] Failed: ' + e);
      }
    }
  }

  // After work
  sandbox_rmdir_sync('zones/' + alias);
  let lord = AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string;
  if (window_id == lord) {
    // If is lord, resave web states;
    let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
    tabs.re_save_web_state(0, 'continue');
  } else {
    // If is other window, then directly save web states to /zone/name
    // Do nothing
  }
  storage.setOrCreate('is_zone', false);
  refresh_AppStorage_zones();

  // Window Title
  let windowClass = window_of_id(window_id);
  if (windowClass) {
    windowClass.setWindowTitle(alias).catch((e: BusinessError) => {
      console.error('[set_zone][change_window_alias] Set alias failed! ' + JSON.stringify(e));
    });
  }
  return true;
}

/**
 * Deletes an offline zone.
 * @param alias The alias of the Zone / window.
 * @returns True if success, false otherwise (Zone is online?)
 * */
export function del_offline_zone(alias: string) {
  let zones = AppStorage.get('zones') as string[];
  let idx = zones.indexOf(alias);
  let zones_opened = AppStorage.get('zones_opened') as boolean[];
  if (zones_opened[idx]) {
    return false;
  }
  sandbox_rmdir_sync('zones/' + alias);
  refresh_AppStorage_zones();
  return true;
}

/**
 * Returns the web state directory for saving.
 * @param storage The LocalStorage of window.
 * @returns The directory or undefined (if is neither a zone nor lord window).
 * */
export function web_state_dir(storage: LocalStorage) {
  let alias = storage.get('my_window_alias') as string;
  let is_zone = storage.get('is_zone') as boolean;
  if (is_zone) {
    return 'zones/' + alias;
  }
  // Not zone, check if is lord
  let is_lord = (storage.get('my_window_id') as string) == (AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string);
  if (is_lord) {
    return 'continue';
  }
  // Neither zone, nor lord
  return undefined;
}

// Data

/**
 * Gets the tab open state of zone.
 * @param storage The LocalStorage.
 * @returns [continue_tabs_main_on, continue_tabs_sub_on].
 * */
export function stat_of_zone(storage: LocalStorage) {
  let dir = web_state_dir(storage);
  let tabs_stat = sandbox_read_text_sync(dir + '/stat');
  if (tabs_stat != 'undefined') {
    // Set stat
    let stat = tabs_stat.split(' ');
    let continue_tabs_main_on = Number.parseInt(stat[0]);
    let continue_tabs_sub_on = Number.parseInt(stat[1]);
    return [continue_tabs_main_on, continue_tabs_sub_on];
  }
  return [0, -1];
}

/**
 * Gets the my_window_id of a zone with alias.
 * @param alias The alias.
 * @returns The my_window_id or undefined.
 * */
export function window_id_of_zone(alias: string) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  for (let index = 0; index < windowStorages.length; index++) {
    let s = windowStorages[index];
    if (s.get('is_zone') as boolean && s.get('my_window_alias') as string == alias) {
      return s.get('my_window_id') as string;
    }
  }
  return undefined;
}

/**
 * Gets the storage of a zone with alias.
 * @param alias The alias.
 * @returns The LocalStorage or undefined.
 * */
export function storage_of_zone(alias: string) {
  let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
  for (let index = 0; index < windowStorages.length; index++) {
    let s = windowStorages[index];
    if (s.get('is_zone') as boolean && s.get('my_window_alias') as string == alias) {
      return s;
    }
  }
  return undefined;
}