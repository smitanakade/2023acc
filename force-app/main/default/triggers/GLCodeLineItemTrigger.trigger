/*****************************************
*@Author        :Mark Daniel B. Alagdon
*@Company       :Accenture
*@Description   :
*@Test Class    :FinancialReportingRulesControllerTest
*@Date:N/A
*@Revision:
*When                 Who                       What
*06-Jan-2023          Mark Daniel B. Alagdon   Created
*****************************************/
trigger GLCodeLineItemTrigger on GL_Code_Line_Item__c (before update, after update) {	
    TriggerDispatcher.dispatch(new GLCodeLineItemTriggerHandler(), Trigger.operationType);
}