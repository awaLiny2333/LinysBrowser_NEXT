import linysText from '../../components/texts/linysText';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { resource_to_string } from '../../utils/resource_tools';
import { common } from '@kit.AbilityKit';

@Component
struct meowCreditsRepos {
  credits_repos_and_projs_resource: Resource = $r("app.string.Credits_repos_and_projs");
  credits_repos_and_projs: string = resource_to_string(this.credits_repos_and_projs_resource);
  credits_repos_and_projs_list: string[] = this.credits_repos_and_projs.split('\n');

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
  }
}

export default meowCreditsRepos;
