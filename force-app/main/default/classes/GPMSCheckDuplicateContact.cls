global with sharing class GPMSCheckDuplicateContact implements omnistudio.VlocityOpenInterface{
    
    global Boolean invokeMethod (String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result=true;
        
        try{
            if(methodName.equals('GPMSCheckDuplicateContactPOC')){
                GetDuplicateContact(inputMap,outMap,'POC');
            }else if(methodName.equals('GPMSCheckDuplicateContactKP')){
                GetDuplicateContact(inputMap,outMap,'KP');
            }
        } catch (Exception e){
            result = false;
        }
        return result;
    }
    
    public void GetDuplicateContact ( Map<String,Object> inputMap,Map<String,Object> outMap,String type){
        
        contactCRInfo crinfo = new contactCRInfo(type,inputMap);
        Contact con = formatContact(crinfo);

        Contact[] contacts = new List<Contact>{con};
            
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(contacts);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    outMap.put('DuplicateCount', matchResult.getMatchRecords().size());
                }
            }
        }
        
    }
    
    private Contact formatContact(contactCRInfo crinfo){
        
        contact con = new contact ();
        
        con.Salutation = crinfo.Salutation;
        con.FirstName = crinfo.FirstName;
        con.LastName = crinfo.LastName;
        con.MiddleName = crinfo.MiddleName;
        con.Preferred_Name__c = crinfo.PreferredName;
        
        if(crinfo.type == 'KP') con.Is_this_contact_a_Key_Personnel__c = true;
        
        String birthdate = crinfo.DateOfBirth;
        String year = birthdate.left(4);
        String month = birthdate.mid(5,2);
        String day = birthdate.mid(8,2);
        if(Integer.valueOf(month)<10) month = month.mid(1,1);
        if(Integer.valueOf(day)<10) day = day.mid(1,1);
        
        con.Birthdate = date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        con.BirthdateText__c = day+'/'+month+'/'+year;
        
        return con;
    }
    
    
    public class contactCRInfo{
        
        public String type;
        
        public String MiddleName;
        public String Salutation;
        public String FirstName;
        public String LastName;
        public String PreferredName;
        public String DateOfBirth;
            
        
        public String Role;
        public String PositionTitle;
        
        public String Phone;
        public String Mobile;
        public String Email;
        
        public String StartDate;
        public String EndDate;
        
        public contactCRInfo(String type, Map<String,Object> inputMap){
            this.type = type;
            if(type == 'POC'){
                this.MiddleName = (String)inputMap.get('MiddleName_POC');
                this.Salutation = (String)inputMap.get('Salutation_POC');
                this.FirstName = (String)inputMap.get('FirstName_POC');
                this.LastName = (String)inputMap.get('LastName_POC');
                this.PreferredName = (String)inputMap.get('PreferredName_POC');
                this.DateOfBirth = (String)inputMap.get('DateOfBirth_POC');                          
                this.Role = (String)inputMap.get('Role_POC');
                this.PositionTitle = (String)inputMap.get('PositionTitle_POC');
                this.Phone = (String)inputMap.get('Phone_POC');
                this.Mobile = (String)inputMap.get('Mobile_POC');
                this.Email = (String)inputMap.get('Email_POC');
                this.StartDate = (String)inputMap.get('StartDate_POC');
                this.EndDate = (String)inputMap.get('EndDate_POC');
            }else if(type == 'KP'){
                this.MiddleName = (String)inputMap.get('MiddleName_KP');
                this.Salutation = (String)inputMap.get('Salutation_KP');
                this.FirstName = (String)inputMap.get('FirstName_KP');
                this.LastName = (String)inputMap.get('LastName_KP');
                this.PreferredName = (String)inputMap.get('PreferredName_KP');
                this.DateOfBirth = (String)inputMap.get('DateOfBirth_KP');                        
                this.Role = (String)inputMap.get('Role_KP');
                this.PositionTitle = (String)inputMap.get('PositionTitle_KP');
                this.Phone = (String)inputMap.get('SecondContact_KP');
                this.Mobile = (String)inputMap.get('PrimaryContact_KP');
                this.Email = (String)inputMap.get('Email_KP');
                this.StartDate = (String)inputMap.get('StartDate_KP');
                this.EndDate = (String)inputMap.get('EndDate_KP');
            }
            
        }
    }
    
}