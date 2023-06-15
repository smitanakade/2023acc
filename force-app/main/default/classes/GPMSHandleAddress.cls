public with sharing class GPMSHandleAddress {
    public static void handleInsert(List<Address__c> addressList){
        for(Address__c iterAddress:addressList){
            UniqueAddressesController.AddressDetails addressDetails = new UniqueAddressesController.AddressDetails();
            addressDetails.poBoxType = iterAddress.PO_BOX_Type__c;
            addressDetails.postOfficeBox = iterAddress.Post_Office_Box__c;
            addressDetails.unitNumber = iterAddress.Unit_Number__c;
            addressDetails.LevelNumber = iterAddress.Level_Number__c;
            addressDetails.buildingName = iterAddress.Building_Name__c;
            addressDetails.lotNumber = iterAddress.Lot_Number__c;
            addressDetails.streetNumber1 = iterAddress.Street_Number_1__c;
            addressDetails.street1 = iterAddress.Street__c;
            addressDetails.streetTypeDescription = iterAddress.Street_Type_Description__c;
            addressDetails.streetSuffixTypeDescription = iterAddress.Street_Suffix_Type_Description__c;
            addressDetails.city = iterAddress.City__c;
            addressDetails.stateProvince = iterAddress.State_Province__c;
            addressDetails.zipPostalCode = iterAddress.Zip_Postal_Code__c;
            addressDetails.country = iterAddress.Country__c;
            if(iterAddress.Latitude_Longitude__Latitude__s!=null){
                addressDetails.latitude = String.valueOf(Math.floor(iterAddress.Latitude_Longitude__Latitude__s*100000)/100000);
            }else{
                addressDetails.latitude = '';
            }
            if(iterAddress.Latitude_Longitude__Longitude__s!=null){
                addressDetails.longitude = String.valueOf(Math.floor(iterAddress.Latitude_Longitude__Longitude__s*100000)/100000);
            }else{
                addressDetails.longitude = '';
            }
            
            
            iterAddress.AddressUniqueKey__c = UniqueAddressesController.concatAddress(addressDetails).remove('null');
        }
    }
	public static void handleUpdate(Map<Id,Address__c> newMap,Map<Id,Address__c> oldMap){
        for(Id addressId:newMap.keySet()){
            Address__c tempAddress =  newMap.get(addressId);
            system.debug(tempAddress.PO_BOX_Type__c);
            UniqueAddressesController.AddressDetails addressDetails = new UniqueAddressesController.AddressDetails();
            addressDetails.poBoxType = tempAddress.PO_BOX_Type__c;
            addressDetails.postOfficeBox = tempAddress.Post_Office_Box__c;
            addressDetails.unitNumber = tempAddress.Unit_Number__c;
            addressDetails.LevelNumber = tempAddress.Level_Number__c;
            addressDetails.buildingName = tempAddress.Building_Name__c;
            addressDetails.lotNumber = tempAddress.Lot_Number__c;
            addressDetails.streetNumber1 = tempAddress.Street_Number_1__c;
            addressDetails.street1 = tempAddress.Street__c;
            addressDetails.streetTypeDescription = tempAddress.Street_Type_Description__c;
            addressDetails.streetSuffixTypeDescription = tempAddress.Street_Suffix_Type_Description__c;
            addressDetails.city = tempAddress.City__c;
            addressDetails.stateProvince = tempAddress.State_Province__c;
            addressDetails.zipPostalCode = tempAddress.Zip_Postal_Code__c;
            addressDetails.country = tempAddress.Country__c;
            if(tempAddress.Latitude_Longitude__Latitude__s!=null){
                addressDetails.latitude = String.valueOf(Math.floor(tempAddress.Latitude_Longitude__Latitude__s*100000)/100000);
            }else{
                addressDetails.latitude = '';
            }
            if(tempAddress.Latitude_Longitude__Longitude__s!=null){
                addressDetails.longitude = String.valueOf(Math.floor(tempAddress.Latitude_Longitude__Longitude__s*100000)/100000);
            }else{
                addressDetails.longitude ='';
            }
            
            
            newMap.get(addressId).AddressUniqueKey__c = UniqueAddressesController.concatAddress(addressDetails).remove('null');
            
        }
    }
}