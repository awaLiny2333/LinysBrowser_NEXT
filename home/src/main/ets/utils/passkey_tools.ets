import { BusinessError } from '@kit.BasicServicesKit';
import { UIContext } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fido2 } from '@kit.OnlineAuthenticationKit';

let uiContext1: UIContext | undefined;
let uiContext: common.UIAbilityContext | undefined;
let clientCapabilities: Map<fido2.ClientCapability, boolean> | undefined;
let platformAuthenticators: Array<fido2.AuthenticatorMetadata> | undefined;

export function init_passkey(meowUiContext: UIContext) {
  uiContext1 = meowUiContext;
  uiContext = uiContext1.getHostContext() as common.UIAbilityContext;

  // Get Client Capabilities
  fido2.getClientCapabilities(uiContext).catch((error: BusinessError) => {
    let message = (error as BusinessError).message;
    let code = (error as BusinessError).code;
    console.error(`[Passkey] Failed to call getClientCapabilities error code is ${code}, message is ${message}`);
  }).then((result) => {
    if (result) {
      clientCapabilities = result;
      console.info("[Passkey] Succeeded in doing getClientCapabilities.");
    }
  });

  // 获取平台认证器能力
  fido2.getPlatformAuthenticators(uiContext).catch((error: BusinessError) => {
    let message = (error as BusinessError).message;
    let code = (error as BusinessError).code;
    console.error(`[Passkey] Failed to call getPlatformAuthenticators error code is ${code}, message is ${message}`);
    // 业务根据错误码判断异常类型，进行相应处理，详见错误码参考
  }).then((result) => {
    if (result) {
      platformAuthenticators = result;
      console.info("[Passkey] Succeeded in doing getPlatformAuthenticators.");
    }
  });
}

export async function register(pkOptions: fido2.PublicKeyCredentialCreationOptions) {
  try {
    let credentialCreationOp: fido2.CredentialCreationOptions = {
      publicKey: pkOptions // pkOptions 为从FIDO服务器获取的注册报文
    } // credentialCreationOp 为应用组装的注册信息

    let publicKeyAttestationCredential: fido2.PublicKeyAttestationCredential = await fido2.register(uiContext, credentialCreationOp); // 进行FIDO2注册
    console.info("Succeeded in doing register.");
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to call discover. Code is ${err.code}, message is ${err.message}`);
  }
}

export async function authenticate(authPub: fido2.PublicKeyCredentialRequestOptions) {
  try {
    let authCredentialRequestOptions: fido2.CredentialRequestOptions = {
      publicKey: authPub, // authPub 为从FIDO服务器获取的认证报文
      mediation: "optional" as fido2.CredentialMediationRequirement //
    } // authCredentialRequestOptions 为应用组装的认证信息

    let pkAssertionCredential: fido2.PublicKeyAssertionCredential = await fido2.authenticate(uiContext, authCredentialRequestOptions); // 进行FIDO2认证
    console.info("Succeeded in doing authenticate.");
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to call discover. Code is ${err.code}, message is ${err.message}`);
  }
}