/**
 * @author: AG
 * @Createddate : 30/4/2023
 * @description : LWC TO DISPLAY QI BULK UPLOAD STATUS(FILE STAGING) AND DOWNLOAD THE FILE
 */

import { LightningElement, wire, api} from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import createStagingRecord from '@salesforce/apex/QIBulkUploadUtility.createFileStagingRecord';
import getFilePreviewLink from '@salesforce/apex/QIGetPreviewLink.getLink';
import getFileStorageContentDocumentId from "@salesforce/apex/QiFileUploadController.getFileStorageContentDocumentId";
import FILE_ID from '@salesforce/schema/File_Staging__c.File_Id__c';
import NAME from '@salesforce/schema/File_Staging__c.Name';
import ERRORFILE_ID from '@salesforce/schema/File_Staging__c.Error_FileId__c';
import FILE_CREATEDDATE from '@salesforce/schema/File_Staging__c.File_CreatedDate__c';
import STATUS from '@salesforce/schema/File_Staging__c.Status__c';
import DISPLAY_STATUS from '@salesforce/schema/File_Staging__c.Display_Status__c';
import TOTAL_RECORDS from '@salesforce/schema/File_Staging__c.Total_Records__c';
import SUCCESS_RECORDS from '@salesforce/schema/File_Staging__c.Success_Records__c';
import FAILED_RECORDS from '@salesforce/schema/File_Staging__c.Failure_Records__c';	
import SUBMITTED_BY from '@salesforce/schema/File_Staging__c.Submission_Requested_By__r.Name';
import FILE_NAME from '@salesforce/schema/File_Staging__c.File_Name__c';
import REPORTING_PERIOD from '@salesforce/schema/File_Staging__c.Reporting_Period__r.Reporting_Period_Short__c';
import ISCURRENTREPORTING_PERIOD from '@salesforce/schema/File_Staging__c.Reporting_Period__r.Current_Reporting_Period__c';
import pendingStatusAlert from '@salesforce/label/c.qiFileUploadPending';
import errorStatusAlert from '@salesforce/label/c.qiFileUploadError';
import partialSuccessStatusAlert from '@salesforce/label/c.qiFileUploadPartialSuccess';
import successStatusAlert from '@salesforce/label/c.qiFileUploadSuccess';
import pendingStatusInfo from '@salesforce/label/c.qiFileUploadPendingInfo';
import partialSuccessInfo from '@salesforce/label/c.qiFileUploadPartialSuccessInfo';
import successInfo from '@salesforce/label/c.qiFileUploadSuccessInfo';
import errorInfo from '@salesforce/label/c.qiFileUploadErrorInfo';
import partialErrorAlert from '@salesforce/label/c.qiFileUploadPartialError';
import partialErrorInfo from '@salesforce/label/c.qiFileUploadPartialErrorInfo';
import UPLOADSTATUS_ICON from '@salesforce/resourceUrl/QISRIconsApril2023';
import UserId from '@salesforce/user/Id';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name'
import CONTENTDOCUMENT_ID  from '@salesforce/schema/ContentDocumentLink.ContentDocumentId';
//import { loadScript } from "lightning/platformResourceLoader";
//import COMETD_JS from "@salesforce/resourceUrl/cometd_js";
//import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';



export default class QiFileUploadStatus extends NavigationMixin(LightningElement) {

   
    contentDocumentLinkId ;
    contentDocumentId;
    attachmentID;
    timeref;
    subscription;
    showFileProcessingErrorToast = false;
    fileStagingRecordId;
    unsubcribeEvents;
    fieldId;
    documentId;
    status;
    loggedInUserId = UserId;
    userProfileName;
    fileName;
    recordData={};
    fileStaging;
    FileStagingWrapper ={};
    isLoaded=false;
    profileRediectPage='';
    reportingPeriod;
    isCurrentReportingPeriod;
    quarterType;
    label = {
        pendingStatusAlert,
        errorStatusAlert,
        partialSuccessStatusAlert,
        successStatusAlert,
        pendingStatusInfo,
        partialSuccessInfo,
        successInfo,
        errorInfo,
        partialErrorAlert,
        partialErrorInfo
    };
    isSuccess = false;
    isNotSuccess = false;

