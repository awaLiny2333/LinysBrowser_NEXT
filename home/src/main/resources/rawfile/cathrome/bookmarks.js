// Currently empty api.
// TODO: Finish bookmarks.js

class cathrome_bookmarks {
    static FolderType = {
        BOOKMARKS_BAR: "bookmarks-bar",
        OTHER: "other",
        MOBILE: "mobile",
        MANAGED: "managed",
    }

    static CreateDetails = class {
        constructor(options = {}) {
            this.parentId = options.parentId;
            this.index = options.index;
            this.title = options.title;
            this.url = options.url;
        }
    };

    static BookmarkTreeNode = class {
        constructor(nodeData) {
            this.children = nodeData.children;
            this.dateAdded = nodeData.dateAdded;
            this.dateGroupModified = nodeData.dateGroupModified;
            this.dateLastUsed = nodeData.dateLastUsed;
            this.folderType = nodeData.folderType;
            this.id = nodeData.id;
            this.index = nodeData.index;
            this.parentId = nodeData.parentId;
            this.syncing = nodeData.syncing;
            this.title = nodeData.title;
            this.unmodifiable = nodeData.unmodifiable;
            this.url = nodeData.url;
        }
    };

    constructor() {
        // --- Constants matches chrome.bookmarks properties ---
        this.MAX_WRITE_OPERATIONS_PER_HOUR = 1800;
        this.MAX_SUSTAINED_WRITE_OPERATIONS_PER_MINUTE = 1000000;

        // --- Events ---
        /** Fired when a bookmark or folder is created. */
        this.onCreated = new cathrome_eventListener();

        /** Fired when a bookmark or folder is removed. */
        this.onRemoved = new cathrome_eventListener();

        /** Fired when a bookmark or folder changes. */
        this.onChanged = new cathrome_eventListener();

        /** Fired when a bookmark or folder is moved to a different parent folder. */
        this.onMoved = new cathrome_eventListener();

        /** Fired when the children of a folder have changed their order due to the UI being sorted by the user. */
        this.onChildrenReordered = new cathrome_eventListener();

        /** Fired when a bookmark import session begins. */
        this.onImportBegan = new cathrome_eventListener();

        /** Fired when a bookmark import session ends. */
        this.onImportEnded = new cathrome_eventListener();
    }

    /**
     * Retrieves the specified BookmarkTreeNode(s).
     * @param {string|string[]} idOrIdList - A single string-valued id, or an array of string-valued ids.
     * @returns {Promise<BookmarkTreeNode[]>}
     */
    async get(idOrIdList) {
        // Implementation: would look up IDs in local storage
        return Promise.resolve([]);
    }

    /**
     * Retrieves the children of the specified BookmarkTreeNode id.
     * @param {string} id
     * @returns {Promise<BookmarkTreeNode[]>}
     */
    async getChildren(id) {
        // Implementation: would filter nodes by parentId
        return Promise.resolve([]);
    }

    /**
     * Retrieves the recently added bookmarks.
     * @param {number} numberOfItems - The maximum number of items to return.
     * @returns {Promise<BookmarkTreeNode[]>}
     */
    async getRecent(numberOfItems) {
        // Implementation: would sort by dateAdded desc
        return Promise.resolve([]);
    }

    /**
     * Retrieves the entire Borders hierarchy.
     * @returns {Promise<BookmarkTreeNode[]>}
     */
    async getTree() {
        // Implementation: would return the root node with fully populated children
        return Promise.resolve([]);
    }

    /**
     * Retrieves part of the Bookmarks hierarchy, starting at the specified node.
     * @param {string} id - The ID of the root of the subtree to retrieve.
     * @returns {Promise<BookmarkTreeNode[]>}
     */
    async getSubTree(id) {
        return Promise.resolve([]);
    }

    /**
     * Searches for BookmarkTreeNodes matching the given query.
     * @param {string|Object} query - Either a string of words and quoted phrases, or an object.
     * @returns {Promise<BookmarkTreeNode[]>}
     */
    async search(query) {
        return Promise.resolve([]);
    }

    /**
     * Creates a bookmark or folder under the specified parentId.
     * If url is NULL or missing, it will be a folder.
     * @param {CreateDetails} bookmark
     * @returns {Promise<BookmarkTreeNode>}
     */
    async create(bookmark) {
        // Mock Implementation structure:
        const newId = Math.random().toString(36).substr(2, 9);
        const newNode = {
            id: newId,
            parentId: bookmark.parentId,
            index: bookmark.index,
            title: bookmark.title || "",
            url: bookmark.url,
            dateAdded: Date.now()
        };

        // Fire event: (id, BookmarkTreeNode)
        this.onCreated.fire(newId, newNode);

        return Promise.resolve(newNode);
    }

    /**
     * Moves the specified BookmarkTreeNode to the provided location.
     * @param {string} id
     * @param {Destination} destination
     * @returns {Promise<BookmarkTreeNode>}
     */
    async move(id, destination) {
        // Fire event: (id, {parentId, index, oldParentId, oldIndex})
        this.onMoved.fire(id, {
            parentId: destination.parentId,
            index: destination.index,
            oldParentId: "mock_old_id",
            oldIndex: 0
        });

        return Promise.resolve({}); // Returns the moved node
    }

    /**
     * Updates the properties of a bookmark or folder.
     * @param {string} id
     * @param {Object} changes - {title?: string, url?: string}
     * @returns {Promise<BookmarkTreeNode>}
     */
    async update(id, changes) {
        // Fire event: (id, {title, url})
        this.onChanged.fire(id, changes);

        return Promise.resolve({}); // Returns the updated node
    }

    /**
     * Removes a bookmark or an empty bookmark folder.
     * @param {string} id
     * @returns {Promise<void>}
     */
    async remove(id) {
        // Fire event: (id, {parentId, index, node})
        this.onRemoved.fire(id, { parentId: "mock", index: 0, node: {} });

        return Promise.resolve();
    }

    /**
     * Recursively removes a bookmark folder.
     * @param {string} id
     * @returns {Promise<void>}
     */
    async removeTree(id) {
        // Fire event: (id, {parentId, index, node})
        this.onRemoved.fire(id, { parentId: "mock", index: 0, node: {} });

        return Promise.resolve();
    }
}

// Mimic the browser namespace
// const bookmarks = new ChromeBookmarks();

// Example Usage
// bookmarks.onCreated.addListener((id, node) => console.log("Created:", id));
// bookmarks.create({ title: "My Bookmark", url: "https://example.com" });