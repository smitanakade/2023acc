import { LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsRelinquishPlacesTable extends OmniscriptBaseMixin(LightningElement) {
    places;
    value = 'Relinquish all places';
    isRead = true;
    reviewedConditions;

    connectedCallback() {
      debugger;
      

      if(this.omniJsonData.Place != null){     
        const allotmentPlacesOmni = this.omniJsonData.Place;
       
        let allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)))
        
        allPlaces.forEach(place => {
          place.NumberOfChanges = place.NumberOfPlaces;
          place.numberOfAfterRelinquished = 0;
          place.StatusChangeTo = 'Ceased';
          place.StatusReason = "S18-2 Provider relinquishes places";
          place.PacketUrl = '/' + place.Id;
        })

        this.places = allPlaces;
        this.reviewedConditions = 'Not applicable';

        this.updateData();

      }
    }

    updateData(){

      this.validation();
      const allPlace = this.places;
      let updatedPlaces = [];

      const total = allPlace.reduce((totalRelinquishedNumber, currentPlace) => { 
        return totalRelinquishedNumber + Math.floor(currentPlace.NumberOfChanges);
      } , 0)

      allPlace.forEach(place => {
        if(place.NumberOfChanges > 0) {
          updatedPlaces = updatedPlaces.concat(JSON.parse(JSON.stringify(place)));
        }
      })
      
      const ouputData = {
        "action" : this.value,
        "places" : updatedPlaces,
        "totalRelinquishedNumber" : total,
        "reviewedConditions": this.reviewedConditions,
      }

      this.omniUpdateDataJson(ouputData);

    }


    updateNumerOfRelinquished(evt){
      debugger;
      let selectedIndex = evt.currentTarget.dataset.index;
     
      const NumberOfChanges = evt.target.value;
      
      const placeId = evt.target.name;


      let tmpObj = this.proxyToObj(this.places[selectedIndex]); 

      if(NumberOfChanges >= 0 && (NumberOfChanges + '').replace('.', '').length === (NumberOfChanges + '').length){

        tmpObj.NumberOfChanges = NumberOfChanges;
        tmpObj.numberOfAfterRelinquished = tmpObj.NumberOfPlaces - NumberOfChanges;
        this.places[selectedIndex]=tmpObj; 
      }

      const tempPlaces = this.places;

      this.places = [];
      this.places = this.places.concat(tempPlaces);

      this.updateData();

    }

    proxyToObj(obj){
      return JSON.parse(JSON.stringify(obj));
     }


    updateAction(evt){

      const value = evt.target.value;

      if(value == 'Relinquish all places'){
        this.isRead = true;
        let allPlaces = this.places;

        allPlaces.forEach(place => {
          place.NumberOfChanges = place.NumberOfPlaces;
          place.numberOfAfterRelinquished = 0;
        })

        this.places = allPlaces;



      }else{
        this.isRead = false;

        let allPlaces = this.places;

        allPlaces.forEach(place => {
          place.NumberOfChanges = 0;
          place.numberOfAfterRelinquished = place.NumberOfPlaces;
        })

        this.places = allPlaces;
      }

      this.value = value;
      this.reviewedConditions = 'Not applicable';

      this.updateData();

    }

    updatePicklist(evt) {
        this.reviewedConditions = evt.target.value;

        this.updateData();
    }

    
    
    get picklistOptions() {
      return [
        { label: 'Relinquish all places', value: 'Relinquish all places' },
        { label: 'Relinquish some places', value: 'Relinquish some places' }
      ];
    }

    get radioButtonSomeOptions() {
        return [
          { label: 'Not applicable', value: 'Not applicable' },
          { label: 'No', value: 'No' },
          { label: 'Yes, variation of remaining places in the allotment is not required', value: 'Yes, variation of remaining places in the allotment is not required' },
          { label: 'Yes, variation of remaining places in the allotment is required', value: 'Yes, variation of remaining places in the allotment is required' }
        ];
    }

    get radioButtonAllOptions() {
        return [
          { label: 'Not applicable', value: 'Not applicable' },
        ];
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