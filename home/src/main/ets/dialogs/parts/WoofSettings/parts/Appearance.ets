import { SegmentButtonV2Items } from "@kit.ArkUI";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { defaultInnerRadius } from "../../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../../../components/common/MooCapsuleButton";
import { MooSlider } from "../../../../components/common/MooSlider";
import { MooSwitch } from "../../../../components/common/MooSwitch";
import { MooTabSegmentV2 } from "../../../../components/common/MooTabSegmentV2";
import { MooTextModifier } from "../../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../../components/common/UniContentCard";
import { meowThemeColorType, mooTextType, standardSpacing } from "../../../../components/constants";
import { defaultAnimation, getColor, getMySettings, isTabsStyleVertical, useEffects } from "../../../../components/settings";
import { forceWebDarkMode } from "../../../../hosts/app/tabs/settings";
import { meowDialogManager, openDialogRequestType } from "../../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../../hosts/system/dialogs/scripts/dialog";
import { meowAppHost } from "../../../../hosts/system/windows/classes/meowAppHost";
import { meowUiHost } from "../../../../hosts/system/windows/classes/meowUiHost";
import { getCreateMyApp } from "../../../../hosts/system/windows/scripts/helpers";
import { globalMessage, meowAppMessageType } from "../../../../hosts/system/windows/scripts/messaging";
import { meowManagedSettings } from "../../../../hosts/userdata/settings/classes/meowManagedSettings";
import { resetAnimations, resetColors } from "../../../../hosts/userdata/settings/scripts/reset";

