// eslint-disable-next-line no-unused-vars
import { LightningElement, api } from "lwc";
import omniscriptStepChart from "omnistudio/omniscriptStepChart";
import stpchrt from "./omniscriptStepChartCustom.html";

export default class OmniscriptStepChartCustom extends omniscriptStepChart {
  stepChartVisibility = 'stepchartvisible';
  stepChartIcon = 'utility:arrow_left';
    


  @api
  get className() {
    return this.stepChartVisibility;
  }

   @api 
  handleClick() {
    if (this.stepChartVisibility === 'stepchartvisible') {
      this.stepChartVisibility = 'stepchartinvisible';
      this.stepChartIcon = 'utility:arrow_right';
    } else if (this.stepChartVisibility === 'stepchartinvisible') {
      this.stepChartVisibility = 'stepchartvisible';
      this.stepChartIcon = 'utility:arrow_left';
    } 
  }

  applyPlacement() {
    super.applyPlacement();
  }

  render() {
    return stpchrt;
  }

}