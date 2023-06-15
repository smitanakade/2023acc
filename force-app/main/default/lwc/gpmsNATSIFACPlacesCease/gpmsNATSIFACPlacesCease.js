import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsNATSIFACPlacesCease extends OmniscriptBaseMixin(LightningElement) {
    @track allotment;
    success = false;

    connectedCallback() {

      if(this.omniJsonData.Cease != null){
        const allotmentPlacesOmni = this.omniJsonData.Cease;
        let allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)))
        
        allPlaces.forEach(place => {
          place.NumberOfChanges = 0;
          place.numberOfAfterCeased = place.NumberofPlaces;
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


    updateNumerOfCeased(evt){

      const numberOfCeased = evt.target.value;
      const placeId = evt.target.name;
      let allPlaces = this.allotment;

      if(numberOfCeased >= 0 && (numberOfCeased + '').replace('.', '').length === (numberOfCeased + '').length){
        allPlaces.forEach(place => {
          if(place.Id === placeId && place.NumberofPlaces >= numberOfCeased){
            place.NumberOfChanges = numberOfCeased;
            place.numberOfAfterCeased = place.NumberofPlaces - numberOfCeased;
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