/**
 * @author Rami Zuhairi
 * @date 06/2022
 * @objects Accounts , Reporting_Period__c, contentDocument, File_Staging__c
 * @description: developed file upload LWC component that will accept values of both CER and QI
 */
import {LightningElement, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import insertFileEntryFields from '@salesforce/apex/SrqiCSVFileReadLWCController.insertFileEntryFields';
import getRecordsRP from '@salesforce/apex/SrqiCSVFileReadLWCController.getRecordsRP';
import {NavigationMixin} from 'lightning/navigation';

export default class srqiFileUpload extends NavigationMixin(LightningElement) {
    sfData;
    hdpFileRef = '';
    reportingPeriodId;
    valueRP = '';

    navigateToFileStaging() {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/o/File_Staging__c/list?filterName=Recent'
                }
            },
            true
        );
    }

    @wire(getRecordsRP)
    wiredRecordsRP({error, data}) {
        if (data) {
            this.valueRP = JSON.stringify(data[0].Reporting_Period_Short__c);
            this.reportingPeriodId = data[0].Id;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: error?.body?.message,
                    variant: 'error'
                }),
            );
        }
    }

    handleInputChange(event) {
        this.hdpFileRef = event.detail.value;
        this.hideShowUploadFile();
        if (this.hdpFileRef === '') {
            this.showValidationToast();
        }
    }

    renderedCallback() {
        this.hideShowUploadFile();
    }

    hideShowUploadFile() {
        if (this.hdpFileRef === '') {
            this.template.querySelector('lightning-file-upload').disabled = true;
        } else {
            this.template.querySelector('lightning-file-upload').disabled = false;
        }
    }

    get acceptedCSVFormats() {
        return ['.csv'];
    }

    handleUpdateStagingFile(event) {
        // Get the list of records from the uploaded files
        const uploadedFiles = event.detail.files;

        // Call apex class insertFileEntryFields method
        insertFileEntryFields({
            contentDocumentId: uploadedFiles[0].documentId,
            reportingPeriodId: this.reportingPeriodId,
            hdpFileRefNum: this.hdpFileRef
        })
            .then(result => {
                this.sfData = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Entry file records are created according to the CSV file uploaded!!!',
                        variant: 'Success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: error?.body?.message,
                        variant: 'error',
                        mode: 'pester'
                    }),
                );
            })
    }

    showValidationToast() {
        const event = new ShowToastEvent({
            title: 'HDP File Ref# required!!',
            message: 'please enter HDP File Ref# in order to upload',
            variant: 'Error',
            mode: 'pester',
        });
        this.dispatchEvent(event);
    }
}