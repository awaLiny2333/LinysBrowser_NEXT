import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayoutModeStatus } from '../../../catstypicalframework/hosts/meowLayoutModeStatus';
import { meowDialogManager } from '../../../hosts/env/classes/meowDialogManager';
import { meowUiStatuses } from '../../../hosts/env/classes/meowUiStatuses';
import { getDevMode } from '../../../hosts/env/settings';
import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { standardSpacing, waterFlowColumnsTemplate } from '../../settings';
import { WoofUniFrame } from '../common/WoofUniFrame';
import { SettingsAbout } from './parts/About';
import { SettingsAccessibility } from './parts/Accessibility';
import { SettingsAppearance } from './parts/Appearance';
import { SettingsCardboardBox } from './parts/CardboardBox';
import { SettingsDeveowlopers } from './parts/Deveowlopers';
import { SettingsExperience } from './parts/Experience';
import { SettingsGeneral } from './parts/General';
import { SettingsHistory } from './parts/History';
import { SettingsOnStartUp } from './parts/OnStartUp';
import { SettingsSecurity } from './parts/Security';
import { SettingsStorage } from './parts/Storage';

@ComponentV2
struct WoofSettings {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Param @Require myMeowDialogManager: meowDialogManager;
  @Param @Require myMeowUiStatuses: meowUiStatuses;
  @Param @Require myMeowLayoutModeStatus: meowLayoutModeStatus;

  build() {
    Scroll() {
      WaterFlow() {
        FlowItem() {
          SettingsOnStartUp();
        };
        FlowItem() {
          SettingsGeneral();
        };
        FlowItem() {
          SettingsExperience();
        };
        FlowItem() {
          SettingsAccessibility();
        };
        FlowItem() {
          SettingsAppearance({
            myMeowDialogManager: this.myMeowDialogManager,
          });
        };
        FlowItem() {
          SettingsHistory();
        };
        FlowItem() {
          SettingsStorage();
        };
        FlowItem() {
          SettingsSecurity({
            myMeowUiStatuses: this.myMeowUiStatuses,
          });
        };
        FlowItem() {
          SettingsCardboardBox();
        };
        FlowItem() {
          SettingsAbout();
        };
        if (getDevMode()) {
          FlowItem() {
            SettingsDeveowlopers({
              myMeowUiStatuses: this.myMeowUiStatuses,
              myMeowDialogManager: this.myMeowDialogManager,
            });
          };
        }
      }
      .columnsTemplate(waterFlowColumnsTemplate(this.myMeowLayoutModeStatus))
      // .animation(defaultAnimation())
      .columnsGap(standardSpacing)
      .rowsGap(standardSpacing);
    }
    .padding(standardSpacing)
    .edgeEffect(EdgeEffect.Spring);
  }
}

@CustomDialog
struct WoofSettingsDialog {
  controller: CustomDialogController;
  @Require myMeowUiStatuses: meowUiStatuses;
  @Require myMeowDialogManager: meowDialogManager;
  @Require myMeowLayoutModeStatus: meowLayoutModeStatus;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings'), myMeowDialogManager: this.myMeowDialogManager, myMeowLayoutModeStatus: this.myMeowLayoutModeStatus }) {
      WoofSettings({ myMeowDialogManager: this.myMeowDialogManager, myMeowUiStatuses: this.myMeowUiStatuses, myMeowLayoutModeStatus: this.myMeowLayoutModeStatus });
    };
  }
}

export { WoofSettingsDialog };
