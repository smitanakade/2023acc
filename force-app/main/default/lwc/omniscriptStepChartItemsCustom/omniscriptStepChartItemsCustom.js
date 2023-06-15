// eslint-disable-next-line no-unused-vars
import { LightningElement,api } from 'lwc';
import omniscriptStepChartItems from 'omnistudio/omniscriptStepChartItems';
import stpchrtitm from './omniscriptStepChartItemsCustom.html';

export default class OmniscriptStepChartItemsCustom extends omniscriptStepChartItems {


@api
  get isStepActive() {
    let isCompleteCheck;
    let currentStep = this.jsonDef.name;  // get step
    let key = currentStep.split(' ').join('') + 'IsComplete';
    isCompleteCheck=this.jsonData[key];

    if(typeof isCompleteCheck ==='undefined'){
           return true;}
    else{
      return Boolean(isCompleteCheck);
    }  
  } 

  render() {
    return stpchrtitm;
  }

}