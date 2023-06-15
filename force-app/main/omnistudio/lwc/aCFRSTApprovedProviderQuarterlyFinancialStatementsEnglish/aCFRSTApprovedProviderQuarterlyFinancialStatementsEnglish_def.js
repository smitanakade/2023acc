export const OMNIDEF = {
	userTimeZone: 600,
	userProfile: "System Administrator",
	userName: "chris.a.yap@health.gov.au.r3dev",
	userId: "005Bm000001otX0IAI",
	userCurrencyCode: "AUD",
	timeStamp: "2023-05-29T12:22:15.085Z",
	sOmniScriptId: "0jNBm0000003ZHNMA2",
	sobjPL: {},
	RPBundle: "",
	rMap: {},
	response: null,
	propSetMap: {
		wpm: false,
		visualforcePagesAvailableInPreview: {},
		trackingCustomData: {},
		timeTracking: false,
		stylesheet: {
			newportRtl: "",
			newport: "",
			lightningRtl: "",
			lightning: ""
		},
		stepChartPlacement: "right",
		ssm: false,
		showInputWidth: false,
		seedDataJSON: {},
		scrollBehavior: "auto",
		saveURLPatterns: {},
		saveObjectId: "%ContextId%",
		saveNameTemplate: null,
		saveForLaterRedirectTemplateUrl: "vlcSaveForLaterAcknowledge.html",
		saveForLaterRedirectPageName: "sflRedirect",
		saveExpireInDays: null,
		saveContentEncoded: false,
		rtpSeed: false,
		pubsub: false,
		persistentComponent: [
			{
				sendJSONPath: "",
				sendJSONNode: "",
				responseJSONPath: "",
				responseJSONNode: "",
				render: false,
				remoteTimeout: 30000,
				remoteOptions: { preTransformBundle: "", postTransformBundle: "" },
				remoteMethod: "",
				remoteClass: "",
				preTransformBundle: "",
				postTransformBundle: "",
				modalConfigurationSetting: {
					modalSize: "lg",
					modalHTMLTemplateId: "vlcProductConfig.html",
					modalController: "ModalProductCtrl"
				},
				label: "",
				itemsKey: "cartItems",
				id: "vlcCart"
			},
			{
				render: false,
				remoteTimeout: 30000,
				remoteOptions: { preTransformBundle: "", postTransformBundle: "" },
				remoteMethod: "",
				remoteClass: "",
				preTransformBundle: "",
				postTransformBundle: "",
				modalConfigurationSetting: {
					modalSize: "lg",
					modalHTMLTemplateId: "",
					modalController: ""
				},
				label: "",
				itemsKey: "knowledgeItems",
				id: "vlcKnowledge",
				dispOutsideOmni: false
			}
		],
		message: {},
		mergeSavedData: false,
		lkObjName: null,
		knowledgeArticleTypeQueryFieldsMap: {},
		hideStepChart: true,
		errorMessage: { custom: [] },
		enableKnowledge: false,
		elementTypeToHTMLTemplateMapping: {},
		disableUnloadWarn: true,
		currentLanguage: "en_US",
		currencyCode: "",
		consoleTabTitle: null,
		consoleTabLabel: "New",
		consoleTabIcon: "custom:custom18",
		cancelType: "SObject",
		cancelSource: "%ContextId%",
		cancelRedirectTemplateUrl: "vlcCancelled.html",
		cancelRedirectPageName: "OmniScriptCancelled",
		bLK: false,
		autoSaveOnStepNext: false,
		autoFocus: false,
		allowSaveForLater: false,
		allowCancel: false
	},
	prefillJSON: "{}",
	lwcId: "b36d7eb1-cbba-90ab-9940-0c1c5bee575e",
	labelMap: {
		ApprovedProviderQFRStatements:
			"STApprovedProviderQuarterlyFinancialStatements:ApprovedProviderQFRStatements",
		CFR_ApprovedProviderQFRAboutSection:
			"STApprovedProviderQuarterlyFinancialStatements:CFR_ApprovedProviderQFRAboutSection",
		QFRReasonsForReissuance:
			"STApprovedProviderQuarterlyFinancialStatements:QFRReasonsForReissuance",
		TextBlock1: "STApprovedProviderQuarterlyFinancialStatements:TextBlock1",
		QFRErrorMessage:
			"STApprovedProviderQuarterlyFinancialStatements:QFRErrorMessage",
		ReportHeader: "STApprovedProviderQuarterlyFinancialStatements:ReportHeader",
		DoNothing: "DoNothing",
		STApprovedProviderQuarterlyFinancialStatements:
			"STApprovedProviderQuarterlyFinancialStatements",
		SetFormId: "SetFormId"
	},
	labelKeyMap: {},
	errorMsg: "",
	error: "OK",
	dMap: {},
	depSOPL: {},
	depCusPL: {},
	cusPL: {},
	children: [
		{
			type: "Set Values",
			propSetMap: {
				wpm: false,
				ssm: false,
				showPersistentComponent: [true, false],
				show: null,
				pubsub: false,
				message: {},
				label: "SetFormId",
				elementValueMap: {
					formId: "=%ApprovedProviderQuarterlyFinancialStatementsFormId%",
					ApprovedProvider_QAOutcome:
						'=IF(%GetFormData_DR:ApprovedProviderQuarterlyFinancialStatements:QA_Outcome__c%=="Re-Issue", true, false)'
				},
				controlWidth: 12,
				HTMLTemplateId: "",
				aggElements: {}
			},
			offSet: 0,
			name: "SetFormId",
			level: 0,
			indexInParent: 0,
			bHasAttachment: false,
			bEmbed: false,
			bSetValues: true,
			JSONPath: "SetFormId",
			lwcId: "lwc0"
		},
		{
			type: "Step",
			propSetMap: {
				wpm: false,
				validationRequired: true,
				ssm: false,
				showPersistentComponent: [true, false],
				show: null,
				saveMessage: "Are you sure you want to save it for later?",
				saveLabel: "Save for later",
				remoteTimeout: 30000,
				remoteOptions: {},
				remoteMethod: "",
				remoteClass: "",
				pubsub: true,
				previousWidth: 0,
				previousLabel: "Previous",
				nextWidth: 0,
				nextLabel: "Next",
				message: { qfr_navigate_next: "true" },
				lwcComponentOverride: "omniscriptStepCustom",
				label: "Approved Provider Quarterly Financial Statements",
				knowledgeOptions: {
					typeFilter: "",
					remoteTimeout: 30000,
					publishStatus: "Online",
					language: "English",
					keyword: "",
					dataCategoryCriteria: ""
				},
				instructionKey: "",
				instruction: "",
				errorMessage: { default: null, custom: [] },
				conditionType: "Hide if False",
				completeMessage: "Are you sure you want to complete the script?",
				completeLabel: "Complete",
				chartLabel: "Approved Provider Quarterly Financial Statements",
				cancelMessage: "Are you sure?",
				cancelLabel: "Cancel",
				businessEvent: "",
				businessCategory: "",
				allowSaveForLater: false,
				HTMLTemplateId: "",
				uiElements: { STApprovedProviderQuarterlyFinancialStatements: "" },
				aggElements: {
					ReportHeader: "",
					QFRErrorMessage: "",
					QFRReasonsForReissuance: "",
					CFR_ApprovedProviderQFRAboutSection: "",
					ApprovedProviderQFRStatements: ""
				}
			},
			offSet: 0,
			name: "STApprovedProviderQuarterlyFinancialStatements",
			level: 0,
			indexInParent: 1,
			bHasAttachment: false,
			bEmbed: false,
			response: null,
			inheritShowProp: null,
			children: [
				{
					response: null,
					level: 1,
					indexInParent: 0,
					eleArray: [
						{
							type: "Custom Lightning Web Component",
							rootIndex: 1,
							response: null,
							propSetMap: {
								show: null,
								lwcName: "cfACFR_Report_Header_Download_Report",
								label: "ReportHeader",
								hide: false,
								customAttributes: [
									{ source: "%caseRecordId%", name: "record-id" }
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "ReportHeader",
							level: 1,
							JSONPath:
								"STApprovedProviderQuarterlyFinancialStatements:ReportHeader",
							indexInParent: 0,
							index: 0,
							children: [],
							bHasAttachment: false,
							bcustomlightningwebcomponent1: true,
							lwcId: "lwc10-0"
						}
					],
					bHasAttachment: false
				},
				{
					response: null,
					level: 1,
					indexInParent: 1,
					eleArray: [
						{
							type: "Custom Lightning Web Component",
							rootIndex: 1,
							response: null,
							propSetMap: {
								customAttributes: [
									{ source: "There are errors in this section", name: "title" },
									{
										source:
											"Click on the ‘Errors Only’ button below to view all errors",
										name: "value"
									},
									{ source: "error", name: "variant" }
								],
								bStandalone: false,
								lwcName: "qfrNotification",
								hide: false,
								conditionType: "Hide if False",
								show: {
									group: {
										rules: [
											{
												field:
													"STApprovedProviderQuarterlyFinancialStatementsIsComplete",
												condition: "=",
												data: "false"
											}
										],
										operator: "AND"
									}
								},
								label: "QFRErrorMessage",
								controlWidth: 12
							},
							name: "QFRErrorMessage",
							level: 1,
							JSONPath:
								"STApprovedProviderQuarterlyFinancialStatements:QFRErrorMessage",
							indexInParent: 1,
							index: 0,
							children: [],
							bHasAttachment: false,
							bcustomlightningwebcomponent2: true,
							lwcId: "lwc11-0"
						}
					],
					bHasAttachment: false
				},
				{
					response: null,
					level: 1,
					indexInParent: 2,
					eleArray: [
						{
							type: "Text Block",
							rootIndex: 1,
							response: null,
							propSetMap: {
								textKey: "",
								text: "<h1>Approved Provider Quarterly Financial Statements</h1>",
								show: null,
								sanitize: false,
								label: "TextBlock1",
								dataJSON: false,
								controlWidth: 12,
								HTMLTemplateId: ""
							},
							name: "TextBlock1",
							level: 1,
							JSONPath:
								"STApprovedProviderQuarterlyFinancialStatements:TextBlock1",
							indexInParent: 2,
							index: 0,
							children: [],
							bHasAttachment: false,
							bTextBlock: true,
							lwcId: "lwc12-0"
						}
					],
					bHasAttachment: false
				},
				{
					response: null,
					level: 1,
					indexInParent: 3,
					eleArray: [
						{
							type: "Custom Lightning Web Component",
							rootIndex: 1,
							response: null,
							propSetMap: {
								customAttributes: [
									{
										source:
											"%GetFormData_DR:ApprovedProviderQuarterlyFinancialStatements:QA_Comments__c%",
										name: "form-reason"
									},
									{
										source:
											"%GetFormData_DR:ApprovedProviderQuarterlyFinancialStatements:Id%",
										name: "record-id"
									}
								],
								bStandalone: false,
								lwcName: "qfrReasonsForReissuance",
								hide: false,
								conditionType: "Hide if False",
								show: {
									group: {
										rules: [
											{
												field: "ApprovedProvider_QAOutcome",
												condition: "=",
												data: "true"
											}
										],
										operator: "AND"
									}
								},
								label: "QFRReasonsForReissuance",
								controlWidth: 12
							},
							name: "QFRReasonsForReissuance",
							level: 1,
							JSONPath:
								"STApprovedProviderQuarterlyFinancialStatements:QFRReasonsForReissuance",
							indexInParent: 3,
							index: 0,
							children: [],
							bHasAttachment: false,
							bcustomlightningwebcomponent3: true,
							lwcId: "lwc13-0"
						}
					],
					bHasAttachment: false
				},
				{
					response: null,
					level: 1,
					indexInParent: 4,
					eleArray: [
						{
							type: "Custom Lightning Web Component",
							rootIndex: 1,
							response: null,
							propSetMap: {
								show: null,
								lwcName: "cfACFR_ApprovedProviderQFRAbout",
								label: "CFR_ApprovedProviderQFRAboutSection",
								hide: false,
								customAttributes: [
									{ source: "%GetFormData_DR:Case:Case__c%", name: "record-id" }
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "CFR_ApprovedProviderQFRAboutSection",
							level: 1,
							JSONPath:
								"STApprovedProviderQuarterlyFinancialStatements:CFR_ApprovedProviderQFRAboutSection",
							indexInParent: 4,
							index: 0,
							children: [],
							bHasAttachment: false,
							bcustomlightningwebcomponent4: true,
							lwcId: "lwc14-0"
						}
					],
					bHasAttachment: false
				},
				{
					response: null,
					level: 1,
					indexInParent: 5,
					eleArray: [
						{
							type: "Custom Lightning Web Component",
							rootIndex: 1,
							response: null,
							propSetMap: {
								show: null,
								lwcName: "omniProviderDatatable",
								label: "ApprovedProviderQFRStatements",
								hide: false,
								customAttributes: [
									{ source: "true", name: "show-toggles" },
									{
										source:
											"%ApprovedProviderQuarterlyFinancialStatementsFormId%",
										name: "record-id"
									}
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "ApprovedProviderQFRStatements",
							level: 1,
							JSONPath:
								"STApprovedProviderQuarterlyFinancialStatements:ApprovedProviderQFRStatements",
							indexInParent: 5,
							index: 0,
							children: [],
							bHasAttachment: false,
							bcustomlightningwebcomponent5: true,
							lwcId: "lwc15-0"
						}
					],
					bHasAttachment: false
				}
			],
			bAccordionOpen: false,
			bAccordionActive: false,
			bOmniscriptStepCustom: true,
			isStep: true,
			JSONPath: "STApprovedProviderQuarterlyFinancialStatements",
			lwcId: "lwc1"
		},
		{
			type: "Set Values",
			propSetMap: {
				wpm: false,
				ssm: false,
				showPersistentComponent: [true, false],
				show: null,
				pubsub: true,
				message: { qfr_navigate_next: true },
				label: "DoNothing",
				elementValueMap: {},
				controlWidth: 12,
				HTMLTemplateId: "",
				aggElements: {}
			},
			offSet: 0,
			name: "DoNothing",
			level: 0,
			indexInParent: 2,
			bHasAttachment: false,
			bEmbed: false,
			bSetValues: true,
			JSONPath: "DoNothing",
			lwcId: "lwc2"
		}
	],
	bReusable: true,
	bpVersion: 19,
	bpType: "ACFR",
	bpSubType: "STApprovedProviderQuarterlyFinancialStatements",
	bpLang: "English",
	bHasAttachment: false,
	lwcVarMap: {
		caseRecordId: null,
		GetFormData_DR: {
			ApprovedProviderQuarterlyFinancialStatements: {
				QA_Comments__c: null,
				Id: null
			},
			Case: { Case__c: null }
		},
		ApprovedProviderQuarterlyFinancialStatementsFormId: null
	}
};
