import { AbilityStage, Want } from '@kit.AbilityKit';
import { meow, meowLevel } from '../catstypicalframework/utils/catsLogger';
import { getMyApp } from '../hosts/system/windows/scripts/helpers';
import { generateTimeBasedWindowId } from '../hosts/system/windows/scripts/multiwindows';

export default class EntryAbilityStage extends AbilityStage {
  onCreate(): void {
    meow('EntryAbilityStage.onCreate()', 'EntryAbilityStage', meowLevel.WARN);
  }

  onAcceptWant(want: Want): string {
    let instanceKey: string;

    if (!want.parameters) {
      // Something's wrong :P
      instanceKey = generateTimeBasedWindowId();
      meow(`onAcceptWant: want.parameters is undefined... But no worries, we have generated a new window id [${instanceKey}]!`, 'Meow][HomeAbility][onAcceptWant', meowLevel.WARN);
    } else {
      // Normal cases
      let wantKey = want.parameters.instanceKey as string;
      if (wantKey) {
        // USER-CREATED new window.
        instanceKey = wantKey;
        meow(`User created new window! instanceKey = [${instanceKey}]`, 'Meow][HomeAbility][onAcceptWant', meowLevel.WARN);
      } else {
        // SYSTEM-CREATED new window.
        let windowIds: string[] = getMyApp().windowIds;
        if (windowIds.length > 0) {
          // Call the last of the already opened windows. Give want to that window.
          instanceKey = getMyApp().lastFocusedWindowId;
          meow(`Key is undefined. We have existing windows [${windowIds.join(', ')}] and let's give want to [${instanceKey}]`, 'Meow][HomeAbility][onAcceptWant', meowLevel.WARN);
        } else {
          // InstanceKey for the very first window of the entire app.
          instanceKey = generateTimeBasedWindowId();
          meow(`Key is undefined and this is FIRST launch! Set instanceKey = [${instanceKey}]`, 'Meow][HomeAbility][onAcceptWant', meowLevel.WARN);
        }
      }
    }

    getMyApp().lastCreatedInstanceKey = instanceKey; // So that the flow in EntryAbility can grab this key and use it as its windowId.

    return instanceKey;
  }
}
