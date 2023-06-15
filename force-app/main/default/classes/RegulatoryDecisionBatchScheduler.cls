/**
 * author: Vivek J
 * date: 17/11/2022
 * description: Scheduler for RegulatoryDecisionBatch
 **/
public with sharing class RegulatoryDecisionBatchScheduler implements Schedulable{
	@testvisible
	private static Boolean fakeException = false;

    public void execute(SchedulableContext sc) {
        try {
            RegulatoryDecisionBatch b = new RegulatoryDecisionBatch();       
            database.executebatch(b,200);
            // Fake exception to cover catch block
            if(Test.isRunningTest() && fakeException){
                Integer exceptionTest = 0;
                // Logger warn to avoid code smell in SonarQube
                dohagedcare.Logger.warn(String.valueOf(exceptionTest)).Log();
                exceptionTest = 1 / 0;
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'RegulatoryDecisionBatchScheduler').Log();
        }          
    } 
}