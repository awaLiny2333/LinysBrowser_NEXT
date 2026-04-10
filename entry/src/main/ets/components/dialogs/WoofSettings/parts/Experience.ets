import { meowManagedSettings } from "../../../../hosts/settings/classes/meowManagedSettings";
import { mooTextType, standardSpacing } from "../../../common/constants";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { UniContentCard } from "../../../common/UniContentCard";
import { MooSwitch } from "../../../common/MooSwitch";
import { AppStorageV2 } from "@kit.ArkUI";
import { MooSlider } from "../../../common/MooSlider";

@ComponentV2
struct SettingsExperience {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_experience'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      UniContentCard({ title: $r('app.string.Settings_category_experience_contextMenu'), icon: $r('sys.symbol.list_square') }) {
        // Text
        MooSwitch({
          text: $r('app.string.Settings_category_experience_contextMenu_enable'),
          isOn: this.myMeowManagedSettings.settingsData[16].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(16, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_contextMenu_trimTexts'),
          isOn: this.myMeowManagedSettings.settingsData[21].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(21, r);
          }
        });
        
        // Image preview
        MooSwitch({
          text: $r('app.string.Settings_category_experience_contextMenu_imagePreview'),
          isOn: this.myMeowManagedSettings.settingsData[17].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(17, r);
          }
        });
        Text($r('app.string.Settings_category_experience_contextMenu_imageWidth')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.myMeowManagedSettings.settingsData[19].value as number,
          min: 100,
          max: 600,
          step: 1,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(19, r);
          }
        });
        
        // Web preview
        MooSwitch({
          text: $r('app.string.Settings_category_experience_contextMenu_webPreview'),
          isOn: this.myMeowManagedSettings.settingsData[18].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(18, r);
          }
        });
        Text($r('app.string.Settings_category_experience_contextMenu_webPreviewHeight')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.myMeowManagedSettings.settingsData[20].value as number,
          min: 100,
          max: 600,
          step: 1,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(20, r);
          }
        });
      };
      UniContentCard({ title: $r('app.string.Settings_category_experience_downloads'), icon: $r('sys.symbol.download') }) {
      };
      UniContentCard({ title: $r('app.string.Settings_category_experience_continuation'), icon: $r('sys.symbol.screen_witching') }) {
      };
      UniContentCard({ title: $r('app.string.Settings_category_experience_suggestions'), icon: $r('sys.symbol.star_message') }) {
      };
      UniContentCard({ title: $r('app.string.Settings_category_experience_advanced'), icon: $r('sys.symbol.fast') }) {
      };
    };
  }
}

export { SettingsExperience };