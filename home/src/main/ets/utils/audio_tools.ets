import lazy { audio } from '@kit.AudioKit';
import lazy { BusinessError } from '@kit.BasicServicesKit';

export function activate_mix_audio_session() {
  let audioManager = audio.getAudioManager();
  let audioSessionManager: audio.AudioSessionManager = audioManager.getSessionManager();

  let strategy: audio.AudioSessionStrategy = {
    concurrencyMode: audio.AudioConcurrencyMode.CONCURRENCY_MIX_WITH_OTHERS
  };

  audioSessionManager.activateAudioSession(strategy).then(() => {
    console.info('[activate_mix_audio_session] Succeeded in doing activateAudioSession! CONCURRENCY_MIX_WITH_OTHERS!');
  }).catch((err: BusinessError) => {
    console.error(`[activate_mix_audio_session] Failed to activateAudioSession (CONCURRENCY_MIX_WITH_OTHERS). Code: ${err.code}, message: ${err.message}`);
  });
}