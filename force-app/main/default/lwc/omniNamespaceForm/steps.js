/**
 * @type {Array<[string, import('./types').Step]>}
 */
const QFR_STEPS = [
	{
		label: "Before You Start",
		name: "STBeforeYouStart",
		status: "inactive"
	},
	{
		label: "Provider Contacts",
		name: "STProviderContact",
		status: "inactive"
	},
	{
		label: "Residential Viability and Prudential Reporting",
		name: "ResidentialProviderFinancialPerformanceSurvey",
		status: "inactive"
	},
	{
		label: "Home Care Viability and Prudential Reporting",
		name: "STViabiltyQuestionsHomeCareProvider",
		status: "inactive"
	},
	{
		label: "Approved Provider Quarterly Financial Statements",
		name: "STApprovedProviderQuarterlyFinancialStatements",
		status: "inactive"
	},
	{
		label: "Residential Labour Costs and Hours",
		name: "STResidentialLabourCostsandHours",
		status: "inactive"
	},
	{
		label: "Home Care Labour Costs and Hours",
		name: "STHomeCareLabourCostsAndHours",
		status: "inactive"
	},
	{
		label: "Residential Food and Nutrition Reporting",
		name: "STFoodandNutritionReporting",
		status: "inactive"
	},
	{
		label: "NATSIFACP Food and Nutrition Reporting",
		name: "NATSIFACPFoodandNutritionReporting",
		status: "inactive"
	},
	{
		label: "MPS Food and Nutrition Reporting",
		name: "MPSFoodandNutritionReporting",
		status: "inactive"
	},
	{
		label: "Declaration and Submission",
		name: "STQFRDeclarationAndSubmission",
		status: "inactive"
	}
].map((step) => {
	return [step.name, step];
});

export { QFR_STEPS };
