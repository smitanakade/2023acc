import { LightningElement,wire,api, track } from 'lwc';
import getSummary from '@salesforce/apex/SRQIQuestionDataCaptureFormController.getSummary' ;
import getQIStatus from '@salesforce/apex/SRQIQuestionDataCaptureFormController.getQIStatus' ;
import getLastModifiedDetails from '@salesforce/apex/SRQIQuestionDataCaptureFormController.getLastModifiedDetails' ;
import BANNER_ICONS from '@salesforce/resourceUrl/QISRIconsApril2023';
import {refreshApex} from '@salesforce/apex';


import { CurrentPageReference} from 'lightning/navigation';


//import message service features 
import {publish ,subscribe , MessageContext} from 'lightning/messageService';
import SERVICE_CHANNEL from '@salesforce/messageChannel/Button_Clicked__c';
import DATA_SAVED_CHANNEL from '@salesforce/messageChannel/Data_Saved__c';


export default class QIReportingPeriodHeader extends LightningElement {
    summaryId;
    dataToRefresh;
    summary;
    error;
    serviceProvider;
    reportingPeriod;
    serviceId;
    dueDate;
    buttonStatus;
    @api reponse = [];
    @api errorValidation =[];
    //Audit details
    lastEditedBy;
    lastModifiedDate;
    ampm = false;
    @track status;

    //icons
    save =  BANNER_ICONS + '/save.svg';
    close = BANNER_ICONS + '/close_icon.svg';
    view = BANNER_ICONS + '/view_history.svg';
    upload = BANNER_ICONS + '/upload_file.svg';

    @wire(MessageContext)
    messageContext;

    //get qiSummaryId
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.summaryId = currentPageReference.state?.qisid;
            this.serviceId = currentPageReference.state?.sproviderId;
            this.status = currentPageReference.state?.status;
        }
    }
   
    async  handleSave(){
      
        try{
            this.reponse = await getQIStatus({
                summaryId: this.summaryId
              });
           
              if(this.reponse.length>0){
                for(const res of this.reponse){
                    this.errorValidation.push({Type:res.RecordType.Name});
                  if(res.Error_Flag__c !== undefined){
                    this.errorValidation = this.errorValidation.map((errValid) => {
                        if(errValid.Type === res.RecordType.Name ){
                            errValid= {...errValid,Error_Flag__c:res.Error_Flag__c};

                        }
                        return errValid;
                    });
                }
                     }
                     const payload = {buttonClicked: this.errorValidation};
                     publish(this.messageContext , SERVICE_CHANNEL, payload );
              }
            }catch (error) {
                console.error(error.body.message);
              }
    }

    handleClose(){
        const payload = {buttonClicked: 'close'};
        publish(this.messageContext , SERVICE_CHANNEL, payload );
    }

    /**
     * Get the user who last made changes to a qid. Only display the name of external users
     */
    @wire (getLastModifiedDetails , { summaryId: '$summaryId' })
    getLastModifiedDetails(result){
        this.dataToRefresh  = result;
        const{data, error} = result;
        if(data){
            this.setLastModifiedInfo(data);
        }else{
            this.error = error;
            this.data = undefined;
        }
    }

    setLastModifiedInfo(data){
        const parsed = JSON.parse(data);
        this.lastEditedBy = parsed.lastModifiedByName;
        this.lastModifiedDate = new Date(parsed.lastModifiedDate); 
        if(parsed.isInternal){
            this.lastEditedBy = 'Department user';
        }
    }
    
    @wire (getSummary , { summaryId: '$summaryId' })
    wiredSummaries({error , data}){
        if(data){
            this.summary = data;
            this.error = undefined;
            this.serviceProvider = this.summary.Service__r.Name;
            this.reportingPeriod = data.REPORTING_PERIOD__r.Reporting_Period__c.replace("- Current reporting period", "").replace("- Previous reporting period", "");
            this.dueDate =  this.summary.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c.split('-')[2] + ' ' + 
                            this.getMonthLitteral(this.summary.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c.split('-')[1]) + ' ' + 
                            this.summary.REPORTING_PERIOD__r.QI_Submission_Due_Dt__c.split('-')[0];
            this.status=this.summary.Status__c;
        }else{
            this.error = error;
            this.data = undefined;
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
                return 'September';
            case '10':
                return 'October';
            case '11':
                return 'November';
            case '12':
                return 'December';
            default:
                return 'Error';
          }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();  
    }

    //refresh last modified information
    subscribeToMessageChannel(){
        this.subscription = subscribe(
            this.messageContext,
            DATA_SAVED_CHANNEL, 
            (message) => refreshApex(this.dataToRefresh)
        );
    }
}