import { Cell } from "./Cell";

export type GL_Code_Line_Item__c = {
	Id?: string;
	Value__c?: number;
	GL_Code__c?: string;
	Category__c?: string;
};
export type TableCellResult = {
	hardValidation: boolean;
	providerExplanation?: string;
	qaOutcome?: string;
	qaComments?: string;
	id: string;
	value?: number;
	rowDefinitionId?: string;
	category?: string;
};
export type RowDefinition = {
	id: string;
	name?: string;
	parentRowId?: string;
	category?: string;
	type?: string;
	order?: number;
	formula_string?: string;
	depth?: number;
	childRows?: RowDefinition[];
};
export type Row = RowDefinition & {
	entries: Cell[];
	displayEntries: Cell[];
	inlineStyle: string;
	isReadOnly?: boolean;
	parentRow?: Row;
	childRows?: Row[];
	hasInvalidCell: boolean;
};
export type Category = {
	name: string;
	rows: Row[];
	displayRows: Row[];
	order: number;
	isExpanded: boolean;
};
export type ColumnDefinition = {
	id: string;
	name: string;
	showToggle: boolean;
	isEnabled?: boolean;
	data?: TableCellResult[];
	cells?: Cell[];
	hasInvalidCell?: boolean;
};
export type FormulaInfo = {
	sourceRowIds: Set<string>;
	formula(args: Map<string, number>): number;
	targetRowId: string;
};
