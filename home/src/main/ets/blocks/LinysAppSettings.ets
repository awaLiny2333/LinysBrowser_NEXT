import { animation_default } from '../hosts/BunchOfSettings';
import LinysTitleText from '../components/LinysTitleText';
import LinysText from '../components/LinysText';
import bundleManager from '@ohos.bundle.bundleManager';
import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@ohos.arkui.advanced.SegmentButton';
import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';

@Component
struct LinysAppSettings {
  // Generals
  @Prop @Watch('on_open_or_close_panel') show: boolean = false;
  @Prop screen_width: number;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  // Settings
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State @Watch('on_title_bar_position_changed') title_bar_position_selected: number[] = [0];
  @Link settings_title_bar_position: string;

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName; //应用版本名
      this.versionNo = bundleInfo.versionCode; //应用版本号
    })
    // Get app version info
    kv_store_get('settings_title_bar_position').then((result) => {
      if (result == "undefined") {
        // First open
        kv_store_put('settings_title_bar_position', "bottom");
        this.settings_title_bar_position = "bottom";
      } else {
        this.settings_title_bar_position = result;
      }
    })
    // Get settings of title bar position
  }

  build() {
    WaterFlow() {
      FlowItem() {
        Column({ space: 15 }) {
          LinysTitleText({ text: $r('app.string.Settings_start_up') })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))
      } // Start up
      .width("100%")

      FlowItem() {
        Column({ space: 15 }) {
          LinysTitleText({ text: $r('app.string.Settings_general') })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))
      } // General
      .width("100%")

      FlowItem() {
        Column({ space: 15 }) {
          LinysTitleText({ text: $r('app.string.Settings_appearance') })
          LinysText({ text: $r('app.string.Settings_appearance_title_bar_position') })
          SegmentButton({
            options: this.title_bar_position_tabOptions,
            selectedIndexes: $title_bar_position_selected
          })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))
      } // Appearance
      .width("100%")

      FlowItem() {
        Column({ space: 15 }) {
          LinysTitleText({ text: $r('app.string.Settings_about') })
          LinysText({ text: "（ฅ＾・ﻌ・＾）ฅ" })
          LinysText({ text: this.versionName + " - " + this.versionNo })

        }
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))
      } // About
      .width("100%")

    } // Bottom Bar of App Settings
    .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width / 430)))
    .rowsGap(10)
    .columnsGap(10)
    .height(this.show ? "75%" : 0)
    .padding({ left: 15, right: 15 })
    .width("100%")
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())
  }

  on_title_bar_position_changed() {
    let result: string = "";
    if (this.title_bar_position_selected[0] == 0) {
      result = 'top';
    } else {
      result = 'bottom';
    }
    this.settings_title_bar_position = result;
    kv_store_put('settings_title_bar_position', result);
  }

  on_open_or_close_panel() {
    if (this.show) {
      // Open panel
      this.on_panel_open();
    } else {
      // Close panel
      this.on_panel_close();
    }
  }

  on_panel_open() {
    if (this.settings_title_bar_position == "top") {
      this.title_bar_position_selected = [0];
    } else {
      this.title_bar_position_selected = [1];
    }
  }

  on_panel_close() {

  }
}

export default LinysAppSettings