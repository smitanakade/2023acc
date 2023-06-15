import { createElement } from "lwc";
import Logger from "../logger.js";

describe("c-logger", () => {

	it("logs to console", () => {
		console.log = jest.fn();
		const logger = new Logger();

		logger.log('test log');
		expect(console.log).toHaveBeenCalledWith('test log');
	});
});
