import { AppStorageV2, display, window } from '@kit.ArkUI';
import lazy { deviceInfo, power, settings } from '@kit.BasicServicesKit';
import lazy { motion } from '@kit.MultimodalAwarenessKit';
import lazy { defaultAnimation, isSmartReachabilityOn, showNavigationIndicator } from '../../components/settings';
import { meowUiFullscreenStatus, meowUiHost } from '../../hosts/system/windows/classes/meowUiHost';
import { getMyApp } from '../../hosts/system/windows/scripts/helpers';
import lazy { meowAvoid } from '../hosts/meowAvoid';
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

/**
 * Returns the text's width.
 * @param text The text.
 * @param uiContext The UIContext.
 * @param fontSize The fontSize.
 * @param fontWeight The fontWeight.
 * @returns The width in vp.
 * */
export function measureTextWidth(text: string, uiContext: UIContext, fontSize: number, fontWeight: FontWeight): number {
  return meowPx2vp(uiContext
    .getMeasureUtils()
    .measureTextSize({ textContent: text, fontSize: fontSize, fontWeight: fontWeight })
    .width as number);
}

// Radiuses

export const defaultRoundedRadius = 15; // 30
export const defaultInnerRadius = 8; // 20
export const defaultItemRadius = 5;
export const defaultMenuItemRadius = deviceInfo.deviceType == deviceInfo.DeviceTypes.TYPE_2IN1 ? 5 : 18;

// Decor (Free window mode)

export const defaultWindowTopDecorHeight = 40;

/**
 * Sets the decor height to defaultDecorHeight (40).
 * @param windowObj The window.Window object.
 * */
export function setDecorHeight(windowObj: window.Window) {
  try {
    meow(`setDecorHeight: ${defaultWindowTopDecorHeight}`, 'setDecorHeight', meowLevel.INFO);
    windowObj.setWindowDecorHeight(defaultWindowTopDecorHeight);
  } catch (e) {
    meow(`windowObj.setWindowDecorHeight(defaultDecorHeight) Failed: ${e}`, 'setDecorHeight', meowLevel.ERROR);
  }
}

// Avoid

/**
 * Enables the listeners for avoid area change.
 * @param windowId The windowId.
 * */
export function listenAvoid(windowId: string) {
  try {
    const myUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${windowId}`)!;
    myUi.windowObj!.on('avoidAreaChange', (data) => {
      // meow('Changes on avoid areas!', 'avoidAreaChange', meowLevel.INFO);
      const myAvoid = AppStorageV2.connect(meowAvoid, `meowAvoid_${windowId}`)!;
      const myApp = getMyApp();

      if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
        let top = meowPx2vp(data.area.topRect.height);
        if (myApp && !myApp.freeWindow) {
          // Traditional window
          myAvoid.top = top;
        } else {
          // Free window
          myAvoid.top = Math.max(top, defaultWindowTopDecorHeight);
        }
      }
      if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        let bottom = meowPx2vp(data.area.bottomRect.height) * 0.75;
        if (myApp && !myApp.freeWindow) {
          myAvoid.bottom = Math.max(bottom, 8);
        } else {
          myAvoid.bottom = 0; // No bottom avoid for free windows.
        }
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let left = meowPx2vp(data.area.leftRect.width);
        myAvoid.left = Math.max(8, left);
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let right = meowPx2vp(data.area.rightRect.width);
        myAvoid.right = Math.max(8, right);
      }
    });
  } catch (e) {
    meow(`windowClass.on('avoidAreaChange') Failed: ${e}`, 'listenAvoid', meowLevel.ERROR);
  }
}

/**
 * Disables the listening of 'avoidAreaChange' for the windowObj.
 * @param windowObj The window.Window object.
 */
export function offAvoid(windowObj: window.Window) {
  try {
    windowObj.off('avoidAreaChange');
  } catch (e) {
    meow(`windowClass.off('avoidAreaChange') Failed: ${e}`, 'offAvoid', meowLevel.ERROR);
  }
}

/**
 * Gets the avoid information and sync to AppStorage.
 * @param windowObj The window.Window object.
 * */
export function updateAvoid(windowObj: window.Window, windowId: string) {
  try {
    let avoidArea: window.AvoidArea;
    const avoid = AppStorageV2.connect(meowAvoid, `meowAvoid_${windowId}`)!;
    const myApp = getMyApp();

    // Get
    avoidArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    let top = meowPx2vp(avoidArea.topRect.height);
    if (myApp && !myApp.freeWindow) {
      // Traditional window
      avoid.top = top;
    } else {
      // Free window
      avoid.top = Math.max(top, defaultWindowTopDecorHeight);
    }

    avoidArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    if (myApp && !myApp.freeWindow) {
      avoid.bottom = Math.max(meowPx2vp(avoidArea.bottomRect.height) * 0.75, 8);
    } else {
      avoid.bottom = 0; // No bottom avoid for free windows.
    }

    avoid.left = Math.max(meowPx2vp(avoidArea.leftRect.width), 8);
    avoid.right = Math.max(8, meowPx2vp(avoidArea.rightRect.width));

  } catch (e) {
    meow(`windowClass.getWindowAvoidArea Failed: ${e}`, 'getUpdateAvoid', meowLevel.ERROR);
  }
}

// Free window mode

/**
 * Listens to the Free-window Mode change and automatically switch modes.
 * @param context
 * @param windowId
 * */
export function listenFreeWindowMode(context: Context) {
  meow('ON!', 'listenFreeWindowMode');
  settings.registerKeyObserver(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY, () => {
    settings.getValue(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY)
      .then((val) => {
        const free = (val == 'true');
        const myApp = getMyApp();
        if (myApp.freeWindow != free) {
          myApp.freeWindow = free;
        }

        // Update for all windows.
        for (const windowId of myApp.windowIds) {
          const myUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${windowId}`)!;
          if (free) {
            setDecorHeight(myUi.windowObj!);
          }
          updateNavigationIndicator(myUi.windowObj!);
        }
        meow(`settings.getValueSync "window_pcmode_switch_status" = ${val}`, 'listenFreeWindowMode', meowLevel.INFO);
      });
  });
}

