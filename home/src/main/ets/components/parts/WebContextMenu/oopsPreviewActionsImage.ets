import { common } from '@kit.AbilityKit';
import { UIContext } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { addUnitsToSize, arrayBuffer_2_pixelMap, base64_2_arrayBuffer, downloadFileHttp, fileDocumentPickSave, readArrayBuffer, saveHybrid, saveImageToAlbum, scanQrFromPath, uri_2_path } from '../../../catstypicalframework/utils/storage';
import { meowTabInfo } from '../../../hosts/app/tabs/classes/meowTabInfo';
import { MooSymbolButton } from '../../common/MooSymbolButton';
import { MooTextButton } from '../../common/MooTextButton';

@ComponentV2
export struct oopsPreviewActionsImage {
  @Param @Require tabInfo: meowTabInfo;
  // Params
  @Param @Require content: string;
  // Events
  @Event requestCloseMenu: () => void;
  @Event requestVisit: (link: string) => void;
  @Event requestCopyImage: () => void;
  @Event requestCopyUrl: () => void;

  aboutToAppear(): void {
    this.get().then((r) => {
      if (!r.ok) {
        return;
      }
      // Save
      const context = UIContext.getLastFocusedUIContext()?.getHostContext();
      if (!context) return;
      const path = `${context.tempDir}/${r.filename!}`;
      saveHybrid(path, r.buffer!, true).then(() => {
        // Set
        this.tabInfo.imageFilename = r.filename!;
        this.tabInfo.imagePath = path;
        this.tabInfo.imageArrayBuffer = r.buffer;
        this.tabInfo.imagePixelMap = r.pixelMap;
        meow(`Image saved to [${path}]!`, 'oopsPreviewActionsImage][aboutToAppear', meowLevel.INFO);
        r.pixelMap?.getImageInfo().then((info) => {
          this.tabInfo.imageInfo = info; // Set info.
        });
        scanQrFromPath(path, true).then((qrResults) => {
          this.tabInfo.imageQrResults = qrResults;
        });
      });
    });
  }

  aboutToDisappear(): void {
    // Set
    this.tabInfo.imageFilename = '';
    this.tabInfo.imagePath = '';
    this.tabInfo.imageArrayBuffer = undefined;
    this.tabInfo.imagePixelMap = undefined;
    this.tabInfo.imageInfo = undefined;
    this.tabInfo.imageQrResults = undefined;
  }

  build() {
    Scroll() {
      Row()
      {
        MooSymbolButton({
          icon: $r('sys.symbol.picture_2'), clickAction: () => {
            this.requestCopyImage();
            this.requestCloseMenu();
          }
        }); // Copy image
        MooSymbolButton({
          icon: $r('sys.symbol.plus_square_on_square'), clickAction: () => {
            this.requestCopyUrl();
            this.requestCloseMenu();
          }
        }); // Copy url
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
        MooTextButton({
          text: `${this.tabInfo.imageInfo?.size?.width}x${this.tabInfo.imageInfo?.size?.height}`
        });
        MooTextButton({
          text: `${addUnitsToSize(this.tabInfo.imageArrayBuffer?.byteLength || 0)}`
        });
        MooTextButton({
          text: `${this.tabInfo.imageInfo?.mimeType}`
        });
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
    let arrayBuffer: ArrayBuffer | undefined;
    // Get arrayBuffer
    const contentLower = this.content.toLowerCase();
    if (contentLower.startsWith('http')) {
      arrayBuffer = await downloadFileHttp(this.content);
    } else if (contentLower.startsWith('data:')) {
      arrayBuffer = await base64_2_arrayBuffer(this.content.split(',')[1]);
    } else if (contentLower.startsWith('file:///')) {
      const path = uri_2_path(this.content);
      arrayBuffer = await readArrayBuffer(path);
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
    if (!pixelMap) {
      return { ok: false };
    }
    try {
      const ext = pixelMap.getImageInfoSync().mimeType.split('/').pop();
      return {
        ok: true,
        filename: `previewImage.${ext}`,
        buffer: arrayBuffer,
        pixelMap: pixelMap
      };
    } catch (e) {
      meow(`pixelMap.getImageInfoSync().mimeType.split('/').pop() failed: ${e}`, 'oopsPreviewActionsImage][get', meowLevel.ERROR);
      return { ok: false };
    }
  }

  saveFile() {
    if (!this.tabInfo.imageArrayBuffer) {
      meow(`No image read.`, 'oopsPreviewActionsImage][saveFile', meowLevel.ERROR);
      return;
    }
    // Save
    fileDocumentPickSave(this.tabInfo.imageFilename!, this.tabInfo.imageArrayBuffer!);
  }

  async saveAlbum() {
    if (!this.tabInfo.imagePath) {
      meow(`No image read.`, 'oopsPreviewActionsImage][saveAlbum', meowLevel.ERROR);
      return;
    }
    // Save
    saveImageToAlbum(this.tabInfo.imagePath, UIContext.getLastFocusedUIContext()?.getHostContext() as common.UIAbilityContext);
  }
}

interface getImageResult {
  ok: boolean,
  filename?: string,
  buffer?: ArrayBuffer;
  pixelMap?: image.PixelMap;
}
