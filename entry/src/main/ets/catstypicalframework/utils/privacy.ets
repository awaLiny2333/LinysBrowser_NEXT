import { privacyManager } from '@kit.AppGalleryKit';
import { meow, meowLevel } from './catsLogger';

export function getPrivacyPolicyLink(id: string) {
  try {
    const infos = privacyManager.getAppPrivacyMgmtInfo().privacyInfo;
    // Find target
    for (let i = 0; i < infos.length; i++) {
      if ((infos[i].id == id) && (infos[i].type == privacyManager.AppPrivacyLinkType.PRIVACY_STATEMENT_LINK)) {
        return infos[i].url;
      }
    }
  } catch (e) {
    meow(`privacyManager.getAppPrivacyMgmtInfo().privacyInfo failed: ${e}`, 'getPrivacyPolicyLink', meowLevel.ERROR);
  }
  return undefined;
}

export function getUserAgreementLink(id: string) {
  try {
    const infos = privacyManager.getAppPrivacyMgmtInfo().privacyInfo;
    // Find target
    for (let i = 0; i < infos.length; i++) {
      if ((infos[i].id == id) && (infos[i].type == privacyManager.AppPrivacyLinkType.USER_AGREEMENT_LINK)) {
        return infos[i].url;
      }
    }
  } catch (e) {
    meow(`privacyManager.getAppPrivacyMgmtInfo().privacyInfo failed: ${e}`, 'getUserAgreementLink', meowLevel.ERROR);
  }
  return undefined;
}