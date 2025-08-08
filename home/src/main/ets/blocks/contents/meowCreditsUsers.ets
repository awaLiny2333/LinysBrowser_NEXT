import linysText from '../../components/texts/linysText';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { resource_to_string } from '../../utils/resource_tools';

@Component
struct meowCreditsUsers {
  @State credits_devs_and_users_resource: Resource = $r("app.string.Credits_devs_and_users");
  @State credits_devs_and_users: string = resource_to_string(this.credits_devs_and_users_resource);
  @State credits_devs_and_users_list: string[] = this.credits_devs_and_users.split('\n');

  build() {
    Scroll() {
      Column({ space: 8 }) {
        linysText({
          text: $r('app.string.Credits_issues'),
          max_lines: 10
        })

        ForEach(this.credits_devs_and_users_list, (text: string, index: number) => {
          linysText({
            text: text,
            max_lines: 48
          })
            .opacity(0.8)
        })
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
    // .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
    .width("100%")
    .height(180)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .borderRadius(13.5)
    .animation(animation_default())

  }

  /**
   * Convert the Resource to string again.
   *
   * Usually called to deal with the change of language.
   * */
  update_resource_string() {
    this.credits_devs_and_users = resource_to_string(this.credits_devs_and_users_resource);
    this.credits_devs_and_users_list = this.credits_devs_and_users.split('\n');
  }
}

export default meowCreditsUsers;
