import { meowContext } from "./environment_tools";

/**
 * Analyses a ResourceStr and converts it to a string object.
 * @param resourceStr A Resource, indicating the identifier of the ResourceStr.
 * @returns A string, the string content retrieved.
 * @example resource_to_string($r('app.string.Whats_new_content_1'))
 * */
export function resource_to_string(resourceStr: Resource) {
  return meowContext().resourceManager.getStringSync(resourceStr);
}