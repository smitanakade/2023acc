import { LightningElement ,api, wire} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRelatedListInfo from '@salesforce/apex/GPMSRelatedListController.getRelatedListInfo';
import generateReportURL from '@salesforce/apex/GPMSRelatedListController.generateReportURL';
import generateNewButtonURL from '@salesforce/apex/GPMSRelatedListController.generateNewButtonURL';

export default class GpmsRelatedList extends NavigationMixin(LightningElement) {

    @api recordId;
    @api relatedListTitle;
    @api relatedListName;
    @api targetObject;
    @api targetField;
    @api condition;
    @api reportname;
    @api objectName;
    @api limit;
    @api icon;
    @api recordtype;
    @api displayNewButton;
    @api disableEdit;
    @api disableDelete;

    editAccess;
    deleteAccess;
    relatedLists = [];
    count;
    showViewAll;
    showAction;
    _allResult;

    @wire(generateNewButtonURL, { recordTypeName: '$recordtype',targetObject: '$targetObject', targetField: '$targetField' , recordId: '$recordId'})
    newbuttonurl

    @wire(getRelatedListInfo, { relatedListName: '$relatedListName',targetObject: '$targetObject',targetField: '$targetField',recordId: '$recordId',condition: '$condition',count: '$limit'})
    relatedListInfos(wireResult) {

        const { data, error } = wireResult;
        this._allResult = wireResult;

        if (data) {
            this.count = data.recordCount;
            this.showViewAll = data.showViewAll;
            this.showAction = data.showAction;
            let relatedrecords = []
            for(const record of data.records ){
                if(this.disableEdit){
                    this.editAccess = false;
                }else{
                    this.editAccess = data.HasEditAccess;
                }
                if(this.disableDelete){
                    this.deleteAccess = false;

                }else{
                    this.deleteAccess = data.HasDeleteAccess;
                }
                relatedrecords.push(relatedListRecord(record, data.fields, this.editAccess, this.deleteAccess));
            }
            this.relatedLists = relatedrecords
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.relatedLists = undefined;
        }
    }
    
    @wire(generateReportURL, { reportname: '$reportname',objectName: '$objectName', recordId: '$recordId'})
    reportURL

    handleAction(event) {
        const action = event.detail.action;
        switch (action.value) {
            case 'edit':
                const config = {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: action.name,
                        objectApiName: this.targetObject,
                        actionName: "edit"
                    }
                };
                this[NavigationMixin.Navigate](config);
                break;
            case 'delete':
                deleteRecord(action.name)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({title: 'Success', message: 'Record deleted', variant: 'success'})
                    );
                })
                .then(()=>{
                    refreshApex(this._allResult);
                })
                break;
        }

    }

}

export function relatedListRecord(record, fields, HasEditAccess, HasDeleteAccess){

    const EDIT_ACTION = {label: 'Edit', value: 'edit'};
    const DELETE_ACTION = {label: 'Delete', value: 'delete'};

    const relatedrecord = {}
    
    relatedrecord.Id = record.Id;
    relatedrecord.Name = record.Name;
    relatedrecord.targetId = '/'+record.Id;

    const actions = []
    DELETE_ACTION.name = record.Id;
    EDIT_ACTION.name = record.Id;
    if(HasEditAccess) {
        actions.push(EDIT_ACTION)
    }
    if(HasDeleteAccess) {
        actions.push(DELETE_ACTION)
    }
    relatedrecord.actions = actions;

    let rows = [];
    for(const field of fields){
        const row = {};
        const number10 = 10;
        row.title = field.MasterLabel;
        row.target = '/' + record[field.Target_Field__c];
        row.value = record[field.Field_Api__c];
        row.type = field.Field_Type__c;
        if(row.type === 'date' && row.value){
            const dateList = row.value.split("-");
            const day = dateList[2]<number10?dateList[2].substring(1):dateList[2];
            const month = dateList[1]<number10?dateList[1].substring(1):dateList[1];
            row.value = day + '/' + month + '/' + dateList[0];
        }

        if(row.type === 'percentage' && row.value){
            row.value = row.value + '%'
        }
        

        if(field.LookUp_Field__c){
            const fieldLayers = field.Field_Api__c.split(".");
            if(record[fieldLayers[0]]){
                row.value = record[fieldLayers[0]][fieldLayers[1]];
            }
        }
        row.lookup = field.LookUp_Field__c
        rows.push(row);
    }
    relatedrecord.lists = rows

    return relatedrecord;

}