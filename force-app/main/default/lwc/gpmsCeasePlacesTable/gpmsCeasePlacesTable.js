import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsCeasePlacesTable extends OmniscriptBaseMixin(LightningElement) {

    @track allotment;
    @track ceasedAllPlaces = 'Cease all places';
    @track value = this.ceasedAllPlaces;

    connectedCallback() {
      
      if(this.omniJsonData.Place){     
        const allotmentPlacesOmni = this.omniJsonData.Place;
       
        let allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)))
        allPlaces.forEach(place => {
          place.numberOfAfterCeased = 0;
          place.StatusChangeTo = 'Ceased';
          place.StatusReason = 'Expired under S14-9(4)';
          place.StatusEffectiveDate = this.omniJsonData.CeasePlaces.CessationEffectiveDateFormat;
        });
        this.allotment = allPlaces;

        this.updateData();

      }
    }

    updateData(){

      const allAllotment = this.allotment;

      const total = allAllotment.reduce((totalCeaseNumber, currentAllotment) => { 
        return totalCeaseNumber + Math.floor(currentAllotment.NumberOfChanges);
      } , 0)
      
      const outputData = {
        "action" : this.value,
        "places" : this.allotment.filter(place => place.NumberOfChanges > 0),
        "totalCeaseNumber" : total
      }

      this.omniUpdateDataJson(outputData);

    }


    updateNumberOfCeased(evt){
      
      const numberOfCeased = evt.target.value;
      const placeId = evt.target.name;

      const allPlaces = this.allotment;
      
      if(numberOfCeased >= 0 && (numberOfCeased + '').replace('.', '').length === (numberOfCeased + '').length){
        allPlaces.forEach(place => {
          if(place.Id === placeId && place.NumberOfPlaces >= numberOfCeased){
            place.NumberOfChanges = numberOfCeased;
            place.numberOfAfterCeased = place.NumberOfPlaces - numberOfCeased;
          }
        })
      }

      


      this.updateData();

    }

    updateAction(evt){

      const value = evt.target.value;
      const allPlaces = this.allotment;

      if(value == this.ceasedAllPlaces){
        

        allPlaces.forEach(place => {
          place.NumberOfChanges = place.NumberOfPlaces;
          place.numberOfAfterCeased = 0;
        })

      }else{
        allPlaces.forEach(place => {
          place.NumberOfChanges = 0;
          place.numberOfAfterCeased = place.NumberOfPlaces;
        })
      }

      this.value = value;
      this.allotment = allPlaces;

      this.updateData();

    }

    get isRead(){
      if(this.value === this.ceasedAllPlaces){
        return true;
      }else{
        return false;
      }
    }
    
    
    get options() {
      return [
        { label: this.ceasedAllPlaces, value: this.ceasedAllPlaces },
        { label: 'Cease some places', value: 'Cease some places' }
      ];
    }

}