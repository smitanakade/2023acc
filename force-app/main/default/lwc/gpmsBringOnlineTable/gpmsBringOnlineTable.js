import { LightningElement, track, api} from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsBringOnlineTable extends OmniscriptBaseMixin(LightningElement) {

    @track allotment;
    success = false;

    connectedCallback() {

      if(this.omniJsonData.Provisional != null){
        const allotmentPlacesOmni = this.omniJsonData.Provisional;

        let allPlaces = [];

        if(this.omniJsonData.Places){
          allPlaces = [].concat(JSON.parse(JSON.stringify(this.omniJsonData.Places.CustomLWC1.places)));
        }else{
          allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)));
        }

        allPlaces.forEach(place => {
          if(place.NumberOfChanges === undefined){
            place.NumberOfChanges = 0;
            place.numberOfAfterBringOnline = place.NumberofPlaces;
          }
          place.StatusEffectiveDate = this.operationalDate;
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

      allAllotment.forEach(place => {
        place.StatusChangeTo = 'Operational';
        place.StatusReason = 'S15-3 Application for determination approved';
      });
      
      const ouputData = {
        "places" : this.allotment,
        "totalNumber" : total,
        "success": this.success,
      }

      this.omniUpdateDataJson(ouputData);

    }

    get operationalDate(){
      return this.omniJsonData.ApplicationForDetermination.operationalDateText;
    }


    updateNumerOfCeased(evt){

      const numberOfCeased = evt.target.value;
      const placeId = evt.target.name;
      let allPlaces = this.allotment;

      if(numberOfCeased >= 0 && (numberOfCeased + '').replace('.', '').length === (numberOfCeased + '').length){
        allPlaces.forEach(place => {
          if(place.Id === placeId && place.NumberofPlaces >= numberOfCeased){
            place.NumberOfChanges = numberOfCeased;
            place.numberOfAfterBringOnline = place.NumberofPlaces - numberOfCeased;
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