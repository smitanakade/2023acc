let definition = {
	dataSource: {
		contextVariables: [],
		orderBy: { isReverse: "", name: "" },
		type: "DataRaptor",
		value: {
			bundle: "ACFR_GetReportingPeriod",
			bundleType: "",
			dsDelay: "",
			inputMap: { caseId: "{recordId}" },
			resultVar: ""
		}
	},
	enableLwc: true,
	globalCSS: true,
	isFlex: true,
	isRepeatable: true,
	listenToWidthResize: true,
	lwc: {
		DeveloperName: "cfACFR_ApprovedProviderQFRAbout_11_Carla",
		Id: "0RbBm0000002gRNKAY",
		MasterLabel: "cfACFR_ApprovedProviderQFRAbout_11_Carla",
		NamespacePrefix: "c",
		ManageableState: "unmanaged"
	},
	osSupport: true,
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
									element: "flexIcon",
									elementLabel: "BLKLeft-Icon-0",
									key: "element_element_block_0_0_flexIcon_0_0",
									name: "Icon",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										color: "#04819C",
										extraclass: "",
										iconName: "utility:info",
										iconType: "Salesforce SVG",
										imgsrc: "",
										record: "{record}",
										size: "small",
										variant: "default"
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
										class: "",
										container: { class: "" },
										elementStyleProperties: { color: "#04819C" },
										inlineStyle: "width:30px ;",
										margin: [],
										padding: [],
										size: { default: "1", isResponsive: false },
										sizeClass: "slds-size_1-of-12 ",
										style: "      \n         width:30px ;",
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
												elementStyleProperties: { color: "#04819C" },
												inlineStyle: "width:30px ;",
												margin: [],
												padding: [],
												size: { default: "1", isResponsive: false },
												sizeClass: "slds-size_1-of-12 ",
												style: "      \n         width:30px ;",
												text: { align: "", color: "" }
											}
										}
									],
									type: "element"
								},
								{
									children: [
										{
											children: [
												{
													class: "nds-col ",
													element: "outputField",
													elementLabel: "TXTSectionContent",
													key: "element_element_element_element_block_0_0_block_1_0_block_0_0_outputField_0_0",
													name: "Text",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_0_0",
													property: {
														card: "{card}",
														"data-conditions": {
															group: [],
															id: "state-condition-object",
															isParent: true
														},
														"data-preloadConditionalElement": true,
														mergeField:
															"%3Cdiv%3E%0A%3Cp%3EPlease%20enter%20the%20following%20segment%20information%20on%20a%20financial%20year%20to%20date%20basis%20as%20at%20%7BRP_End_Date%7D,%20ensuring%20the%20following:%3C/p%3E%0A%3Cp%3E&nbsp;%3C/p%3E%0A%3C/div%3E",
														record: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: {
														background: {
															color: "#F7FCFD",
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
														class: " ",
														container: { class: "" },
														customClass: "",
														elementStyleProperties: {},
														inlineStyle: "",
														margin: [],
														padding: [],
														size: { default: "12", isResponsive: false },
														sizeClass: "nds-size_12-of-12 ",
														style: "background-color:#F7FCFD;      \n         ",
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
																	color: "#F7FCFD",
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
																class: " ",
																container: { class: "" },
																customClass: "",
																elementStyleProperties: {},
																inlineStyle: "",
																margin: [],
																padding: [],
																size: { default: "12", isResponsive: false },
																sizeClass: "nds-size_12-of-12 ",
																style:
																	"background-color:#F7FCFD;      \n         ",
																text: { align: "", color: "" }
															}
														}
													],
													type: "text",
													userUpdatedElementLabel: true
												},
												{
													class: "nds-col ",
													element: "outputField",
													elementLabel: "BLKRight-Block-0-Text-0-clone-0",
													key: "element_element_element_element_block_0_0_block_1_0_block_0_0_outputField_1_0",
													name: "Text",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_0_0",
													property: {
														card: "{card}",
														mergeField:
															"%3Cdiv%3EThe%20Quarterly%20Financial%20Statement%20collects%20financial%20information%20about%20the&nbsp;%3Cstrong%3Eapproved%20provider%3C/strong%3E&nbsp;(which%20may%20include%20both%20aged%20care%20and%20non-aged%20care%20operations).%3C/div%3E%0A%3Cul%3E%0A%3Cli%3EPlease%20enter%20all%20data%20on%20a&nbsp;%3Cstrong%3Efinancial%20year%20to%20date%3C/strong%3E&nbsp;basis.%20For%20example,%20if%20your%20financial%20year%20commenced%20on%201%20July,%20then%20the%20data%20for%20the%20quarter%20ending%2030%20September%20would%20be%20for%203%20months,%20whereas%20if%20your%20financial%20year%20started%20on%201%20January%20then%20the%20data%20for%20the%20quarter%20ending%2030%20September%20would%20be%20for%209%20months.%3C/li%3E%0A%3Cli%3EEach%20line-item%20recorded%20should%20be%20GST%20exclusive,%20accounted%20for%20using%20the%20accrual%20basis,%20and%20expressed%20in%20whole%20dollars.%3C/li%3E%0A%3Cli%3EThe%20Community%20Segment%20includes%20CHSP,%20DVA%20and%20other%20non-aged%20care%20community%20services%20including%20NDIS,%20children%20services%20and%20other%20community%20services.%3C/li%3E%0A%3C/ul%3E",
														record: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: {
														background: {
															color: "#F7FCFD",
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
														class: " ",
														container: { class: "" },
														customClass: "",
														elementStyleProperties: {},
														inlineStyle: "",
														margin: [],
														padding: [],
														size: { default: "12", isResponsive: false },
														sizeClass: "nds-size_12-of-12 ",
														style: "background-color:#F7FCFD;      \n         ",
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
																	color: "#F7FCFD",
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
																class: " ",
																container: { class: "" },
																customClass: "",
																elementStyleProperties: {},
																inlineStyle: "",
																margin: [],
																padding: [],
																size: { default: "12", isResponsive: false },
																sizeClass: "nds-size_12-of-12 ",
																style:
																	"background-color:#F7FCFD;      \n         ",
																text: { align: "", color: "" }
															}
														}
													],
													type: "text",
													userUpdatedElementLabel: true
												},
												{
													class: "nds-col ",
													element: "outputField",
													elementLabel: "BLKRight-Block-0-Text-1-clone-0",
													key: "element_element_element_element_block_0_0_block_1_0_block_0_0_outputField_2_0",
													name: "Text",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_0_0",
													property: {
														card: "{card}",
														mergeField:
															"%3Cp%3EPease%20note%20that%20you%20are%20required%20to%20provide%20an%20answer%20for%20all%20line%20items.%20If%20any%20of%20the%20following%20are%20not%20applicable%20to%20your%20organisation,%20simply%20enter%200%20in%20the%20space%20provided.%20If%20you%20encounter%20any%20difficulties%20or%20require%20further%20information,%20please%20contact%20Forms%20Administration%20on%20(02)%204403%200640.%3C/p%3E%0A%3Cp%3E&nbsp;%3C/p%3E",
														record: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: {
														background: {
															color: "#F7FCFD",
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
														class: " ",
														container: { class: "" },
														customClass: "",
														elementStyleProperties: {},
														inlineStyle: "",
														margin: [],
														padding: [],
														size: { default: "12", isResponsive: false },
														sizeClass: "nds-size_12-of-12 ",
														style: "background-color:#F7FCFD;      \n         ",
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
																	color: "#F7FCFD",
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
																class: " ",
																container: { class: "" },
																customClass: "",
																elementStyleProperties: {},
																inlineStyle: "",
																margin: [],
																padding: [],
																size: { default: "12", isResponsive: false },
																sizeClass: "nds-size_12-of-12 ",
																style:
																	"background-color:#F7FCFD;      \n         ",
																text: { align: "", color: "" }
															}
														}
													],
													type: "text",
													userUpdatedElementLabel: true
												},
												{
													class: "nds-col ",
													element: "outputField",
													elementLabel: "BLKRight-Block-0-Text-2-clone-0",
													key: "element_element_element_element_block_0_0_block_1_0_block_0_0_outputField_3_0",
													name: "Text",
													parentElementKey:
														"element_element_element_block_0_0_block_1_0_block_0_0",
													property: {
														card: "{card}",
														mergeField:
															"%3Cp%3E%3Cstrong%3EColumns%20Not%20Relevant%20to%20Your%20Organisation?%3C/strong%3E%3Cbr%20/%3EIf%20any%20of%20the%20columns%20shown%20in%20the%20table%20below%20are%20not%20relevant%20to%20your%20organisation,%20please%20unselect%20those%20columns%20using%20the%20checkboxes%20provided.%20Please%20note,%20doing%20so%20will%20automatically%20populate%20fields%20in%20those%20columns%20with%20values%20of%20$0.00%20and%20cause%20any%20previously%20entered%20data%20to%20be%20overwritten.%3C/p%3E",
														record: "{record}"
													},
													size: { default: "12", isResponsive: false },
													stateIndex: 0,
													styleObject: {
														background: {
															color: "#F7FCFD",
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
														class: " ",
														container: { class: "" },
														customClass: "",
														elementStyleProperties: {},
														inlineStyle: "",
														margin: [],
														padding: [],
														size: { default: "12", isResponsive: false },
														sizeClass: "nds-size_12-of-12 ",
														style: "background-color:#F7FCFD;      \n         ",
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
																	color: "#F7FCFD",
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
																class: " ",
																container: { class: "" },
																customClass: "",
																elementStyleProperties: {},
																inlineStyle: "",
																margin: [],
																padding: [],
																size: { default: "12", isResponsive: false },
																sizeClass: "nds-size_12-of-12 ",
																style:
																	"background-color:#F7FCFD;      \n         ",
																text: { align: "", color: "" }
															}
														}
													],
													type: "text",
													userUpdatedElementLabel: true
												}
											],
											class: "nds-col ",
											element: "block",
											elementLabel: "BLKRight-Block-0",
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
												class: "nds-p-left_small nds-p-left_medium ",
												container: { class: "" },
												elementStyleProperties: {},
												inlineStyle: "",
												margin: [],
												padding: [
													{ label: "left:small", size: "small", type: "left" },
													{ label: "left:medium", size: "medium", type: "left" }
												],
												size: { default: "12", isResponsive: false },
												sizeClass: "nds-size_12-of-12 ",
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
														class: "nds-p-left_small nds-p-left_medium ",
														container: { class: "" },
														elementStyleProperties: {},
														inlineStyle: "",
														margin: [],
														padding: [
															{
																label: "left:small",
																size: "small",
																type: "left"
															},
															{
																label: "left:medium",
																size: "medium",
																type: "left"
															}
														],
														size: { default: "12", isResponsive: false },
														sizeClass: "nds-size_12-of-12 ",
														style: "      \n         ",
														text: { align: "", color: "" }
													}
												}
											],
											type: "block"
										}
									],
									class: "nds-col ",
									element: "block",
									elementLabel: "BLKRight",
									key: "element_element_block_0_0_block_1_0",
									name: "Block",
									parentElementKey: "element_block_0_0",
									property: {
										card: "{card}",
										collapsedByDefault: false,
										collapsible: true,
										label: "About This Section",
										record: "{record}",
										styles: {
											label: { color: "#000", fontFamily: "", fontSize: "20px" }
										}
									},
									size: { default: "11", isResponsive: false },
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
										class: "nds-text-align_left nds-p-bottom_xxx-small ",
										container: { class: "" },
										elementStyleProperties: {
											styles: {
												label: {
													color: "#000",
													fontFamily: "",
													fontSize: "20px"
												}
											}
										},
										inlineStyle: "",
										margin: [],
										padding: [
											{
												label: "bottom:xxx-small",
												size: "xxx-small",
												type: "bottom"
											}
										],
										size: { default: "11", isResponsive: false },
										sizeClass: "nds-size_11-of-12 ",
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
												class: "nds-text-align_left nds-p-bottom_xxx-small ",
												container: { class: "" },
												elementStyleProperties: {
													styles: {
														label: {
															color: "#000",
															fontFamily: "",
															fontSize: "20px"
														}
													}
												},
												inlineStyle: "",
												margin: [],
												padding: [
													{
														label: "bottom:xxx-small",
														size: "xxx-small",
														type: "bottom"
													}
												],
												size: { default: "11", isResponsive: false },
												sizeClass: "nds-size_11-of-12 ",
												style: "      \n         ",
												text: { align: "left", color: "" }
											}
										}
									],
									type: "block",
									userUpdatedElementLabel: true
								}
							],
							class: "nds-col ",
							element: "block",
							elementLabel: "BLKAboutThis",
							name: "Block",
							property: {
								card: "{card}",
								collapsedByDefault: false,
								collapsible: false,
								label: "",
								record: "{record}"
							},
							size: { default: "12", isResponsive: false },
							stateIndex: 0,
							styleObject: {
								background: {
									color: "#F7FCFD",
									image: "",
									position: "",
									repeat: "initial",
									size: ""
								},
								border: {
									color: "#E8F4F9",
									radius: "2px",
									style: "solid",
									type: [
										"border_top",
										"border_right",
										"border_bottom",
										"border_left"
									],
									width: "1"
								},
								class:
									"nds-border_top nds-border_right nds-border_bottom nds-border_left nds-p-around_small nds-p-top_medium nds-m-top_x-small ",
								container: { class: "" },
								elementStyleProperties: {},
								inlineStyle: "",
								margin: [
									{ label: "top:x-small", size: "x-small", type: "top" }
								],
								padding: [
									{ label: "around:small", size: "small", type: "around" },
									{ label: "top:medium", size: "medium", type: "top" }
								],
								size: { default: "12", isResponsive: false },
								sizeClass: "nds-size_12-of-12 ",
								style:
									"background-color:#F7FCFD;  background-repeat:initial;   border-top: #E8F4F9 1px solid;border-right: #E8F4F9 1px solid;border-bottom: #E8F4F9 1px solid;border-left: #E8F4F9 1px solid; \n    border-radius:2px;     ",
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
											color: "#F7FCFD",
											image: "",
											position: "",
											repeat: "initial",
											size: ""
										},
										border: {
											color: "#E8F4F9",
											radius: "2px",
											style: "solid",
											type: [
												"border_top",
												"border_right",
												"border_bottom",
												"border_left"
											],
											width: "1"
										},
										class:
											"nds-border_top nds-border_right nds-border_bottom nds-border_left nds-p-around_small nds-p-top_medium nds-m-top_x-small ",
										container: { class: "" },
										elementStyleProperties: {},
										inlineStyle: "",
										margin: [
											{ label: "top:x-small", size: "x-small", type: "top" }
										],
										padding: [
											{ label: "around:small", size: "small", type: "around" },
											{ label: "top:medium", size: "medium", type: "top" }
										],
										size: { default: "12", isResponsive: false },
										sizeClass: "nds-size_12-of-12 ",
										style:
											"background-color:#F7FCFD;  background-repeat:initial;   border-top: #E8F4F9 1px solid;border-right: #E8F4F9 1px solid;border-bottom: #E8F4F9 1px solid;border-left: #E8F4F9 1px solid; \n    border-radius:2px;     ",
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
					color: "#fff",
					image: "",
					position: "",
					repeat: "repeat",
					size: ""
				},
				border: { color: "", radius: "", style: "", type: "", width: "" },
				class: "nds-theme_default nds-p-around_x-small nds-m-bottom_x-small ",
				container: { class: "" },
				elementStyleProperties: {},
				inlineStyle: "",
				margin: [{ label: "bottom:x-small", size: "x-small", type: "bottom" }],
				padding: [{ label: "around:x-small", size: "x-small", type: "around" }],
				size: { default: "12", isResponsive: false },
				sizeClass: "nds-size_12-of-12 ",
				style:
					"background-color:#fff;  background-repeat:repeat;    \n        color:#000; ",
				text: { align: "", color: "#000" },
				theme: "theme_default"
			}
		}
	],
	theme: "nds",
	title: "ACFR_ApprovedProviderQFRAbout",
	uniqueKey: "CaseId",
	Id: "0koBm0000000Bl3IAE",
	OmniUiCardKey: "ACFR_ApprovedProviderQFRAbout/Carla/11.0",
	OmniUiCardType: "Child"
};
export default definition;
