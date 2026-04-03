import common from '@ohos.app.ability.common';
import { meow, meowLevel } from './catsLogger';

/**
 * Jumps to a link, calling the default browser.
 * */
export default function openLink(link: string, context: common.UIAbilityContext) {
  context.openLink(link)
    .catch((e: BusinessError) => {
      meow(`context.openLink(${link}) Failed: ${e}`, 'openLink', meowLevel.ERROR);
    })
}