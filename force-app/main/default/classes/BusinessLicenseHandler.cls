/*******************************************************************************************
 * @Name             BusinessLicenseHandler
 * @Test class
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date             26-09-2022
 * @Story#           225785 (SR-QI ART Planning Sprint 4)
 * @LWC Component    None
 * @Description      handles service records and decides if system exemptions needs to be created
 * @testClass        BusinessLicenseHandlerTest
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     		Gabriel Piragibe Cova Leda de Almeida    26-09-2022          Initial Creation
 *******************************************************************************************/
public with sharing class BusinessLicenseHandler implements afterInsert, afterUpdate, beforeDelete {

    public void afterInsert(Map<Id, SObject> newServiceMap) {
        BusinessLicenseTriggerService.cacheExistingGroups((Map<Id, BusinessLicense>) newServiceMap);
        BusinessLicenseTriggerService.fireBusinessLicenseIdPE((Map<Id, BusinessLicense>) newServiceMap);
    }

    public void beforeDelete(Map<Id, SObject> oldServiceMap) {
        BusinessLicenseTriggerService.fireBusinessLicenseDeletePE((Map<Id, BusinessLicense>) oldServiceMap);
    }

    public void afterUpdate(Map<Id, SObject> newServiceMap, Map<Id, SObject> oldServiceMap) {
        BusinessLicenseTriggerService.cacheExistingGroups((Map<Id, BusinessLicense>) newServiceMap);
        BusinessLicenseTriggerService.addUsersToGroupWhenAccountChanged((Map<Id, BusinessLicense>) newServiceMap, (Map<Id, BusinessLicense>) oldServiceMap);
        BusinessLicenseTriggerService.fireBusinessLicenseIdPE((Map<Id, BusinessLicense>) newServiceMap);
        BusinessLicenseTriggerService.serviceRecordShare((Map<Id, BusinessLicense>) newServiceMap, (Map<Id, BusinessLicense>) oldServiceMap);
    }
}