/*******************************************************************************************
 * @Name             IntegrationProcedureInvocable
 * @testClass IntegrationProcedureInvocableTest
 * @Author           Gabriel Piragibe Cova Leda de Almeida
 * @Date
 * @Story#           TBD
 * @LWC Component    None
 * @Description		 Calculates CER rating
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version       Developer                                Date                Description
 *-------------------------------------------------------------------------------------------
 *  1.0     	 Gabriel Piragibe Cova Leda de Almeida              Initial Creation
 *******************************************************************************************/
public with sharing class IntegrationProcedureInvocable {
	@InvocableMethod(label='Call IP From Flow')
	public static List<IntegrationProcedureOutput> runIntegrationServiceInvocable(
		List<IntegrationProcedureInput> input
	) {
		IntegrationProcedureOutput ipResult = new IntegrationProcedureOutput();
		List<IntegrationProcedureOutput> results = new List<IntegrationProcedureOutput>();
		Set<Id> cerIds = new Set<Id>();

		for (IntegrationProcedureInput rec : input) {
			Map<String, Object> ipRequest = (Map<String, Object>) System.JSON.deserializeUntyped((String) rec.input[0]);

			if (ipRequest.get('Domain') == 'callCER') {
				cerIds.add((Id) ipRequest.get('CERId'));
			} else {
				ipResult.output = JSON.serialize(
					omnistudio.IntegrationProcedureService.runIntegrationService(
						rec.procedureAPIName,
						new Map<String, Object>{ 'Input' => rec.input },
						new Map<String, Object>()
					)
				);
			}

			results.add(ipResult);
		}

		if (!cerIds.isEmpty()) {
			CEIAlgorithmHelper.recalculateCER(cerIds);
		}

		return results;
	}

	public class IntegrationProcedureInput {
		@InvocableVariable(label='Procedure Name')
		public String procedureAPIName;
		@InvocableVariable(label='Input')
		public List<String> input;
	}

	public class IntegrationProcedureOutput {
		@InvocableVariable(label='Output')
		public String output;
	}
}
