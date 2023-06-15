let definition = {
	dataSource: { contextVariables: [], orderBy: {}, type: null, value: {} },
	enableLwc: true,
	globalCSS: true,
	isFlex: true,
	lwc: {
		DeveloperName: "cfACFR_GuidedFAQVersion2_2_QFR",
		Id: "0RbBm0000003sK1KAI",
		MasterLabel: "cfACFR_GuidedFAQVersion2_2_QFR",
		NamespacePrefix: "c",
		ManageableState: "unmanaged"
	},
	selectableMode: "Multi",
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
									elementLabel: "Block-1-Text-0",
									key: "element_element_block_0_0_outputField_0_0",
									name: "Text",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										mergeField:
											"%3Ch5%3E%3Cspan%20style=%22font-family:%20'Salesforce%20Sans',%20Arial,%20sans-serif;%22%3EQuarterly%20Financial%20Report%20(QFR)%3C/span%3E%3C/h5%3E",
										record: "{record}"
									},
									size: { default: "6", isResponsive: false },
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
										class: "header-text ",
										container: { class: "header-text" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [],
										size: { default: "6", isResponsive: false },
										sizeClass: "slds-size_6-of-12 ",
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
												class: "header-text ",
												container: { class: "header-text" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [],
												size: { default: "6", isResponsive: false },
												sizeClass: "slds-size_6-of-12 ",
												style: "      \n         ",
												text: { align: "", color: "" }
											}
										}
									],
									type: "text"
								},
								{
									children: [
										{
											children: [
												{
													class: "slds-col ",
													element: "action",
													elementLabel: "Block-1-Block-1-Action-3",
													key: "element_element_element_element_block_0_0_block_1_0_block_0_0_action_0_0",
													name: "Action",
													property: {
														actionList: [
															{
																actionIndex: 0,
																draggable: false,
																isOpen: true,
																key: "1666924742127-h33l3qywq",
																label: "Action",
																stateAction: {
																	"Web Page": {
																		targetName:
																			"https://www.health.gov.au/resources/collections/quarterly-financial-report-resources#reporting-guidance"
																	},
																	id: "flex-action-1682567181382",
																	openUrlIn: "New Tab/Window",
																	targetType: "Web Page",
																	type: "Custom"
																}
															}
														],
														card: "{card}",
														flyoutDetails: {},
														iconName: "doctype:pdf",
														label: "Reporting Guidance",
														record: "{record}",
														showSpinner: "false",
														stateObj: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: { sizeClass: "slds-size_12-of-12" },
													type: "element",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_0_0"
												}
											],
											class: "slds-col ",
											element: "block",
											elementLabel: "Block-1-Block-1-Block-1-clone-0",
											key: "element_element_element_block_0_0_block_1_0_block_0_0",
											name: "Block",
											parentElementKey: "element_element_block_0_0_block_1_0",
											property: {
												card: "{card}",
												collapsedByDefault: false,
												collapsible: false,
												label: "Block",
												record: "{record}"
											},
											size: { default: "12", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												class: "slds-p-around_x-small",
												padding: [{ size: "x-small", type: "around" }],
												sizeClass: "slds-size_12-of-12"
											},
											type: "block"
										},
										{
											children: [
												{
													class: "slds-col ",
													element: "action",
													elementLabel: "Block-1-Block-1-Action-4",
													key: "element_element_element_element_block_0_0_block_1_0_block_1_0_action_0_0",
													name: "Action",
													property: {
														actionList: [
															{
																actionIndex: 0,
																draggable: false,
																isOpen: true,
																key: "1666924850301-9fev8w7mg",
																label: "Action",
																stateAction: {
																	"Web Page": {
																		targetName:
																			"https://www.health.gov.au/resources/collections/quarterly-financial-report-resources#policy-guidance"
																	},
																	id: "flex-action-1682567192492",
																	openUrlIn: "New Tab/Window",
																	targetType: "Web Page",
																	type: "Custom"
																}
															}
														],
														card: "{card}",
														flyoutDetails: {},
														iconName: "doctype:pdf",
														label: "Policy Guidance",
														record: "{record}",
														showSpinner: "false",
														stateObj: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: { sizeClass: "slds-size_12-of-12" },
													type: "element",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_1_0"
												}
											],
											class: "slds-col ",
											element: "block",
											elementLabel: "Block-1-Block-1-Block-2-clone-0",
											key: "element_element_element_block_0_0_block_1_0_block_1_0",
											name: "Block",
											parentElementKey: "element_element_block_0_0_block_1_0",
											property: {
												card: "{card}",
												collapsedByDefault: false,
												collapsible: false,
												label: "Block",
												record: "{record}"
											},
											size: { default: "12", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												class: "slds-p-around_x-small",
												padding: [{ size: "x-small", type: "around" }],
												sizeClass: "slds-size_12-of-12"
											},
											type: "block"
										},
										{
											children: [
												{
													class: "slds-col ",
													element: "action",
													elementLabel: "Block-1-Block-1-Action-5",
													key: "element_element_element_element_block_0_0_block_1_0_block_2_0_action_0_0",
													name: "Action",
													property: {
														actionList: [
															{
																actionIndex: 0,
																draggable: false,
																isOpen: true,
																key: "1666924913079-6zehsweez",
																label: "Action",
																stateAction: {
																	"Web Page": {
																		targetName:
																			"https://www.health.gov.au/resources/collections/quarterly-financial-report-resources#system-user-guidance"
																	},
																	id: "flex-action-1682567199033",
																	openUrlIn: "New Tab/Window",
																	targetType: "Web Page",
																	type: "Custom"
																}
															}
														],
														card: "{card}",
														flyoutDetails: {},
														iconName: "doctype:pdf",
														label: "System User Guidance",
														record: "{record}",
														showSpinner: "false",
														stateObj: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: { sizeClass: "slds-size_12-of-12" },
													type: "element",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_2_0"
												}
											],
											class: "slds-col ",
											element: "block",
											elementLabel: "Block-1-Block-1-Block-3-clone-0",
											key: "element_element_element_block_0_0_block_1_0_block_2_0",
											name: "Block",
											parentElementKey: "element_element_block_0_0_block_1_0",
											property: {
												card: "{card}",
												collapsedByDefault: false,
												collapsible: false,
												label: "Block",
												record: "{record}"
											},
											size: { default: "12", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												class: "slds-p-around_x-small",
												padding: [{ size: "x-small", type: "around" }],
												sizeClass: "slds-size_12-of-12"
											},
											type: "block"
										},
										{
											children: [
												{
													class: "slds-col ",
													element: "action",
													elementLabel: "Block-1-Block-1-Action-7",
													key: "element_element_element_element_block_0_0_block_1_0_block_3_0_action_0_0",
													name: "Action",
													property: {
														actionList: [
															{
																actionIndex: 0,
																draggable: false,
																isOpen: true,
																key: "1666925020734-fb1wxgpbg",
																label: "Action",
																stateAction: {
																	"Web Page": {
																		targetName:
																			"https://www.health.gov.au/resources/collections/quarterly-financial-report-resources#webinars"
																	},
																	id: "flex-action-1682567205591",
																	openUrlIn: "New Tab/Window",
																	targetType: "Web Page",
																	type: "Custom"
																}
															}
														],
														card: "{card}",
														flyoutDetails: {},
														iconColor: "#000000",
														iconName: "utility:video",
														label: "Webinars",
														record: "{record}",
														showSpinner: "false",
														stateObj: "{record}"
													},
													size: { default: "12", isResponsive: false },
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
														container: { class: "" },
														elementStyleProperties: { iconColor: "#000000" },
														inlineStyle: "",
														margin: [],
														padding: [],
														size: { default: "12", isResponsive: false },
														sizeClass: "slds-size_12-of-12",
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
																container: { class: "" },
																elementStyleProperties: {
																	iconColor: "#000000"
																},
																inlineStyle: "",
																margin: [],
																padding: [],
																size: { default: "12", isResponsive: false },
																sizeClass: "slds-size_12-of-12",
																text: { align: "", color: "" }
															}
														}
													],
													type: "element",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_3_0"
												}
											],
											class: "slds-col ",
											element: "block",
											elementLabel: "Block-1-Block-1-Block-5-clone-0",
											key: "element_element_element_block_0_0_block_1_0_block_3_0",
											name: "Block",
											parentElementKey: "element_element_block_0_0_block_1_0",
											property: {
												card: "{card}",
												collapsedByDefault: false,
												collapsible: false,
												label: "Block",
												record: "{record}"
											},
											size: { default: "12", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												class: "slds-p-around_x-small",
												padding: [{ size: "x-small", type: "around" }],
												sizeClass: "slds-size_12-of-12"
											},
											type: "block"
										},
										{
											children: [
												{
													class: "slds-col ",
													element: "action",
													elementLabel: "Block-1-Block-1-Action-10",
													key: "element_element_element_element_block_0_0_block_1_0_block_4_0_action_0_0",
													name: "Action",
													property: {
														actionList: [
															{
																actionIndex: 0,
																draggable: false,
																isOpen: true,
																key: "1666925333963-v6rroojur",
																label: "Action",
																stateAction: {
																	"Web Page": {
																		targetName:
																			"Care minutes and 24/7 registered nurses in residential aged care | Australian Government Department of Health and Aged Care"
																	},
																	id: "flex-action-1682567212655",
																	openUrlIn: "New Tab/Window",
																	targetType: "Web Page",
																	type: "Custom"
																}
															}
														],
														card: "{card}",
														flyoutDetails: {},
														iconName: "doctype:pdf",
														label: "Care Minutes Reporting Resources",
														record: "{record}",
														showSpinner: "false",
														stateObj: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: { sizeClass: "slds-size_12-of-12" },
													type: "element",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_4_0"
												}
											],
											class: "slds-col ",
											element: "block",
											elementLabel: "Block-1-Block-1-Block-8-clone-0",
											key: "element_element_element_block_0_0_block_1_0_block_4_0",
											name: "Block",
											parentElementKey: "element_element_block_0_0_block_1_0",
											property: {
												card: "{card}",
												collapsedByDefault: false,
												collapsible: false,
												label: "Block",
												record: "{record}"
											},
											size: { default: "12", isResponsive: false },
											stateIndex: 0,
											styleObject: {
												class: "slds-p-around_x-small",
												padding: [{ size: "x-small", type: "around" }],
												sizeClass: "slds-size_12-of-12"
											},
											type: "block"
										}
									],
									class: "slds-col ",
									element: "block",
									elementLabel: "Block-1-Block-1",
									key: "element_element_block_0_0_block_1_0",
									name: "Block",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										collapsedByDefault: false,
										collapsible: false,
										label: "Block",
										record: "{record}"
									},
									size: { default: "6", isResponsive: false },
									stateIndex: 0,
									styleObject: {
										class: "slds-p-around_x-small ",
										padding: [
											{
												size: "x-small",
												type: "around",
												label: "around:x-small"
											}
										],
										size: { default: "6", isResponsive: false },
										sizeClass: "slds-size_6-of-12 ",
										margin: [],
										background: {
											color: "",
											image: "",
											size: "",
											repeat: "",
											position: ""
										},
										container: { class: "" },
										border: {
											type: "",
											width: "",
											color: "",
											radius: "",
											style: ""
										},
										elementStyleProperties: {},
										text: { align: "", color: "" },
										inlineStyle: "",
										style: "      \n         "
									},
									type: "block",
									styleObjects: [
										{
											key: 0,
											conditions: "default",
											styleObject: {
												class: "slds-p-around_x-small ",
												padding: [
													{
														size: "x-small",
														type: "around",
														label: "around:x-small"
													}
												],
												size: { default: "6", isResponsive: false },
												sizeClass: "slds-size_6-of-12 ",
												margin: [],
												background: {
													color: "",
													image: "",
													size: "",
													repeat: "",
													position: ""
												},
												container: { class: "" },
												border: {
													type: "",
													width: "",
													color: "",
													radius: "",
													style: ""
												},
												elementStyleProperties: {},
												text: { align: "", color: "" },
												inlineStyle: "",
												style: "      \n         "
											},
											label: "Default",
											name: "Default",
											conditionString: "",
											draggable: false
										}
									]
								}
							],
							class: "slds-col ",
							element: "block",
							elementLabel: "Block-3",
							name: "Block",
							property: {
								card: "{card}",
								collapsedByDefault: false,
								collapsible: false,
								label: "Block",
								record: "{record}"
							},
							size: { default: "12", isResponsive: false },
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
								class: "slds-p-around_x-small ",
								container: { class: "" },
								element: "block",
								elementStyleProperties: {},
								inlineStyle: "",
								margin: [],
								padding: [
									{ label: "around:x-small", size: "x-small", type: "around" }
								],
								selectedStyles: "QFR Guides and FAQs ",
								size: { default: "12", isResponsive: false },
								sizeClass: "slds-size_12-of-12 ",
								text: { align: "", color: "" },
								style: "      \n         "
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
										class: "slds-p-around_x-small ",
										container: { class: "" },
										element: "block",
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [],
										padding: [
											{
												label: "around:x-small",
												size: "x-small",
												type: "around"
											}
										],
										selectedStyles: "QFR Guides and FAQs ",
										size: { default: "12", isResponsive: false },
										sizeClass: "slds-size_12-of-12 ",
										text: { align: "", color: "" },
										style: "      \n         "
									}
								}
							],
							type: "block"
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
				class: "slds-card background slds-p-around_x-small slds-m-around_none ",
				container: { class: "slds-card background" },
				elementStyleProperties: {},
				inlineStyle: "",
				margin: [{ label: "around:none", size: "none", type: "around" }],
				padding: [{ label: "around:x-small", size: "x-small", type: "around" }],
				size: { default: "12", isResponsive: false },
				sizeClass: "slds-size_12-of-12 ",
				style: "      \n     height:24em;    ",
				text: { align: "", color: "" },
				height: "24em"
			}
		}
	],
	theme: "slds",
	title: "ACFR_GuidedFAQVersion2",
	Id: "0koBm0000000KzdIAE",
	OmniUiCardKey: "ACFR_GuidedFAQVersion2/QFR/2.0",
	OmniUiCardType: "Child"
};
export default definition;
