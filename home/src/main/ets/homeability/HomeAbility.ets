import lazy { AbilityConstant, Configuration, UIAbility, Want, wantConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import {
  enter_free_window_mode,
  enter_traditional_window_mode,
  get_avoid,
  get_free_window_mode,
  listen_avoid,
  listen_focus,
  listen_free_window_mode,
  run_time,
  window_index_of_id
} from '../utils/ui_tools';
import lazy { meow_init_main, meow_init_sub } from '../processes/init_process';
import lazy { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import lazy { bunch_of_settings } from '../hosts/bunch_of_settings';
import lazy { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import { meowPx2vp } from '../utils/environment_tools';

export default class HomeAbility extends UIAbility {
  my_window_id = '';
  my_window_alias = '';
  storage: LocalStorage = new LocalStorage();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    console.log('want bundle name: ' + want.bundleName);
    console.log('launchParam launchReason: ' + launchParam.launchReason);

    // save environment
    this.storage.setOrCreate('context', this.context);
    AppStorage.setOrCreate('pathDir', this.context.filesDir);
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);

    // LAST_WINDOW_INSTANCE_KEY is set by HomeAbilityStage.
    this.my_window_id = AppStorage.get('LAST_WINDOW_INSTANCE_KEY') as string;
    this.storage.setOrCreate('my_window_id', this.my_window_id); // Use it as a UNIQUE window id.

    this.process_want(want, 'onCreate');

    // Restore if is continuation
    if (launchParam.launchReason == AbilityConstant.LaunchReason.CONTINUATION) {
      try {
        this.context.restoreWindowStage(this.storage);
      } catch (e) {
        console.error('[HomeAbility] onCreate restoreWindowStage Error: ' + e);
      }
    }
  }

  // Life Cycles

  /**
   * Receives a want.
   * @param want The want.
   * @param launchParam The launchParam to determine if this is a continuation or something else.
   * */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log('launchParam launchReason: ' + launchParam.launchReason);
    this.process_want(want, 'onNewWant');
  }

  /**
   * Send a page to else where.
   * @param wantParam The wantParam.
   * @returns If agree.
   * */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    // Settings
    let continuation_auto_exit = bunch_of_settings.get('continuation_auto_exit') as boolean;
    let continuation_auto_close_tab = bunch_of_settings.get('continuation_auto_close_tab') as boolean;

    // Process
    console.info(`[onContinue] my version = ${wantParam.version}, targetDevice: ${wantParam.targetDevice}`);
    const continue_url = this.storage.get('current_url') as string;
    wantParam['data'] = continue_url;
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = false;
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = continuation_auto_exit;

    // Close app or tab
    if (!continuation_auto_exit && continuation_auto_close_tab) {
      this.storage.set('universal_close_tab_gateway', (this.storage.get('bunch_of_tabs') as bunch_of_tabs).main_tab_idx);
    }

    console.log('[onContinue] Sending url: ' + continue_url + '.');
    return AbilityConstant.OnContinueResult.AGREE;
  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // Init & Load window content
    if (this.is_new_window()) {
      this.storage.setOrCreate('START_TIME', Date.now());
      let is_app_start = this.is_new_launch();
      if (is_app_start) {
        windowStage.setWindowRectAutoSave(true).then(() => {
          console.info('[HomeAbility] Succeeded in setting window rect auto-save');
        }).catch((err: BusinessError) => {
          console.error(`[HomeAbility] Failed to set window rect auto-save. Cause code: ${err.code}, message: ${err.message}`);
        });
        console.log(`[HomeAbility][onWindowStageCreate] Is new launch! this.my_window_id=${this.my_window_id}`);
        AppStorage.setOrCreate('THE_LORD_OF_THE_WINDOWS', this.my_window_id);
        await meow_init_main(this.context, this.storage);
      } else {
        console.log(`[HomeAbility][onWindowStageCreate] Is sub window! this.my_window_id=${this.my_window_id}`);
        meow_init_sub(this.context, this.storage);
      }

      let windowClass = windowStage.getMainWindowSync(); // Get app main window
      this.window_load_content(windowStage, windowClass, this.my_window_id, this.storage, is_app_start);
    }
  }

  async onWindowStageRestore(windowStage: window.WindowStage) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageRestore');

    // Init & Load window content
    if (this.is_new_window()) {
      this.storage.setOrCreate('START_TIME', Date.now());
      let is_app_start = this.is_new_launch();
      if (is_app_start) {
        windowStage.setWindowRectAutoSave(true).then(() => {
          console.info('[HomeAbility] Succeeded in setting window rect auto-save');
        }).catch((err: BusinessError) => {
          console.error(`[HomeAbility] Failed to set window rect auto-save. Cause code: ${err.code}, message: ${err.message}`);
        });
        console.log(`[HomeAbility][onWindowStageRestore] Is new launch! this.my_window_id=${this.my_window_id}`);
        AppStorage.setOrCreate('THE_LORD_OF_THE_WINDOWS', this.my_window_id);
        await meow_init_main(this.context, this.storage);
      } else {
        console.log(`[HomeAbility][onWindowStageRestore] Is sub window! this.my_window_id=${this.my_window_id}`);
        meow_init_sub(this.context, this.storage);
      }

      let windowClass = windowStage.getMainWindowSync(); // Get app main window
      this.window_load_content(windowStage, windowClass, this.my_window_id, this.storage, is_app_start);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
  }

  onWindowStageWillDestroy(windowStage: window.WindowStage) {
    let window_id = this.my_window_id;
    let window_index = window_index_of_id(window_id);
    console.log(' \n[HomeAbility][onWindowStageWillDestroy] Will destroy window #' + window_index + ' (' + window_id + ')!\n ');

    // Dispose web nodes.
    let tabs = this.storage.get('bunch_of_tabs') as bunch_of_tabs;
    tabs.DISPOSE();

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

    // Set window notes
    AppStorage.set('THE_LORD_OF_THE_WINDOWS', windowIds[0]);
    if (window_id == AppStorage.get('THE_FOCUS_OF_THE_WINDOWS') as string) {
      // Reset focus
      // TODO: Should set this to the second top window! Lazzzy cat!
      AppStorage.setOrCreate('THE_FOCUS_OF_THE_WINDOWS', '');
    }

    // Mark zone closed
    if (this.storage.get('is_zone') as boolean) {
      let zones = AppStorage.get('zones') as string[];
      let idx = zones.indexOf(this.storage.get('my_window_alias') as string);
      let zones_opened = AppStorage.get('zones_opened') as boolean[];
      console.log(`[onWindowStageWillDestroy] Mark zones_opened of #${idx} to false!`);
      zones_opened[idx] = false;
    }

    hilog.info(0x0000, 'testTag', `onWindowStageWillDestroy`);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability (' + this.my_window_id + ') onForeground');
    // Update downloads to refresh downloads UI.
    try {
      let downloads = AppStorage.get('bunch_of_downloads') as bunch_of_downloads;
      downloads.update_timestamp();
      console.log('[onForeground][bunch_of_downloads][update_timestamp]');
    } catch (e) {
      console.error('[onForeground][bunch_of_downloads][update_timestamp] Failed: ' + e);
    }
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability (' + this.my_window_id + ') onBackground');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // Window Actions

  /**
   * A general load content function.
   *
   * EXECUTED ONLY ONCE FOR EACH WINDOW INSTANCE.
   * @param windowStage The windowStage.
   * */
  window_load_content(windowStage: window.WindowStage, windowClass: window.Window, my_window_id: string, storage: LocalStorage, is_app_start: boolean) {
    // Save my window to AppStorage
    let windowClasses: window.Window[] | undefined = AppStorage.get('windows');
    let my_index: number;
    if (windowClasses == undefined) {
      // IS THE FIRST WINDOW OF APP
      my_index = 0;
      AppStorage.setOrCreate('windows', [windowClass]);
      AppStorage.setOrCreate('windowIds', []);
      AppStorage.setOrCreate('windowStages', []);
      AppStorage.setOrCreate('windowStorages', []);
    } else {
      // one of the multi-windows
      my_index = windowClasses.length;
      windowClasses.push(windowClass);
      AppStorage.setOrCreate('windows', windowClasses); // Is this needed?
    }

    storage.setOrCreate('my_windowClass', windowClass);

    // windowClass operations
    let log = [
      ' ',
      '[Meow][HomeAbility][window_load_content]',
      '    window.Window #' + my_index,
      '    my_window_id: ' + this.my_window_id,
      '    alias: ' + this.my_window_alias,
      ' '
    ].join('\n');
    console.log(log);
    let tablet_mode: boolean;
    let compact_mode: boolean;
    try {
      const rect: window.Rect = windowClass.getWindowProperties().windowRect;
      tablet_mode = meowPx2vp(rect.width) > 600;
      compact_mode = meowPx2vp(rect.height) < 400;
    } catch (error) {
      // Leave tablet_mode there to be negative
      tablet_mode = false;
      compact_mode = false;
    }
    this.storage.setOrCreate('tablet_mode', tablet_mode);
    this.storage.setOrCreate('compact_mode', compact_mode);

    // Save is_zone mark
    let is_zone = AppStorage.get('LAST_WINDOW_WINDOW_IS_ZONE') as boolean;
    this.storage.setOrCreate('is_zone', is_zone);
    // if (is_zone) {
    //   let zones = AppStorage.get('zones') as string[];
    //   let idx = zones.indexOf(this.storage.get('my_window_alias') as string);
    //   let zones_opened = AppStorage.get('zones_opened') as boolean[];
    //   zones_opened[idx] = true;
    // }

    // Parallel array of ids
    let windowIds = AppStorage.get('windowIds') as string[];
    windowIds.push(my_window_id);
    let windowStages = AppStorage.get('windowStages') as window.WindowStage[];
    windowStages.push(windowStage);
    let windowStorages = AppStorage.get('windowStorages') as LocalStorage[];
    windowStorages.push(storage);

    console.log(`[Meow][HomeAbility] loadContent! (${run_time(this.storage)} ms)`);

    // Load content
    windowStage.loadContent('pages/Index', storage, (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      console.log('Succeeded in obtaining the main window. Data: ' + JSON.stringify(windowClass));
      console.log('[HomeAbility] deviceType: ' + deviceInfo.deviceType);

      let free_window_mode = get_free_window_mode(this.context);

      if (free_window_mode) {
        console.log('[HomeAbility] Free-Window mode! Let\'s GO!');
        enter_free_window_mode(windowClass, storage, my_window_id);
      } else {
        console.log('[HomeAbility] Traditional window mode~');
        enter_traditional_window_mode(windowClass, storage, my_window_id);
      }

      if (is_app_start) {
        // Listen free window mode
        listen_free_window_mode(this.context, windowClass, storage, this.my_window_id);
      }
      AppStorage.setOrCreate('THE_FOCUS_OF_THE_WINDOWS', this.my_window_id);

      // Avoid hosts
      get_avoid(windowClass, storage);
      listen_avoid(windowClass, storage);
      listen_focus(windowClass, storage);
    });
  }

  // Tools

  /**
   * Fills the want into this.storage.
   * @param want the want
   * */
  process_want(want: Want, source: string) {
    console.log(' \n[Meow][HomeAbility] Want accepted!');
    console.log('[Meow][HomeAbility] Source: ' + source + '!');
    this.storage.setOrCreate('want_source', source);

    // want
    let want_type = want.type;
    let want_flags = want.flags;
    this.storage.setOrCreate('want_type', want_type);
    this.storage.setOrCreate('want_flags', want_flags);

    // Want uri
    let want_uri = want.uri;
    let want_action = want.action;
    if (want.parameters) {
      console.log('[Meow][HomeAbility] want.parameters.instanceKey: ' + want.parameters.instanceKey + '!');
      // Got from continuation
      if (want.parameters.data) {
        want_uri = want.parameters.data as string;
        want_action = 'ohos.want.action.viewData';
      }
    }
    this.storage.setOrCreate('want_uri', want_uri);
    this.storage.setOrCreate('want_action', want_action);

    if (want_uri) {
      // Good want
      console.log('[Meow][HomeAbility] Want uri: ' + want_uri + '\n ');
      // Refresh and trigger want response in meowTabsVertical.ets
      this.storage.setOrCreate('want_timestamp', Date.now().toString());
    } else {
      // Invalid want
      console.info('[Meow][HomeAbility] No or empty Want uri accepted.\n ');
    }
  }

  /**
   * Checks if this is the very first launch of the entire application.
   * @returns True if is.
   * */
  is_new_launch() {
    let settings_init_retrieved: boolean | undefined = AppStorage.get('settings_init_retrieved');
    if (settings_init_retrieved) {
      return false;
    }
    return true;
  }

  /**
   * Checks if this is the first launch of this window.
   * @returns True if is.
   * */
  is_new_window() {
    let settings_init_retrieved: boolean | undefined = this.storage.get('settings_init_retrieved');
    if (settings_init_retrieved) {
      return false;
    }
    return true;
  }
}