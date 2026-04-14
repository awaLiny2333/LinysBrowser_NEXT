import { meowManagedSettings } from "../../../../hosts/settings/classes/meowManagedSettings";
import { mooTextType, standardSpacing } from "../../../settings";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { UniContentCard } from "../../../common/UniContentCard";
import { MooSwitch } from "../../../common/MooSwitch";
import { AppStorageV2 } from "@kit.ArkUI";
import { MooSlider } from "../../../common/MooSlider";
import { MooCapsuleButton } from "../../../common/MooCapsuleButton";

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
        MooSwitch({
          text: $r('app.string.Settings_category_experience_downloads_directSave'),
          isOn: this.myMeowManagedSettings.settingsData[72].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(72, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_downloads_openOnFinish'),
          isOn: this.myMeowManagedSettings.settingsData[73].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(73, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_experience_continuation'), icon: $r('sys.symbol.screen_witching') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_experience_continuation_closeApp'),
          isOn: this.myMeowManagedSettings.settingsData[27].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(27, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_experience_continuation_closeTab'),
          isOn: this.myMeowManagedSettings.settingsData[28].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(28, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_experience_suggestions'), icon: $r('sys.symbol.star_message') }) {
        Text($r('app.string.Settings_category_experience_suggestions_maxBookmark')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.myMeowManagedSettings.settingsData[12].value as number,
          min: 0,
          max: 20,
          step: 1,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(12, r);
          }
        });
        Text($r('app.string.Settings_category_experience_suggestions_maxHistory')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.myMeowManagedSettings.settingsData[13].value as number,
          min: 0,
          max: 20,
          step: 1,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(13, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_experience_advanced'), icon: $r('sys.symbol.fast') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_experience_advanced_adsblocker'),
          isOn: this.myMeowManagedSettings.settingsData[52].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(52, r);
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
          isOn: this.myMeowManagedSettings.settingsData[57].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(57, r);
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
          isOn: this.myMeowManagedSettings.settingsData[54].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(54, r);
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