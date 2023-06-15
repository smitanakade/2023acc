/**
 * An apex page controller that handles deletion of GPMS_Emergency_Situation__c record
 */
public with sharing class EmergencySituationMessageController {

    private GPMS_Emergency_Situation__c emergencySituation;    
    
    public EmergencySituationMessageController(ApexPages.StandardController controller) {
		if(!Test.isRunningTest()) controller.addFields(new List<String> {'Service__c'});
		this.emergencySituation = (GPMS_Emergency_Situation__c) controller.getRecord();
    }
    
    public PageReference customDelete() {
        try {
        	delete this.emergencySituation;
        	return goBackToListView();    
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot delete this record'));
            dohagedcare.Logger.error(ex.getMessage(),ex,'GPMS').Log();
            return null;
        }
	}
    
    private PageReference goBackToListView() {
        String listViewPage = '/lightning/r/GPMS_Emergency_Situation__c/'
            +this.emergencySituation.Service__c+
            '/related/Incidents__r/view?ws=%2Flightning%2Fr%2FBusinessLicense%2F'+
            this.emergencySituation.Service__c+'%2Fview';
        PageReference pageRef = new PageReference(listViewPage);
        pageRef.setRedirect(true);
        return pageRef;
    }
}