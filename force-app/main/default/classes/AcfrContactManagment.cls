public without sharing class AcfrContactManagment implements Callable {
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    switch on action {
      when 'updateContactAndContactRelationShip' {
        Boolean isUpdated = updateContactAndContactRelationShip(
          (String) input.get('cRelationId'),
          (String) input.get('firstName'),
          (String) input.get('lastName'),
          (String) input.get('position'),
          (String) input.get('email'),
          (String) input.get('phone')
        );
        output.put(
          'updateContactAndContactRelationShip',
          JSON.serialize(isUpdated)
        );
        return true;
      }
      when 'addContactAndContactRelationShip' {
        Boolean isAddMethod = addContactAndContactRelationShip(
          (String) input.get('accountId'),
          (String) input.get('firstName'),
          (String) input.get('lastName'),
          (String) input.get('position'),
          (String) input.get('email'),
          (String) input.get('phone'),
          (String) input.get('role')
        );
        output.put(
          'addContactAndContactRelationShip',
          JSON.serialize(isAddMethod)
        );
        return true;
      }
      when else {
        throw new ExtensionMalformedCallException('Method not implemented');
      }
    }
  }

  public static Boolean updateContactAndContactRelationShip(
    String cRelationId,
    String firstName,
    String lastName,
    String position,
    String email,
    string phone
  ) {
    try {
      Contact_Relationship__c crelation = [
        SELECT id, contact__r.Id
        FROM Contact_Relationship__c
        WHERE id = :cRelationId
        LIMIT 1
      ];
      Contact c = [SELECT id FROM Contact WHERE id = :crelation.contact__r.Id];
      c.FirstName = firstName;
      c.LastName = lastName;
      c.phone = phone;
      c.Email = email;
      crelation.Email__c = email;
      crelation.Primary_Contact__c = phone;
      crelation.Position_Title__c = position;
      update crelation;
      update c;
    } catch (Exception e) {
      dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
    }
    return true;
  }

  public static Boolean addContactAndContactRelationShip(
    String accountId,
    String firstName,
    String lastName,
    String position,
    String email,
    string phone,
    String role
  ) {
     try {
      Contact c = new Contact();
      c.FirstName = firstName;
      c.LastName = lastName;
      c.phone = phone;
      c.Email = email;
      c.accountId = accountId;
      c.Contact_type__c = 'QFR Primary Contact';
         c.Salutation = 'Ms';
      c.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Financial_Contact_QFR_ACFR')
        .getRecordTypeId();
      if (c != null)
        insert c;

      Contact_Relationship__c cr = new Contact_Relationship__c();
      cr.Email__c = email;
      cr.Primary_Contact__c = phone;
      cr.Position_Title__c = position;
      cr.recordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName()
        .get('FinancialContactQFRACFR')
        .getRecordTypeId();
      cr.account__c = accountId;
      cr.role__c = role;
      cr.Start_date__c = System.today();
      cr.Contact__c = c.id;

      insert cr;
    } catch (Exception e) {
      dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
    }
    return true;
  }
  public class ExtensionMalformedCallException extends Exception {
  }
}