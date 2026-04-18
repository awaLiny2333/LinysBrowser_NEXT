import { meowManagedSettings } from "../classes/meowManagedSettings";
import { AppStorageV2 } from "@kit.ArkUI";

/**
 * Resets the animation params.
 */
export function resetAnimations() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  settings.setByIndex(39, 36);
  settings.setByIndex(40, 20);
}

/**
 * Resets the color params.
 */
export function resetColors() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  settings.setByIndex(62, '#E1E9E3');
  settings.setByIndex(63, '#CDD7CD');
  settings.setByIndex(64, '#243B24');
  settings.setByIndex(65, '#0F1A0F');
  settings.setByIndex(66, '#2A392A');
  settings.setByIndex(67, '#E1E9E3');
}
