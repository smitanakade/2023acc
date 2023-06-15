/****************************************************************************************************
* @CreatedBy   : Accenture Developer Team
* @CreatedDate : 1-Nov-2022
* @Description : Handles the logic to create new places for allotment
* @testClass GPMSCreateUpdatePlaceStatusTest
*****************************************************************************************************/
global with sharing class GPMSCreateUpdatePlaceStatus implements Callable {
    
    public Object call(String action, Map<String, Object> args) {
        
        try {
            Map<String, Object> input = (Map<String, Object>)args.get('input');
            Map<String, Object> output = (Map<String, Object>)args.get('output');
            return invokeMethod(action, input, output);
        } catch (exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log();
            return true;
        }
        
    }
    
    private Object invokeMethod(String action, Map<String, Object>inputMap, Map<String, Object> outputMap) {
        
        if (null == inputMap.get('Places') 
            || null == inputMap.get('AllotmentId') 
            || null == inputMap.get('EventId') 
            || null == inputMap.get('UpdateParentPacket')) {
            return null;
        }
        
        List < Map < String, String >> result = new List < Map < String,String >> ();
        
        String allotmentId = (String)inputMap.get('AllotmentId');
        String eventId = (String)inputMap.get('EventId');
        String needApproval = (String)inputMap.get('NeedApproval');
        String updateParentPacket = (String)inputMap.get('UpdateParentPacket');

        PacketDTO packet = new PacketDTO(needApproval, eventId, allotmentId);
        
        Map < String, Places_Allotment__c> allNewPlaces = new Map <String, Places_Allotment__c> ();
        
        if (inputMap.get('Places') instanceof List<Object>) {
            
            List<Object> placesList = (List<Object>)inputMap.get('Places');
            
            for (object place : placesList) {
                
                Map<String,Object> placeFormat = (Map<String,Object>)place;
                
                Places_Allotment__c placeNew = formatePlace(placeFormat,packet);
                
                if(null != placeNew){
                    String packetId = generatePacketUniqueId(placeNew);
                    if(null == allNewPlaces.get(packetId)){
                        allNewPlaces.put(packetId, placeNew);
                    }else{
                        allNewPlaces.get(packetId).Number_of_Places__c = allNewPlaces.get(packetId).Number_of_Places__c + placeNew.Number_of_Places__c;
                    }
                }
                
            }
            
        }else {
            Map<String,Object> placeFormat = (Map<String,Object>)inputMap.get('Places');
            Places_Allotment__c placeNew = formatePlace(placeFormat,packet);
            if(null != packet){
                String packetId = generatePacketUniqueId(placeNew);
            	allNewPlaces.put(packetId, placeNew);
            }
            
        }
        
        packet.allNewPlaces = allNewPlaces;
        
        List<Places_Allotment__c> placeToUpsert = new List<Places_Allotment__c>();
        if('Yes'.equalsIgnoreCase(updateParentPacket)){
            placeToUpsert.addAll(getParentPlaces(packet));
        }
        placeToUpsert.addAll(getNewPlaces(packet));
        
        if(!placeToUpsert.isEmpty()){
            upsert placeToUpsert;
        }
        
        outputMap.put('result',result);
        
        return true;
    }
    
    private Places_Allotment__c formatePlace(Map<String,Object> placeFormat, PacketDTO packet){
        
        Places_Allotment__c place = new Places_Allotment__c(Allotment__c = packet.allotmentId,Event__c = packet.eventId);
        
        place.Parent_Packet__c = (String)placeFormat.get('Id');
        place.Care_Level__c = (String)placeFormat.get('CareLevel');
        place.Care_Type__c = (String)placeFormat.get('CareType');
        place.Care_Setting__c = (String)placeFormat.get('CareSetting');
        place.Status_of_Places__c = (String)placeFormat.get('StatusChangeTo');
        place.Status_Reason__c = (String)placeFormat.get('StatusReason');
        
        
        if(placeFormat.get('NumberOfChanges') instanceof String){
            String numberOfPlaces = (String)placeFormat.get('NumberOfChanges');
            place.Number_of_Places__c = Integer.valueOf(numberOfPlaces);
        }else if(placeFormat.get('NumberOfChanges') instanceof Double){
            Double numberOfPlaces = (Double)placeFormat.get('NumberOfChanges');
            place.Number_of_Places__c = Integer.valueOf(numberOfPlaces);
        }else{
            place.Number_of_Places__c = 0;
        }
        
        place.Current__c = 'Yes';
        if(String.isNotBlank(packet.needApproval) && 'Yes'.equalsIgnoreCase(packet.needApproval)){
            place.Current__c = 'Pending';
        }
        
        String statusEffectiveDate = (String)placeFormat.get('StatusEffectiveDate');
        String careSettingDate = (String)placeFormat.get('CareSettingEffectiveDate');
        
        String expectedEndDateText = (String)placeFormat.get('ExpectedOfflineEndDate');
        if(String.isNotBlank(expectedEndDateText)){
            date expectedEndDateDate = date.valueOf(expectedEndDateText);
        	place.GPMS_Expected_Offline_End_Date__c = expectedEndDateDate;
        }
            
        place.First_Brought_into_Effect_Date__c = System.today();
        place.Status_Effective_Date__c = formatDateFromString(statusEffectiveDate);
        place.Care_Setting_Effective_Date__c = formatDateFromString(careSettingDate);
        
        return place;
        
    }
    
    private date formatDateFromString(string dateString){
        
        if(String.isBlank(dateString)){
            return null;
        }
        
        List<String> dateStringList = dateString.split('/');
        
        if(dateStringList.size() != 3){
            return null;
        }
        
        String returnDate = dateStringList[2] + '-' + dateStringList[1] + '-' + dateStringList[0];
        
        return date.valueOf(returnDate);
        
    }
    
    private String generatePacketUniqueId(Places_Allotment__c place){
        
        String packetId = '';
        
        if(String.isNotBlank(place.Parent_Packet__c)){
            packetId = packetId + place.Parent_Packet__c;
        }
        
        if(String.isNotBlank(place.Care_Level__c)){
            packetId = packetId + place.Care_Level__c;
        }
        
        if(String.isNotBlank(place.Care_Type__c)){
            packetId = packetId + place.Care_Type__c;
        }
        
        if(String.isNotBlank(place.Care_Setting__c)){
            packetId = packetId + place.Care_Setting__c;
        }
        
        if(String.isNotBlank(place.Status_of_Places__c)){
            packetId = packetId + place.Status_of_Places__c;
        }
        
        if(String.isNotBlank(place.Status_Reason__c)){
            packetId = packetId + place.Status_Reason__c;
        }
        
        if(null != place.Status_Effective_Date__c){
            packetId = packetId + String.valueof(place.Status_Effective_Date__c);
        }
        
        if(null != place.First_Brought_into_Effect_Date__c){
            packetId = packetId + String.valueof(place.First_Brought_into_Effect_Date__c);
        }
        
        if(null != place.Care_Setting_Effective_Date__c){
            packetId = packetId + String.valueof(place.Care_Setting_Effective_Date__c);
        }
        
        if(null != place.GPMS_Expected_Offline_End_Date__c){
            packetId = packetId + String.valueof(place.GPMS_Expected_Offline_End_Date__c);
        }
        
        return packetId;
        
    }
    
    private List<Places_Allotment__c> getParentPlaces(PacketDTO packet){
        
        Map<String, Decimal> parentPlaceChanged = new Map<String,Decimal>();
        List<Places_Allotment__c> placesToUpsertList = new List<Places_Allotment__c>();
        
        Set<String> parentAllotmentId = new Set<String>();
        Set<String> parentPlaceId = new Set<String>();
        
        for(Places_Allotment__c place : packet.allNewPlaces.values()){
            
            if(null == parentPlaceChanged.get(place.Parent_Packet__c)){
                parentPlaceChanged.put(place.Parent_Packet__c, place.Number_of_Places__c);
            }else{
                parentPlaceChanged.put(place.Parent_Packet__c, parentPlaceChanged.get(place.Parent_Packet__c) + place.Number_of_Places__c);
            }
            
            parentPlaceId.add(place.Parent_Packet__c);
            
        }
        
        List<Places_Allotment__c> parentAllotmentPlacesList = [SELECT Id,Allotment__c FROM Places_Allotment__c WHERE Id in :parentPlaceId AND Current__c = 'Yes'];
        
        for(Places_Allotment__c place : parentAllotmentPlacesList){
            parentAllotmentId.add(place.Allotment__c);
        }
        
        List<Places_Allotment__c> parentPlacesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,Current__c,
                                                      Care_Type__c,Care_Level__c,Care_Setting__c,GPMS_Number_of_Remaining__c, Status_Effective_Date__c,
                                                      Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c, GPMS_Number_of_Variation__c 
                                                      FROM Places_Allotment__c WHERE Allotment__c in :parentAllotmentId AND Current__c = 'Yes'];
        
         
        if(!parentPlacesList.isEmpty()){
            
            String parentStatus = 'No';
            String parentCloneStatus = 'Yes';
            
            if('Yes'.equalsIgnoreCase(packet.needApproval)){
                parentStatus = 'Yes';
                parentCloneStatus = 'Pending';
            }
            
            for(Places_Allotment__c parentPlace : parentPlacesList){
                if(null != parentPlaceChanged.get(parentPlace.Id) || parentPlace.GPMS_Number_of_Remaining__c < parentPlace.Number_of_Places__c){
                    
                    if((parentPlaceId.contains(parentPlace.Id) && parentPlace.Current__c != parentStatus) || parentPlace.GPMS_Number_of_Variation__c != 0){
                        parentPlace.GPMS_Number_of_Variation__c = 0;
                        parentPlace.Current__c = parentStatus;
                        placesToUpsertList.add(parentPlace);
                    }
                    
                    Decimal numberOfPlacesChanged = 0;
                    if(null != parentPlaceChanged.get(parentPlace.Id)){
                        numberOfPlacesChanged = parentPlaceChanged.get(parentPlace.Id);
                    }
                    
                    if(parentPlace.GPMS_Number_of_Remaining__c > numberOfPlacesChanged && parentPlaceChanged.get(parentPlace.Id) != null){
                        Places_Allotment__c parentClone = parentPlace.clone(false, true, false, false);
                        parentClone.Number_of_Places__c = parentClone.GPMS_Number_of_Remaining__c - numberOfPlacesChanged;
                        parentClone.Current__c = parentCloneStatus;
                        parentClone.Parent_packet__c = parentPlace.Id;
                        parentClone.Event__c = packet.eventId;
                        parentClone.Integration_Id__c = null;
                        placesToUpsertList.add(parentClone);
                    }
                    
                    
                    
                }
            }
            
        }
        
        return placesToUpsertList;
        
    }
    
    private List<Places_Allotment__c> getNewPlaces(PacketDTO packet){
        
        Set<String> parentPlaceId = new Set<String>();
        Map<String, Decimal> parentPlaceChanged = new Map<String,Decimal>();
        List<Places_Allotment__c> placesToUpsertList = new List<Places_Allotment__c>();
        
        List<Places_Allotment__c> pendingPlacesList = [SELECT Id,Number_of_Places__c,Allotment__c,Parent_Packet__c,
                                                       Care_Type__c,Care_Level__c,Care_Setting__c,Status_Effective_Date__c,
                                                       Status_Reason__c,Status_of_Places__c,First_Brought_into_Effect_Date__c 
                                                       FROM Places_Allotment__c WHERE Event__c = :packet.eventId AND Current__c = 'Pending' AND Allotment__c=:packet.allotmentId];
        
        Map<String,Places_Allotment__c> pendingPlacesMap = new Map<String,Places_Allotment__c>();
        
        if(!pendingPlacesList.isEmpty()){
            for(Places_Allotment__c pendingPlace : pendingPlacesList){
                String placeUniqueId = generatePacketUniqueId(pendingPlace);
                pendingPlacesMap.put(placeUniqueId, pendingPlace);                
            }
        }
        
        for(Places_Allotment__c newPlace : packet.allNewPlaces.values()){
            
            String placeUniqueId = generatePacketUniqueId(newPlace);
            
            if(null != pendingPlacesMap.get(placeUniqueId)){
                Places_Allotment__c pendingPlace = pendingPlacesMap.get(placeUniqueId);
                pendingPlace.Number_of_Places__c = pendingPlace.Number_of_Places__c + newPlace.Number_of_Places__c;
                placesToUpsertList.add(pendingPlacesMap.get(placeUniqueId));
            }else{
                placesToUpsertList.add(newPlace);
            }
            
        }
        return placesToUpsertList;
        
    }
    
    public class PacketDTO{
        
        public Map < String, Places_Allotment__c> allNewPlaces;
        public String needApproval;
        public String eventId;
        public String allotmentId;
        
        public PacketDTO(String needApproval, String eventId, String allotmentId){
            this.allNewPlaces = allNewPlaces;
            this.needApproval = needApproval;
            this.eventId = eventId;
            this.allotmentId = allotmentId;
        }
        
    }
    
    
}