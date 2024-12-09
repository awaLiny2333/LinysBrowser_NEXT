import linysText from '../components/linysText';
import { animation_default } from '../hosts/bunch_of_defaults';
import { resource_to_string } from '../utils/resource_tools';

@Component
struct meowCredits {
  @State credits_devs_and_users_resource: Resource = $r("app.string.Credits_devs_and_users");
  @State credits_devs_and_users: string = resource_to_string(this.credits_devs_and_users_resource);
  @State credits_devs_and_users_list: string[] = this.credits_devs_and_users.split('\n');
  @State credits_repos_and_projs_resource: Resource = $r("app.string.Credits_repos_and_projs");
  @State credits_repos_and_projs: string = resource_to_string(this.credits_repos_and_projs_resource);
  @State credits_repos_and_projs_list: string[] = this.credits_repos_and_projs.split('\n');

  build() {
    Column({ space: 15 }) {
      Column({ space: 8 }) {
        linysText({
          text: $r('app.string.Credits')
        })

        ForEach(this.credits_repos_and_projs_list, (text: string, index: number) => {
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

      Column({ space: 8 }) {
        linysText({
          text: $r('app.string.Credits_issues')
        })

        ForEach(this.credits_devs_and_users_list, (text: string, index: number) => {
          linysText({
            text: text,
            max_lines: 48
          })
            .opacity(0.8)
        })
        linysText({
          text: $r("app.string.Credits_extra"),
          max_lines: 6
        })
          .opacity(0.8)
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
    .width("100%")
  }

  /**
   * Convert the Resource to string again.
   *
   * Usually called to deal with the change of language.
   * */
  update_resource_string() {
    this.credits_devs_and_users = resource_to_string(this.credits_devs_and_users_resource);
    this.credits_devs_and_users_list = this.credits_devs_and_users.split('\n');
    this.credits_repos_and_projs = resource_to_string(this.credits_repos_and_projs_resource);
    this.credits_repos_and_projs_list = this.credits_repos_and_projs.split('\n');
  }
}

export default meowCredits;