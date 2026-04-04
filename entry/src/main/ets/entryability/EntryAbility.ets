import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { aboutToLoadContent, earlyOnCreate, earlyOnWindowStageCreate as onWindowStageCreate, onLoadContent, onWant, wantSource } from '../catstypicalframework/flows/flows';
import { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.warn(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    earlyOnCreate(this.context);

    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    onWant(want, wantSource.ONCREATE);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    onWant(want, wantSource.RUNTIME);
  }

  onDestroy(): void {
    hilog.warn(DOMAIN, 'testTag', '%{public}s', ' \nAbility onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.warn(DOMAIN, 'testTag', '%{public}s', ' \nAbility onWindowStageCreate');
    await onWindowStageCreate(this.context); // Start this loading in an early stage. Does this make a difference?

    try {
      let mainWindow = await windowStage.getMainWindow();
      await aboutToLoadContent(windowStage, mainWindow, this.context);

      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', ' \nFailed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.warn(DOMAIN, 'testTag', ' \nMeow onLoadContent');
        onLoadContent(mainWindow, this.context);
      });

    } catch (e) {
      meow(`windowStage.getMainWindowSync(); Failed: ${e}`, 'init', meowLevel.ERROR);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.warn(DOMAIN, 'testTag', '%{public}s', ' \nAbility onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.warn(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.warn(DOMAIN, 'testTag', '%{public}s', ' \nAbility onBackground');
  }
}