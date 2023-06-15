import { LightningElement, api, wire, track } from 'lwc';
import getRelatedDocuments from '@salesforce/apex/GPMSRelatedDocumentController.getRelatedDocuments';
import updateRelatedDocument from '@salesforce/apex/GPMSRelatedDocumentController.updateRelatedDocument';
import deleteRelatedDocument from '@salesforce/apex/GPMSRelatedDocumentController.deleteRelatedDocument';
import hasReadonlyPermission from '@salesforce/customPermission/GPMS_ACQSC_Read_Only'; //Added to fix the Bug 302431
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

const actions = [
    { label: 'Preview', name: 'Preview' },
    { label: 'Download', name: 'Download' },
    { label: 'View File Details', name: 'View_File_Details' },
    { label: 'Delete', name: 'Delete' },
];

const columns = [
    { label: 'Document Name', fieldName: 'Title', editable: true},
    { label: 'Received Date', fieldName: 'Received_Date__c', type: 'date-local', editable: true,
        typeAttributes:{year:"numeric", month:"numeric", day:"numeric"}
    },
    { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto' } }
];

export default class RelatedDocument extends NavigationMixin(LightningElement) {

    @api recordId;

    viewAll = false;
    clickViewAll = false;
    errors = {};
    columns = columns;
    draftValues = [];
    allResult;
    data = [];
    allDate = [];
    documentSize = 0; 
    _allResult;
    @wire(getRelatedDocuments,{ recordId: '$recordId'})
    wireDocuments(wireResult) {
        const { data, error } = wireResult;
        this._allResult = wireResult;
        if (data) {
            this.documentSize = data.documentsSize;
            this.allDate = data.documents;
            this.viewAll = data.documentsSize>5;
            this.viewAll = this.clickViewAll?false:this.viewAll;
            if(this.viewAll){
                this.data = data.documents.slice(0, 5);
            }else{
                this.data = data.documents;
            }
            this.draftValues = []
        }
    }

    async handleSave(event) {
        let updatedFields = event.detail.draftValues
        let hasError = false;

        let updateError = { rows: {}, table: {} }
        updatedFields.forEach(row => {
            
            if(row.Received_Date__c === null && row.Title === ''){
                hasError = true
                updateError.rows[row.Id] = { title: "We found two errors", messages: ['Received Date is mandatory','Document Name is mandatory'], fieldNames: ['Received_Date__c', 'Title'] }
            }else if(row.Received_Date__c === null){
                hasError = true
                updateError.rows[row.Id] = { title: "We found an error", messages: ['Received Date is mandatory'], fieldNames: ['Received_Date__c'] }
            }else if(row.Title === ''){
                hasError = true
                updateError.rows[row.Id] = { title: "We found an error", messages: ['Document Name is mandatory'], fieldNames: ['Title'] }
            }
        });


        if(hasError){
            updateError.table = {
                title: 'Your changes cannot be saved. Fix the errors and try again.',
                messages: [
                    'Document Name and Received Date are all mandatory'
                ]
            }
            this.errors = updateError;
        }else{
            this.errors = {};
            const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
            try {
                await updateRelatedDocument({data: updatedFields});
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Success', message: 'Documents updated', variant: 'success'})
                );
                getRecordNotifyChange(notifyChangeIds);
                return refreshApex(this._allResult);
            }catch(error) {
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error updating or refreshing records', message: error.body.message, variant: 'error'})
                )
            }
        }
    } 
    
    get ispermissionEnabled() { //Added to fix the Bug 302431
        return hasReadonlyPermission;
    }

    handleUploadFinished(event) {
        this.dispatchEvent(
            new ShowToastEvent({title: 'Success', message: 'File uploaded Successfully', variant: 'success' })
        );
        return refreshApex(this._allResult);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        switch (action.name) {
            case 'Preview':
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state : {
                        selectedRecordId:row.ContentDocumentId
                    }
                })
                break;
            case 'Download':
                let urlDir = '/sfc/servlet.shepherd/document/download/'+row.ContentDocumentId
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: urlDir
                    }
                }, false);
                break;
            case 'View_File_Details':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.ContentDocumentId,
                        objectApiName: 'ContentDocument',
                        actionName: 'view'
                    }
                });
                break;
            case 'Delete':
                const result = confirm("Are you sure you want to delete this document?");
                if(result){
                    deleteRelatedDocument({ ids: row.ContentDocumentId})
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({title: 'Success', message: 'Record deleted', variant: 'success'})
                        );
                        return refreshApex(this._allResult);
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({ title: 'Error deleting record', message: error.body.message, })
                        );
                    });
                }
                break;
        }
    }

    viewAllAction(){
        this.viewAll = false;
        this.data = this.allDate;
        this.draftValues = [];
        this.clickViewAll = true;
    }
}