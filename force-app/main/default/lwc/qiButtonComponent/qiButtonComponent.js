import { LightningElement, api } from 'lwc';
import BANNER_ICONS from '@salesforce/resourceUrl/QISRIconsApril2023';


export default class QiButtonComponent extends LightningElement {

    
    @api recordData;
    @api buttonName;
    @api reportingPeriodId;
    hasRendered = false;
    showOfflineIcon = false;

    lock_icon =  BANNER_ICONS + '/lock_icon.svg';
    

    handleClick() {
        const data ={recordData:this.recordData, buttonName:this.buttonName, reportingPeriodId:this.reportingPeriodId};
        
        const event = new CustomEvent('buttonmethod', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: data,
        });

        this.dispatchEvent(event);
    }

    renderedCallback(){

        if(this.hasRendered){
            return
        }else{
            const buttonElement = this.template.querySelectorAll('.button-class');
            if(buttonElement){
                Array.from(buttonElement).forEach(item=>{
                    if(item.name==='' || item.name===null){
                        item.class="all:revert";
                        item.classList.add('slds-hidden');

                    }
                    if(item.name==='Start' || item.name==='View'){
                       
                        item.style= 'padding:5px 5px 5px 30px';

                    }
                    if(item.name==='Offline'){

                        this.showOfflineIcon= true;
                    }
                    
                })

            }
            this.hasRendered=true;

        }
    }

}