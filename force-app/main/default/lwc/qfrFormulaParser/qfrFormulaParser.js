const sfIdRegex = /^[a-zA-Z0-9\.]*$/;
const shouldMapToken = /^[a-zA-Z0-9\.]*$/;
const allowedFormulaRegex = /^([a-zA-Z0-9\.]|[+\-*/()]|\s|\d)*$/;
function parseFormula(formula) {
    const tokens = tokeniseFormula(formula);
    const [calculationFunction, sourceIds] = constructCalculationFunction(tokens);
    const excelFormulaFunctionBody = constructExcelFormulaGenerator(tokens);
    // eslint-disable-next-line no-new-func
    const calculationFunctionResult = new Function("args", calculationFunction);
    const excelFormulaGenerator = new Function("args", "cellColumn", excelFormulaFunctionBody);
    // TODO: run function with map of sourceIds => zeroes, and handle error if function doesn't execute
    return {
        sourceIds,
        formula: calculationFunctionResult,
        excelFormulaGenerator: excelFormulaGenerator
    };
 
}
function constructCalculationFunction(tokens) {
    let functionBody = "return ";
    const sourceIds = new Set();
    for (const token of tokens){
        if (!isNaN(parseInt(token, 10))) {
            // number literal tokens shouldn't try to look up from args
            functionBody += token;
        } else if (shouldMapToken.test(token)) {
            if (sfIdRegex.test(token)) {
                sourceIds.add(token);
            }
            functionBody += `args.get('${token}')`;
        } else {
            functionBody += token;
        }
    }
    return [
        functionBody,
        sourceIds
    ];
}
function constructExcelFormulaGenerator(tokens) {
    let functionBody = "return `";
    const sourceIds = new Set();
    for (const token of tokens){
        if (!isNaN(parseInt(token, 10))) {
            // number literal tokens shouldn't try to look up from args
            functionBody += token;
        } else if (shouldMapToken.test(token)) {
            functionBody += '${cellColumn}${args.get("' + token + '")}';
        } else {
            functionBody += token;
        }
    }
    return functionBody + "`";
}
function tokeniseFormula(formula) {
    // TODO: improve validation
    if (!allowedFormulaRegex.test(formula)) {
        throw new Error(`Invalid Formula supplied. Formula: ${formula}`);
    }
    const clearWhitespace = formula.replaceAll(/\s/g, "");
    const spaceSeparated = clearWhitespace.replaceAll(/[+\-*/()]/g, (match)=>` ${match} `); // ensures allowed special characters are space separated
    const tokens = spaceSeparated.trim().split(/\s/);
    return tokens.filter((token)=>token !== "");
}
export { parseFormula };


//# sourceMappingURL=formulaParser.js.map