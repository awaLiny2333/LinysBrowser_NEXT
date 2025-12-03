class liny {
    constructor() {
    }

    test(data) {
        console.log(`[Extension][CatsBridge][js] Test! data=[${data}]! Is this the same as output from [arkTs]?`);
        CatsBridge.liny_test(data);
    }
}