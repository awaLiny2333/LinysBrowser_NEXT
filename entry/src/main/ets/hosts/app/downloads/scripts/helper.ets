import { AppStorageV2 } from "@kit.ArkUI";
import { meowDawnloada } from "../classes/meowDawnloada";

let myDawn: meowDawnloada | undefined = undefined;

/**
 * Guarantee the existence of the meowDawnloada instance and return it.
 * @returns The meowDawnloada object!
 */
export function getMyDawn() {
  if (!myDawn) {
    myDawn = AppStorageV2.connect(meowDawnloada, () => new meowDawnloada())!;
  }
  return myDawn;
}
