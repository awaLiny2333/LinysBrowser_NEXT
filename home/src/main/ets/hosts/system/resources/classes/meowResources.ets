import lazy { image } from "@kit.ImageKit";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { fileCopy, fileDocumentPick2Path, galleryPick2Path } from "../../../../catstypicalframework/utils/storage";
import lazy { defaultAnimation } from "../../../../components/settings";
import { readBackgroundImageConcurrent } from "../scripts/storage";

/**
 * The one who manages miscallaneous resources.
 */
@ObservedV2
export class meowResources {
  // Settings
  backgroundImagePath: string;
  // Data
  @Trace backgroundImage: image.PixelMap | undefined = undefined;

  constructor(backgroundImagePath: string) {
    this.backgroundImagePath = backgroundImagePath;
  }

  /**
   * Load background image from path.
   * @param path The path.
   */
  async loadBackgroundImage() {
    const backgroundImage = await readBackgroundImageConcurrent(this.backgroundImagePath);
    if (!backgroundImage) {
      meow(`NO background image read from ${this.backgroundImagePath}.`, 'meowResources][loadBackgroundImage', meowLevel.WARN);
      return;
    }
    setTimeout(() => {
      animateToImmediately(defaultAnimation(), () => {
        this.backgroundImage?.release();
        this.backgroundImage = backgroundImage;
      });
    });
  }

  /**
   * Pick background image from documents.
   */
  async pickBackgroundImageFromDocuments() {
    const result = await fileDocumentPick2Path(['*.png *.jpeg *.jpg|.png,.jpeg,.jpg'], 1);
    if (!result.succeed) {
      meow(`Failed to pick background image from documents.`, 'meowResources][pickBackgroundImageFromDocuments', meowLevel.WARN);
      return;
    }
    const path = result.sourcePaths![0];
    await fileCopy(path, this.backgroundImagePath, true);
    await this.loadBackgroundImage();
    meow(`Background image loaded from ${path}.`, 'meowResources][pickBackgroundImageFromDocuments', meowLevel.INFO);
  }

  /**
   * Pick background image from gallery.
   */
  async pickBackgroundImageFromGallery() {
    const result = await galleryPick2Path();
    if (!result.succeed) {
      meow(`Failed to pick background image from gallery.`, 'meowResources][pickBackgroundImageFromGallery', meowLevel.WARN);
      return;
    }
    const path = result.sourcePaths![0];
    await fileCopy(path, this.backgroundImagePath, true);
    await this.loadBackgroundImage();
    meow(`Background image loaded from ${path}.`, 'meowResources][pickBackgroundImageFromGallery', meowLevel.INFO);
  }
}
