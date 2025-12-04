/**
 * StandaloneI18n Class
 * * This class provides a basic implementation of the Chrome i18n API
 * (chrome.i18n) for use in environments where the native API is unavailable,
 * such as non-extension web pages or testing frameworks.
 * * NOTE: This is a structural and functional mimic. It does not handle
 * real-world locale file loading (_locales/xx/messages.json) or advanced
 * Chrome features like Bidi-UI.
 */
class cathrome_i18n {
    constructor() {
        // Log initialization success
        console.log(`[i18n] StandaloneI18n initialized!`);
    }

    /**
     * Gets the localized string for the specified message name.
     * Substitutions using $1, $2, etc., are supported, mimicking Chrome's behavior.
     * * @param {string} messageName - The name of the message to retrieve.
     * @param {string|string[]|null} substitutions - A single string or an array of substitution strings.
     * @returns {string} The localized message, or an error message if not found.
     */
    getMessage(messageName, substitutions = [], options = {}) {
        let message = CatsBridge.chrome_i18n_getMessage(messageName);

        // 1. Handle substitutions
        const subsArray = Array.isArray(substitutions) ? substitutions : (substitutions ? [substitutions] : []);

        // Iterate through substitutions (up to $99)
        for (let i = 0; i < subsArray.length; i++) {
            // Replace $1, $2, etc. with the substitution string
            const placeholder = new RegExp('\\$' + (i + 1), 'g');
            message = message.replace(placeholder, subsArray[i]);
        }

        // 2. Handle escape sequences: replace '$$' with '$'
        message = message.replace(/\$\$/g, '$');

        const escapeLt = options.escapeLt;
        if (escapeLt) {
            // ?
        }

        return message;
    }

    /**
     * Gets the browser's UI language. In this standalone version, it returns the
     * locale provided during initialization.
     * * @returns {string} The application's UI language.
     */
    getUILanguage() {
        return CatsBridge.chrome_i18n_getUILanguage();
    }

    /**
     * Gets the language list that the browser supports.
     * This is an asynchronous method in the Chrome API, so we mimic the structure.
     * * NOTE: In a real implementation, you'd fetch this from the environment
     * (e.g., navigator.languages) or return it directly if synchronous is acceptable.
     * * @param {function(string[]): void} callback - A callback function that accepts the language array.
     */
    getAcceptLanguages(callback) {
        // Mocking the asynchronous call with a hardcoded list and a setTimeout.
        const mockLanguages = CatsBridge.chrome_i18n_getAcceptLanguages();

        // Use setTimeout to mimic the asynchronous nature of a Chrome API call
        setTimeout(() => {
            if (typeof callback === 'function') {
                callback(mockLanguages);
            }
        }, 0);
    }

    /**
     * Detects the language of the provided text.
     * This method mimics the asynchronous signature and return structure of the Chrome API.
     * * @param {string} text - The text to analyze for language.
     * @param {function(Object): void} callback - A callback function that accepts the detection result object.
     */
    detectLanguage(text, callback) {
        // Simple, mock language detection logic based on keywords
        const normalizedText = text.toLowerCase();

        // Construct the result object as per Chrome API specification
        const result = {
            isReliable: isReliable,
            languages: [{
                language: 'und',
                percentage: 49 // Mock percentage
            }]
        };

        // Use setTimeout to mimic the asynchronous nature of a Chrome API call
        setTimeout(() => {
            if (typeof callback === 'function') {
                callback(result);
            }
        }, 0);
    }
}