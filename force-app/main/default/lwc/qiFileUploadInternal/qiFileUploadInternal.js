import { api, LightningElement, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { showErrorToast } from 'c/qiUtils';
import { getSObjectValue } from '@salesforce/apex';
import userId from '@salesforce/user/Id';
import getContactsForProvider from '@salesforce/apex/QIFileUploadInternalController.getContactsForProvider';
import getFileStagingRecord from '@salesforce/apex/QIFileUploadInternalController.getFileStagingRecord';
import createFileStagingRecord from '@salesforce/apex/QIBulkUploadUtility.createFileStagingRecord';
import hasQIBulkUploadPermission from '@salesforce/customPermission/QI_Bulk_Upload';

import FILE_STAGING_OBJECT from '@salesforce/schema/File_Staging__c';
import PROVIDER_FIELD from '@salesforce/schema/File_Staging__c.Provider__c';
import SUBMISSION_REQUESTED_BY_FIELD from '@salesforce/schema/File_Staging__c.Submission_Requested_By__c';
import REQUEST_RECEIVED_DATE_FIELD from '@salesforce/schema/File_Staging__c.Request_Received_Date__c';
import DISPLAY_STATUS_FIELD from '@salesforce/schema/File_Staging__c.Display_Status__c';

const STATUS_PENDING = 'Pending';
const STATUS_SUBMITTED = 'Submitted';

export default class QiFileUploadInternal extends LightningElement {
    existingFileStagingRecordId;
    newFileStagingRecordId;
    fileStagingRecord = {};
    isLoading = false;
    providerContactOptions = [];
    showContent = false;
    showFileUploadComponent = false;

    fileStagingObject = FILE_STAGING_OBJECT;
    providerField = PROVIDER_FIELD;
    submissionRequestedByField = SUBMISSION_REQUESTED_BY_FIELD;
    requestReceivedDateField = REQUEST_RECEIVED_DATE_FIELD;

    @wire(CurrentPageReference)
    getURLParameters(pageReference) {
        if (pageReference) {
            this.existingFileStagingRecordId = pageReference.state?.c__id;
        }
    }

    /**
     * Workaround for issue where the help text cannot be hidden via standard methods
     * @see https://ideas.salesforce.com/s/feed/0D58W0000A9VUyLSQW
     */
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = ".hide-help-text lightning-helptext { display: none; }";
        let elements = this.template.querySelectorAll('.hide-help-text');
        elements.forEach(element => {
            element.appendChild(style);
        });
    }

    async connectedCallback() {
        if (this.existingFileStagingRecordId) {
            await this.prepopulateExistingRecordData();
        }

        /**
         * Note we check the access here after potentially fetching an existing record for a re-upload, because
         * one of the checks depends on the status of the existing record.
         */
        const accessError = this.validateAccess();
        if (accessError) {
            showErrorToast(this, accessError);
        } else {
            this.showContent = true;
        }
    }

    async prepopulateExistingRecordData() {
        this.setLoading(true);
        try {
            // Get record
            const existingRecord = await getFileStagingRecord({ recordId: this.existingFileStagingRecordId });
            // Get contacts related to the selected provider
            const providerId = getSObjectValue(existingRecord, PROVIDER_FIELD);
            await this.getContactsForSelectedProvider(providerId);
            // Prepopulate values and set defaults
            this.fileStagingRecord = {
                status: getSObjectValue(existingRecord, DISPLAY_STATUS_FIELD),
                provider: getSObjectValue(existingRecord, PROVIDER_FIELD),
                submissionRequestedBy: getSObjectValue(existingRecord, SUBMISSION_REQUESTED_BY_FIELD),
                requestReceivedDate: this.getTodaysDate()
            };
        } catch(error) {
            showErrorToast(this, error.body.message);
        }
        this.setLoading(false);
    }

    /**
     * Submission Requested By field should only show Contacts related to the selected Provider
     */
    handleProviderChange() {
        const providerId = this.template.querySelector('[data-id="provider"]').value;
        if (!providerId) {
            this.providerContactOptions = [];
        } else {
            this.getContactsForSelectedProvider(providerId);
        }
    }

    async handleSubmit(event) {
        this.setLoading(true);
        // Prevent standard form submission
        event.preventDefault();
        // Explicitly check validity of non lightning-input-field component
        const isValid = this.template.querySelector('[data-id="submissionRequestedBy"]').checkValidity();
        if (!isValid) {
            return;
        }
        // Create new file staging record then show the file upload component 
        try {
            const fileStagingWrapper = {
                userIdAura: userId,
                providerIdAura: this.template.querySelector('[data-id="provider"]').value,
                subReqByIdAura: this.template.querySelector('[data-id="submissionRequestedBy"]').value,
                reqReceivedDateAura: this.template.querySelector('[data-id="requestReceivedDate"]').value
            };
            const record = await createFileStagingRecord({ fileStagingWrapper });
            this.newFileStagingRecordId = record.Id;
            this.showFileUploadComponent = true;
        } catch(error) {
            showErrorToast(this, error.body.message);
        }
        this.setLoading(false);
    }

    mapProviderContactOptions(contacts) {
        this.providerContactOptions = contacts.map(contact => ({
            label: contact.name,
            value: contact.id
        }));
    }

    async getContactsForSelectedProvider(providerId) {
        this.setLoading(true);
        try {
            const providerContacts = await getContactsForProvider({ providerId });
            this.mapProviderContactOptions(providerContacts);
        } catch(error) {
            showErrorToast(this, error.body.message);
        }
        this.setLoading(false);
    }
    
    /**
     * As we are using a lightning-record-edit-form component, the submit button will not check the validity
     * of any non lightning-input-field components within the form, so we do this explicitly here.
     */
    reportSubmissionRequestedByValidity() {
        this.template.querySelector('[data-id="submissionRequestedBy"]').reportValidity();
    }

    /**
     * Returns today's date in the format yyyy-mm-dd
     */
    getTodaysDate() {
        const today = new Date().toLocaleDateString('en-AU'); // dd/mm/yyyy
        return today.split('/').reverse().join('-'); // yyyy-mm-dd
    }

    setLoading(isLoading) {
        this.isLoading = isLoading;
    }

    /**
     * Returns error message if component cannot be used
     */
    validateAccess() {
        if (!hasQIBulkUploadPermission) {
            return 'You do not have permission to access this feature';
        }
        if (this.isReupload) {
            const status = this.fileStagingRecord.status;
            if (status === STATUS_PENDING || status === STATUS_SUBMITTED) {
                return 'Cannot re-upload a file that is pending or successful';
            }
        }
        return; // All good, component can be used
    }

    @api
    get isProviderContactOptionsEmpty() {
        return this.providerContactOptions.length <= 0;
    }

    @api
    get isReupload() {
        return this.existingFileStagingRecordId !== undefined && this.existingFileStagingRecordId !== null;
    }
}