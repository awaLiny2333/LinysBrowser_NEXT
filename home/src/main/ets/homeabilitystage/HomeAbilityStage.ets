import { AbilityStage, Want } from '@kit.AbilityKit';
import { default_new_window_name } from '../hosts/bunch_of_defaults';

export default class HomeAbilityStage extends AbilityStage {
  onCreate(): void {
    AppStorage.setOrCreate('context', this.context);
  }

  onAcceptWant(want: Want): string {
    let instanceKey = '';
    let windowIds: string[] | undefined = AppStorage.get('windowIds');

    if (want.parameters) {
      // instanceKey
      let key = want.parameters.instanceKey;
      if (key) {
        // Specially call for a new window.
        console.log('[Meow][HomeAbility][onAcceptWant]! Key = [' + key + ']');
        instanceKey = 'Meow_' + key;
      } else {
        console.log('[Meow][HomeAbility][onAcceptWant]! Key is undefined.');
        if (windowIds) {
          // Call the last of the already opened windows.
          instanceKey = windowIds[windowIds.length-1];
        } else {
          // Initial key for the very first window of the entire app.
          instanceKey = 'Meow_meow';
        }
      }

      // windowName
      let name = AppStorage.get('LAST_WINDOW_WINDOW_NAME') as string;
      if (!name) {
        // This actually works???
        AppStorage.setOrCreate('LAST_WINDOW_WINDOW_NAME', default_new_window_name());
      }
    }
    // So that HomeAbility class could read and use this as window id.
    AppStorage.setOrCreate('LAST_WINDOW_INSTANCE_KEY', instanceKey);

    // Report back
    return instanceKey;
  }
}