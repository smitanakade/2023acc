/**
* Author : Sharevreet Singh
* Date : 01/03/2023
* Description : Controller class for qiServiceProviderList
* @testClass QIServiceProviderControllerTest
**/
public with sharing class QIServiceProviderController {
    private final static String MASTER_RT = 'Master';
    private final static String STATUS_IP = 'In Progress';
    private final static String APPROVED_PROVIDER_RT = 'Approved_Provider';
   
    /***
     * @description Used to retrieve Services/BusinessLicense based on parameters to populate data in datatable
     * @params searchPeriodEnding - reporting period end dates
     * @params searchStatus - quality indicator summary status
     * @params searchServNameOrId - service name or oracle service id 
     */
    @AuraEnabled (Cacheable=true)
    public static List<BusinessLicense> getRecordsDataTableListFilterSearch(List<Date> searchPeriodEnding, List<String> searchStatus, String searchServNameOrId, String userId) {
        try {
            if(searchStatus.size() > 0 && searchStatus.contains('Submitted - Updated After Due Date')){
                Integer indexOfSub=  searchStatus.indexOf('Submitted - Updated After Due Date');
                searchStatus.remove(indexOfSub);
                searchStatus.add('Updated After Due Date');
            }
            String soqlQuery;
            List<SObject> serviceList = new List<SObject>();
            SET<Id> providerIds=new SET<Id>();
            SET<Id> serviceProviderIds=new SET<Id>();
            map<String, Boolean> mapRoleService= new map<String, Boolean>();
            //get the contactID
            User portalUser=[SELECT id, ContactId, AccountId FROM User where Id=: userId];
            for(Org_Switcher_Mapping__mdt roleMap: [SELECT Role__c, isServiceRole__c FROM Org_Switcher_Mapping__mdt WHERE Role__c != '']){
                mapRoleService.put(roleMap.Role__c, roleMap.isServiceRole__c);
            }
                                                               
            List<AccountContactRelation> accountContactRelations=[Select id, AccountId,  Roles FROM AccountContactRelation 
                                                                    WHERE ContactId=:portalUser.ContactId 
                                                                    AND IsActive=true
                                                                    AND Account.RecordType.DeveloperName =: APPROVED_PROVIDER_RT ]; //there will always be roles
            for(AccountContactRelation relation: accountContactRelations){
                for(String str:relation.Roles.split(';')){
                    if(mapRoleService.get(str)==true){
                        serviceProviderIds.add(relation.AccountId);
                        break;
                    }
                    else{
                        providerIds.add(relation.AccountId);
                    }
                }
            }
            if(!serviceProviderIds.isEmpty()){
                SET<Id> serviceIds=new SET<Id>();
                List<Contact_Relationship__c> associateContacts= [SELECT Id, Service__c 
                                                                    FROM Contact_Relationship__c 
                                                                    WHERE Contact__c=: portalUser.ContactId 
                                                                    AND Portal_Service_Roles__c!=null];
                for(Contact_Relationship__c conRelation:associateContacts){
                    serviceIds.add(conRelation.Service__c);
                }
                soqlQuery = 'SELECT id,  Name, AccountId, Oracle_Service_ID__c, PeriodEnd, Decision_Due_Date__c, Status__c, ';
                soqlQuery += 'Physical_Address_Location__r.Address__r.City__c, ';
                soqlQuery += 'Physical_Address_Location__r.Address__r.Full_Street__c, ';
                soqlQuery += 'Physical_Address_Location__r.Address__r.State_Province__c, ';
                soqlQuery += 'Physical_Address_Location__r.Address__r.Country__c, ';
                soqlQuery += 'Physical_Address_Location__r.Address__r.Zip_Postal_Code__c, ';
                soqlQuery += '(SELECT Status__c, REPORTING_PERIOD__r.End_Date__c,  REPORTING_PERIOD__r.Start_Date__c, REPORTING_PERIOD__r.QI_Submission_Due_Dt__c, ';
                soqlQuery += 'REPORTING_PERIOD__r.Current_Reporting_Period__c, REPORTING_PERIOD__r.Previous_Reporting_Period__c, Submission_Date_Time__c ';
                soqlQuery += 'FROM Quality_Indicator_Summary__r ';
                soqlQuery += 'WHERE REPORTING_PERIOD__c != NULL ';
              /*  if (searchStatus.size() > 0) {
                    soqlQuery += 'AND Status__c IN :searchStatus ';
                }*/
            
                soqlQuery += '), ';
                soqlQuery += '(SELECT Id FROM Service_Account_Relationships__r ';
                soqlQuery += 'WHERE (Association_End_Date__c = NULL OR Association_End_Date__c >= Today) ';
                soqlQuery += 'AND Provider_Name__c IN: serviceProviderIds ';
                soqlQuery += ') ';
                soqlQuery += 'FROM BusinessLicense ';
                soqlQuery += 'WHERE Care_Type__c = \'Residential\' ';
                soqlQuery += 'AND Status__c IN (\'Operational\', \'Offline\') ';
                soqlQuery += 'AND Id IN: serviceIds ';
                if (searchServNameOrId != '') {
                    soqlQuery += 'AND (Name LIKE \'%' + String.escapeSingleQuotes(searchServNameOrId) + '%\' ';
                    soqlQuery += 'OR Oracle_Service_ID__c LIKE \'%' + String.escapeSingleQuotes(searchServNameOrId) + '%\' )';
                }
                soqlQuery += 'ORDER BY Status__c';
                for (SObject service : Database.query(soqlQuery)) {
                        serviceList.add(service);
                }

            }
            else if(!providerIds.isEmpty()){
                    soqlQuery = 'SELECT id,  Name, AccountId, Oracle_Service_ID__c, PeriodEnd, Decision_Due_Date__c, Status__c, ';
                    soqlQuery += 'Physical_Address_Location__r.Address__r.City__c, ';
                    soqlQuery += 'Physical_Address_Location__r.Address__r.Full_Street__c, ';
                    soqlQuery += 'Physical_Address_Location__r.Address__r.State_Province__c, ';
                    soqlQuery += 'Physical_Address_Location__r.Address__r.Country__c, ';
                    soqlQuery += 'Physical_Address_Location__r.Address__r.Zip_Postal_Code__c, ';
                    soqlQuery += '(SELECT Status__c, REPORTING_PERIOD__r.End_Date__c,  REPORTING_PERIOD__r.Start_Date__c, REPORTING_PERIOD__r.QI_Submission_Due_Dt__c, ';
                    soqlQuery += 'REPORTING_PERIOD__r.Current_Reporting_Period__c, REPORTING_PERIOD__r.Previous_Reporting_Period__c, Submission_Date_Time__c ';
                    soqlQuery += 'FROM Quality_Indicator_Summary__r ';
                    soqlQuery += 'WHERE REPORTING_PERIOD__c != NULL ';
                   /* if (searchStatus.size() > 0) {
                        soqlQuery += 'AND Status__c IN :searchStatus ';
                    }*/
                
                    soqlQuery += '), ';
                    soqlQuery += '(SELECT Id FROM Service_Account_Relationships__r ';
                    soqlQuery += 'WHERE (Association_End_Date__c = NULL OR Association_End_Date__c >= Today) ';
                    soqlQuery += 'AND Provider_Name__c IN: providerIds ';
                    soqlQuery += ') ';
                    soqlQuery += 'FROM BusinessLicense ';
                    soqlQuery += 'WHERE Care_Type__c = \'Residential\' ';
                    soqlQuery += 'AND Status__c IN (\'Operational\', \'Offline\') ';
                    if (searchServNameOrId != '') {
                        soqlQuery += 'AND (Name LIKE \'%' + String.escapeSingleQuotes(searchServNameOrId) + '%\' ';
                        soqlQuery += 'OR Oracle_Service_ID__c LIKE \'%' + String.escapeSingleQuotes(searchServNameOrId) + '%\' )';
                    }
                    soqlQuery += 'ORDER BY Status__c';
                    for (SObject service : Database.query(soqlQuery)) {
                        if(service.getSObjects('Service_Account_Relationships__r') != NULL) {
                            serviceList.add(service);
                        }
                    }
            }
            return serviceList;
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'qiServiceProviderUtil').log();
            throw new AuraHandledException('Error in Filter Search! Please try again or contact system administrator.');
        }
    }

    /**
     * @description create Quality Indicator Summary, Quality Indicator Details and Target
     * @params busLicId, providerId, sarId
     */
    @AuraEnabled
    public static Id createQISRelatedRecords(String busLicId, String providerId, String sarId, String reportingPId) {
        Id reportinPeriodId = reportingPId;
        List<Quality_Indicator_Summary__c> qiSummries=[SELECT Id, Service__c, REPORTING_PERIOD__c
                                                        FROM Quality_Indicator_Summary__c
                                                        WHERE Service__c=:busLicId AND REPORTING_PERIOD__c=: reportinPeriodId];
        if(!qiSummries.isEmpty()){
            System.debug('***qiSummries'+qiSummries);
            return qiSummries[0].Id;
        }
        Quality_Indicator_Summary__c qis = new Quality_Indicator_Summary__c(
            PROVIDER_ID__c = providerId,
            SERVICE_ACCOUNT_ID__c = sarId,
            Service__c = busLicId,
            Status__c = STATUS_IP,
            REPORTING_PERIOD__c = reportinPeriodId
        );
        
        try {
            System.debug('***qis'+qis);
            insert qis;
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'qiServiceProviderUtil').log();
            throw new AuraHandledException('Error in Creating Records! Please try again or contact system administrator.');
        }
        List<Quality_Indicator_Details__c> qidList = new List<Quality_Indicator_Details__c>();
        List<Schema.RecordTypeInfo> recordTypes= Quality_Indicator_Details__c.SObjectType.getDescribe().getRecordTypeInfos();
        for(Schema.RecordTypeInfo rt : recordTypes) {
            if(rt.isActive() && rt.getDeveloperName() != MASTER_RT) {
                qidList.add(new Quality_Indicator_Details__c(
                    QI_Summary_Id__c = qis.Id,
                    Status__c = STATUS_IP,
                    RecordTypeId = rt.getRecordTypeId()));
            }
        }

        Quality_Indicator_Targets__c qit = new Quality_Indicator_Targets__c(
            Quality_Indicator_Summary__c = qis.Id,
            Service__c = busLicId,
            Reporting_Period__c = reportinPeriodId);

        try {
            if(!qidList.isEmpty()){
                insert qidList;   
            }
            insert qit;
        } catch (Exception ex) {
            dohagedcare.Logger.error(ex.getMessage(), ex, 'qiServiceProviderUtil').log();
            throw new AuraHandledException('Error in Creating Records! Please try again or contact system administrator.');
        }
        return qis.Id;
    }

    /**
    * @description : get the start date from the current RP
    * @author Vivek Jaiswal | 03-14-2023 
    * @return string 
    **/
    @AuraEnabled
    public static Reporting_Period__c getCurrentRPQuery{
        get {
            if (getCurrentRPQuery == null) {
                List<Reporting_Period__c> rpList = [SELECT Id, Start_Date__c, QI_Submission_Due_Dt__c,End_Date__c, Previous_Reporting_Period__c, Current_Reporting_Period__c
                FROM Reporting_Period__c WHERE Current_Reporting_Period__c = true AND Reporting_Period_Type__c = 'Quarter' LIMIT 1];
                if (rpList.size() > 0) {
                    getCurrentRPQuery = rpList.get(0);
                }
            }
            System.debug('***getCurrentRPQuery'+getCurrentRPQuery);
            return getCurrentRPQuery;
        }
        private set;
    }

    @AuraEnabled
    public static Reporting_Period__c getCurrentRP(){
        try {
             Reporting_Period__c currentRP = getCurrentRPQuery;
            return currentRP;
           
        } catch (Exception ex) {
            throw new AuraHandledException('Error in finfing current Reporting Period');
        }
    }

     /**
    * @description : get the Previous RP
    * @author Vivek Jaiswal | 05-20-2023 
    * @return Reporting_Period__c 
    **/
    @AuraEnabled
    public static Reporting_Period__c getPreviousRPQuery{
        get {
            if (getPreviousRPQuery == null) {
                List<Reporting_Period__c> rpList = [SELECT Id, Start_Date__c, QI_Submission_Due_Dt__c,End_Date__c, Previous_Reporting_Period__c, Current_Reporting_Period__c
                FROM Reporting_Period__c WHERE Previous_Reporting_Period__c = true AND Reporting_Period_Type__c = 'Quarter' LIMIT 1];
                if (rpList.size() > 0) {
                    getPreviousRPQuery = rpList.get(0);
                }
            }
            return getPreviousRPQuery;
        }
        private set;
    }

    @AuraEnabled
    public static Reporting_Period__c getPreviousRP(){
        try {
            
            Reporting_Period__c previousRP = getPreviousRPQuery;
            return previousRP;
           
        } catch (Exception ex) {
                
            dohagedcare.Logger.error(ex.getMessage(), ex, 'getPreviousRP').log();
            throw new AuraHandledException('Error in finfing previous Reporting Period');
        }
    }

    public static Id currentReportingPeriodId() {
        return [SELECT Id FROM Reporting_Period__c WHERE Current_Reporting_Period__c = true LIMIT 1].Id;
    }

    /**
    * @description : check if the Service is offile for the given period
    * @author Vivek.Jaiswal | 03-10-2023 
    * @param bHistpry: 
    * @param serviceHistory 
    * @return boolean
    **/
    @AuraEnabled
    public static Map<String, boolean> areServicesOffline(List<String> serviceIds){
        Map<String, boolean> mapServiceOffline= new  Map<String, boolean>();
        String OfflineStatus='Offline';
        set<Id> services= new set<Id>();
        Date startDate=getCurrentRP().Start_Date__c;
        Map<id, List<BusinessLicenseHistory>> mapServiceANDHistory=new Map<id, List<BusinessLicenseHistory>>();
        for(BusinessLicense ser:[SELECT id, Status__c,  (SELECT Id, REPORTING_PERIOD__r.Current_Reporting_Period__c, REPORTING_PERIOD__r.Previous_Reporting_Period__c 
                                                            FROM  Quality_Indicator_Summary__r WHERE 
                                                            REPORTING_PERIOD__r.Current_Reporting_Period__c=:true) 
                                                FROM BusinessLicense WHERE Id IN: serviceIds AND Status__c=:'Offline']){
            if(ser.Quality_Indicator_Summary__r.isEmpty()){
                services.add(ser.id);
            }
        }
        if(services.size()>0){
            List<BusinessLicenseHistory> serviceHistory=[SELECT Id, BusinessLicense.id, BusinessLicense.Status__c, createdDate,  Field, OldValue, NewValue 
                                                                FROM BusinessLicenseHistory where Field='Status__c' AND BusinessLicense.id IN :services 
                                                                AND createdDate>=:startDate AND createdDate<=:DateTime.NOW()];

            for(BusinessLicenseHistory bh:serviceHistory){
                if(mapServiceANDHistory.containskey(bh.BusinessLicense.id)){
                    List<BusinessLicenseHistory> listServhis=new  List<BusinessLicenseHistory>();
                    listServhis= mapServiceANDHistory.get(bh.BusinessLicense.id);
                    listServhis.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, listServhis);
                }
                else{
                    List<BusinessLicenseHistory> bhs=new List<BusinessLicenseHistory>();
                    bhs.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, bhs);
                }
            }
            for(Id serviceId: services){
                if(!mapServiceANDHistory.containsKey(serviceId)){
                    mapServiceOffline.put(serviceId, true);
                }
                else{
                    for(BusinessLicenseHistory his: mapServiceANDHistory.get(serviceId)){
                        if(his.OldValue!=OfflineStatus || his.NewValue!=OfflineStatus){
                            mapServiceOffline.put(serviceId, false);
                            break;
                        }
                        mapServiceOffline.put(serviceId, true);  
                    }
                }
            }    
        
        }
        return mapServiceOffline;
    }

    /**
    * @description : check if the Service is offile for the previous RP
    * @author Vivek.Jaiswal | 05-20-2023 
    * @param bHistpry: 
    * @param serviceHistory 
    * @return boolean
    **/
    @AuraEnabled
    public static Map<String, boolean> areServicesOfflinePRP(List<String> serviceIds){
        Map<String, boolean> mapServiceOffline= new  Map<String, boolean>();
        String OfflineStatus='Offline';
        set<Id> services= new set<Id>();
        Date startDate=getPreviousRP().Start_Date__c;
        Date endDate=getPreviousRP().End_Date__c;
        Map<Id, String> businessStatusMap=new Map<Id, String>();
        Map<id, List<BusinessLicenseHistory>> mapServiceANDHistory=new Map<id, List<BusinessLicenseHistory>>();
        for(BusinessLicense ser:[SELECT id, Status__c,  (SELECT Id, REPORTING_PERIOD__r.Current_Reporting_Period__c, REPORTING_PERIOD__r.Previous_Reporting_Period__c 
                                                            FROM  Quality_Indicator_Summary__r WHERE 
                                                            REPORTING_PERIOD__r.Previous_Reporting_Period__c=:true) 
                                                FROM BusinessLicense WHERE Id IN: serviceIds]){
            if(ser.Quality_Indicator_Summary__r.isEmpty()){
                businessStatusMap.put(ser.id, ser.Status__c);
                services.add(ser.id);
            }
        }
        if(services.size()>0){
            List<BusinessLicenseHistory> serviceHistory=[SELECT Id, BusinessLicense.id, BusinessLicense.Status__c, createdDate,  Field, OldValue, NewValue 
                                                                FROM BusinessLicenseHistory where Field='Status__c' AND BusinessLicense.id IN :services 
                                                                AND createdDate>=:startDate AND createdDate<=:endDate];

            for(BusinessLicenseHistory bh:serviceHistory){
                if(mapServiceANDHistory.containskey(bh.BusinessLicense.id)){
                    List<BusinessLicenseHistory> listServhis=new  List<BusinessLicenseHistory>();
                    listServhis= mapServiceANDHistory.get(bh.BusinessLicense.id);
                    listServhis.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, listServhis);
                }
                else{
                    List<BusinessLicenseHistory> bhs=new List<BusinessLicenseHistory>();
                    bhs.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, bhs);
                }
            }
            for(Id serviceId: services){
                if(!mapServiceANDHistory.containsKey(serviceId)){
                    if(businessStatusMap.get(serviceId)=='Offline'){
                         mapServiceOffline.put(serviceId, true);
                    }
                    else{
                        mapServiceOffline.put(serviceId, false);
                    }
                }
                else{
                    for(BusinessLicenseHistory his: mapServiceANDHistory.get(serviceId)){
                        if(his.OldValue!=OfflineStatus || his.NewValue!=OfflineStatus){
                            mapServiceOffline.put(serviceId, false);
                            break;
                        }
                        mapServiceOffline.put(serviceId, true);  
                    }
                }
            }    
        
        }
        return mapServiceOffline;
    }

     /**
    * @description : check if the Service is Operational for the current RP
    * @author Vivek.Jaiswal | 03-10-2023 
    * @param bHistpry: 
    * @param serviceHistory 
    * @return boolean
    **/
    @AuraEnabled
    public static Map<String, boolean> areServicesOperational(List<String> serviceIds){
        Map<String, boolean> mapServiceOffline= new  Map<String, boolean>();
        Map<String, boolean> mapServiceOperReturn= new  Map<String, boolean>();
        String OperatinalStatus='Operational';
        set<Id> services= new set<Id>();
        Date startDate=getCurrentRP().Start_Date__c;
        Map<id, List<BusinessLicenseHistory>> mapServiceANDHistory=new Map<id, List<BusinessLicenseHistory>>();
        for(BusinessLicense ser:[SELECT id, Status__c,  (SELECT Id, REPORTING_PERIOD__r.Current_Reporting_Period__c, REPORTING_PERIOD__r.Previous_Reporting_Period__c 
                                                            FROM  Quality_Indicator_Summary__r WHERE 
                                                             REPORTING_PERIOD__r.Current_Reporting_Period__c=:true) 
                                                FROM BusinessLicense WHERE Id IN: serviceIds]){
            if(ser.Quality_Indicator_Summary__r.isEmpty()){
                services.add(ser.id);
            }
        }
        if(services.size()>0){
            List<BusinessLicenseHistory> serviceHistory=[SELECT Id, BusinessLicense.id, BusinessLicense.Status__c, createdDate,  Field, OldValue, NewValue 
                                                                FROM BusinessLicenseHistory where Field='Status__c' AND BusinessLicense.id IN :services 
                                                                AND createdDate>=:startDate AND createdDate<=:DateTime.NOW()];

            for(BusinessLicenseHistory bh:serviceHistory){
                if(mapServiceANDHistory.containskey(bh.BusinessLicense.id)){
                    List<BusinessLicenseHistory> listServhis=new  List<BusinessLicenseHistory>();
                    listServhis= mapServiceANDHistory.get(bh.BusinessLicense.id);
                    listServhis.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, listServhis);
                }
                else{
                    List<BusinessLicenseHistory> bhs=new List<BusinessLicenseHistory>();
                    bhs.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, bhs);
                }
            }
            for(Id serviceId: services){
                if(mapServiceANDHistory.containskey(serviceId)){
                    for(BusinessLicenseHistory his: mapServiceANDHistory.get(serviceId)){
                        if(his.OldValue==OperatinalStatus || his.NewValue==OperatinalStatus){
                            mapServiceOffline.put(serviceId, true);
                            break;
                        }
                        mapServiceOffline.put(serviceId, false);  
                    }
                }
                else{
                    mapServiceOffline.put(serviceId, true);
                }
            }    
        }
        return mapServiceOffline;
    }

     /**
    * @description : check if the Service is Operation for the previous RP
    * @author Vivek.Jaiswal | 05-20-2023 
    * @param bHistpry: 
    * @param serviceHistory 
    * @return boolean
    **/
    @AuraEnabled
    public static Map<String, boolean> areServicesOperationalPRP(List<String> serviceIds){
        Map<String, boolean> mapServiceOffline= new  Map<String, boolean>();
        Map<String, boolean> mapServiceOperReturn= new  Map<String, boolean>();
        String OperatinalStatus='Operational';
        set<Id> services= new set<Id>();
        Date startDate=getPreviousRP().Start_Date__c;
        Date endDate=getPreviousRP().End_Date__c;
        Map<id, List<BusinessLicenseHistory>> mapServiceANDHistory=new Map<id, List<BusinessLicenseHistory>>();
        for(BusinessLicense ser:[SELECT id, Status__c,  (SELECT Id, REPORTING_PERIOD__r.Current_Reporting_Period__c, REPORTING_PERIOD__r.Previous_Reporting_Period__c 
                                                            FROM  Quality_Indicator_Summary__r WHERE 
                                                             REPORTING_PERIOD__r.Previous_Reporting_Period__c=:true) 
                                                FROM BusinessLicense WHERE Id IN: serviceIds]){
            if(ser.Quality_Indicator_Summary__r.isEmpty()){
                services.add(ser.id);
            }
        }
        if(services.size()>0){
            List<BusinessLicenseHistory> serviceHistory=[SELECT Id, BusinessLicense.id, BusinessLicense.Status__c, createdDate,  Field, OldValue, NewValue 
                                                                FROM BusinessLicenseHistory where Field='Status__c' AND BusinessLicense.id IN :services 
                                                                AND createdDate>=:startDate AND createdDate<=:endDate];

            for(BusinessLicenseHistory bh:serviceHistory){
                if(mapServiceANDHistory.containskey(bh.BusinessLicense.id)){
                    List<BusinessLicenseHistory> listServhis=new  List<BusinessLicenseHistory>();
                    listServhis= mapServiceANDHistory.get(bh.BusinessLicense.id);
                    listServhis.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, listServhis);
                }
                else{
                    List<BusinessLicenseHistory> bhs=new List<BusinessLicenseHistory>();
                    bhs.add(bh);
                    mapServiceANDHistory.put(bh.BusinessLicense.id, bhs);
                }
            }
            for(Id serviceId: services){
                if(mapServiceANDHistory.containskey(serviceId)){
                    for(BusinessLicenseHistory his: mapServiceANDHistory.get(serviceId)){
                        if(his.OldValue==OperatinalStatus || his.NewValue==OperatinalStatus){
                            mapServiceOffline.put(serviceId, true);
                            break;
                        }
                        mapServiceOffline.put(serviceId, false);  
                    }
                }
                else{
                    mapServiceOffline.put(serviceId, true);
                }
            }    
        }
        return mapServiceOffline;
    }
}