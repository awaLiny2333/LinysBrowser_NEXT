import { AppStorageV2 } from '@kit.ArkUI';
import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { standardSpacing, waterFlowColumnsTemplate } from '../../common/constants';
import { WoofUniFrame } from '../common/WoofUniFrame';
import { SettingsAccessibility } from './parts/Accessibility';
import { SettingsAppearance } from './parts/Appearance';
import { SettingsExperience } from './parts/Experience';
import { SettingsGeneral } from './parts/General';
import { SettingsHistory } from './parts/History';
import { SettingsOnStartUp } from './parts/OnStartUp';
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
