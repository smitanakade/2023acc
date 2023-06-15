@IsTest
public class GPMSCheckDuplicateContactTest {
    
    @testSetup static void setup() {
        Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Birthdate = System.today().addYears(-20);     
        con.Salutation = 'Mr';
        insert con;
    }
    
    @isTest static void testGPMSCheckDuplicateContactPOC() {
        
        Map<String,Object> inputMap = formatInput('POC');
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        GPMSCheckDuplicateContact checkDuplicate = new GPMSCheckDuplicateContact();
        Boolean result = checkDuplicate.invokeMethod('GPMSCheckDuplicateContactPOC',inputMap,outMap,options);
        
        
    }
    
    @isTest static void testGPMSCheckDuplicateContactKP() {
        
        Map<String,Object> inputMap = formatInput('KP');
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        GPMSCheckDuplicateContact checkDuplicate = new GPMSCheckDuplicateContact();
        Boolean result = checkDuplicate.invokeMethod('GPMSCheckDuplicateContactKP',inputMap,outMap,options);
        
    }
    
    private static Map<String,Object> formatInput(String personType){
        
        Date birthdate = System.today().addYears(-20);
        String DateOfBirthYear = String.valueOf(birthdate.year());
        String DateOfBirthMonth = String.valueOf(birthdate.Month());
        if(birthdate.Month()<10) DateOfBirthMonth = '0'+DateOfBirthMonth;
        String DateOfBirthDay = String.valueOf(birthdate.Day());
        if(birthdate.Day()<10) DateOfBirthDay = '0'+DateOfBirthDay;
        String DateOfBirth = DateOfBirthYear + '-' + DateOfBirthMonth + '-' +DateOfBirthDay;
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        inputMap.put('MiddleName_'+personType,'Middle');
        inputMap.put('Salutation_'+personType,'Miss');
        inputMap.put('FirstName_'+personType,'First');
        inputMap.put('LastName_'+personType,'Last');
        inputMap.put('PreferredName_'+personType,'TestPrefer');
        inputMap.put('DateOfBirth_'+personType,DateOfBirth);      
        inputMap.put('Role_'+personType,'Role');
        inputMap.put('PositionTitle_'+personType,'PositionTitle');
        inputMap.put('Phone_'+personType,'0483765212');
        inputMap.put('Mobile_'+personType,'0483765212');
        inputMap.put('Email_'+personType,'test.gmail.com');
        inputMap.put('StartDate_'+personType,'2022-01-02');
        inputMap.put('EndDate_'+personType,'2026-01-02');
        
        return inputMap;
    }
    
}