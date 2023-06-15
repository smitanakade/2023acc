/******************************************************************************
 *  Apex Name   :       AcfrGenerateServiceLineItems
 *  Test Class  :       AcfrGenerateServiceLineItemsTest
 *  Author      :       CJJOYA
 *
 *  Revision History:
 *  15032023    :       Date created
 *                      PBI#339782
 *
 */
public with sharing class AcfrGenerateServiceLineItems {
	Map<Database.SaveResult, Id> allFailedResultsSLI = new Map<Database.SaveResult, Id>();
	List<Database.SaveResult> allSuccessResultsSLI = new List<Database.SaveResult>();
	Map<Id, List<Form__c>> accountIdToFormMap = new Map<Id, List<Form__c>>();
	Map<Id, List<BusinessLicense>> accountIdToServiceMap = new Map<Id, List<BusinessLicense>>();
	Map<String, List<String>> serviceTypeToFormMap = new Map<String, List<String>>();
	Map<String, Form_Entry_Type__mdt> formEntryMapMDT;
	Map<String, Service_To_Form_Type__mdt> careToFormMDT;
	Map<String, Form_Entry_Type__mdt> formEntryTypeMap = new Map<String, Form_Entry_Type__mdt>();

	List<String> serviceCatValueList = new List<String>();
	List<Service_line_item__c> serviceLineItems = new List<Service_line_item__c>();
	List<Form__c> formList = new List<Form__c>();
	List<Service_Account_Relationship__c> serviceRelationships = new List<Service_Account_Relationship__c>();
	Set<String> serviceCategories = new Set<String>();
	Set<String> formTypes = new Set<String>();
	List<Id> accountIds = new List<Id>();
	List<Geospatial_Information__c> regionList = new List<Geospatial_Information__c>();
	Map<Id, Id> addressToServiceMap = new Map<Id, Id>();
	Map<Id, Geospatial_Information__c> serviceToRegionMap = new Map<Id, Geospatial_Information__c>();

	Boolean qfsSLICreationComplete;

	Reporting_Period__c activeReportingPeriod = null;

	public static final String RESIVIABILITY = 'Residential Viability and Prudential Reporting';
	public static final String HOMECAREVIABILITY = 'Home Care Viability and Prudential Reporting';
	public static final String QFRSTATEMENTS = 'Approved Provider Quarterly Financial Statements';
	public static final String MPSFOODNUTRI = 'MPS Food and Nutrition Reporting';
	public static final String HOMECARECALC = 'Home Care Labour Costs and Hours';
	public static final String RESICARECALC = 'Residential Labour Costs and Hours';
	public static final String RESIFOODNUTRI = 'Residential Food and Nutrition Reporting';
	public static final String NATSIFACP = 'NATSIFACP Food and Nutrition Reporting';
	public static final String RESICARETYPE = 'Residential';
	public static final String FLEXIBLECARETYPE = 'Flexible';
	public static final String NATSICARETYPE = 'National Aboriginal and Torres Strait Islander Flexible Aged Care Program';
	public static final String FORM_ENTRY_TYPE = 'GL_Code';

	WithoutSharingDML withoutSharingDML = new WithoutSharingDML();

	public AcfrGenerateServiceLineItems(
		List<Id> accountIds,
		List<Form__c> formList,
		Map<Id, List<Form__c>> accountIdToFormMap,
		Map<Id, List<BusinessLicense>> accountIdToServiceMap
	) {
		this.accountIds = accountIds;
		this.formList = formList;
		this.accountIdToFormMap = accountIdToFormMap;
		this.accountIdToServiceMap = accountIdToServiceMap;
		initialSetup();
	}

	public void initialSetup() {
		formEntryMapMDT = Form_Entry_Type__mdt.getAll();
		careToFormMDT = Service_To_Form_Type__mdt.getAll();
		queryRecords();
		setServiceToRegionMap();
		setServiceToFormMap();
		getServiceCategoryValues();
	}

	private void getServiceCategoryValues() {
		Schema.DescribeFieldResult serviceCat = Service_Line_Item__c.Service_Category__c.getDescribe();
		List<Schema.PicklistEntry> ple = serviceCat.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple) {
			serviceCatValueList.add(pickListVal.getLabel());
		}
	}

	public void setServiceToFormMap() {
		for (Service_To_Form_Type__mdt serviceToForm : careToFormMDT.values()) {
			if (
				this.serviceTypeToFormMap.containsKey(
					serviceToForm.Care_Type__c
				)
			) {
				List<String> forms = this.serviceTypeToFormMap.get(
					serviceToForm.Care_Type__c
				);
				forms.add(serviceToForm.Form_Type__c);
				this.serviceTypeToFormMap.put(
					serviceToForm.Care_Type__c,
					forms
				);
			} else {
				this.serviceTypeToFormMap.put(
					serviceToForm.Care_Type__c,
					new List<String>{ serviceToForm.Form_Type__c }
				);
			}
		}
		for (Form_Entry_Type__mdt entry : formEntryMapMDT.values()) {
			this.formEntryTypeMap.put(entry.Form_Type__c, entry);
		}
	}

	public List<Service_Line_Item__c> createSLIForCategories(Id formId) {
		List<Service_Line_Item__c> serviceLineItemList = new List<Service_Line_Item__c>();
		for (String category : this.serviceCatValueList) {
			if (category != null) {
				serviceLineItemList.add(
					createSLI(formId, null, category, null)
				);
			}
		}
		return serviceLineItemList;
	}

	public List<Service_Line_Item__c> createSLIForCategories(
		Id formId,
		String categorynew
	) {
		List<Service_Line_Item__c> serviceLineItemList = new List<Service_Line_Item__c>();
		if (categorynew != null) {
			serviceLineItemList.add(createSLI(formId, null, categorynew, null));
		}
		return serviceLineItemList;
	}

	public Service_Line_Item__c createSLI(
		Id formId,
		Id serviceId,
		String category,
		String region
	) {
		Service_line_item__c s = new Service_line_item__c();
		s.Form__c = formId;
		s.Service__c = serviceId;
		s.Service_Category__c = category;
		s.Service_Region__c = region;
		return s;
	}

	public void getFormTypes(
		Id formId,
		Id accountId,
		string formType,
		string formEntryType,
		string entryTypeCategory
	) {
		boolean isItQFSForm =
			formType == QFRSTATEMENTS &&
			formEntryType == FORM_ENTRY_TYPE &&
			qfsSLICreationComplete == false;
		boolean isItHomeCareLabourCostForm =
			formType == HOMECARECALC &&
			formEntryType == FORM_ENTRY_TYPE;
		boolean isItAllOtherForm =
			(formType == RESICARECALC ||
			formType == RESIFOODNUTRI ||
			formType == NATSIFACP ||
			formType == MPSFOODNUTRI) && formEntryType == FORM_ENTRY_TYPE;
		if (isItQFSForm) {
			this.serviceLineItems.addAll(createSLIForCategories(formId));
			qfsSLICreationComplete = true;
		}
		if (isItHomeCareLabourCostForm) {
			this.serviceLineItems.addAll(
				createSLIForCategories(formId, entryTypeCategory)
			);
			this.serviceLineItems.add(createSLI(formId, null, 'Total', null));
			for (
				BusinessLicense service : this.accountIdToServiceMap.get(
					accountId
				)
			) {
				checkServiceAndRegionForHomeCareLabour(service.Id, formId);
			}
		}
		if (isItAllOtherForm) {
			this.serviceLineItems.add(createSLI(formId, null, 'Total', null));
			for (
				BusinessLicense service : this.accountIdToServiceMap.get(
					accountId
				)
			) {
				checkServiceAndCareTypeForOtherForms(
					service.Id,
					formId,
					service.Care_Type__c,
					formType
				);
			}
		}
	}

	private void queryRecords() {
		this.serviceRelationships = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getServiceAccountRelByAccountId(this.accountIds);
		this.addressToServiceMap = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getAddressLocationByServiceId(this.accountIds);
		this.regionList = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getRegionsByAddressId(this.addressToServiceMap.KeySet());
	}

	public void checkServiceAndCareTypeForOtherForms(
		Id serviceId,
		Id formId,
		string careType,
		string formType
	) {
		Boolean isResiCareType =
			serviceId != null &&
			careType == RESICARETYPE &&
			(formType == RESICARECALC ||
			formType == RESIFOODNUTRI);
		Boolean isNATSICareType =
			serviceId != null &&
			careType == NATSICARETYPE &&
			formType == NATSIFACP;
		Boolean isFlexibleCareType =
			serviceId != null &&
			careType == FLEXIBLECARETYPE &&
			formType == MPSFOODNUTRI;
		if (isResiCareType) {
			this.serviceLineItems.add(createSLI(formId, serviceId, null, null));
		} else if (isNATSICareType) {
			this.serviceLineItems.add(createSLI(formId, serviceId, null, null));
		} else if (isFlexibleCareType) {
			this.serviceLineItems.add(createSLI(formId, serviceId, null, null));
		}
	}

	public void checkServiceAndRegionForHomeCareLabour(
		Id serviceId,
		Id formId
	) {
		Set<String> regionSet = new Set<String>();
		string region;
		if (
			serviceId != null &&
			this.ServiceToRegionMap.get(serviceId)
				?.Address__r.State_Province__c != null
		) {
			region =
				this.ServiceToRegionMap.get(serviceId)
					?.Address__r.State_Province__c +
				'-' +
				this.ServiceToRegionMap.get(serviceId).Description__c;
		}
		if (
			region != '' &&
			this.ServiceToRegionMap.containsKey(serviceId) &&
			!regionSet.contains(region) &&
			serviceId != null
		) {
			regionSet.add(region);
			this.serviceLineItems.add(createSLI(formId, null, null, region));
		}
	}

	public void generateServiceLineItems() {
		for (Id accountid : accountIds) {
			if (this.accountIdToFormMap.containsKey(accountId)) {
				for (
					Form__c formList : this.accountIdToFormMap.get(accountId)
				) {
					List<Form_Entry_Type__mdt> formEntryType = new List<Form_Entry_Type__mdt>();
					for (Form_Entry_Type__mdt fet : formEntryMapMDT.values()) {
						if (formList.Type__c == fet.Form_Type__c)
							formEntryType.add(fet);
					}
					qfsSLICreationComplete = false;
					for (Form_Entry_Type__mdt entryType : formEntryType) {
						getFormTypes(
							formList.Id,
							accountId,
							entryType?.Form_Type__c,
							entryType?.Form_Entry_Type__c,
							entryType?.Category__c
						);
					}
				}
			}
		}
		if (serviceLineItems != null && !serviceLineItems.isEmpty()) {
			try {
				withoutSharingDML.insertRecords(serviceLineItems, false);
			} catch (DmlException e) {
				dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
			}
		}
	}

	// - create a map of service to region based on the regionList and addressToServiceMap created earlier
	void setServiceToRegionMap() {
		for (Geospatial_Information__c regionDetails : this.regionList) {
			if (
				this.addressToServiceMap.containsKey(
					regionDetails.Address__r.id
				)
			) {
				Id services = this.addressToServiceMap.get(
					regionDetails.Address__r.id
				);
				ServiceToRegionMap.put(services, regionDetails);
			}
		}
	}
}
