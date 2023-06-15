import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class changeCareSetting extends OmniscriptBaseMixin(LightningElement) {
 @track allotment;
 @track allPlaces;
 @track selectedPlace;
 @track placeSummary;
 errorCode = "";

 connectedCallback() {
      debugger;

      if(this.omniJsonData.Place != null){     
        const allotmentPlacesOmni = this.omniJsonData.Place;
        const allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)));
        
        allPlaces.forEach(place => {
              place.oldCareSetting = place.CareSetting;
              place.RemainingAfterCareSetting = place.NumberofPlaces;
              place.PacketUrl = '/' + place.PlacesId;
              if(place.NumberofPlaces == 0)
              {
                place.RemainingAfterCareSetting = 0;
              }
            })
            this.allPlaces = allPlaces;
          }
    }
	
	get careSettingOptions(){
    return [
        { label: 'Home Care', value: 'Home Care' },
        { label: 'Residential', value: 'Residential' },
        { label: 'Community', value: 'Community' },
		    { label: 'Mixed', value: 'Mixed' },
        { label: 'To be Confirmed', value: 'To be Confirmed' }
      ];
    }
	get CareSetting()
  {
    return this.omniJsonData.CareSetting;
  }
   get DateOfAllotment(){
        return this.omniJsonData.DateOfAllotment;
    }

  get CareSettingDate(){
    if(this.omniJsonData.ChangeCareSetting && this.omniJsonData.ChangeCareSetting.CareSettingEffectiveDate){
    return this.omniJsonData.ChangeCareSetting.CareSettingEffectiveDate;
    }
  }
  updateCareSetting(evt){   
    this.selectedPlace.CareSetting = evt.target.value;
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
  updateNumber(evt){

    this.selectedPlace.CurrentAction = evt.target.value;
    this.selectedPlace.currentRemainingAfterCareSetting = this.selectedPlace.NumberofRemaining - Math.floor(this.selectedPlace.CurrentAction);
    
    this.checkSelectedPlaces();

  }
  checkSelectedPlaces(){
    this.errorCode = "";
    let success = this.validation();
    const place = this.selectedPlace;
    place.notValid = place.CareSetting != place.oldCareSetting && place.CurrentAction > 0 && place.CurrentAction <= place.NumberofRemaining ? false : true;
    if(!(success && !place.notValid)) {
      this.errorCode = place.CareSetting == place.oldCareSetting ? "CareSetting" : "NumberOfPlace";
    }

    this.updateOmni();
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
      relatedPlace.RemainingAfterCareSetting = relatedPlace.RemainingAfterCareSetting - Math.floor(selectPlace.CurrentAction);
      relatedPlace.NumberofRemaining = relatedPlace.RemainingAfterCareSetting;
      this.allPlaces.forEach( place => place.checked = false)

      this.selectedPlace = null;
      this.errorCode = "";

      this.updateOmni();
    }
  }
  edit(evt){
        
    let placeSummary = this.placeSummary;
    const editPlace = placeSummary[evt.target.name];
    
    const relatedPlace = this.allPlaces.find( place => place.PlacesId === editPlace.PlacesId);
    relatedPlace.RemainingAfterCareSetting = relatedPlace.RemainingAfterCareSetting + Math.floor(editPlace.CurrentAction);
    relatedPlace.NumberofRemaining = relatedPlace.RemainingAfterCareSetting;

    this.allPlaces.forEach( place => place.checked = false);

    this.selectedPlace = JSON.parse(JSON.stringify(editPlace));

    placeSummary.splice(evt.target.name, 1);

    if(placeSummary.length === 0){
        this.placeSummary = null;
    }
    this.errorCode = "";
    this.updateOmni();
  }

  remove(evt){

      this.edit(evt);
      this.selectedPlace = null;
      this.errorCode = "";

      this.updateOmni();

  }
  updateOmni(){
    const places = this.placeSummary;
    console.log('errorCode', this.errorCode);
    this.omniUpdateDataJson({
      "Places":places,
      "errorCode":this.errorCode,
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