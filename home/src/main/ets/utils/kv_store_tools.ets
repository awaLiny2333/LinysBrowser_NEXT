import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

export async function kv_store_get(key_name: string) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[kv_store_tools][GET] Launch of app, now getting kvStore")
    await get_kv_store_into_app_storage();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  if (kvStore !== undefined) {
    // If kvStore already got
    let get_result = "";
    await kvStore.get(key_name).then((value) => {
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

export async function kv_store_put(key_name: string, put_content: string) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[kv_store_tools][GET] Launch of app, now getting kvStore")
    await get_kv_store_into_app_storage();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  kvStore.put(key_name, put_content, (err) => {
    if (err !== undefined) {
      console.error(`[kv_store_tools][ERROR] Failed to put data. Code: ${err.code},message: ${err.message}`);
    } else {
      console.log("[kv_store_tools] Succeeded in putting data, key: " + key_name + ".")
    }
  });

}

/**
 *
 * @param key_name The name of key stored in kvStore.
 * @returns The Uint8Array.
 * @returns An Empty Uint8Array if the key is not found.
 * @returns An Uint8Array containing -1 if kvStore is undefined.
 * */
export async function kv_store_get_uint_8_array(key_name: string) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[kv_store_tools][GET] Launch of app, now getting kvStore")
    await get_kv_store_into_app_storage();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  if (kvStore !== undefined) {
    // If kvStore already got
    let get_result:Uint8Array = new Uint8Array();
    await kvStore.get(key_name).then((value) => {
      console.log("[kv_store_tools] Succeeded in getting data, key: " + key_name + ".")
      get_result = value as Uint8Array;
    }).catch(() => {
      get_result = new Uint8Array();
    })
    return get_result;

  } else {
    let get_result = new Uint8Array(-1);
    console.error("[kv_store_tools][GET][ERROR] Undefined KVStore! ")
    return get_result;

  }
}

export async function kv_store_put_uint_8_array(key_name: string, put_content: Uint8Array) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[kv_store_tools][GET] Launch of app, now getting kvStore")
    await get_kv_store_into_app_storage();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  kvStore.put(key_name, put_content, (err) => {
    if (err !== undefined) {
      console.error(`[kv_store_tools][ERROR] Failed to put data. Code: ${err.code},message: ${err.message}`);
    } else {
      // console.log("[kv_store_tools] Succeeded in putting data, key: " + key_name + ".")
    }
  });

}

export async function kv_store_delete(key_name: string) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[kv_store_tools][GET] Launch of app, now getting kvStore")
    await get_kv_store_into_app_storage();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  kvStore.delete(key_name, (err) => {
    if (err !== undefined) {
      console.error(`[kv_store_tools][ERROR] Failed to delete data. Code: ${err.code},message: ${err.message}`);
    } else {
      console.info("[kv_store_tools] Succeeded in deleting data, key: " + key_name + ".");
    }
  });

}

async function get_kv_store_into_app_storage() {

  const kvManagerConfig: distributedKVStore.KVManagerConfig = {
    context: AppStorage.get('context') as common.UIAbilityContext,
    bundleName: 'com.next.liny.linysbrowserNEXT',
  }

  try {
    let kvManager = distributedKVStore.createKVManager(kvManagerConfig);
    console.info("[kv_store_tools] Succeeded in creating KVManager");
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
        console.info("[kv_store_tools] Succeeded in getting KVStore and storing it to AppStorage");
        AppStorage.setOrCreate("kvStore", store)
        // Got kvStore
      }).catch((err: BusinessError) => {
        console.error(`[kv_store_tools][ERROR] Failed to get KVStore.code is ${err.code},message is ${err.message}`);
      });
    // Get kvStore

  } catch (e) {
    let error = e as BusinessError;
    console.error(`[kv_store_tools][ERROR] Failed to create KVManager.code is ${error.code},message is ${error.message}`);
  }
}