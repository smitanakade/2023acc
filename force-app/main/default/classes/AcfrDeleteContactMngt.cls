public without sharing class AcfrDeleteContactMngt implements Callable{

    public static Boolean deleteContactRelationshipInfo(String cRelationId)
    {
        System.debug('Boolean deleteContactRelationshipInfo method');
        System.debug('deleteContactRelationshipInfo cRelationId: '+cRelationId);
       try{
         Contact_Relationship__c crelation =[Select id,contact__r.Id from Contact_Relationship__c  where id=: cRelationId Limit   1];
         Contact c=[Select id from Contact where id=:crelation.contact__r.Id Limit   1];
           delete crelation;
           delete c;     
          }
       Catch(DmlException e)
          {
            System.debug('Unable to delete case record'+e.getMessage());
          }
          return true;

          
    }

    public Object call(String action, Map<String, Object> args) {           
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        System.debug('Object call');
          switch on action {
            when 'deleteContactRelationshipInfo' {       
                System.debug('deleteContactRelationshipInfo cRelationId: '+(String)input.get('cRelationId'));     
               Boolean isDeleted = deleteContactRelationshipInfo((String)input.get('cRelationId'));
                output.put('deleteContactRelationshipInfo', JSON.serialize(isDeleted));
              return true;
            }                    
            when else {
             throw new ExtensionMalformedCallException('Method not implemented');
            }           
          }
        }
        public class ExtensionMalformedCallException extends Exception {}

}
