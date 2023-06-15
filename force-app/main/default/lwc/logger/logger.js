/* eslint-disable @typescript-eslint/no-explicit-any */ /* eslint-disable no-console */ 
export default class Logger {
    constructor(){
        this.console = console;
    }
    console = console;
    // START-NOSCAN
    log(message) {
        this.console.log(message);
    }
    error(message) {
        this.console.error(message);
    }
    table(message) {
        this.console.table(message);
    }
    warn(message) {
        this.console.warn(message);
    }
    time(label) {
        this.console.time(label);
    }
}


//# sourceMappingURL=logger.js.map
