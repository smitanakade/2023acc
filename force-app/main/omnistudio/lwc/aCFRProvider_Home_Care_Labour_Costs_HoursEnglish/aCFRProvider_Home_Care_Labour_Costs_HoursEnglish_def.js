export const OMNIDEF = {
	userTimeZone: 600,
	userProfile: "System Administrator",
	userName: "chris.a.yap@health.gov.au.r3dev",
	userId: "005Bm000001otX0IAI",
	userCurrencyCode: "AUD",
	timeStamp: "2023-05-29T12:11:27.330Z",
	sOmniScriptId: "0jNBm0000003ZZ7MAM",
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
	lwcId: "b74c9451-b837-9655-0d84-cf0a95d29bc1",
	labelMap: {
		HomeCareLabourCostsAndHoursDT:
			"STHomeCareLabourCostsAndHours:HomeCareLabourCostsAndHoursDT",
		Home_Care_Labour_Costs_Hours_About:
			"STHomeCareLabourCostsAndHours:Home_Care_Labour_Costs_Hours_About",
		ReasonsForReissuance: "STHomeCareLabourCostsAndHours:ReasonsForReissuance",
		TextBlock1: "STHomeCareLabourCostsAndHours:TextBlock1",
		HomeCostsAndHoursErrorMessage:
			"STHomeCareLabourCostsAndHours:HomeCostsAndHoursErrorMessage",
		ReportHeader: "STHomeCareLabourCostsAndHours:ReportHeader",
		DoNothing: "DoNothing",
		STHomeCareLabourCostsAndHours: "STHomeCareLabourCostsAndHours",
		SetOutcomeVal: "SetOutcomeVal"
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
				label: "SetOutcomeVal",
				elementValueMap: {
					HomeCareLabourCostsandHours_QAOutcome:
						'=IF(%GetFormData_DR:HomeCareLabourCostsandHours:QA_Outcome__c%=="Re-Issue", true, false)'
				},
				controlWidth: 12,
				HTMLTemplateId: "",
				aggElements: {}
			},
			offSet: 0,
			name: "SetOutcomeVal",
			level: 0,
			indexInParent: 0,
			bHasAttachment: false,
			bEmbed: false,
			bSetValues: true,
			JSONPath: "SetOutcomeVal",
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
				previousWidth: 3,
				previousLabel: "Previous",
				nextWidth: 0,
				nextLabel: "Next",
				message: { qfr_navigate_next: "true" },
				lwcComponentOverride: "omniscriptStepCustom",
				label: "",
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
				chartLabel: "Home Care Labour Costs and Hours",
				cancelMessage: "Are you sure?",
				cancelLabel: "Cancel",
				businessEvent: "",
				businessCategory: "",
				allowSaveForLater: true,
				HTMLTemplateId: "",
				uiElements: { STHomeCareLabourCostsAndHours: "" },
				aggElements: {
					ReportHeader: "",
					HomeCostsAndHoursErrorMessage: "",
					ReasonsForReissuance: "",
					Home_Care_Labour_Costs_Hours_About: "",
					HomeCareLabourCostsAndHoursDT: ""
				}
			},
			offSet: 0,
			name: "STHomeCareLabourCostsAndHours",
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
							JSONPath: "STHomeCareLabourCostsAndHours:ReportHeader",
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
												field: "STHomeCareLabourCostsAndHoursIsComplete",
												condition: "=",
												data: "false"
											}
										],
										operator: "AND"
									}
								},
								label: "HomeCostsAndHoursErrorMessage",
								controlWidth: 12
							},
							name: "HomeCostsAndHoursErrorMessage",
							level: 1,
							JSONPath:
								"STHomeCareLabourCostsAndHours:HomeCostsAndHoursErrorMessage",
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
								text: "<h1>Home Care Labour Costs and Hours</h1>",
								show: null,
								sanitize: false,
								label: "TextBlock1",
								dataJSON: false,
								controlWidth: 12,
								HTMLTemplateId: ""
							},
							name: "TextBlock1",
							level: 1,
							JSONPath: "STHomeCareLabourCostsAndHours:TextBlock1",
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
										source: "%GetFormData_DR:HomeCareLabourCostsandHours:Id%",
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
												field: "HomeCareLabourCostsandHours_QAOutcome",
												condition: "=",
												data: "true"
											}
										],
										operator: "AND"
									}
								},
								label: "ReasonsForReissuance",
								controlWidth: 12
							},
							name: "ReasonsForReissuance",
							level: 1,
							JSONPath: "STHomeCareLabourCostsAndHours:ReasonsForReissuance",
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
								lwcName: "cfACFR_AboutProviderHomeCareLabourCostsHours",
								label: "Home Care Labour Costs and Hours About",
								hide: false,
								customAttributes: [
									{ source: "%GetFormData_DR:Case:Case__c%", name: "record-id" }
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "Home_Care_Labour_Costs_Hours_About",
							level: 1,
							JSONPath:
								"STHomeCareLabourCostsAndHours:Home_Care_Labour_Costs_Hours_About",
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
								label: "Home Care Labour Costs and Hours Datatable",
								hide: false,
								customAttributes: [
									{
										source: "%HomeCareLabourCostsandHoursFormId%",
										name: "record-id"
									}
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "HomeCareLabourCostsAndHoursDT",
							level: 1,
							JSONPath:
								"STHomeCareLabourCostsAndHours:HomeCareLabourCostsAndHoursDT",
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
			JSONPath: "STHomeCareLabourCostsAndHours",
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
	bpVersion: 16,
	bpType: "ACFR",
	bpSubType: "Provider_Home_Care_Labour_Costs_Hours",
	bpLang: "English",
	bHasAttachment: false,
	lwcVarMap: {
		caseRecordId: null,
		GetFormData_DR: {
			HomeCareLabourCostsandHours: { Id: null },
			Case: { Case__c: null }
		},
		HomeCareLabourCostsandHoursFormId: null
	}
};
