import { LightningElement, api } from "lwc";
import getEmailContent from "@salesforce/apex/AcfrEmailTemplateBuilderController.getEmailContent";
import getEmailSubject from "@salesforce/apex/AcfrEmailTemplateBuilderController.getEmailSubject";
import getEmailAddress from "@salesforce/apex/AcfrEmailTemplateBuilderController.getEmailAddress";
import getEmailAddressCC from "@salesforce/apex/AcfrEmailTemplateBuilderController.getEmailAddressCC";
import sendSingleEmailMethod from "@salesforce/apex/AcfrEmailTemplateBuilderController.sendSingleEmailMethod";

export default class customEmailTemplateBuilder extends LightningElement {
    @api
    recordId = null;

    @api
    emailBody;

    @api
    emailAdd;

    @api
    emailAddCC;

    @api
    emailResult;

    @api
    emailSubject;

    @api
    editable = false;

    @api
    isSent = false;

    connectedCallback() {
        this.init();
    }

    init() {
    getEmailContent({ recordId: this.recordId })
		.then(result => {
			this.emailBody = result;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			});

    getEmailSubject({ recordId: this.recordId })
		.then(result => {
			this.emailSubject = result;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			});

    getEmailAddress({ recordId: this.recordId })
		.then(result => {
			this.emailAdd = result;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			});

    getEmailAddressCC({ recordId: this.recordId })
		.then(result => {
			this.emailAddCC = result;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			});
    }

    handleEdit() {
        this.editable = true;
    }

	handleSend() {
			sendSingleEmailMethod({ 
					recordId:this.recordId,
					emailBody: this.emailBody,
					emailAddress:this.emailAdd,  
					emailAddressCC:this.emailAddCC, 
					emailSubject:this.emailSubject
			})
				.then(_result => {
					this.isSent = true;
					this.emailResult = "Email has been sent.";
					this.error = undefined;
			})
					.catch(error => {
					this.isSent = true;
					this.emailResult = "Something went wrong. Email not sent.";
					this.error = error;
			});
	}

    handlePreview() {
				this.editable = false;
    }
		
		handleEmailBody(event){
				this.emailBody = event.target.value;
		}
		
		handleEmailAdd(event){
				this.emailAdd = event.target.value;
		}
		
		handleEmailAddCC(event){
				this.emailAddCC = event.target.value;
		}
		
		handleEmailSubject(event){
				this.emailSubject = event.target.value;
		}

}