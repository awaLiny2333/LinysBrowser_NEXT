import { AbilityConstant, Configuration, UIAbility, Want, wantConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { meow_init_main, meow_init_sub } from '../processes/init';
import { meowPx2vp } from '../utils/environment_tools';
import lazy { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { storage_of_window, window_id_at_index, window_index_of_windowStage } from '../utils/ui_tools';

export default class HomeAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    console.log('want bundle name: ' + want.bundleName);
    console.log('launchParam launchReason: ' + launchParam.launchReason);

    // save environment
    AppStorage.setOrCreate('context', this.context);
    AppStorage.setOrCreate('pathDir', this.context.filesDir);
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);

    let storage: LocalStorage = new LocalStorage();

    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.process_continue(want, 'onCreate');
      try {
        this.context.restoreWindowStage(storage);
      } catch (e) {
        console.error('[onCreate] restoreWindowStage Failed: ' + e);
      }
    } else {
      // Normal wants
      this.process_want(want, 'onCreate');
    }
  }

  // /**
  //  * Receives a want.
  //  * @param want The want.
  //  * @param launchParam The launchParam to determine if this is a continuation or something else.
  //  * */
  // onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  //   if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
  //     this.process_continue(want, 'onNewWant');
  //   } else {
  //     this.process_want(want, 'onNewWant');
  //   }
  // }

  /**
   * Sends a page to another device.
   * @param wantParam The wantParam.
   * @returns AbilityConstant.OnContinueResult.
   * */
  async onContinue(wantParam: Record<string, Object>) {
    console.info(`onContinue version = ${wantParam.version}, targetDevice: ${wantParam.targetDevice}`);

    // Check if continuation_auto_exit
    let auto_exit = AppStorage.get('continuation_auto_exit') as boolean;
    let close_tab = AppStorage.get('continuation_auto_close_tab') as boolean;

    // try {
    let storage = storage_of_window(await window.getLastWindow(this.context));
    let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
    let url_to_be_sent = tabs.get_current_main_url();
    console.log('[onContinue] url_to_be_sent: ' + url_to_be_sent);

    // Pack continue data
    // wantParam['data'] = 'baidu.com';
    wantParam['data'] = url_to_be_sent;
    if (auto_exit) {
      // Close app
      wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = true;
      console.log('[onContinue] CLOSE APP');
    } else {
      // Doesn't close app
      wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = false;
      console.log('[onContinue] WON\'T CLOSE APP');
      if (close_tab) {
        // Close tab
        storage.set('universal_close_tab_gateway', tabs.main_tab_idx);
      }
    }

    // No auto recovery
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = false;
    return AbilityConstant.OnContinueResult.AGREE;
    // } catch (e) {
    //   console.error('[onContinue] Failure: ' + e);
    //   return AbilityConstant.OnContinueResult.REJECT;
    // }
  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let is_new_launch = !(AppStorage.get('settings_init_retrieved') as boolean);

    // Set window rect auto save
    windowStage.setWindowRectAutoSave(true).then(() => {
      console.info('[HomeAbility] Succeeded in setting window rect auto-save');
    }).catch((err: BusinessError) => {
      console.error(`[HomeAbility] Failed to set window rect auto-save. Cause code: ${err.code}, message: ${err.message}`);
    });

    let windowClass = windowStage.getMainWindowSync(); // Get app main window
    let storage = new LocalStorage();
    let my_window_id = Date.now().toString();
    storage.setOrCreate('my_window_id', my_window_id);

    // Init & Load window content
    if (is_new_launch) {
      AppStorage.set('THE_LORD_OF_THE_WINDOWS', my_window_id);
      await meow_init_main(this.context, storage);
    } else {
      meow_init_sub(this.context, storage);
    }
    this.window_load_content(windowStage, windowClass, my_window_id, storage);
  }

  async onWindowStageRestore(windowStage: window.WindowStage) {
    let is_new_launch = !(AppStorage.get('settings_init_retrieved') as boolean);
    console.log('[HomeAbility][onWindowStageRestore] is_new_launch? - ' + (is_new_launch ? 'yes!' : 'no...'))

    // Set window rect auto save
    windowStage.setWindowRectAutoSave(true).then(() => {
      console.info('[HomeAbility] Succeeded in setting window rect auto-save');
    }).catch((err: BusinessError) => {
      console.error(`[HomeAbility] Failed to set window rect auto-save. Cause code: ${err.code}, message: ${err.message}`);
    });

    let windowClass = windowStage.getMainWindowSync(); // Get app main window
    let storage = new LocalStorage();
    let my_window_id = Date.now().toString();
    storage.setOrCreate('my_window_id', my_window_id);

    // Init & Load window content
    if (is_new_launch) {
      AppStorage.set('THE_LORD_OF_THE_WINDOWS', my_window_id);
      await meow_init_main(this.context, storage);
    } else {
      meow_init_sub(this.context, storage);
    }
    this.window_load_content(windowStage, windowClass, my_window_id, storage);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
  }

  onWindowStageWillDestroy(windowStage: window.WindowStage) {
    let window_index = window_index_of_windowStage(windowStage);
    let window_id = window_id_at_index(window_index);
    console.log(' \n[HomeAbility][onWindowStageWillDestroy] Will destroy window #' + window_index + ' (' + window_id + ')!\n ');

    // Delete myself from the lists
    let windowIds = AppStorage.get('windowIds') as string[];
    windowIds.splice(window_index, 1);
    let windowStages = AppStorage.get('windowStages') as window.WindowStage[];
    windowStages.splice(window_index, 1);
    let windowClasses = AppStorage.get('windows') as window.Window[];
    windowClasses.splice(window_index, 1);
    let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
    windowStorages.splice(window_index, 1);
    let all_bunch_of_tabs = AppStorage.get('all_bunch_of_tabs') as bunch_of_tabs[];
    all_bunch_of_tabs.splice(window_index, 1);

    AppStorage.set('THE_LORD_OF_THE_WINDOWS', windowIds[0]);

    hilog.info(0x0000, 'testTag', `onWindowStageWillDestroy`);
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
  process_want(want: Want, source: string) {
    console.log('[HomeAbility][process_want] Source: ' + source + '!');
    AppStorage.setOrCreate('want_source', source);
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
      AppStorage.setOrCreate('want_timestamp', Date.now().toString());
    }
  }

  /**
   * Cross device continuation.
   * Fills the want into AppStorage.
   * @param want the want
   * */
  process_continue(want: Want, source: string) {
    AppStorage.setOrCreate('want_source', source);
    AppStorage.setOrCreate('want_action', 'ohos.want.action.viewData');
    AppStorage.setOrCreate('want_type', want.type);
    AppStorage.setOrCreate('want_flags', want.flags);
    if (want.parameters && want.parameters.data) {
      // Get the data
      let continue_params_data = want.parameters.data.toString();
      console.info('[Meow][HomeAbility] process_continue url: ' + continue_params_data);
      AppStorage.setOrCreate('want_uri', continue_params_data);
    } else {
      // Get failed?
      console.error('[Meow][HomeAbility] process_continue url get failed? IDK why but I\'ll show you a blank page');
      AppStorage.setOrCreate('want_uri', '');
    }
  }

  /**
   * A general load content function.
   *
   * EXECUTED ONLY ONCE FOR EACH WINDOW INSTANCE.
   * @param windowStage The windowStage.
   * */
  window_load_content(windowStage: window.WindowStage, windowClass: window.Window, my_window_id: string, storage: LocalStorage) {

    // Save my window to AppStorage
    let windowClasses: window.Window[] | undefined = AppStorage.get('windows');
    if (windowClasses == undefined) {
      // IS THE FIRST WINDOW OF APP
      AppStorage.setOrCreate('windows', [windowClass]);
      AppStorage.setOrCreate('windowIds', []);
      AppStorage.setOrCreate('windowStages', []);
      AppStorage.setOrCreate('windowStorages', []);
    } else {
      // one of the multi-windows
      windowClasses.push(windowClass);
      AppStorage.setOrCreate('windows', windowClasses); // Is this needed?
    }

    // Parallel array of ids
    let windowIds = AppStorage.get('windowIds') as string[];
    windowIds.push(my_window_id);
    let windowStages = AppStorage.get('windowStages') as window.WindowStage[];
    windowStages.push(windowStage);
    let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
    windowStorages.push(storage);

    // Load content
    windowStage.loadContent('pages/Index', storage, (err) => {
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