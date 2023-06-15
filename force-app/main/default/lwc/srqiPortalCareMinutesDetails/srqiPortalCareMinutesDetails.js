import {api, LightningElement} from "lwc";
import {loadStyle} from "lightning/platformResourceLoader";
import srqiStyles from '@salesforce/resourceUrl/srqi_styles';

let cssLoaded = false;
const cellFontStyle = 'font-size: 16px;';
const columns = [
    {
        label: 'Staffing category',
        type: 'richText',
        fieldName: 'name',
        hideDefaultActions: true,
        wrapText: true,
        cellAttributes: {
            style: "font-size: 20px; height: 80px; font-weight: 500;"
        }
    },
    {
        label: 'Minimum target',
        type: 'richText',
        hideDefaultActions: true,
        wrapText: true,
        fieldName: 'target',
        cellAttributes: {
            style: cellFontStyle
        }
    },
    {
        label: 'Achieved',
        type: 'richText',
        hideDefaultActions: true,
        wrapText: true,
        fieldName: 'actual',
        cellAttributes: {
            style: cellFontStyle
        }
    },
    {
        label: 'Your performance',
        type: 'richText',
        hideDefaultActions: true,
        wrapText: true,
        fieldName: 'indicator',
        cellAttributes: {
            style: cellFontStyle
        }
    }];

export default class srqiPortalCareMinutesDetails extends LightningElement {
    @api srhRecord;
    @api fieldMappingJSON;

    // Expected JSON field mapping example as below
    /*
        [
         {
            "name": "Total nursing and personal care",
            "description": "nursing and personal care",
            "actualFieldName": "Care_Minutes_Id__r.Actual_Care_Minutes__c",
            "targetFieldName": "Care_Minutes_Id__r.Total_Care_Minutes_Target__c"
          },
          {
            "name": "Care from a registered nurse",
            "description": "registered nurse",
            "actualFieldName": "Care_Minutes_Id__r.Actual_Registered_Nursing_Minutes__c",
            "targetFieldName": "Care_Minutes_Id__r.Registered_Nurse_Care_Minutes_Target__c"
          }
        ]
    */
    get fieldMappingList() {
        return this.fieldMappingJSON ? JSON.parse(this.fieldMappingJSON) : {};
    }

    dataTableColumns = columns;
    ratingDetails;

    getFieldValue(record, fieldMapping) {
        const fieldLayers = fieldMapping.split('.');
        let value;
        if (record) {
            value = JSON.parse(JSON.stringify(record));
            for (const fieldLayer of fieldLayers) {
                value = value?.[fieldLayer];
            }
        }
        return value;
    }

    getIndicator(actualValue, targetValue) {
        if (actualValue === targetValue) {
            return 'Equal to target';
        } else if (actualValue < targetValue) {
            return 'Below target';
        } else if (actualValue > targetValue) {
            return 'Above target';
        } else {
            return '';
        }
    }

    transformRatingDetails() {
        this.ratingDetails = [];
        for (const mapping of this.fieldMappingList) {
            this.ratingDetails.push({
                name: mapping.name,
                description: mapping.description,
                target: `${this.getFieldValue(this.srhRecord, mapping.targetFieldName)} minutes`,
                actual: `${this.getFieldValue(this.srhRecord, mapping.actualFieldName)} minutes`,
                indicator: this.getIndicator(this.getFieldValue(this.srhRecord, mapping.actualFieldName), this.getFieldValue(this.srhRecord, mapping.targetFieldName))
            });
        }
    }

    renderedCallback() {
        if (!cssLoaded) {
            loadStyle(this, srqiStyles + '/portal.css');
            cssLoaded = true;
        }
    }

    connectedCallback() {
        this.transformRatingDetails();
    }
}