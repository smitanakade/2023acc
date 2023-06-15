@SuppressWarnings('apex:AvoidGlobalModifier')
global with Sharing class srqiOmniscriptLWCRichText implements omnistudio.VlocityOpenInterface2 {
    global Object call(String action, Map<String, Object> args) {
       
       Map<String, Object> input = (Map<String, Object>)args.get('input');
       Map<String, Object> output = (Map<String, Object>)args.get('output');
       Map<String, Object> options = (Map<String, Object>)args.get('options');

       return invokeMethod(action, input, output, options);
   }
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    switch on methodName {
      when 'getResponseforIssue' {
        string datatableDef = getResponseforIssue(
          (String) input.get('recordid')
        );
        output.put(
          'getResponseforIssue',
          JSON.deserializeUntyped(JSON.serialize(datatableDef))
        );
        return true;
      }
        when 'getDecisionDetails' {
        string DecisionDetails = getDecisionDetails(
          (String) input.get('recordid')
        );
        output.put(
          'getDecisionDetails',
          JSON.deserializeUntyped(JSON.serialize(DecisionDetails))
        );
        return true;
      }
        when 'getProgressDetails' {
        string ProgressDetails = getProgressDetails(
          (String) input.get('recordid')
        );
        output.put(
          'getProgressDetails',
          JSON.deserializeUntyped(JSON.serialize(ProgressDetails))
        );
        return true;
      }
        when else {
        throw new QiSrCustomDatatableException(
          'Specified action not supported'
        );
      }

    }
  }
public class QiSrCustomDatatableException extends Exception {
  }
    public static string getResponseforIssue( string Id) {
        
          String returnParam='';
          List<RegulatoryCodeViolation> ResponseforIssue =[select Reason_for_issuing_Regulatory_Decision__c from RegulatoryCodeViolation where Id =: Id LIMIT 1 ];
 			returnParam= ResponseforIssue[0].Reason_for_issuing_Regulatory_Decision__c;
        
            return returnParam;
       
    }
     public static string getDecisionDetails( string Id) {
        
          String returnParam='';
          List<RegulatoryCodeViolation> DecisionDetails =[select Decision_Details__c from RegulatoryCodeViolation where Id =: Id LIMIT 1 ];
 			returnParam= DecisionDetails[0].Decision_Details__c;
        
            return returnParam;
       
    }
     public static string getProgressDetails( string Id) {
        
          String returnParam='';
         List<RegulatoryCodeViolation> ProgressDetails =[select Progress__c  from RegulatoryCodeViolation where Id =: Id LIMIT 1 ];
        returnParam = ProgressDetails[0].Progress__c;
            return returnParam;
       
    }

}