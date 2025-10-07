import { meowContext } from './environment_tools';

/**
 * Analyses a ResourceStr and converts it to a string object.
 * @param resourceStr A Resource, indicating the identifier of the ResourceStr.
 * @returns A string, the string content retrieved.
 * @example resource_to_string($r('app.string.Whats_new_content_1'))
 * */
export function resource_to_string(resourceStr: Resource, context?: Context) {
  try {
    if (context) {
      return context.resourceManager.getStringSync(resourceStr);
    }
      return meowContext().resourceManager.getStringSync(resourceStr);
    // TODO: replace deprecated getStringSync when api20 is eventually released
  } catch (error) {
    console.error('[resource_to_string] ' + error);
    return 'meow Error!';
  }
}