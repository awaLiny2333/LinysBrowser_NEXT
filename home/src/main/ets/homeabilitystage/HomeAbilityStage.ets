import { AbilityStage, Want } from '@kit.AbilityKit';

export default class HomeAbilityStage extends AbilityStage {
  onAcceptWant(want: Want): string {
    let instanceKey = '';
    let windowIds: string[] | undefined = AppStorage.get('windowIds');

    if (want.parameters) {
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
    }
    // So that HomeAbility class could read and use this as window id.
    AppStorage.setOrCreate('LAST_WINDOW_INSTANCE_KEY', instanceKey);

    // Report back
    return instanceKey;
  }
}