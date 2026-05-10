import { meowLayout } from '../../../catstypicalframework/hosts/meowLayout';
import { standardSpacing } from '../../../components/constants';
import { waterFlowColumnsTemplate } from '../../../components/settings';
import { meowDialogManager } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { getDevMode } from '../../../hosts/system/storage/settings';
import { meowUiHost } from '../../../hosts/system/windows/classes/meowUiHost';
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
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  @Param @Require myUi: meowUiHost;

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
          SettingsSecurity({ myDialog: this.myDialog });
        };
        FlowItem() {
          SettingsCardboardBox({ myDialog: this.myDialog, myUi: this.myUi });
        };
        FlowItem() {
          SettingsAbout({ myDialog: this.myDialog });
        };
        if (getDevMode()) {
          FlowItem() {
            SettingsDeveowlopers({ myDialog: this.myDialog });
          };
        }
      }
      .clip(false) // To eliminate the cuts on the edges
      .columnsTemplate(waterFlowColumnsTemplate(this.myLayout))
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
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings'), myDialog: this.myDialog, myLayout: this.myLayout }) {
      WoofSettings({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi });
    };
  }
}

export { WoofSettingsDialog };
