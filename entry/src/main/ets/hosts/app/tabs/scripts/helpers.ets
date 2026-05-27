import lazy { belongsToDomain } from "../../../../catstypicalframework/utils/url";
import lazy { adBlockExceptions, disableWebImages, disableWebImagesOnAllSites, disableWebImagesSites, disableWebJavaScripts, disableWebJavaScriptSites, disableWebJavaScriptsOnAllSites, forceWebDarkExceptions, forceWebDarkMode, useAdBlock } from "../settings";

export const viewableSchemes = ['http', 'https', 'resource', 'file', 'data', 'blob'];

/**
 * Determine if a URL should be forced to dark mode.
 * @param url The url.
 * @returns true or false.
 */
export function forceDark(url: string | undefined) {
  if (!url) {
    return true;
  }
  if (!forceWebDarkMode()) {
    return false;
  }
  const exc = forceWebDarkExceptions();
  for (const domain of exc) {
    if (belongsToDomain(url, domain)) {
      return false;
    }
  }
  return true;
}

/**
 * Determine if a URL should have images disabled.
 * @param url The url.
 * @returns true or false.
 */
export function disableImages(url: string | undefined) {
  if (!url) {
    return false;
  }
  if (!disableWebImages()) {
    return false;
  }
  if (disableWebImagesOnAllSites()) {
    return true;
  }
  const dis = disableWebImagesSites();
  for (const domain of dis) {
    if (belongsToDomain(url, domain)) {
      return true;
    }
  }
  return false;
}

/**
 * Determine if a URL should have JavaScript disabled.
 * @param url The url.
 * @returns true or false.
 */
export function disableJS(url: string | undefined) {
  if (!url) {
    return false;
  }
  if (!disableWebJavaScripts()) {
    return false;
  }
  if (disableWebJavaScriptsOnAllSites()) {
    return true;
  }
  const dis = disableWebJavaScriptSites();
  for (const domain of dis) {
    if (belongsToDomain(url, domain)) {
      return true;
    }
  }
  return false;
}

/**
 * Determine if a URL should have adblocker enabled.
 * @param url The url.
 * @returns true or false.
 */
export function enableAdBlocker(url: string | undefined) {
  if (!url) {
    return false;
  }
  if (!useAdBlock()) {
    return false;
  }
  const exc = adBlockExceptions();
  for (const domain of exc) {
    if (belongsToDomain(url, domain)) {
      return false;
    }
  }
  return true;
}
