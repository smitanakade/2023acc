global with sharing class GPMSRelatedProviderController implements omnistudio.VlocityOpenInterface{
    
    global Boolean invokeMethod (String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result=true;
        
        try{
            if(methodName.equals('fetchAcoGrpMember')){
                fetchAcoGrpMember(inputMap,outMap);
            }else if(methodName.equals('fetchSingleAcoGrpMember')){
                fetchSingleAcoGrpMember(inputMap,outMap);
            }else if(methodName.equals('fetchAcoGrp')){
                fetchAcoGrp(inputMap,outMap);
            }
        } catch (Exception e){
            result = false;
        }
        return result;
    }
    
    public void fetchAcoGrp ( Map<String,Object> inputMap,Map<String,Object> outMap){
        
        String accid = (String)inputMap.get('AccountId');
        System.debug(accid);
        List<Account> accs = new List<Account>();
        List<ACO_Group_Member__c> acogrpmember = new List<ACO_Group_Member__c>();
        Set<Id> groupIds = new Set<Id>();
        try{
            List<Account_Relationship__c> providerACO = [SELECT id, Account_From_Id__c, Account_To_Id__c FROM Account_Relationship__c where Account_To_Id__c=:accid];        
            if(providerACO.isEmpty()) return;
            System.debug(providerACO);
            List<ACO_Group_Member__c> ACOGroupMember = [SELECT id, ACOs_to_link__c,ACOs_to_link__r.name,ACO_Group_Name__c,ACO_Group_Name__r.name,ACO_Group_Name__r.id,Name FROM ACO_Group_Member__c where ACOs_to_link__c=:providerACO[0].Account_From_Id__c];
            if(ACOGroupMember.isEmpty()) return;
            System.debug(ACOGroupMember);
            for(ACO_Group_Member__c member : ACOGroupMember){
                groupIds.add(member.ACO_Group_Name__c);
            }
            System.debug(groupIds);
            
			List<ACO_Group__c> groups = [SELECT Id,Name,Reason__c,Comments__c,CreatedById,CreatedBy.Name,CreatedDate FROM ACO_Group__c WHERE Id in :groupIds];
            if(groups.isEmpty()) return;
            
            List < Map < String, String >> result = new List < Map < String,String >> ();
            Map<Id,Set<Id>> ACOGroupIdMap = new Map<Id,Set<Id>>();
            For(ACO_Group__c acogroup : groups){
                Map < String, String > tempMap = new Map < String, String > ();
                
                tempMap.put('ACOGroupName', acogroup.Name);
                tempMap.put('ACOGroupId', acogroup.Id);
                tempMap.put('ACOGroupReason', acogroup.Reason__c);
                tempMap.put('ACOGroupComments', acogroup.Comments__c);
                tempMap.put('ACOGroupCreatedById', acogroup.CreatedById);
                tempMap.put('ACOGroupCreatedBy', acogroup.CreatedBy.Name);
                date createdDate = acogroup.CreatedDate.dateGMT();
                Integer day = createdDate.day();
                Integer month = createdDate.month();
                Integer year = createdDate.year();
                tempMap.put('ACOGroupCreatedDate', String.valueOf(day)+'/'+String.valueOf(month)+'/'+year);
                result.add(tempMap);
            }
            
            outMap.put('result', result);
            
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
    }
    
    public void fetchAcoGrpMember ( Map<String,Object> inputMap,Map<String,Object> outMap){
        
        String accid = (String)inputMap.get('AccountId');
        System.debug(accid);
        List<Account> accs = new List<Account>();
        List<ACO_Group_Member__c> acogrpmember = new List<ACO_Group_Member__c>();
        Set<Id> groupIds = new Set<Id>();
        try{
            List<Account_Relationship__c> providerACO = [SELECT id, Account_From_Id__c, Account_To_Id__c FROM Account_Relationship__c where Account_To_Id__c=:accid];        
            if(providerACO.isEmpty()) return;
            System.debug(providerACO);
            List<ACO_Group_Member__c> ACOGroupMember = [SELECT id, ACOs_to_link__c,ACOs_to_link__r.name,ACO_Group_Name__c,ACO_Group_Name__r.name,ACO_Group_Name__r.id,Name FROM ACO_Group_Member__c where ACOs_to_link__c=:providerACO[0].Account_From_Id__c];
            if(ACOGroupMember.isEmpty()) return;
            System.debug(ACOGroupMember);
            for(ACO_Group_Member__c member : ACOGroupMember){
                groupIds.add(member.ACO_Group_Name__c);
            }
            System.debug(groupIds);
            getRelatedProvider(groupIds,outMap);
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
    }
    
    public void getRelatedProvider(set<Id> groupIds,Map<String,Object> outMap){
        Map<Id,ACO_Group__c> groups = new Map<Id,ACO_Group__c>([SELECT Id,Name,Reason__c,Comments__c,CreatedById,CreatedBy.Name,CreatedDate,(SELECT Id,Name,ACOs_to_link__c FROM ACO_Group_Members__r) FROM ACO_Group__c WHERE Id in :groupIds]);
        if(groups.isEmpty()) return;
        
        Map<Id,Set<Id>> ACOGroupIdMap = new Map<Id,Set<Id>>();
        For(ACO_Group__c acogroup : groups.values()){
            for(ACO_Group_Member__c acomember : acogroup.ACO_Group_Members__r){
                Set<Id> temp = new Set<Id>();
                if(ACOGroupIdMap.get(acomember.ACOs_to_link__c) != null){
                    temp = ACOGroupIdMap.get(acomember.ACOs_to_link__c);
                }
                temp.add(acogroup.Id);
                ACOGroupIdMap.put(acomember.ACOs_to_link__c,temp);
            }
        }
        
        List<Account_Relationship__c> ACOs = [SELECT Id, Name,Account_From_Id__c,Account_From_Id__r.Name,Account_To_Id__c,Account_To_Id__r.Name FROM Account_Relationship__c WHERE Account_From_Id__c in:ACOGroupIdMap.keyset() AND Account_To_Id__r.RecordType.DeveloperName in ('Approved_Provider','Commonwealth_Home_Support_Programme','National_Aboriginal_and_Torres_Strait_Islander_Flexible_Aged_Care')];
        
        Map<String,List<Account_Relationship__c>> ACOGroupProviders = new Map<String,List<Account_Relationship__c>>();
        for(Account_Relationship__c ar : ACOs){
            for(Id ACOGroupId : ACOGroupIdMap.get(ar.Account_From_Id__c)){
                List<Account_Relationship__c> tmp = new List<Account_Relationship__c>();
                if(ACOGroupProviders.get(ACOGroupId) != null){
                    tmp = ACOGroupProviders.get(ACOGroupId);
                }
                tmp.add(ar);
                ACOGroupProviders.put(ACOGroupId,tmp);
            }
        }
        
        List < Map < String, String >> result = new List < Map < String,String >> ();
        for (String groupId: ACOGroupProviders.keyset()) {
            for(Account_Relationship__c ar : ACOGroupProviders.get(groupId)){
                Map < String, String > tempMap = new Map < String, String > ();
                
                tempMap.put('ACOGroupName', groups.get(groupId).Name);
                tempMap.put('ACOGroupId', groups.get(groupId).Id);
                tempMap.put('ACOGroupReason', groups.get(groupId).Reason__c);
                tempMap.put('ACOGroupComments', groups.get(groupId).Comments__c);
                tempMap.put('ACOGroupProvider', ar.Account_To_Id__r.Name +' ('+ar.Account_From_Id__r.Name+')');
                tempMap.put('ACOGroupProviderId', ar.Account_To_Id__c);
                tempMap.put('ACOGroupProviderName', ar.Account_To_Id__r.Name);
                tempMap.put('ACOGroupACOName', ar.Account_From_Id__r.Name);
                tempMap.put('ACOGroupACOId', ar.Account_From_Id__c);
                tempMap.put('ACOGroupCreatedById', groups.get(groupId).CreatedById);
                tempMap.put('ACOGroupCreatedBy', groups.get(groupId).CreatedBy.Name);
                date createdDate = groups.get(groupId).CreatedDate.dateGMT();
                Integer day = createdDate.day();
                Integer month = createdDate.month();
                Integer year = createdDate.year();
                tempMap.put('ACOGroupCreatedDate', String.valueOf(day)+'/'+String.valueOf(month)+'/'+year);
                result.add(tempMap);
            }
        }        
        outMap.put('result', result);
    }
    
    public void fetchSingleAcoGrpMember (Map<String,Object> inputMap,Map<String,Object> outMap){
        String accid = (String)inputMap.get('AccountId');
        Set<Id> groupIds = new Set<Id>();
        groupIds.add(accid);
        getRelatedProvider(groupIds,outMap);
    }
    
}