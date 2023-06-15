import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//import csvFileRead from '@salesforce/apex/CSVFileReadLWCCntrl.csvFileRead';


export default class SrqiSpinnerLoading extends NavigationMixin(LightningElement) {
    SFResultdata = "has error data test";

    @track loading = true; // turn on of spinner @ waiting message

    connectedCallback() {

        setTimeout(() => {

            // this.showToast();
            this.navigateToFileStaging();
            this.loading = false;
        }, 30000
        );

    }


    showToast() {
        const event = new ShowToastEvent({
            title: 'Long Waiting!!',
            message:
                'The Porcess taking longer than usual please try again later!!!',
            variant: 'Error',
            mode: 'pester',
        });
        this.dispatchEvent(event);
    }

    navigateToFileStaging() {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/o/File_Staging__c/list?filterName=Recent '
            }
        },
            true

        );
    }


}