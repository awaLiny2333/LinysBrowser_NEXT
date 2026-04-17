import { meowManagedSettings } from "../../../hosts/settings/classes/meowManagedSettings";
import { mooTextType, standardSpacing } from "../../../components/settings";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { MooSwitch } from "../../../components/common/MooSwitch";
import { AppStorageV2 } from "@kit.ArkUI";
import { MooSlider } from "../../../components/common/MooSlider";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";

@ComponentV2
struct SettingsExperience {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

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
          isOn: this.mySettings.settingsData[16].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(16, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_contextMenu_trimTexts'),
          isOn: this.mySettings.settingsData[21].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(21, r);
          }
        });

        // Image preview
        MooSwitch({
          text: $r('app.string.Settings_category_experience_contextMenu_imagePreview'),
          isOn: this.mySettings.settingsData[17].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(17, r);
          }
        });
        Text($r('app.string.Settings_category_experience_contextMenu_imageWidth')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.mySettings.settingsData[19].value as number,
          min: 100,
          max: 600,
          step: 1,
          onChange: (r) => {
            this.mySettings.setByIndex(19, r);
          }
        });

        // Web preview
        MooSwitch({
          text: $r('app.string.Settings_category_experience_contextMenu_webPreview'),
          isOn: this.mySettings.settingsData[18].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(18, r);
          }
        });
        Text($r('app.string.Settings_category_experience_contextMenu_webPreviewHeight')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.mySettings.settingsData[20].value as number,
          min: 100,
          max: 600,
          step: 1,
          onChange: (r) => {
            this.mySettings.setByIndex(20, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_experience_downloads'), icon: $r('sys.symbol.download') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_experience_downloads_directSave'),
          isOn: this.mySettings.settingsData[72].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(72, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_downloads_openOnFinish'),
          isOn: this.mySettings.settingsData[73].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(73, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_experience_continuation'), icon: $r('sys.symbol.screen_witching') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_experience_continuation_closeApp'),
          isOn: this.mySettings.settingsData[27].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(27, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_continuation_closeTab'),
          isOn: this.mySettings.settingsData[28].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(28, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_experience_suggestions'), icon: $r('sys.symbol.star_message') }) {
        Text($r('app.string.Settings_category_experience_suggestions_maxBookmark')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.mySettings.settingsData[12].value as number,
          min: 0,
          max: 20,
          step: 1,
          onChange: (r) => {
            this.mySettings.setByIndex(12, r);
          }
        });
        Text($r('app.string.Settings_category_experience_suggestions_maxHistory')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.mySettings.settingsData[13].value as number,
          min: 0,
          max: 20,
          step: 1,
          onChange: (r) => {
            this.mySettings.setByIndex(13, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_experience_advanced'), icon: $r('sys.symbol.fast') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_experience_advanced_adsblocker'),
          isOn: this.mySettings.settingsData[52].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(52, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_experience_advanced_adsblocker_manage'),
          clickAction: () => {
            // TODO: Ads blocker manager entrance.
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_experience_advanced_adsblocker_rules'),
          clickAction: () => {
            // TODO: Ads blocker rules manager entrance.
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_advanced_webImages'),
          isOn: this.mySettings.settingsData[57].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(57, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_experience_advanced_webImages_manage'),
          clickAction: () => {
            // TODO: Web image manager entrance.
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_advanced_Js'),
          isOn: this.mySettings.settingsData[54].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(54, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_experience_advanced_Js_manage'),
          clickAction: () => {
            // TODO: Js manager entrance.
          }
        });
      };
    };
  }
}

export { SettingsExperience };