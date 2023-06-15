public with sharing class SF2DW_Extract_Email_Helper {
//  This class was developed as part of the Salesforce to Data Warehouse
//  TEMPORARY data migration deployment
//  the class/method is designed to send an email with an attachment to one or more email addresses

public static string EmailFile(string sfiledata, string sfilename, string sInpEmail, string sSubject, string sBodyText) {

Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
blob csvBlob = Blob.valueOf(sfiledata);
string fname = sfilename;
csvAttc.setFileName(fname);
csvAttc.setBody(csvBlob);
Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
// Multiple email adresses can be sent in as single comma delimited string but they need to be converted to a list
List<String> toAddresses = sInpEmail.split(',');

email.setSubject(sSubject);
email.setToAddresses( toAddresses );
email.setPlainTextBody(sBodyText);
email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});


return 'An email has been sent to ' + toAddresses;
}  
    
  
}