/**
 * @testClass AcfrEmailServiceTest
 */
public with sharing class AcfrEmailService {
	static final String primaryRole = 'QFR Primary Contact';
	static String reportingPeriodId;
	static String accountIdFromCase;
    
    static Map<String, QFR_EmailNotificationSettings__mdt> mapQFREmailNotf = QFR_EmailNotificationSettings__mdt.getAll();
    static String emailAdrress = mapQFREmailNotf.get('SendEmail').OWEA__c;
    static List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :emailAdrress LIMIT 1];


	public static String getEmailSubject(
		String recordId,
		String objectAPI,
		String templateName
	) {
		EmailTemplate tmplt = [
			SELECT id, name, Subject, DeveloperName, HtmlValue, Body
			FROM EmailTemplate
			WHERE DeveloperName = :templateName
			LIMIT 1
		];
		String emailSubject = AcfrEmailService.mergeFields(
			tmplt.Subject,
			recordId,
			objectAPI
		);
		if (
			reportingPeriodId != null &&
			(templateName == 'QFR_Overdue_Template' ||
			templateName == 'QFR_Final_Overdue')
		) {
			String emailSubjectToReplace = emailSubject;
			emailSubject = AcfrEmailService.mergeFields(
				emailSubject,
				reportingPeriodId,
				'Reporting_Period__c'
			);
			String toMonth = emailSubject.substringBetween('to ', ' QFR');
			emailSubject = updateSubjectForOverdueEmails(
				emailSubjectToReplace,
				emailSubject.substringBetween('/', '/'),
				toMonth.substring(toMonth.indexOf('/')+1,toMonth.lastIndexOf('/', toMonth.length()))
			);
		}
		return emailSubject;
	}

	public static String getEmailContent(
		String recordId,
		String objectAPI,
		String templateName
	) {
		EmailTemplate tmplt = [
			SELECT id, name, Subject, DeveloperName, HtmlValue, Body
			FROM EmailTemplate
			WHERE DeveloperName = :templateName
			LIMIT 1
		];
		String emailBody = tmplt.HTMLValue;
		
		emailBody = AcfrEmailService.mergeFields(
			emailBody,
			recordId,
			objectAPI
		);
		if (
			reportingPeriodId != null &&
			(templateName == 'QFR_Overdue_Template' ||
			templateName == 'QFR_Final_Overdue')
		) {
			emailBody = AcfrEmailService.mergeFields(
				emailBody,
				reportingPeriodId,
				'Reporting_Period__c'
			);
		}
		if (emailBody.contains('PROVIDERNAME') && accountIdFromCase != null) {
			Account acc = [
				SELECT Id, Name
				FROM Account
				WHERE Id = :accountIdFromCase
			];
			String accName = acc.name;
			emailBody = emailBody.replaceAll('PROVIDERNAME', accName);
		}

		emailBody = emailBody.replace('<![CDATA[', '');
		emailBody = emailBody.replace(']]>', '');
		emailBody = emailBody.replace('<o:p></o:p>', '');
		emailBody = emailBody.replace('{', '');
		emailBody = emailBody.replace('}', '');


		return emailBody;
	}

	public static String getPrimaryEmailAddress(String recordId) {
		String emailAdd = '';
		List<Case> cs = [
			SELECT AccountId
			FROM Case
			WHERE Id = :recordId
			LIMIT 1
		];
		if (cs.size() > 0) {
			for (Contact_Relationship__c rec : [
				SELECT id, Contact__r.Email
				FROM Contact_Relationship__c
				WHERE
					Account__c = :cs[0].AccountId
					AND Contact__r.Email != NULL
					AND Contact__r.Email != ''
					AND Role__c = :primaryRole
				LIMIT 1
			]) {
				if (rec != null)
					emailAdd = rec.Contact__r.Email;
			}
		}
		return emailAdd;
	}

	public static String getNonPrimaryEmailAddress(String recordId) {
		String emailAdd = '';
		List<Case> cs = [
			SELECT AccountId
			FROM Case
			WHERE Id = :recordId
			LIMIT 1
		];
		if (cs.size() > 0) {
			for (Contact_Relationship__c rec : [
				SELECT id, Contact__r.Email
				FROM Contact_Relationship__c
				WHERE
					Account__c = :cs[0].AccountId
					AND Contact__r.Email != NULL
					AND Contact__r.Email != ''
					AND Role__c != :primaryRole
			]) {
				emailAdd = emailAdd + rec.Contact__r.Email + ';';
			}
		}
		return emailAdd;
	}

	public static String getPrimaryandNonPrimaryEmailAddress(
		String recordId,
		String excludeEmailAddress
	) {
		String emailAdd = '';
		List<Case> cs = [
			SELECT AccountId
			FROM Case
			WHERE Id = :recordId
			LIMIT 1
		];
		if (cs.size() > 0) {
			for (Contact_Relationship__c rec : [
				SELECT id, Contact__r.Email
				FROM Contact_Relationship__c
				WHERE
					Account__c = :cs[0].AccountId
					AND Contact__r.Email != NULL
					AND Contact__r.Email != ''
					AND Contact__r.Email != :excludeEmailAddress
			]) {
				if (rec != null)
					emailAdd = rec.Contact__r.Email;
			}
		}
		return emailAdd;
	}

	public static void sendCustomSingleEmailMethod(
		String recordId,
		String emailBody,
		String emailAddress,
		String emailAddressCC,
		String emailSubject
	) {
		List<String> emailAddressList = new List<String>();
		if (emailAddress != '' && emailAddress != null) {
			emailAddress = emailAddress.replaceAll('\\s+', '');
			for (String str : emailAddress.split(';')) {
				if (str != null && str != '') {
					emailAddressList.add(str);
				}
			}
		}
        
        
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if (emailAddressList != null && emailAddressList.size() > 0) {
			mail.setToAddresses(emailAddressList);
			if (emailAddressCC != '' && emailAddressCC != null) {
				emailAddressCC = emailAddressCC.replaceAll('\\s+', '');
				List<String> emailAddressCCList = new List<String>();
				for (String str : emailAddressCC.split(';')) {
					if (str != null && str != '') {
						emailAddressCCList.add(str);
					}
				}
				mail.setCcAddresses(emailAddressCCList);
			}
            
			mail.setWhatId(recordId);
            if (owea.size() > 0 ){
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            mail.setSubject(emailSubject);
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(emailBody);
			mail.setSaveAsActivity(true);
			try {
				Messaging.sendEmail(
					new List<Messaging.SingleEmailMessage>{ mail }
				);
			} catch (Exception exp) {
				dohagedcare.Logger.error(
						exp.getMessage(),
						exp,
						'AcfrEmailService.sendCustomSingleEmailMethod'
					)
					.Log();
			}
		}
	}

	public static String updateSubjectForOverdueEmails(
		String emailSubject,
		String startDate,
		String endDate
	) {
		if (startDate != null && startDate != null && endDate != null) {
			Map<String, String> numberToStringMonths = createNumberToStringMonthMap();
			String startMonth = numberToStringMonths.get(startDate);
			String endMonth = numberToStringMonths.get(endDate);
			emailSubject = emailSubject.replace(
				'REPORTING_STARTDATE',
				startMonth
			);
			emailSubject = emailSubject.replace('REPORTING_ENDDATE', endMonth);
		}
		return emailSubject;
	}

	public static Map<String, String> createNumberToStringMonthMap() {
		Map<String, String> monthNumberToStringMap = new Map<String, String>();
		monthNumberToStringMap.put('1', 'January');
		monthNumberToStringMap.put('2', 'February');
		monthNumberToStringMap.put('3', 'March');
		monthNumberToStringMap.put('4', 'April');
		monthNumberToStringMap.put('5', 'May');
		monthNumberToStringMap.put('6', 'June');
		monthNumberToStringMap.put('7', 'July');
		monthNumberToStringMap.put('8', 'August');
		monthNumberToStringMap.put('9', 'September');
		monthNumberToStringMap.put('10', 'October');
		monthNumberToStringMap.put('11', 'November');
		monthNumberToStringMap.put('12', 'December');
		return monthNumberToStringMap;
	}

	public static void sendStandardSingleEmailMethod(
		String recordId,
		String primaryContactId,
		String emailTemplate,
		String emailAddress,
		String emailAddressCC
	) {
		String templateId = [
			SELECT Id
			FROM emailtemplate
			WHERE developername = :emailTemplate
			LIMIT 1
		]
		.Id;
		List<String> emailAddressList = new List<String>();
		if (emailAddress != '' && emailAddress != null) {
			emailAddress = emailAddress.replaceAll('\\s+', '');
			for (String str : emailAddress.split(';')) {
				if (str != null && str != '') {
					emailAddressList.add(str);
				}
			}
		}
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if (emailAddressList != null && emailAddressList.size() > 0) {
			mail.setToAddresses(emailAddressList);
			if (emailAddressCC != '' && emailAddressCC != null) {
				emailAddressCC = emailAddressCC.replaceAll('\\s+', '');
				List<String> emailAddressCCList = new List<String>();
				for (String str : emailAddressCC.split(';')) {
					if (str != null && str != '') {
						emailAddressCCList.add(str);
					}
				}
				mail.setCcAddresses(emailAddressCCList);
			}
            if (owea.size() > 0 ){
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setWhatId(recordId);
			mail.setTreatTargetObjectAsRecipient(false);
			if (primaryContactId == null || primaryContactId == '') {
				primaryContactId = [SELECT Id FROM Contact LIMIT 1].Id; //Placeholder ContactId
			}
			mail.setTargetObjectId(primaryContactId);
			mail.setTemplateId(templateId);
			mail.setSaveAsActivity(true);
			try {
				Messaging.sendEmail(
					new List<Messaging.SingleEmailMessage>{ mail }
				);
			} catch (Exception exp) {
				dohagedcare.Logger.error(
						exp.getMessage(),
						exp,
						'AcfrEmailService.sendStandardSingleEmailMethod'
					)
					.Log();
			}
		}
	}

	public static String mergeFields(
		String emailBody,
		String recordId,
		String recObject
	) {
		Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		for (
			Custom_Email_Template_Field_Mapping__mdt rec : Custom_Email_Template_Field_Mapping__mdt.getAll()
				.values()
		) {
			Set<String> fieldSet = new Set<String>();
			if (fieldMap.get(rec.Object__c) != null) {
				fieldSet = fieldMap.get(rec.Object__c);
			}
			fieldSet.add(rec.Field__c);
			fieldMap.put(rec.Object__c, fieldSet);
		}
		String query = null;
		for (String key : fieldMap.keySet()) {
			if (recObject == key) {
				for (String stringField : fieldMap.get(key)) {
					query = draftQuery(stringField, query);
				}
				query =
					query +
					' From ' +
					key +
					' where Id = \'' +
					recordId +
					'\'';
				List<sObject> sobjRec = Database.query(query);
				if (key == 'Case') {
					Case caseTemp = (Case) sobjRec[0];
					reportingPeriodId = caseTemp.Reporting_Period__c;
					accountIdFromCase = caseTemp.AccountId;
				}
				if (sobjRec.size() > 0) {
					List<Custom_Email_Template_Field_Mapping__mdt> mappingMeta = Custom_Email_Template_Field_Mapping__mdt.getAll()
						.values();
					Map<String, String> fdMap = new Map<String, String>();
					for (FieldDefinition rec : [
						SELECT DataType, QualifiedApiName
						FROM FieldDefinition
						WHERE
							EntityDefinitionId = :recObject
							AND QualifiedApiName IN :fieldMap.get(recObject)
					]) {
						fdMap.put(rec.QualifiedApiName, rec.DataType);
					}
					for (
						Custom_Email_Template_Field_Mapping__mdt rec : mappingMeta
					) {
						if (rec.Object__c == key) {
							emailBody = retrieveEmailBody(
								fieldMap.get(key),
								rec,
								emailBody,
								sobjRec,
								recObject,
								fdMap
							);
						}
					}
				}
				emailBody = emailBody.replace('}', '');
				emailBody = emailBody.replace('{', '');
			} else {
				//do nothing
			}
		}
		return emailBody;
	}
	public static String retrieveEmailBody(
		Set<String> stringFieldList,
		Custom_Email_Template_Field_Mapping__mdt rec,
		String emailBody,
		List<sObject> sobjRec,
		String recObject,
		Map<String, String> fdMap
	) {
		for (String stringField : stringFieldList) {
			if (stringField == rec.Field__c) {
				String val = getFieldVal(
					stringField,
					sobjRec,
					recObject,
					fdMap
				);
				String mergeField = rec.Merge_Field_Name__c;
				if (val != null && val != '') {
					emailBody = emailBody.replace(mergeField, val);
				}
			}
		}
		return emailBody;
	}

	public static String draftQuery(String stringField, String query) {
		if (query == null) {
			query = 'Select ' + stringField;
		} else {
			query = query + ', ' + stringField;
		}
		return query;
	}

	public static String getFieldVal(
		String stringField,
		List<Sobject> sobjRec,
		String recObject,
		Map<String, String> fdMap
	) {
		String val = '';
		if (stringField.contains('.')) {
			List<String> stringFieldList = stringField.split('\\.');
			switch on stringFieldList.size() {
				when 3 {
					val = clauseStringFieldListSize3(stringFieldList, sobjRec, val);
				}
				when 2 {
					val = clauseStringFieldListSize2(stringFieldList, sobjRec, val);
				}
				when else {
					// do nothing
				}
			}
		} else {
			String dtType = fdMap.get(stringField);
			switch on dtType {
				when 'Date/Time' {
					datetime dt = (datetime) sobjRec[0].get(stringField);
					val = dt.format('yyyy/MM/dd');
				}
				when 'Date' {
					val = clauseDate(stringField, sobjRec, val);
				}
				when else {
					if (sobjRec[0].get(stringField) instanceof Date) {
						val = String.valueOf(sobjRec[0].get(stringField));
					} else {
						val = (string) sobjRec[0].get(stringField);
					}
				}
			}
		}
		return val;
	}
	public static String clauseStringFieldListSize3(
		List<String> stringFieldList,
		List<Sobject> sobjRec,
		String val
	) {
		String parent2 = stringFieldList[0].replace('__r', '__c');
		String parent1 = stringFieldList[1].replace('__r', '__c');
		String stringField = stringFieldList[2];
		if (
			sobjRec[0].getSobject(parent2) != null &&
			sobjRec[0].getSobject(parent2).getSobject(parent1) != null
		) {
			val = (String) sobjRec[0]
				.getSobject(parent2)
				.getSobject(parent1)
				.get(stringField);
		}
		return val;
	}

	public static String clauseStringFieldListSize2(
		List<String> stringFieldList,
		List<Sobject> sobjRec,
		String val
	) {
		String parent1 = stringFieldList[0];
		String stringField = stringFieldList[1];
		if (sobjRec[0].getSobject(parent1) != null) {
			val = (String) sobjRec[0].getSobject(parent1).get(stringField);
		}
		return val;
	}

	public static String clauseDate(
		String stringField,
		List<Sobject> sobjRec,
		String val
	) {
		date dt = (date) sobjRec[0].get(stringField);
		if (sobjRec[0].get(stringField) != null) {
			val = dt.year() + '/' + dt.month() + '/' + dt.day();
		}
		return val;
	}

	public static String hideConditions(
		String emailBody,
		String conditionVar,
		Boolean visible
	) {
		String conditionVar_Start = 'CONDITION_START_' + conditionVar;
		String conditionVar_End = 'CONDITION_END_' + conditionVar;
		if (visible == false) {
			String val = emailBody.substringBetween(
				conditionVar_Start,
				conditionVar_End
			);
			if (val == null) {
				val = '';
			}
			emailBody = emailBody.replace(val, '');
		}
		emailBody = emailBody.replace(conditionVar_Start, '');
		emailBody = emailBody.replace(conditionVar_End, '');
		emailBody = emailBody.replace('}', '');
		emailBody = emailBody.replace('{', '');

		return emailBody;
	}

	public static Map<Id, String> getEmailToAccMap(
		List<Contact_Relationship__c> conRelList,
		Boolean hasPrimaryMergeField,
		Boolean toAddress1PrimaryOnly,
		Boolean toAddressPrimaryAll,
		Boolean toAddressAllContactRel
	) {
		Map<Id, String> emailToAccMap = new Map<Id, String>();
		for (Contact_Relationship__c rec : conRelList) {
			String emailAdd = '';
			if (
				(toAddressAllContactRel ||
				(toAddressPrimaryAll && rec.Role__c == primaryRole)) &&
				emailToAccMap.get(rec.Account__c) != null
			) {
				emailAdd = emailToAccMap.get(rec.Account__c) + ';';
				emailAdd = emailAdd + rec.Contact__r.email + ';';
				emailToAccMap.put(rec.Account__c, emailAdd);
			} else if (
				(toAddressAllContactRel ||
				(toAddressPrimaryAll && rec.Role__c == primaryRole)) &&
				emailToAccMap.get(rec.Account__c) == null
			) {
				emailAdd = emailAdd + rec.Contact__r.email + ';';
				emailToAccMap.put(rec.Account__c, emailAdd);
			} else if (
				toAddress1PrimaryOnly &&
				rec.Role__c == primaryRole &&
				emailToAccMap.get(rec.Account__c) == null
			) {
				emailAdd = rec.Contact__r.email + ';';
				emailToAccMap.put(rec.Account__c, emailAdd);
			} else {
				//do nothing
			}
		}
		return emailToAccMap;
	}

	public static Map<Id, String> getEmailCCAccMap(
		List<Contact_Relationship__c> conRelList,
		Boolean hasPrimaryMergeField,
		Boolean toAddress1PrimaryOnly,
		Boolean toAddressPrimaryAll,
		Boolean toAddressAllContactRel,
		Map<Id, String> emailToAccMap
	) {
		Map<Id, String> emailCCAccMap = new Map<Id, String>();
		for (Contact_Relationship__c rec : conRelList) {
			String emailAdd = '';
			if (
				((toAddressPrimaryAll == true && rec.Role__c != primaryRole) ||
				(toAddress1PrimaryOnly == true &&
				!emailToAccMap.get(rec.Account__c)
					.contains(rec.Contact__r.email))) &&
				emailCCAccMap.get(rec.Account__c) != null
			) {
				emailAdd = emailCCAccMap.get(rec.Account__c) + ';';
				emailAdd = emailAdd + rec.Contact__r.email + ';';
				emailCCAccMap.put(rec.Account__c, emailAdd);
			} else if (
				((toAddressPrimaryAll == true && rec.Role__c != primaryRole) ||
				(toAddress1PrimaryOnly == true &&
				!emailToAccMap.get(rec.Account__c)
					.contains(rec.Contact__r.email))) &&
				emailCCAccMap.get(rec.Account__c) == null
			) {
				emailAdd = emailAdd + rec.Contact__r.email + ';';
				emailCCAccMap.put(rec.Account__c, emailAdd);
			} else {
				//do nothing
			}
		}
		return emailCCAccMap;
	}

	public static void sendEmailMain(
		Boolean isStandard,
		String templateName,
		List<Sobject> objectList,
		String toAddress,
		String ccAddress,
		Boolean hasPrimaryMergeField,
		Boolean toAddress1PrimaryOnly,
		Boolean toAddressPrimaryAll,
		Boolean toAddressAllContactRel,
		Boolean toAddressVariable
	) {
		//isStandard - true/false is using standard template or custom matadata merge fields
		//objectList - list of record where email is sent. Accepts only Case or Account Sobjects -  NOTE: Case Sobject must contain AccountId in query list
		//toAddress - optional, required if toAddressVariable is TRUE
		//ccAddress - optional, required if toAddressVariable is TRUE
		//hasPrimaryMergeField - has Contact.Name merge field populated by one of the primary role contacts
		//toAddress1PrimaryOnly - to: 1 Primary contact rel, cc: all other contact rels
		//toAddressPrimaryAll - to: All Primary contact rels, cc: all non primary contact rels
		//toAddressAllContactRel - to: all contact rels cc: empty
		//toAddressVariable - to: toAddress, cc: ccAddress variables from the method paramaters

		//IF TOADDRESS BOOLEAN VARIABLES ARE ALL FALSE, ITS DEFAULT TO SEND TO ALLCONTACTREL (toAddressAllContactRel will default TRUE)
		if (
			toAddressVariable == false &&
			toAddress1PrimaryOnly == false &&
			toAddressPrimaryAll == false
		) {
			toAddressAllContactRel = true;
		}
		Set<Id> accId = new Set<Id>();
		Map<Id, Id> accPrimaryMap = new Map<Id, Id>();
		String objectAPI = objectList[0]
			.Id.getSObjectType()
			.getDescribe()
			.getName();

		if (objectAPI == 'Case') {
			List<Case> caseList = objectList;
			for (Case rec : caseList) {
				accId.add(rec.AccountId);
			}
		} else if (objectAPI == 'Account') {
			List<Account> accountList = objectList;
			for (Account rec : accountList) {
				accId.add(rec.Id);
			}
		} else {
			//do nothing
		}

		List<Contact_Relationship__c> conRelList = [
			SELECT Id, Account__c, Contact__c, Contact__r.email, Role__c
			FROM Contact_Relationship__c
			WHERE
				Account__c IN :accId
				AND Contact__r.email != NULL
				AND Contact__r.email != ''
		];

		Map<Id, String> emailToAccMap = getEmailToAccMap(
			conRelList,
			hasPrimaryMergeField,
			toAddress1PrimaryOnly,
			toAddressPrimaryAll,
			toAddressAllContactRel
		);
		Map<Id, String> emailCCAccMap = getEmailCCAccMap(
			conRelList,
			hasPrimaryMergeField,
			toAddress1PrimaryOnly,
			toAddressPrimaryAll,
			toAddressAllContactRel,
			emailToAccMap
		);

		for (Contact_Relationship__c rec : conRelList) {
			if (
				hasPrimaryMergeField == true &&
				toAddress1PrimaryOnly == true &&
				accPrimaryMap.get(rec.Account__c) == null
			) {
				accPrimaryMap.put(rec.Account__c, rec.Contact__c);
			} else if (
				hasPrimaryMergeField == true &&
				toAddress1PrimaryOnly == false
			) {
				accPrimaryMap.put(rec.Account__c, rec.Contact__c);
			} else {
				//do nothing
			}
		}

		switch on objectAPI {
			when 'Case' {
				clauseForObjectAPICase(
					objectList,
					toAddressVariable,
					emailCCAccMap,
					emailToAccMap,
					templateName,
					accPrimaryMap,
					toAddress,
					ccAddress,
					objectAPI,
					isStandard
				);
			}
			when 'Account' {
				clauseForObjectAPIAccount(
					objectList,
					toAddressVariable,
					emailCCAccMap,
					emailToAccMap,
					templateName,
					accPrimaryMap,
					toAddress,
					ccAddress,
					objectAPI,
					isStandard
				);
			}
			when else {
				//do nothing
			}
		}
	}
	public static void clauseForObjectAPIAccount(
		List<Account> objectList,
		Boolean toAddressVariable,
		Map<Id, String> emailCCAccMap,
		Map<Id, String> emailToAccMap,
		String templateName,
		Map<Id, Id> accPrimaryMap,
		String toAddress,
		String ccAddress,
		String objectAPI,
		Boolean isStandard
	) {
		List<Account> accountList = objectList;
		for (Account rec : accountList) {
			if (toAddressVariable != true) {
				toAddress = emailToAccMap.get(rec.Id);
				ccAddress = emailCCAccMap.get(rec.Id);
			} else {
				//do nothing
			}
			if (isStandard && accPrimaryMap.size() > 0 && toAddress != null) {
				AcfrEmailService.sendStandardSingleEmailMethod(
					rec.Id,
					accPrimaryMap.get(rec.Id),
					templateName,
					toAddress,
					ccAddress
				);
			} else if (toAddress != null) {
				String emailSubject = getEmailSubject(
					rec.Id,
					objectAPI,
					templateName
				);
				String emailBody = getEmailContent(
					rec.Id,
					objectAPI,
					templateName
				);
				sendCustomSingleEmailMethod(
					rec.Id,
					emailBody,
					toAddress,
					ccAddress,
					emailSubject
				);
			} else {
				// do nothing
			}
		}
	}

	public static void clauseForObjectAPICase(
		List<Case> objectList,
		Boolean toAddressVariable,
		Map<Id, String> emailCCAccMap,
		Map<Id, String> emailToAccMap,
		String templateName,
		Map<Id, Id> accPrimaryMap,
		String toAddress,
		String ccAddress,
		String objectAPI,
		Boolean isStandard
	) {
		List<Case> caseList = objectList;
		for (Case rec : caseList) {
			toAddress = '';
			ccAddress = '';
			if (
				toAddressVariable != true &&
				rec.AccountId != null &&
				emailToAccMap.get(rec.AccountId) != null &&
				emailToAccMap.get(rec.AccountId) != ''
			) {
				toAddress = emailToAccMap.get(rec.AccountId);
				ccAddress = emailCCAccMap.get(rec.AccountId);
			}
			if (isStandard && accPrimaryMap.size() > 0 && toAddress != null) {
				AcfrEmailService.sendStandardSingleEmailMethod(
					rec.Id,
					accPrimaryMap.get(rec.AccountId),
					templateName,
					toAddress,
					ccAddress
				);
			} else if (toAddress != null) {
				String emailSubject = getEmailSubject(
					rec.Id,
					objectAPI,
					templateName
				);
				String emailBody = getEmailContent(
					rec.Id,
					objectAPI,
					templateName
				);
				sendCustomSingleEmailMethod(
					rec.Id,
					emailBody,
					toAddress,
					ccAddress,
					emailSubject
				);
			} else {
				//do nothing
			}
		}
	}

	@InvocableMethod(
		label='sendEmailMainInvocable'
		description='sendEmailMainInvocable'
	)
	public static void sendEmailMainInvocable(List<String> invocableVariables) {
		Id recordId;
		Boolean isStandard;
		String templateName;
		List<Sobject> objectList;
		String toAddress;
		String ccAddress;
		Boolean hasPrimaryMergeField;
		Boolean toAddress1PrimaryOnly;
		Boolean toAddressPrimaryAll;
		Boolean toAddressAllContactRel;
		Boolean toAddressVariable;

		for (String var : invocableVariables[0].split(';')) {
			if (var.substringBefore('=') == 'recordId') {
				recordId = var.substringAfter('=');
			} else if (var.substringBefore('=') == 'isStandard') {
				isStandard = Boolean.valueOf(var.substringAfter('='));
			} else if (var.substringBefore('=') == 'templateName') {
				templateName = var.substringAfter('=');
			} else if (var.substringBefore('=') == 'toAddress') {
				toAddress = var.substringAfter('=');
			} else if (var.substringBefore('=') == 'ccAddress') {
				ccAddress = var.substringAfter('=');
			} else if (var.substringBefore('=') == 'hasPrimaryMergeField') {
				hasPrimaryMergeField = Boolean.valueOf(var.substringAfter('='));
			} else if (var.substringBefore('=') == 'toAddress1PrimaryOnly') {
				toAddress1PrimaryOnly = Boolean.valueOf(
					var.substringAfter('=')
				);
			} else if (var.substringBefore('=') == 'toAddressPrimaryAll') {
				toAddressPrimaryAll = Boolean.valueOf(var.substringAfter('='));
			} else if (var.substringBefore('=') == 'toAddressAllContactRel') {
				toAddressAllContactRel = Boolean.valueOf(
					var.substringAfter('=')
				);
			} else if (var.substringBefore('=') == 'toAddressVariable') {
				toAddressVariable = Boolean.valueOf(var.substringAfter('='));
			} else {
				//do nothing
			}
		}

		String objectAPI = recordId.getSObjectType().getDescribe().getName();
		if (objectAPI == 'Case') {
			objectList = [SELECT Id, AccountId FROM Case WHERE Id = :recordId];
		} else if (objectAPI == 'Account') {
			objectList = [SELECT Id FROM Account WHERE Id = :recordId];
		} else {
			//do nothing
		}

		sendEmailMain(
			isStandard,
			templateName,
			objectList,
			toAddress,
			ccAddress,
			hasPrimaryMergeField,
			toAddress1PrimaryOnly,
			toAddressPrimaryAll,
			toAddressAllContactRel,
			toAddressVariable
		);
	}
	public static Messaging.SingleEmailMessage sendCustomMultipleEmailMethod(
		String recordId,
		String emailBody,
		String emailAddress,
		String emailAddressCC,
		String emailSubject
	) {
		List<String> emailAddressList = new List<String>();
		if (emailAddress != '' && emailAddress != null) {
			emailAddress = emailAddress.replaceAll('\\s+', '');
			for (String str : emailAddress.split(';')) {
				if (str != null && str != '') {
					emailAddressList.add(str);
				}
			}
		}

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(emailAddressList);
		if (emailAddressCC != '' && emailAddressCC != null) {
			emailAddressCC = emailAddressCC.replaceAll('\\s+', '');
			List<String> emailAddressCCList = new List<String>();
			for (String str : emailAddressCC.split(';')) {
				if (str != null && str != '') {
					emailAddressCCList.add(str);
				}
			}
			mail.setCcAddresses(emailAddressCCList);
		}
        if (owea.size() > 0 ){
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
		mail.setWhatId(recordId);
		mail.setSubject(emailSubject);
		mail.setBccSender(false);
		mail.setUseSignature(false);
		mail.setHtmlBody(emailBody);
		mail.setSaveAsActivity(true);

		return mail;
	}
}