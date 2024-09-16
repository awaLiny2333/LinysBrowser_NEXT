import { animation_default } from '../hosts/BunchOfSettings';
import LinysTitleText from '../components/LinysTitleText';
import LinysText from '../components/LinysText';
import bundleManager from '@ohos.bundle.bundleManager';

@Component
struct LinysAppSettings {
  @Prop show: boolean = false;
  @Prop screen_width: number;
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName; //应用版本名
      this.versionNo = bundleInfo.versionCode; //应用版本号
    })
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
    .padding({ top: this.show ? 15 : 0, left: 15, right: 15 })
    .width("100%")
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())
  }
}

export default LinysAppSettings