import { meowAppHost } from "../classes/meowAppHost";
import { AppStorageV2 } from "@kit.ArkUI";

let myApp: meowAppHost | undefined = undefined;

/**
 * Guarantee the existence of the meowAppHost instance and return it.
 * @returns The meowAppHost object!
 */
export function getMyApp() {
  if (!myApp) {
    myApp = AppStorageV2.connect(meowAppHost, () => new meowAppHost())!;
  }
  return myApp;
}
