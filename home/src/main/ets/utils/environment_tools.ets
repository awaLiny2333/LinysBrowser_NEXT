import { common } from '@kit.AbilityKit';

/**
 * Retrieves the context from AppStorage.
 * @returns common.UIAbilityContext
 * */
export function meowContext(): common.UIAbilityContext {
  return AppStorage.get('context') as common.UIAbilityContext;
}