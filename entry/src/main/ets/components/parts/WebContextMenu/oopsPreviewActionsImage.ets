import { common } from '@kit.AbilityKit';
import { UIContext } from '@kit.ArkUI';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { arrayBuffer_2_pixelMap, base64_2_arrayBuffer, downloadFileHttp, fileDocumentPickSave, saveHybrid, saveImageToAlbum } from '../../../catstypicalframework/utils/storage';
import { MooSymbolButton } from '../../common/MooSymbolButton';

@ComponentV2
export struct oopsPreviewActionsImage {
  // Params
  @Param @Require content: string;
  // Events
  @Event requestCloseMenu: () => void;
  @Event requestVisit: (link: string) => void;
  @Event requestCopyImage: () => void;

  build() {
    Scroll() {
      Row() {
        MooSymbolButton({
          icon: $r('sys.symbol.plus_square_on_square'), clickAction: () => {
            this.requestCopyImage();
            this.requestCloseMenu();
          }
        }); // Copy
        MooSymbolButton({
          icon: $r('sys.symbol.arrow_up_right'), clickAction: () => {
            this.requestVisit(this.content);
            this.requestCloseMenu();
          }
        }); // Open in new tab
        MooSymbolButton({
          icon: $r('sys.symbol.download'), clickAction: async () => {
            this.saveFile();
          }
        }); // Save to Files
        MooSymbolButton({
          icon: $r('sys.symbol.picture_badge_arrow_down'), clickAction: async () => {
            this.saveAlbum();
          }
        }); // Save to Files

      }; // Control buttons
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .edgeEffect(EdgeEffect.Spring);
  }

  /**
   * Get image arrayBuffer, automatically through the correct mean!
   * @returns The getImageResult in a promise.
   */
  async get(): Promise<getImageResult> {
    let arrayBuffer: ArrayBuffer;
    // Get arrayBuffer
    if (this.content.startsWith('http')) {
      arrayBuffer = await downloadFileHttp(this.content);
    } else if (this.content.startsWith('data:')) {
      arrayBuffer = await base64_2_arrayBuffer(this.content.split(',')[1]);
    } else {
      return { ok: false };
    }
    // Process
    if (!arrayBuffer) {
      return { ok: false };
    }
    const context = UIContext.getLastFocusedUIContext()?.getHostContext();
    if (!context) {
      return { ok: false };
    }
    const pixelMap = await arrayBuffer_2_pixelMap(arrayBuffer);
    try {
      const ext = pixelMap!.getImageInfoSync().mimeType.split('/').pop();
      return {
        ok: true,
        filename: `previewImage.${ext}`,
        file: arrayBuffer
      };
    } catch (e) {
      meow(`pixelMap.getImageInfoSync().mimeType.split('/').pop() failed: ${e}`, 'oopsPreviewActionsImage][get', meowLevel.ERROR);
      return { ok: false };
    }
  }

  async saveFile() {
    const r = await this.get();
    if (r.ok) {
      fileDocumentPickSave(r.filename!, r.file!);
    }
  }

  async saveAlbum() {
    const context = UIContext.getLastFocusedUIContext()?.getHostContext();
    if (!context) {
      return;
    }
    const r = await this.get();
    if (!r.ok) {
      meow(`this.get() not ok: ${r.ok}`, 'oopsPreviewActionsImage][saveAlbum', meowLevel.ERROR);
      return;
    }
    const path = `${context.tempDir}/${r.filename!}`;
    await saveHybrid(path, r.file!, true);
    saveImageToAlbum(context! as common.UIAbilityContext, path);
  }
}

interface getImageResult {
  ok: boolean,
  filename?: string,
  file?: ArrayBuffer;
}