/**
 * Checks settings to figure out if currently is in free window mode.
 * @param context The UIAbility Context.
 * @param windowObj The window.Window object.
 * @returns A boolean value.
 * */
export function updateFreeWindowMode(context: Context, windowObj: window.Window) {
  const myApp = getMyApp();
  if (deviceInfo.deviceType == '2in1') {
    meow('Return true for 2in1 type!', 'getUpdateFreeWindowMode', meowLevel.INFO);
    myApp.freeWindow = true;
    setDecorHeight(windowObj);
    return true;
  }

  let val = settings.getValueSync(context, 'window_pcmode_switch_status', 'false', settings.domainName.USER_PROPERTY);
  let free = (val == 'true');

  // Update!
  if (myApp.freeWindow != free) {
    myApp.freeWindow = free;
    if (free) {
      setDecorHeight(windowObj);
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
    const myApp = getMyApp();
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
            const myApp = getMyApp();
            if (myApp.smartReachabilitySaysWeShouldPreferRightHand != useRightHand) {
              myApp.smartReachabilitySaysWeShouldPreferRightHand = useRightHand;
            }
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
 * @param windowId The windowId.
 * */
export function listenFocus(windowId: string) {
  // Focus Listener
  try {
    let myUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${windowId}`)!;
    myUi.windowObj!.on("windowEvent", (windowEvent) => {
      let on_focus = false;
      if (windowEvent == window.WindowEventType.WINDOW_ACTIVE || windowEvent == window.WindowEventType.WINDOW_SHOWN) {
        // Focused
        on_focus = true;
        getMyApp().lastFocusedWindowId = windowId;
      }
      myUi.windowFocused = on_focus;
    });
  } catch (e) {
    meow('Failed: ' + e, 'listen_focus', meowLevel.ERROR);
  }
}

/**
 * Disables the listeners for avoid area change.
 * @param windowObj The window.Window object.
 */
export function offFocus(windowObj: window.Window) {
  windowObj.off("windowEvent");
}

// FULLSCREEN


/**
 * Listen to window status changes.
 *
 * @param windowId the windowId.
 */
export function listenWindowStatusChange(windowId: string) {
  const myUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${windowId}`)!;
  if (myUi.windowObj) {
    try {
      myUi.windowObj.on('windowStatusDidChange', (status) => {
        // If a maximized window is manually recovered by the user:
        if (myUi.fullscreenStatus == meowUiFullscreenStatus.FULLSCREEN_FULL && status != window.WindowStatusType.FULL_SCREEN) {
          meow(`Window changed from FULL_SCREEN to ${status}! Go NONE!`, `windowStatusDidChange][${windowId}`);
          myUi.fullscreenStatus = meowUiFullscreenStatus.NONE;
          myUi.webFullscreenHandler?.exitFullScreen();
        }
      });
    } catch (e) {
      meow(`Failed to listen window status change: ${e.message}`, `meowUiHost][${windowId}`, meowLevel.ERROR);
    }
  }
}

/**
 * Disables the listeners for window status change.
 * @param windowId the windowId.
 */
export function offWindowStatusChange(windowId: string) {
  const myUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${windowId}`)!;
  if (myUi.windowObj) {
    try {
      myUi.windowObj.off('windowStatusDidChange');
    } catch (e) {
      meow(`Failed to off window status change: ${e.message}`, `meowUiHost][${windowId}`, meowLevel.ERROR);
    }
  }
}

// Navigation indicator

/**
 * Updates the navigation indicator status.
 * @param window The window.Window object.
 */
export function updateNavigationIndicator(window: window.Window) {
  window.setSpecificSystemBarEnabled('navigationIndicator', showNavigationIndicator()).catch((e: BusinessError) => {
    meow(`Failed: ${e}`, 'setSpecificSystemBarEnabled', meowLevel.ERROR);
  });
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
