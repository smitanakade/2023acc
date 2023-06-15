import { LightningElement,api,wire } from 'lwc';
import {OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
const ApexControllerClassName = "srqiOmniscriptLWCRichText";

export default class SRQI_RegulatoryRichText extends OmniscriptBaseMixin(LightningElement)  {

    @api recordId;
    @api records;
    @api record;
    @api disable;
    output="";
    asterisk='*';
    charCount = 8000;
    richText=0;
    text =' is required and 8000 charachter limit';
    @api checkValidity() {
    
      this.richText=this.template.querySelector('.richText').value.length;
      if(this.richText <= this.charCount ){
          if(this.template.querySelector('.richText').value ==="" && this.records !== "Progress"){
            return false;
          }
          else if (this.template.querySelector('.richText').value ==="" && this.records === "Progress"){
            return true;
          }
          else if (this.template.querySelector('.richText').value !=="" && this.richText > this.charCount){
            return false;
          }
          else{
          return true ;
          }
      } else{
        return false;
    }
    }
   async connectedCallback() {
    if(this.records.includes("Progress")){
      this.asterisk='';
      this.text = '8000 charachter limit';
    }
    if(this.recordId){
        if(this.records.includes("Reason for issuing the regulatory decision") ){
        await this.getResponseforIssue();}
        if(this.records.includes("Decision Details")){
          await this.getDecisionDetails();}
        if(this.records.includes("Progress")){
          await this.getProgressDetails();}
      }
    }
    async getResponseforIssue() {
        let args = {
          recordid: this.recordId,
          OmniSection: this.records,

        };
        let options = {};
        let remoteCallParams = {
          input: JSON.stringify(args),
          sClassName: ApexControllerClassName,
          sMethodName: "getResponseforIssue",
          options: JSON.stringify(options),
        };
        let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
        if (error) {
          console.error(
            `An error occurred in a remote call. Details: ${JSON.stringify(result)}`
          );
        }
        else{
            this.output = result.getResponseforIssue;

        }
        return result.datatableDefinition;
      }
      async getDecisionDetails() {
        let args = {
          recordid: this.recordId,
          OmniSection: this.records,

        };
        let options = {};
        let remoteCallParams = {
          input: JSON.stringify(args),
          sClassName: ApexControllerClassName,
          sMethodName: "getDecisionDetails",
          options: JSON.stringify(options),
        };
        let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
        if (error) {
          console.error(
            `An error occurred in a remote call. Details: ${JSON.stringify(result)}`
          );
        }
        else{
            this.output="";
            this.output = result.getDecisionDetails;

        }
        return result.datatableDefinition;
      }
      async getProgressDetails() {
        let args = {
          recordid: this.recordId,
          OmniSection: this.records,
        };
        let options = {};
        let remoteCallParams = {
          input: JSON.stringify(args),
          sClassName: ApexControllerClassName,
          sMethodName: "getProgressDetails",
          options: JSON.stringify(options),
        };
        let { result, error } = await this.omniRemoteCall(remoteCallParams, false);
        if (error) {
          console.error(
            `An error occurred in a remote call. Details: ${JSON.stringify(result)}`
          );
        }
        else{
            this.output="";
            this.output = result.getProgressDetails;   

        }
        return result.datatableDefinition;
      }
      handlefocus(){
        if(this.record){
        if(this.record== true){
          this.disable="true";
        }
      }
    }
    handleBlur(evt) {
    this.omniValidate();
      this.omniUpdateDataJson(evt.target.value);
    }


}