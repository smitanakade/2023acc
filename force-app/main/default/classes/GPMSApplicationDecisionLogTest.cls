@IsTest
public class GPMSApplicationDecisionLogTest {
    
    private static User currentUser = TestDataFactory.createGPMSTestUser();
    
    @testSetup static void setup() {
        
        System.runAs(currentUser){

            RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(name='Application-CareType', RegulatoryAuthCategory='License');
            insert licenseType;
            
            Account acc = GPMSTestUtility.getAccountByRecordType('Approved_Provider');
            Insert acc;
            
            BusinessLicenseApplication application = new BusinessLicenseApplication(AccountId = acc.Id, NewStatus__c = 'Application submission receipt',PaymentReferenceNumber__c = '890');
            application.CareTypes__c = 'Home Care;Residential';
            application.LicenseTypeId = licenseType.Id;
            application.status = 'Submitted';
            application.AppliedDate = System.now();
            application.recordTypeId = Schema.SObjectType.BusinessLicenseApplication.getRecordTypeInfosByDeveloperName().get('CaretypeApplicationSubmitted').getRecordTypeId();
            insert application;
            
            Recommendation_Log__c AATReviewLog = new Recommendation_Log__c(ApplicationId__c = application.Id);
            insert AATReviewLog;
            
            Recommendation_Item__c recommendationItem = new Recommendation_Item__c(Recommendation_Log__c = AATReviewLog.Id);
            insert recommendationItem;
            
            List<Care_Type__c> caretypes = [SELECT Id FROM Care_Type__c WHERE ApplicationId__c = :application.Id];
            List<Recommendation_Item_Care_Type__c> itemCareTypeToInsert = new List<Recommendation_Item_Care_Type__c>();
            for(Care_Type__c ct : caretypes){
                 Recommendation_Item_Care_Type__c itemct = new Recommendation_Item_Care_Type__c(Care_Type__c = ct.Id);
                 itemCareTypeToInsert.add(itemct);
            }
            insert itemCareTypeToInsert;
            
        }
        
    }
    
    @isTest static void testGPMSStreetStringFormatreplace() {
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        System.runAs(currentUser){
            
            Test.startTest();
            
            BusinessLicenseApplication application = [SELECT Id FROM BusinessLicenseApplication limit 1];
            
            GPMSApplicationDecisionLog decisionlog = new GPMSApplicationDecisionLog();
            
            //Application decsion log
            inputMap.put('ApplicationId',Application.Id);
            inputMap.put('Type','applicationrecommendation');
            Object applicationlog = decisionlog.invokeMethod('DecisionLog',inputMap,outMap,options);
            System.assertEquals(true, (Boolean)applicationlog, 'Get application decision log failed');
            
            //Application reconsideration log
            inputMap.put('Type','applicationreconsideration');
            Object applicationreconsiderationlog = decisionlog.invokeMethod('DecisionLog',inputMap,outMap,options);
            System.assertEquals(true, (Boolean)applicationreconsiderationlog, 'Get reconsideration log failed');
            
            //Application reconsideration outcome log
            inputMap.put('Type','applicationReconsiderationOutcome');
            Object applicationreconsiderationOutcomelog = decisionlog.invokeMethod('DecisionLog',inputMap,outMap,options);
            System.assertEquals(true, (Boolean)applicationreconsiderationOutcomelog, 'Get reconsideration reconsideration outcome log failed');
            
            //Application AATReview log
            inputMap.put('Type','applicationAATReview');
            Object applicationAATReviewlog = decisionlog.invokeMethod('DecisionLog',inputMap,outMap,options);
            System.assertEquals(true, (Boolean)applicationAATReviewlog, 'Get Application AATReview log failed');
            
            Test.stopTest();
            
        }
        
        
    }
    
}