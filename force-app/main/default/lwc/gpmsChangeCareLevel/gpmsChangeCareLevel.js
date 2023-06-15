import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class changeCareLevel extends OmniscriptBaseMixin(LightningElement) {
 @track allotment;
 @track allPlaces;
 @track selectedPlace;
 //@track isOther = false;
 @track placeSummary;
 connectedCallback() {
      debugger;
      if(this.omniJsonData.Place != null){     
            const allotmentPlacesOmni = this.omniJsonData.Place;
            const allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)));

            allPlaces.forEach(place =>  {
                place.oldCareLevel = place.CareLevel;
                place.PacketUrl = '/' + place.PlacesId;
            })
            this.allPlaces = allPlaces;
        }
    }
	
	get careLevelOptions(){
            return [
                { label: 'Residential', value: 'Residential' },
                { label: 'Home Care', value: 'Home Care' }
            ];
    }

    updateCareLevel(evt){ 
        this.selectedPlace.CareLevel = evt.target.value;
        this.checkSelectedPlaces();
    }

    changeSelectedPlace(evt){

        const checkPlace = evt.target.checked;
        const placeId = evt.target.name;
        const allPlaces = this.allPlaces;

        if(checkPlace){

            const checkedPlace = allPlaces.find(place => place.PlacesId === placeId);
            checkedPlace.checked = true;
            this.selectedPlace = JSON.parse(JSON.stringify(checkedPlace));
            this.updateSelecedPlace();
            
            allPlaces.filter(place => place.PlacesId != placeId)
            .forEach(place => place.checked = false);

        }
        else{
            this.selectedPlace = null
        }

    }
    updateSelecedPlace(){
        let place = this.selectedPlace
        place.notValid = true;
        place.CurrentAction = 0;
    }
    updateNumer(evt){

        this.selectedPlace.CurrentAction = evt.target.value;
        this.selectedPlace.placesremaining = this.selectedPlace.NumberofRemaining - Math.floor(this.selectedPlace.CurrentAction);
        this.checkSelectedPlaces();

    }
    checkSelectedPlaces(){

        const place = this.selectedPlace;
        place.notValid = place.CareLevel && place.CurrentAction > 0 && place.CurrentAction <= place.NumberofRemaining ? false : true;
    }

    addToSummary(){
        if(this.validation()) {
            const placeSummary = this.placeSummary;
            const selectPlace = JSON.parse(JSON.stringify(this.selectedPlace));

            if(placeSummary){
                placeSummary.push(selectPlace)
            }else{
                this.placeSummary = [selectPlace];
            }

            const relatedPlace = this.allPlaces.find( place => place.PlacesId ===this.selectedPlace.PlacesId);
                
            this.allPlaces.forEach( place => place.checked = false)

            this.selectedPlace = null;

            this.updateOmni();
        }
    }
    edit(evt){
        
        let placeSummary = this.placeSummary;
        const editPlace = placeSummary[evt.target.name];
    
        this.allPlaces.forEach( place => place.checked = false);
    
        this.selectedPlace = JSON.parse(JSON.stringify(editPlace));
    
        placeSummary.splice(evt.target.name, 1);
    
        if(placeSummary.length === 0){
            this.placeSummary = null;
        }
    
        this.updateOmni();
      }
    
      remove(evt){
    
          this.edit(evt);
          this.selectedPlace = null;
          this.updateOmni();
    
    }
    updateOmni(){
        const places = this.placeSummary;

        this.omniUpdateDataJson({
        "Places":places
        });
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