import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsPlacesReductionTable extends OmniscriptBaseMixin(LightningElement)  {
  
  @track allPlaces;
  
  connectedCallback() {
    
    if(this.omniJsonData.Place != null){
      
      const allotmentPlaces = this.omniJsonData.Place;
      const allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlaces)))
      
      allPlaces.forEach(place => {
        place.NumberOfChanges = 0;
        place.numberOfPlaces = place.NumberOfRemaining;
      });
      
      this.allPlaces = allPlaces;
      
      this.updateData();
    
    }
  }
  
  updateData(){
    
    const allPlaces = this.allPlaces;
    const remainingTotal = allPlaces.reduce((totalRemainNumber, currentAllotment) => { 
      return totalRemainNumber + Math.floor(currentAllotment.NumberOfRemaining);
    } , 0);

    const newPlaceList = [];

    allPlaces.forEach( place => {
      if(place.NumberOfChanges > 0){
        const newPlace = JSON.parse(JSON.stringify(place))
        newPlace.StatusChangeTo = "Ceased";
        newPlace.StatusReason = "S15-5 provider reduces number of places in provisional allocation";
        newPlaceList.push(newPlace);
      }
      
    })
    
    const ouputData = {
      "places" : this.allPlaces,
      "remainingTotal" : remainingTotal,
      "reductionPlace" : newPlaceList
    }
    
    this.omniUpdateDataJson(ouputData);
  
  }
  
  updateNumberOfReduction(evt){
    
    const numberOfReduction = evt.target.value;
    const placeId = evt.target.name;
    const allPlaces = this.allPlaces;
    
    if(numberOfReduction >=0 && (numberOfReduction + '').replace('.', '').length === (numberOfReduction + '').length){
      const selectPlace = allPlaces.find(place => place.Id === placeId && place.NumberOfRemaining >= numberOfReduction);
      if(selectPlace){
        selectPlace.NumberOfChanges = numberOfReduction;
        selectPlace.NumberOfRemaining = selectPlace.numberOfPlaces - numberOfReduction;
        selectPlace.VariationNumber = numberOfReduction;
      }
    }
    
    
    
    this.updateData();
  }
    

}