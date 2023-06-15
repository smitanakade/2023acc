/**
 * @author Rami Zuhairi
 * @date 08/2022
 * @objects Question_Section__c, Question_Library__c, Section_Library__c, Question_Category__c
 * @description LWC JS to make dynamic read and get the required data for Nav bar so when the user delete or add new section,
 * it will reflect directly on the LWC component
 */
import { api, wire, LightningElement } from "lwc";
import getFormSections from "@salesforce/apex/SRQIQuestionDataCaptureFormController.getFormSections";
import { CurrentPageReference } from "lightning/navigation";
import getValidationErrorSetting from "@salesforce/apex/SRQIQuestionDataCaptureFormController.getValidationErrorSetting";
import isShowFieldsReadOnly from "@salesforce/apex/SRQIQuestionDataCaptureFormController.isShowFieldsReadOnly";
import isDraftVersionRequiredForAmendment from "@salesforce/apex/SRQIQuestionDataCaptureFormController.isDraftVersionRequiredForAmendment";
import { toSentenceCase } from "c/srqiQuestionDataCaptureFormUtils";
import getQIStatus from "@salesforce/apex/SRQIQuestionDataCaptureFormController.getQIStatus";
import isSubmitted from "@salesforce/apex/SRQISubmissionController.isSubmitted";
import { subscribe, MessageContext } from "lightning/messageService";
import BUTTON_CLICKED_CHANNEL from "@salesforce/messageChannel/Button_Clicked__c";
import VERSION_MESSAGE from "@salesforce/messageChannel/Version_Message__c";

// Constants
const questionListComponent = "c-srqi-question-list";
const timeOutNumber = 100;
const QIT_LABEL = "Quality Indicator Targets";
const QIT_TITLE_REPLACEMENT = "Set up QI Target/s";
const activeClass = "slds-is-active";
const qidCompleteStatus = "Completed";

