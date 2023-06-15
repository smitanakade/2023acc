/****************************************************************************************************
* @createdBy    Yohan Perera
* @createdDate  1-11-2022
* @description  Service class for BusinessLicenseTrigger
* @testClass    BusinessLicenseHandlerTest
*****************************************************************************************************/
public with sharing class BusinessLicenseTriggerService {
    private static Boolean existingServiceIdToGroupsCacheLoaded = false;
    private static final String SERVICE_PUBLIC_GROUP_NAME_PREFIX = 'SRV_';
    private static Map<Id, Group> serviceIdToExistingGroupMap = new Map<Id, Group>();

    public static void fireBusinessLicenseDeletePE(Map<Id, BusinessLicense> oldServiceMap) {
        List<BusinessLicenseDeletePE__e> eventsList = new List<BusinessLicenseDeletePE__e>();

        for (Id serviceId : oldServiceMap.keySet()) {
            BusinessLicenseDeletePE__e event = new BusinessLicenseDeletePE__e();
            event.BusinessLicenseId__c = serviceId;
            eventsList.add(event);
        }

        EventBus.publish(eventsList);
    }

    /**
    * This method fires platform events to create public groups for BusinessLicense records
    * when their status is 'Operational' and a Public Group does not already exist for the record.
    * @param newServiceMap
    */
    public static void fireBusinessLicenseIdPE(Map<Id, BusinessLicense> newServiceMap) {
        List<BusinessLicensePE__e> eventsList = new List<BusinessLicensePE__e>();
        try {
            for (Id serviceId : newServiceMap.keySet()) {
                BusinessLicense service = newServiceMap.get(serviceId);
                if (!serviceIdToExistingGroupMap.containsKey(serviceId) &&
                    service.Status__c == 'Operational' &&
                    (service.Care_Type__c == 'Residential' || service.Care_Type__c == 'Home Care')) {
                    BusinessLicensePE__e event = new BusinessLicensePE__e();
                    event.BusinessLicenseId__c = serviceId;
                    eventsList.add(event);
                }
            }

            EventBus.publish(eventsList);
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }

    public static void createPublicGroupAndShare(List<BusinessLicensePE__e> newServiceList) {
        List<String> serviceIds = new List<String>();

        try {
            for (BusinessLicensePE__e event : newServiceList) {
                serviceIds.add(event.BusinessLicenseId__c);
            }
            Map<Id, BusinessLicense> newServiceMap = new Map<Id, BusinessLicense>([SELECT Id, AccountId FROM BusinessLicense WHERE Id IN :serviceIds]);
            createPublicGroupAndShare(newServiceMap);
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }

    public static void createPublicGroupAndShare(Map<Id, BusinessLicense> newServiceMap) {
        Map<Id, Group> publicGroupsToCreateMap = new Map<Id, Group>();
        Set<Id> providerAccountIds = new Set<Id>();

        try {
            for (Id serviceId : newServiceMap.keySet()) {
                BusinessLicense newRecord = newServiceMap.get(serviceId);
                Group grp = new Group(Name = SERVICE_PUBLIC_GROUP_NAME_PREFIX + newRecord.Id, DoesIncludeBosses = false);
                publicGroupsToCreateMap.put(serviceId, grp);
                providerAccountIds.add(newRecord.AccountId);
            }

            if (!publicGroupsToCreateMap.isEmpty()) {
                insert publicGroupsToCreateMap.values();
                // For providers with existing contacts, add existing community users to new service public groups
                // This applies to the situation when providers are linked to the services 'BEFORE' public groups creation.
                addUsersToGroupByProviderAccountIds(providerAccountIds);
            }

            List<BusinessLicenseShare> sharesList = new List<BusinessLicenseShare>();

            for (Id serviceId : publicGroupsToCreateMap.keySet()) {
                Group newGroup = publicGroupsToCreateMap.get(serviceId);
                sharesList.add(getNewBusinessLicenseShare(serviceId, newGroup.Id));
            }

            if (!sharesList.isEmpty()) {
                insert sharesList;
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }

    /**
     * Manual sharing is lost when the ownership changes and sharing must be re-instated.
     * @param newServiceMap
     * @param oldServiceMap
     */
    public static void serviceRecordShare(Map<Id, BusinessLicense> newServiceMap, Map<Id, BusinessLicense> oldServiceMap) {
        List<BusinessLicenseShare> sharesList = new List<BusinessLicenseShare>();

        try {
            for (Id serviceId : newServiceMap.keySet()) {
                if (newServiceMap.get(serviceId).OwnerId != oldServiceMap.get(serviceId).OwnerId &&
                    serviceIdToExistingGroupMap.containsKey(serviceId)
                ) {
                    sharesList.add(getNewBusinessLicenseShare(serviceId, serviceIdToExistingGroupMap.get(serviceId).Id));
                }
            }

            if (!sharesList.isEmpty()) {
                insert sharesList;
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }

    public static void deletePublicGroups(List<BusinessLicenseDeletePE__e> businessLicenseDeletePES) {
        List<String> groupNamesToDelete = new List<String>();

        try {
            for (BusinessLicenseDeletePE__e event : businessLicenseDeletePES) {
                groupNamesToDelete.add(SERVICE_PUBLIC_GROUP_NAME_PREFIX + event.BusinessLicenseId__c);
            }

            List<Group> groups = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :groupNamesToDelete];

            if (groups != null && !groups.isEmpty()) {
                delete groups;
            }
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'Star Rating').log();
        }
    }

    /**
     * This method adds users to a group when the Account associated with a service changes.
     * Currently a record triggered flow - 'SACR : Update Service' on SAR object, updates service's account field when the SAR is active.
     * This applies to the situation when providers are linked to the services 'AFTER' public groups creation.
     * If the conditions are met, it calls the 'addUsersToGroupByProviderAccountIds' method with the new AccountIds.
     * @param newServiceMap
     * @param oldServiceMap
     */
    public static void addUsersToGroupWhenAccountChanged(Map<Id, BusinessLicense> newServiceMap, Map<Id, BusinessLicense> oldServiceMap) {
        Set<Id> newProviderAccountIds = new Set<Id>();
        for (Id serviceId : newServiceMap.keySet()) {
            BusinessLicense newService = newServiceMap.get(serviceId);
            BusinessLicense oldService = oldServiceMap.get(serviceId);
            if (newService.AccountId != null && newService.AccountId != oldService.AccountId) {
                newProviderAccountIds.add(newService.AccountId);
            }
        }
        if (!newProviderAccountIds.isEmpty()) {
            addUsersToGroupByProviderAccountIds(newProviderAccountIds);
        }
    }

    /**
     * Caches the existing public groups for services in the system so other methods can use it without extra SOQL queries.
     * @param newServiceMap A map of new business licenses that need to be checked for public groups.
     */
    public static void cacheExistingGroups(Map<Id, BusinessLicense> newServiceMap) {
        if (existingServiceIdToGroupsCacheLoaded) {
            return;
        }
        Set<String> groupNames = new Set<String>();
        for (Id serviceId : newServiceMap.keySet()) {
            groupNames.add(SERVICE_PUBLIC_GROUP_NAME_PREFIX + serviceId);
        }
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :groupNames]) {
            serviceIdToExistingGroupMap.put(g.DeveloperName.replace(SERVICE_PUBLIC_GROUP_NAME_PREFIX, ''), g);
        }
        existingServiceIdToGroupsCacheLoaded = true;
    }

    /**
     * This queries AccountContactRelation records related to those providerIds and fires a platform event to add those
     * account contact relations to public groups. This method is used to add users to public groups based on their
     * relationships with service providers.
     * @param providerAccountIds Set of providerAccountIds to get AccountContactRelation for.
     */
    private static void addUsersToGroupByProviderAccountIds(Set<Id> providerAccountIds) {
        Map<Id, AccountContactRelation> acrs = new Map<Id, AccountContactRelation>([
            SELECT Id
            FROM AccountContactRelation
            WHERE AccountId IN :providerAccountIds
        ]);
        if (!acrs.isEmpty()) {
            AccountContactRelationshipTriggerService.fireAddUsersToPublicGroupsPE(acrs);
        }
    }

    private static BusinessLicenseShare getNewBusinessLicenseShare(Id serviceId, Id groupId) {
        BusinessLicenseShare blShare = new BusinessLicenseShare();
        blShare.ParentId = serviceId;
        blShare.UserOrGroupId = groupId;
        blShare.RowCause = Schema.BusinessLicenseShare.RowCause.Manual;
        blShare.AccessLevel = 'Read';
        return blShare;
    }
}