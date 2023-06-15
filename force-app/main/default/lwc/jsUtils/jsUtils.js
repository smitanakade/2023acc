/**
 *
 * @param {Function} func
 * @param {number} [delay=300] number of milliseconds to wait between calls before execution. Defaults to 300
 * @returns
 */
export function debounce(func, delay = 300) {
	let timeout;

	return (...args) => {
		clearTimeout(timeout);
		let context = this;
		timeout = setTimeout(() => func.apply(context, args), delay);
	};
}

export function normalizeString(value, config = {}) {
	const { fallbackValue = "", validValues, toLowerCase = true } = config;
	let normalized = (typeof value === "string" && value.trim()) || "";
	normalized = toLowerCase ? normalized.toLowerCase() : normalized;
	if (validValues && validValues.indexOf(normalized) === -1) {
		normalized = fallbackValue;
	}
	return normalized;
}

export function dynamicSort(property) {
	var sortOrder = 1;
	if (property[0] === "-") {
		sortOrder = -1;
		property = property.substr(1);
	}
	return function (a, b) {
		/* next line works with strings and numbers,
		 * and you may want to customize it to your needs
		 */
		var result =
			a[property] < b[property] ? -1 : a[property] > b[property] ? 1 : 0;
		return result * sortOrder;
	};
}
