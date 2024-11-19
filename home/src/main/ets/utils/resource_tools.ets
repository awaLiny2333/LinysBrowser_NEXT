import { common } from "@kit.AbilityKit";

/**
 * Analyses a ResourceStr and converts it to a string object.
 * @param resourceStr A Resource, indicating the identifier of the ResourceStr.
 * @returns A string, the string content retrieved.
 * @example resource_to_string($r('app.string.Whats_new_content_1'))
 * */
export function resource_to_string(resourceStr: Resource) {
  let context = AppStorage.get('context') as common.UIAbilityContext;
  return context.resourceManager.getStringSync(resourceStr);
}