    error_icon =  UPLOADSTATUS_ICON + '/error_icon.svg';
    partial_success_icon =  UPLOADSTATUS_ICON + '/partial_success_icon.svg';
    pending_alert_icon =  UPLOADSTATUS_ICON + '/pending_alert_icon.svg';
    pending_info_icon =  UPLOADSTATUS_ICON + '/pending_info_icon.svg';
    success_icon =  UPLOADSTATUS_ICON + '/success_icon.svg';
    lock_icon = UPLOADSTATUS_ICON + '/lock_icon.svg';
    
    /* TO DO ONCE THE PLATFORM EVENT ISSUE IS RESOLVED
    subscription ={};
    //channelName ='/event/File_Preview_Event__e';
    //channelName = '/event/dohagedcare__File_Preview_Event__e';	
    channelName ='/event/dohagedcare__AutoRefresh__e';
    libInitialized = false;
    sessionId;
    error;
    payloadEvents =[];

    */
   
   
    
    //CometD Changes - Start
    // TO DO ONCE THE PLATFORM EVENT ISSUE IS RESOLVED
    /*
    @wire(getSessionId)
    wiredSessionId
    
    
    initializecometd() {
        console.log('initializecometd start ');
        if (this.libInitialized) {
          return;
        }
    
        this.libInitialized = true;
        this.showFileProcessingErrorToast = true;
        this.subscription = null;

        //initializing cometD object/class
        var cometdlib = new window.org.cometd.CometD();
        console.log('initializecometd before configure ');   
        console.log('initializecometd before configure sesssionId ' + JSON.stringify(this.sessionId));         
        //Calling configure method of cometD class, to setup authentication which will be used in handshaking
          cometdlib.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/47.0/',
            requestHeaders: { Authorization: 'OAuth ' + this.sessionId},
            appendMessageTypeToURL : false,
            logLevel: 'debug'
        });
        console.log(`inside 134 initialize cometD`);
        
        cometdlib.websocketEnabled = false;
        let thisReference = this;
        console.log(`inside 138 initialize cometD`);
        cometdlib.handshake(function(status) {
          console.log('initializecometd handshake start '); 
          console.log('handshake start thisReference.channelName ' + thisReference.channelName);       
            if (status.successful) {
                // Successfully connected to the server.
                // Now it is possible to subscribe or send messages
                console.log('Successfully connected to server for preview for channel ' + thisReference.channelName);
                try{
                   console.log('lets subscribe!');
                    
                        thisReference.subscription = cometdlib.subscribe(thisReference.channelName, (message)=> {
                            console.log('subscribed to message!'+ JSON.stringify(message));
                            if (message.data?.payload) {
                            thisReference.responses = message;
                            } 
                            console.log(`*** Playload iss *** ${JSON.stringify(message.data.payload)}`);
                            const payloadValue = JSON.parse(JSON.stringify(message.data.payload));
                            console.log(`*** PlayloadValue iss *** ${payloadValue['dohagedcare__Url__c']}`);
                            if((payloadValue['dohagedcare__Url__c']!=null || payloadValue['dohagedcare__Content_Document_Id__c']!=null) && payloadValue['dohagedcare__Content_Document_Id__c'] === thisReference.documentId){
                            console.log(`payloadValue is ${payloadValue['dohagedcare__Content_Document_Id__c']} && this.documentId is ${thisReference.documentId}`)
                            thisReference.handlePlatformEvents(payloadValue);
                            thisReference.showFileProcessingErrorToast = false;
                            thisReference.unsubcribeEvents = true;
                            }
                            
                            console.log(`value of unsubscribe and toast ${thisReference.showFileProcessingErrorToast} && ${thisReference.unsubcribeEvents } `)
                            if(thisReference.unsubcribeEvents){
                                console.log(`inside unsubscribeEvents`)
                                thisReference.unsubscribe = cometdlib.unsubscribe(thisReference.subscription,(message)=>{
    
                                    console.log(`inside unsubscribe`);
                                    
                                }); 
                            } 
                            if(thisReference.showFileProcessingErrorToast){
                                thisReference.showToast(`Error has occured`,`We are unable to process your request. Please contact the admin`,`error`);
                    
                            }
                            
                        },(messageAvailable)=>{

                            console.log(`value of message is ${JSON.stringify(messageAvailable)}`);
                        });
                        console.log(`outside callback`);
                    
                    
                    
                    

                    //thisReference.unsubscribe(thisReference.subscription);
                    //console.log(`the document is found or not ${thisReference.documentFound}`);
                   
                }
                catch (error) {
                  console.log(
                    "exception at acdsChannelSubscriber::initializecometd: " + error
                  );
                }   
            } else {
                /// Cannot handshake with the server, alert user.
                console.error('Error in handshaking: ' + JSON.stringify(status));
            }
            
        }); 

        console.log(`this payloadEvents is::: ${this.payloadEvents}`);
    }

    */
   //CometD Changes - End