export default class srqiQuestionDataCaptureForm extends LightningElement{
  qiSummaryId;
  qiSummaryVersionId;
  @api questionCategory;
  questionSections;
  questionSectionLength;
  selectedQuestionSectionType;
  selectedQuestionSectionTypeIndex = 0;
  validationErrorSetting;
  isInitialPageLoad = true;
  isSubmission = false;
  submissionClass;
  isReadOnly = false;
  isDraftVersionRequired = false;
  recordTypeId;
  @api reponse = [];
  renderedCallbackFlag = false;
  
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.qiSummaryId = currentPageReference.state?.qisid;
    }
  }

  @wire(MessageContext)
  messageContext;

  subscribeToMessageChannels() {
    // Listen to buttons on the banner and handle the payload
    subscribe(
      this.messageContext,
      BUTTON_CLICKED_CHANNEL,
      (message) => this.handleMessage(message)
    );

    // Listen to version changes 
    subscribe(
      this.messageContext,
      VERSION_MESSAGE,
      (message) => this.handleVersionChange(message)
    );
  }

  async connectedCallback() {
    try {  
      this.subscribeToMessageChannels();
      await this.setIsReadOnly();
      await this.setIsDraftVersionRequired();
      this.validationErrorSetting = await getValidationErrorSetting();
      this.questionSections = await getFormSections({
        category: this.questionCategory,
        qiSummaryId: this.qiSummaryId
      });
      const submissionSubmitted = await isSubmitted({
        qisId: this.qiSummaryId
      });
      if (submissionSubmitted) {
        this.submissionClass = qidCompleteStatus;
      }
 
      // Add property to questionSection objects that formats the displayed label as sentence case
      this.questionSections = this.questionSections.map((questionSection) => {
        if (questionSection.Type__c === QIT_LABEL) {
          return {
            ...questionSection,
            formattedLabel: QIT_TITLE_REPLACEMENT
          };
        }
        return {
          ...questionSection,
          formattedLabel: toSentenceCase(questionSection.Type__c)
        };
      });

      if (this.questionSections && this.questionSections.length > 0) {
        this.selectedQuestionSectionType = this.questionSections[0].Type__c;
        this.questionSectionLength = this.questionSections.length;
        this.reponse = await getQIStatus({
          summaryId: this.qiSummaryId
        });
        
        let i =0;
        this.questionSections = this.questionSections.map((ques) => {
          const tempid = ques.Type__c.replace(/\s/g, "" );
          const rscTempid= this.removeSpecialCharacters(tempid);
          ques = { ...ques,id:rscTempid};
          i+=1;
          const matchingItem = this.reponse.find(
            (rep) => rep.RecordType.Name === ques.Type__c
          );
          if (matchingItem) {
            ques = { ...ques, ...matchingItem };
          }
          return ques;
        });

      }
    } catch (error) {
      console.error(error.body.message);
    }
  }
  removeSpecialCharacters(inputString) {
    // Regular expression pattern to match special characters
    var specialCharPattern = /[!@#$%^&*(),.?":{}|<>]/;
    if(specialCharPattern.test(inputString)){
        const tempstring =inputString.replace(specialCharPattern, "");
        return  tempstring.replace(specialCharPattern, "");
    }
    else{
        return inputString;
    }
  }
  renderedCallback() {
    if (this.renderedCallbackFlag) {
      return;
    }
    this.renderedCallbackFlag = true;
    const container = this.template.querySelector('[data-id="PressureInjuries"]');
    if (container) {
      this.addErrorMessagesToDOM();
    }
    this.renderedCallbackFlag = false;
  }

  addErrorMessagesToDOM() {
    this.questionSections.forEach((ques) => {
      if (ques.Error_Flag__c && ques.Status__c !== 'Completed') {
        const tempid = ques.Type__c.replace(/\s/g, '');
        const rscTempid= this.removeSpecialCharacters(tempid);
        const container = this.template.querySelector('[data-id="' + rscTempid + '"]');
        const subContainer = document.querySelector('#p' + rscTempid);
        if (!subContainer) {
          const newElement = document.createElement('p');
          newElement.id = 'p'+rscTempid;
          newElement.textContent = ques.Error_Flag__c;
          newElement.style.color = ((ques.Error_Flag__c.replace(/\s/g, "" ) === 'WarningsReturned') ? '#ffa400' : 'red');
          container.className += " "+ques.Error_Flag__c.replace(/\s/g, "" );
          container.appendChild(newElement);
        }
      }
    });
  }

  handleVersionChange(message) {
    const versionId = message.qisvId;
    if (this.qiSummaryVersionId != versionId) {
      this.qiSummaryVersionId = versionId;

      // Update read only status
      this.setIsReadOnly();

      // Fetch form and go back to first section
      this.isInitialPageLoad = true; // Set initial page load variable so it doesn't try to save after version change
      const mockEvent = { detail: 0 };
      this.handleNavigation(mockEvent);
    }
  }

  //determine if 'Save' or 'Close' was clicked in qiReportingSummaryBanner
  async handleMessage(message) {
    if (message.buttonClicked !== "close") {
      this.questionSections = this.questionSections.map((ques) => {
        const matchingItem = message.buttonClicked.find(
          (butn) => butn.Type === ques.Type__c
        );
      
        if (matchingItem && matchingItem.Status__c !== 'Completed') {
          ques = {
            ...ques,
            Status__c: matchingItem.Error_Flag__c.replace(/\s/g, "")
          };
          
          if (ques.Error_Flag__c) {
            const tempid = ques.Type__c.replace(/\s/g, '');
            const rscTempid= this.removeSpecialCharacters(tempid);
            const container = this.template.querySelector('[data-id="' + rscTempid + '"]');
            const subContainer = document.querySelector('#p' + rscTempid);
            if (!subContainer) {
              const newElement = document.createElement('p');
              newElement.id = 'p'+rscTempid;
              newElement.textContent = ques.Error_Flag__c;
              newElement.style.color = (ques.Error_Flag__c.replace(/\s/g, "" ) === 'WarningsReturned' ? '#ffa400' : 'red');
              container.appendChild(newElement);
            }
          }
        }
        if (ques.Status__c !== 'In Progress') {
          const tempid = ques.Type__c.replace(/\s/g, '');
          const rscTempid= this.removeSpecialCharacters(tempid);
          const container = this.template.querySelector('[data-id="' + rscTempid + '"]');
          const subContainer = document.querySelector('#p' + rscTempid);
          if (!subContainer) {
            const newElement = document.createElement('p');
            newElement.id = 'p'+rscTempid;
            newElement.textContent = ques.Status__c;
            newElement.className = ques.Status__c.replace(/\s/g, "");
            container.appendChild(newElement);
          }
        }

        return ques;
      });
    }
  }

  /**
   * Navigates to the selected section. If required as set in the event parameter, saves the data beforehand.
   * @param {*} event
   */
  async handleSelectQuestionSection(event) {
    if (event.detail.name) {
      if (event.detail.name === "Submission") {
        // Check that we are not coming from the submission page (in which case we don't have any data to save)
        if (this.selectedQuestionSectionType !== undefined) {
          // Save data on current section and check with user if they have unsaved changes
          const shouldNavigate = await this.template
            .querySelector(questionListComponent)
            .handleSaveData(true);
          if (!shouldNavigate) {
            return;
          }
        }
        
        // Now proceed to show submission page
        this.isSubmission = true;
        if (this.submissionClass !== qidCompleteStatus) {
          this.submissionClass = activeClass;
        }
        this.selectedQuestionSectionType = undefined;
        setTimeout(
          () =>
            this.template.querySelector("c-srqi-submission").fetchDomainInfo(),
          timeOutNumber
        );
      } else {
        this.isSubmission = false;
        if (this.submissionClass !== qidCompleteStatus) {
          this.submissionClass = null;
        }

        // Ignore initial form load - we don't want to save data at this point
        if (this.isInitialPageLoad) {
          this.isInitialPageLoad = false;

          // Navigate to new section
          this.selectedQuestionSectionType = event.detail.name;
          this.selectedQuestionSectionTypeIndex =
            this.questionSections.findIndex(
              (section) => section.Type__c === this.selectedQuestionSectionType
            );
          setTimeout(
            () =>
              this.template
                .querySelector(questionListComponent)
                .fetchQuestionsAndResponse(),
            100
          );
          return;
        }

        // Ignore navigation to same section from that section
        if (event.detail.name === this.selectedQuestionSectionType) {
          return;
        }
        
        // Check that we are not coming from the submission page (in which case we don't have any data to save)
        if (this.selectedQuestionSectionType !== undefined) {
          // Save data on current section and check with user if they have unsaved changes
          const shouldNavigate = await this.template
            .querySelector(questionListComponent)
            .handleSaveData(true);
          if (!shouldNavigate) {
            return;
          }
        }

        // Navigate to new section
        this.selectedQuestionSectionType = event.detail.name;
        this.selectedQuestionSectionTypeIndex = this.questionSections.findIndex(
          (section) => section.Type__c === this.selectedQuestionSectionType
        );
        setTimeout(
          () =>
            this.template
              .querySelector(questionListComponent)
              .fetchQuestionsAndResponse(),
          100
        );
      }
    }
  }

          handlecssremove(event) {
                const message = event.detail;
                const section = event.detail.section;
                const error = event.detail.error;
                const hasWarnings= event.detail.hasWarnings;
                const tempid=section.replace(/\s/g, '');
                const rscTempid= this.removeSpecialCharacters(tempid);
                const container = this.template.querySelector('[data-id="' + rscTempid + '"]');
                const subContainer = document.querySelector('#p'+rscTempid);
                if(error == false && hasWarnings == false){
                  if(subContainer){
                    subContainer.innerHTML='';
                  }                   
                  container.className='slds-nav-vertical__item Completed';
                
              }else{
                if (hasWarnings == true || error== true) {
                  if(subContainer){
                    subContainer.innerHTML='';

                  }
                  const newElement = document.createElement('p');
                  newElement.id = 'p'+rscTempid;
                  if(error == true){
                    newElement.textContent = '';
                    newElement.textContent = 'Errors Returned';
                    newElement.style.color = 'red';
                    container.className='';
                    container.className = 'slds-nav-vertical__item ErrorsReturned';
                  }else{ 
                    newElement.textContent = '';
                    newElement.textContent = 'Warnings Returned';
                    newElement.style.color = '#ffa400';
                    container.className='';
                    container.className = 'slds-nav-vertical__item WarningsReturned';
                  }
                  container.appendChild(newElement);
                }
              }
    }


  /**
   * Given the index of a section in the questionSections array, navigates to that section in the form
   * @param {*} event `detail` property should be the index of the section we are navigating to
   */
  handleNavigation(event) {
    const index = event.detail;

    if (index < 0) {
      return;
    }

    // Assumption: Index greater than length means we are navigating to the submission page
    if (index >= this.questionSections.length) {
      // Disable navigation to submission page if read-only
      if (this.isReadOnly) {
        return;
      }
      const mockEvent = { detail: { name: "Submission" } };
      this.handleSelectQuestionSection(mockEvent);
    } else {
      const questionSectionType = this.questionSections[index].Type__c;
      const mockEvent = { detail: { name: questionSectionType } };
      this.handleSelectQuestionSection(mockEvent);
    }

    this.template.querySelector(questionListComponent).scrollIntoView({
      behavior: "smooth"
    });
  }
  
  handleCompletion(event) {
    const status = event.detail;
    this.submissionClass = status;
  }

  async setIsDraftVersionRequired() {
    this.isDraftVersionRequired = !this.isReadOnly && await isDraftVersionRequiredForAmendment({ summaryId: this.qiSummaryId });
  }

  async setIsReadOnly() {
    this.isReadOnly = await isShowFieldsReadOnly({
      summaryId: this.qiSummaryId,
      summaryVersionId: this.qiSummaryVersionId
    });
  }
}