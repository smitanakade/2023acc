import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsTransferTable extends OmniscriptBaseMixin(LightningElement) {

    @track allPlaces;
    @track selectedPlace;
    @track placeSummary;
    @track isPAVariation = false;
    @track title;
    @track allPlacesTitle;

    connectedCallback(){

        if(this.omniJsonData.Place != null){
            const allotmentPlacesOmni = this.omniJsonData.Place;
            
            const allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)));

            allPlaces.forEach(place => {
                place.PacketUrl = '/' + place.Id;
            })

            this.allPlaces = allPlaces;
            this.updateOmni();
        }

        this.updateTitle();

    }

    changeSelectedPlace(evt){

        const checkPlace = evt.target.checked;
        const placeId = evt.target.name;
        const allPlaces = this.allPlaces;

        if(checkPlace){

            const checkedPlace = allPlaces.find(place => place.Id === placeId);
            checkedPlace.checked = true;
            this.selectedPlace = JSON.parse(JSON.stringify(checkedPlace));
            this.selectedPlace.notValid = true;
            this.selectedPlace.NumberOfChanges = 0;

            allPlaces.filter(place => place.Id != placeId)
            .forEach(place => place.checked = false);

        }else{
            this.selectedPlace = null
        }

    }

    updateCareLevel(evt){
        
        this.selectedPlace.CareLevel = evt.target.value;
        this.checkSelectedPlaces();

    }

    updateNumer(evt){

        this.selectedPlace.NumberOfChanges = evt.target.value;
        this.checkSelectedPlaces();

    }

    updateStatus(evt){

        this.selectedPlace.StatusChangeTo = evt.target.value;
        this.checkSelectedPlaces();

    }

    checkSelectedPlaces(){

        const place = this.selectedPlace;
        place.notValid = place.CareLevel && place.StatusChangeTo && place.NumberOfChanges > 0 && place.NumberOfChanges <= place.RemainingAfterVariation ? false : true;
    }

    addToSummary(){

        const placeSummary = this.placeSummary;
        const selectPlace = JSON.parse(JSON.stringify(this.selectedPlace));

        if(placeSummary){
            placeSummary.push(selectPlace)
        }else{
            this.placeSummary = [selectPlace];
        }

        const relatedPlace = this.allPlaces.find( place => place.Id ===this.selectedPlace.Id);
        relatedPlace.RemainingAfterVariation = relatedPlace.RemainingAfterVariation - Math.floor(selectPlace.NumberOfChanges);
            
        this.allPlaces.forEach( place => place.checked = false)

        this.selectedPlace = null;

        this.updateOmni();
        
    }

    edit(evt){
        
        let placeSummary = this.placeSummary;
        const editPlace = placeSummary[evt.target.name];
        
        const relatedPlace = this.allPlaces.find( place => place.Id === editPlace.Id);
        relatedPlace.RemainingAfterVariation = relatedPlace.RemainingAfterVariation + Math.floor(editPlace.NumberOfChanges);

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

    }

    updateOmni(){

        const allPlaces = this.allPlaces;
        let placesVaried = this.placeSummary;
        
        let  totalVariation = 0;
        
        if(placesVaried){

            //Update total variation number
            totalVariation = placesVaried.reduce((totalVariationPlace, currentPlace) => { 
                return totalVariationPlace + Math.floor(currentPlace.NumberOfChanges);
            } , 0);

        }

        if(allPlaces){
            allPlaces.forEach( place => place.VariationNumber = place.PlacesSum - place.RemainingAfterVariation);
        }

        this.omniUpdateDataJson({
            "totalVariation" : totalVariation,
            "AllPlaces":allPlaces, // All Places Information
            "VariedPlaces" : placesVaried //Places for new allotment
        });

    }

    get careLevelOptions(){
        const serviceCareSubType = this.omniJsonData.ServiceCareSubType;
        console.log(serviceCareSubType);
        if(serviceCareSubType === "Multi-Purpose Service"){
            return [
                { label: 'Residential', value: 'Residential' },
                { label: 'Home Care', value: 'Home Care' }
            ];
        }else if(serviceCareSubType === "Innovative Pool"){
            return [
                { label: 'High', value: 'High' },
                { label: 'Low', value: 'Low' },
                { label: 'Community', value: 'Community' }
            ];
        }else{
            return [
                { label: '', value: '' }
            ];
        }
    }

    get isOther(){
        const serviceCareSubType = this.omniJsonData.ServiceCareSubType;
        if(serviceCareSubType === "Multi-Purpose Service" ||  serviceCareSubType === "Innovative Pool"){
            return false;
        }else{
            return true;
        }
    }

    get statusOptions(){
        return [
            { label: 'Offline', value: 'Offline' },
            { label: 'Operational', value: 'Operational' }
        ];
    }

    get serviceName(){
        return this.omniJsonData.RelocateServiceName;
    }

    get location(){
        return this.omniJsonData.DisplayLocation;
    }

    get currentServiceName(){
        return this.omniJsonData.DisplayServiceName;
    }

    get SDA(){
        const sdaDisplayList = [];
        if(this.omniJsonData.SDA){
            const sda = JSON.parse(JSON.stringify(this.omniJsonData.SDA));
            sda.forEach(area => {
                if(area.ACPR && area.SA2){
                    area.display = area.ACPR + ' - ' + area.SA2;
                }else if (area.ACPR) {
                    area.display = area.ACPR;
                }else if (area.SA2){
                    area.display = area.SA2;
                }
                if(area.display){
                    sdaDisplayList.push(area.display);
                }
            })

        }

        if(sdaDisplayList.length){
            return sdaDisplayList.join('<br>')
        }else{
            return 'N/A';
        }

    }

    get isFlexible(){
        return this.omniJsonData.ServiceCareType === 'Flexible' ? true : false;
    }

    updateTitle(){
        const changeToNewService = this.omniJsonData.RelocationService.ChangeService;
        const changeToNewCareLevel = this.omniJsonData.VariationCareLevel.ChangeCareLevel;

        if(changeToNewService === "Yes" && changeToNewCareLevel === "Yes"){
            this.title = "Number of places to be relocated and have this care level";
            this.allPlacesTitle = "Places available for relocation and change of care level";
        }else if(changeToNewService === "No" && changeToNewCareLevel === "Yes"){
            this.title = "Number of places to have this care level";
            this.allPlacesTitle = "Places available for change of care level";
        }else if(changeToNewService === "Yes" && changeToNewCareLevel === "No"){
            this.title = "Number of places to be relocated";
            this.allPlacesTitle = "Places available for relocation";
        }else{
            this.title = "";
            this.allPlacesTitle = "";
        }
    }

}