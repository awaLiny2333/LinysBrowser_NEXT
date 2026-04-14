import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../../hosts/env/classes/meowDialogManager';
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
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;

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
            myDialog: this.myDialog,
          });
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
        if (getDevMode()) {
          FlowItem() {
            SettingsDeveowlopers({
              myDialog: this.myDialog,
            });
          };
        }
      }
      .columnsTemplate(waterFlowColumnsTemplate(this.myLayout))
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
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      WoofSettings({ myDialog: this.myDialog, myLayout: this.myLayout });
    };
  }
}

export { WoofSettingsDialog };
