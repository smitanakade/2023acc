/* Author: Nick Parsons
   Date Created: 15/8/22
   User Story: 233634
   Revision History: */

global with sharing class OmniPeriodEndingDateHelper implements Callable {

	public static Date getPeriodEndingDate(Id formId) {
        //Need to make the recordID context sensitive
        //String reportPeriodId = 'a2Y9h0000000KgHEAU';

        //Query to get the reporting period end date
        Date periodEndDate = [
            SELECT Reporting_Period__r.End_Date__c
            FROM Form__c
            WHERE Id =: formId
            LIMIT 1
        ].Reporting_Period__r.End_Date__c;

        //Return the date
        return periodEndDate;
    }


    global Object call(string action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        switch on action {
            when 'getPeriodEndingDate' {
                Date periodEndDate = getPeriodEndingDate((String)input.get('formId'));
                output.put('endingDate', periodEndDate);
                return true;
            }
            when else {
                throw new ExtensionMalformedException('Method not implemented');
            }
        }
    }
    public class ExtensionMalformedException extends Exception {}
}