@ComponentV2
struct SettingsAppearance {
  @Local mySettings: meowManagedSettings = getMySettings();
  @Param myApp: meowAppHost = getCreateMyApp();
  @Param @Require myUi: meowUiHost;
  @Param @Require myDialog: meowDialogManager;

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
          isOn: this.mySettings.settingsData[5].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(5, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_navigationIndicator'),
          isOn: this.mySettings.settingsData[6].value as boolean,
          onChange: (r) => {
            globalMessage(meowAppMessageType.SETTINGS_NAV_INDICATOR_UPDATE);
            this.mySettings.setByIndex(6, r);
          }
        });
      };

      // Layout
      UniContentCard({ title: $r('app.string.Settings_category_appearance_layout'), icon: $r('sys.symbol.rectangle_4_group_1') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_appearance_layout_editButtons'),
          clickAction: () => {
            requestDialog(this.myDialog, openDialogRequestType.BUTTONS, undefined, true);
          }
        });
        Text($r('app.string.Settings_category_appearance_layout_titleBarPosition')).attributeModifier(new MooTextModifier());
        MooTabSegmentV2({
          initSelected: this.selectedTitleBarPositionFromSettings(),
          items: new SegmentButtonV2Items([{ text: '↑' }, { text: '↓' }]),
          onSelected: (index) => {
            // 'top' | 'bottom'
            switch (index) {
              case 0:
                this.mySettings.setByIndex(1, 'top');
                break;
              case 1:
                this.mySettings.setByIndex(1, 'bottom');
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
                this.mySettings.setByIndex(3, 'vertical');
                break;
              case 1:
                this.mySettings.setByIndex(3, 'horizontal');
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
                this.mySettings.setByIndex(4, 'vertical');
                break;
              case 1:
                this.mySettings.setByIndex(4, 'horizontal');
                break;
              default:
                break;
            }
            // Avoid showing both sidebar and vertical tabs
            if (!this.myUi.myLayout.wideMode && this.myUi.showSidebar && this.myUi.showTabs && isTabsStyleVertical(this.myUi.myLayout)) {
              this.myUi.showSidebar = false;
            }
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_layout_shrinkSideAreaButton'),
          isOn: this.mySettings.settingsData[15].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(15, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_layout_shrinkSideAreaAuto'),
          isOn: this.mySettings.settingsData[14].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(14, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_layout_shrinkSideAreaNoPush'),
          isOn: this.mySettings.settingsData[84].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(84, r);
          }
        });
      };

      // Windows
      UniContentCard({ title: $r('app.string.Settings_category_appearance_windows'), icon: $r('sys.symbol.single_page_flipping') }) {
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_windows_windowTitle_wide'),
          isOn: this.mySettings.settingsData[23].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(23, r);
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_windows_windowTitle_slim'),
          isOn: this.mySettings.settingsData[24].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(24, r);
          }
        });
        Text($r('app.string.Settings_category_appearance_windows_windowTitlePosition')).attributeModifier(new MooTextModifier());
        MooTabSegmentV2({
          initSelected: this.selectedWindowTitlePositionFromSettings(),
          items: new SegmentButtonV2Items([{ text: '←' }, { text: '󰁨' }, { text: '→' }, { text: '󰁱' }]),
          onSelected: (index) => {
            // 'left' | 'center' | 'right' | 'address'
            switch (index) {
              case 0:
                this.mySettings.setByIndex(25, 'left');
                break;
              case 1:
                this.mySettings.setByIndex(25, 'center');
                break;
              case 2:
                this.mySettings.setByIndex(25, 'right');
                break;
              case 3:
                this.mySettings.setByIndex(25, 'address');
                break;
              default:
                break;
            }
          }
        });
        MooSwitch({
          text: $r('app.string.Settings_category_appearance_windows_windowTitle_gigantic'),
          isOn: this.mySettings.settingsData[2].value as boolean,
          onChange: (r) => {
            this.mySettings.setByIndex(2, r);
          }
        });
      };

      // Animation
      UniContentCard({ title: $r('app.string.Settings_category_appearance_animation'), icon: $r('sys.symbol.play_round_triangle') }) {
        Text($r('app.string.Settings_category_appearance_animation_response')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.mySettings.settingsData[39].value as number,
          min: 1,
          max: 100,
          step: 1,
          onChange: (r) => {
            this.mySettings.setByIndex(39, r);
          }
        });
        Text($r('app.string.Settings_category_appearance_animation_elasticity')).attributeModifier(new MooTextModifier());
        MooSlider({
          value: this.mySettings.settingsData[40].value as number,
          min: 0,
          max: 75,
          step: 1,
          onChange: (r) => {
            this.mySettings.setByIndex(40, r);
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
          isOn: this.mySettings.settingsData[7].value as boolean,
          onChange: (r) => {
            if (useEffects() != r) {
              meow(`Use Effects change!`, 'WoofSettings][Appearance', meowLevel.WARN);
              animateToImmediately(defaultAnimation(), () => {
                this.mySettings.setByIndex(7, r);
              });
              globalMessage(meowAppMessageType.USE_EFFECTS_UPDATED, r); // Majorly used to notify background color update.
            }
          }
        });

        Text($r('app.string.Settings_category_appearance_colors_light')).attributeModifier(new MooTextModifier());
        Row({ space: standardSpacing * 0.75 }) {
          ColorDemoBlock({ myDialog: this.myDialog, myUi: this.myUi, color: this.mySettings.settingsData[62].value as string, settingsId: 62, showBorder: !this.myApp.dark });
          ColorDemoBlock({ myDialog: this.myDialog, myUi: this.myUi, color: this.mySettings.settingsData[63].value as string, settingsId: 63, showBorder: !this.myApp.dark });
          ColorDemoBlock({ myDialog: this.myDialog, myUi: this.myUi, color: this.mySettings.settingsData[64].value as string, settingsId: 64, showBorder: !this.myApp.dark });
        }
        .opacity(useEffects() ? 0.5 : 1);

        Text($r('app.string.Settings_category_appearance_colors_dark')).attributeModifier(new MooTextModifier());
        Row({ space: standardSpacing * 0.75 }) {
          ColorDemoBlock({ myDialog: this.myDialog, myUi: this.myUi, color: this.mySettings.settingsData[65].value as string, settingsId: 65, showBorder: this.myApp.dark });
          ColorDemoBlock({ myDialog: this.myDialog, myUi: this.myUi, color: this.mySettings.settingsData[66].value as string, settingsId: 66, showBorder: this.myApp.dark });
          ColorDemoBlock({ myDialog: this.myDialog, myUi: this.myUi, color: this.mySettings.settingsData[67].value as string, settingsId: 67, showBorder: this.myApp.dark });
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
          isOn: forceWebDarkMode(),
          onChange: (r) => {
            this.mySettings.setByIndex(60, r);
          }
        });
        MooCapsuleButton({
          text: $r('app.string.Settings_category_appearance_colors_forceDarkMode_manage'),
          clickAction: () => {
            requestDialog(this.myDialog, openDialogRequestType.DARK, undefined, true);
          }
        });
      };
    };
  }

  selectedTitleBarPositionFromSettings() {
    const value = this.mySettings.settingsData[1].value as string;
    const seq = ['top', 'bottom'];
    return seq.indexOf(value);
  }
  selectedTabsStyleSlimFromSettings() {
    const value = this.mySettings.settingsData[4].value as string;
    const seq = ['vertical', 'horizontal'];
    return seq.indexOf(value);
  }
  selectedTabsStyleWideFromSettings() {
    const value = this.mySettings.settingsData[3].value as string;
    const seq = ['vertical', 'horizontal'];
    return seq.indexOf(value);
  }
  selectedWindowTitlePositionFromSettings() {
    const value = this.mySettings.settingsData[25].value as string;
    const seq = ['left', 'center', 'right', 'address'];
    return seq.indexOf(value);
  }
}

export { SettingsAppearance };

@ComponentV2
struct ColorDemoBlock {
  // Hosts
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiHost;
  // Data
  @Param @Require color: ResourceColor;
  @Param @Require settingsId: number;
  @Param @Require showBorder: boolean;
  // Local
  @Local pendingColorDialog: boolean = false;

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
        this.pendingColorDialog = true;
        requestDialog(this.myDialog, openDialogRequestType.COLOR_PICKER, this.color as string, true);
      });
      Text(this.color as string).attributeModifier(new MooTextModifier());
    }
    .layoutWeight(1);
  }

  @Monitor('myUi.localMessageTunnel')
  receiveMessage() {
    // Receive the result.
    if (this.myUi.localMessageTunnel?.type == meowAppMessageType.COLOR_PICKED) {
      if (this.pendingColorDialog) {
        getMySettings().setByIndex(this.settingsId, this.myUi.localMessageTunnel.payload as string);
      }
    }
    // Stop 'listening'.
    if (this.myUi.localMessageTunnel?.type == meowAppMessageType.COLOR_PICKER_CLOSED) {
      if (this.pendingColorDialog) {
        this.pendingColorDialog = false;
      }
    }
  }
}
