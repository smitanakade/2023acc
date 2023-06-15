import { LightningElement, api } from "lwc";
import getRecordCount from "@salesforce/apex/AcfrSendOverDueEmailController.getRecordCount";
import sendOverDueEmail from "@salesforce/apex/AcfrSendOverDueEmailController.sendOverDueEmail";

export default class acfrSendOverDueEmail extends LightningElement {
    @api
    recordId = null;

    @api
    isModalOpen = false;

    @api
    recordFirstCount;

    @api
    recordFinalCount;
    
    @api
    displayFinalOverdue=false;

    @api
    displayFistOverdue=false;

    @api
    providersFound=false;

    connectedCallback() {
        this.init();
    }
	
    init() {
       const action = getRecordCount;
        action().then(response => {

            this.recordFirstCount = response[0];
            this.recordFinalCount = response[1];
            if(this.recordFirstCount>0) {
                this.displayFirstOverdue=true;
                this.providersFound=true;
            }
            if(this.recordFinalCount>0){
                this.displayFinalOverdue=true;
                this.providersFound=true;
            }
            
           
            
        }).catch(response => {
            const errors = response;
            if (errors) {
                if (errors[0] && errors[0].message) {
                    //TO DO implement logger error
                }
            } else {
                //TO DO implement logger error
            }
        });
    }

   handleOpen() {
        //Set isModalOpen attribute to true
        this.isModalOpen = true;
    }

    handleClose() {
        // Set isModalOpen attribute to false  
        this.isModalOpen = false;
    }

    handleSubmitdetails() {
		const action = sendOverDueEmail;
        action().then(_response => {
            this.isModalOpen = false;
        }).catch(response => {
						alert('Something went wrong. Emails are not sent.');
            const errors = response;
            if (errors) {
                if (errors[0] && errors[0].message) {
                    //TO DO implement logger error
                }
            } else {
                //TO DO implement logger error
            }
        });
    }
}