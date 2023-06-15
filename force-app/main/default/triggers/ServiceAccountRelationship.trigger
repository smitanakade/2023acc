/*******************************************************************************************
 * @Name             ServiceAccountRelationship
 * @Test class       ServiceAccountRelationshipTriggerTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             23-09-2022
 * @Story#           225789 (SR-QI ART Planning Sprint 4)
 * @LWC Component    None
 * @Description      Dispatch after insert and after update in SAR and depending on conditions
 *                   system exemptions will be created
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Gabriel Piragibe Cova Leda de Almeida    23-09-2022       Initial Creation
 *  1.1				Gabriel Piragibe Cova Leda de Almeida    10-11-2022       Removed after insert
 *******************************************************************************************/
trigger ServiceAccountRelationship on Service_Account_Relationship__c(after update) {
	if (!(new TriggerBypassStrategy().isDisabled())) {
		switch on Trigger.operationType {
			when AFTER_UPDATE {
				TriggerDispatcher.dispatch(new ServiceAcctRelationshipHandler(), TriggerOperation.AFTER_UPDATE);
			}
		}
	}
}