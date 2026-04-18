import { AppStorageV2, display, window } from '@kit.ArkUI';
import lazy { deviceInfo, power, settings } from '@kit.BasicServicesKit';
import lazy { motion } from '@kit.MultimodalAwarenessKit';
import lazy { defaultAnimation, isSmartReachabilityOn } from '../../components/settings';
import { meowAppStatuses } from '../../hosts/system/windows/classes/meowAppStatuses';
import lazy { meowAvoid } from '../hosts/meowAvoid';
import lazy { meowLayout } from '../hosts/meowLayout';
import lazy { meow, meowLevel } from './catsLogger';

export const wideModeThreshold = 700;
export const shortModeThreshold = 400;

/**
 * Converts px to vp.
 * @param px The true px.
 * @returns The equivalent vp.
 * */
export function meowPx2vp(px: number) {
  try {
    return px / display.getDefaultDisplaySync().densityPixels;
  } catch (e) {
    // This is not good.
    meow(`Error: ${e}, returned in px.`, 'meowPx2vp', meowLevel.ERROR);
    return px;
  }
}

/**
 * Converts vp to px.
 * @param vp The true vp.
 * @returns The equivalent px.
 * */
export function meowVp2px(vp: number) {
  try {
    return vp * display.getDefaultDisplaySync().densityPixels;
  } catch (e) {
    // This is not good.
    meow(`Error: ${e}, returned in vp.`, 'meowVp2px', meowLevel.ERROR);
    return vp;
  }
}

/**
 * Returns the text's height.
 * @param text The text.
 * @param uiContext The UIContext.
 * @param fontSize The fontSize.
 * @param fontWeight The fontWeight.
 * @returns The height in vp.
 * */
export function measureTextHeight(text: string, uiContext: UIContext, fontSize: number, fontWeight: FontWeight): number {
  return meowPx2vp(uiContext
    .getMeasureUtils()
    .measureTextSize({ textContent: text, fontSize: fontSize, fontWeight: fontWeight })
    .width as number);
}

export let defaultAnima: AnimateParam = { curve: Curve.FastOutSlowIn, duration: 350 };

export const defaultRoundedRadius: number = deviceInfo.deviceType == deviceInfo.DeviceTypes.TYPE_2IN1 ? 15 : 15; // 30

export const defaultInnerRadius: number = deviceInfo.deviceType == deviceInfo.DeviceTypes.TYPE_2IN1 ? 8 : 8; // 20

export const defaultMenuItemRadius: number = deviceInfo.deviceType == deviceInfo.DeviceTypes.TYPE_2IN1 ? 5 : 5; // 18

// Decor (Free window mode)

export const defaultDecorHeight: number = 40;

/**
 * Sets the decor height to defaultDecorHeight (50).
 * @param windowClass The window.Window object.
 * */
export function setDecorHeight(windowClass: window.Window) {
  try {
    meow(`setDecorHeight: ${defaultDecorHeight}`, 'setDecorHeight', meowLevel.INFO);
    windowClass.setWindowDecorHeight(defaultDecorHeight);
  } catch (e) {
    meow(`windowClass.setWindowDecorHeight(defaultDecorHeight) Failed: ${e}`, 'setDecorHeight', meowLevel.ERROR);
  }
}

// Avoid

/**
 * Enables the listeners for avoid area change.
 * @param windowClass The window.Window object.
 * */
