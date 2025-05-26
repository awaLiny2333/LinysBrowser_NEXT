import linysText from '../../components/texts/linysText';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { resource_to_string } from '../../utils/resource_tools';

@Component
struct meowCreditsRepos {
  @State credits_repos_and_projs_resource: Resource = $r("app.string.Credits_repos_and_projs");
  @State credits_repos_and_projs: string = resource_to_string(this.credits_repos_and_projs_resource);
  @State credits_repos_and_projs_list: string[] = this.credits_repos_and_projs.split('\n');

  build() {
    Column({ space: 8 }) {
      linysText({
        text: $r('app.string.Credits'),
        max_lines: 3
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
  }

  /**
   * Convert the Resource to string again.
   *
   * Usually called to deal with the change of language.
   * */
  update_resource_string() {
    this.credits_repos_and_projs = resource_to_string(this.credits_repos_and_projs_resource);
    this.credits_repos_and_projs_list = this.credits_repos_and_projs.split('\n');
  }
}

export default meowCreditsRepos;
