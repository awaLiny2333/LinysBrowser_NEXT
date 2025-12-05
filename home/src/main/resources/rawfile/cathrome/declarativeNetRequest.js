/**
 * 模拟 chrome.declarativeNetRequest API 的独立类
 */
class cathrome_declarativeNetRequest {
    // ==================== 静态属性（常量）====================
    static DYNAMIC_RULESET_ID = "dynamic";
    static SESSION_RULESET_ID = "session";
    static GETMATCHEDRULES_QUOTA_INTERVAL = 30; // 分钟
    static GUARANTEED_MINIMUM_STATIC_RULES = 30000;
    static MAX_GETMATCHEDRULES_CALLS_PER_INTERVAL = 20;
    static MAX_NUMBER_OF_DYNAMIC_RULES = 30000;
    static MAX_NUMBER_OF_ENABLED_STATIC_RULESETS = 50;
    static MAX_NUMBER_OF_REGEX_RULES = 1000;
    static MAX_NUMBER_OF_SESSION_RULES = 5000;
    static MAX_NUMBER_OF_STATIC_RULESETS = 100;
    static MAX_NUMBER_OF_UNSAFE_DYNAMIC_RULES = 5000;
    static MAX_NUMBER_OF_UNSAFE_SESSION_RULES = 5000;

    // ==================== 事件 ====================
    static onRuleMatchedDebug = new cathrome_eventListener();

    // ==================== 方法 ====================

    /**
     * 获取可用的静态规则数量
     * @returns {Promise<number>}
     */
    async getAvailableStaticRuleCount() {
        // 模拟实现
        return Promise.resolve(1000);
    }

    /**
     * 获取禁用的规则ID
     * @param {GetDisabledRuleIdsOptions} options
     * @returns {Promise<number[]>}
     */
    async getDisabledRuleIds(options) {
        // 模拟实现
        return Promise.resolve([]);
    }

    /**
     * 获取动态规则
     * @param {GetRulesFilter} [filter]
     * @returns {Promise<Rule[]>}
     */
    async getDynamicRules(filter) {
        // 模拟实现
        return Promise.resolve([]);
    }

    /**
     * 获取启用的规则集ID
     * @returns {Promise<string[]>}
     */
    async getEnabledRulesets() {
        // 模拟实现
        return Promise.resolve([]);
    }

    /**
     * 获取匹配的规则
     * @param {MatchedRulesFilter} [filter]
     * @returns {Promise<RulesMatchedDetails>}
     */
    async getMatchedRules(filter) {
        // 模拟实现
        return Promise.resolve({ rulesMatchedInfo: [] });
    }

    /**
     * 获取会话规则
     * @param {GetRulesFilter} [filter]
     * @returns {Promise<Rule[]>}
     */
    async getSessionRules(filter) {
        // 模拟实现
        return Promise.resolve([]);
    }

    /**
     * 检查正则表达式是否支持
     * @param {RegexOptions} regexOptions
     * @returns {Promise<IsRegexSupportedResult>}
     */
    async isRegexSupported(regexOptions) {
        // 模拟实现
        return Promise.resolve({ isSupported: true });
    }

    /**
     * 设置扩展操作选项
     * @param {ExtensionActionOptions} options
     * @returns {Promise<void>}
     */
    async setExtensionActionOptions(options) {
        // 模拟实现
        return Promise.resolve();
    }

    /**
     * 测试匹配结果
     * @param {TestMatchRequestDetails} request
     * @returns {Promise<TestMatchOutcomeResult>}
     */
    async testMatchOutcome(request) {
        // 模拟实现
        return Promise.resolve({ matchedRules: [] });
    }

    /**
     * 更新动态规则
     * @param {UpdateRuleOptions} options
     * @returns {Promise<void>}
     */
    async updateDynamicRules(options) {
        // 模拟实现
        return Promise.resolve();
    }

    /**
     * 更新启用的规则集
     * @param {UpdateRulesetOptions} options
     * @returns {Promise<void>}
     */
    async updateEnabledRulesets(options) {
        // 模拟实现
        return Promise.resolve();
    }

    /**
     * 更新会话规则
     * @param {UpdateRuleOptions} options
     * @returns {Promise<void>}
     */
    async updateSessionRules(options) {
        // 模拟实现
        return Promise.resolve();
    }

    /**
     * 更新静态规则
     * @param {UpdateStaticRulesOptions} options
     * @returns {Promise<void>}
     */
    async updateStaticRules(options) {
        // 模拟实现
        return Promise.resolve();
    }
}

// ==================== 类型定义（静态嵌套类）====================

/**
 * 域类型
 */
cathrome_declarativeNetRequest.DomainType = class {
    static FIRST_PARTY = "firstParty";
    static THIRD_PARTY = "thirdParty";
};

/**
 * 扩展操作选项
 */
cathrome_declarativeNetRequest.ExtensionActionOptions = class {
    /** @type {boolean} */
    displayActionCountAsBadgeText;
    /** @type {TabActionCountUpdate} */
    tabUpdate;
};