export function listenAvoid(windowClass: window.Window, windowId: string) {
  try {
    windowClass.on('avoidAreaChange', (data) => {
      // meow('Changes on avoid areas!', 'avoidAreaChange', meowLevel.INFO);
      let myLayout = AppStorageV2.connect(meowLayout, `meowLayout_${windowId}`)!;
      let avoid = AppStorageV2.connect(meowAvoid, `meowAvoid_${windowId}`)!;

      if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
        let top = meowPx2vp(data.area.topRect.height);
        if (myLayout && !myLayout.freeWindow) {
          // Traditional window
          avoid.top = top;
        } else {
          // Free window
          avoid.top = Math.max(top, defaultDecorHeight);
        }
      }
      if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        let bottom = meowPx2vp(data.area.bottomRect.height) * 0.75;
        if (myLayout && !myLayout.freeWindow) {
          avoid.bottom = Math.max(bottom, 8);
        } else {
          avoid.bottom = 0; // No bottom avoid for free windows.
        }
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let left = meowPx2vp(data.area.leftRect.width);
        avoid.left = Math.max(8, left);
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let right = meowPx2vp(data.area.rightRect.width);
        avoid.right = Math.max(8, right);
      }
    });
  } catch (e) {
    meow(`windowClass.on('avoidAreaChange') Failed: ${e}`, 'avoidAreaChange', meowLevel.ERROR);
  }
}

/**
 * Gets the avoid information and sync to AppStorage.
 * @param windowClass The window.Window object.
 * */
export function getUpdateAvoid(windowClass: window.Window, windowId: string) {
  try {
    let avoidArea: window.AvoidArea;
    let avoid = AppStorageV2.connect(meowAvoid, `meowAvoid_${windowId}`)!;
    let myLayout = AppStorageV2.connect(meowLayout, `meowLayout_${windowId}`)!;

    // Get
    avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    let top = meowPx2vp(avoidArea.topRect.height);
    if (myLayout && !myLayout.freeWindow) {
      // Traditional window
      avoid.top = top;
    } else {
      // Free window
      avoid.top = Math.max(top, defaultDecorHeight);
    }

    avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    if (myLayout && !myLayout.freeWindow) {
      avoid.bottom = Math.max(meowPx2vp(avoidArea.bottomRect.height) * 0.75, 8);
    } else {
      avoid.bottom = 0; // No bottom avoid for free windows.
    }

    avoid.left = Math.max(meowPx2vp(avoidArea.leftRect.width), 8);
    avoid.right = Math.max(8, meowPx2vp(avoidArea.rightRect.width));

  } catch (e) {
    // TODO: Implement error handling.
  }
}

// Free window mode

/**
 * Listens to the Free-window Mode change and automatically switch modes.
 * @param context
 * @param windowClass
 * @param storage
 * @param id
 * */
export function listenFreeWindowMode(context: Context, windowClass: window.Window, windowId: string) {
  meow('ON!', 'listenFreeWindowMode');
  settings.registerKeyObserver(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY, () => {
    settings.getValue(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY)
      .then((val) => {
        const free = (val == 'true');
        const myLayout = AppStorageV2.connect(meowLayout, `meowLayout_${windowId}`)!;

        // Update!
        if (myLayout.freeWindow != free) {
          myLayout.freeWindow = free;
          if (free) {
            setDecorHeight(windowClass);
          }
        }
        meow(`settings.getValueSync "window_pcmode_switch_status" = ${val}`, 'listenFreeWindowMode', meowLevel.INFO);
      });
  });
}

/**
 * Checks settings to figure out if currently is in free window mode.
 * @param context The UIAbility Context.
 * @returns A boolean value.
 * */
export function getUpdateFreeWindowMode(context: Context, windowClass: window.Window, windowId: string) {
  const myLayout = AppStorageV2.connect(meowLayout, `meowLayout_${windowId}`)!;
  if (deviceInfo.deviceType == '2in1') {
    meow('Return true for 2in1 type!', 'getUpdateFreeWindowMode', meowLevel.INFO);
    myLayout.freeWindow = true;
    setDecorHeight(windowClass);
    return true;
  }

  let val = settings.getValueSync(context, 'window_pcmode_switch_status', 'false', settings.domainName.USER_PROPERTY);
  let free = (val == 'true');

  // Update!
  if (myLayout.freeWindow != free) {
    myLayout.freeWindow = free;
    if (free) {
      setDecorHeight(windowClass);
    }
  }
  meow(`settings.getValueSync "window_pcmode_switch_status" = ${val}`, 'getUpdateFreeWindowMode', meowLevel.INFO);
  return free;
}

