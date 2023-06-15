export const OMNIDEF = {
	userTimeZone: 600,
	userProfile: "System Administrator",
	userName: "chris.a.yap@health.gov.au.r3dev",
	userId: "005Bm000001otX0IAI",
	userCurrencyCode: "AUD",
	timeStamp: "2023-05-29T12:19:04.362Z",
	sOmniScriptId: "0jNBm0000003ZXVMA2",
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
	lwcId: "e7c716b9-83b5-72d0-3f28-f164c6a55270",
	labelMap: {
		ResiCareLabourCostAndHoursDT:
			"STResidentialLabourCostsandHours:ResiCareLabourCostAndHoursDT",
		cfACFR_ResidentialLabourCostHoursAboutSection:
			"STResidentialLabourCostsandHours:cfACFR_ResidentialLabourCostHoursAboutSection",
		ReasonsForReissuance:
			"STResidentialLabourCostsandHours:ReasonsForReissuance",
		TextBlock1: "STResidentialLabourCostsandHours:TextBlock1",
		ResiCostAndHoursErrorMessage:
			"STResidentialLabourCostsandHours:ResiCostAndHoursErrorMessage",
		ReportHeader: "STResidentialLabourCostsandHours:ReportHeader",
		DoNothing: "DoNothing",
		STResidentialLabourCostsandHours: "STResidentialLabourCostsandHours",
		SetValuesQAOutcome: "SetValuesQAOutcome"
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
				label: "SetValuesQAOutcome",
				elementValueMap: {
					ResiCareLabourCostAndHours_QAOutcome:
						'=IF(%GetFormData_DR:ResidentialLabourCostsandHours:QA_Outcome__c%=="Re-Issue", true, false)'
				},
				controlWidth: 12,
				HTMLTemplateId: "",
				aggElements: {}
			},
			offSet: 0,
			name: "SetValuesQAOutcome",
			level: 0,
			indexInParent: 0,
			bHasAttachment: false,
			bEmbed: false,
			bSetValues: true,
			JSONPath: "SetValuesQAOutcome",
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
				chartLabel: "Residential Labour Costs and Hours",
				cancelMessage: "Are you sure?",
				cancelLabel: "Cancel",
				businessEvent: "",
				businessCategory: "",
				allowSaveForLater: false,
				HTMLTemplateId: "",
				uiElements: { STResidentialLabourCostsandHours: "" },
				aggElements: {
					ReportHeader: "",
					ResiCostAndHoursErrorMessage: "",
					ReasonsForReissuance: "",
					cfACFR_ResidentialLabourCostHoursAboutSection: "",
					ResiCareLabourCostAndHoursDT: ""
				}
			},
			offSet: 0,
			name: "STResidentialLabourCostsandHours",
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
							JSONPath: "STResidentialLabourCostsandHours:ReportHeader",
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
												field: "STResidentialLabourCostsandHoursIsComplete",
												condition: "=",
												data: "false"
											}
										],
										operator: "AND"
									}
								},
								label: "ResiCostAndHoursErrorMessage",
								controlWidth: 12
							},
							name: "ResiCostAndHoursErrorMessage",
							level: 1,
							JSONPath:
								"STResidentialLabourCostsandHours:ResiCostAndHoursErrorMessage",
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
								text: "<h1>Residential Labour Costs and Hours</h1>",
								show: null,
								sanitize: false,
								label: "TextBlock1",
								dataJSON: false,
								controlWidth: 12,
								HTMLTemplateId: ""
							},
							name: "TextBlock1",
							level: 1,
							JSONPath: "STResidentialLabourCostsandHours:TextBlock1",
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
											"%GetFormData_DR:ResidentialLabourCostsandHours:Id%",
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
												field: "ResiCareLabourCostAndHours_QAOutcome",
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
							JSONPath: "STResidentialLabourCostsandHours:ReasonsForReissuance",
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
								lwcName: "cfACFR_AboutProviderResiLabourCostsHours",
								label: "CustomLWC1",
								hide: false,
								customAttributes: [
									{ source: "%GetFormData_DR:Case:Case__c%", name: "record-id" }
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "cfACFR_ResidentialLabourCostHoursAboutSection",
							level: 1,
							JSONPath:
								"STResidentialLabourCostsandHours:cfACFR_ResidentialLabourCostHoursAboutSection",
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
								label: "ResiCareLabourCostAndHoursDT",
								hide: false,
								customAttributes: [
									{
										source:
											"%GetFormData_DR:ResidentialLabourCostsandHours:Id%",
										name: "record-id"
									}
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "ResiCareLabourCostAndHoursDT",
							level: 1,
							JSONPath:
								"STResidentialLabourCostsandHours:ResiCareLabourCostAndHoursDT",
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
			JSONPath: "STResidentialLabourCostsandHours",
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
				label: "True",
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
	bpVersion: 15,
	bpType: "ACFR",
	bpSubType: "STResidentialLabourCostsandHours",
	bpLang: "English",
	bHasAttachment: false,
	lwcVarMap: {
		caseRecordId: null,
		GetFormData_DR: {
			ResidentialLabourCostsandHours: { Id: null },
			Case: { Case__c: null }
		}
	}
};
