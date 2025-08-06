import { AbilityConstant, Configuration, UIAbility, Want, wantConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { kv_store_get } from '../utils/kv_store_tools';

export default class HomeAbility extends UIAbility {
  storage: LocalStorage = new LocalStorage();

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    console.log('want bundle name: ' + want.bundleName);
    console.log('launchParam launchReason: ' + launchParam.launchReason);

    // save environment
    AppStorage.setOrCreate('context', this.context);
    AppStorage.setOrCreate('pathDir', this.context.filesDir);
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);

    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.process_continue(want);
      this.context.restoreWindowStage(this.storage);
    } else {
      // Process want
      this.process_want(want);
    }

    // Perhaps this could get the KVStore manager?
    await kv_store_get('meow');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.process_continue(want);
    } else {
      // Process want
      this.process_want(want);
    }
  }

  onContinue(wantParam: Record<string, Object>) {
    // Check if continuation_auto_exit
    let auto_exit = AppStorage.get('continuation_auto_exit') as boolean;
    let close_tab = AppStorage.get('continuation_auto_close_tab') as boolean;
    // Set continue information
    console.info(`onContinue version = ${wantParam.version}, targetDevice: ${wantParam.targetDevice}`);
    let current_url = AppStorage.get('current_url') as string;
    wantParam['data'] = current_url;
    if (!auto_exit) {
      wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = false;
      if (close_tab) {
        let current_main_tab_index = AppStorage.get('current_main_tab_index') as number;
        AppStorage.set('universal_close_tab_gateway', current_main_tab_index);
      }
    }
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = false;
    return AbilityConstant.OnContinueResult.AGREE;
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.getMainWindow((err: BusinessError, win) => {
      const errCode: number = err.code;
      if (errCode) {
        console.error(`Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }
    })

    // Load window content
    this.window_load_content(windowStage);
  }

  onWindowStageRestore(windowStage: window.WindowStage) {
    let is_new_launch = !(AppStorage.get('settings_init_retrieved') as boolean);
    console.log('[HomeAbility][onWindowStageRestore] is_new_launch? - ' + (is_new_launch ? 'yes!' : 'no...'))
    // Only loads if is new launch
    if (is_new_launch) {
      this.window_load_content(windowStage);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  process_want(want: Want) {
    AppStorage.setOrCreate('want_uri', '');
    // want
    let want_uri = want.uri;
    let want_type = want.type;
    let want_action = want.action;
    if (want_uri == null || want_uri == undefined || want_uri.length < 1) {
      // Invalid want
      console.info('[Meow][HomeAbility] No or empty Want uri accepted.');
      AppStorage.setOrCreate('want_uri', '');
      AppStorage.setOrCreate('want_type', '');
      AppStorage.setOrCreate('want_action', '');
    } else {
      // Good want
      console.log('[Meow][HomeAbility] Want accepted!');
      console.log('[Meow][HomeAbility] Want uri: ' + want_uri);

      // Process the rest params
      if (want_type) {
        AppStorage.setOrCreate('want_type', want_type);
        console.log('[Meow][HomeAbility] Want type: ' + want_type);
      } else {
        AppStorage.setOrCreate('want_type', '');
        console.log('[Meow][HomeAbility] Want type is empty?');
      }
      if (want_action) {
        AppStorage.setOrCreate('want_action', want_action);
        console.log('[Meow][HomeAbility] Want action: ' + want_action);
      } else {
        AppStorage.setOrCreate('want_action', '');
        console.log('[Meow][HomeAbility] Want action is empty?');
      }

      // refresh want_uri in the last place
      AppStorage.setOrCreate('want_uri', want_uri);
    }
  }

  process_continue(want: Want) {
    let is_new_launch = !(AppStorage.get('settings_init_retrieved') as boolean);
    console.log('[HomeAbility][onWindowStageRestore] is_new_launch? - ' + (is_new_launch ? 'yes' : 'no'))
    // Get the data
    let continueInput = '';
    if (want.parameters !== undefined) {
      try {
        continueInput = want.parameters.data.toString();
        console.info('[Meow][HomeAbility][onNewWant] continue input: ' + continueInput);
        // Recovery of window
        setTimeout(() => {
          AppStorage.set('universal_new_tab_gateway', continueInput);
        }, is_new_launch ? 1000 : 100)
      } catch (e) {
        console.error(e);
      }
    }
  }

  /**
   * Implements a same px2vp as this.getUIContext().px2vp in UI interfaces
   * @param px the real pixel
   * @returns the vp equivalent
   * */
  px2vp(px: number) {
    return px / display.getDefaultDisplaySync().densityPixels;
  }

  window_load_content(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      let windowClass = windowStage.getMainWindowSync(); // Get app main window

      console.log('Succeeded in obtaining the main window. Data: ' + JSON.stringify(windowClass));
      console.log('[HomeAbility] deviceType: ' + deviceInfo.deviceType);

      if (deviceInfo.deviceType == '2in1') {
        console.log('[HomeAbility] Treated as a 2in1.');
        // windowClass.setWindowCornerRadius(26);
        // windowClass.setWindowTitleButtonVisible(true, true, true);
        windowClass.setWindowDecorVisible(false);
        let windowDecorHeight = windowClass.getWindowDecorHeight();

        windowClass.on('windowTitleButtonRectChange', (titleButtonRect) => {
          console.info('[HomeAbility] Succeeded in enabling the listener for window title buttons area changes. Data: ' + JSON.stringify(titleButtonRect));

          AppStorage.setOrCreate('windowDecorHeight', titleButtonRect.height);
          console.log('[HomeAbility] windowDecorHeight: ' + titleButtonRect.height);

          AppStorage.setOrCreate('windowDecorWidth', titleButtonRect.width);
          console.log('[HomeAbility] windowDecorWidth: ' + titleButtonRect.width);
        })

        AppStorage.setOrCreate('topAvoidHeight', windowDecorHeight);
        console.log('[HomeAbility] topAvoidHeight: ' + windowDecorHeight);
        // windowClass.setResizeByDragEnabled(true);
        // windowClass.setWindowTitle('qwq');
      } else {
        console.log('[HomeAbility] Treated as else.');

        // 1. Set fullscreen window
        windowClass.setImmersiveModeEnabledState(true);

        // 2. Get avoid area
        let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
        let avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidBottom = this.px2vp(avoidArea.bottomRect.height); // 获取到导航条区域的高度
        AppStorage.setOrCreate('bottomAvoidHeight', avoidBottom);
        console.log('[HomeAbility] New avoidBottomHeight: ' + avoidBottom);

        type = window.AvoidAreaType.TYPE_SYSTEM;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidTop = this.px2vp(avoidArea.topRect.height);
        AppStorage.setOrCreate('topAvoidHeight', avoidTop + (avoidTop == 0 ? 0 : 2));
        console.log('[HomeAbility] topAvoidHeight: ' + avoidTop + (avoidTop == 0 ? 0 : 2));

        type = window.AvoidAreaType.TYPE_CUTOUT;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidLeft = this.px2vp(avoidArea.leftRect.width);
        AppStorage.setOrCreate('leftAvoidWidth', avoidLeft + (avoidLeft == 0 ? 0 : 2));
        console.log('[HomeAbility] New leftAvoidWidth: ' + avoidLeft + (avoidLeft == 0 ? 0 : 2));

        type = window.AvoidAreaType.TYPE_CUTOUT;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidRight = this.px2vp(avoidArea.rightRect.width);
        AppStorage.setOrCreate('rightAvoidWidth', avoidRight + (avoidRight == 0 ? 0 : 2));
        console.log('[HomeAbility] New avoidRightWidth: ' + avoidRight + (avoidRight == 0 ? 0 : 2));

        // Change listener
        windowClass.on('avoidAreaChange', (data) => {
          if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
            avoidTop = this.px2vp(data.area.topRect.height);
            AppStorage.setOrCreate('topAvoidHeight', avoidTop + (avoidTop == 0 ? 0 : 2));
            console.log('[HomeAbility] New topAvoidHeight: ' + avoidTop + (avoidTop == 0 ? 0 : 2));
          }
          if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
            avoidBottom = this.px2vp(data.area.bottomRect.height);
            AppStorage.setOrCreate('bottomAvoidHeight', avoidBottom);
            console.log('[HomeAbility] New avoidBottomHeight: ' + avoidBottom);
          }
          if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
            avoidLeft = this.px2vp(data.area.leftRect.width);
            AppStorage.setOrCreate('leftAvoidWidth', avoidLeft + (avoidLeft == 0 ? 0 : 2));
            console.log('[HomeAbility] New leftAvoidWidth: ' + avoidLeft + (avoidLeft == 0 ? 0 : 2));
          }
          if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
            avoidRight = this.px2vp(data.area.rightRect.width);
            AppStorage.setOrCreate('rightAvoidWidth', avoidRight + (avoidRight == 0 ? 0 : 2));
            console.log('[HomeAbility] New avoidRightWidth: ' + avoidRight + (avoidRight == 0 ? 0 : 2));
          }
        })
      }
      AppStorage.set('isAppRunning', true);
    });
  }
}
