import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { meowContext } from './environment_tools';

/**
 * THEORETICALLY THIS FILE IS LEGACY.
 *
 * AS WE HAVE MOVED TOTALLY AWAY FROM KVSTORE SINCE SEP 30 2025.
 *
 * BUT MIGRATION IN bunch_of_settings.ets AND BOOKMARKS (init.ets) STILL NEEDS THIS, SO WE KEPT THIS FILE INTACT.
 * */

let kvs: distributedKVStore.DeviceKVStore | undefined = undefined;

export async function kv_store_get(key_name: string) {
  if (kvs == undefined) {
    await get_kv_store_into_app_storage();
    // console.log("[kv_store_tools][GET] kvStore not found from AppStorage! Created & Stored a new one.");
  } else {
    // console.log('[kv_store_tools][GET] Using an existing KVStore.');
  }

  if (kvs) {
    // If kvStore already got
    let get_result = "";
    await kvs.get(key_name).then((value) => {
      // console.log("[kv_store_tools] Succeeded in getting data, key: " + key_name + ".")
      get_result = value as string;
    }).catch(() => {
      get_result = "undefined"
    })
    return get_result;
  } else {
    let get_result = "error"
    console.error("[kv_store_tools][GET][ERROR] Undefined KVStore! ")
    return get_result;
  }
}

// export async function kv_store_put(key_name: string, put_content: string) {
//   if (kvs == undefined) {
//     await get_kv_store_into_app_storage();
//     // console.log("[kv_store_tools][GET] kvStore not found from AppStorage! Created & Stored a new one.");
//   } else {
//     // console.log('[kv_store_tools][GET] Using an existing KVStore.');
//   }
//
//   if (kvs) {
//     kvs.put(key_name, put_content, (err) => {
//       if (err !== undefined) {
//         console.error(`[kv_store_tools][ERROR] Failed to put data. Code: ${err.code},message: ${err.message}`);
//       } else {
//         console.log("[kv_store_tools] Succeeded in putting data, key: " + key_name + ", content:\n\t" + put_content);
//       }
//     });
//   }
//
// }
//
// export async function kv_store_delete(key_name: string) {
//   if (kvs == undefined) {
//     console.log("[kv_store_tools][GET] Launch of app, now getting kvStore")
//     await get_kv_store_into_app_storage();
//   }
//   if (kvs) {
//     kvs.delete(key_name, (err) => {
//       if (err !== undefined) {
//         console.error(`[kv_store_tools][ERROR] Failed to delete data. Code: ${err.code},message: ${err.message}`);
//       } else {
//         console.info("[kv_store_tools] Succeeded in deleting data, key: " + key_name + ".");
//       }
//     });
//   }
// }

async function get_kv_store_into_app_storage() {
  console.log('[kv_store_tools] Getting a KVStore into AppStorage...')
  let t0 = Date.now();

  const kvManagerConfig: distributedKVStore.KVManagerConfig = {
    context: meowContext(),
    bundleName: 'com.next.liny.linysbrowserNEXT',
  }

  try {
    let kvManager = distributedKVStore.createKVManager(kvManagerConfig);
    console.info("[kv_store_tools] Succeeded in creating KVManager!");
    // Get kvManager

    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: false,
      kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
      securityLevel: distributedKVStore.SecurityLevel.S2,
    };

    await kvManager.getKVStore<distributedKVStore.DeviceKVStore>('storeId', options)
      .then((store: distributedKVStore.DeviceKVStore) => {
        kvs = store;
        let t = Date.now() - t0;
        console.info("[kv_store_tools] Succeeded in getting KVStore! (" + t + ' ms)');
        // Got kvStore
      }).catch((err: BusinessError) => {
        console.error(`[kv_store_tools][ERROR] Failed to get KVStore. Code is ${err.code},message is ${err.message}.`);
      });
    // Get kvStore

  } catch (e) {
    let error = e as BusinessError;
    console.error(`[kv_store_tools][ERROR] Failed to create KVManager. Code is ${error.code},message is ${error.message}.`);
  }
}

// /**
//  * The only items stored in kv_store are the browsing statuses.
//  * @returns A json format string.
//  * */
// export async function export_json_kv_store() {
//   let result_string: string[] = [];
//   result_string.push('    "continue_tabs_count": "' + await kv_store_get('continue_tabs_count') + '"');
//   result_string.push('    "continue_tabs_main_on": "' + await kv_store_get('continue_tabs_main_on') + '"');
//   result_string.push('    "continue_tabs_sub_on": "' + await kv_store_get('continue_tabs_sub_on') + '"');
//   result_string.sort();
//   return '{\n' + result_string.join(',\n') + '\n}';
// }
//
// /**
//  * Imports settings from a json text.
//  * @param text The json text.
//  * @returns True if succeeded.
//  * */
// export async function import_json_kv_store(text: string) {
//   let jsonObject: Record<string, string> | null = null;
//   if (text.length < 2) {
//     return false;
//   }
//
//   try {
//     jsonObject = JSON.parse(text);
//   } catch (e) {
//     console.log('[Meow][kv_store_tools] Import kv_store failed! Json parse failed!');
//     return false;
//   }
//
//   Object.entries(jsonObject as Record<string, string>).forEach(async (item) => {
//     const key = item[0];
//     const val = item[1];
//     kv_store_put(key, val);
//   })
//   console.log('[Meow][kv_store_tools] Import kv_store:\n' + text);
//   return true;
// }