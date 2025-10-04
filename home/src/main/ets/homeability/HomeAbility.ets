import { AbilityConstant, Configuration, UIAbility, Want, wantConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { meow_init } from '../processes/init';
import { meowPx2vp } from '../utils/environment_tools';
import lazy { bunch_of_tabs } from '../hosts/bunch_of_tabs';

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
      try {
        this.context.restoreWindowStage(this.storage);
      } catch (e) {
        console.error('[onCreate] restoreWindowStage Failed: ' + e);
      }
    } else {
      // Normal wants
      this.process_want(want);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.process_continue(want);
    } else {
      this.process_want(want);
    }
  }

  onContinue(wantParam: Record<string, Object>) {
    console.info(`onContinue version = ${wantParam.version}, targetDevice: ${wantParam.targetDevice}`);

    // Check if continuation_auto_exit
    let auto_exit = AppStorage.get('continuation_auto_exit') as boolean;
    let close_tab = AppStorage.get('continuation_auto_close_tab') as boolean;

    // Pack continue data
    wantParam['data'] = AppStorage.get('current_url') as string;
    if (!auto_exit) {
      wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = false;
      // Close tab
      if (close_tab) {
        let tabs = AppStorage.get('bunch_of_tabs') as bunch_of_tabs;
        AppStorage.set('universal_close_tab_gateway', tabs.main_tab_idx);
      }
    }

    // No auto recovery
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = false;
    return AbilityConstant.OnContinueResult.AGREE;
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // Set window rect auto save
    try {
      windowStage.setWindowRectAutoSave(true).then(() => {
        console.info('[HomeAbility] Succeeded in setting window rect auto-save');
      }).catch((err: BusinessError) => {
        console.error(`[HomeAbility] Failed to set window rect auto-save. Cause code: ${err.code}, message: ${err.message}`);
      });
    } catch (exception) {
      console.error(`[HomeAbility] Failed to set window rect auto-save. Cause code: ${exception.code}, message: ${exception.message}`);
    }

    windowStage.getMainWindow((err: BusinessError, win) => {
      const errCode: number = err.code;
      if (errCode) {
        console.error(`[HomeAbility] Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }

      // This does nothing at all. Just to get rid of the warning on ['win' is declared but its value is never read].
      console.log('[getMainWindow] ' + (win ? 'Window Got' : 'No Window???'))
    })

    // Init & Load window content
    await meow_init(this.context);
    this.window_load_content(windowStage);
  }

  async onWindowStageRestore(windowStage: window.WindowStage) {
    let is_new_launch = !(AppStorage.get('settings_init_retrieved') as boolean);
    console.log('[HomeAbility][onWindowStageRestore] is_new_launch? - ' + (is_new_launch ? 'yes!' : 'no...'))

    // Only loads if is new launch
    // Init & Load window content
    if (is_new_launch) {
      await meow_init(this.context);
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

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  /**
   * Fills the want into AppStorage.
   * @param want the want
   * */
  process_want(want: Want) {
    AppStorage.setOrCreate('want_uri', '');
    // want
    let want_uri = want.uri;
    let want_type = want.type;
    let want_action = want.action;
    let want_flags = want.flags;
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
      if (want_flags) {
        AppStorage.setOrCreate('want_flags', want_flags);
        console.log('[Meow][HomeAbility] Want flags: ' + want_flags);
      } else {
        AppStorage.setOrCreate('want_flags', '');
        console.log('[Meow][HomeAbility] Want flags are empty?');
      }

      // refresh want_uri in the last place
      AppStorage.setOrCreate('want_uri', want_uri);
    }
  }

  /**
   * Cross device continuation.
   * Fills the want into AppStorage.
   * @param want the want
   * */
  process_continue(want: Want) {
    AppStorage.setOrCreate('want_uri', '');
    if (want.parameters !== undefined) {
      // Get the data
      let continue_params_data = want.parameters.data.toString();
      console.info('[Meow][HomeAbility][onNewWant] continue input: ' + continue_params_data);
      AppStorage.setOrCreate('want_action', 'ohos.want.action.viewData');
      AppStorage.setOrCreate('want_type', want.type);
      AppStorage.setOrCreate('want_flags', want.flags);
      AppStorage.setOrCreate('want_uri', continue_params_data);
    }
  }

  /**
   * A general load content function.
   * @param windowStage The windowStage.
   * */
  window_load_content(windowStage: window.WindowStage) {
    this.storage.setOrCreate('windowClass', windowStage); // Save windowClass
    this.storage.setOrCreate('window_id', Date.now().toString()); // Save my window ID

    let windowClass = windowStage.getMainWindowSync(); // Get app main window

    // Load content
    windowStage.loadContent('pages/Index', this.storage, (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');


      console.log('Succeeded in obtaining the main window. Data: ' + JSON.stringify(windowClass));
      console.log('[HomeAbility] deviceType: ' + deviceInfo.deviceType);

      if (deviceInfo.deviceType == '2in1') {
        windowClass.setWindowDecorVisible(false);
        let windowDecorHeight = windowClass.getWindowDecorHeight();

        windowClass.on('windowTitleButtonRectChange', (titleButtonRect) => {
          AppStorage.setOrCreate('windowDecorHeight', titleButtonRect.height);
          AppStorage.setOrCreate('windowDecorWidth', titleButtonRect.width);
        })

        AppStorage.setOrCreate('topAvoidHeight', windowDecorHeight);
        console.log('[HomeAbility] topAvoidHeight: ' + windowDecorHeight);

      } else {
        // 1. Set fullscreen window
        windowClass.setImmersiveModeEnabledState(true);

        console.log('[HomeAbility] Get avoid areas:')
        // 2. Get avoid area
        let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
        let avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidBottom = meowPx2vp(avoidArea.bottomRect.height); // 获取到导航条区域的高度
        AppStorage.setOrCreate('bottomAvoidHeight', avoidBottom);
        console.log('\tNew avoidBottomHeight: ' + avoidBottom);

        type = window.AvoidAreaType.TYPE_SYSTEM;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidTop = meowPx2vp(avoidArea.topRect.height);
        AppStorage.setOrCreate('topAvoidHeight', avoidTop + (avoidTop == 0 ? 0 : 2));
        console.log('\ttopAvoidHeight: ' + avoidTop + (avoidTop == 0 ? 0 : 2));

        type = window.AvoidAreaType.TYPE_CUTOUT;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidLeft = meowPx2vp(avoidArea.leftRect.width);
        AppStorage.setOrCreate('leftAvoidWidth', avoidLeft + (avoidLeft == 0 ? 0 : 2));
        console.log('\tNew leftAvoidWidth: ' + avoidLeft + (avoidLeft == 0 ? 0 : 2));

        type = window.AvoidAreaType.TYPE_CUTOUT;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let avoidRight = meowPx2vp(avoidArea.rightRect.width);
        AppStorage.setOrCreate('rightAvoidWidth', avoidRight + (avoidRight == 0 ? 0 : 2));
        console.log('\tNew avoidRightWidth: ' + avoidRight + (avoidRight == 0 ? 0 : 2));

        // Avoid change listener
        windowClass.on('avoidAreaChange', (data) => {
          console.log('[HomeAbility] Changes on avoid areas:')

          if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
            avoidTop = meowPx2vp(data.area.topRect.height);
            AppStorage.setOrCreate('topAvoidHeight', avoidTop + (avoidTop == 0 ? 0 : 2));
            console.log('\tNew topAvoidHeight: ' + avoidTop + (avoidTop == 0 ? 0 : 2));
          }
          if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
            avoidBottom = meowPx2vp(data.area.bottomRect.height);
            AppStorage.setOrCreate('bottomAvoidHeight', avoidBottom);
            console.log('\tNew avoidBottomHeight: ' + avoidBottom);
          }
          if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
            avoidLeft = meowPx2vp(data.area.leftRect.width);
            AppStorage.setOrCreate('leftAvoidWidth', avoidLeft + (avoidLeft == 0 ? 0 : 2));
            console.log('\tNew leftAvoidWidth: ' + avoidLeft + (avoidLeft == 0 ? 0 : 2));
          }
          if (data.type == window.AvoidAreaType.TYPE_CUTOUT) {
            avoidRight = meowPx2vp(data.area.rightRect.width);
            AppStorage.setOrCreate('rightAvoidWidth', avoidRight + (avoidRight == 0 ? 0 : 2));
            console.log('\tNew avoidRightWidth: ' + avoidRight + (avoidRight == 0 ? 0 : 2));
          }
        })
      } // Avoid areas

    });
  }
}