/*****************************************
*@Author        :Mark Daniel B. Alagdon
*@Company       :Accenture
*@Description   :
*@Test Class    :GLCodeLineItemTriggerHandler
*@Date:N/A
*@Revision:
*When                 Who                       What
*06-Jan-2023          Mark Daniel B. Alagdon   Created
*****************************************/
public with sharing class GLCodeLineItemTriggerHandler implements AfterUpdate, Disableable {
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // Cast SObject to GLCodeLineItem object so we can access lookup fieds
		Map<Id, GL_Code_Line_Item__c> newGLCodeLineItems = new Map<Id, GL_Code_Line_Item__c>(
			(List<GL_Code_Line_Item__c>) newItems.values()
		);
        
        Map<Id, GL_Code_Line_Item__c> oldGLCodeLineItems = new Map<Id, GL_Code_Line_Item__c>(
			(List<GL_Code_Line_Item__c>) oldItems.values()
		);
        FinancialReportingRulesController.runQFRRules(newGLCodeLineItems, oldGLCodeLineItems);            
    }
  
    public Boolean isDisabled() {
      return false;
    }
  }