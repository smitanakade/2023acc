/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class ACFRGetViabilityResponse implements Callable {
	public static List<Map<String, Question>> getResponse(Id formId) {
		// Set the Form record ID

		List<Map<String, Question>> questionList = new List<Map<String, Question>>();

		try {
			for (Response__c res : [
				SELECT
					Form__c,
					Question_library__r.ql_dm_key__c,
					Response_options__c,
					Additional_information__c,
					Care_or_services__c,
					Other_Care_Services__c,
					Other_Business_Structure__c,
					QA_Comments__c
				FROM Response__c
				WHERE Form__c = :formId
				LIMIT 50000
			]) {
				if (res.Question_library__r.ql_dm_key__c != null) {
					Map<String, Question> questionMap = new Map<String, Question>();
					Question question = new Question();
					if (res.Question_library__r.ql_dm_key__c.contains('BSS')) {
						question.businessStructureOption = (res.Response_options__c ==
							'Yes')
							? true
							: false;
					} else {
						question.responseOption = res.Response_options__c;
					}
					question.additionalInformation = res.Additional_information__c;
					question.qlDmKey = res.Question_library__r.ql_dm_key__c;
					question.otherCareOfService = res.Other_Care_Services__c;
					question.otherBusinessStructure = res.Other_Business_Structure__c;
					question.qaExtComments = res.QA_Comments__c;

					if (res.Care_or_services__c != null) {
						CareOfService careOfService = new CareOfService();
						for (String care : res.Care_or_services__c.split(';')) {
							switch on care {
								when 'Clinical Care' {
									careOfService.clinicalCare = true;
								}
								when 'Personal Care' {
									careOfService.personalCare = true;
								}
								when 'Allied Health' {
									careOfService.alliedHealth = true;
								}
								when 'Other' {
									careOfService.other = true;
								}
								when 'Diversional Therapy' {
									careOfService.diversionalTherapy = true;
								}
								when else {
									System.debug('care of Service:' + care);
									System.debug(
										'contains lifestyle:' +
										care.contains('Lifestyle')
									);
									if (care.contains('Lifestyle')) {
										careOfService.lifeStyleRecreationOfficer = true;
									}
								}
							}
						}
						question.CareOfService = careOfService;
					}
					questionMap.put(question.qlDmKey, question);
					questionList.add(questionMap);
				}
			}
		} catch (QueryException e) {
			System.debug('Error querying Form: ' + e.getMessage());
		}
		return questionList;
	}

	public Object call(string action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		switch on action {
			when 'getResponse' {
				List<Map<String, Question>> response = getResponse(
					(String) input.get('FormId')
				);
				output.put('response', response);
				system.debug(output);
				return true;
			}
			when else {
				throw new ExtensionMalformedException('Method not implemented');
			}
		}
	}
	public class ExtensionMalformedException extends Exception {
	}

	@JsonAccess(serializable='always' deserializable='always')
	public class Question {
		public Boolean businessStructureOption;
		public string responseOption;
		public string additionalInformation;
		public string qlDmKey;
		public string otherCareOfService;
		public string otherBusinessStructure;
		public string qaExtComments;
		public CareOfService careOfService;
	}
	@JsonAccess(serializable='always' deserializable='always')
	public class CareOfService {
		public Boolean clinicalCare;
		public Boolean personalCare;
		public Boolean alliedHealth;
		public Boolean diversionalTherapy;
		public Boolean lifeStyleRecreationOfficer;
		public Boolean other;
	}
}
