const columns = [
    {
        label: 'Upload ID',
        fieldName: 'uploadId',
        sortable: 'true',
        initialWidth: 170,
        cellAttributes: {
            class: 'slds-text-color_weak'
        }
    },
    {
        label: 'File name',
        fieldName: 'fileName',
        sortable: 'true'
    },
    {
        label: 'Reporting quarter',
        fieldName: 'reportingQuarter',
        sortable: 'true',
        initialWidth: 150
    },
    {
        label: 'Submitted date',
        fieldName: 'submittedDate',
        sortable: 'true',
        initialWidth: 130,
        type: 'date-local',
        typeAttributes: {
            day: '2-digit',
            month: '2-digit'
        }
    },
    {
        label: 'Total',
        fieldName: 'totalRecords',
        initialWidth: 80
    },
    {
        label: 'Submitted',
        fieldName: 'successRecords',
        initialWidth: 110,
        cellAttributes: {
            class: 'slds-text-color_success'
        }
    },
    {
        label: 'Failed',
        fieldName: 'failureRecords',
        initialWidth: 80,
        cellAttributes: {
            class: 'slds-text-color_error'
        }
    },
    {
        label: 'Status',
        fieldName: 'status',
        initialWidth: 100,
        type: 'customBadge',
        typeAttributes: {
            label: {
                fieldName: 'status'
            },
            class: {
                fieldName: 'statusClass'
            }
        }
    },
    {
        label: '',
        initialWidth: 90,
        type: 'button',
        typeAttributes: {
            name: 'view',
            label: 'View',
            title: 'View record',
            variant: 'brand'
        }
    }
];

export {
    columns
};