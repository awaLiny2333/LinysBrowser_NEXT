import lazy { unifiedDataChannel, uniformTypeDescriptor } from "@kit.ArkData";
import lazy { image } from "@kit.ImageKit";
import lazy { meow } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { fileNameOfPath, readArrayBufferConcurrent, uri_2_path } from "../../../../catstypicalframework/utils/storage";
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
export function unifiedRecord2BoardData(records: unifiedDataChannel.UnifiedRecord[], unique: boolean) {
  const newRecords: MeowScratchingBoardData[] = [];
  let lastAdd = '';

  records.forEach((rec) => {
    const type = rec.getType();
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
        const imgUri = (rec as unifiedDataChannel.Image).imageUri;
        if (lastAdd != imgUri) {
          if (unique) {
            lastAdd = imgUri;
          }

          const imgPath = uri_2_path(imgUri);
          const originalName = fileNameOfPath(imgPath);
          const originalExt = originalName.includes('.') ? `${originalName.split('.').pop()}` : '';
          const imgEntry = new MeowScratchingBoardData(MeowScratchingBoardDataType.IMAGE, originalName, originalExt);

          readArrayBufferConcurrent(imgPath).then((buffer) => {
            image.createImageSource(buffer).createPixelMap().then((result) => {
              imgEntry.payload = [buffer, result];
            });
          });

          newRecords.push(imgEntry);
        }

        const uri = (rec as unifiedDataChannel.Image).uri;
        if (lastAdd != uri) {
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
  });

  return newRecords;
}
