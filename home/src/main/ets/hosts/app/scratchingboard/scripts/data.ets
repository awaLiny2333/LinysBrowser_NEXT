import lazy { unifiedDataChannel, uniformTypeDescriptor } from "@kit.ArkData";
import lazy { image } from "@kit.ImageKit";
import lazy { meow } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { ensureDirectoryExist, fileNameOfPath, path_2_uri, readArrayBufferConcurrent, saveHybrid, uri_2_path } from "../../../../catstypicalframework/utils/storage";
import lazy { MeowScratchingBoardData, MeowScratchingBoardDataType } from "../classes/meowBoardHolder";
import lazy { splitUrls } from "./url";

/**
 * All the accepted types of the meowBoardHolder.
 */
export const meowBoardHolderAccepteTypesSet = new Set<string>([
  uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
  uniformTypeDescriptor.UniformDataType.HYPERLINK,
  uniformTypeDescriptor.UniformDataType.IMAGE
]);

/**
 * Analyzes and unifies unifiedDataChannel.UnifiedRecord[] to MeowScratchingBoardData[].
 *
 * @param records unifiedDataChannel.UnifiedRecord[]
 * @returns MeowScratchingBoardData[]
 * @author DeepSeek Web @ May 13 2026
 */
export async function unifiedRecord2BoardData(records: unifiedDataChannel.UnifiedRecord[], unique: boolean, imgTempDir: string) {
  const newRecords: MeowScratchingBoardData[] = [];
  let lastAdd = '';
  ensureDirectoryExist(imgTempDir);

  for (const rec of records) {
    const type = rec.getType();
    meow(`Adding entry of type: [${type}]`, 'meowBoardHolder][addEntry');
    switch (type) {
      case uniformTypeDescriptor.UniformDataType.PLAIN_TEXT: {
        const items = splitUrls((rec as unifiedDataChannel.PlainText).textContent);
        for (const item of items) {
          const content = item.textContent as string;
          if (lastAdd != content) {
            if (unique) {
              lastAdd = content;
            }
            newRecords.push(item);
          }
        }
        break;
      }

      case uniformTypeDescriptor.UniformDataType.HYPERLINK: {
        const url = (rec as unifiedDataChannel.Hyperlink).url;
        const description = (rec as unifiedDataChannel.Hyperlink).description;

        // URL
        if (lastAdd != url) {
          if (unique) {
            lastAdd = url;
          }
          newRecords.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.URL, url));
        }

        // description
        if (description && lastAdd != description) {
          if (unique) {
            lastAdd = description;
          }
          newRecords.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.TEXT, description));
        }
        break;
      }

      case uniformTypeDescriptor.UniformDataType.IMAGE: {
        // Image and imageUri
        const imgUri = (rec as unifiedDataChannel.Image).imageUri;
        if (lastAdd != imgUri) {
          if (unique) {
            lastAdd = imgUri;
          }
          // Bunch of values.
          const originalPath = uri_2_path(imgUri);
          const originalName = fileNameOfPath(originalPath);
          const originalExt = originalName.includes('.') ? `${originalName.split('.').pop()}` : '';
          const newName = `${Date.now().toString(16)}-${newRecords.length}.${originalExt}`;
          const newPath = `${imgTempDir}/${newName}`;
          const newUri = path_2_uri(newPath);
          // Read, copy and get info.
          const buffer = await readArrayBufferConcurrent(originalPath);
          const imgSource = image.createImageSource(buffer);
          const pixelMap = await imgSource.createPixelMap();
          imgSource.release();
          const info = await pixelMap.getImageInfo();
          await saveHybrid(newPath, buffer);
          // Push to new record list!
          newRecords.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.IMAGE, newName, originalExt, [buffer, pixelMap, newUri, info]));
          newRecords.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.URL, imgUri));
        }
        
        // Uri
        const uri = (rec as unifiedDataChannel.Image).uri;
        if (lastAdd != uri && (imgUri != uri)) {
          if (unique) {
            lastAdd = uri;
          }
          newRecords.push(new MeowScratchingBoardData(MeowScratchingBoardDataType.URL, uri));
        }
        break;
      }
      default: {
        meow(`Entry of type ${type} is not accepted!`, 'meowBoardHolder][addEntry');
      }
    }

  }

  return newRecords;
}
