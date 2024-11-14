import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { bunch_of_search_engines } from '../hosts/bunch_of_search_engines';

export default class HomeAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    console.log('want bundle name: ' + want.bundleName);
    console.log('launchParam launchReason: ' + launchParam.launchReason);

    // save environment
    AppStorage.setOrCreate('context', this.context);
    AppStorage.setOrCreate('pathDir', this.context.filesDir);
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);
    AppStorage.setOrCreate('bunch_of_tabs', new bunch_of_tabs());
    AppStorage.setOrCreate('bunch_of_bookmarks', new bunch_of_bookmarks("Bookmarks Meow"));
    AppStorage.setOrCreate('bunch_of_user_agents', new bunch_of_user_agents());
    AppStorage.setOrCreate('bunch_of_search_engines', new bunch_of_search_engines());
    AppStorage.setOrCreate('bunch_of_downloads', new bunch_of_downloads());
    AppStorage.setOrCreate('bunch_of_history', new bunch_of_history());
    AppStorage.setOrCreate('bunch_of_settings', new bunch_of_settings());
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
}
