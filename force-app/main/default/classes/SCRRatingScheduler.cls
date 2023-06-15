/*******************************************************************************************
 * @Name             SCRRatingScheduler
 * @Author           Daryl Dumas
 * @Date             11-14-2022
 * @LWC Component    None
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Daryl Dumas    						 11-14-2022          Initial Creation
 *  1.1			Gabriel			   						 16-11-2022          Updated modifier
 *******************************************************************************************/
public with sharing class SCRRatingScheduler implements Schedulable {
	public void execute(SchedulableContext sc) {
		SCRRatingCalculationBatch b = new SCRRatingCalculationBatch();
		database.executebatch(b, 200);
	}
}
