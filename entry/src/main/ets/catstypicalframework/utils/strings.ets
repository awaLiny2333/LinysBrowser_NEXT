const INVISIBLE_REGEX = /^[\p{White_Space}\p{Cf}]*$/u;

/**
 * Checks if a string is blank, considering Unicode whitespace and control characters.
 * @param str The string to check.
 * @returns True if the string is blank, false otherwise.
 */
export function isBlank(str: string | null | undefined): boolean {
    return str === null || str === undefined || INVISIBLE_REGEX.test(str);
}
