import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class GpmsCombineService extends OmniscriptBaseMixin(LightningElement) {

    @track duplicateCR = [];
    @track allKP = [];
    @track allPOC = [];
    nonDuplicateKP = [];
    nonDuplicatePOC = [];

    connectedCallback(){

        if(this.omniJsonData.SelectDiscontinuingKP.DisKP){
            const crKP = this.omniJsonData.SelectDiscontinuingKP.DisKP.SelectedResult.CRs;
            this.allKP = [...[].concat(crKP)];
        }

        if(this.omniJsonData.SelectDiscontinuingPOC.DisPOC){
            const crPOC = this.omniJsonData.SelectDiscontinuingPOC.DisPOC.SelectedResult.CRs;
            this.allPOC = [...[].concat(crPOC)];
        }

        this.duplicateCR  = [
            {"Title":"Duplicate Key Personnel","crList":this.findDuplicateContacts(this.allKP,"KP"),"Id":"KP"},
            {"Title":"Duplicate Point of Contact","crList":this.findDuplicateContacts(this.allPOC, "POC"),"Id":"POC"},
        ];

        this.updateOmniJSON();

    }

    findDuplicateContacts(crList, type) {
        
        const contacts = {};
        const duplicates = [];
        
        crList.forEach((item) => {
            const contact = item.Contact;
            if (contacts[contact]) {
                contacts[contact].push(item);
            } else {
                contacts[contact] = [item];
            }
        });
      
        // Iterate over the map and collect the duplicates
        Object.keys(contacts).forEach((contact) => {
            const items = contacts[contact];
            if (items.length > 1) {
                duplicates.push({Contact: contact,Name: items[0].Name,CR: items,options: this.contactOptions(items),Select: items[0].Id});
            }else if (type === "KP"){
                this.nonDuplicateKP.push(items[0]);
            }else if (type === "POC"){
                this.nonDuplicatePOC.push(items[0]);
            }
        });
        return duplicates;
    
    }
    
    contactOptions(crList) {
        return crList.map(cr => ({ label: "Role: " + cr.Role + "; Position: " + cr.Position, value: cr.Id }));
    }

    handleChange(event){
        
        const selectCR = event.target.value;
        const selectType = event.target.type;
        const selectContact = event.target.name;

        let duplicateCR = this.duplicateCR.find(type => type.Id === selectType)?.crList.find(cr => cr.Contact === selectContact);
        if (duplicateCR) {
            duplicateCR.Select = selectCR;
        }

        this.updateOmniJSON();

    }

    updateOmniJSON(){
        
        let nonDuplicateKP = this.nonDuplicateKP;
        let nonDuplicatePOC = this.nonDuplicatePOC;

        let matchingKP = this.findContectRelationship(this.duplicateCR.find(type => type.Id === "KP"));
        let matchingPOC = this.findContectRelationship(this.duplicateCR.find(type => type.Id === "POC"));


        nonDuplicateKP = nonDuplicateKP.concat(matchingKP);
        nonDuplicatePOC = nonDuplicatePOC.concat(matchingPOC);


        this.omniUpdateDataJson({
            "KP":nonDuplicateKP,
            "POC":nonDuplicatePOC,
          });

    }

    findContectRelationship(crType) {

        const crItems = [];
        crType.crList.forEach((item) => {
            const selectedCR = item.CR.find((contact) => contact.Id === item.Select);
            if (selectedCR) {
                crItems.push(selectedCR);
            }
        });
        
        return crItems;
    }
    

}