// Layout mode

export const windowTopAvoidRight: number = 140;
export const windowTopAvoidLeft: number = 20;

/**
 * Listens to the power save mode change and sync status to meowLayout.
 *
 * System common events won't trigger once the app is in background.
 * So we have to use this instead as a 下策.
 *
 * @param interval The interval between each check.
 */
export function listenPowerSave(interval: number = 10000) {
  meow(`Try to force listenPowerSave();`, 'listenPowerSave');
  setInterval(() => {
    const newMode = power.getPowerMode();
    const isPowerSave = (newMode == power.DevicePowerMode.MODE_POWER_SAVE || newMode == power.DevicePowerMode.MODE_EXTREME_POWER_SAVE || newMode == power.DevicePowerMode.MODE_CUSTOM_POWER_SAVE);
    const myApp = AppStorageV2.connect(meowAppStatuses);
    if (myApp) {
      if (myApp.powerSave != isPowerSave) {
        animateToImmediately(defaultAnimation(), () => {
          myApp.powerSave = isPowerSave;
        });
        meow(`Powermode changed! powerSave = ${isPowerSave}`, 'listenPowerSave');
      }
    }
  }, interval);
}

/**
 * Listens to the smart reachability change and sync status to meowLayout.
 */
export function listenSmartReachability() {
  if (canIUse("SystemCapability.MultimodalAwareness.Motion")) {
    try {
      motion.on('holdingHandChanged', (m: motion.HoldingHandStatus) => {
        // Received a change!
        if (m == motion.HoldingHandStatus.UNKNOWN_STATUS || m == motion.HoldingHandStatus.NOT_HELD || m == motion.HoldingHandStatus.BOTH_HANDS_HELD) {
          // Do nothing
        } else {
          const useRightHand = m == motion.HoldingHandStatus.RIGHT_HAND_HELD;
          if (isSmartReachabilityOn()) {
            const myApp = AppStorageV2.connect(meowAppStatuses)!;
            if (myApp.smartReachabilitySaysWeShouldPreferRightHand != useRightHand) myApp.smartReachabilitySaysWeShouldPreferRightHand = useRightHand;
          }
        }
      });
      meow('listen succeeded!', 'listenSmartReachability][motion.on');
    } catch (e) {
      meow(`listen Failed: ${e}`, 'listenSmartReachability][motion.on', meowLevel.ERROR);
    }
  } else {
    meow('Rejected. Cannot use [SystemCapability.MultimodalAwareness.Motion]!', 'listenSmartReachability][canIUse', meowLevel.WARN);
  }
}

// Focus

/**
 * Enables the listeners for avoid area change.
 *
 * Works OK in both window modes (free / traditional).
 *
 * @param windowClass The window.Window object.
 * */
export function listenFocus(windowClass: window.Window, windowId: string) {
  // Focus Listener
  try {
    windowClass.on("windowEvent", (windowEvent) => {
      let on_focus = false;
      if (windowEvent == window.WindowEventType.WINDOW_ACTIVE || windowEvent == window.WindowEventType.WINDOW_SHOWN) {
        // Focused
        on_focus = true;
      }
      let myLayout = AppStorageV2.connect(meowLayout, `meowLayout_${windowId}`);
      if (myLayout) {
        myLayout.isOnFocus = on_focus;
      }
    });
  } catch (e) {
    meow('Failed: ' + e, 'listen_focus', meowLevel.ERROR);
  }
}

// Toast

export const toastDuration: number = 5000;

export function toast(UIContext: UIContext, msg: ResourceStr) {
  try {
    UIContext.getPromptAction()
      .showToast({
        message: msg,
        duration: toastDuration
      });
  } catch (e) {
    meow(`showToast failed: ${e}`, 'ui', meowLevel.ERROR);
  }
}
