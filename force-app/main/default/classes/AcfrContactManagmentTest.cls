@isTest(seeAllData=false)
public class AcfrContactManagmentTest {
  @TestSetup
  static void setup() {
    Account acc = new Account(
      Name = 'Test Provider',
      Purpose__c = 'Government',
      Incorporation_ID_Type__c = 'ACN',
      Prospective_Provider__c = 'No',
      Incorporation_ID__c = '852147963',
      RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE
          SobjectType = 'Account'
          AND IsActive = TRUE
          AND Name = 'Approved Provider'
        LIMIT 1
      ]
      .Id
    );
    insert acc;
    Contact c = new Contact();
    c.Salutation = 'Madam'; //Added by CJJOYA 20012023
    c.FirstName = 'testF';
    c.LastName = 'testL';
    c.phone = '0477788999';
    c.Email = 'a@g.com';
    insert c;
    Contact_Relationship__c crelation = new Contact_Relationship__c();
    crelation.Email__c = 'a@g.com';
    crelation.Primary_Contact__c = '0477788999';
    crelation.Position_Title__c = 'test';
    crelation.Contact__c = c.Id;
    insert crelation;
  }
  @isTest
  private static void addContactAndContactRelationShip() {
    Test.startTest();
    Account acc = [SELECT Id FROM Account LIMIT 1];
    String uploadClass = 'AcfrContactManagment';
    Boolean result;
    Map<String, Map<String, Object>> args1 = new Map<String, Map<String, Object>>{
      'output' => new Map<String, Object>(),
      'input' => new Map<String, Object>{
        'accountId' => acc.Id,
        'firstName' => 'testf1',
        'lastName' => 'testl1',
        'position' => 'testPosition',
        'email' => 'email@g.com',
        'phone' => '0455566777',
        'role' => 'test'
      }
    };

    TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
    User healthUser = healthUserBuilder.createUser();
    // When

    System.runAs(healthUser) {
      Callable extension = (Callable) Type.forName(uploadClass).newInstance();
      result = (Boolean) extension.call(
        'addContactAndContactRelationShip',
        args1
      );
    }
    // Then
    Test.stopTest();
    system.assertEquals(true, result);
  }

  @isTest
  private static void updateContactAndContactRelationShip() {
    Test.startTest();
    Contact_Relationship__c crelation = [
      SELECT Id
      FROM Contact_Relationship__c
      LIMIT 1
    ];

    // Given
    String uploadClass = 'AcfrContactManagment';
    Boolean result;
    Map<String, Map<String, Object>> args = new Map<String, Map<String, Object>>{
      'output' => new Map<String, Object>(),
      'input' => new Map<String, Object>{
        'cRelationId' => crelation.Id,
        'firstName' => 'testf1',
        'lastName' => 'testl1',
        'position' => 'testPosition',
        'email' => 'email@g.com',
        'phone' => '0455566777'
      }
    };

    TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
    User healthUser = healthUserBuilder.createUser();
    // When

    System.runAs(healthUser) {
      Callable extension = (Callable) Type.forName(uploadClass).newInstance();
      result = (Boolean) extension.call(
        'updateContactAndContactRelationShip',
        args
      );
    }
    // Then
    Test.stopTest();
    Contact updatedContact = [SELECT id, FirstName FROM Contact LIMIT 1];
    system.assertEquals(true, result);
    system.assertEquals(updatedContact.FirstName, 'testf1');
  }
}
