/**
 * @author Vivek J
 * @date 23-02-2023
 * @objects 
 * @description : Server response wrapper
 */
public with sharing class QIResponseDTO {
    @AuraEnabled
    public String status {get;set;}

    @AuraEnabled
    public String message {get;set;}

    @AuraEnabled
    public String returnValue {get;set;}

    @AuraEnabled
    public String redirectUrl {get;set;}

    public QIResponseDTO(){
        this.status='Success';
        this.message='';
        this.redirectUrl='';
       
    }
}