    /* ----TO DO ONCE THE PLATFORM EVENT ISSUE IS RESOLVED

    handleSubscribe(){
        try{
            if(this.wiredSessionId.data != null || this.wiredSessionId.data !== undefined){
                this.sessionId = this.wiredSessionId.data;
                this.error = undefined;
                loadScript(this, COMETD_JS + '/cometd_js/cometd.js').then(() => {
                    console.log(`COMET D has rendered successfully`);
                    this.initializecometd();
                });

                
            }    
        }catch(error){
            console.log("exception at acdsChannelSubscriber::handleSubscribe: " + error);
        } 

        
    }

    handlePlatformEvents(message){
        console.log(`inside pE ${message}`);
        
        console.log(`Message is ${message['dohagedcare__Content_Document_Id__c']} `);
        if(message['dohagedcare__Content_Document_Id__c'] ===this.documentId && message['dohagedcare__Url__c']!=null ){
            console.log(`the url is ${message['dohagedcare__Url__c']}`);
            //this.showFileProcessingErrorToast = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
            attributes: {
              url: message['dohagedcare__Url__c']
            }
          });

        }
    }
    --TO DO ONCE THE PLATFORM EVENT ISSUE IS RESOLVED
    */
    connectedCallback(){

        getFileStorageContentDocumentId({
            fileStagingId: this.fileStagingRecordId
        }).then((result)=>{

            this.documentId = result;
           

        }).catch(error=>{
            this.showToast(`Error Occured. Please contact the admin`, error.body.message,`error`)
        })  


    }

    get headerTitle(){

        return 'Uploaded file status';
    }
    

