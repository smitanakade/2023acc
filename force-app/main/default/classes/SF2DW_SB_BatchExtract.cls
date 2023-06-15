public with sharing class SF2DW_SB_BatchExtract implements Database.Batchable<sObject>, Database.Stateful {

public string sCSVcontent;
public string sfilename = '';
public string semails = '';
    
public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        
List<SF2DW_Export_File_Control__mdt> lfilecontrol = [SELECT DeveloperName, Reporting_Period_Name__c, File_Name__c, Send_to_Email__c 
                                               FROM SF2DW_Export_File_Control__mdt
                                               where DeveloperName = 'SB'];
string sRPName = '';

for(SF2DW_Export_File_Control__mdt thisRP: lfilecontrol)
{
    sRPName = thisRP.Reporting_Period_Name__c;
    sfilename = thisRP.File_Name__c; 
    semails = thisRP.Send_to_Email__c;     
}

//You will only ever get one single record in the Reporting_Period__c list due to the 'WHERE' clause
ID sRPId;
List<Reporting_Period__c> lRP = [SELECT Id FROM Reporting_Period__c where Name = :sRPName];
for(Reporting_Period__c thisRP: lRP)
{
    sRPId = thisRP.Id;
}
 

sCSVcontent = 'Financial Year,Quarter,NAPS Provider ID,Provider Name,NAPS ServiceID,Service Name,QFR Due date,First Submission Date,Last Submission Date - ResiCare Labour Costs & Hours,Date last checked,Date last reasonableness check outcome recorded,Last Reasonableness check outcome,Last Reasonableness check reason (free text),Last reissue reason,Date last notified of - reasonableness check outcome,Date last reissued due to failed reasonableness check outcome,';     // col A - P
sCSVcontent = sCSVcontent +  'Care Exp-LC-Registered nurses,';                                                // col Q Q.2.511111100
sCSVcontent = sCSVcontent +  'Care Exp-LC-Enrolled-licensed nurses NMBA,';                                    // col R Q.2.511111200
sCSVcontent = sCSVcontent +  'Care Exp-LC-Personal care/assistants nursing,';                                 // col S Q.2.511112000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Care Mgmt Staff,';                                                  // col T Q.2.511113000
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Physiotherapist,';                                               // col U Q.2.511114200
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Occupational Therapist,';                                        // col V Q.2.511114500
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Speech Pathologist,';                                            // col W Q.2.511114300
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Podiatrist,';                                                    // col X Q.2.511114600
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Dietetic Care,';                                                 // col Y Q.2.511114100
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Allied Health Assistants,';                                      // col Z Q.2.511114700
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Other allied health,';                                           // col AA Q.2.511114400
sCSVcontent = sCSVcontent +  'Care Exp-LC-AH-Total allied health,';                                           // col AB Q.2.511114000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Diversional/Lifestyle/Recreation/Act Officer,';                     // col AC Q.2.511115000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Other employee staff,';                                             // col AD Q.2.511116000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Total Employee Labour Costs,';                                      // col AE Q.2.511110000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Registered nurses,';                                         // col AF Q.2.511121100
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Enrolled and licensed nurses NMBA,';                         // col AG Q.2.511121200
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Personal care/assistants nursing,';                          // col AH Q.2.511122000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Physiotherapist,';                                           // col AI Q.2.511124200
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Occupational Therapist,';                                    // col AJ Q.2.511124500
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Speech Pathologist,';                                        // col AA Q.2.511124300
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Podiatrist,';                                                // col AK Q.2.511124600
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Dietetic Care,';                                             // col AL Q.2.511124100
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Allied Health Assistants,';                                  // col AM Q.2.511124700
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Other allied health,';                                       // col AN Q.2.511124400
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Total allied health,';                                       // col AO Q.2.511124000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Diversional/Lifestyle/Recreation/Act Officer,';              // col AP Q.2.511125000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Other agency staff costs,';                                  // col AQ Q.2.511126000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Agency-Total Agency Staff Cost Direct Care,';                       // col AR Q.2.511120000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Contract Labour Mgmt entity staff costs,';                          // col AS Q.2.511130000
sCSVcontent = sCSVcontent +  'Care Exp-LC-Total Direct Care Labour Costs,';                                   // col AT Q.2.511100000
sCSVcontent = sCSVcontent +  'Hours-RN-Morning Shift 7am-3pm,';                                               // col AU Q.2H511111110
sCSVcontent = sCSVcontent +  'Hours-RN-Afternoon Shift 3pm-11pm,';                                            // col AV Q.2H511111120
sCSVcontent = sCSVcontent +  'Hours-RN-Overnight Shift 11pm-7am,';                                            // col AW Q.2H511111130
sCSVcontent = sCSVcontent +  'Hours-RN-Total registered nurses,';                                             // col AX Q.2H511111100
sCSVcontent = sCSVcontent +  'Hours-Enrolled-licensed nurses NMBA,';                                          // col AY Q.2H511111200
sCSVcontent = sCSVcontent +  'Hours-Personal care/assistants nursing,';                                       // col BA Q.2H511112000
sCSVcontent = sCSVcontent +  'Hours-Care Management Staff,';                                                  // col BB Q.2H511113000
sCSVcontent = sCSVcontent +  'Hours-AH-Physiotherapist,';                                                     // col BC Q.2H511114200
sCSVcontent = sCSVcontent +  'Hours-AH-Occupational Therapist,';                                              // col BD Q.2H511114500
sCSVcontent = sCSVcontent +  'Hours-AH-Speech Pathologist,';                                                  // col BE Q.2H511114300
sCSVcontent = sCSVcontent +  'Hours-AH-Podiatrist,';                                                          // col BF Q.2H511114600
sCSVcontent = sCSVcontent +  'Hours-AH-Dietetic Care,';                                                       // col BG Q.2H511114100
sCSVcontent = sCSVcontent +  'Hours-AH-Allied Health Assistants,';                                            // col BH Q.2H511114700
sCSVcontent = sCSVcontent +  'Hours-AH-Other allied health,';                                                 // col BI Q.2H511114400
sCSVcontent = sCSVcontent +  'Hours-AH-Total allied health,';                                                 // col BJ Q.2H511114000
sCSVcontent = sCSVcontent +  'Hours-Diversional/Lifestyle/Recreation/Act Officer,';                           // col BK Q.2H511115000
sCSVcontent = sCSVcontent +  'Hours-Other employee staff,';                                                   // col BL Q.2H511116000
sCSVcontent = sCSVcontent +  'Hours-Total Employee Direct Care Worked Hours,';                                // col BM Q.2H511110000
sCSVcontent = sCSVcontent +  'Hours-Agency-RN-Morning Shift 7am-3pm,';                                        // col BN Q.2H511121110
sCSVcontent = sCSVcontent +  'Hours-Agency-RN-Afternoon Shift 3pm-11pm,';                                     // col BO Q.2H511121120
sCSVcontent = sCSVcontent +  'Hours-Agency-RN-Overnight Shift 11pm-7am,';                                     // col BP Q.2H511121130
sCSVcontent = sCSVcontent +  'Hours-Agency-RN-Total registered nurses,';                                      // col BQ Q.2H511121100
sCSVcontent = sCSVcontent +  'Hours-Agency-Enrolled-licensed nurses NMBA,';                                   // col BR Q.2H511121200
sCSVcontent = sCSVcontent +  'Hours-Agency-Personal care/assistants nursing,';                                // col BS Q.2H511122000
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Physiotherapist,';                                              // col BT Q.2H511124200
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Occupational Therapist,';                                       // col BU Q.2H511124500
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Speech Pathologist,';                                           // col BV Q.2H511124300
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Podiatrist,';                                                   // col BW Q.2H511124600
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Dietetic Care,';                                                // col BX Q.2H511124100
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Allied Health Assistants,';                                     // col BY Q.2H511124700
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Other allied health,';                                          // col BZ Q.2H511124400
sCSVcontent = sCSVcontent +  'Hours-Agency-AH-Total allied health,';                                          // col CA Q.2H511124000
sCSVcontent = sCSVcontent +  'Hours-Agency-Diversional/Lifestyle/Recreation/Act Officer,';                    // col CB Q.2H511125000
sCSVcontent = sCSVcontent +  'Hours-Agency-Other agency staff Worked Hours,';                                 // col CC Q.2H511126000
sCSVcontent = sCSVcontent +  'Hours-Agency-Total Agency Staff Worked HoursDirect Care,';                      // col CD Q.2H511120000
sCSVcontent = sCSVcontent +  'Hours-Contract Labour Worked Hours,';                                           // col CE Q.2H511130000
sCSVcontent = sCSVcontent +  'Hours-Total Direct Care Labour Worked Hours,';                                  // col CF Q.2H511100000
sCSVcontent = sCSVcontent +  'Hours-Non-worked hours,';                                                       // col CG Q.2H530000000
sCSVcontent = sCSVcontent +  'Bed Days-Occupied bed days,';                                                   // col CH Q.2D430000000
sCSVcontent = sCSVcontent +  'Bed Days-Available bed days,';                                                  // col CI Q.2D420000000
sCSVcontent = sCSVcontent +  'Minutes-RN care minutes per occupied bed day,';                                 // col CJ Q.2H551000000
sCSVcontent = sCSVcontent +  'Minutes-Enrolled-licensed nurses NMBA care mins/occupied bed day,';             // col CK Q.2H552000000
sCSVcontent = sCSVcontent +  'Minutes-Personal care/assistants nursing care mins/occupied bed day,';          // col CL Q.2H553000000
sCSVcontent = sCSVcontent +  'Minutes-Total direct care mins worked/occupied bed day,';                       // col CM Q.2H550000000
sCSVcontent = sCSVcontent + '\r\n';                                                                           // Carriage Return

    string subm = 'Submitted';
string query = 'select id,form__r.type__c,form__r.Reporting_Period__c,Form__r.Account__r.Name, Form__r.Account__r.Integration_ID__c, Service__c, Service__r.Name, Service__r.Integration_ID__c, Service__r.AccountId,Form__r.First_Submission_Date__c,Form__r.Latest_Submission_Date__c,Form__r.Submission_Due_Date__c,Form__r.Reasonableness_Check_Outcome__c, Form__r.Reasonableness_Check_Reason__c,'
 + '(select id,name,GL_Code__r.Business_ID__c,Value__c,Service_Line_Item__r.Service_Category__c,Service_Line_Item__r.Form__c from GL_Code_Line_Items__r) from Service_Line_Item__c' + 
+ ' where   form__r.Reporting_period__c = :sRPid and ' + 'form__r.case__r.status=:subm and'+
+ ' Form__r.Type__c = \'' + 'Residential Labour Costs and Hours' + '\' and Service__c!=null';  
    
return Database.getQueryLocator(Query);
    }
