import { LightningElement} from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class ManageOffline extends OmniscriptBaseMixin(LightningElement) {
    allotments;
    selectedId;
    
    connectedCallback() {
        if(this.omniJsonData.RecordNoticeOfTransferDetails.Allotment != null){
            const recordJson = this.omniJsonData.RecordNoticeOfTransferDetails.Allotment;
            this.allotments = [].concat(JSON.parse(JSON.stringify(recordJson))).filter( allotment => allotment?.PendingEvents == null);

            this.allotments.forEach(allotment => {
                allotment.Place = allotment?.Place ? [].concat(allotment.Place) : null;
            });
            
        }

        this.updateOutput();
        
    }

    updateOutput() {
        const ouputData = {
            "selectedId": this.selectedId,
          }
    
        this.omniUpdateDataJson(ouputData);
    }

    updateSelection() {
        var elements = this.template.querySelectorAll(".allotmentId");
        
        for(let element of elements)  {
            if(element.checked) {
                this.selectedId = element.value;
            }
            
        }
        
        this.updateOutput();
    }
}