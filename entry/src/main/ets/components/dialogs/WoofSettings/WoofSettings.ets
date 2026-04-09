import { standardSpacing, waterFlowColumnsTemplate } from '../../common/constants';
import { WoofUniFrame } from '../WoofUniFrame';
import { SettingsGeneral } from './General';
import { SettingsOnStartUp } from './OnStartUp';

@ComponentV2
struct WoofSettings {
  build() {
    WaterFlow() {
      FlowItem() {
        SettingsOnStartUp();
      };
      FlowItem() {
        SettingsGeneral();
      };
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsGap(standardSpacing)
    .padding({ top: 50, left: standardSpacing, right: standardSpacing, bottom: standardSpacing })
    .columnsTemplate(waterFlowColumnsTemplate());
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
