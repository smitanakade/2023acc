import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getServiceNameRecords from '@salesforce/apex/srqiSearchStarRating.getServiceNameRecords';
import getServiceNameIDRecord from '@salesforce/apex/srqiSearchStarRating.getServiceNameIDRecord';

import { NavigationMixin } from 'lightning/navigation';
export default class srqiSendServiceNametoViewRating extends NavigationMixin(LightningElement) {
    @api values;
    @api label = '';
    @api name = '';
    @api required;
    @api placeholder = 'Select a service';
    @api showQIRatingDetails;
    @api showCMRatingDetails;
    @api showSCRRatingDetails;
    @api showCERRatingDetails;
    @api qiDatatableFieldMappingJSON;
    @api cmDatatableFieldMappingJSON;
    @api cerDatatableFieldMappingJSON;

    initialized = false;
    @track serviceNamesItems;
    @track errorServiceNames;
    @track selectedServiceNameValue;
    @track returnedServiceIdToBeSendToViewRatings;

    async HandleDataList(event) {
        this.selectedServiceNameValue = event.target.value;

        getServiceNameIDRecord({ serviceName: this.selectedServiceNameValue })
            .then(result => {
                this.returnedServiceIdToBeSendToViewRatings = result;

            })
            .catch(error => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning!!',
                        message: 'Error in getting the data, Please try again',
                        variant: 'warning',
                        mode: 'pester'
                    }),

                );

            })
        clearTimeout(this.timeoutId); // no-op if invalid id
        let delayTime = 500;
        this.timeoutId = setTimeout(this.refreshGraph.bind(this), delayTime);
    }
    async refreshGraph() {
        await this.template.querySelector('c-srqi-star-rate-history-sub-category-graphs-p').retrievalDataFromIntgrationId();
    }

    @wire(getServiceNameRecords)
    getServiceNameRecords({ error, data }) {
        if (data) {
            let arrServiceNames = [];
            for (let i = 0; i < data.length; i++) {
                arrServiceNames.push({ label: data[i].Name, value: data[i].Name }); // store the result of Id and Value inside array
            }
            this.serviceNamesItems = arrServiceNames;

        } else if (error) {
            this.errorServiceNames = error;

        }
    }

    goToAllServices() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                name: 'Your_Organisations_Rating__c'
            }
        },
            true
        );
    }
}