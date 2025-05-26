import { FaultLogger } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import woofControlFrame from '../woofControlFrame';
import { copy } from '../../utils/clipboard_tools';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysTextTitle from '../../components/texts/linysTextTitle';

@CustomDialog
struct woofRecentFaultLogs {
  controller: CustomDialogController;
  @State faultLogs: string[] = [];

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
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Edit
  @State copied: boolean = false;

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        linysTextTitle({ text: (this.idx + 1).toString() + "." })
          .layoutWeight(1)
        linysCapsuleButton({
          text: this.copied ? " 󰆊 " : " 󰆝 "
        })
          .onClick(() => {
            this.copy_this();
          })
      }
      .alignItems(VerticalAlign.Bottom)
      .width('100%')

      TextArea({ text: this.fault })
        .fontWeight(FontWeight.Regular)
        .fontColor(this.color_current_font)
        .caretColor(this.color_current_font)
        .selectedBackgroundColor(this.color_current_font)
      // .height(200)
    }
  }

  copy_this() {
    this.copied = true;
    copy(this.fault);
  }
}
