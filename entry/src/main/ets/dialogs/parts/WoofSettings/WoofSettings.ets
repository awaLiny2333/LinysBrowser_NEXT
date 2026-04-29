import { AppStorageV2 } from '@kit.ArkUI';
import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { standardSpacing, waterFlowColumnsTemplate } from '../../../components/settings';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { getDevMode } from '../../../hosts/system/storage/settings';
import { meowUiStatuses } from '../../../hosts/system/windows/classes/meowUiStatuses';
import { WoofUniFrame } from '../../WoofUniFrame';
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
  @Param @Require myUi: meowUiStatuses;

  build() {
    Scroll() {
      WaterFlow() {
        FlowItem() {
          SettingsOnStartUp();
        };
        FlowItem() {
          SettingsGeneral({ myDialog: this.myDialog });
        };
        FlowItem() {
          SettingsExperience({ myDialog: this.myDialog });
        };
        FlowItem() {
          SettingsAccessibility({ myDialog: this.myDialog });
        };
        FlowItem() {
          SettingsAppearance({ myDialog: this.myDialog, myUi: this.myUi });
        };
        FlowItem() {
          SettingsHistory({ myDialog: this.myDialog });
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
            SettingsDeveowlopers({ myDialog: this.myDialog });
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
  @Require myUi: meowUiStatuses;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      WoofSettings({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi });
    };
  }
}

export { WoofSettingsDialog };
