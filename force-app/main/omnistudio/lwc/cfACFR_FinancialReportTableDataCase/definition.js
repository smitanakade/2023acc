let definition = {
	dataSource: {
		type: "Query",
		value: {
			dsDelay: "",
			query:
				"Select NAPSID__c,Provider_Name__c,QFR_RP_Locked__c,Reporting_Period_End_Date__c, status,Reporting_Due_Date__c from case where recordtype.name='QFR' AND Reporting_Due_Date__c<>NULL LIMIT 50000",
			resultVar: ""
		},
		orderBy: { name: "Reporting_Due_Date__c", isReverse: "true" },
		contextVariables: []
	},
	enableLwc: true,
	isFlex: true,
	isRepeatable: true,
	listenToWidthResize: false,
	lwc: {
		DeveloperName: "cfACFR_FinancialReportTableDataCase_11_Ashwani",
		Id: "0RbBm00000053zlKAA",
		MasterLabel: "cfACFR_FinancialReportTableDataCase_11_Ashwani",
		NamespacePrefix: "c",
		ManageableState: "unmanaged"
	},
	osSupport: true,
	selectableMode: "Multi",
	selectedCardsLabel: "",
	sessionVars: [{ isApi: true, name: "AccountId", val: "" }],
	states: [
		{
			actions: [],
			childCards: [],
			components: {
				"layer-0": {
					children: [
						{
							children: [
								{
									class: "slds-col ",
									element: "outputField",
									elementLabel: "BLKNew-NAPSID__c-1",
									key: "element_element_block_0_0_outputField_0_0",
									name: "NAPSID__c",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										fieldName: "NAPSID__c",
										label: "",
										placeholder: "output",
										record: "{record}",
										type: "text"
									},
									size: { default: "1", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "",
											radius: "",
											style: "",
											type: "",
											width: ""
										},
										class: "slds-text-align_left ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "1", isResponsive: false },
										sizeClass: "slds-size_1-of-12 ",
										style: "      \n         ",
										text: { align: "left", color: "" }
									},
									styleObjects: [
										{
											conditionString: "",
											conditions: "default",
											draggable: false,
											key: 0,
											label: "Default",
											name: "Default",
											styleObject: {
												background: {
													color: "",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "",
													radius: "",
													style: "",
													type: "",
													width: ""
												},
												class: "slds-text-align_left ",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "1", isResponsive: false },
												sizeClass: "slds-size_1-of-12 ",
												style: "      \n         ",
												text: { align: "left", color: "" }
											}
										}
									],
									type: "field"
								},
								{
									class: "slds-col ",
									element: "outputField",
									elementLabel: "BLKNew-Provider_Name__c-2",
									key: "element_element_block_0_0_outputField_1_0",
									name: "Provider_Name__c",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										fieldName: "Provider_Name__c",
										label: "",
										placeholder: "output",
										record: "{record}",
										type: "text"
									},
									size: { default: "2", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "",
											radius: "",
											style: "",
											type: "",
											width: ""
										},
										class: "slds-text-align_center ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "2", isResponsive: false },
										sizeClass: "slds-size_2-of-12 ",
										style: "      \n         ",
										text: { align: "center", color: "" }
									},
									styleObjects: [
										{
											conditionString: "",
											conditions: "default",
											draggable: false,
											key: 0,
											label: "Default",
											name: "Default",
											styleObject: {
												background: {
													color: "",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "",
													radius: "",
													style: "",
													type: "",
													width: ""
												},
												class: "slds-text-align_center ",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "2", isResponsive: false },
												sizeClass: "slds-size_2-of-12 ",
												style: "      \n         ",
												text: { align: "center", color: "" }
											}
										}
									],
									type: "field"
								},
								{
									class: "slds-col ",
									element: "outputField",
									elementLabel: "Type Data",
									key: "element_element_block_0_0_outputField_2_0",
									name: "Field",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										"data-conditions": {
											group: [],
											id: "state-condition-object",
											isParent: true
										},
										"data-preloadConditionalElement": false,
										fieldName: "",
										label: "",
										placeholder: "QFR",
										record: "{record}",
										type: "text"
									},
									size: { default: "1", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "#cccccc",
											radius: "",
											style: "",
											type: [],
											width: ""
										},
										class: "slds-text-align_center  ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "1", isResponsive: false },
										sizeClass: "slds-size_1-of-12 ",
										style: "      \n         ",
										text: { align: "center", color: "" }
									},
									styleObjects: [
										{
											conditionString: "",
											conditions: "default",
											draggable: false,
											key: 0,
											label: "Default",
											name: "Default",
											styleObject: {
												background: {
													color: "",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "#cccccc",
													radius: "",
													style: "",
													type: [],
													width: ""
												},
												class: "slds-text-align_center  ",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "1", isResponsive: false },
												sizeClass: "slds-size_1-of-12 ",
												style: "      \n         ",
												text: { align: "center", color: "" }
											}
										}
									],
									type: "element",
									userUpdatedElementLabel: true
								},
								{
									class: "slds-col ",
									element: "outputField",
									elementLabel: "BLKNew-Reporting_Period_End_Date__c-4",
									key: "element_element_block_0_0_outputField_3_0",
									name: "Reporting_Period_End_Date__c",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										fieldName: "Reporting_Period_End_Date__c",
										format: "D/M/YYYY",
										label: "",
										placeholder: "",
										record: "{record}",
										type: "date"
									},
									size: { default: "2", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "",
											radius: "",
											style: "",
											type: "",
											width: ""
										},
										class: "slds-text-align_center ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "2", isResponsive: false },
										sizeClass: "slds-size_2-of-12 ",
										style: "      \n         ",
										text: { align: "center", color: "" }
									},
									styleObjects: [
										{
											conditionString: "",
											conditions: "default",
											draggable: false,
											key: 0,
											label: "Default",
											name: "Default",
											styleObject: {
												background: {
													color: "",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "",
													radius: "",
													style: "",
													type: "",
													width: ""
												},
												class: "slds-text-align_center ",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "2", isResponsive: false },
												sizeClass: "slds-size_2-of-12 ",
												style: "      \n         ",
												text: { align: "center", color: "" }
											}
										}
									],
									type: "field"
								},
								{
									class: "slds-col ",
									element: "outputField",
									elementLabel: "BLKNew-Status-5",
									key: "element_element_block_0_0_outputField_4_0",
									name: "Status",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										fieldName: "Status",
										label: "",
										placeholder: "output",
										record: "{record}",
										type: "text"
									},
									size: { default: "1", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "",
											radius: "",
											style: "",
											type: "",
											width: ""
										},
										class: "slds-text-align_center ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "1", isResponsive: false },
										sizeClass: "slds-size_1-of-12 ",
										style: "      \n         ",
										text: { align: "center", color: "" }
									},
									styleObjects: [
										{
											conditionString: "",
											conditions: "default",
											draggable: false,
											key: 0,
											label: "Default",
											name: "Default",
											styleObject: {
												background: {
													color: "",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "",
													radius: "",
													style: "",
													type: "",
													width: ""
												},
												class: "slds-text-align_center ",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "1", isResponsive: false },
												sizeClass: "slds-size_1-of-12 ",
												style: "      \n         ",
												text: { align: "center", color: "" }
											}
										}
									],
									type: "field"
								},
								{
									class: "slds-col ",
									element: "outputField",
									elementLabel: "BLKNew-Reporting_Due_Date__c-6",
									key: "element_element_block_0_0_outputField_5_0",
									name: "Reporting_Due_Date__c",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										fieldName: "Reporting_Due_Date__c",
										format: "D/M/YYYY",
										label: "",
										placeholder: "",
										record: "{record}",
										type: "date"
									},
									size: { default: "2", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "",
											radius: "",
											style: "",
											type: "",
											width: ""
										},
										class: "slds-text-align_center ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "2", isResponsive: false },
										sizeClass: "slds-size_2-of-12 ",
										style: "      \n         ",
										text: { align: "center", color: "" }
									},
									styleObjects: [
										{
											conditionString: "",
											conditions: "default",
											draggable: false,
											key: 0,
											label: "Default",
											name: "Default",
											styleObject: {
												background: {
													color: "",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "",
													radius: "",
													style: "",
													type: "",
													width: ""
												},
												class: "slds-text-align_center ",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "2", isResponsive: false },
												sizeClass: "slds-size_2-of-12 ",
												style: "      \n         ",
												text: { align: "center", color: "" }
											}
										}
									],
									type: "field"
								},
								{
									children: [
										{
											class: "slds-col ",
											element: "action",
											elementLabel: "ActionStart",
											key: "element_element_element_block_0_0_block_6_0_action_0_0",
											name: "Action",
											parentElementKey: "element_element_block_0_0_block_6_0",
											property: {
												actionList: [
													{
														actionIndex: 0,
														card: "{card}",
														draggable: false,
														isOpen: true,
														key: "1663550107579-oiqljlaxa",
														label: "Action",
														stateAction: {
															"Community Named Page": {
																targetName: "Form_Submission__c"
															},
															displayName: "Action",
															hasExtraParams: true,
															id: "flex-action-1673250452294",
															openUrlIn: "Current Window",
															targetParams: { c__caseId: "{Id}" },
															targetType: "Community Named Page",
															type: "Custom",
															vlocityIcon: "standard-default"
														}
													}
												],
												buttonVariant: "brand",
												card: "{card}",
												"data-conditions": {
													group: [
														{
															id: "state-new-condition-0",
															field: "Status",
															operator: "==",
															value: "New",
															type: "custom",
															hasMergeField: false
														},
														{
															id: "state-new-condition-47",
															field: "QFR_RP_Locked__c",
															operator: "!=",
															value: "true",
															type: "custom",
															hasMergeField: false,
															logicalOperator: "&&"
														}
													],
													id: "state-condition-object",
													isParent: true
												},
												displayAsButton: false,
												flyoutChannel: "close_modal",
												flyoutDetails: {},
												hideActionIcon: true,
												iconColor: "#000",
												iconName: "standard-default",
												iconSize: "x-small",
												label: "Start",
												preloadFlyout: false,
												record: "{record}",
												showSpinner: "false",
												stateObj: "{record}",
												styles: {
													label: {
														color: "#fff",
														fontSize: "",
														textAlign: "center",
														textDecoration: ""
													}
												}
											},
											size: { default: "4", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												background: {
													color: "#51376B",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "#51376B",
													radius: "5px",
													style: "",
													type: "",
													width: ""
												},
												class:
													"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
												container: { class: "" },
												element: "action",
												elementStyleProperties: {
													iconColor: "#000",
													iconSize: "x-small",
													styles: {
														label: {
															color: "#fff",
															fontSize: "",
															textAlign: "center",
															textDecoration: ""
														}
													}
												},
												inlineStyle: "",
												margin: [],
												padding: [
													{
														label: "top:x-small",
														size: "x-small",
														type: "top"
													},
													{
														label: "horizontal:small",
														size: "small",
														type: "horizontal"
													}
												],
												selectedStyles: "qfr-button",
												size: { default: "4", isResponsive: false },
												sizeClass: "slds-size_4-of-12 ",
												style:
													"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
												text: { align: "center", color: "#51376B" }
											},
											styleObjects: [
												{
													conditionString: "",
													conditions: "default",
													draggable: false,
													key: 0,
													label: "Default",
													name: "Default",
													styleObject: {
														background: {
															color: "#51376B",
															image: "",
															position: "",
															repeat: "",
															size: ""
														},
														border: {
															color: "#51376B",
															radius: "5px",
															style: "",
															type: "",
															width: ""
														},
														class:
															"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
														container: { class: "" },
														element: "action",
														elementStyleProperties: {
															iconColor: "#000",
															iconSize: "x-small",
															styles: {
																label: {
																	color: "#fff",
																	fontSize: "",
																	textAlign: "center",
																	textDecoration: ""
																}
															}
														},
														inlineStyle: "",
														margin: [],
														padding: [
															{
																label: "top:x-small",
																size: "x-small",
																type: "top"
															},
															{
																label: "horizontal:small",
																size: "small",
																type: "horizontal"
															}
														],
														selectedStyles: "qfr-button",
														size: { default: "4", isResponsive: false },
														sizeClass: "slds-size_4-of-12 ",
														style:
															"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
														text: { align: "center", color: "#51376B" }
													}
												}
											],
											type: "element",
											userUpdatedElementLabel: true
										},
										{
											class: "slds-col ",
											element: "action",
											elementLabel: "resumeError",
											key: "element_element_element_block_0_0_block_6_0_action_1_0",
											name: "Action",
											parentElementKey: "element_element_block_0_0_block_6_0",
											property: {
												actionList: [
													{
														key: "1683764126833-9q8em2t1y",
														label: "Action",
														draggable: true,
														isOpen: true,
														card: "{card}",
														stateAction: {
															id: "flex-action-1683770325361",
															type: "Flyout",
															displayName: "Action",
															vlocityIcon: "standard-default",
															openUrlIn: "Current Window",
															flyoutType: "childCard",
															openFlyoutIn: "Modal",
															channelName: "close_modal",
															cardNode: "{record}",
															cardName: "ACFR_CaseLockError",
															flyoutLwc: "ACFR_CaseLockError",
															layoutType: "lightning"
														},
														actionIndex: 0,
														reRenderFlyout: true
													}
												],
												buttonVariant: "brand",
												card: "{card}",
												"data-conditions": {
													group: [
														{
															id: "state-new-condition-7",
															field: "QFR_RP_Locked__c",
															operator: "==",
															value: "true",
															type: "custom",
															hasMergeField: false
														}
													],
													id: "state-condition-object",
													isParent: true
												},
												displayAsButton: false,
												flyoutChannel: "close_modal",
												flyoutDetails: { openFlyoutIn: "Modal" },
												hideActionIcon: false,
												iconColor: "#ffffff",
												iconName: "utility:lock",
												iconSize: "x-small",
												label: "Locked",
												record: "{record}",
												showSpinner: "false",
												stateObj: "{record}",
												styles: {
													label: {
														color: "#fff",
														fontSize: "",
														textAlign: "center",
														textDecoration: ""
													}
												},
												iconOnly: true,
												reRenderFlyout: true
											},
											size: { default: "4", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												background: {
													color: "#51376B",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "#51376B",
													radius: "5px",
													style: "",
													type: "",
													width: ""
												},
												class:
													"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
												container: { class: "" },
												element: "action",
												elementStyleProperties: {
													iconColor: "#ffffff",
													iconSize: "x-small",
													styles: {
														label: {
															color: "#fff",
															fontSize: "",
															textAlign: "center",
															textDecoration: ""
														}
													}
												},
												inlineStyle: "",
												margin: [],
												padding: [
													{
														label: "top:x-small",
														size: "x-small",
														type: "top"
													},
													{
														label: "horizontal:small",
														size: "small",
														type: "horizontal"
													}
												],
												selectedStyles: "qfr-button",
												size: { default: "4", isResponsive: false },
												sizeClass: "slds-size_4-of-12 ",
												style:
													"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
												text: { align: "center", color: "#51376B" }
											},
											styleObjects: [
												{
													conditionString: "",
													conditions: "default",
													draggable: false,
													key: 0,
													label: "Default",
													name: "Default",
													styleObject: {
														background: {
															color: "#51376B",
															image: "",
															position: "",
															repeat: "",
															size: ""
														},
														border: {
															color: "#51376B",
															radius: "5px",
															style: "",
															type: "",
															width: ""
														},
														class:
															"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
														container: { class: "" },
														element: "action",
														elementStyleProperties: {
															iconColor: "#ffffff",
															iconSize: "x-small",
															styles: {
																label: {
																	color: "#fff",
																	fontSize: "",
																	textAlign: "center",
																	textDecoration: ""
																}
															}
														},
														inlineStyle: "",
														margin: [],
														padding: [
															{
																label: "top:x-small",
																size: "x-small",
																type: "top"
															},
															{
																label: "horizontal:small",
																size: "small",
																type: "horizontal"
															}
														],
														selectedStyles: "qfr-button",
														size: { default: "4", isResponsive: false },
														sizeClass: "slds-size_4-of-12 ",
														style:
															"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
														text: { align: "center", color: "#51376B" }
													}
												}
											],
											type: "element",
											userUpdatedElementLabel: true
										},
										{
											class: "slds-col ",
											element: "action",
											elementLabel: "BLKNew-Block-7-Action-1-clone-0",
											key: "element_element_element_block_0_0_block_6_0_action_2_0",
											name: "Action",
											parentElementKey: "element_element_block_0_0_block_6_0",
											property: {
												actionList: [
													{
														actionIndex: 0,
														card: "{card}",
														draggable: true,
														isOpen: false,
														key: "1663550107579-oiqljlaxa",
														label: "Action",
														stateAction: {
															"Community Named Page": {
																targetName: "Form_Submission__c"
															},
															displayName: "Action",
															hasExtraParams: true,
															id: "flex-action-1665627503466",
															openUrlIn: "Current Window",
															targetParams: { c__caseId: "{Id}" },
															targetType: "Community Named Page",
															type: "Custom",
															vlocityIcon: "standard-default"
														}
													}
												],
												buttonVariant: "brand",
												card: "{card}",
												"data-conditions": {
													group: [
														{
															id: "state-new-condition-7",
															field: "QFR_RP_Locked__c",
															operator: "!=",
															value: "true",
															type: "custom",
															hasMergeField: false
														},
														{
															id: "state-new-group-1",
															group: [
																{
																	id: "state-new-condition-0",
																	field: "Status",
																	operator: "==",
																	value: "Draft",
																	type: "custom",
																	hasMergeField: false
																},
																{
																	id: "state-new-condition-15",
																	field: "Status",
																	operator: "==",
																	value: "Reissued",
																	type: "custom",
																	hasMergeField: false,
																	logicalOperator: "||"
																}
															],
															logicalOperator: "&&"
														}
													],
													id: "state-condition-object",
													isParent: true
												},
												displayAsButton: false,
												flyoutChannel: "close_modal",
												flyoutDetails: {},
												hideActionIcon: true,
												iconColor: "#000",
												iconName: "standard-default",
												iconSize: "x-small",
												label: "Resume",
												preloadFlyout: false,
												record: "{record}",
												showSpinner: "false",
												stateObj: "{record}",
												styles: {
													label: {
														color: "#fff",
														fontSize: "",
														textAlign: "center",
														textDecoration: ""
													}
												}
											},
											size: { default: "4", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												background: {
													color: "#51376B",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "#51376B",
													radius: "5px",
													style: "",
													type: "",
													width: ""
												},
												class:
													"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
												container: { class: "" },
												element: "action",
												elementStyleProperties: {
													iconColor: "#000",
													iconSize: "x-small",
													styles: {
														label: {
															color: "#fff",
															fontSize: "",
															textAlign: "center",
															textDecoration: ""
														}
													}
												},
												inlineStyle: "",
												margin: [],
												padding: [
													{
														label: "top:x-small",
														size: "x-small",
														type: "top"
													},
													{
														label: "horizontal:small",
														size: "small",
														type: "horizontal"
													}
												],
												selectedStyles: "qfr-button",
												size: { default: "4", isResponsive: false },
												sizeClass: "slds-size_4-of-12 ",
												style:
													"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
												text: { align: "center", color: "#51376B" }
											},
											styleObjects: [
												{
													conditionString: "",
													conditions: "default",
													draggable: false,
													key: 0,
													label: "Default",
													name: "Default",
													styleObject: {
														background: {
															color: "#51376B",
															image: "",
															position: "",
															repeat: "",
															size: ""
														},
														border: {
															color: "#51376B",
															radius: "5px",
															style: "",
															type: "",
															width: ""
														},
														class:
															"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
														container: { class: "" },
														element: "action",
														elementStyleProperties: {
															iconColor: "#000",
															iconSize: "x-small",
															styles: {
																label: {
																	color: "#fff",
																	fontSize: "",
																	textAlign: "center",
																	textDecoration: ""
																}
															}
														},
														inlineStyle: "",
														margin: [],
														padding: [
															{
																label: "top:x-small",
																size: "x-small",
																type: "top"
															},
															{
																label: "horizontal:small",
																size: "small",
																type: "horizontal"
															}
														],
														selectedStyles: "qfr-button",
														size: { default: "4", isResponsive: false },
														sizeClass: "slds-size_4-of-12 ",
														style:
															"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
														text: { align: "center", color: "#51376B" }
													}
												}
											],
											type: "element",
											userUpdatedElementLabel: true
										},
										{
											class: "slds-col ",
											element: "action",
											elementLabel: "BLKNew-Block-6-Action-1-clone-0",
											key: "element_element_element_block_0_0_block_6_0_action_3_0",
											name: "Action",
											parentElementKey: "element_element_block_0_0_block_6_0",
											property: {
												actionList: [
													{
														actionIndex: 0,
														card: "{card}",
														draggable: false,
														isOpen: true,
														isTrackingDisabled: false,
														key: "1665558716316-aaxrvzfro",
														label: "Action",
														stateAction: {
															"Community Named Page": {
																targetName: "QFR_Report_Download__c"
															},
															displayName: "Action",
															hasExtraParams: true,
															id: "flex-action-1674431576977",
															openUrlIn: "New Tab/Window",
															targetParams: { caseId: "{Id}" },
															targetType: "Community Named Page",
															type: "Custom",
															vlocityIcon: "standard-default"
														}
													}
												],
												buttonVariant: "brand",
												card: "{card}",
												"data-conditions": {
													group: [
														{
															field: "Status",
															hasMergeField: false,
															id: "state-new-condition-21",
															operator: "==",
															type: "custom",
															value: "Draft"
														},
														{
															field: "Status",
															hasMergeField: false,
															id: "state-new-condition-28",
															logicalOperator: "||",
															operator: "==",
															type: "custom",
															value: "Submitted"
														},
														{
															field: "Status",
															hasMergeField: false,
															id: "state-new-condition-0",
															logicalOperator: "||",
															operator: "==",
															type: "custom",
															value: "Reissued"
														},
														{
															field: "Status",
															hasMergeField: false,
															id: "state-new-condition-9",
															logicalOperator: "||",
															operator: "==",
															type: "custom",
															value: "Re-Submitted"
														}
													],
													id: "state-condition-object",
													isParent: true
												},
												displayAsButton: false,
												flyoutChannel: "close_modal",
												flyoutDetails: {},
												hideActionIcon: true,
												iconColor: "#000",
												iconName: "standard-default",
												iconSize: "x-small",
												label: "Download",
												preloadFlyout: false,
												record: "{record}",
												showSpinner: "false",
												stateObj: "{record}",
												styles: {
													label: {
														color: "#fff",
														fontSize: "",
														textAlign: "center",
														textDecoration: ""
													}
												}
											},
											size: { default: "4", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												background: {
													color: "#51376B",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "#51376B",
													radius: "5px",
													style: "",
													type: "",
													width: ""
												},
												class:
													"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
												container: { class: "" },
												element: "action",
												elementStyleProperties: {
													iconColor: "#000",
													iconSize: "x-small",
													styles: {
														label: {
															color: "#fff",
															fontSize: "",
															textAlign: "center",
															textDecoration: ""
														}
													}
												},
												inlineStyle: "",
												margin: [],
												padding: [
													{
														label: "top:x-small",
														size: "x-small",
														type: "top"
													},
													{
														label: "horizontal:small",
														size: "small",
														type: "horizontal"
													}
												],
												selectedStyles: "qfr-button",
												size: { default: "4", isResponsive: false },
												sizeClass: "slds-size_4-of-12 ",
												style:
													"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
												text: { align: "center", color: "#51376B" }
											},
											styleObjects: [
												{
													conditionString: "",
													conditions: "default",
													draggable: false,
													key: 0,
													label: "Default",
													name: "Default",
													styleObject: {
														background: {
															color: "#51376B",
															image: "",
															position: "",
															repeat: "",
															size: ""
														},
														border: {
															color: "#51376B",
															radius: "5px",
															style: "",
															type: "",
															width: ""
														},
														class:
															"slds-text-align_center slds-p-top_x-small slds-p-horizontal_small ",
														container: { class: "" },
														element: "action",
														elementStyleProperties: {
															iconColor: "#000",
															iconSize: "x-small",
															styles: {
																label: {
																	color: "#fff",
																	fontSize: "",
																	textAlign: "center",
																	textDecoration: ""
																}
															}
														},
														inlineStyle: "",
														margin: [],
														padding: [
															{
																label: "top:x-small",
																size: "x-small",
																type: "top"
															},
															{
																label: "horizontal:small",
																size: "small",
																type: "horizontal"
															}
														],
														selectedStyles: "qfr-button",
														size: { default: "4", isResponsive: false },
														sizeClass: "slds-size_4-of-12 ",
														style:
															"background-color:#51376B;      \n    border-radius:5px;    color:#51376B; ",
														text: { align: "center", color: "#51376B" }
													}
												}
											],
											type: "element",
											userUpdatedElementLabel: true
										}
									],
									class: "slds-col ",
									element: "block",
									elementLabel: "BLKNew-Block-7",
									key: "element_element_block_0_0_block_6_0",
									name: "Block",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										collapsedByDefault: false,
										collapsible: false,
										label: "Block",
										record: "{record}"
									},
									size: { default: "3", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "",
											radius: "",
											style: "",
											type: "",
											width: ""
										},
										class: "",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "3", isResponsive: false },
										sizeClass: "slds-size_3-of-12 ",
										style: "      \n         ",
										text: { align: "", color: "" }
									},
									styleObjects: [
										{
											conditionString: "",
											conditions: "default",
											draggable: false,
											key: 0,
											label: "Default",
											name: "Default",
											styleObject: {
												background: {
													color: "",
													image: "",
													position: "",
													repeat: "",
													size: ""
												},
												border: {
													color: "",
													radius: "",
													style: "",
													type: "",
													width: ""
												},
												class: "",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "3", isResponsive: false },
												sizeClass: "slds-size_3-of-12 ",
												style: "      \n         ",
												text: { align: "", color: "" }
											}
										}
									],
									type: "block"
								}
							],
							class: "slds-col ",
							element: "block",
							elementLabel: "BLKNew",
							name: "Block",
							property: {
								card: "{card}",
								collapsedByDefault: false,
								collapsible: false,
								"data-conditions": {
									group: [],
									id: "state-condition-object",
									isParent: true
								},
								label: "Block",
								record: "{record}"
							},
							size: { default: "12", isResponsive: false },
							stateIndex: 0,
							styleObject: {
								background: {
									color: "#FFA400",
									image: "",
									position: "",
									repeat: "",
									size: ""
								},
								border: {
									color: "#BBBBBB",
									radius: "2px",
									style: "",
									type: "border_bottom",
									width: "1"
								},
								class:
									"slds-border_bottom slds-p-top_x-small slds-p-bottom_x-small ",
								container: { class: "" },
								elementStyleProperties: {},
								inlineStyle: "",
								margin: [],
								padding: [
									{ label: "top:x-small", size: "x-small", type: "top" },
									{ label: "bottom:x-small", size: "x-small", type: "bottom" }
								],
								size: { default: "12", isResponsive: false },
								sizeClass: "slds-size_12-of-12 ",
								style:
									"background-color:#FFA400;     border-bottom: #BBBBBB 1px solid; \n    border-radius:2px;     ",
								text: { align: "", color: "" }
							},
							styleObjects: [
								{
									conditionString: "",
									conditions: "default",
									draggable: false,
									isSetForDesignTime: false,
									isopen: true,
									key: 0,
									label: "Default",
									name: "Default",
									styleObject: {
										background: {
											color: "",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "#BBBBBB",
											radius: "2px",
											style: "",
											type: "border_bottom",
											width: "1"
										},
										class:
											"slds-border_bottom slds-p-top_x-small slds-p-bottom_x-small ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [
											{ label: "top:x-small", size: "x-small", type: "top" },
											{
												label: "bottom:x-small",
												size: "x-small",
												type: "bottom"
											}
										],
										size: { default: "12", isResponsive: false },
										sizeClass: "slds-size_12-of-12 ",
										style:
											"     border-bottom: #BBBBBB 1px solid; \n    border-radius:2px;     ",
										text: { align: "", color: "" }
									}
								},
								{
									conditionString: "NotOverdueReport == false",
									conditions: {
										group: [
											{
												field: "NotOverdueReport",
												hasMergeField: false,
												id: "state-new-condition-6",
												operator: "==",
												type: "custom",
												value: "false"
											}
										],
										id: "state-condition-object",
										isParent: true
									},
									draggable: true,
									isSetForDesignTime: true,
									isopen: true,
									key: 1,
									label: "orangebackground",
									name: "orangebackground",
									styleObject: {
										background: {
											color: "#FFA400",
											image: "",
											position: "",
											repeat: "",
											size: ""
										},
										border: {
											color: "#BBBBBB",
											radius: "2px",
											style: "",
											type: "border_bottom",
											width: "1"
										},
										class:
											"slds-border_bottom slds-p-top_x-small slds-p-bottom_x-small ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [
											{ label: "top:x-small", size: "x-small", type: "top" },
											{
												label: "bottom:x-small",
												size: "x-small",
												type: "bottom"
											}
										],
										size: { default: "12", isResponsive: false },
										sizeClass: "slds-size_12-of-12 ",
										style:
											"background-color:#FFA400;     border-bottom: #BBBBBB 1px solid; \n    border-radius:2px;     ",
										text: { align: "", color: "" }
									}
								}
							],
							type: "block",
							userUpdatedElementLabel: true
						}
					]
				}
			},
			conditions: { group: [], id: "state-condition-object", isParent: true },
			definedActions: { actions: [] },
			documents: [],
			fields: [],
			isSmartAction: false,
			name: "Active",
			omniscripts: [],
			smartAction: {},
			styleObject: {
				background: {
					color: "",
					image: "",
					position: "",
					repeat: "",
					size: ""
				},
				border: { color: "", radius: "", style: "", type: "", width: "" },
				class: "slds-p-top_xxx-small slds-p-bottom_xxx-small ",
				container: { class: "" },
				elementStyleProperties: {},
				inlineStyle: "",
				margin: [],
				padding: [
					{ label: "top:xxx-small", size: "xxx-small", type: "top" },
					{ label: "bottom:xxx-small", size: "xxx-small", type: "bottom" }
				],
				size: { default: "12", isResponsive: false },
				sizeClass: "slds-size_12-of-12 ",
				style: "      \n         ",
				text: { align: "", color: "" }
			}
		}
	],
	theme: "slds",
	title: "ACFR_FinancialReportTableDataCase",
	Id: "0koBm0000000NavIAE",
	OmniUiCardKey: "ACFR_FinancialReportTableDataCase/Ashwani/11.0",
	OmniUiCardType: "Child"
};
export default definition;
