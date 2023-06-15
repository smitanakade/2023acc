export const OMNIDEF = {
	userTimeZone: 600,
	userProfile: "System Administrator",
	userName: "cristina.joya@health.gov.au.r3dev",
	userId: "005Bm000001YYIXIA4",
	userCurrencyCode: "AUD",
	timeStamp: "2023-05-29T05:35:30.706Z",
	sOmniScriptId: "0jNBm0000003ZdxMAE",
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
	lwcId: "887a9cba-3728-44a8-4442-d597fcc4f34e",
	labelMap: {
		CustomLWC2: "NATSIFACPFoodandNutritionReporting:CustomLWC2",
		FoodNutritionAboutSection:
			"NATSIFACPFoodandNutritionReporting:FoodNutritionAboutSection",
		ReasonsForReissuance:
			"NATSIFACPFoodandNutritionReporting:ReasonsForReissuance",
		TextBlock1: "NATSIFACPFoodandNutritionReporting:TextBlock1",
		FoodNutritionErrorMessage:
			"NATSIFACPFoodandNutritionReporting:FoodNutritionErrorMessage",
		ReportHeader: "NATSIFACPFoodandNutritionReporting:ReportHeader",
		DoNothing: "DoNothing",
		NATSIFACPFoodandNutritionReporting: "NATSIFACPFoodandNutritionReporting",
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
					NATSIFACPFoodandNutrition_QAOutcome:
						'IF(%GetFormData_DR:NATSIFACPFoodandNutritionReporting:QA_Outcome__c%=="Re-Issue",true,false)'
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
				previousWidth: 0,
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
				chartLabel: "NATSIFACP Food and Nutrition Reporting",
				cancelMessage: "Are you sure?",
				cancelLabel: "Cancel",
				businessEvent: "",
				businessCategory: "",
				allowSaveForLater: true,
				HTMLTemplateId: "",
				uiElements: { NATSIFACPFoodandNutritionReporting: "" },
				aggElements: {
					ReportHeader: "",
					FoodNutritionErrorMessage: "",
					ReasonsForReissuance: "",
					FoodNutritionAboutSection: "",
					CustomLWC2: ""
				}
			},
			offSet: 0,
			name: "NATSIFACPFoodandNutritionReporting",
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
							JSONPath: "NATSIFACPFoodandNutritionReporting:ReportHeader",
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
								show: {
									group: {
										rules: [
											{
												field: "NATSIFACPFoodandNutritionReportingIsComplete",
												data: "false",
												condition: "="
											}
										],
										operator: "AND"
									}
								},
								lwcName: "cfACFR_DatatableValidationSummaryMessage",
								label: "FoodNutritionErrorMessage",
								hide: false,
								customAttributes: [],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "FoodNutritionErrorMessage",
							level: 1,
							JSONPath:
								"NATSIFACPFoodandNutritionReporting:FoodNutritionErrorMessage",
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
								text: "<h1>NATSIFACP Food and Nutrition Reporting</h1>",
								show: null,
								sanitize: false,
								label: "TextBlock1",
								dataJSON: false,
								controlWidth: 12,
								HTMLTemplateId: ""
							},
							name: "TextBlock1",
							level: 1,
							JSONPath: "NATSIFACPFoodandNutritionReporting:TextBlock1",
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
											"%GetFormData_DR:NATSIFACPFoodandNutritionReporting:Id%",
										name: "record-id"
									}
								],
								bStandalone: false,
								lwcName: "qfrReasonsForReissuance",
								hide: false,
								conditionType: "Hide if False",
								show: null,
								label: "ReasonsForReissuance",
								controlWidth: 12
							},
							name: "ReasonsForReissuance",
							level: 1,
							JSONPath:
								"NATSIFACPFoodandNutritionReporting:ReasonsForReissuance",
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
								lwcName: "cfACFR_AboutFoodNutritionReporting",
								label: "FoodNutritionAboutSection",
								hide: false,
								customAttributes: [
									{ source: "%GetFormData_DR:Case:Case__c%", name: "record-id" }
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: true
							},
							name: "FoodNutritionAboutSection",
							level: 1,
							JSONPath:
								"NATSIFACPFoodandNutritionReporting:FoodNutritionAboutSection",
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
								label: "CustomLWC2",
								hide: false,
								customAttributes: [
									{
										source:
											"%GetFormData_DR:NATSIFACPFoodandNutritionReporting:Id%",
										name: "record-id"
									}
								],
								controlWidth: 12,
								conditionType: "Hide if False",
								bStandalone: false
							},
							name: "CustomLWC2",
							level: 1,
							JSONPath: "NATSIFACPFoodandNutritionReporting:CustomLWC2",
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
			JSONPath: "NATSIFACPFoodandNutritionReporting",
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
				label: "Do Nothing",
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
	bpVersion: 14,
	bpType: "ACFR",
	bpSubType: "NATSIFACFoodandNutrition",
	bpLang: "English",
	bHasAttachment: false,
	lwcVarMap: {
		caseRecordId: null,
		GetFormData_DR: {
			NATSIFACPFoodandNutritionReporting: { Id: null },
			Case: { Case__c: null }
		}
	}
};
