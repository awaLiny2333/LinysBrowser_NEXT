import lazy { AppStorageV2, display, window } from '@kit.ArkUI';
import lazy { meow, meowLevel } from './catsLogger';
import { deviceInfo, settings } from '@kit.BasicServicesKit';

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
 * Converts vp to inch.
 * @param vp The true vp.
 * @returns The equivalent inch.
 * */
export function meowVp2In(vp: number) {
  try {
    let dpi = display.getDefaultDisplaySync().densityDPI;
    let px = meowVp2px(vp);
    let inch = px / dpi;
    return inch;
  } catch (e) {
    meow(`Error: ${e}, returned in vp.`, 'meowVp2In', meowLevel.ERROR);
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
    .width as number)
}

export let defaultAnima: AnimateParam = { curve: Curve.FastOutSlowIn, duration: 350 };

export const defaultRoundedRadius: number = deviceInfo.deviceType == deviceInfo.DeviceTypes.TYPE_2IN1 ? 15 : 30;

export const defaultInnerRadius: number = deviceInfo.deviceType == deviceInfo.DeviceTypes.TYPE_2IN1 ? 8 : 20;

export const defaultMenuItemRadius: number = deviceInfo.deviceType == deviceInfo.DeviceTypes.TYPE_2IN1 ? 5 : 18;

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

@ObservedV2
export class meowAvoid {
  @Trace top: number = 0;
  @Trace left: number = 0;
  @Trace right: number = 0;
  @Trace bottom: number = 0;

  constructor(t: number, b: number, l: number, r: number) {
    this.top = t;
    this.bottom = b;
    this.left = l;
    this.right = r;
  }
}

/**
 * Enables the listeners for avoid area change.
 * @param windowClass The window.Window object.
 * */
export function listenAvoid(windowClass: window.Window) {
  try {
    windowClass.on('avoidAreaChange', (data) => {
      meow('Changes on avoid areas!', 'avoidAreaChange', meowLevel.INFO);
      let free = AppStorageV2.connect(meowFreeWindowModeStatus);
      let avoid = AppStorageV2.connect<meowAvoid>(meowAvoid, 'meowAvoid', () => new meowAvoid(0, 0, 0, 0))!;

      if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
        let top = meowPx2vp(data.area.topRect.height);
        if (free && !free.on) {
          // Traditional window
          avoid.top = top;
        } else {
          // Free window
          avoid.top = Math.max(top, defaultDecorHeight);
        }
      }
      if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        let bottom = meowPx2vp(data.area.bottomRect.height);
        avoid.bottom = Math.max(bottom, 10);
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let left = meowPx2vp(data.area.leftRect.width);
        avoid.left = Math.max(10, left);
      }
      if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
        let right = meowPx2vp(data.area.rightRect.width);
        avoid.right = Math.max(10, right);
      }
    })
  } catch (e) {
    meow(`windowClass.on('avoidAreaChange') Failed: ${e}`, 'avoidAreaChange', meowLevel.ERROR);
  }
}

/**
 * Gets the avoid information and sync to AppStorage.
 * @param windowClass The window.Window object.
 * */
export function getUpdateAvoid(windowClass: window.Window) {
  try {
    let avoidArea: window.AvoidArea;
    let avoid = AppStorageV2.connect<meowAvoid>(meowAvoid, 'meowAvoid', () => new meowAvoid(0, 0, 0, 0))!;
    let free = AppStorageV2.connect(meowFreeWindowModeStatus);

    // Get
    avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    let top = meowPx2vp(avoidArea.topRect.height);
    if (free && !free.on) {
      // Traditional window
      avoid.top = top;
    } else {
      // Free window
      avoid.top = Math.max(top, defaultDecorHeight);
    }

    avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    avoid.bottom = Math.max(meowPx2vp(avoidArea.bottomRect.height), 10);

    avoid.left = Math.max(meowPx2vp(avoidArea.leftRect.width), 10);
    avoid.right = Math.max(10, meowPx2vp(avoidArea.rightRect.width));

  } catch (e) {
    // TODO: Implement error handling.
  }
}

// Free window mode

@ObservedV2
export class meowFreeWindowModeStatus {
  @Trace on: boolean;
  @Trace onFocus: boolean = true;

  constructor(on: boolean) {
    this.on = on;
  }
}

/**
 * Listens to the Free-window Mode change and automatically switch modes.
 * @param context
 * @param windowClass
 * @param storage
 * @param id
 * */
export function listenFreeWindowMode(context: Context, windowClass: window.Window) {
  meow('ON!', 'listenFreeWindowMode');
  settings.registerKeyObserver(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY,
    () => {
      settings.getValue(context, 'window_pcmode_switch_status', settings.domainName.USER_PROPERTY)
        .then((val) => {
          let free = (val == 'true');
          if (free) {
            setDecorHeight(windowClass);
          }
          AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus, 'meowFreeWindowModeStatus', () => new meowFreeWindowModeStatus(free))!.on = free;
          meow(`${free}`, 'listenFreeWindowMode', meowLevel.INFO);
        });
    })
}

/**
 * Checks settings to figure out if currently is in free window mode.
 * @param context The UIAbility Context.
 * @returns A boolean value.
 * */
export function getUpdateFreeWindowMode(context: Context, windowClass: window.Window) {
  if (deviceInfo.deviceType == '2in1') {
    meow('Return true for 2in1 type!', 'getUpdateFreeWindowMode', meowLevel.INFO);
    AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus, 'meowFreeWindowModeStatus', () => new meowFreeWindowModeStatus(true));
    setDecorHeight(windowClass);
    return true;
  }
  let val = settings.getValueSync(context, 'window_pcmode_switch_status', 'false', settings.domainName.USER_PROPERTY);
  let free = (val == 'true');
  AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus, 'meowFreeWindowModeStatus', () => new meowFreeWindowModeStatus(free));
  if (free) {
    setDecorHeight(windowClass);
  }
  meow(`settings.getValueSync "window_pcmode_switch_status" = ${val}`, 'getUpdateFreeWindowMode', meowLevel.INFO);
  return free;
}

// Layout mode

@ObservedV2
export class meowLayoutModeStatus {
  @Trace wideMode: boolean;
  @Trace width: number;
  @Trace height: number;

  constructor(wideMode: boolean, width: number, height: number) {
    this.wideMode = wideMode;
    this.width = width;
    this.height = height;
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
export function listenFocus(windowClass: window.Window) {
  // Focus Listener
  try {
    windowClass.on("windowEvent", (windowEvent) => {
      let on_focus = false;
      if (windowEvent == window.WindowEventType.WINDOW_ACTIVE || windowEvent == window.WindowEventType.WINDOW_SHOWN) {
        // Focused
        on_focus = true;
      }
      let stat = AppStorageV2.connect<meowFreeWindowModeStatus>(meowFreeWindowModeStatus);
      if (stat) {
        stat.onFocus = on_focus;
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
