import { LightningElement , api} from 'lwc';


export default class QiPillComponent extends LightningElement {

    @api buttonStatus;
    @api submittedDate;
    @api buttonStyle;
    hasRendered=false;
    statusFirstText;
    statusLastText;
    
    

   

    get checkDateRendering(){

        if(this.buttonStatus==='Submitted - Updated After Due Date' || this.buttonStatus==='Late Submission' || this.buttonStatus==='Submitted' ){
            return true;
        }

        return false;
    }

    get isUpdatedAfterButton(){

        if(this.buttonStatus==='Submitted - Updated After Due Date'){
            this.statusFirstText = 'Submitted';
            this.statusLastText = '(Updated)';
            return true;
        }
        if(this.buttonStatus==='Late Submission'){
            this.statusFirstText = 'Late';
            this.statusLastText = 'Submission';
            return true;
        }
        if(this.buttonStatus==='In Progress'){
            this.statusFirstText = 'In-Progress';
            return true;
        }

        return false;
    }

    
}