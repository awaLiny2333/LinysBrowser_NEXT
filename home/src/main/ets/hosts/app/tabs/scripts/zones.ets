import lazy { common } from "@kit.AbilityKit";
import lazy { fastbuffer } from "@kit.ArkTS";
import lazy { AppStorageV2, UIContext } from "@kit.ArkUI";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { dirMove, listFilesUnderDir, readArrayBuffer, removeDir, renameFolder } from "../../../../catstypicalframework/utils/storage";
import lazy { meowUiHost } from "../../../system/windows/classes/meowUiHost";
import lazy { getCreateMyApp } from "../../../system/windows/scripts/helpers";
import lazy { globalMessage, meowAppMessageType } from "../../../system/windows/scripts/messaging";
import lazy { generateTimeBasedWindowId, newOrCallWindow } from "../../../system/windows/scripts/multiwindows";

/**
 * Discovers zones from the disk.
 * @returns The zones list, or undefined if something went wrong.
 */
export async function discoverZones() {
  const context = UIContext.getLastFocusedUIContext()?.getHostContext();
  if (!context) {
    meow(`No UI context found.`, 'discoverZones', meowLevel.ERROR);
    return undefined;
  }

  const filesDir = context.filesDir;
  const zonesDir = `${filesDir}/zones`;
  const zones = await listFilesUnderDir(zonesDir);
  return zones;
}

/**
 * Glimpses on a zone. Get the first three labels of tabs in that zone
 * @param zoneAlias The alias of the zone.
 * @returns The labels of the tabs in that zone. Undefined if something went wrong.
 */
export async function glimpseOnZone(zoneAlias: string) {
  const context = UIContext.getLastFocusedUIContext()?.getHostContext();
  if (!context) {
    meow(`No UI context found.`, 'discoverZones', meowLevel.ERROR);
    return undefined;
  }

  const filesDir = context.filesDir;
  const zoneDir = `${filesDir}/zones/${zoneAlias}`;
  const filenames = await listFilesUnderDir(zoneDir);

  if (filenames == undefined) {
    return undefined;
  }

  const labels: string[] = [];
  for (const fn of filenames) {
    if (!fn.endsWith('el')) {
      continue; // For '_label'
    }
    try {
      const content = fastbuffer.from(await readArrayBuffer(`${zoneDir}/${fn}`)).toString();
      labels.push(content);
    } catch (e) {
      meow(`Failed to read file ${fn} in zone ${zoneAlias}: ${e}`, 'glimpseOnZone', meowLevel.ERROR);
    }
    if (labels.length >= 3) {
      break;
    }
  }
  return labels;
}

/**
 * Deletes a zone from the disk.
 * @param zoneAlias The alias of the zone.
 */
export async function deleteZone(zoneAlias: string) {
  const context = UIContext.getLastFocusedUIContext()?.getHostContext();
  if (!context) {
    meow(`No UI context found.`, 'deleteZone', meowLevel.ERROR);
    return false;
  }

  // Reject if zone is opened.
  if (await isZoneOpened(zoneAlias)) {
    meow(`Zone ${zoneAlias} is opened.`, 'deleteZone', meowLevel.WARN);
    return false;
  }

  const zoneDir = `${context.filesDir}/zones/${zoneAlias}`;
  await removeDir(zoneDir);

  // Broadcast
  globalMessage(meowAppMessageType.ZONES_REFRESH);
  return true;
}

/**
 * Opens a zone.
 * @param zoneAlias The alias of the zone.
 */
export async function openZone(zoneAlias: string) {
  const context = UIContext.getLastFocusedUIContext()?.getHostContext();
  if (!context) {
    meow(`No UI context found.`, 'deleteZone', meowLevel.ERROR);
    return;
  }

  // Reject if zone is opened already.
  const thatWindowId = await isZoneOpened(zoneAlias);
  if (thatWindowId) {
    meow(`Zone [${zoneAlias}] is already opened. Jumping to [${thatWindowId}]`, 'openZone', meowLevel.WARN);
  }

  await newOrCallWindow(context as common.UIAbilityContext, thatWindowId || generateTimeBasedWindowId(), zoneAlias);
}

/**
 * Checks if a zone is opened, and returns the windowId if it is.
 * @param zoneAlias The alias of the zone.
 * @returns The zone's windowId if the zone is opened, false otherwise.
 */
