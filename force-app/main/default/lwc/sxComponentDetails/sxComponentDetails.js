import { LightningElement, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import sxResource from '@salesforce/resourceUrl/solutionExchange';
import { CurrentPageReference } from 'lightning/navigation';

export default class SxComponentDetail extends LightningElement {
    @track cmpDetail = {};
    @track cmpType = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.cmpType = currentPageReference.state.type;
       }
    }

    connectedCallback() {
        loadScript(this, sxResource + '/data/JSON-components.js').then(() => {
            let components = window.components;
            let foundCmp = null;
            // console.log(JSON.stringify(window.components));
            // console.log('cmp type: ' + this.cmpType);
            if (components && this.cmpType) {
                foundCmp = components.find(o => o.id === this.cmpType);
            }
            if (foundCmp) {
                this.cmpDetail = foundCmp;
            }
        });
    }

    get compUrl() {
        return this.cmpDetail.componentImg;
    }

}