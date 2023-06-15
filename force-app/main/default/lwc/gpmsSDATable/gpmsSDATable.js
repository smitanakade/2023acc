import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

const columns = [
    { label: 'State', fieldName: 'State',editable:false },
    { label: 'ACPR', fieldName: 'ACPR', type: 'text',editable:false },
    { label: 'SA2', fieldName: 'SA2', type: 'text' ,editable:false},
    { label: 'ACPRId', fieldName: 'ACPRId', type: 'text',editable:false },
    { label: 'SA2Id', fieldName: 'SA2Id', type: 'text',editable:false },
    { label: 'places', fieldName: 'places', type: 'number' ,editable:true,required:true}
];


export default class GpmsSDATable extends  OmniscriptBaseMixin(LightningElement) {
    columns = columns;
    @track data = [];
    @track ouputData = [];
    selectedkeys = [];
    connectedCallback() {
      if(this.omniJsonData.DistributionOfPlaces.CustomLWC5 == null){
        this.data = this.omniJsonData.tableValues;
      }else{
        this.data = this.omniJsonData.DistributionOfPlaces.CustomLWC5;
      }
      for(const dataItem of this.data){
        
        let tempRow = {
          "State": dataItem.State,
          "ACPR":dataItem.ACPR,
          "SA2":dataItem.SA2,
          "ACPRId":dataItem.ACPRId,
          "SA2Id":dataItem.SA2Id,
          "places":dataItem.places,
          "key":dataItem.key
        }
        this.ouputData.push(tempRow);
      }
    }
    handleChange(evt){
      const value = evt.target.value;
      const name = evt.target.name;
      for(const dataOutputItem of this.ouputData){
        if(dataOutputItem.key == name && this.ouputData!=null){
          dataOutputItem.places =value;
        } 
    }
    this.omniUpdateDataJson(this.ouputData);
  }
    
  }