import {api, LightningElement} from 'lwc';

const columns = [
    {label: 'File Staging Id', fieldName: 'Id'},
    {label: 'ContentDocumentId', fieldName: 'File_Id__c'},
    {label: 'OwnerId', fieldName: 'OwnerId'},
    {label: 'Title', fieldName: 'Name'},
    {label: 'Status', fieldName: 'Status__c'},
    {label: 'File Created Date', fieldName: 'File_CreatedDate__c'}
];

export default class srqiReadFile extends LightningElement {
    @api sfData;
    columnsFileStaging = columns;
}