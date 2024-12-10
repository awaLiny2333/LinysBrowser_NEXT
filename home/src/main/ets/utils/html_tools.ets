let chars: string[] =
  ["\"", "\'", "&", "<", ">", String.fromCharCode(8194), String.fromCharCode(8195), String.fromCharCode(160),
    "©", "®", "™", "×", "÷"]
let codes: string[] =
  ["&quot;", "&#39;", "&amp;", "&lt;", "&gt;", "&ensp;", "&emsp;", "&nbsp;",
    "&copy;", "&reg;", "&trade;", "&times;", "&divide;"]

export function encode_string_to_html_code(input: string) {
  let result = "";
  for (let index = 0; index < input.length; index++) {
    // Check each character
    let char = input.substring(index, index + 1);
    if (chars.includes(char)) {
      // Encode special chars
      result += codes[chars.indexOf(char)];
    } else {
      // No action for else chars
      result += char;
    }
  }
  return result;
}

export function decode_html_code_to_string(input: string) {
  let result = input;
  for (let index = 0; index < codes.length; index++) {
    result = result.replaceAll(codes[index], chars[index]);
  }
  return result;
}