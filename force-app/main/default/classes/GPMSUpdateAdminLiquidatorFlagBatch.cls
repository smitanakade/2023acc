/****************************************************************************************************
* @CreatedBy   : Lavanya Uddarraju
* @CreatedDate : 20-Sep-2022
* @Description : Handles the logic to update Administrator/Liquidator Flag to 'False' 
                 on ACO's, Providers and Third Party Orgs 
                 when Administrator/Liquidator records end date lapsed
* @Test Class  : GPMSUpdateAdminLiquidatorFlagBatchTest
*****************************************************************************************************/
public class GPMSUpdateAdminLiquidatorFlagBatch implements Database.Batchable<SObject>,Schedulable {
    private String queryString;
    private Set<Id> recIdSet;
    private Date today;
    private final Boolean ADMIN_LIQUID_FLAG_TRUE = true;
    private final Boolean ADMIN_LIQUID_FLAG_FALSE = false;
    private Static final Id adminLiquidatorRecordTypeId = Schema.SObjectType.Contact_Relationship__c.getRecordTypeInfosByDeveloperName().get('Administrator_Liquidator_CR').getRecordTypeId();
    private Static final Id acoToAccountRecordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByDeveloperName().get('ACO_to_Account').getRecordTypeId();
    
    //////* --------- CONSTRUCTORS ------------ *//////
    public GPMSUpdateAdminLiquidatorFlagBatch() {
        this.today = System.today();
        this.queryString = 'SELECT Id, End_Date__c, Administrator_Liquidator_Record_Exists__c, Account__c FROM Contact_Relationship__c ' +
                           'WHERE End_Date__c < today ' +
                           'AND Administrator_Liquidator_Record_Exists__c = :ADMIN_LIQUID_FLAG_TRUE ' +
                           'AND Account__c != null ' +
                           'AND RecordTypeId = :adminLiquidatorRecordTypeId';
    }
    
    public GPMSUpdateAdminLiquidatorFlagBatch(Set<Id> recIdSet) {
        this.today = System.today();
        this.recIdSet = recIdSet;
        this.queryString = 'SELECT Id, End_Date__c, Administrator_Liquidator_Record_Exists__c, Account__c FROM Contact_Relationship__c ' +
                           'WHERE End_Date__c < today ' +
                           'AND Administrator_Liquidator_Record_Exists__c = :ADMIN_LIQUID_FLAG_TRUE ' +
                           'AND Account__c != null ' +
                           'AND RecordTypeId = :adminLiquidatorRecordTypeId ' +
                           'AND Id IN :recIdSet';
    }
    
    ////////* -------- SCHEDULE -------- *//////////
    public void execute(SchedulableContext sc) {
       Database.executeBatch(new GPMSUpdateAdminLiquidatorFlagBatch(),50);
    }
    
    /////////* ---------- MANUAL EXECUTION ------------- *//////
    public static void executeByIds(Set<Id> recIdSet, Integer i) {
        Database.executeBatch(new GPMSUpdateAdminLiquidatorFlagBatch(recIdSet), i);
    }
    
    //////////* ------------- START -------------- *////////
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('-------GPMSUpdateAdminLiquidatorFlagBatch Started---------');
        return Database.getQueryLocator(this.queryString);
    }
    
    /////////* ------------ Execute ------------- */////////
    public void execute(Database.BatchableContext bc, List<Contact_Relationship__c> scope) {
        Set<String> accountIdSet = new Set<String>();
        try {
            for (Contact_Relationship__c cr : scope) {
                accountIdSet.add(cr.Account__c);
            }
            setAdminLiquidatorFlagOnAccounts(accountIdSet);
        } catch (Exception exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp,'GPMS').Log(); 
        }
    }
     
    /////////* ------------ FINISH ------------- */////////
    public void finish(Database.BatchableContext bc) {
       System.debug('-------GPMSUpdateAdminLiquidatorFlagBatch Completed---------'); 
    }
    
    ////////* ---- Set Administrator/Liquidator Flag to 'False' on Accounts ----- *////////
    public void setAdminLiquidatorFlagOnAccounts(Set<String> accountIdSet) {
        Map<Id,Account_Relationship__c> acoAccountMap = new Map<Id,Account_Relationship__c>();
        Map<Id,Account_Relationship__c> apOrTPOAccountMap = new Map<Id,Account_Relationship__c>();
        
        List<Account_Relationship__c> acoRolesList = [SELECT Id,Account_From_Id__c,Account_To_Id__c 
                                                        FROM Account_Relationship__c WHERE Account_To_Id__c IN :accountIdSet
                                                        AND RecordTypeId = :acoToAccountRecordTypeId
                                                        AND Account_From_Id__r.Administrator_Liquidator_Record_Exists__c = :ADMIN_LIQUID_FLAG_TRUE];
        
        if( !acoRolesList.isEmpty() ) {
            for (Account_Relationship__c acoRole : acoRolesList) {
                acoAccountMap.put(acoRole.Account_From_Id__c,acoRole);
            }
            
            List<Account> accountList = [SELECT Id,Administrator_Liquidator_Record_Exists__c, 
                                        (SELECT Id,Account_From_Id__c,Account_To_Id__c 
                                        FROM Account_Relationship_From__r 
                                        WHERE Account_To_Id__r.Administrator_Liquidator_Record_Exists__c = :ADMIN_LIQUID_FLAG_TRUE) 
                                        FROM Account WHERE Id IN :acoAccountMap.keySet()];
            
            for (Account aco : accountList) {
                if (aco.Account_Relationship_From__r.size() > 0) {
                    for (Account_Relationship__c acoRole : aco.Account_Relationship_From__r) {
                        apOrTPOAccountMap.put(acoRole.Account_To_Id__c,acoRole);
                    }
                }
            }
        }
        
        List<Account> accountsToBeUpdatedList = [SELECT Id, Administrator_Liquidator_Record_Exists__c
                                                FROM Account
                                                WHERE Id IN :accountIdSet 
                                                OR Id IN : acoAccountMap.keySet()
                                                OR Id IN : apOrTPOAccountMap.keySet()];
        
        for (Account account: accountsToBeUpdatedList) {
            account.Administrator_Liquidator_Record_Exists__c = ADMIN_LIQUID_FLAG_FALSE;
        }

        updateAccounts(accountsToBeUpdatedList);

    }

    private void updateAccounts(List<Account> accounts) {

        Database.SaveResult[] updateResults = Database.update(accounts,false);

        Integer failCount = 0;
        String errorString = 'GPMSUpdateAdminLiquidatorFlagBatch Failures: ';
        for (Database.SaveResult sr : updateResults) {
            if (!sr.isSuccess()) {
                failCount++;
                errorString += ('\nAccount update failed: ' + sr.getId());
                for(Database.Error err : sr.getErrors()) {
                    errorString += ('\n'+err.getMessage());
                }
            }
        }
        if (failCount>0) {
            dohagedcare.Logger.error(errorString,null,'GPMS').Log();
        }
    }
}