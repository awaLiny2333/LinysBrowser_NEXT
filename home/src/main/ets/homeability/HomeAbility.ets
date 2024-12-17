import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export default class HomeAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    console.log('want bundle name: ' + want.bundleName);
    console.log('launchParam launchReason: ' + launchParam.launchReason);

    // save environment
    AppStorage.setOrCreate('context', this.context);
    AppStorage.setOrCreate('pathDir', this.context.filesDir);
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);

    this.process_want(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.process_want(want);
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
      win.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED)
      // Set window orientation
    })

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口

      // 1. 设置窗口全屏
      let isLayoutFullScreen = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)
        .then(() => {
          console.info('Succeeded in setting the window layout to full-screen mode.');
        })
        .catch((err: BusinessError) => {
          console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
        });

      // 2. 获取布局避让遮挡的区域
      let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);
      let avoid = avoidArea.bottomRect.height; // 获取到导航条区域的高度
      AppStorage.setOrCreate('bottomAvoidHeight', avoid);

      type = window.AvoidAreaType.TYPE_SYSTEM;
      avoidArea = windowClass.getWindowAvoidArea(type);
      avoid = avoidArea.topRect.height;
      AppStorage.setOrCreate('topAvoidHeight', avoid);

      type = window.AvoidAreaType.TYPE_CUTOUT;
      avoidArea = windowClass.getWindowAvoidArea(type);
      avoid = avoidArea.leftRect.width;
      AppStorage.setOrCreate('leftAvoidWidth', avoid);

      type = window.AvoidAreaType.TYPE_CUTOUT;
      avoidArea = windowClass.getWindowAvoidArea(type);
      avoid = avoidArea.rightRect.width;
      AppStorage.setOrCreate('rightAvoidWidth', avoid);
    });
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
}
