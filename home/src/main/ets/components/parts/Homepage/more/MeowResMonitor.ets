import { addUnitsToSize } from "../../../../catstypicalframework/utils/storage";
import { defaultInnerRadius } from "../../../../catstypicalframework/utils/ui";
import { getCPU, getNativeHeapSize, getPrivateDirty, getPss, getSharedDirty, getVRAM, getVss } from "../../../../hosts/system/performance/scripts/funcAsync";
import { MooTextModifier } from "../../../common/MooTextModifier";
import { standardSpacing,mooTextType,meowThemeColorType } from "../../../constants";
import { getColor, isPreferRightHand, useEffects } from "../../../settings";

@Builder
export function MeowResMonitor() {
  Scroll() {
    Row({ space: standardSpacing }) {
      DataBlock({
        label: $r('app.string.ResMonitor_CPU'),
        valueRetriever: async () => {
          return `${(await getCPU() * 100).toFixed(2)}%`;
        },
      });
      DataBlock({
        label: $r('app.string.ResMonitor_VRAM'),
        refreshInterval: 7000,
        valueRetriever: async () => {
          return `${addUnitsToSize(await getVRAM())}`;
        },
      });
      DataBlock({
        label: $r('app.string.ResMonitor_PSS'),
        valueRetriever: async () => {
          return `${addUnitsToSize(await getPss())}`;
        },
      });
      DataBlock({
        label: $r('app.string.ResMonitor_VSS'),
        valueRetriever: async () => {
          return `${addUnitsToSize(await getVss())}`;
        },
      });
      DataBlock({
        label: $r('app.string.ResMonitor_nativeHeap'),
        valueRetriever: async () => {
          return `${addUnitsToSize(await getNativeHeapSize())}`;
        },
      });
      DataBlock({
        label: $r('app.string.ResMonitor_sharedDirty'),
        valueRetriever: async () => {
          return `${addUnitsToSize(await getSharedDirty())}`;
        },
      });
      DataBlock({
        label: $r('app.string.ResMonitor_privateDirty'),
        valueRetriever: async () => {
          return `${addUnitsToSize(await getPrivateDirty())}`;
        },
      });
    };
  }
  .borderRadius(defaultInnerRadius + standardSpacing * 0.25)
  .scrollBar(BarState.Off)
  .align(isPreferRightHand() ? Alignment.End : Alignment.Start)
  .width('100%')
  .scrollable(ScrollDirection.Horizontal)
  .edgeEffect(EdgeEffect.Spring);
}

@ComponentV2
struct DataBlock {
  // Config
  @Param @Require @Once label: ResourceStr;
  @Param refreshInterval: number = 2333;
  // Local
  @Local value: ResourceStr = this.label;
  intervalId: number | undefined = undefined;
  // Events
  @Event valueRetriever: () => Promise<string>;

  aboutToAppear(): void {
    // Loop
    this.intervalId = setInterval(async () => {
      this.value = await this.valueRetriever();
    }, this.refreshInterval);
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId);
  }

  build() {
    Column() {
      Text(this.label).attributeModifier(new MooTextModifier()).opacity(0.75);
      Text(this.value).attributeModifier(new MooTextModifier(mooTextType.TITLE));
    }
    .padding(standardSpacing * 0.85)
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .border({ radius: defaultInnerRadius + standardSpacing * 0.25, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
    .alignItems(HorizontalAlign.Start);
  }
}
