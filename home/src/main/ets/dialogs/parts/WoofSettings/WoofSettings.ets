import { standardSpacing } from '../../../components/constants';
import { waterFlowColumnsTemplate } from '../../../components/settings';
import { getDevMode } from '../../../hosts/system/resources/settings';
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
  @Param @Require myUi: meowUiHost;

  build() {
    Scroll() {
      WaterFlow() {
        FlowItem() {
          SettingsOnStartUp();
        };
        FlowItem() {
          SettingsGeneral({ myUi: this.myUi });
        };
        FlowItem() {
          SettingsExperience({ myUi: this.myUi });
        };
        FlowItem() {
          SettingsAccessibility({ myUi: this.myUi });
        };
        FlowItem() {
          SettingsAppearance({ myUi: this.myUi });
        };
        FlowItem() {
          SettingsHistory({ myUi: this.myUi });
        };
        FlowItem() {
          SettingsStorage();
        };
        FlowItem() {
          SettingsSecurity({ myUi: this.myUi });
        };
        FlowItem() {
          SettingsCardboardBox({ myUi: this.myUi });
        };
        FlowItem() {
          SettingsAbout({ myUi: this.myUi });
        };
        if (getDevMode()) {
          FlowItem() {
            SettingsDeveowlopers({ myUi: this.myUi });
          };
        }
      }
      .clip(false) // To eliminate the cuts on the edges
      .columnsTemplate(waterFlowColumnsTemplate(this.myUi))
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
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings'), myUi: this.myUi }) {
      WoofSettings({ myUi: this.myUi });
    };
  }
}

export { WoofSettingsDialog };