public void execute(Database.BatchableContext bc, List<Service_Line_Item__c> scope){

string sGLCodes;
string sService;
    
for(Service_Line_Item__c sli: scope)
{ sli.Form__r.Account__r.Name=sli.Form__r.Account__r.Name.replace(',',' ');
    sCSVcontent = sCSVcontent + '2022-23,Quarter2,' + sli.Form__r.Account__r.Integration_ID__c + ',' + sli.Form__r.Account__r.Name + ','+ sli.Service__r.Integration_ID__c + ',' + sli.Service__r.Name + ',' +  sli.Form__r.Submission_Due_Date__c + ',' + sli.Form__r.First_Submission_Date__c + ',' + sli.Form__r.Latest_Submission_Date__c + ',' +  'unmapped,unmapped,'  + sli.Form__r.Reasonableness_Check_Outcome__c + ',' + sli.Form__r.Reasonableness_Check_Reason__c + ',' + 'unmapped,unmapped,unmapped'; 
//    sFormId = sli.Form__c;  DAP I dont think we need this variable
    sService = sli.Service__c;
    sGLCodes = getGLCodes(sli.GL_Code_Line_Items__r, sService);
//    sGLCodes = getGLCodes(sli.GL_Code_Line_Items__r, sFormId, sService);   Remove Form Id from the Method
    sCSVcontent = sCSVcontent + ',' + sGLCodes;    
     

}  // end SLI for loop     
        
    }
