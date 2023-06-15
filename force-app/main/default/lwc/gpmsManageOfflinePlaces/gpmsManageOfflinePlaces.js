import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class ManageOfflinePlaces extends OmniscriptBaseMixin(LightningElement) {
    places;
    editDetails = false;
    selectedPlace;
    summaryPlaces = [];
    updatedPlaces = [];
    buttonDisabled = true;
    picklistDisabled = true;
    dateDisabled = true;
    placeOfChange = 0;
    statusEffectiveDate;
    minDateOfEffectiveDate;
    offlineEndDate;
    today;
    StatusReason;
    minDateOfOfflineDate;
    success;

    StatusReasonOptions = [
        { label: 'Places transferred in as offline ', value: 'Places transferred in as offline ' },
        { label: 'Places varied in as offline', value: 'Places varied in as offline' },
        { label: 'Offline at time of migration', value: 'Offline at time of migration' },
        { label: 'Rebuilding', value: 'Rebuilding' },
        { label: 'Places not being used', value: 'Places not being used' },
        { label: 'Provider expected to apply for transfer of places', value: 'Provider expected to apply for transfer of places' },
        { label: 'Provider expected to apply for variation of places', value: 'Provider expected to apply for variation of places' },
        { label: 'Provider undertaking strategic review', value: 'Provider undertaking strategic review' },
    ];

    connectedCallback() {
        
        if(this.omniJsonData.Place != null) {
            const allotmentPlacesOmni = this.omniJsonData.Place;
            const allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)));

            allPlaces.forEach(place => {
                place.NumberOfChanges = 0;
                place.NumberOfAfter = place.NumberOfRemaining;
                place.StatusChangeTo = place.StatusOfPlaces == "Operational" ? "Offline" : "Operational";
                place.StatusEffectiveDateAfter = null;
                place.OriginalStatusEffectiveDate = place.StatusEffectiveDate;
                place.StatusReason = null;
                place.PacketUrl = '/' + place.Id;
            })

            this.places = allPlaces;
        }

        this.updateOmniOutput();
    }

    handleSelection() {
        this.success = false;
        var elements = this.template.querySelectorAll(".placeId");
        let selectedId;

        for(let element of elements)  {
            if(element.checked) {
                selectedId = element.value; 
            }
        }

        let selectedPlaces = this.places.filter(place => {return place.Id == selectedId});
        this.selectedPlace = JSON.parse(JSON.stringify(selectedPlaces[0]));

        this.selectedPlace.NumberOfAfter = this.selectedPlace.NumberOfRemaining;

        let date = this.selectedPlace.OriginalStatusEffectiveDate;
        date = date.split("/").reverse().join("-");

        let effectiveMinDate = new Date(date);
        effectiveMinDate.setDate(effectiveMinDate.getDate() + 1);
        this.statusEffectiveDate = effectiveMinDate.toISOString().slice(0, 10);
        this.minDateOfEffectiveDate = this.statusEffectiveDate;


        effectiveMinDate = new Date(this.statusEffectiveDate);
        effectiveMinDate.setDate(effectiveMinDate.getDate() + 1);
        this.minDateOfOfflineDate = effectiveMinDate.toISOString().slice(0, 10);
        
        if(this.selectedPlace.StatusChangeTo == "Offline") {
            this.dateDisabled = false;
            this.picklistDisabled = false;
        }
        
        this.editDetails = true;
        this.placeOfChange = 0;

        this.updatePlaces();
        this.updateOmniOutput();
    }

    updateRemainingPlaces(event) {
        this.placeOfChange = event.target.value;
        this.selectedPlace.NumberOfAfter = this.selectedPlace.NumberOfRemaining;

        if(this.placeOfChange >= 0 && this.selectedPlace.NumberOfRemaining >= this.placeOfChange){
            this.selectedPlace.NumberOfChanges = Number(this.placeOfChange);
            this.selectedPlace.NumberOfAfter = this.selectedPlace.NumberOfAfter - this.placeOfChange;
            this.handleButtonValidation();
        }
    }

    handleDateChanges(event) {
        let action = event.target.name;
        let value = event.target.value;

        switch(action) {
            case "effectiveDate":
                this.statusEffectiveDate = value;
                let effectiveMinDate = new Date(this.statusEffectiveDate);
                effectiveMinDate.setDate(effectiveMinDate.getDate() + 1);
                this.minDateOfOfflineDate = effectiveMinDate.toISOString().slice(0, 10);
                break;
            case "offlineEndDate":
                this.offlineEndDate = value;
                break;
            default:
                break;
        }
        this.handleButtonValidation();
    }

    handlePicklistChange(event) {
        this.StatusReason = event.target.value;
        this.handleButtonValidation();
    }

    handleButtonClick(event) {
        let action = event.target.label;
        let packetId = event.target.name;
        let index = event.target.value;

        switch(action) {
            case "Add":
                this.addRecord(packetId);
                break;
            case "Edit":
                this.editRecord(index);
                break;    
            case "Remove":
                this.removeRecord(index);
                break;
            default:
                break;
        }
    }

    handleButtonValidation() {
        let buttonDisabled = false;
        if((this.placeOfChange <= 0 && this.selectedPlace.NumberOfRemaining < this.placeOfChange) || this.statusEffectiveDate == null){
            buttonDisabled = true;
        }

        if(this.selectedPlace.StatusChangeTo == 'Offline' && (this.StatusReason == null || this.offlineEndDate == null)) {
            buttonDisabled = true;
        }

        this.buttonDisabled = buttonDisabled;
        this.updateOmniOutput();
    }

    addRecord(packetId) {
        if(this.validation() && this.checkDuplicate(packetId)) {
            this.success = true;
            let placesTemp = this.places;
            placesTemp.forEach(place => {
                if(place.Id == packetId){
                    place.NumberOfRemaining = this.selectedPlace.NumberOfAfter;
                }
            })

            this.selectedPlace.StatusReason = this.StatusReason;
            this.selectedPlace.StatusEffectiveDateAfter = this.statusEffectiveDate;
            const date = this.selectedPlace.StatusEffectiveDateAfter;
            this.selectedPlace.StatusEffectiveDate = date.split("-").reverse().join("/");
            if (this.selectedPlace.StatusOfPlaces == "Operational"){
                this.selectedPlace.ExpectedOfflineEndDate = this.offlineEndDate;
                this.selectedPlace.ExpectedOfflineEndDateDisplay = this.offlineEndDate.split("-").reverse().join("/");
            }
            this.places = [];
            this.places = this.places.concat(placesTemp);

            this.summaryPlaces = this.summaryPlaces.concat(JSON.parse(JSON.stringify(this.selectedPlace)));
            this.resetValue();

            this.updatePlaces();
            this.updateOmniOutput();
        }
    }

    updatePlaces() {
        this.updatedPlaces = [];
        this.places.forEach(place => {
            if(place.NumberOfRemaining < place.NumberOfPlaces) {
                this.updatedPlaces = this.updatedPlaces.concat(JSON.parse(JSON.stringify(place)));
            }
        });
    }

    checkDuplicate(packetId) {
        let validation = true;
        if(this.summaryPlaces.length > 0) {
            let tempPlace = this.summaryPlaces.filter(place => {return place.Id == packetId});
            tempPlace.forEach(place => {
                if(place.ExpectedOfflineEndDate == this.offlineEndDate && place.StatusReason == this.StatusReason) {
                    validation = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Add new record failed',
                            message: "Places can't be added since places with same attributes for the selected packet already exist. Edit the Places in Summary section instead",
                            variant: 'error'
                        })
                    );
                }
            })
        } 

        return validation;
    }

    resetValue() {
        this.selectedPlace = null;
        this.dateDisabled = true;
        this.editDetails = false;
        this.picklistDisabled = true;
        this.buttonDisabled = true;
        this.StatusReason = null;
        this.statusEffectiveDate = null;
        this.offlineEndDate = null;
        this.placeOfChange = 0;
        const elements = this.template.querySelectorAll(".placeId");
        for(const element of elements)  {
            element.checked = false;
        }
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

    editRecord(index) {
        let selectedPlace = this.summaryPlaces[index];
        this.removeRecord(index);

        this.selectedPlace = JSON.parse(JSON.stringify(selectedPlace));
        this.editDetails = true;
        this.placeOfChange = this.selectedPlace.NumberOfChanges;
        this.statusEffectiveDate = this.selectedPlace.StatusEffectiveDateAfter;
        this.selectedPlace.NumberOfAfter = this.selectedPlace.NumberOfRemaining - this.placeOfChange;
        this.buttonDisabled = false;
        if(this.selectedPlace.StatusChangeTo == "Offline") {
            this.dateDisabled = false;
            this.picklistDisabled = false;
            this.offlineEndDate = this.selectedPlace.ExpectedOfflineEndDate;
            this.StatusReason = this.selectedPlace.StatusReason;
        } 
        
    }

    removeRecord(index) {
        let summaryPlacesTemp = this.summaryPlaces;
        this.success = false;
        if(index != null) {
            let NumberOfChanges = summaryPlacesTemp[index].NumberOfChanges;
            let packetId = summaryPlacesTemp[index].Id;
            summaryPlacesTemp.splice(index, 1);
            this.summaryPlaces = [];

            if(summaryPlacesTemp.length != 0) {
                this.summaryPlaces = this.summaryPlaces.concat(summaryPlacesTemp);
            }

            let placesTemp = this.places;

            placesTemp.forEach(place => {
                if(place.Id == packetId){
                    place.NumberOfRemaining = Number(place.NumberOfRemaining) + Number(NumberOfChanges);
                    place.StatusEffectiveDateAfter = this.statusEffectiveDate;
                    place.StatusReason = null;
                    place.ExpectedOfflineEndDate = null;
                    place.ExpectedOfflineEndDateDisplay = null;
                }
            })

            this.places = [];
            this.places = this.places.concat(placesTemp);
    
            this.resetValue();
        }

        this.updatePlaces();
        this.updateOmniOutput();
    }

    updateOmniOutput() {
        const ouputData = {
            "summaryPlaces" : this.summaryPlaces,
            "updatedPlaces" : this.updatedPlaces,
            "success": this.success,
        }
    
        this.omniUpdateDataJson(ouputData);
    }
}