export async function isZoneOpened(zoneAlias: string) {
  const myApp = getCreateMyApp();
  for (const wId of myApp.windowIds) {
    const thatUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${wId}`);
    if (!thatUi || !thatUi.isZone) {
      continue;
    }
    if (thatUi.windowAlias == zoneAlias) {
      // meow(`Zone [${zoneAlias}] is opened.`, 'isZoneOpened', meowLevel.WARN);
      return thatUi.windowId;
    }
  }
  return false;
}

/**
 * Checks if a zone can be renamed to the given alias.
 * @param testZoneAlias The alias to test.
 * @returns True if the zone can be renamed, false otherwise.
 */
export async function canRenameZoneTo(testZoneAlias: string) {
  const allZones = await discoverZones();
  if (!allZones) {
    return false;
  }
  return !allZones.includes(testZoneAlias);
}

/**
 * Enables the zone mode for the given UI.
 * @param myUi The meowUiHost.
 */
export async function enZone(myUi: meowUiHost) {
  const startTime = Date.now();
  const context = UIContext.getLastFocusedUIContext()?.getHostContext();
  if (!context) {
    meow(`No UI context found.`, 'enZone', meowLevel.ERROR);
    return false;
  }

  // Reject duplicate names
  if (await canRenameZoneTo(myUi.windowAlias) == false) {
    meow(`Zone name [${myUi.windowAlias}] already taken.`, 'enZone', meowLevel.WARN);
    return false;
  }

  // Reject if busy
  const myTabs = myUi.myTabs;
  if (myTabs.isBusy) {
    meow(`Zone ${myUi.windowAlias} is busy.`, 'enZone', meowLevel.WARN);
    return false;
  }

  // Move
  const newWorkingDirParent = `${context.filesDir}/zones`;
  const oldWorkingDir = myUi.workingDir;
  await dirMove(oldWorkingDir, newWorkingDirParent, false);

  // Rename
  const originalWorkingDirName = oldWorkingDir.split('/').pop();
  const wDirAfterMove = `${newWorkingDirParent}/${originalWorkingDirName}`;
  const newWorkingDir = `${newWorkingDirParent}/${myUi.windowAlias}`;
  await renameFolder(wDirAfterMove, newWorkingDir);

  // Set Info
  myUi.workingDir = newWorkingDir;
  myUi.isZone = true;
  await myUi.updateWindowTitle();

  // Broadcast
  globalMessage(meowAppMessageType.ZONES_REFRESH);
  meow(`Zone ${myUi.windowAlias} is enabled. (${Date.now() - startTime} ms)`, 'enZone', meowLevel.INFO);
  return true;
}

/**
 * Disables the zone mode for the given UI.
 * @param myUi The meowUiHost.
 */
export async function deZone(myUi: meowUiHost) {
  const startTime = Date.now();
  const context = UIContext.getLastFocusedUIContext()?.getHostContext();
  if (!context) {
    meow(`No UI context found.`, 'deZone', meowLevel.ERROR);
    return false;
  }

  // Reject if busy
  const myTabs = myUi.myTabs;
  if (myTabs.isBusy) {
    meow(`Zone ${myUi.windowAlias} is busy.`, 'deZone', meowLevel.WARN);
    return false;
  }

  // Move
  const newWorkingDirParent = `${context.filesDir}/continues`;
  const oldWorkingDir = myUi.workingDir;
  await dirMove(oldWorkingDir, newWorkingDirParent, false);

  // Rename
  const originalWorkingDirName = oldWorkingDir.split('/').pop();
  const wDirAfterMove = `${newWorkingDirParent}/${originalWorkingDirName}`;
  const newWorkingDir = `${newWorkingDirParent}/${myUi.windowId}`;
  await renameFolder(wDirAfterMove, newWorkingDir);

  // Set Info
  myUi.workingDir = newWorkingDir;
  myUi.isZone = false;
  await myUi.updateWindowTitle();

  // Broadcast
  globalMessage(meowAppMessageType.ZONES_REFRESH);
  meow(`Zone ${myUi.windowAlias} is disabled. (${Date.now() - startTime} ms)`, 'deZone', meowLevel.INFO);
  return true;
}