    properties =[

        {'Pending': 
            { 'iconName':'utility:warning','alertInlineStyle': 'background:#FFA400;', 'infoInlineStyle': 'background:#F7FCFD;',
              'pillInlineStyle':'background:#FFA400;','alertHeader':'Pending', 'alertMessage':this.label.pendingStatusAlert,
              'infoMessage':this.label.pendingStatusInfo, 'showPendingButton':true, 'showOriginalFileLink':false, 'showErrorFileLink':false,
               'alertIcon':this.pending_alert_icon, 'infoIcon':this.pending_info_icon
            } 
        },
        {'Failed': 
            { 'iconName':'utility:wifi','alertInlineStyle': 'background:#E91E63;', 'pillInlineStyle':'background:#E91E63;',
              'infoInlineStyle': 'background:#E91E63;', 'alertHeader':'Error', 'alertMessage':this.label.errorStatusAlert, 
              'infoMessage':this.label.errorInfo, 'showReuploadButton':true,'showOriginalFileLink':true, 'showErrorFileLink':true,
              'alertIcon':this.error_icon, 'infoIcon':this.error_icon
            }     
        },
        {'Partial': 
            { 'iconName':'utility:wifi','alertInlineStyle': 'background:#EDF2EC;', 'pillInlineStyle':'background:#EDF2EC;',
              'infoInlineStyle': 'background:#EDF2EC;','alertHeader':'Partial Success', 'alertMessage':this.label.partialSuccessStatusAlert,
              'infoMessage':this.label.partialSuccessInfo,  'showReuploadButton':true,'showOriginalFileLink':true, 'showErrorFileLink':true,
              'alertIcon':this.partial_success_icon, 'infoIcon':this.partial_success_icon
            }    
        },
        {'Submitted': 
            { 'iconName':'utility:wifi','alertInlineStyle': 'background:#4D8144;', 'pillInlineStyle':'background:#4D8144;color: #ffffff;',
              'infoInlineStyle': 'background:#4D8144;color: #ffffff;','alertHeader':'Success', 'alertMessage':this.label.successStatusAlert,
              'infoMessage':this.label.successInfo, 'showSuccessButton':true,'showOriginalFileLink':true, 'showErrorFileLink':false,
              'alertIcon':this.success_icon, 'infoIcon':this.success_icon
            }     
        },

    
    
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.fileStagingRecordId = currentPageReference.state?.filestagingid;
        }
    }

    

    @wire(getRecord, {recordId:UserId, fields: [PROFILE_NAME]})
    userDetails({data, error}){
        if(data){
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
               
                
            } 
        }
        if(error){
            console.error(error.body.message)
        }

    }

    @wire(getRecord, { recordId:'$contentDocumentLinkId', fields: [CONTENTDOCUMENT_ID] })
    contentdocument({data,error}){
        if(data){
            
            this.contentDocumentId =getFieldValue(data, CONTENTDOCUMENT_ID );
            if(this.contentDocumentLinkId && this.contentDocumentId){
                this.recordData = {...this.recordData, ...{'errorFileId':this.contentDocumentId}
            
                }
                
            }
        }
        if(error){
            console.error(error.body.message)
        }

        

    }

    @wire(getRecord,{recordId:'$fileStagingRecordId', 
        fields:[NAME,FILE_ID,ERRORFILE_ID,STATUS, DISPLAY_STATUS,SUBMITTED_BY,TOTAL_RECORDS,SUCCESS_RECORDS,
            FAILED_RECORDS,FILE_NAME,FILE_CREATEDDATE, REPORTING_PERIOD, ISCURRENTREPORTING_PERIOD]
        })
    recordDetails({data,error}){
        if(data){
            this.name = getFieldValue(data, NAME);
            this.fileId=getFieldValue(data,FILE_ID);
            this.status=getFieldValue(data,STATUS);
            this.fileCreatedDate=getFieldValue(data,FILE_CREATEDDATE);
            this.displayStatus=getFieldValue(data,DISPLAY_STATUS);
            this.submittedBy=getFieldValue(data,SUBMITTED_BY);
            this.fileName=getFieldValue(data,FILE_NAME);
            this.totalRows = getFieldValue(data,TOTAL_RECORDS)!=null? getFieldValue(data,TOTAL_RECORDS):'-';
            this.numberSubmitted = getFieldValue(data,SUCCESS_RECORDS)!=null? getFieldValue(data,SUCCESS_RECORDS):'-';
            this.failedRecords = getFieldValue(data,FAILED_RECORDS)!=null? getFieldValue(data,FAILED_RECORDS): '-';
            this.errorFileId = getFieldValue(data,ERRORFILE_ID);
            this.contentDocumentLinkId = getFieldValue(data,ERRORFILE_ID);
            this.reportingPeriod = getFieldValue(data,REPORTING_PERIOD);
            this.isCurrentReportingPeriod = getFieldValue(data,ISCURRENTREPORTING_PERIOD);
            this.dateSubmitted = this.formatDateddmmyyyy(this.fileCreatedDate);
            this.quarterType = this.isCurrentReportingPeriod==false? '(Past)':'(Current)';
            const statusValue = data.fields['Display_Status__c'].value;
            this.properties.forEach((item)=>{
                
                if(item[statusValue]){
                    this.recordData ={...data,...item[statusValue],...{'displayStatus':this.displayStatus},...{'fileId':this.fileId},...{'name':this.name},
                        ...{'totalRows':this.totalRows},...{'numberSubmitted':this.numberSubmitted},...{'failedRecords':this.failedRecords},
                        ...{'fileName':this.fileName},...{'submittedBy':this.submittedBy},...{'dateSubmitted':this.dateSubmitted},...{'errorFileId':this.errorFileId},
                        ...{'reportingPeriod':this.reportingPeriod},...{'quarterType':this.quarterType}
                    
                                 
                    }
                }

            })

            if(data.fields['Display_Status__c'].value==='Failed' && data.fields['Status__c'].value==='Failed'){

                this.recordData = {...this.recordData,...{'alertMessage':this.label.errorStatusAlert},
                    ...{'infoMessage':this.label.errorInfo}, ...{'showOriginalFileLink':false}, ...{'showErrorFileLink':false}
                }
            }
            if(data.fields['Display_Status__c'].value==='Failed' && data.fields['Status__c'].value!=='Failed'){

                this.recordData = {...this.recordData,...{'alertMessage':this.label.partialErrorAlert},
                    ...{'infoMessage':this.label.partialErrorInfo}
                }
            }
            
            
        }
        if(error){
            console.error(error.body.message);
        }

        if (this.recordData.alertHeader === "Success") {
          this.isSuccess = true;
          this.isNotSuccess = false;
        } else {
          this.isSuccess = false;
          this.isNotSuccess = true;
        }
    }
    
    clickHandler(event){
        
        const fileStagingParam ={ 
            userIdAura:this.loggedInUserId,
            fileStagingRecordIdAura:event.target.value,
            fileName:this.fileName

        }
        this.isLoaded=!this.isLoaded;
        this.fileStaging= createStagingRecord({
            fileStagingWrapper: fileStagingParam
        }).then((result)=>{
            this.isLoaded=!this.isLoaded;
            this.showToast(`Record is created successfully`,'You will be redirected to File Upload screen','success')
            this.navigateToPage('QI_File_Upload__c',result.Id);
            

        }).catch(error=>{
            this.showToast(`Error Occured. Please contact the admin`, error.body.message,`error`)
            this.isLoaded=!this.isLoaded;
        })
        //this.isLoaded=!this.isLoaded;  
    }


    /*getFileStorageContentDocumentId(recordId){
        
        getFileStorageContentDocumentId({
            fileStagingId: recordId
        }).then((result)=>{

            console.log(`the file id is ${result}`);
            this.documentId = result;
            console.log(`the this.documentId  is ${this.documentId }`);

        }).catch(error=>{
            this.showToast(`Error Occured. Please contact the admin`, error.body.message,`error`)
        })  

    }*/


    getFilePreviewLink(event){
        this.isLoaded=!this.isLoaded;
       
        const {fileid,recordid,type} = event.target.dataset;
        if(type==='Original'){
            
            this.attachmentID =this.documentId;
           
        }
        
        if(type==='Error'){
            this.attachmentID= fileid;
        }
        
        
        if(this.attachmentID==null || this.attachmentID ==undefined){
            this.isLoaded=!this.isLoaded;
            this.showToast(`System is temporarily unavailable `,`Please try again later. If the problem persists, please contact the My Aged Care service provider and assessor helpline on 1800 836 799. The helpline is open Monday to Friday between 8am-8pm and Saturday between 10am-2pm.`,`error`);
           
        }

        if(this.attachmentID!=null || this.attachmentID !=undefined){
            getFilePreviewLink({
                parentRecID:recordid,
                attachmentID:this.attachmentID
            }).then((result)=>{
                this.isLoaded=!this.isLoaded;
               if(result.includes('https://')){
                    window.open(result,"_blank");
                }
                if(result.includes('WAIT')){
                    // TO DO ONCE THE PLATFORM EVENT ISSUE IS RESOLVED
                    //this.handleSubscribe();
                    this.showToast(`Failed to download large files`,`Please contact the My Aged Care service provider and assessor helpline on 1800 836 799 to help download your file. The helpline is open Monday to Friday between 8am-8pm and Saturday between 10am-2pm.`,`warning`);
                }
                if(result.includes('error')){
                    this.showToast(`System is temporarily unavailable `,`Please try again later. If the problem persists, please contact the My Aged Care service provider and assessor helpline on 1800 836 799. The helpline is open Monday to Friday between 8am-8pm and Saturday between 10am-2pm.`,`error`);
                    
                }
                
            }).catch(error=>{
    
                console.error(error.body.message)
            })

        }
        
        
    }

    showToast(title,message,variant){
        this.dispatchEvent(new ShowToastEvent({

            title,
            message,
            variant
        }))


    }

    navigateToPage(pageName,recordId) {
        if (pageName) {
            this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: pageName
                    },
                    state:{
                        'fileStagingId':recordId,
                        'isReupload':true
                    }
                },
                true
            );
        }
    }

    redirectToPage(pageName) {
        if (pageName) {
            this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: pageName
                    }
                },
                true
            );
        }
    }

    redirectToMainPage(event){
        
        if(this.userProfileName=='QI Benchmarker'){
            this.profileRediectPage='QI_File_Upload_History__c';

        }
        if(this.userProfileName!='QI Benchmarker'){
            this.profileRediectPage='Quality_Indicator_Details__c';
        }
        
        this.redirectToPage(this.profileRediectPage);

    }

    formatDateddmmyyyy(dateTime) {
        if (!dateTime) {
            return null;
        }
       
        const date = dateTime.split('T')[0];
        const day = date.substring(date.lastIndexOf("-") + 1, date.length);
        const month = date.substring(date.indexOf("-") + 1, date.lastIndexOf("-"));
        const year = date.substring(0, date.indexOf("-"));
        return day + '/' + month + '/' + year;
    }




}