public void finish(Database.BatchableContext bc){
// execute any post-processing operations      
string ssub = 'Daily Extract of ' + sfilename;
string sbody = 'test body';
//string sbody = 'Daily Extract of ' + sfilename + ' for Forms Created between : ' + dFormStart + ' - ' + dFormEnd;
string stestmail = SF2DW_Extract_Email_Helper.EmailFile(sCSVcontent, sfilename, semails, ssub, sbody);        
        
}
public static string  getGLCodes(List<GL_Code_Line_Item__c> lGLCodes, string sServiceId) {

string Q_2_511111100 = '0';
string Q_2_511111200 = '0';
string Q_2_511112000 = '0';
string Q_2_511113000 = '0';
string Q_2_511114200 = '0';
string Q_2_511114500 = '0';
string Q_2_511114300 = '0';
string Q_2_511114600 = '0';
string Q_2_511114100 = '0';
string Q_2_511114700 = '0';
string Q_2_511114400 = '0';
string Q_2_511114000 = '0';
string Q_2_511115000 = '0';
string Q_2_511116000 = '0';
string Q_2_511110000 = '0';
string Q_2_511121100 = '0';
string Q_2_511121200 = '0';
string Q_2_511122000 = '0';
string Q_2_511124200 = '0';
string Q_2_511124500 = '0';
string Q_2_511124300 = '0';
string Q_2_511124600 = '0';
string Q_2_511124100 = '0';
string Q_2_511124700 = '0';
string Q_2_511124400 = '0';
string Q_2_511124000 = '0';
string Q_2_511125000 = '0';
string Q_2_511126000 = '0';
string Q_2_511120000 = '0';
string Q_2_511130000 = '0';
string Q_2_511100000 = '0';
string Q_2H511111110 = '0';
string Q_2H511111120 = '0';
string Q_2H511111130 = '0';
string Q_2H511111100 = '0';
string Q_2H511111200 = '0';
string Q_2H511112000 = '0';
string Q_2H511113000 = '0';
string Q_2H511114200 = '0';
string Q_2H511114500 = '0';
string Q_2H511114300 = '0';
string Q_2H511114600 = '0';
string Q_2H511114100 = '0';
string Q_2H511114700 = '0';
string Q_2H511114400 = '0';
string Q_2H511114000 = '0';
string Q_2H511115000 = '0';
string Q_2H511116000 = '0';
string Q_2H511110000 = '0';
string Q_2H511121110 = '0';
string Q_2H511121120 = '0';
string Q_2H511121130 = '0';
string Q_2H511121100 = '0';
string Q_2H511121200 = '0';
string Q_2H511122000 = '0';
string Q_2H511124200 = '0';
string Q_2H511124500 = '0';
string Q_2H511124300 = '0';
string Q_2H511124600 = '0';
string Q_2H511124100 = '0';
string Q_2H511124700 = '0';
string Q_2H511124400 = '0';
string Q_2H511124000 = '0';
string Q_2H511125000 = '0';
string Q_2H511126000 = '0';
string Q_2H511120000 = '0';
string Q_2H511130000 = '0';
string Q_2H511100000 = '0';
string Q_2H530000000 = '0';
string Q_2D430000000 = '0';
string Q_2D420000000 = '0';
string Q_2H551000000 = '0';
string Q_2H552000000 = '0';
string Q_2H553000000 = '0';
string HROBD ='0';
string Q_2H550000000 = '0';

for(GL_Code_Line_Item__c thisGLCodeRecord: lGLCodes)
{
    
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511111100') 
             {Q_2_511111100 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511111200') 
             {Q_2_511111200 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511112000') 
             {Q_2_511112000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511113000') 
             {Q_2_511113000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114200') 
             {Q_2_511114200 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114500') 
             {Q_2_511114500  = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114300') 
             {Q_2_511114300 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114600') 
             {Q_2_511114600 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114100') 
             {Q_2_511114100  = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114700') 
             {Q_2_511114700 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114400') 
             {Q_2_511114400 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511114000') 
             {Q_2_511114000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511115000') 
             {Q_2_511115000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511116000') 
             {Q_2_511116000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511110000') 
             {Q_2_511110000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511121100') 
             {Q_2_511121100 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511121200') 
             {Q_2_511121200  = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511122000') 
             {Q_2_511122000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124200') 
             {Q_2_511124200 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124500') 
             {Q_2_511124500 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124300') 
             {Q_2_511124300 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124600') 
             {Q_2_511124600 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124100') 
             {Q_2_511124100 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124700') 
             {Q_2_511124700 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124400') 
             {Q_2_511124400 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511124000') 
             {Q_2_511124000 = String.valueOf(thisGLCodeRecord.Value__c);}
             If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511125000') 
             {Q_2_511125000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511126000') 
             {Q_2_511126000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511120000') 
             {Q_2_511120000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511130000') 
             {Q_2_511130000  = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2.511100000') 
             {Q_2_511100000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511111110') 
             {Q_2H511111110= String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511111120') 
             {Q_2H511111120 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511111130') 
             {Q_2H511111130 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511111100') 
             {Q_2H511111100 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511111200') 
             {Q_2H511111200 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511112000') 
             {Q_2H511112000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511113000') 
             {Q_2H511113000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114200') 
             {Q_2H511114200 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114500') 
             {Q_2H511114500 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114300') 
             {Q_2H511114300 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114600') 
             {Q_2H511114600 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114100') 
             {Q_2H511114100 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114700') 
             {Q_2H511114700 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114400') 
             {Q_2H511114400 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511114000') 
             {Q_2H511114000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511115000') 
             {Q_2H511115000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511116000') 
             {Q_2H511116000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511110000') 
             {Q_2H511110000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511121110') 
             {Q_2H511121110 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511121120') 
             {Q_2H511121120 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511121130') 
             {Q_2H511121130 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511121100') 
             {Q_2H511121100 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511121200') 
             {Q_2H511121200 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511122000') 
             {Q_2H511122000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124200') 
             {Q_2H511124200 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124500') 
             {Q_2H511124500 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124300') 
             {Q_2H511124300 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124600') 
             {Q_2H511124600 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124100') 
             {Q_2H511124100 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124700') 
             {Q_2H511124700 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124400') 
             {Q_2H511124400 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511124000') 
             {Q_2H511124000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511125000') 
             {Q_2H511125000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511126000') 
             {Q_2H511126000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511120000') 
             {Q_2H511120000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511130000') 
             {Q_2H511130000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H511100000') 
             {Q_2H511100000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H530000000') 
             {Q_2H530000000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2D430000000') 
             {Q_2D430000000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2D420000000') 
             {Q_2D420000000= String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H551000000') 
             {Q_2H551000000 = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H552000000') 
             {Q_2H552000000 = String.valueOf(thisGLCodeRecord.Value__c);}
        If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H553000000') 
             {Q_2H553000000 = String.valueOf(thisGLCodeRecord.Value__c);}
        If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'HROBD') 
             {HROBD = String.valueOf(thisGLCodeRecord.Value__c);}
         If (thisGLCodeRecord.GL_Code__r.Business_ID__c == 'Q.2H550000000') 
             {Q_2H550000000= String.valueOf(thisGLCodeRecord.Value__c);}
            
}   // end of for loop  
string sConcatall; // = sGL310100 + ',' + sGL320200 + ',' + sGL310300 + '\r\n'; 
sConcatall = Q_2_511111100 + ',';                // Col F
sConcatall = sConcatall + Q_2_511111200 + ',';   // Col H
sConcatall = sConcatall + Q_2_511112000 + ',';   // Col I
sConcatall = sConcatall + Q_2_511113000 + ',';   // Col J
sConcatall = sConcatall + Q_2_511114200 + ',';   // Col K
sConcatall = sConcatall + Q_2_511114500 + ',';   // Col L
sConcatall = sConcatall + Q_2_511114300 + ',';   // Col M
sConcatall = sConcatall + Q_2_511114600 + ',';   // Col N
sConcatall = sConcatall + Q_2_511114100 + ',';   // Col O
sConcatall = sConcatall + Q_2_511114700 + ',';   // Col P
sConcatall = sConcatall + Q_2_511114400 + ',';   // Col Q
sConcatall = sConcatall + Q_2_511114000 + ',';   // Col R
sConcatall = sConcatall + Q_2_511115000 + ',';   // Col S
sConcatall = sConcatall + Q_2_511116000 + ',';   // Col T
sConcatall = sConcatall + Q_2_511110000 + ',';   // Col U
sConcatall = sConcatall + Q_2_511121100 + ',';   // Col V
sConcatall = sConcatall + Q_2_511121200 + ',';   // Col W
sConcatall = sConcatall + Q_2_511122000 + ',';   // Col X
sConcatall = sConcatall + Q_2_511124200 + ',';   // Col Y
sConcatall = sConcatall + Q_2_511124500 + ',';   // Col Z
sConcatall = sConcatall + Q_2_511124300 + ',';   // Col AA
sConcatall = sConcatall + Q_2_511124600 + ',';   // Col AB
sConcatall = sConcatall + Q_2_511124100 + ',';   // Col AC
sConcatall = sConcatall + Q_2_511124700 + ',';   // Col AD
sConcatall = sConcatall + Q_2_511124400 + ',';   // Col AE
sConcatall = sConcatall + Q_2_511124000 + ',';   // Col AF
sConcatall = sConcatall + Q_2_511125000 + ',';   // Col AG
sConcatall = sConcatall + Q_2_511126000 + ',';   // Col AH
sConcatall = sConcatall + Q_2_511120000 + ',';   // Col AI
sConcatall = sConcatall + Q_2_511130000 + ',';   // Col AJ
sConcatall = sConcatall + Q_2_511100000 + ',';   // Col AK
sConcatall = sConcatall + Q_2H511111110 + ',';   // Col AL
sConcatall = sConcatall + Q_2H511111120 + ',';   // Col AM
sConcatall = sConcatall + Q_2H511111130 + ',';   // Col AN
sConcatall = sConcatall + Q_2H511111100 + ',';   // Col AO
sConcatall = sConcatall + Q_2H511111200 + ',';   // Col AP
sConcatall = sConcatall + Q_2H511112000 + ',';   // Col AQ
sConcatall = sConcatall + Q_2H511113000 + ',';   // Col AR
sConcatall = sConcatall + Q_2H511114200 + ',';   // Col AS
sConcatall = sConcatall + Q_2H511114500 + ',';   // Col AT
sConcatall = sConcatall + Q_2H511114300 + ',';   // Col AU
sConcatall = sConcatall + Q_2H511114600 + ',';   // Col AV
sConcatall = sConcatall + Q_2H511114100 + ',';   // Col AW
sConcatall = sConcatall + Q_2H511114700 + ',';   // Col AX
sConcatall = sConcatall + Q_2H511114400 + ',';   // Col AY
sConcatall = sConcatall + Q_2H511114000 + ',';   // Col AZ
sConcatall = sConcatall + Q_2H511115000 + ',';   // Col BA
sConcatall = sConcatall + Q_2H511116000 + ',';   // Col BB
sConcatall = sConcatall + Q_2H511110000 + ',';   // Col BC
sConcatall = sConcatall + Q_2H511121110 + ',';   // Col BD
sConcatall = sConcatall + Q_2H511121120 + ',';   // Col BE
sConcatall = sConcatall + Q_2H511121130 + ',';   // Col BF
sConcatall = sConcatall + Q_2H511121100 + ',';   // Col BG
sConcatall = sConcatall + Q_2H511121200 + ',';   // Col BH
sConcatall = sConcatall + Q_2H511122000 + ',';   // Col BI
sConcatall = sConcatall + Q_2H511124200 + ',';   // Col BJ
sConcatall = sConcatall + Q_2H511124500 + ',';   // Col BK
sConcatall = sConcatall + Q_2H511124300 + ',';   // Col BL
sConcatall = sConcatall + Q_2H511124600 + ',';   // Col BM
sConcatall = sConcatall + Q_2H511124100 + ',';   // Col BN
sConcatall = sConcatall + Q_2H511124700 + ',';   // Col BO
sConcatall = sConcatall + Q_2H511124400 + ',';   // Col BP
sConcatall = sConcatall + Q_2H511124000 + ',';   // Col BQ
sConcatall = sConcatall + Q_2H511125000 + ',';   // Col BR
sConcatall = sConcatall + Q_2H511126000 + ',';   // Col BS
sConcatall = sConcatall + Q_2H511120000 + ',';   // Col BT
sConcatall = sConcatall + Q_2H511130000 + ',';   // Col BU
sConcatall = sConcatall + Q_2H511100000 + ',';   // Col BV
sConcatall = sConcatall + Q_2H530000000 + ',';   // Col BW
sConcatall = sConcatall + Q_2D430000000 + ',';   // Col BX
sConcatall = sConcatall + Q_2D420000000 + ',';   // Col BY
sConcatall = sConcatall + Q_2H551000000 + ',';   // Col BZ
sConcatall = sConcatall + Q_2H552000000 + ',';   // Col CA
sConcatall = sConcatall + Q_2H553000000 + ',';   // Col CB
sConcatall = sConcatall + Q_2H550000000 + ',';   // Col CC

sConcatall = sConcatall + '\r\n';   // Carriage Return
    
System.debug('GLCodes:' + sConcatall); 
return sConcatall;
}   // end of method
 
}