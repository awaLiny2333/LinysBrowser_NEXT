import { wantAgent, WantAgent } from "@kit.AbilityKit";
import { UIContext } from "@kit.ArkUI";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { notificationManager } from "@kit.NotificationKit";
import { openDialogRequestType } from "../../hosts/system/dialogs/classes/meowDialogManager";
import { getAbilityName, getBundleName } from "./environment";
import { toast } from "./ui";

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
      // context = application.getApplicationContext();
      context = UIContext.getAllUIContexts()[0].getHostContext();
    } catch (e) {
      console.warn('[requestBackgroundDataTransfer] Rejected for context cannot get.');
      return;
    }
  }

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
    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      try {
        let list: Array<string> = ["dataTransfer"];
        backgroundTaskManager.startBackgroundRunning(context, list, wantAgentObj).then((res: backgroundTaskManager.ContinuousTaskNotification) => {
          console.warn("[requestBackgroundDataTransfer] Operation startBackgroundRunning succeeded");
          backgroundNotificationId = res.notificationId;
          backgroundTaskId = res.continuousTaskId;
        }).catch((error: BusinessError) => {
          console.error(`[requestBackgroundDataTransfer] Operation startBackgroundRunning failed A. code is ${error.code} message is ${error.message}`);
        });
      } catch (error) {
        console.error(`[requestBackgroundDataTransfer] Operation startBackgroundRunning failed B. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
      }
    })
      .catch((error: BusinessError) => {
        console.error(`[requestBackgroundDataTransfer] Operation wantAgent.getWantAgent(wantAgentInfo) failed. code is ${error.code} message is ${error.message}`);
      });
  } catch (error) {
    console.error(`[requestBackgroundDataTransfer] Operation getWantAgent failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
  }
}

// 当长时任务类型包含数据传输(dataTransfer)时，应用需要更新进度，其他类型不需要
export async function updateBackgroundDataTransferProcess(title: string, fileName: string, text: string, process: number) {
  if (backgroundTaskId === undefined) {
    return;
  }

  // 定义通知类型，更新进度时的通知类型必须为实况窗
  let downLoadTemplate: notificationManager.NotificationTemplate = {
    name: 'downloadTemplate', // 当前只支持downloadTemplate，保持不变
    data: {
      title: title, // 必填
      fileName: fileName, // 必填
      progressValue: process, // 应用更新进度值，自定义
    }
  };
  let request: notificationManager.NotificationRequest = {
    content: {
      // 系统实况类型，保持不变
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
      systemLiveView: {
        typeCode: 8, // 数据传输(dataTransfer)类型需要填写 8，当前仅支持此类型。保持不变
        title: title, // 应用自定义
        text: text, // 应用自定义
      }
    },
    id: backgroundNotificationId, // 必须是申请长时任务返回的id，否则应用更新通知失败
    notificationSlotType: notificationManager.SlotType.LIVE_VIEW, // 实况窗类型，保持不变
    template: downLoadTemplate // 应用需要设置的模版名称
  };

  try {
    await notificationManager.publish(request).then(() => {
      console.info("[updateBackgroundDataTransferProcess] publish success, id= " + backgroundNotificationId);
    }).catch((err: BusinessError) => {
      console.error(`[updateBackgroundDataTransferProcess] publish fail: ${JSON.stringify(err)}`);
    });
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
      // context = application.getApplicationContext();
      context = UIContext.getAllUIContexts()[0].getHostContext();
    } catch (e) {
      console.warn('[stopBackgroundDataTransfer] Rejected for get context failed.');
      return;
    }
  }

  toast('wtf');

  try {
    await backgroundTaskManager.stopBackgroundRunning(context, backgroundTaskId).then(() => {
      console.warn("[stopBackgroundDataTransfer] Operation stopBackgroundRunning succeeded");
      backgroundNotificationId = undefined;
      backgroundTaskId = undefined;
    }).catch((error: BusinessError) => {
      console.error(`[stopBackgroundDataTransfer] Operation stopBackgroundRunning failed. code is ${error.code} message is ${error.message}`);
    });
  } catch (error) {
    console.error(`[stopBackgroundDataTransfer] Operation stopBackgroundRunning failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
  }
}
