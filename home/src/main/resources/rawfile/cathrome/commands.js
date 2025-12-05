// Currently empty api.
// TODO: Finish commands.js

/**
 * A standalone class that mirrors the features of the chrome.commands API.
 * The internal logic for interacting with the operating system or browser is omitted.
 */
class cathrome_commands {
    static Command = class {
        constructor(options = {}) {
            this.description = options.description;
            this.name = options.name;
            this.shortcut = options.shortcut;
        }
    };

    constructor() {
        /**
         * Fired when a registered command is activated using a keyboard shortcut.
         * The callback is expected to receive `(command: string, tab?: object) => void`.
         * @type {cathrome_eventListener}
         */
        this.onCommand = new cathrome_eventListener();

        // Placeholder for internal state, mimicking registered commands.
        /** @private @type {Command[]} */
        this._registeredCommands = [
            // {
            //     name: "example-command-1",
            //     description: "Toggles a feature.",
            //     shortcut: "Ctrl+Shift+1"
            // },
            // {
            //     name: "_execute_action",
            //     description: "Reserved for the extension's primary action.",
            //     shortcut: "Ctrl+U"
            // }
        ];
    }

    fire(command, tab) {
        this.onCommand.fire(command, tab);
    }

    /**
     * Returns all the registered extension commands for this extension and their shortcut (if active).
     *
     * In a real environment, this would involve async browser communication.
     * Here, we use a callback to mimic the API's structure and immediately return placeholder data.
     *
     * @param {function(Command[]): void} callback A function that is called with an array of Command objects.
     * @returns {void}
     */
    getAll(callback) {
        if (typeof callback === 'function') {
            // Return a copy of the placeholder data to the callback.
            callback(this._registeredCommands.slice());
        }
        // NOTE: The real API supports a Promise return style as well, but we stick to the
        // common callback pattern for simplicity in this standalone structure.
    }
}