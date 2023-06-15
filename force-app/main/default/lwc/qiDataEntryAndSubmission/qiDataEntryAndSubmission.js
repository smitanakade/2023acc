import { LightningElement, api, track } from 'lwc';

export default class QiDataEntryAndSubmission extends LightningElement {
    @track reportingPeriods;
    @track statuses;
    @track serviceId;
    @track searchText;

    handleSearchFilter(event) {
        this.reportingPeriods = event.detail.selectedStatus;
        this.statuses = event.detail.selectedRP;
        this.searchText=event.detail.searchInput;
        this.template.querySelector('c-qi-service-provider-list').handleFilterSearch(this.reportingPeriods, this.statuses, this.searchText);
    }
}