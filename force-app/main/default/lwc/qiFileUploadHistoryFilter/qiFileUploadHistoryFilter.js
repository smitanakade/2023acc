import { api, LightningElement } from 'lwc';
import { showErrorToast } from 'c/qiUtils';
import getPicklistValues from '@salesforce/apex/QIFileUploadHistoryController.getPicklistValues';

export default class QiFileUploadHistoryFilter extends LightningElement {
    picklistValues = {};
    filterInputs = {};

    async connectedCallback() {
        try {
            this.picklistValues = await getPicklistValues();
        } catch(error) {
            showErrorToast(this, error.body.message);
        }
    }

    handleTextChange(event) {
        const elementName = event.target.name;
        this.filterInputs[elementName] = event.detail.value;
        this.dispatchFilterEvent();
    }

    handleMultiSelectChange(event) {
        const elementName = event.target.name;
        this.filterInputs[elementName] = event.detail.map(option => option.value);
    }

    handleFilterClick() {
        this.dispatchFilterEvent();
    }

    handleClearClick() {
        this.template.querySelectorAll('c-multi-select-combobox').forEach(element => element.reset());
        this.template.querySelectorAll('lightning-input').forEach(element => element.value = '');
        this.filterInputs = {};
        this.dispatchFilterEvent();
    }

    dispatchFilterEvent() {
        const event = new CustomEvent('filter', {
            detail: this.filterInputs
        });
        this.dispatchEvent(event);
    }

    mapPicklistValuesToOptions(picklistValues) {
        const options = picklistValues?.map(value => ({
            label: value,
            value
        }));
        return options || [];
    }

    @api
    get reportingQuarterOptions() {
        return this.mapPicklistValuesToOptions(this.picklistValues.reportingQuarters);
    }

    @api
    get statusOptions() {
        return this.mapPicklistValuesToOptions(this.picklistValues.statuses);
    }
}