import { distributedKVStore } from '@kit.ArkData';

let context = getContext(this);
const kvManagerConfig: distributedKVStore.KVManagerConfig = {
  context: context,
  bundleName: "com.next.liny.linysbrowserNEXT"
};
const store_options: distributedKVStore.Options = {
  createIfMissing: true,
  encrypt: false,
  backup: false,
  autoSync: false,
  // kvStoreType不填时，默认创建多设备协同数据库
  kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
  // 多设备协同数据库：kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
  securityLevel: distributedKVStore.SecurityLevel.S1
};

let kvManager: distributedKVStore.KVManager = distributedKVStore.createKVManager(kvManagerConfig);
let kvStore: distributedKVStore.DeviceKVStore | undefined = undefined;

async function kv_store_get_init() {
  await kvManager.getKVStore<distributedKVStore.DeviceKVStore>
  ("linys_Store", store_options).then((store: distributedKVStore.DeviceKVStore) => {
    console.info("[Meow][kv_store_tools] Succeeded in getting KVStore.");
    kvStore = store as distributedKVStore.DeviceKVStore;
    // 请确保获取到键值数据库实例后，再进行相关数据操作
  })
}

export async function kv_store_get(key_name: string) {
  if (kvStore !== undefined) {
    // If kvStore already got
    let get_result = "";
    await kvStore.get(key_name).then((value) => {
      console.log("[Meow][kv_store_tools] Succeeded in getting data, key: " + key_name + ".")
      get_result = value as string;
    })
    return get_result;
  } else {
    // If kvStore not yet got
    let get_result = ""
    await kv_store_get_init().then(async () => {
      console.log("[Meow][kv_store_tools][ERROR] Undefined KVStore! Now trying to get KVStore.")
      await kv_store_get(key_name).then((value) => {
        get_result = value as string;
      });
    })
    return get_result;
  }
}

export function kv_store_put(key_name: string, put_content: string) {
  if (kvStore !== undefined) {
    kvStore.put(key_name, put_content, (err) => {
      if (err !== undefined) {
        console.error(`[Meow][kv_store_tools][ERROR] Failed to put data. Code: ${err.code},message: ${err.message}`);
      } else {
        console.log("[Meow][kv_store_tools] Succeeded in putting data, key: " + key_name + ".")
      }
    });
  } else {
    kv_store_get_init().then(() => {
      console.log("[Meow][kv_store_tools][ERROR] Undefined KVStore! Now trying to get KVStore.")
      kv_store_put(key_name, put_content);
    })
  }
}

export function kv_store_delete(key_name: string) {
  if (kvStore !== undefined) {
    kvStore.delete(key_name, (err) => {
      if (err !== undefined) {
        console.error(`[Meow][kv_store_tools][ERROR] Failed to delete data. Code: ${err.code},message: ${err.message}`);
      } else {
        console.info("[Meow][kv_store_tools] Succeeded in deleting data, key: " + key_name + ".");
      }
    });
  } else {
    kv_store_get_init().then(() => {
      console.log("[Meow][kv_store_tools][ERROR] Undefined KVStore! Now trying to get KVStore.")
      kv_store_delete(key_name);
    })
  }
}
