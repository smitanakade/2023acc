/*------------------------------------------------------------------------------------------------
Author:         Pinali Patel
Description:    This class will be the Scheduler class and Batch class for Bulk case and form creation functionality.
 ************************************************************************************************
 History 
 ************************************************************************************************
 --------------------------------------------------------------------------------------------------*/
public with sharing class AcfrCreateQuaterlyCasesAndFormsService {
	Map<Database.SaveResult, Id> allFailedResultsCase = new Map<Database.SaveResult, Id>();
	List<Database.SaveResult> allSuccessResultsCase = new List<Database.SaveResult>();
	Map<Database.SaveResult, Id> allFailedResultsForm = new Map<Database.SaveResult, Id>();
	List<Database.SaveResult> allSuccessResultsForm = new List<Database.SaveResult>();
	Map<Database.SaveResult, Id> allFailedResultsSLI = new Map<Database.SaveResult, Id>();
	List<Database.SaveResult> allSuccessResultsSLI = new List<Database.SaveResult>();

	Map<Id, List<Form__c>> accountIdToFormMap = new Map<Id, List<Form__c>>();
	Map<Id, List<BusinessLicense>> accountIdToServiceMap = new Map<Id, List<BusinessLicense>>();
	Map<String, List<String>> serviceTypeToFormMap = new Map<String, List<String>>();
	Map<String, Id> recordTypeMap = new Map<String, Id>();
	Map<String, Form_Entry_Type__mdt> formEntryMapMDT;
	Map<String, Service_To_Form_Type__mdt> careToFormMDT;
	Map<String, Form_Entry_Type__mdt> formEntryTypeMap = new Map<String, Form_Entry_Type__mdt>();

	List<Case> caseList = new List<Case>();
	List<Form__c> formList = new List<Form__c>();
	List<Service_Account_Relationship__c> serviceRelationships = new List<Service_Account_Relationship__c>();
	List<Id> govAccounts = new List<Id>();
	List<Id> mpsServiceProviders = new List<Id>();
	List<String> serviceCatValueList = new List<String>();
	List<Service_line_item__c> serviceLineItems = new List<Service_line_item__c>();
	List<Account> accountList = new List<Account>();
	Set<String> serviceCategories = new Set<String>();
	Set<String> formTypes = new Set<String>();
	List<Id> accountIds = new List<Id>();
	Map<Id, Account> accountsByIds = new Map<Id, Account>();
	List<Geospatial_Information__c> regionList = new List<Geospatial_Information__c>();
	Map<Id, Id> addressToServiceMap = new Map<Id, Id>();
	Map<Id, Geospatial_Information__c> ServiceToRegionMap = new Map<Id, Geospatial_Information__c>();

	Reporting_Period__c activeReportingPeriod = null;
	String resiViablity = 'Residential Viability and Prudential Reporting';
	String homeCareViablity = 'Home Care Viability and Prudential Reporting';
	String qfStatements = 'Approved Provider Quarterly Financial Statements';
	String mpsFoodnNutri = 'MPS Food and Nutrition Reporting';
	String homecarelc = 'Home Care Labour Costs and Hours';
	String resicarelc = 'Residential Labour Costs and Hours';
	String resifoodnutri = 'Residential Food and Nutrition Reporting';
	String natsifacp = 'NATSIFACP Food and Nutrition Reporting';
	String resiCareType = 'Residential';
	String flexibleCareType = 'Flexible';
	String natsiCareType = 'National Aboriginal and Torres Strait Islander Flexible Aged Care Program';

	WithoutSharingDML withoutSharingDML = new WithoutSharingDML();

	/*public AcfrCreateQuaterlyCasesAndFormsService(List<Service_Account_Relationship__c> serviceRelationships) {
    this.serviceRelationships = serviceRelationships;
    initialSetup();
    }*/

	public AcfrCreateQuaterlyCasesAndFormsService(List<Account> accountList) {
		this.accountList = accountList;
		for (Account acc : accountList) {
			this.accountIds.add(acc.Id);
			this.accountsByIds.put(acc.Id, acc);
		}
		initialSetup();
	}

	public AcfrCreateQuaterlyCasesAndFormsService(
		List<Service_line_item__c> serviceLineItems
	) {
		this.serviceLineItems = serviceLineItems;
		initialSetup();
	}

	public AcfrCreateQuaterlyCasesAndFormsService() {
		initialSetup();
	}

	public void initialSetup() {
		formEntryMapMDT = Form_Entry_Type__mdt.getAll();
		careToFormMDT = Service_To_Form_Type__mdt.getAll();
		setServiceToFormMap();
		getServiceCategoryValues();
	}

	public List<Case> performAction() {
		queryRecords();
		setServiceToRegionMap();
		preparingData();
		generateCases();
		generateForms();
		//generateServiceLineItems();
		generateServiceLineItems(
			this.accountIds,
			this.formList,
			this.accountIdToFormMap,
			this.accountIdToServiceMap
		);
		return this.caseList;
	}

	public void performActionForGLCodeLineItems() {
		for (Service_Line_Item__c sli : this.serviceLineItems) {
			this.formTypes.add(sli.Form__r.Type__c);
			this.serviceCategories.add(sli.Service_Category__c);
		}
		generateGLCodeLineItems(this.serviceLineItems, this.formTypes);
	}
	private void generateGLCodeLineItems(
		List<Service_line_item__c> serviceLineItems,
		Set<String> formTypes
	) {
		GLCodeLineItemHelper glcLineItemHelper = new GLCodeLineItemHelper(
			serviceLineItems,
			formTypes
		);
		glcLineItemHelper.generateGLCodeLineItems();
	}

	private List<Service_Line_Item__c> createSLIForCategories(Id formId) {
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
	private List<Service_Line_Item__c> createSLIForCategories(
		Id formId,
		String categorynew
	) {
		List<Service_Line_Item__c> serviceLineItemList = new List<Service_Line_Item__c>();
		if (categorynew != null) {
			serviceLineItemList.add(createSLI(formId, null, categorynew, null));
		}
		return serviceLineItemList;
	}
	private Service_Line_Item__c createSLI(
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

	private void generateServiceLineItems(
		List<Id> accountIds,
		List<Form__c> formList,
		Map<Id, List<Form__c>> accountIdToFormMap,
		Map<Id, List<BusinessLicense>> accountIdToServiceMap
	) {
		AcfrGenerateServiceLineItems generateServiceLineItem = new AcfrGenerateServiceLineItems(
			accountIds,
			formList,
			accountIdToFormMap,
			accountIdToServiceMap
		);
		generateServiceLineItem.generateServiceLineItems();
	}

	private void queryRecords() {
		this.recordTypeMap = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getRecordTypeIds('QFR');
		this.activeReportingPeriod = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getActiveReportingPeriod();
		this.serviceRelationships = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getServiceAccountRelByAccountId(this.accountIds);
		this.addressToServiceMap = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getAddressLocationByServiceId(this.accountIds);
		this.regionList = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getRegionsByAddressId(this.addressToServiceMap.KeySet());
	}

	public void preparingData() {
		for (
			Service_Account_Relationship__c serviceRel : this.serviceRelationships
		) {
			if (
				serviceRel.Association_Start_Date__c <=
				this.activeReportingPeriod.End_Date__c &&
				(serviceRel.Association_End_Date__c >=
				this.activeReportingPeriod.Start_Date__c ||
				serviceRel.Association_End_Date__c == null)
			) {
				if (serviceRel.Provider_Name__r.Purpose__c == 'Government') {
					govAccounts.add(serviceRel.Provider_Name__r.Id);
				}
				if (
					serviceRel.Service_Name__r.Care_Type__c == 'Flexible' &&
					serviceRel.Service_Name__r.Service_Care_Sub_Type__c ==
					'Multi-Purpose Service'
				) {
					mpsServiceProviders.add(serviceRel.Provider_Name__r.Id);
				}
				if (
					this.accountIdToServiceMap.containsKey(
						serviceRel.Provider_Name__r.Id
					)
				) {
					List<BusinessLicense> services = this.accountIdToServiceMap.get(
						serviceRel.Provider_Name__r.Id
					);
					services.add(serviceRel.Service_Name__r);
					this.accountIdToServiceMap.put(
						serviceRel.Provider_Name__r.Id,
						services
					);
				} else {
					this.accountIdToServiceMap.put(
						serviceRel.Provider_Name__r.Id,
						new List<BusinessLicense>{ serviceRel.Service_Name__r }
					);
				}
			}
		}
	}

	private void generateForms() {
		for (Case c : this.caseList) {
			Set<String> formTypesPerCase = new Set<String>();
			Set<String> careTypesForCase = new Set<String>();
			if (this.accountIdToServiceMap.containsKey(c.accountId)) {
				for (
					BusinessLicense service : this.accountIdToServiceMap
						?.get(c?.accountId)
				) {
					careTypesForCase.add(service.Care_Type__c);

					if (
						this.serviceTypeToFormMap.containsKey(
							service.Care_Type__c
						)
					) {
						formTypesPerCase.addAll(
							this.serviceTypeToFormMap.get(service.Care_Type__c)
						);
					}
				}
				formTypesPerCase.addAll(this.serviceTypeToFormMap.get('All'));
				if (govAccounts.contains(c.accountId)) {
					if (formTypesPerCase.contains(resiViablity)) {
						formTypesPerCase.remove(resiViablity);
					}
					if (formTypesPerCase.contains(homeCareViablity)) {
						formTypesPerCase.remove(homeCareViablity);
					}
					if (formTypesPerCase.contains(qfStatements)) {
						formTypesPerCase.remove(qfStatements);
					}
				}
				if (!mpsServiceProviders.contains(c.accountId)) {
					if (formTypesPerCase.contains(mpsFoodnNutri)) {
						formTypesPerCase.remove(mpsFoodnNutri);
					}
				}
				for (String type : formTypesPerCase) {
					formList.add(createForms(c, type));
				}

				formTypes.addAll(formTypesPerCase);
			}
			String stampCareType = '';
			for (String s : careTypesForCase) {
				stampCareType += s + ',';
			}
			stampCareType = stampCareType.removeEnd(',');
			c.QFR_Care_Type__c = stampCareType;
		}
		try {
			update this.caseList;
		} catch (DmlException exc) {
			dohagedcare.logger.error(exc.getMessage(), exc, 'QFR').log();
		}

		if (formList != null && !formList.isEmpty()) {
			try {
				withoutSharingDML.insertRecords(this.formList, false);
			} catch (DmlException e) {
				dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
			}
		}
		for (Form__c form : this.formList) {
			if (this.accountIdToFormMap.containsKey(form.Account__c)) {
				List<Form__c> forms = this.accountIdToFormMap.get(
					form.Account__c
				);
				forms.add(form);
				this.accountIdToFormMap.put(form.Account__c, forms);
			} else {
				this.accountIdToFormMap.put(
					form.Account__c,
					new List<Form__c>{ form }
				);
			}
		}
	}

	private void generateCases() {
		for (Id accountId : accountIds) {
			this.caseList.add(createCase(accountId));
		}

		if (this.caseList != null && !this.caseList.isEmpty()) {
			try {
				withoutSharingDML.insertRecords(this.caseList, false);
			} catch (DmlException e) {
				dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
			}
		}
	}

	private void getServiceCategoryValues() {
		Schema.DescribeFieldResult serviceCat = Service_Line_Item__c.Service_Category__c.getDescribe();
		List<Schema.PicklistEntry> ple = serviceCat.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple) {
			serviceCatValueList.add(pickListVal.getLabel());
		}
	}

	public Form__c createForms(Case c, String formType) {
		Form__c form = new Form__c();
		form.Account__c = c.accountid;
		form.Case__c = c.Id;
		form.RecordTypeId = this.recordTypeMap.get('Form__c');
		form.Reporting_Period__c = this.activeReportingPeriod.Id;
		form.Type__c = formType;
		return form;
	}

	public Case createCase(Id accountId) {
		Case c = new Case();
		c.Status = 'New';
		c.accountid = accountid;
		c.Priority = 'Medium';
		c.RecordTypeId = this.recordTypeMap.get('Case');
		c.Reporting_Period__c = this.activeReportingPeriod.id;
		c.NAPS_Id__c = this.accountsByIds.containsKey(accountId)
			? this.accountsByIds.get(accountId).Integration_ID__c
			: null;
		c.Provider_Name_Text__c = this.accountsByIds.containsKey(accountId)
			? this.accountsByIds.get(accountId).Name
			: null;

		return c;
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

	//****
	/* Additional Service creation - 
  /* 
  /* */
	public Service_Line_Item__c createSLIAdditionalService(
		Form__c form,
		Id serviceId,
		String category,
		String region
	) {
		Service_line_item__c s = new Service_line_item__c();
		s.Form__r = form;
		s.Form__c = form.id;
		s.Service__c = serviceId;
		s.Service_Category__c = category;
		s.Service_Region__c = region;
		return s;
	}
	public void generateRecordsForAdditionalServices(
		Id caseId,
		Id serviceId,
		String region
	) {
		queryRecords();
		Set<String> regionSetAdditional = new Set<String>();
		List<Service_Line_Item__c> additionalSLI = new List<Service_Line_Item__c>();
		List<Form__c> forms = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getFormsByCaseId(caseId);
		Service_Account_Relationship__c serviceAccountRel = AcfrCreateQuaterlyCasesAndFormsRepo.getInstance()
			.getServiceAccountRelById(serviceId);
		Set<String> newFormTypes = new Set<String>();
		Set<Form__c> existingFormsSLIs = new Set<Form__c>();
		List<String> formListTemp = this.serviceTypeToFormMap.get(
			serviceAccountRel.Service_Name__r.Care_Type__c
		);
		List<Form__c> additionalForms = new List<Form__c>();
		if (caseId != null) {
			newFormTypes.addAll(formListTemp);
			for (Form__c form : forms) {
				if (newFormTypes.contains(form.Type__c)) {
					newFormTypes.remove(form.Type__c);
					existingFormsSLIs.add(form);
				}
			}
			if (serviceAccountRel.Provider_Name__r.Purpose__c == 'Government') {
				if (newFormTypes.contains(resiViablity)) {
					newFormTypes.remove(resiViablity);
				}
				if (newFormTypes.contains(homeCareViablity)) {
					newFormTypes.remove(homeCareViablity);
				}
				if (newFormTypes.contains(qfStatements)) {
					newFormTypes.remove(qfStatements);
				}
			}
			if (
				serviceAccountRel.Service_Name__r.Care_Type__c == 'Flexible' &&
				serviceAccountRel.Service_Name__r.Service_Care_Sub_Type__c !=
				'Multi-PurposeMulti-Purpose Service'
			) {
				if (newFormTypes.contains(mpsFoodnNutri)) {
					newFormTypes.remove(mpsFoodnNutri);
				}
			}
			if (!newFormTypes.isEmpty()) {
				// this is where you need to add a new care type and a new form

				for (String type : newFormTypes) {
					Form__c form = new Form__c();
					form.Account__c = serviceAccountRel.Provider_Name__r.Id;
					form.Case__c = caseId;
					form.RecordTypeId = this.recordTypeMap.get('Form__c');
					form.Reporting_Period__c = this.activeReportingPeriod.Id;
					form.Type__c = type;

					additionalForms.add(form);
				}
				try {
					insert additionalForms;
				} catch (DmlException e) {
					dohagedcare.logger.error(e.getMessage(), e, 'QFR').log();
				}
				additionalForms.addAll(existingFormsSLIs);
			} else {
				newFormTypes.addAll(formListTemp);
				additionalForms.addAll(existingFormsSLIs);
			}
			for (Form__c form : additionalForms) {
				List<Form_Entry_Type__mdt> formEntryType = new List<Form_Entry_Type__mdt>();
				for (Form_Entry_Type__mdt fet : formEntryMapMDT.values()) {
					if (form.Type__c == fet.Form_Type__c)
						formEntryType.add(fet);
				}
				boolean qfsSLICreationComplete = false;
				for (Form_Entry_Type__mdt entryType : formEntryType) {
					if (
						(entryType?.Form_Type__c == resicarelc ||
						entryType?.Form_Type__c == resifoodnutri ||
						entryType?.Form_Type__c == natsifacp ||
						entryType?.Form_Type__c == mpsFoodnNutri) &&
						entryType?.Form_Entry_Type__c == 'GL_Code'
					) {
						additionalSLI.add(
							createSLIAdditionalService(
								form,
								null,
								'Total',
								null
							)
						);

						if (
							serviceId != null &&
							serviceAccountRel.Service_Name__r.Care_Type__c ==
							resiCareType &&
							(entryType?.Form_Type__c == resicarelc ||
							entryType?.Form_Type__c == resifoodnutri)
						) {
							additionalSLI.add(
								createSLIAdditionalService(
									form,
									serviceId,
									null,
									null
								)
							);
						} else if (
							serviceId != null &&
							serviceAccountRel.Service_Name__r.Care_Type__c ==
							natsiCareType &&
							entryType?.Form_Type__c == natsifacp
						) {
							additionalSLI.add(
								createSLIAdditionalService(
									form,
									serviceId,
									null,
									null
								)
							);
						} else if (
							serviceId != null &&
							serviceAccountRel.Service_Name__r.Care_Type__c ==
							flexibleCareType &&
							entryType?.Form_Type__c == mpsFoodnNutri
						) {
							additionalSLI.add(
								createSLIAdditionalService(
									form,
									serviceId,
									null,
									null
								)
							);
						} else {
							//do nothing
						}
					}
					//Creates all SLI for Approved Provider Quarterly Financial Statement including Total

					if (
						entryType?.Form_Type__c == qfStatements &&
						entryType?.Form_Entry_Type__c == 'GL_Code' &&
						qfsSLICreationComplete == false
					) {
						additionalSLI.addAll(createSLIForCategories(form.id));
						qfsSLICreationComplete = true;
					}
					//Creates Centrally Held SLI for Home Care Labour Costs and Hour
					else if (
						entryType?.Form_Type__c == homecarelc &&
						entryType?.Form_Entry_Type__c == 'GL_Code'
					) {
						if (region == null) {
							additionalSLI.addAll(
								createSLIForCategories(
									form.id,
									entryType.Category__c
								)
							);
							additionalSLI.add(
								createSLIAdditionalService(
									form,
									null,
									'Total',
									null
								)
							);
						}
						if (
							region != null &&
							!regionSetAdditional.contains(region)
						) {
							regionSetAdditional.add(region);
							additionalSLI.add(
								createSLIAdditionalService(
									form,
									null,
									null,
									region
								)
							);
						}
					}
				}
			}
			try {
				insert additionalSLI;
			} catch (DmlException f) {
				dohagedcare.logger.error(f.getMessage(), f, 'QFR').log();
			}
			generateGLCodeLineItems(additionalSLI, newFormTypes);
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
