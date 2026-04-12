import { meowManagedSettings } from "../../../../hosts/settings/classes/meowManagedSettings";
import { AppStorageV2, SegmentButtonV2Items } from "@kit.ArkUI";
import { mooTextType, standardSpacing } from "../../../common/constants";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { UniContentCard } from "../../../common/UniContentCard";
import { MooSwitch } from "../../../common/MooSwitch";
import { MooTabSegmentV2 } from "../../../common/MooTabSegmentV2";

@ComponentV2
struct SettingsAppearance {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_appearance'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      // Avoid and navigation indicator
      UniContentCard() {
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_bottomAvoid'),
          isOn: this.myMeowManagedSettings.settingsData[5].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(5, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_navigationIndicator'),
          isOn: this.myMeowManagedSettings.settingsData[6].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(6, r);
          }
        });
      };

      UniContentCard({ title: $r('app.string.Settings_category_appearance_layout'), icon: $r('sys.symbol.rectangle_4_group_1') }) {
        Text($r('app.string.Settings_category_appearance_layout_titleBarPins')).attributeModifier(new MooTextModifier());
        Text($r('app.string.Settings_category_appearance_layout_titleBarPosition')).attributeModifier(new MooTextModifier());
        MooTabSegmentV2({
          initSelected: this.selectedTitleBarPositionFromSettings(),
          items: new SegmentButtonV2Items([{ text: '↑' }, { text: '↓' }]),
          onSelected: (index) => {
            // 'top' | 'bottom'
            switch (index) {
              case 0:
                this.myMeowManagedSettings.setByIndex(1, 'top');
                break;
              case 1:
                this.myMeowManagedSettings.setByIndex(1, 'bottom');
                break;
              default:
                break;
            }
          }
        });
        Text($r('app.string.Settings_category_appearance_layout_tabsStyle_wide')).attributeModifier(new MooTextModifier());
        MooTabSegmentV2({
          initSelected: this.selectedTabsStyleWideFromSettings(),
          items: new SegmentButtonV2Items([{ text: '󰕥' }, { text: '󰕦' }]),
          onSelected: (index) => {
            // 'vertical' | 'horizontal'
            switch (index) {
              case 0:
                this.myMeowManagedSettings.setByIndex(4, 'vertical');
                break;
              case 1:
                this.myMeowManagedSettings.setByIndex(4, 'horizontal');
                break;
              default:
                break;
            }
          }
        });
        Text($r('app.string.Settings_category_appearance_layout_tabsStyle_slim')).attributeModifier(new MooTextModifier());
        MooTabSegmentV2({
          initSelected: this.selectedTabsStyleSlimFromSettings(),
          items: new SegmentButtonV2Items([{ text: '󰕥' }, { text: '󰕦' }]),
          onSelected: (index) => {
            // 'vertical' | 'horizontal'
            switch (index) {
              case 0:
                this.myMeowManagedSettings.setByIndex(3, 'vertical');
                break;
              case 1:
                this.myMeowManagedSettings.setByIndex(3, 'horizontal');
                break;
              default:
                break;
            }
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_layout_shrinkSideBar'),
          isOn: this.myMeowManagedSettings.settingsData[14].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(14, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_layout_shrinkSideBarButton'),
          isOn: this.myMeowManagedSettings.settingsData[15].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(15, r);
          }
        });
      };
    };
  }

  selectedTitleBarPositionFromSettings() {
    const value = this.myMeowManagedSettings.settingsData[1].value as string;
    const seq = ['top', 'bottom'];
    return seq.indexOf(value);
  }
  selectedTabsStyleWideFromSettings() {
    const value = this.myMeowManagedSettings.settingsData[4].value as string;
    const seq = ['vertical', 'horizontal'];
    return seq.indexOf(value);
  }
  selectedTabsStyleSlimFromSettings() {
    const value = this.myMeowManagedSettings.settingsData[3].value as string;
    const seq = ['vertical', 'horizontal'];
    return seq.indexOf(value);
  }
}

export { SettingsAppearance };