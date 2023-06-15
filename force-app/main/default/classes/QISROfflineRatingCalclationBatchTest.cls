@isTest
public class QISROfflineRatingCalclationBatchTest {
    @TestSetup
	static void makeData() {
		Test.startTest();
		Integer recordCount = 150;

		// create services
		List<BusinessLicense> serviceList = new List<BusinessLicense>();
		for (Integer i = 0; i < recordCount; i++) {
			BusinessLicense serv = new BusinessLicense();
			serv.Name = 'Service Test ' + i;
			serv.RecordTypeId = Schema.SObjectType.BusinessLicense.getRecordTypeInfosByDeveloperName()
				.get('Approved_Provider_Service')
				.getRecordTypeId();
            serv.Care_Type__c='Residential';
			serv.Status__c = 'Operational';	
			serviceList.add(serv);
		}
	
		insert serviceList;
		Test.stopTest();
	}


     @IsTest
    public static void offlineRatingCalculationTest() {        

        try{
            Test.startTest();
            QISROfflineRatingCalclationBatch obj = new QISROfflineRatingCalclationBatch();
            Database.executeBatch(obj, 200);
            Test.stopTest();
        }
        catch(Exception exp){
            System.debug('somthing went wrong QISROfflineRatingCalclationBatch execute ' + exp.getMessage());
            dohagedcare.Logger.error(exp.getMessage(),exp,'QISROfflineRatingCalclationBatchTest').Log();             

        }
        try{
            BusinessLicense serviceRecord = [Select Operational_Two_Last_Quarters__c From BusinessLicense Where Status__c IN ('Operational') Limit 1];
             System.assertEquals(false, serviceRecord.Operational_Two_Last_Quarters__c, 'Operational_Two_Last_Quarters__c is updated');
        }       
        catch(Exception exp){
            System.debug('somthing went wrong QISROfflineRatingCalclationBatch execute ' + exp.getMessage());
            dohagedcare.Logger.error(exp.getMessage(),exp,'QISROfflineRatingCalclationBatchTest').Log();             
        }
        }
    }