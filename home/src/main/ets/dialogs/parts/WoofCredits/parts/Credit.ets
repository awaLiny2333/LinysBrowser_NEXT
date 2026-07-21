import { standardSpacing } from '../../../../components/constants';
import { meowUiHost } from '../../../../hosts/system/windows/classes/meowUiHost';
import { userCredits } from '../creditDetails';
import { CreditUser } from './CreditUser';

@ComponentV2
struct UserCredits {
  @Param @Require myUi: meowUiHost;
  // Events
  @Event requestVisit: (url: string) => void;

  build() {
    // The list
    List({ space: standardSpacing }) {
      ListItem(); // push the padding
      Repeat(userCredits)
        .each((item) => {
          CreditUser({
            myUi: this.myUi,
            details: item.item,
            requestVisit: (url) => {
              this.requestVisit(url);
            }
          });
        })
        .virtualScroll();
      ListItem(); // push the padding
    }
    .width('100%')
    .height('auto');
  }
}

export { UserCredits };
