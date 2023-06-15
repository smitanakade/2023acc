/**
* author: Daniel Clift
* date: 18/08/2022
* description: scheduler class to call ratingscalculationhandler
**/

public with sharing class RatingsCalculationScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        RatingsCalculationHandler.executeHandler();
    }
}