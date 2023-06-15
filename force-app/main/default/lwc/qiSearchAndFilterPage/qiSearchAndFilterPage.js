import { LightningElement, track, api } from 'lwc';
import getFilterComp from '@salesforce/apex/QIDataEntrySubmissionController.getfilterComponents';
export default class QiSearchAndFilterPage extends LightningElement {

    itemsRP = [];
    itemStatus = [];
    selectedRP = [];
    selectedStatus = [];
    searcInput;
    selectedItems = [];
    typingTimer;

    /**
     * description: retrive the status and RP on page load
     **/
    connectedCallback() {
        this.getFilterComponent();
    }

    /**
     * description: call backend api to get the filter values
     **/
    async getFilterComponent() {
        const result = await getFilterComp();
        if (result.status === 'Success') {

            const repoData = JSON.parse(result.returnValue);
            const arrRP = [];
            // arrRP.push({label: 'All Periods', value: 'All'})
            const repPersSorted = repoData.reportingPeriods.sort().reverse();
            for (let i = 0; i < repPersSorted.length; i++) {
                arrRP.push({
                    label: this.formatDateddmmyyyy(repPersSorted[i]),
                    value: repPersSorted[i]
                });
            }
            this.itemsRP = arrRP;

            const arrStatus = [];

            for (let i = 0; i < repoData.status.length; i++) {
                arrStatus.push({
                    label: repoData.status[i],
                    value: repoData.status[i]
                });
            }
            this.itemStatus = arrStatus;

        }

    }
    /**
     * description: RP options value
     **/
    get optionsRP() {
        return this.itemsRP;
    }
    /**
     * description: status options value
     **/
    get optionsStatus() {
        return this.itemStatus;
    }
    /**
     * description: capture reporting period values
     **/
    handleChangedRP(event) {
        this.selectedRP = [];
        for (let i = 0; i < event.detail.length; i++) {
            this.selectedRP.push(
                event.detail[i].value
            );
        }

    }
    /**
     * description: capture status values
     **/
    handleChangedStatus(event) {
        this.selectedStatus = [];
        for (let i = 0; i < event.detail.length; i++) {
            this.selectedStatus.push(
                event.detail[i].value
            );
        }

    }
    /**
     * description: serach box activity
     **/
    updateSearch(event) {
        clearTimeout(this.typingTimer);
        this.typingTimer = setTimeout(() => {

        this.searcInput = event.detail.value;
        this.handleFiletrEvent();
        },500);
    }
    /**
     * description: clear filter functinality
     **/
    handleClearClick() {
        this.template.querySelectorAll('c-multi-select-combobox').forEach(element => element.reset());
        this.template.querySelector('lightning-input[data-name="searchbox"]').value = null;    
        this.selectedRP = [];
        this.selectedStatus = [];
        this.searcInput="";
        this.handleFiletrEvent();
    }
    /**
     * description: call parent function and pass the values
     **/
    handleFiletrEvent() {
        const event = new CustomEvent('message', {
            detail: {
                selectedStatus: this.selectedStatus,
                selectedRP: this.selectedRP,
                searchInput: this.searcInput
            }
        });
        this.dispatchEvent(event);
    }

    formatDateddmmyyyy(date) {
        if(!date) {
            return null;
        }

        const day = date.substring(date.lastIndexOf("-")+1, date.length);
        const month = date.substring(date.indexOf("-")+1, date.lastIndexOf("-"));
        const year = date.substring(0, date.indexOf("-"));
        return day+'/'+month+'/'+year;
    }
}