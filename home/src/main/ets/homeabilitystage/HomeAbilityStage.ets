import { AbilityStage, Want } from '@kit.AbilityKit';

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
          let focus_window_id = AppStorage.get('THE_FOCUS_OF_THE_WINDOWS') as string;
          if (focus_window_id == '') {
            // That window is closed;
            instanceKey = windowIds[windowIds.length-1];
          } else {
            // Give want to that window.
            instanceKey = focus_window_id;
          }
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