/**
 * 获取禁用规则ID选项
 */
cathrome_declarativeNetRequest.GetDisabledRuleIdsOptions = class {
    /** @type {string} */
    rulesetId;
};

/**
 * 获取规则过滤器
 */
cathrome_declarativeNetRequest.GetRulesFilter = class {
    /** @type {number[]} */
    ruleIds;
};

/**
 * 头部信息
 */
cathrome_declarativeNetRequest.HeaderInfo = class {
    /** @type {string[]} */
    excludedValues;
    /** @type {string} */
    header;
    /** @type {string[]} */
    values;
};

/**
 * 头部操作
 */
cathrome_declarativeNetRequest.HeaderOperation = class {
    static APPEND = "append";
    static SET = "set";
    static REMOVE = "remove";
};

/**
 * 正则表达式支持结果
 */
cathrome_declarativeNetRequest.IsRegexSupportedResult = class {
    /** @type {boolean} */
    isSupported;
    /** @type {UnsupportedRegexReason} */
    reason;
};

/**
 * 匹配的规则
 */
cathrome_declarativeNetRequest.MatchedRule = class {
    /** @type {number} */
    ruleId;
    /** @type {string} */
    rulesetId;
};

/**
 * 匹配的规则信息
 */
cathrome_declarativeNetRequest.MatchedRuleInfo = class {
    /** @type {MatchedRule} */
    rule;
    /** @type {number} */
    tabId;
    /** @type {number} */
    timeStamp;
};

/**
 * 匹配的规则信息（调试）
 */
cathrome_declarativeNetRequest.MatchedRuleInfoDebug = class {
    /** @type {RequestDetails} */
    request;
    /** @type {MatchedRule} */
    rule;
};

/**
 * 匹配的规则过滤器
 */
cathrome_declarativeNetRequest.MatchedRulesFilter = class {
    /** @type {number} */
    minTimeStamp;
    /** @type {number} */
    tabId;
};

/**
 * 修改头部信息
 */
cathrome_declarativeNetRequest.ModifyHeaderInfo = class {
    /** @type {string} */
    header;
    /** @type {HeaderOperation} */
    operation;
    /** @type {string} */
    value;
};

/**
 * 查询键值对
 */
cathrome_declarativeNetRequest.QueryKeyValue = class {
    /** @type {string} */
    key;
    /** @type {boolean} */
    replaceOnly;
    /** @type {string} */
    value;
};

/**
 * 查询转换
 */
cathrome_declarativeNetRequest.QueryTransform = class {
    /** @type {QueryKeyValue[]} */
    addOrReplaceParams;
    /** @type {string[]} */
    removeParams;
};

/**
 * 重定向
 */
cathrome_declarativeNetRequest.Redirect = class {
    /** @type {string} */
    extensionPath;
    /** @type {string} */
    regexSubstitution;
    /** @type {URLTransform} */
    transform;
    /** @type {string} */
    url;
};

/**
 * 正则表达式选项
 */
cathrome_declarativeNetRequest.RegexOptions = class {
    /** @type {boolean} */
    isCaseSensitive;
    /** @type {string} */
    regex;
    /** @type {boolean} */
    requireCapturing;
};

/**
 * 请求详情
 */
cathrome_declarativeNetRequest.RequestDetails = class {
    /** @type {string} */
    documentId;
    /** @type {string} */
    documentLifecycle;
    /** @type {number} */
    frameId;
    /** @type {string} */
    frameType;
    /** @type {string} */
    initiator;
    /** @type {string} */
    method;
    /** @type {string} */
    parentDocumentId;
    /** @type {number} */
    parentFrameId;
    /** @type {string} */
    requestId;
    /** @type {number} */
    tabId;
    /** @type {ResourceType} */
    type;
    /** @type {string} */
    url;
};

/**
 * 请求方法
 */
cathrome_declarativeNetRequest.RequestMethod = class {
    static CONNECT = "connect";
    static DELETE = "delete";
    static GET = "get";
    static HEAD = "head";
    static OPTIONS = "options";
    static PATCH = "patch";
    static POST = "post";
    static PUT = "put";
    static OTHER = "other";
};

/**
 * 资源类型
 */
cathrome_declarativeNetRequest.ResourceType = class {
    static MAIN_FRAME = "main_frame";
    static SUB_FRAME = "sub_frame";
    static STYLESHEET = "stylesheet";
    static SCRIPT = "script";
    static IMAGE = "image";
    static FONT = "font";
    static OBJECT = "object";
    static XMLHTTPREQUEST = "xmlhttprequest";
    static PING = "ping";
    static CSP_REPORT = "csp_report";
    static MEDIA = "media";
    static WEBSOCKET = "websocket";
    static WEBTRANSPORT = "webtransport";
    static WEBBUNDLE = "webbundle";
};

/**
 * 规则
 */
