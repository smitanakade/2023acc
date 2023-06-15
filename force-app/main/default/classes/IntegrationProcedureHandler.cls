/**
* author: Daniel Clift
* date: 18/08/2022
* description: calls integration procedures
**/

public with sharing class IntegrationProcedureHandler {

    public static final String RUNCM = 'SRQI_CareMinutes_Periodical';
    public static final String RUNQI = 'SRQI_QIRatingCalculation';
    public static final String RUNCER = 'CER_Hybrid';
    public static final String RUNSRH = 'SRQI_StarRatingCalculation';
    public static final String RUNALLSUBDOMAIN = 'Recalculation_AllSubdomains';
    
    public static final String APEXIPHELPER = 'ApexIpHelper_ApexIpHelper';//Staging IP
    
    // initialise variables
    public Map<String, Object> ipInput = new Map<String, Object> (); // used to pass data to IP
    public Map<String, Object> ipOptions = new Map<String, Object> {'queueableChainable' => true}; // additional options, can be used to debug
    
    public String procedureName = '';
    
    public IntegrationProcedureHandler(String procedureName){
        this.procedureName = procedureName;
    }
    public IntegrationProcedureHandler(String procedureName, Map<String, Object> input){
        this.procedureName = procedureName;
        if(input != null){
            this.ipInput = input;
        }
    }
    public IntegrationProcedureHandler(String procedureName, Map<String, Object> input, Map<String, Object> ipOptions){
        this.procedureName = procedureName;
        if(input != null){
            this.ipInput = input;
        }
        if(ipOptions != null){
            this.ipOptions = ipOptions;
        }
    }
    
    public void executeIp(){
        
        Map<String, Object> inputs = this.ipInput;
        inputs.put('actionName', this.procedureName);// pass the calculation IP as an action name to the Staging IP
        //The Staging Ip will take care of executing the calculation IPs and log the errors to Application Log.
        omnistudio.IntegrationProcedureService.runIntegrationProcedureQueueable(APEXIPHELPER, this.ipInput, this.ipOptions);
    }
}