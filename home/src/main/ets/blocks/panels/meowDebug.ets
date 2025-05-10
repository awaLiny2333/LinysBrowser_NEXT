import linysSymbol from '../../components/linysSymbol';
import linysText from '../../components/linysText';
import { click_effect_default } from '../../hosts/bunch_of_defaults';
import { getPrivateDirty, getPss, getSharedDirty, getVRAM, getVss } from '../../utils/any_concurrent_tools';
import { getCPU_sync, getNativeHeapSize_sync } from '../../utils/performance_tools';
import { add_units_to_size } from '../../utils/storage_tools';

@Component
struct meowDebug {
  @State data: string[] = ['pss', 'vss', 'shared dirty', 'private dirty', 'cpu', 'native heap', 'vram'];
  @StorageLink('showing_more_options') showing_more_options: boolean = false;

  build() {
    Scroll() {
      Row({ space: 10 }) {
        dataBoard({
          label: $r('app.string.Debug_cpu'),
          data: this.data[4],
          symbol_glyph_target: 'sys.symbol.hardware',
          loop_execution: () => {
            if (!this.showing_more_options) {
              return
            }
            this.data[4] = (getCPU_sync() * 100).toFixed(2) + '%';
          }
        })
        dataBoard({
          label: $r('app.string.Debug_native_vram'),
          data: this.data[6],
          symbol_glyph_target: 'sys.symbol.hardware',
          loop_time: 5000,
          loop_execution: () => {
            if (!this.showing_more_options) {
              return
            }
            getVRAM().then(result => {
              this.data[6] = add_units_to_size(result);
            })
          }
        })
        dataBoard({
          label: $r('app.string.Debug_physical_ram'),
          data: this.data[0],
          symbol_glyph_target: 'sys.symbol.archivebox',
          loop_execution: () => {
            if (!this.showing_more_options) {
              // Saves performance and battery, maybe
              return
            }
            getPss().then(result => {
              this.data[0] = add_units_to_size(result * 1024n);
            })
          }
        })
        dataBoard({
          label: $r('app.string.Debug_virtual_ram'),
          data: this.data[1],
          symbol_glyph_target: 'sys.symbol.archivebox_badge_clock',
          loop_execution: () => {
            if (!this.showing_more_options) {
              return
            }
            getVss().then(result => {
              // this.data[1] = add_units_to_size(result * 1024n);
              // Due to somewhat reason, this value returned is too large if its unit is KB
              // So Liny guess it's a mistake of documentation, hence it is not multiplied by 1024n
              // Assuming it's in Byte as unit.
              // TODO: consider further about unit of getVss().
              this.data[1] = add_units_to_size(result);
            })
          }
        })
        dataBoard({
          label: $r('app.string.Debug_native_heap'),
          data: this.data[5],
          symbol_glyph_target: 'sys.symbol.doc_zipper',
          loop_execution: () => {
            if (!this.showing_more_options) {
              return
            }
            this.data[5] = add_units_to_size(getNativeHeapSize_sync());
          }
        })
        dataBoard({
          label: $r('app.string.Debug_shared_dirty'),
          data: this.data[2],
          symbol_glyph_target: 'sys.symbol.rectangle_text_rectangle_portrait',
          loop_execution: () => {
            if (!this.showing_more_options) {
              return
            }
            getSharedDirty().then(result => {
              this.data[2] = add_units_to_size(result * 1024n);
            })
          }
        })
        dataBoard({
          label: $r('app.string.Debug_private_dirty'),
          data: this.data[3],
          symbol_glyph_target: 'sys.symbol.lock_text_rectangle_portrait',
          loop_execution: () => {
            if (!this.showing_more_options) {
              return
            }
            getPrivateDirty().then(result => {
              this.data[3] = add_units_to_size(result * 1024n);
            })
          }
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .align(Alignment.BottomEnd)
    .width('100%')
  }
}

export default meowDebug;

@Component
struct dataBoard {
  @Prop data: string = 'label';
  @Prop symbol_glyph_target: string | undefined = undefined;
  @Prop label: ResourceStr = 'label';
  loop_execution?: () => void;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @Prop loop_time: number = 1000;

  build() {
    Row({ space: 10 }) {
      if (this.symbol_glyph_target) {
        linysSymbol({
          symbol_glyph_target: this.symbol_glyph_target,
        })
          .margin({ left: 3 })
      }
      Column() {
        linysText({
          text: this.label,
        })
        linysText({
          text: this.data,
        })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .clickEffect(click_effect_default())
    .padding(10)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(12)
    .justifyContent(FlexAlign.Start)
    .onAppear(() => {
      setInterval(() => {
        if (this.loop_execution) {
          this.loop_execution();
        }
      }, this.loop_time)
    })
  }
}