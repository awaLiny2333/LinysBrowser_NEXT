import linysCapsuleButton from '../components/linysCapsuleButton';
import linysText from '../components/linysText';
import woofUpdateHistory from '../dialogs/woofUpdateHistory';
import { animation_default } from '../hosts/bunch_of_defaults';
import { resource_to_string } from '../utils/resource_tools';

@Component
struct meowWhatsNew {
  @State new_things_resource: Resource = $r("app.string.Whats_new_content");
  @State new_things: string = resource_to_string(this.new_things_resource);
  @State new_things_list: string[] = this.new_things.split('\n');
  update_history: CustomDialogController = new CustomDialogController({
    builder: woofUpdateHistory(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });

  build() {
    Column({ space: 8 }) {
      linysText({
        text: $r('app.string.Whats_new')
      })
      ForEach(this.new_things_list, (text: string, index: number) => {
        Row({ space: 5 }) {
          linysText({ text: (index+1).toString() + '.' })
          linysText({
            text: text,
            max_lines: 48
          })
            .opacity(0.8)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      })
      linysText({
        text: $r("app.string.Whats_new_content_extra"),
        max_lines: 6
      })
        .opacity(0.8)
      Row({ space: 10 }) {
        Blank()
        linysText({ text: $r('app.string.Update_record') })
        linysCapsuleButton({ text: "  󰀩  " })
          .onClick(() => {
            this.update_history.open();
          })
      } // Update history
      .width("100%")
    }
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .borderRadius(13.5)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width("100%")
    .animation(animation_default())
    .onAreaChange(() => {
      this.update_resource_string();
    })
  }

  /**
   * Convert the Resource to string again.
   *
   * Usually called to deal with the change of language.
   * */
  update_resource_string() {
    this.new_things = resource_to_string(this.new_things_resource);
    this.new_things_list = this.new_things.split('\n');
  }
}

export default meowWhatsNew;