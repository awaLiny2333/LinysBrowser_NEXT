import { wantAgent } from "@kit.AbilityKit";
import { UIContext } from "@kit.ArkUI";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { notificationManager } from "@kit.NotificationKit";
import { openDialogRequestType } from "../../hosts/system/dialogs/classes/meowDialogManager";
import { getAbilityName, getBundleName } from "./environment";

export let backgroundNotificationId: number | undefined = undefined; // Notification ID.
export let backgroundTaskId: number | undefined = undefined; // Task ID.

export function isBackgroundDataTransferRunning() {
  return backgroundTaskId !== undefined;
}

export async function requestBackgroundDataTransfer(context?: Context) {
  if (backgroundTaskId !== undefined) {
    console.warn('[requestBackgroundDataTransfer] Rejected for duplicated task existing.');
    return;
  }

  if (!context) {
    try {
      context = UIContext.getAllUIContexts()[0].getHostContext();
    } catch (e) {
      console.warn('[requestBackgroundDataTransfer] Rejected for context cannot get.');
      return;
    }
  }

  // Construct wantAgentInfos.
  const bN = await getBundleName();
  const aN = await getAbilityName();
  let wantAgentInfo: wantAgent.WantAgentInfo = {
    wants: [
      {
        bundleName: bN,
        abilityName: aN,
        parameters: {
          meowTarget: openDialogRequestType.DOWNLOADS
        }
      }
    ],
    actionType: wantAgent.OperationType.START_ABILITY,
    requestCode: 233
  };

  try {
    // Get wantAgent.
    const wantAgentObj = await wantAgent.getWantAgent(wantAgentInfo);
    // Start background task.
    await backgroundTaskManager.startBackgroundRunning(context, ["dataTransfer"], wantAgentObj)
      .then((res: backgroundTaskManager.ContinuousTaskNotification) => {
        console.warn("[requestBackgroundDataTransfer] Operation startBackgroundRunning succeeded");
        backgroundNotificationId = res.notificationId;
        backgroundTaskId = res.continuousTaskId;
      });
  } catch (error) {
    console.error(`[requestBackgroundDataTransfer] Operation getWantAgent failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
  }
}

/**
 * Updates the download progress for the background task.
 * @param title The title of the notification.
 * @param fileName The file name (in fact the sub title) of the notification.
 * @param text The text (didn't see anywhere O.o) of the notification.
 * @param progress The progress ${progress}% of download.
 */
export async function updateBackgroundDataTransferProcess(title: string, fileName: string, text: string, progress: number) {
  if (backgroundTaskId === undefined) {
    return;
  }

  let downLoadTemplate: notificationManager.NotificationTemplate = {
    name: 'downloadTemplate',
    data: {
      title: title,
      fileName: fileName,
      progressValue: progress,
    }
  };
  let request: notificationManager.NotificationRequest = {
    content: {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW, // MUST use NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW.
      systemLiveView: {
        typeCode: 8, // dataTransfer REQUIRES an 8 for this field.
        title: title,
        text: text, // No use?
      }
    },
    id: backgroundNotificationId,
    notificationSlotType: notificationManager.SlotType.LIVE_VIEW,
    template: downLoadTemplate
  };

  try {
    await notificationManager.publish(request);
    console.info("[updateBackgroundDataTransferProcess] publish success, id= " + backgroundNotificationId);
  } catch (err) {
    console.error(`[updateBackgroundDataTransferProcess] publish fail: ${JSON.stringify(err)}`);
  }
}

export async function stopBackgroundDataTransfer(context?: Context) {
  if (backgroundTaskId === undefined) {
    console.warn('[stopBackgroundDataTransfer] Rejected for duplicated task existing.');
    return;
  }

  if (!context) {
    try {
      context = UIContext.getAllUIContexts()[0].getHostContext();
    } catch (e) {
      console.warn('[stopBackgroundDataTransfer] Rejected for get context failed.');
      return;
    }
  }

  try {
    await backgroundTaskManager.stopBackgroundRunning(context, backgroundTaskId);
    backgroundNotificationId = undefined;
    backgroundTaskId = undefined; // Release these locks.
    console.warn("[stopBackgroundDataTransfer] Operation stopBackgroundRunning succeeded");
  } catch (error) {
    console.error(`[stopBackgroundDataTransfer] Operation stopBackgroundRunning failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
  }
}
