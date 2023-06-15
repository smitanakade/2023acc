import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCurrentQISList from '@salesforce/apex/QIDynamicManagementController.getCurrentQISList';
import createNewQI from '@salesforce/apex/QIDynamicManagementController.createNewQI';

const createButtonLabel = 'Create QI for Current Quarter';
const manageButtonLabel = 'Manage Current Quarter';

export default class QiDynamicManagement extends NavigationMixin(LightningElement) {
    @api recordId;
    error;
    QISResponse;
    newQISRecord;
    buttonLabel;
    isManage;

    @wire(getCurrentQISList, { serviceId: '$recordId' })
    wiredResponse({ data, error }) {
        if (data) {
            this.QISResponse = JSON.parse(data);
            if (this.QISResponse.isEmpty) {
                this.buttonLabel = createButtonLabel;
                this.isManage = false;
            } else {
                this.buttonLabel = manageButtonLabel;
                this.isManage = true;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            const newError = new ShowToastEvent({
                "tittle": "Error",
                "message": error.body.message,
                "variant": "error"
            });
            this.dispatchEvent(newError);
        }
    }

    handleClick(event) {
        if (this.isManage) {
            event.preventDefault();
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.QISResponse.id,
                    actionName: 'view'
                }
            });
        } else {
            createNewQI({ serviceId: this.recordId })
            .then(result => {
                this.newQISRecord = JSON.parse(result);
                this.error = undefined;
                const success = new ShowToastEvent ({
                    "title": "Success!",
                    "message": "Quality Indicator Summary created successfully",
                    "variant": "success"
                });
                this.dispatchEvent(success);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.newQISRecord.id,
                        actionName: 'view',
                    },
                });
            })
            .catch(error => {
                this.error = error;
                this.newQISRecord = undefined;
                const newError = new ShowToastEvent({
                    "tittle": "Error",
                    "message": error.body.message,
                    "variant": "error"
                });
                this.dispatchEvent(newError);
            });
        }
    }
}