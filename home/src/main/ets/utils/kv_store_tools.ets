import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

export async function kv_store_get(key_name: string) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[Meow][kv_store_tools][GET] First launch of app, now getting kvStore")
    await get_kv_store();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  if (kvStore !== undefined) {
    // If kvStore already got
    let get_result = "";
    await kvStore.get(key_name).then((value) => {
      console.log("[Meow][kv_store_tools] Succeeded in getting data, key: " + key_name + ".")
      get_result = value as string;
    }).catch(() => {
      get_result = "undefined"
    })
    return get_result;

  } else {
    let get_result = "error"
    console.log("[Meow][kv_store_tools][GET][ERROR] Undefined KVStore! ")
    return get_result;

  }
}

export async function kv_store_put(key_name: string, put_content: string) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[Meow][kv_store_tools][GET] First launch of app, now getting kvStore")
    await get_kv_store();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  kvStore.put(key_name, put_content, (err) => {
    if (err !== undefined) {
      console.error(`[Meow][kv_store_tools][ERROR] Failed to put data. Code: ${err.code},message: ${err.message}`);
    } else {
      console.log("[Meow][kv_store_tools] Succeeded in putting data, key: " + key_name + ".")
    }
  });

}

export async function kv_store_delete(key_name: string) {
  if (AppStorage.get('kvStore') == undefined) {
    console.log("[Meow][kv_store_tools][GET] First launch of app, now getting kvStore")
    await get_kv_store();
  }
  let kvStore = AppStorage.get('kvStore') as distributedKVStore.DeviceKVStore;

  kvStore.delete(key_name, (err) => {
    if (err !== undefined) {
      console.error(`[Meow][kv_store_tools][ERROR] Failed to delete data. Code: ${err.code},message: ${err.message}`);
    } else {
      console.info("[Meow][kv_store_tools] Succeeded in deleting data, key: " + key_name + ".");
    }
  });

}

async function get_kv_store() {
  let kvManager = AppStorage.get('kvManager') as distributedKVStore.KVManager;
  let kvStore: distributedKVStore.DeviceKVStore | undefined = undefined;
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
      console.info("Succeeded in getting KVStore");
      kvStore = store;
      AppStorage.setOrCreate("kvStore", kvStore)
      // Got kvStore
    }).catch((err: BusinessError) => {
      console.error(`Failed to get KVStore.code is ${err.code},message is ${err.message}`);
    });
  // Get kvStore
}