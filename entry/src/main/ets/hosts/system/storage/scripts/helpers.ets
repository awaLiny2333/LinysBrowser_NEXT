import { AppStorageV2 } from "@kit.ArkUI";
import { meowResources } from "../classes/meowResources";

let myResource: meowResources | undefined = undefined;

/**
 * Guarantee the existence of the meowResources instance and return it.
 * @returns The meowResources object!
 */
export function getMyResource() {
  if (!myResource) {
    myResource = AppStorageV2.connect(meowResources)!;
  }
  return myResource;
}
