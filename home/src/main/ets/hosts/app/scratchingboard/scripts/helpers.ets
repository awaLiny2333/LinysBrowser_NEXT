import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { meowBoardHolder } from "../classes/meowBoardHolder";

let myBoard: meowBoardHolder | undefined = undefined;

/**
 * Guarantee the existence of the meowAppHost instance and return it.
 * 
 * @returns The meowAppHost object!
 */
export function getMyBoard() {
  if (!myBoard) {
    myBoard = AppStorageV2.connect(meowBoardHolder, () => new meowBoardHolder())!;
  }
  return myBoard;
}
