import { AppStorageV2, SegmentButtonV2Items } from "@kit.ArkUI";
import { defaultInnerRadius } from "../../../../catstypicalframework/utils/ui";
import { meowDialogManager, openDialogRequestType } from "../../../../hosts/env/classes/meowDialogManager";
import { requestDialog } from "../../../../hosts/env/scripts/dialog";
import { meowManagedSettings } from "../../../../hosts/settings/classes/meowManagedSettings";
import { resetAnimations, resetColors } from "../../../../hosts/settings/scripts/reset";
import { getColor, meowThemeColorType, mooTextType, standardSpacing, useEffects } from "../../../settings";
import { MooCapsuleButton } from "../../../common/MooCapsuleButton";
import { MooSlider } from "../../../common/MooSlider";
import { MooSwitch } from "../../../common/MooSwitch";
import { MooTabSegmentV2 } from "../../../common/MooTabSegmentV2";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { UniContentCard } from "../../../common/UniContentCard";
import { meowAppStatuses } from "../../../../hosts/env/classes/meowAppStatuses";

@ComponentV2
struct SettingsAppearance {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Param myMeowAppStatuses: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  @Param @Require myMeowDialogManager: meowDialogManager;

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

      // Layout
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

      // Windows
      UniContentCard({ title: $r('app.string.Settings_category_appearance_windows'), icon: $r('sys.symbol.single_page_flipping') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_windows_windowTitle_wide'),
          isOn: this.myMeowManagedSettings.settingsData[23].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(23, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_windows_windowTitle_slim'),
          isOn: this.myMeowManagedSettings.settingsData[24].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(24, r);
          }
        });
        Text($r('app.string.Settings_category_appearance_windows_windowTitlePosition')).attributeModifier(new MooTextModifier());
        MooTabSegmentV2({
          initSelected: this.selectedWindowTitlePositionFromSettings(),
          items: new SegmentButtonV2Items([{ text: '←' }, { text: '󰁨' }, { text: '→' }]),
          onSelected: (index) => {
            // 'left' | 'center' | 'right'
            switch (index) {
              case 0:
                this.myMeowManagedSettings.setByIndex(25, 'left');
                break;
              case 1:
                this.myMeowManagedSettings.setByIndex(25, 'center');
                break;
              case 2:
                this.myMeowManagedSettings.setByIndex(25, 'right');
                break;
              default:
                break;
            }
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_windows_windowTitle_gigantic'),
          isOn: this.myMeowManagedSettings.settingsData[2].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(2, r);
          }
        });
      };

      // Animation
      UniContentCard({ title: $r('app.string.Settings_category_appearance_animation'), icon: $r('sys.symbol.play_round_triangle') }) {
        Text($r('app.string.Settings_category_appearance_animation_response')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.myMeowManagedSettings.settingsData[39].value as number,
          min: 1,
          max: 100,
          step: 1,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(39, r);
          }
        });
        Text($r('app.string.Settings_category_appearance_animation_elasticity')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.myMeowManagedSettings.settingsData[40].value as number,
          min: 0,
          max: 75,
          step: 1,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(40, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_appearance_animation_reset'),
          needDoubleConfirm: true,
          clickAction: () => {
            resetAnimations();
          }
        });
      };

      // Colors
      UniContentCard({ title: $r('app.string.Settings_category_appearance_colors'), icon: $r('sys.symbol.paintpalette') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_colors_effects'),
          isOn: this.myMeowManagedSettings.settingsData[7].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(7, r);
          }
        });

        Text($r('app.string.Settings_category_appearance_colors_light')).attributeModifier(new MooTextModifier());
        Row({ space: standardSpacing * 0.75 }) {
          ColorDemoBlock({ myMeowDialogManager: this.myMeowDialogManager, color: this.myMeowManagedSettings.settingsData[62].value as string, settingsId: 62, showBorder: !this.myMeowAppStatuses.dark });
          ColorDemoBlock({ myMeowDialogManager: this.myMeowDialogManager, color: this.myMeowManagedSettings.settingsData[63].value as string, settingsId: 63, showBorder: !this.myMeowAppStatuses.dark });
          ColorDemoBlock({ myMeowDialogManager: this.myMeowDialogManager, color: this.myMeowManagedSettings.settingsData[64].value as string, settingsId: 64, showBorder: !this.myMeowAppStatuses.dark });
        }
        .opacity(useEffects() ? 0.5 : 1);

        Text($r('app.string.Settings_category_appearance_colors_dark')).attributeModifier(new MooTextModifier());
        Row({ space: standardSpacing * 0.75 }) {
          ColorDemoBlock({ myMeowDialogManager: this.myMeowDialogManager, color: this.myMeowManagedSettings.settingsData[65].value as string, settingsId: 65, showBorder: this.myMeowAppStatuses.dark });
          ColorDemoBlock({ myMeowDialogManager: this.myMeowDialogManager, color: this.myMeowManagedSettings.settingsData[66].value as string, settingsId: 66, showBorder: this.myMeowAppStatuses.dark });
          ColorDemoBlock({ myMeowDialogManager: this.myMeowDialogManager, color: this.myMeowManagedSettings.settingsData[67].value as string, settingsId: 67, showBorder: this.myMeowAppStatuses.dark });
        }
        .opacity(useEffects() ? 0.5 : 1);

        MooCapsuleButton({
          text: $r('app.string.Settings_category_appearance_colors_reset'),
          needDoubleConfirm: true,
          clickAction: () => {
            resetColors();
          }
        });

        MooSwitch({
          text: $r('app.string.Settings_category_appearance_colors_forceDarkMode'),
          isOn: this.myMeowManagedSettings.settingsData[60].value as boolean,
          onChange: (r) => {
            this.myMeowManagedSettings.setByIndex(60, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_appearance_colors_forceDarkMode_manage'),
          clickAction: () => {
            // TODO: manage web darkmode entrance.s
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
  selectedWindowTitlePositionFromSettings() {
    const value = this.myMeowManagedSettings.settingsData[25].value as string;
    const seq = ['left', 'center', 'right'];
    return seq.indexOf(value);
  }
}

export { SettingsAppearance };

@ComponentV2
struct ColorDemoBlock {
  @Param @Require myMeowDialogManager: meowDialogManager;
  @Param @Require color: ResourceColor;
  @Param @Require settingsId: number;
  @Param @Require showBorder: boolean;

  build() {
    Column({ space: standardSpacing }) {
      Column() {
      }
      .width('100%')
      .hoverEffect(HoverEffect.Highlight)
      .height(90)
      .backgroundColor(this.color)
      .border({
        width: 2,
        color: this.showBorder ? getColor(meowThemeColorType.FONT) : getColor(meowThemeColorType.SECONDARY),
        radius: defaultInnerRadius
      })
      .onClick(() => {
        requestDialog(this.myMeowDialogManager, openDialogRequestType.COLOR_PICKER, this.settingsId, true);
      });
      Text(this.color as string).attributeModifier(new MooTextModifier());
    }.layoutWeight(1);
  }
}
