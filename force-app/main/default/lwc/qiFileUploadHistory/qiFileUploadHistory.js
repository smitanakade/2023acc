import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { showErrorToast } from 'c/qiUtils';
import { columns } from './dataTableSetup';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import getFileUploadHistory from '@salesforce/apex/QIFileUploadHistoryController.getFileUploadHistory';
import userId from '@salesforce/user/Id';
import USER_PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

export default class QiFileUploadHistory extends NavigationMixin(LightningElement) {
    dataTableColumns = columns;
    allRecords = [];
    visibleRecords = [];

    @wire(getRecord, { recordId: userId, fields: [ USER_PROFILE_NAME_FIELD ] })
    user;

    async connectedCallback() {
        await this.getData();
    }

    async getData(filters) {
        try {
            this.allRecords = await getFileUploadHistory({ filterJSON: JSON.stringify(filters) });
            this.setCSSProperties();
        } catch(error) {
            showErrorToast(this, error.body.message);
        }
    }

    /**
     * Sorts records by the given field and direction.
     * @note If field value is undefined then record will be sorted as the lesser record
     * @note If field values are equal then records will be sorted by created date descending
     * @param {string} fieldName Field to sort by
     * @param {string} sortDirection Direction to sort by (asc/desc)
     */
    sortData(fieldName, sortDirection) {
        const direction = sortDirection === 'asc' ? 1 : -1;
        const data = [...this.allRecords];
        this.allRecords = data.sort((a, b) => {
            let sortResult;

            if (a[fieldName] === undefined && b[fieldName] === undefined) {
                return a['createdDate'] > b['createdDate'] ? -1 : 1;
            } else if (a[fieldName] === undefined) {
                sortResult = -1;
            } else if (b[fieldName] === undefined) {
                sortResult = 1;
            } else if (a[fieldName] === b[fieldName]) {
                return a['createdDate'] > b['createdDate'] ? -1 : 1;
            } else {
                sortResult = a[fieldName] > b[fieldName] ? 1 : -1;
            }

            return direction * sortResult;
        });
    }

    setCSSProperties() {
        this.allRecords = this.allRecords.map(record => ({
            ...record,
            statusClass: `qi-file-upload-status ${record.status?.toLowerCase()}` 
        }));
    }

    handleSortUpdate(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortedDirection);
    }

    handlePagination(event) {
        this.visibleRecords = event.detail.records;
    }

    handleFilterUpdate(event) {
        const filters = event.detail;
        this.getData(filters);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const record = event.detail.row;
        if (action.name === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Quality_Indicator_File_Upload_status__c'
                },
                state: {
                    filestagingid: record.id
                }
            });
        }
    }

    get isBenchmarkerUser() {
        if (this.user.data) {
            return 'QI Benchmarker' === getFieldValue(this.user.data, USER_PROFILE_NAME_FIELD);
        } else {
            return false;
        }
    }
}