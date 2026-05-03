import { meowLayout } from '../../../../catstypicalframework/hosts/meowLayout';
import { standardSpacing } from '../../../../components/settings';
import { userCredits } from '../creditDetails';
import { CreditUser } from './CreditUser';

@ComponentV2
struct UserCredits {
  @Param @Require myLayout: meowLayout;

  build() {
    // The list
    List({ space: standardSpacing }) {
      ListItem(); // push the padding
      Repeat(userCredits)
        .each((item) => {
          CreditUser({
            myLayout: this.myLayout,
            details: item.item
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
