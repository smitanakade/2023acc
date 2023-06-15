/**
 * Make the first letter uppercase and the rest are lowercase.
 * Note there is one exception for ADL. Logic used here is to apply the above formatting
 * to all letters up to a "(" character so that we preserve "(ADLs)".
 */
const toSentenceCase = (str) => {
    return str.replace(
        /[^(]+/, 
        (text) => {
            return text.charAt(0).toUpperCase() + text.toLowerCase().slice(1);
        }
    );
};

/**
 * Make all letters lowercase.
 * Note there is one exception for ADL. Logic used here is to apply the above formatting
 * to all letters up to a "(" character so that we preserve "(ADLs)".
 */
const toLowerCase = (str) => {
    return str.replace(
        /[^(]+/, 
        (text) => {
            return text.toLowerCase();
        }
    );
};

export {
    toSentenceCase,
    toLowerCase
};