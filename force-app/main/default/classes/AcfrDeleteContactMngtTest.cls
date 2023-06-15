@isTest(seeAllData=false)
public class AcfrDeleteContactMngtTest {
    static testMethod void deleteContactRelationshipInfo(){
        Test.startTest();
        Contact c= new Contact();
        c.Salutation ='madam';
        c.FirstName='testF';
        c.LastName='testL'; 
        c.phone='0477788999';
        c.Email='a@g.com';
        insert c;
        Contact_Relationship__c crelation=new  Contact_Relationship__c ();
        crelation.Email__c='a@g.com';
        crelation.Primary_Contact__c='0477788999';
        crelation.Position_Title__c='test';
        crelation.Contact__c=c.Id;           
        insert crelation;
        // Given   
        String uploadClass = 'AcfrDeleteContactMngt';
        Boolean result;
        Map<String, Map<String, Object>> args = new Map<String, Map<String, Object>> {
            'output' => new Map<String, Object>(),
                'input' => new Map<String, Object> {
                    'cRelationId' => crelation.Id
                        }  
        };
            
        TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
        User healthUser = healthUserBuilder.createUser();
        // When
        
        System.runAs(healthUser) {
            Callable extension = (Callable) 
                Type.forName(uploadClass).newInstance();
            result = (Boolean)
                extension.call('deleteContactRelationshipInfo', args);
        }            
        // Then
        Test.stopTest(); 
      //  Contact deleteContact = [Select id, FirstName from Contact];
        system.assertEquals(true, result);
      //  system.assertEquals(deleteContact.FirstName, 'testf1');           
    }
}