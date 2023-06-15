/**
 * @author      Rami Zuhairi
 * @date        23-02-2023
 * @description Selector class to get data from RegulatoryCodeViolation
 */
public with sharing class RegulatoryCodeViolationSelector {
    public static RegulatoryCodeViolationSelector singletonInstance {
        get {
            if (singletonInstance == null) {
                singletonInstance = new RegulatoryCodeViolationSelector();
            }
            return singletonInstance;
        }
        private set;
    }

    public List<RegulatoryCodeViolation> getRDListBySFServiceIds(
        Id sfServiceAccountRelationshipId
    ) {
        return [
            SELECT
                Id,
                Service_Name_lookup__c,
                Service_Name_lookup__r.name,
                Status,
                ViolationType.name,
                Date_Decision_Ends__c,
                Date_Decision_Applied__c
            FROM RegulatoryCodeViolation
            WHERE
                Service_Name_lookup__c = :sfServiceAccountRelationshipId
                AND (Status = 'Current'
                OR (Status = 'Non-Current'
                AND Date_Decision_Ends__c >= LAST_N_DAYS:1095))
            ORDER BY Status, Date_Decision_Applied__c DESC
        ];
    }
}