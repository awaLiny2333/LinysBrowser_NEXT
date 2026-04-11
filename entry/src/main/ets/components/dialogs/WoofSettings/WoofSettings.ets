import { standardSpacing, waterFlowColumnsTemplate } from '../../common/constants';
import { WoofUniFrame } from './common/WoofUniFrame';
import { SettingsAccessibility } from './parts/Accessibility';
import { SettingsExperience } from './parts/Experience';
import { SettingsGeneral } from './parts/General';
import { SettingsOnStartUp } from './parts/OnStartUp';

@ComponentV2
struct WoofSettings {
  build() {
    WaterFlow() {
      FlowItem() {
        SettingsOnStartUp();
      }.padding({ bottom: standardSpacing });
      FlowItem() {
        SettingsGeneral();
      }.padding({ bottom: standardSpacing });
      FlowItem() {
        SettingsExperience();
      }.padding({ bottom: standardSpacing });
      FlowItem() {
        SettingsAccessibility();
      }.padding({ bottom: standardSpacing });
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsGap(standardSpacing)
    // .rowsGap(standardSpacing)
    .padding({ top: 50, left: standardSpacing, right: standardSpacing })
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
