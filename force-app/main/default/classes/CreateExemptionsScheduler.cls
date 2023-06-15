/*******************************************************************************************
 * @Name             CreateExemptionsScheduler
 * @Test class       CreateExemptionsSchedulerTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             17-11-2022
 * @Story#           280716
 * @LWC Component    None
 * @Description      Schedule create exemption batch class
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida    17-11-2022          Initial Creation
 *******************************************************************************************/
public with sharing class CreateExemptionsScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
		CreateExemptionsBatch b = new CreateExemptionsBatch();
		Database.executebatch(b, 200);
	}
}
