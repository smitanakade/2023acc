import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsNATSIFACReinstatePlaces extends OmniscriptBaseMixin(LightningElement) {
    @track allotment;
    success = false;

    connectedCallback() {

      if(this.omniJsonData.Reinstate != null){
        const allotmentPlacesOmni = this.omniJsonData.Reinstate;
        let allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)))
        
        allPlaces.forEach(place => {
          place.NumberOfChanges = 0;
          place.numberOfAfterReinstated = place.NumberofPlaces;
          place.oldPlacesStatus = place.StatusofPlaces;
          place.PacketUrl = '/' + place.Id;
        })

        this.allotment = allPlaces;

        this.updateData();

      }
    }

    updateData(){

      const allAllotment = this.allotment;

      const total = allAllotment.reduce((totalCeaseNumber, currentAllotment) => { 
        return totalCeaseNumber + Math.floor(currentAllotment.NumberOfChanges);
      } , 0)

      this.success = this.validation();
      
      const ouputData = {
        "places" : this.allotment,
        "totalNumber" : total,
        "success": this.success,
      }

      this.omniUpdateDataJson(ouputData);

    }


    updateNumerOfReinstate(evt){

      const numberOfReinstate = evt.target.value;
      const placeId = evt.target.name;
      let allPlaces = this.allotment;

      if(numberOfReinstate >= 0 && (numberOfReinstate + '').replace('.', '').length === (numberOfReinstate + '').length){
        allPlaces.forEach(place => {
          if(place.Id === placeId && place.NumberofPlaces >= numberOfReinstate){
            place.NumberOfChanges = numberOfReinstate;
            place.numberOfAfterReinstated = place.NumberofPlaces - numberOfReinstate;
          }
        })
      }

      this.updateData();

    }

    validation() {
      const allValid = [
        ...this.template.querySelectorAll('lightning-input'),
      ].reduce((validSoFar, inputCmp) => {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
      }, true);
      
      return allValid;
    }
}