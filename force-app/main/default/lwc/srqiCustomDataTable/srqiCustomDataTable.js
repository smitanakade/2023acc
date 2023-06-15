import LightningDatatable from 'lightning/datatable';
import imageTableControl from './imageTableControl.html';
import serviceVsTargetTemplate from './serviceVsTarget.html';
import servicePerformanceTemplate from './servicePerformance.html';
import buttonColumn from './qiServiceProviderListCustomButton.html';
import pillCustomTemplate from './qiPillCustomButton.html';
import customBadgeTemplate from './customBadge.html';

export default class srqiCustomDataTable extends LightningDatatable {

    static customTypes = {
        richText: {
            template: imageTableControl,
            standardCellLayout: true
        },
        serviceVsTarget: {
            template: serviceVsTargetTemplate,
            standardCellLayout: true,
            typeAttributes: ['isAbove', 'isBelow', 'isEqual',
                'compareToTarget', 'targetValue', 'indicator',
                'serviceValue', 'description', 'isNumber', 'isQI', 'isCM']
        },
        servicePerformance: {
            template: servicePerformanceTemplate,
            standardCellLayout: true,
            typeAttributes: ['description', 'serviceValue', 'isQI', 'isCM']
        },
        buttonColumn: {
            template: buttonColumn,
            standardCellLayout: true,
            typeAttributes: ['recordData','buttonName', 'reportingPeriodId']
        },
        qiPillCustomButton: {
            template: pillCustomTemplate,
            standardCellLayout: true,
            typeAttributes: ['buttonStatus','submittedDate','buttonStyle']
        },
        customBadge: {
            template: customBadgeTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'class']
        }
    };
}