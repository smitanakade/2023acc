//********************************************
//Apex Class		:OmniFileUploadHelper
//Test Classname	:OmniFileUploadHelperTest
//Author			:N Parsons
//Date Created		:
//
//Revision History 	:
//	20012023		:CJJOYA - Modify line 6 to include RecordTypeId for creating QFR case
//  20012024        :NPPARSONS - Changed input parameter from recordId to caseId
@isTest
public class OmniFileUploadHelperTest {
    @isTest static void OmniFileUploadHelperTest() {
        // Setup
        
        //Get QFR Case Record Type
        String strRecordTypeId = [Select Id from RecordType where SobjectType='Case' and Name ='QFR'].Id; //Added by CJ 20012023
        Case c = new Case();
        c.RecordTypeId = strRecordTypeId; //Added by CJ 20012023
        insert c;
        
        Form__c f = new Form__c();
        f.CreatedDate = Datetime.newInstance(2022, 9, 14);
        f.QA_Outcome__c = 'Re-Issue';
        f.QA_Comments__c = 'Re-Issue Form'; //Added by CJ 20012023 QA Comments Mandatory field
        f.Type__c = 'Declaration and Submission';
        f.Case__c = c.Id;
        insert f;

        ContentVersion cd = new ContentVersion();
        cd.title = 'PDFforQFR';
        cd.PathOnClient = 'test.pdf';
        cd.ContentLocation = 'S';
        cd.VersionData = Blob.valueOf('test file content');
        cd.FirstPublishLocationId = c.Id;
        insert cd;

        TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
        User healthUser = healthUserBuilder.createUser();

        // Given
        String titleTestValue = cd.title;
        String uploadClass = 'OmniFileUploadHelper';
        Boolean result;
        Map<String, Map<String, Object>> args = new Map<String, Map<String, Object>> {
                'output' => new Map<String, Object>(),
                'input' => new Map<String, Object> {
                    'caseId' => c.Id
                }  
        };

        // When
        Test.startTest();
            System.runAs(healthUser) {
                Callable extension = (Callable) 
                        Type.forName(uploadClass).newInstance();
                result = (Boolean)
                        extension.call('getRelatedFiles', args);
            }
        Test.stopTest();
                
        // Then
        system.assertEquals(true, result);
        String resultFilesJSON = (String) args.get('output').get('relatedFile');
        List<OmniFileUploadHelper.File> resultFiles = (List<OmniFileUploadHelper.File>) JSON.deserialize(resultFilesJSON, List<OmniFileUploadHelper.File>.class);
		system.assertEquals(1, resultFiles.size());
        system.assertEquals(titleTestValue, resultFiles.get(0).Title);
    }
}