cathrome_declarativeNetRequest.Rule = class {
    /** @type {RuleAction} */
    action;
    /** @type {RuleCondition} */
    condition;
    /** @type {number} */
    id;
    /** @type {number} */
    priority;
};

/**
 * 规则操作
 */
cathrome_declarativeNetRequest.RuleAction = class {
    /** @type {Redirect} */
    redirect;
    /** @type {ModifyHeaderInfo[]} */
    requestHeaders;
    /** @type {ModifyHeaderInfo[]} */
    responseHeaders;
    /** @type {RuleActionType} */
    type;
};

/**
 * 规则操作类型
 */
cathrome_declarativeNetRequest.RuleActionType = class {
    static BLOCK = "block";
    static REDIRECT = "redirect";
    static ALLOW = "allow";
    static UPGRADE_SCHEME = "upgradeScheme";
    static MODIFY_HEADERS = "modifyHeaders";
    static ALLOW_ALL_REQUESTS = "allowAllRequests";
};

/**
 * 规则条件
 */
cathrome_declarativeNetRequest.RuleCondition = class {
    /** @type {DomainType} */
    domainType;
    /** @type {string[]} */
    domains; // 已弃用
    /** @type {string[]} */
    excludedDomains; // 已弃用
    /** @type {string[]} */
    excludedInitiatorDomains;
    /** @type {string[]} */
    excludedRequestDomains;
    /** @type {RequestMethod[]} */
    excludedRequestMethods;
    /** @type {ResourceType[]} */
    excludedResourceTypes;
    /** @type {HeaderInfo[]} */
    excludedResponseHeaders;
    /** @type {number[]} */
    excludedTabIds;
    /** @type {string[]} */
    initiatorDomains;
    /** @type {boolean} */
    isUrlFilterCaseSensitive;
    /** @type {string} */
    regexFilter;
    /** @type {string[]} */
    requestDomains;
    /** @type {RequestMethod[]} */
    requestMethods;
    /** @type {ResourceType[]} */
    resourceTypes;
    /** @type {HeaderInfo[]} */
    responseHeaders;
    /** @type {number[]} */
    tabIds;
    /** @type {string} */
    urlFilter;
};

/**
 * 规则集
 */
cathrome_declarativeNetRequest.Ruleset = class {
    /** @type {boolean} */
    enabled;
    /** @type {string} */
    id;
    /** @type {string} */
    path;
};

/**
 * 规则匹配详情
 */
cathrome_declarativeNetRequest.RulesMatchedDetails = class {
    /** @type {MatchedRuleInfo[]} */
    rulesMatchedInfo;
};

/**
 * 标签页操作计数更新
 */
cathrome_declarativeNetRequest.TabActionCountUpdate = class {
    /** @type {number} */
    increment;
    /** @type {number} */
    tabId;
};

/**
 * 测试匹配结果
 */
cathrome_declarativeNetRequest.TestMatchOutcomeResult = class {
    /** @type {MatchedRule[]} */
    matchedRules;
};

/**
 * 测试匹配请求详情
 */
cathrome_declarativeNetRequest.TestMatchRequestDetails = class {
    /** @type {string} */
    initiator;
    /** @type {RequestMethod} */
    method;
    /** @type {Object} */
    responseHeaders;
    /** @type {number} */
    tabId;
    /** @type {ResourceType} */
    type;
    /** @type {string} */
    url;
};

/**
 * 不支持的正则表达式原因
 */
cathrome_declarativeNetRequest.UnsupportedRegexReason = class {
    static SYNTAX_ERROR = "syntaxError";
    static MEMORY_LIMIT_EXCEEDED = "memoryLimitExceeded";
};

/**
 * 更新规则选项
 */
cathrome_declarativeNetRequest.UpdateRuleOptions = class {
    /** @type {Rule[]} */
    addRules;
    /** @type {number[]} */
    removeRuleIds;
};

/**
 * 更新规则集选项
 */
cathrome_declarativeNetRequest.UpdateRulesetOptions = class {
    /** @type {string[]} */
    disableRulesetIds;
    /** @type {string[]} */
    enableRulesetIds;
};

/**
 * 更新静态规则选项
 */
cathrome_declarativeNetRequest.UpdateStaticRulesOptions = class {
    /** @type {number[]} */
    disableRuleIds;
    /** @type {number[]} */
    enableRuleIds;
    /** @type {string} */
    rulesetId;
};

/**
 * URL转换
 */
cathrome_declarativeNetRequest.URLTransform = class {
    /** @type {string} */
    fragment;
    /** @type {string} */
    host;
    /** @type {string} */
    password;
    /** @type {string} */
    path;
    /** @type {string} */
    port;
    /** @type {string} */
    query;
    /** @type {QueryTransform} */
    queryTransform;
    /** @type {string} */
    scheme;
    /** @type {string} */
    username;
};

// 导出类
// 在浏览器环境中：window.cathrome_declarativeNetRequest = cathrome_declarativeNetRequest;
// 在Node.js环境中：module.exports = cathrome_declarativeNetRequest;