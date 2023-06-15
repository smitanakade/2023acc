import { LightningElement} from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsRevokePlaceTable extends OmniscriptBaseMixin(LightningElement) {
    places;
    success = false;
    value = 'Revoke All Places';
    isRead = true;
    reviewedConditions;

    connectedCallback() {
        let noticeType = this.omniJsonData.RevokeDetailsProvisional?.NoticeTypeProvisional;
        if(noticeType == null){
          noticeType = this.omniJsonData.RevokeDetailsPlacesTakenEffect.NoticeTypePlacesTakenEffect;
        }
        if(this.omniJsonData.Provisional != null){
            const allotmentPlacesOmni = this.omniJsonData.Provisional;
            let allPlaces = [].concat(JSON.parse(JSON.stringify(allotmentPlacesOmni)))

            allPlaces.forEach(place => {
                place.NumberOfChanges = place.NumberofPlaces;
                place.NumberOfPlacesAfterReduction = place.NumberofPlaces;
                place.StatusChangeTo = 'Ceased';
                place.StatusReason = noticeType;
                place.PacketUrl = '/' + place.Id;
            })

            this.places = allPlaces;
            this.reviewedConditions = 'Not Applicable';

            this.updateData();

        }
        
    }

    updateData(){

        const allAllotment = this.places;
  
        const total = allAllotment.reduce((totalInvokeNumber, currentAllotment) => { 
          return totalInvokeNumber + Math.floor(currentAllotment.NumberOfChanges);
        } , 0)
  
        this.success = this.validation();
        
        const ouputData = {
          "places" : allAllotment.filter(packet => packet.NumberOfChanges > 0),
          "totalNumber" : total,
          "action" : this.value,
          "success": this.success,
          "reviewedConditions": this.reviewedConditions,
        }
  
        this.omniUpdateDataJson(ouputData);
  
      }
  
  
      updateNumerOfInvoke(evt){
  
        const numberOfInvoked = evt.target.value;
        const placeId = evt.target.name;
        let allPlaces = this.places;
  
        if(numberOfInvoked >= 0 && (numberOfInvoked + '').replace('.', '').length === (numberOfInvoked + '').length){
            allPlaces.forEach(place => {
              if(place.Id === placeId && place.NumberofPlaces >= numberOfInvoked){
                place.NumberOfChanges = numberOfInvoked;
                place.NumberOfPlacesAfterReduction = place.NumberofPlaces - numberOfInvoked;
              }
            })
          }

        this.places = [];

        this.places = this.places.concat(allPlaces);
  
        this.updateData();
  
      }
  
      updateAction(evt){

        const value = evt.target.value;
  
        if(value == 'Revoke All Places'){
          this.isRead = true;
          let allPlaces = this.places;
  
          allPlaces.forEach(place => {
            place.NumberOfChanges = place.NumberofPlaces;
            place.NumberOfPlacesAfterReduction = 0;
          })
  
          this.places = allPlaces;

        }else{
          this.isRead = false;
  
          let allPlaces = this.places;
  
          allPlaces.forEach(place => {
            place.NumberOfChanges = 0;
            place.NumberOfPlacesAfterReduction = place.NumberofPlaces;
          })
  
          this.places = allPlaces;
        }
  
        this.value = value;
        this.reviewedConditions = 'Not Applicable';
  
        this.updateData();
  
      }
  
      updatePicklist(evt) {
          this.reviewedConditions = evt.target.value;
  
          this.updateData();
      }
  
      
      
      get picklistOptions() {
        return [
          { label: 'Revoke All Places', value: 'Revoke All Places' },
          { label: 'Revoke Some Places (Review of S14-5(4) Conditions is required)', value: 'Revoke Some Places' }
        ];
      }
  
      get radioButtonSomeOptions() {
          return [
            { label: 'Not Applicable', value: 'Not Applicable' },
            { label: 'Yes, variation of the S14-5(4) Condition for the remaining places in the allotment has been completed', value: 'Yes, variation of the S14-5(4) Condition for the remaining places in the allotment has been completed' },
          ];
      }
  
      get radioButtonAllOptions() {
          return [
            { label: 'Not Applicable', value: 'Not Applicable' },
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