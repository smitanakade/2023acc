let definition = {
	dataSource: { type: null, value: {}, orderBy: {}, contextVariables: [] },
	enableLwc: true,
	globalCSS: true,
	isFlex: true,
	isRepeatable: true,
	listenToWidthResize: true,
	lwc: {
		DeveloperName: "cfACFR_CaseLockError",
		Id: "0RbBm00000054B3KAI",
		MasterLabel: "cfACFR_CaseLockError",
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
							name: "Text",
							element: "outputField",
							size: { isResponsive: false, default: "12" },
							stateIndex: 0,
							class: "nds-col ",
							property: {
								record: "{record}",
								mergeField:
									"%3Cdiv%3E&nbsp;This%20QFR%20submission%20period%20has%20now%20ended.%20If%20you%20want%20to%20start%20or%20resume%20this%20submission,%20please%20contact%20Forms%20Administration.%3C/div%3E",
								card: "{card}"
							},
							type: "text",
							styleObject: { sizeClass: "nds-size_12-of-12" },
							elementLabel: "Text-0"
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
				class: "nds-theme_default ",
				container: { class: "" },
				elementStyleProperties: {},
				inlineStyle: "",
				margin: [],
				padding: [],
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
	title: "ACFR_CaseLockError",
	uniqueKey: "CaseId",
	Id: "0koBm0000000NuHIAU",
	OmniUiCardKey: "ACFR_CaseLockError/Cyrille/1.0",
	OmniUiCardType: "Child"
};
export default definition;
