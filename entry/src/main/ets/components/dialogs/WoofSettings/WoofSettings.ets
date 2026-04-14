import { AppStorageV2 } from '@kit.ArkUI';
import { DEV_MODE } from '../../../hosts/env/scripts/deveowlopers';
import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { standardSpacing, waterFlowColumnsTemplate } from '../../common/constants';
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
          SettingsAppearance();
        };
        FlowItem() {
          SettingsHistory();
        };
        FlowItem() {
          SettingsStorage();
        };
        FlowItem() {
          SettingsSecurity();
        };
        FlowItem() {
          SettingsCardboardBox();
        };
        FlowItem() {
          SettingsAbout();
        };
        if (DEV_MODE()) {
          FlowItem() {
            SettingsDeveowlopers();
          };
        }
      }
      .columnsTemplate(waterFlowColumnsTemplate())
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

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings') }) {
      WoofSettings();
    };
  }
}

export { WoofSettingsDialog };
