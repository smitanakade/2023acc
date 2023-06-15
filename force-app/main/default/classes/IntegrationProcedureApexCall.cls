/**
* author: Daniel Clift
* date: 18/08/2022
* description: handles integration procedure remote actions, calling apex based on string passed as action 
**/

global class IntegrationProcedureApexCall implements Callable {
    public Object call(String action, Map<String, Object> args) {

        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');

        return invokeMethod(action, input, output, options);
    }

    private Object invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        switch on methodName {
            when 'RunCER' {
                Database.executeBatch(new CEIAlgorithmBatch(), 200);
            }
            when else {
                System.debug('MethodName: ' + methodName + ', is not recognised');
            }
        }
        return null;
    }
}