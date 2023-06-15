/**
 * @author Rami Zuhairi
 * @date 28-03-2023
 * @description Apex class that will query Service_Account_Relationship__c of current portal user
 */
public with sharing class SRProviderPortalUtil {
    public static User getCurrentUserContactId() {
        return [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }

    public static List<Service_Account_Relationship__c> getServiceAccountRelationships() {
        return [
            SELECT
                Id,
                Service_Name__r.Name,
                Service_Name__c,
                Provider_Name__r.Name,
                Provider_Name__c,
                Provider_Name__r.ParentId
            FROM Service_Account_Relationship__c
            WHERE
                Provider_Name__c IN (
                    SELECT AccountId
                    FROM AccountContactRelation
                    WHERE ContactId = :getCurrentUserContactId().ContactId
                )
                AND Service_Name__r.Status__c = 'Operational'
                AND Service_Name__r.Care_Type__c IN ('Residential')
        ];
    }

    public static String getSARIdsString() {
        String[] ids = new List<String>{};
        String idString;
        for (
            Service_Account_Relationship__c sar : getServiceAccountRelationships()
        ) {
            ids.add(sar.Id);
        }
        idString = '\'' + String.join(ids, '\',\'') + '\'';
        return '( ' + idString + ' )';
    }
}