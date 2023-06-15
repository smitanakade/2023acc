public with sharing class GPMSCodeGenerator {
	@InvocableMethod
    public static List<String> verifyCode(List<Integer> length) {
        List<String> generatedCode = new List<String>();
        try{
            generatedCode = generateCode(Length);
        } 
        catch (MathException exp) {
            dohagedcare.Logger.error(exp.getMessage(),exp, 'GPMS').Log();
            generatedCode.add('Error'); 
        }
        return generatedCode;
        
    }
    private static List<String> generateCode (List<Integer> length) {        
        list<string> generatedCode = new list<string>();
        Integer randomCode = Math.round((Math.random()*Math.pow(10, Length[0])));
        String codeToString = string.valueOf(randomCode);
        Integer len = codeToString.length();
        For (Integer i=0;i<(Length[0]-len);i++) {
            codeToString = '0'+codeToString;
        }
        generatedCode.add(codeToString);
        return generatedCode;
    }
}