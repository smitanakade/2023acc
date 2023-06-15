@isTest
public class QFRLWCDownloadControllerTest {
	@TestSetup
	static void setup() {
		User testUser = TestDataFactory.createSystemAdminUser();
		System.runAs(testUser) {
			List<BusinessLicense> services = new List<BusinessLicense>();
			for (Integer i = 0; i < 5; i++) {
				services.add(
					new BusinessLicense(
						Name = 'Test Service ' + i,
						Effective_Date__c = Date.today(),
						Status_Date__c = Date.today(),
						Care_Type__c = 'Residential',
						Status = 'Approved'
					)
				);
			}

			services.add(
				new BusinessLicense(
					Name = 'Total',
					Effective_Date__c = Date.today(),
					Status_Date__c = Date.today(),
					Care_Type__c = 'Residential',
					Status = 'Approved'
				)
			);
			insert services;

			Account acc = TestDataFactory.createProviderRecords(1)[0]; // create one, get first entry
			insert acc;

			Contact con1 = new Contact(
				FirstName = '2',
				LastName = 'Test',
				Salutation = 'Ms',
				Email = 'test@gmail.com'
			);
			insert con1;

			Contact_Relationship__c cr1 = new Contact_Relationship__c(
				Account__c = acc.Id,
				Contact__c = con1.Id,
				Role__c = 'QFR Primary Contact'
			);
			insert cr1;

			Case tc = new Case(
				AccountId = acc.Id,
				Status = 'Submitted',
				RecordTypeId = [
					SELECT Id
					FROM RecordType
					WHERE SObjectType = 'Case' AND DeveloperName = 'QFR'
					LIMIT 1
				]
				.Id
			);
			insert tc;

			Form__c viability = new Form__c(
				Type__c = 'Residential Viability and Prudential Reporting',
				Account__c = acc.Id,
				Case__c = tc.Id,
				QA_Comments__c = 'None',
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			insert viability;

			Response__c response = new Response__c(
				Response_Options__c = 'Yes',
				Additional_Information__c = 'Test class response',
				Form__c = viability.Id
			);
			insert response;

			Form__c form = new Form__c(
				Type__c = 'Home Care Labour Costs and Hours',
				Account__c = acc.Id,
				Case__c = tc.Id,
				QA_Comments__c = 'None',
				RecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName()
					.get('QFR')
					.getRecordTypeId()
			);
			insert form;

			List<GL_Code__c> testGLCodes = new List<GL_Code__c>();
			testGLCodes.add(
				new GL_Code__c(
					Name = 'Test GL',
					Type__c = 'Home Care Labour Costs and Hours',
					Display_Order__c = 0,
					Line_Item_Value_Type__c = 'Numeric'
				)
			);
			testGLCodes.add(
				new GL_Code__c(
					Name = 'Test GL 2',
					Type__c = 'Residential Labour Costs and Hours',
					Display_Order__c = 0,
					Line_Item_Value_Type__c = 'Numeric'
				)
			);
			insert testGLCodes;
			insert new List<Service_Line_Item__c>{
				new Service_Line_Item__c(
					Service__c = services[0].Id,
					Form__c = form.Id
				),
				new Service_Line_Item__c(
					Service__c = services[services.size() - 1].Id, // add Total Service Line Item
					Form__c = form.Id
				)
			};
		}
	}

	@isTest
	static void it_get_forms_for_case() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;

		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [SELECT Id FROM Form__c];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		update forms;

		List<QFRLWCDownloadController.FormDownloadDetail> result = new List<QFRLWCDownloadController.FormDownloadDetail>();

		Test.startTest();
		System.runAs(healthUser) {
			result = QFRLWCDownloadController.getFormIdsForCase(caseId);
		}
		Test.stopTest();

		System.assertEquals(2, result.size());
	}

	@isTest
	static void it_get_response_for_viability() {
		Id formId = [
			SELECT Id
			FROM Form__c
			WHERE Type__c = 'Residential Viability and Prudential Reporting'
		]
		.Id;

		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();
		List<Form__c> forms = [SELECT Id FROM Form__c];
		for (Form__c form : forms) {
			form.OwnerId = healthUser.Id;
		}
		update forms;

		List<QFRLWCDownloadController.ViabilityResponse> result = new List<QFRLWCDownloadController.ViabilityResponse>();

		Test.startTest();
		System.runAs(healthUser) {
			result = QFRLWCDownloadController.getViabilityResponses(formId);
		}
		Test.stopTest();

		System.assertEquals(
			'Test class response',
			result[0].additionalInformation
		);
		System.assertEquals('Yes', result[0].response);
	}

	@isTest
	static void it_save_a_file() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;
		String fileName = 'UploadExcel.xlsx';
		String fileData = 'String to convert to base64 encoding.';
		String base64File = EncodingUtil.base64Encode(Blob.valueOf(fileData));

		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		Test.startTest();
		System.runAs(healthUser) {
			QFRLWCDownloadController.saveExcelFile(
				caseId,
				base64File,
				fileName
			);
		}
		Test.stopTest();

		String contentDocTitle = [
			SELECT ContentDocument.Title
			FROM ContentDocumentLink
			WHERE
				LinkedEntityId = :caseId
				AND ContentDocument.FileExtension = 'xlsx'
			ORDER BY ContentDocument.LastModifiedDate DESC
			LIMIT 1
		]
		.ContentDocument.Title;

		String contentDocType = [
			SELECT ContentDocument.FileType
			FROM ContentDocumentLink
			WHERE
				LinkedEntityId = :caseId
				AND ContentDocument.FileExtension = 'xlsx'
			ORDER BY ContentDocument.LastModifiedDate DESC
			LIMIT 1
		]
		.ContentDocument.FileType;

		System.assertEquals('UploadExcel', contentDocTitle);
		System.assertEquals('EXCEL_X', contentDocType);
	}

	@isTest
	static void it_load_a_file() {
		Id caseId = [SELECT Id FROM Case WHERE Status = 'Submitted' LIMIT 1].Id;

		String fileName = 'UploadExcel.xlsx';
		String fileData = 'String to convert to base64 encoding.';
		String base64File = EncodingUtil.base64Encode(Blob.valueOf(fileData));
		Blob contentBody = EncodingUtil.base64Decode(base64File);
		ContentVersion cv = new ContentVersion(
			ContentLocation = 'S',
			FirstPublishLocationId = caseId,
			PathOnClient = fileName,
			VersionData = contentBody
		);

		DMLImpl dmlinsert = new DMLImpl();
		dmlinsert.InsertRecord(cv);

		Id contentDocId = [
			SELECT ContentDocumentId
			FROM ContentVersion
			WHERE id = :cv.id
		]
		.ContentDocumentId;

		TestUserBuilder healthUserBuilder = QFRTestDataFactory.getHealthProviderBuilder();
		User healthUser = healthUserBuilder.createUser();

		dohagedcare.FilePreviewUtility.PreviewResponseWrapper result = new dohagedcare.FilePreviewUtility.PreviewResponseWrapper();

		Test.startTest();
		System.runAs(healthUser) {
			result = QFRLWCDownloadController.loadExcelFile(caseId);
		}
		Test.stopTest();

		System.assertEquals(contentDocId, result.ContentDocumentId);
	}
}
