import { fileIo } from '@kit.CoreFileKit';
import { meowContext } from '../utils/environment_tools';
import { sandbox_read_text_sync } from '../utils/storage_tools';

export function scan_extensions() {
  let extensions: string[] = [];
  try {
    extensions = fileIo.listFileSync(meowContext().filesDir + '/extensions', { recursion: false });
  } catch (error) {
    return [];
  }
  console.log('[zone_actions][scan_extensions] Result: ' + extensions);
  return extensions;
}

export function refresh_AppStorage_extensions() {
  let xts = scan_extensions();
  AppStorage.setOrCreate('extensions', xts);
}

/**
 * Reads the manifest of extension.
 * @param id The id of extension.
 * @returns The manifest object.
 * */
export function manifest_of_extension(id: string) {
  let versions: string[] = [];
  try {
    versions = fileIo.listFileSync(meowContext().filesDir + '/extensions/' + id, { recursion: false });
  } catch (e) {
    return undefined;
  }
  let manifest = sandbox_read_text_sync(`/extensions/${id}/${versions[0]}/manifest.json`);
  let m: object = JSON.parse(manifest);
  console.log(`[extension_actions][manifest_of_extension] Read manifest.json! "name"=${m?.['name']}` + '\n' + m);
  return m;
}