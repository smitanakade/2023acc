/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable no-console */

export default class Logger {
	constructor(){
		this.console = console;
	}
	
	console = console;
	// START-NOSCAN
	log(message: any) {
		this.console.log(message);
	}

	error(message: any): void {
		this.console.error(message);
	}

	table(message: any) {
		this.console.table(message);
	}

	warn(message: any) {
		this.console.warn(message);
	}

	time(label: any) {
		this.console.time(label);
	}
	// END-NOSCAN
}

