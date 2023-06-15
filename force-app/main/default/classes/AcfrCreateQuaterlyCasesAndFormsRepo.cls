/*------------------------------------------------------------------------------------------------
Author:         Pinali Patel
Description:    This class will be the Scheduler class and Batch class for bulk case and form creation functionality.
************************************************************************************************
History
/*
* Change log
27012023        
    - HEGDEA
       - Bug #327339 
       - Add Access Modifiers                
    - CJJOYA 
        - Bug #327347 
        - Implement Exception Handling and/or error logging framework for lines: 23, 30, 36, 42, 47 
        - Remove debug statements
Sprint 21 - PBI 299110.
    -KanalT
        - add two new methods
        - getAddressLocationByServiceId
        - getRegionsByAddressId
        - Updated DMLexception to QueryException
04042023
    - CJJOYA
        - Bug #362489
        - Change without sharing to with sharing

************************************************************************************************
 * @TestClass AcfrCreateQuaterlyCasesAndFormsTest
--------------------------------------------------------------------------------------------------*/
public with sharing class AcfrCreateQuaterlyCasesAndFormsRepo {
	private static AcfrCreateQuaterlyCasesAndFormsRepo instance = null;

	private AcfrCreateQuaterlyCasesAndFormsRepo() {
	}

	private QueryService queryService = new QueryService();

	public static AcfrCreateQuaterlyCasesAndFormsRepo getInstance() {
		if (instance == null) {
			instance = new AcfrCreateQuaterlyCasesAndFormsRepo();
		}
		return instance;
	}

	public Map<String, Id> getRecordTypeIds(String name) {
		Map<String, Id> recordTypeMap = new Map<String, Id>();
		for (RecordType recType : this.queryService.getRecordTypes(name)) {
			recordTypeMap.put(recType.SobjectType, recType.Id);
		}
		return recordTypeMap;
	}

	public Reporting_Period__c getActiveReportingPeriod() {
		List<Reporting_Period__c> repoPeriod = this.queryService.getReportingPeriod();

		return repoPeriod.size() > 0 ? repoPeriod[0] : null;
	}

	public List<Form__c> getFormsByCaseId(Id caseId) {
		List<Form__c> forms = new List<Form__c>();
		try {
			forms = this.queryService.getForms(caseId);
		} catch (QueryException e) {
			dohagedcare.Logger.error(e.getMessage(), e, 'QFR').log();
		}
		return forms;
	}

	public Service_Account_Relationship__c getServiceAccountRelById(
		Id serviceId
	) {
		Service_Account_Relationship__c sar = this.queryService.getServiceAccountRelationship(
			serviceId
		);
		return sar;
	}

	public List<Service_Account_Relationship__c> getServiceAccountRelByAccountId(
		List<Id> accountIds
	) {
		List<Service_Account_Relationship__c> sarList = new List<Service_Account_Relationship__c>();
		try {
			sarList = this.queryService.getServiceAccountRelationships(
				accountIds
			);
		} catch (QueryException e) {
			dohagedcare.Logger.error(e.getMessage(), e, 'QFR').log();
		}
		return sarList;
	}

	public List<Geospatial_Information__c> getRegionsByAddressId(
		Set<Id> addressList
	) {
		List<Geospatial_Information__c> regionsByAddressId = new List<Geospatial_Information__c>();
		try {
			regionsByAddressId = this.queryService.getRegions(addressList);
		} catch (QueryException e) {
			dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
		}
		return regionsByAddressId;
	}

	public Map<Id, Id> getAddressLocationByServiceId(List<Id> accountIds) {
		Map<Id, Id> addressLocationIdToServiceId = new Map<Id, Id>();
		try {
			for (
				Address_Location__c recType : this.queryService.getAddressLocations(
					accountIds
				)
			) {
				if (recType.Address__r.id != null) {
					addressLocationIdToServiceId.put(
						recType.Address__r.id,
						recType.Service__c
					);
				}
			}
		} catch (QueryException e) {
			dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
		}
		return addressLocationIdToServiceId;
	}

	private without sharing class QueryService {
		private List<Address_Location__c> getAddressLocations(
			List<Id> accountIds
		) {
			return [
				SELECT Id, Address__c, Address__r.id, Service__c, Service__r.id
				FROM Address_Location__c
				WHERE
					Service__r.AccountId = :accountIds
					AND Service__r.Care_Type__c = 'Home Care'
			];
		}
		private List<Geospatial_Information__c> getRegions(Set<Id> addressIds) {
			return [
				SELECT
					Id,
					Address__c,
					Address__r.id,
					Address__r.State_Province__c,
					Layer_Id__c,
					Name,
					Description__c
				FROM Geospatial_Information__c
				WHERE Address__c = :addressIds AND Layer_Id__c = 0
			];
		}

		private List<Service_Account_Relationship__c> getServiceAccountRelationships(
			List<Id> accountIds
		) {
			return [
				SELECT
					Id,
					Service_Name__r.Id,
					Service_Name__r.Care_Type__c,
					Service_Name__r.Service_Care_Sub_Type__c,
					Provider_Name__r.Purpose__c,
					Service_Name__r.Status__c,
					Provider_Name__r.Id,
					Association_Start_Date__c,
					Association_End_Date__c
				FROM Service_Account_Relationship__c
				WHERE
					Provider_Name__r.Id IN :accountIds
					AND Service_Name__r.Status__c = 'Operational'
					AND Service_Name__r.Care_Type__c IN (
						'Home Care',
						'National Aboriginal and Torres Strait Islander Flexible Aged Care Program',
						'Residential',
						'Flexible'
					)
				LIMIT 50000
			];
		}
		private Service_Account_Relationship__c getServiceAccountRelationship(
			Id serviceId
		) {
			return [
				SELECT
					Id,
					Service_Name__r.Care_Type__c,
					Service_Name__r.Service_Care_Sub_Type__c,
					Provider_Name__r.Id,
					Provider_Name__r.Purpose__c
				FROM Service_Account_Relationship__c
				WHERE Service_Name__r.Id = :serviceId
			];
		}

		private List<Form__c> getForms(Id caseId) {
			return [
				SELECT Id, Type__c, Case__r.Accountid, Case__c
				FROM Form__c
				WHERE Case__c = :caseId
			];
		}

		private List<Reporting_Period__c> getReportingPeriod() {
			return [
				SELECT
					Id,
					Current_Reporting_Period__c,
					End_Date__c,
					Start_Date__c
				FROM Reporting_Period__c
				WHERE Current_Reporting_Period__c = TRUE AND Type__c = 'Quarter'
			];
		}

		private List<RecordType> getRecordTypes(String recordTypeName) {
			return [
				SELECT Id, SobjectType
				FROM RecordType
				WHERE
					Name = :recordTypeName
					AND SobjectType IN ('Case', 'Form__c')
			];
		}
	}
}
