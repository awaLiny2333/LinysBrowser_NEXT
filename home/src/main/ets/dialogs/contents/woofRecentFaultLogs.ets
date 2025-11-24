import { FaultLogger } from '@kit.PerformanceAnalysisKit';
// TODO: switch to https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hiappevent-watcher-crash-events-arkts
import { BusinessError } from '@kit.BasicServicesKit';
import lazy woofControlFrame from '../woofControlFrame';
import { copy } from '../../utils/clipboard_tools';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default } from '../../hosts/bunch_of_defaults';
import linysTextArea from '../../components/texts/linysTextArea';

@CustomDialog
struct woofRecentFaultLogs {
  controller: CustomDialogController;
  @State faultLogs: string[] = [];
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    woofControlFrame({
      title: $r('app.string.Fault_logs'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 10 }) {
          if (this.faultLogs.length == 0) {
            linysTextTitle({
              text: $r('app.string.Fault_logs_empty')
            })
            linysTextTitle({
              text: ' ¯\\_(ツ)_/¯ '
            })
              .opacity(0.7)
          } else {
            ForEach(this.faultLogs, (fault: string, index: number) => {
              faultItem({
                fault: fault,
                idx: index
              })
            })
          }
        }
        .alignItems(HorizontalAlign.Center)
      }
      .borderRadius(13.5)
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .onAppear(() => {
        this.get_fault_logs();
      })
    }
  }

  get_fault_logs() {
    this.faultLogs = [];
    try {
      FaultLogger.query(FaultLogger.FaultType.JS_CRASH).then(value => {
        if (value) {
          console.info("FaultLog length is " + value.length);
          let len: number = value.length;
          for (let i = 0; i < len; i++) {
            let this_fault: string[] = [];
            // this_fault.push("log: " + i)
            this_fault.push("Log pid: " + value[i].pid)
            this_fault.push("Log uid: " + value[i].uid)
            this_fault.push("Log type: " + value[i].type)
            this_fault.push("Log timestamp: " + value[i].timestamp +
              " (" + new Date(value[i].timestamp).toLocaleString() + ")")
            this_fault.push("Log reason: " + value[i].reason)
            this_fault.push("Log module: " + value[i].module)
            // this_fault.push("Log summary: " + value[i].summary)
            this_fault.push("Log text: " + value[i].fullLog)
            this.faultLogs.push(this_fault.join("\n"));
          }
        }
      });
    } catch (err) {
      console.error(`code: ${(err as BusinessError).code}, message: ${(err as BusinessError).message}`);
    }
  }
}

export default woofRecentFaultLogs;

@Component
struct faultItem {
  @Prop fault: string = 'meow meow meow wait a second meow!';
  @Prop idx: number;
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Edit
  @State copied: boolean = false;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Row() {
          linysTextTitle({ text: (this.idx + 1).toString() + "." })
        }
        .layoutWeight(this.preferred_hand_left_or_right == 'right' ? 1 : undefined)
        .animation(animation_default())

        linysCapsuleButton({
          text: this.copied ? " 󰆊 " : " 󰆝 "
        })
          .onClick(() => {
            this.copy_this();
          })
      }
      .alignItems(VerticalAlign.Bottom)
      .width('100%')

      linysTextArea({ text: this.fault, init_text: this.fault })
    }
  }

  copy_this() {
    this.copied = true;
    copy(this.fault);
  }
}
