import { LightningElement , wire } from 'lwc';
import getReportingQuarters from '@salesforce/apex/QIReportingController.getReportingQuarters';


export default class QiReportingPeriod extends LightningElement {
    periods;
    error;
    yearMin;
    yearMax;
    @wire(getReportingQuarters)
    wiredgetReportingPeriod({ error, data }) {
        if (data) {
            this.periods = [];
            for (let i = 0; i < data.length; i++) {
                let quarter;
                if(data[i].Reporting_Period_Short__c){
                    if(data[i].Reporting_Period_Short__c .startsWith('Quarter 1')){
                        quarter = 'Q1: ';
                        this.yearMin = data[i].Start_Date__c.split('-')[0];
                    }else if (data[i].Reporting_Period_Short__c .startsWith('Quarter 2')){
                        quarter = 'Q2: ';
                    }else if(data[i].Reporting_Period_Short__c .startsWith('Quarter 3')){
                        quarter = 'Q3: ';
                    }else if(data[i].Reporting_Period_Short__c .startsWith('Quarter 4')){
                        quarter = 'Q4: ';
                        this.yearMax = data[i].Start_Date__c.split('-')[0].substr(2);
                    }
                }else{
                    quarter = 'N/A';
                }

                this.periods.push({ 
                    key: data[i].Id, 
                    quarter: quarter , 
                    dueDate: data[i].QI_Submission_Due_Dt__c.split('-')[2] + ' ' + this.getMonthLitteral(data[i].QI_Submission_Due_Dt__c.split('-')[1]) + ' ' + data[i].QI_Submission_Due_Dt__c.split('-')[0],
                    startDate: data[i].Start_Date__c.split('-')[2] + ' ' + this.getMonthLitteralShort(data[i].Start_Date__c.split('-')[1]) + ' ' + data[i].Start_Date__c.split('-')[0], 
                    endDate: data[i].End_Date__c.split('-')[2] + ' ' + this.getMonthLitteralShort(data[i].End_Date__c.split('-')[1]) + ' ' + data[i].End_Date__c.split('-')[0] });
            }
            this.periods.sort();
        } else if (error) {
            this.error = error;
        }
    }

    getMonthLitteral(month){
        switch(month) {
            case '01':
                return 'January';
            case '02':
                return 'February';
            case '03':
                return 'March';
            case '04':
                return 'April';
            case '05':
                return 'May';
            case '06':
                return 'June';
            case '07':
                return 'July';
            case '08':
                return 'August';
            case '09':
                return 'November';
            case '10':
                return 'October';
            case '11':
                return 'September';
            case '12':
                return 'December';
            default:
                return 'Error';
          }
    }

    getMonthLitteralShort(month){
        switch(month) {
            case '01':
                return 'Jan';
            case '02':
                return 'Feb';
            case '03':
                return 'Mar';
            case '04':
                return 'Apr';
            case '05':
                return 'May';
            case '06':
                return 'Jun';
            case '07':
                return 'Jul';
            case '08':
                return 'Aug';
            case '09':
                return 'Sep';
            case '10':
                return 'Oct';
            case '11':
                return 'Nov';
            case '12':
                return 'Dec';
            default:
                return 'Error';
          }
    }
}