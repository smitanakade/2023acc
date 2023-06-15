import { LightningElement } from 'lwc';
import omniscriptStepChartItems from 'omnistudio/omniscriptStepChartItems';
import stpchrtitm from './omniscriptStepChartItemsIncompletedCustom.html';

export default class OmniscriptStepChartItemsIncompletedCustom extends omniscriptStepChartItems {
    completedwithsuccess ;

    render() {
        return stpchrtitm;
    }
}