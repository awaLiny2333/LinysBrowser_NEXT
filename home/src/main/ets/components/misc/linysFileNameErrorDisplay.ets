import { animation_default } from "../../hosts/bunch_of_defaults";
import linysText from "../texts/linysText";

@Component
struct linysFileNameErrorDisplay {
  @Prop file_name: string = 'uwu';
  @Prop error_code: number = 0;
  chars: string[] = ['', '', '\\', '/', ':', '*', '?', '\'', '<', '>', '|'];

  build() {
    Column({ space: 10 }) {
      linysText({
        text: $r('app.string.Index_downloads_illegal_chars_in_filename'),
        max_lines: 3,
        is_description: true,
        is_expanded: true
      }) // File name error prompt
        .visibility(this.error_code > 0 ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      Row() {
        linysText({
          text: $r('app.string.Index_downloads_filename_length'),
          max_lines: 3,
        })
        linysText({
          text: this.file_name.length.toString(),
          max_lines: 3,
        })
      } // File name too long
      .visibility(this.error_code == 1 ? Visibility.Visible : Visibility.None)
      .animation(animation_default())

      Row() {
        linysText({
          text: $r('app.string.Index_downloads_filename_illegal'),
          max_lines: 3,
        })
        linysText({
          text: this.chars[this.error_code],
          max_lines: 3,
        })
      } // File name illegal
      .visibility(this.error_code >= 2 ? Visibility.Visible : Visibility.None)
      .animation(animation_default())
    }
    .visibility(this.error_code > 0 ? Visibility.Visible : Visibility.None)
    .alignItems(HorizontalAlign.Start)
  }
}

export default linysFileNameErrorDisplay