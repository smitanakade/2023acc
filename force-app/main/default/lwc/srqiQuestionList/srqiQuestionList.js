/**
 * @author Rami Zuhairi
 * @date 08/2022
 * @objects Question_Section__c , Question_library__c, Section_Library__c, Question_Category__c
 * @description LWC JS to make dynamic read and get the required data for QI pages so when the user delete or add new questions,
 * it will reflect directly on the LWC component
 */
import { api, LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { publish, subscribe, MessageContext} from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import getQuestions from '@salesforce/apex/SRQIQuestionDataCaptureFormController.getQuestions';
import saveFormSectionInProgress from '@salesforce/apex/SRQIQuestionDataCaptureFormController.saveFormSectionInProgress';
import saveFormSectionComplete from '@salesforce/apex/SRQIQuestionDataCaptureFormController.saveFormSectionComplete';
import saveFormSectionVersionComplete from '@salesforce/apex/SRQIQuestionDataCaptureFormController.saveFormSectionVersionComplete';
import getRecordType from '@salesforce/apex/SRQIQuestionDataCaptureFormController.getRecordType';
import getFormSectionResponse from '@salesforce/apex/SRQIQuestionDataCaptureFormController.getFormSectionResponse';
import createDraftVersion from '@salesforce/apex/SRQIQuestionDataCaptureFormController.createDraftVersion';
import getValidationWarningSettings from "@salesforce/apex/SRQIQuestionDataCaptureFormController.getValidationWarningSettings";
import { toSentenceCase, toLowerCase } from 'c/srqiQuestionDataCaptureFormUtils';
import draftVersionModal from 'c/srqiQuestionDraftVersionModal';
import BUTTON_CLICKED_CHANNEL from '@salesforce/messageChannel/Button_Clicked__c';
import DATA_SAVED_CHANNEL from '@salesforce/messageChannel/Data_Saved__c';

// Constants
const NUMBER_RESPONSE_DATA_TYPE = 'number';
const TEXT_RESPONSE_DATA_TYPE = 'text';
const DATE_RESPONSE_DATE_TYPE = 'date';
const QIT_LABEL = 'Quality Indicator Targets';
const QIT_TITLE_REPLACEMENT = 'Set up QI Target/s';

export default class srqiQuestionList extends NavigationMixin(LightningElement) {
    @api qiSummaryId;
    @api qiSummaryVersionId;
    @api questionSectionType;
    @api questionSectionTypeIndex;
    @api questionSectionLength;
    @api questionCategory;
    @api questions = [];
    recordTypeId;
    isLoading = false;
    isSuccess = false;
    isStatusCompleted = false;
    @api isReadOnly;
    @api isDraftVersionRequired;
    @api validationErrorSetting;
    validationWarningSettings;
    errorMessageMap;
    savedFormData;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.qiSummaryId = currentPageReference.state?.qisid;
        }
    }

    @wire(MessageContext)
    messageContext;

    /**
     * Listen for button clicks on the banner (qiReportingSummaryBanner)
     */
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            BUTTON_CLICKED_CHANNEL, 
            (message) => this.handleBannerButtonClick(message)
        );
    }

    connectedCallback() {
        this.subscribeToMessageChannel();  
    }

    @api
    async fetchRecordTypeId() {
        try {
            this.recordTypeId = await getRecordType({
                recordTypeName: this.questionSectionType,
                isVersionObject: this.qiSummaryVersionId != null
            });
        } catch (error) {
            console.error(error);
        }
    }

    @api
    async fetchQuestionsAndResponse() {
        this.setLoading(true);
        this.clearErrorMessages();
        this.setSuccessMessage(false);
        await this.fetchRecordTypeId();
        await this.fetchQuestions();
        await this.fetchValidationWarnings();
        await this.fetchResponse();
        this.setLoading(false);
    }

    @api
    async getResponse() {
        let responseData = await getFormSectionResponse({
            recordTypeId: this.recordTypeId, 
            summaryId: this.qiSummaryId, 
            summaryVersionId: this.qiSummaryVersionId, 
            questionSectionType: this.questionSectionType
        });
        return responseData;
    }
    /**
     * Retrieve validation errors based on the question type
     * @returns Validations formatted as properties to be appended to the question object
     * @note We reference these properties in the input field validation attributes
     * @see ValidationSettingWrapper Apex class
     */
    getValidationErrorSettings(question) {
        switch(question.Question_Library__r.Response_Data_Type__c) {
            case TEXT_RESPONSE_DATA_TYPE:
                return {
                    /* 
                        Using the max-length attribute will restrict the user from entering more characters than the maximum allowed and also does
                        not trigger the message-when-too-long error message. Instead we use pattern which will allow the user to enter any number 
                        of characters and then we can display an error message if they enter more characters than the maximum allowed.
                    */
                    maxCharPattern: `.{0,${this.validationErrorSetting.maxChar}}`,
                    charError: this.validationErrorSetting.charError,
                };
            case NUMBER_RESPONSE_DATA_TYPE:
                return {
                    maxNumber: this.validationErrorSetting.maxNumber,
                    minNumber: this.validationErrorSetting.minNumber,
                    numberError: this.validationErrorSetting.numberError,
                };
            case DATE_RESPONSE_DATE_TYPE:
                return {
                    dateError: 'Date must be a valid format DD/MM/YYYY',
                    dateStyle:'short'
                };
            default:
                return {};
        }
    }

    /**
     * Checks whether the value of the input for the given question meets
     * the criteria to trigger a validation warning
     * @note We only validate questions which have been configured with a warning
     * @returns Warning message if validation triggered, else null
     */
    checkValidationWarning(question) {
        const value = this.template.querySelector(`[data-id="${question.Key__c}"]`).value;
        const settingName = question.Validation_Warning_Setting__c;
        const hasValue = value !== '';

        if (settingName && hasValue) {
            const setting = this.validationWarningSettings[settingName];
            if (!setting) {
                return null;
            }

            const questionType = question.Question_Library__r.Response_Data_Type__c;
            let warningMessage = null;

            if (
                questionType === TEXT_RESPONSE_DATA_TYPE &&
                value.length > setting.maxChar
            ) {
                warningMessage = setting.charError;
            } else if (
                questionType === NUMBER_RESPONSE_DATA_TYPE &&
                (value < setting.minNumber || value > setting.maxNumber)
            ) {
                warningMessage = setting.numberError;
            } else {
                // No action
            }

            return warningMessage;
        }

        return null;
    }

    /**
     * For all questions, checks whether a validation warning is triggered for the input
     * and appends a warning property, and adds a CSS class to colour the border
     * @returns True if at least one warning has been triggered, false otherwise
     */
    handleValidationWarnings() {
        let hasWarning = false;

        this.questions = this.questions.map(question => {
            const warning = this.checkValidationWarning(question);

            if (warning) {
                hasWarning = true;
            }

            return { 
                ...question, 
                class: warning ? 'srqi-input warning-border' : (question.error ? 'srqi-input error-border' : 'srqi-input'),
                warning
            };
        });
        
        return hasWarning;
    }

    /**
     * If any questions are configured with validation warnings, fetches the validation warning settings
     */
    @api
    async fetchValidationWarnings() {
        const qualityIndicatorSettingNames = [];
        this.questions.forEach(question => {
            const settingName = question.Validation_Warning_Setting__c;
            if (settingName) {
                qualityIndicatorSettingNames.push(settingName);
            }
        });

        if (qualityIndicatorSettingNames.length === 0) {
            return;
        }

        this.validationWarningSettings = await getValidationWarningSettings({ qualityIndicatorSettingNames });
    }

    /**
     * For all questions, checks whether a validation error is triggered for the input
     * and appends an error property, and adds a CSS class to colour the border
     * @param {Object} fieldToErrorsMap Map of field API names to errors
     */
    handleValidationErrors(fieldToErrorsMap) {
        this.questions = this.questions.map(question => {
            const field = question.Key__c;
            const error = fieldToErrorsMap[field] || null;
            return {
                ...question,
                class: error ? 'srqi-input error-border' : (question.warning ? 'srqi-input warning-border' : 'srqi-input'),
                error
            };
        });
    }

    /**
     * For all questions, clears the error property 
     */
    clearValidationErrors() {
        this.questions = this.questions.map(question => {
            return {
                ...question,
                class: question.warning ? 'srqi-input warning-border' : 'srqi-input',
                error: null
            };
        });
    }

    @api
    async fetchQuestions() {
        try {
            const formElements = await getQuestions({type: this.questionSectionType, category: this.questionCategory});

            this.questions = this.parseFormElements(formElements);

            /*
                Add some extra properties:
                class - Set default CSS class
                placeholderText - Used to display placeholder text depending on question type
                validations - See getValidationErrorSettings function
                required - Read Mandatory checkbox field for QID and override as always false for QIT
            */
            this.questions = this.questions.map((question) => {
                return { 
                    ...question, 
                    class: 'srqi-input',
                    placeholderText: this.getPlaceholderText(question.Question_Library__r.Response_Data_Type__c),
                    required: this.isQualityIndicatorTargetsSection ? false : question.Question_Library__r.Mandatory__c,
                    ...this.getValidationErrorSettings(question)
                }
            });

            this.questions = this.groupQuestions();
        } catch (error) {
            this.questions = null;
        }
    }

    /**
     * The 'fetchQuestions' controller class fetches both section headings and questions referred to as form elements here.
     * We return an array of questions that has an extra property on it to indicate that a section heading has to be rendered
     * above the question.
     */
    parseFormElements(formElements) {
        const questions = [];    
        let sectionHeadingText = null;

        formElements.forEach(formElement => {
            if (sectionHeadingText !== null) {
                // Previous form element was a section heading, we need to add extra property to question
                questions.push({
                    ...formElement,
                    sectionHeading: sectionHeadingText
                }); 

                // Reset variable
                sectionHeadingText = null;
            } else {
                const isNotQuestionOrSectionHeading = formElement.Question_Library__c === undefined && formElement.Section_Library__r.Sub_Section__c === 'Subsection';

                if (isNotQuestionOrSectionHeading) {
                    return;
                }

                const isSectionHeading = formElement.Question_Library__c === undefined && formElement.Section_Library__r.Sub_Section__c === 'Section';

                if (isSectionHeading) {
                    const isQualityIndicatorTargetsSection = this.questionSectionType === QIT_LABEL;
                    if (!isQualityIndicatorTargetsSection) {
                        // We only display section headings for the Quality Indicator Targets section in the form
                        return;
                    }

                    // Form element is a section heading, store the text to append to next question
                    sectionHeadingText = formElement.Section_Library__r.Section_Name__c;
                } else {
                    // Form element is a question, add directly to array
                    questions.push(formElement);
                }
            }
        });

        return questions;
    }

    /**
     * Set extra properties on the question objects to assist in displaying them as either stand-alone questions, or
     * questions that are grouped under a top-level question (referred to as question group below).
     */
    groupQuestions() {
        let previousQuestionGroupText = null;
        let questionNumberCount = 1;

        return this.questions.map(question => {
            const isInQuestionGroup = question.Question_Group__c;
            const questionGroupText = question.Section_Library__r.Section_Name__c;
            let isFirstQuestionInQuestionGroup = false;
            let topLevelQuestionText = null;
            let questionNumber = null;

            if (!isInQuestionGroup) {
                // Stand-alone/not part of question group, simply display the actual question text
                topLevelQuestionText = question.Question_Library__r.Question__c;
            } else if (previousQuestionGroupText !== questionGroupText) {
                // First question in question group, need to show the question group text 
                previousQuestionGroupText = questionGroupText;
                isFirstQuestionInQuestionGroup = true;
                topLevelQuestionText = questionGroupText;
            } else {
                // Subsequent question in question group, don't show question group text again
            }

            // Question groups are displayed under one question number
            if (!isInQuestionGroup || isFirstQuestionInQuestionGroup) {
                questionNumber = questionNumberCount;
                questionNumberCount++;
            }

            return {
                ...question,
                questionNumber,
                topLevelQuestionText,
                // Required questions in question groups will have the asterisk on their individual question texts
                // Override Mandatory checkbox field on QIT to make required always false
                topLevelQuestionRequired: !isInQuestionGroup && (this.isQualityIndicatorTargetsSection ? false : question.Question_Library__r.Mandatory__c),
                isInQuestionGroup
            };
        });
    }
   
    @api
    async fetchResponse() {  
        try {
            const responseData = await getFormSectionResponse({
                recordTypeId: this.recordTypeId, 
                summaryId: this.qiSummaryId, 
                summaryVersionId: this.qiSummaryVersionId, 
                questionSectionType: this.questionSectionType
            });
            if (responseData) {
                const validationFlag = responseData.Error_Flag__c;
                this.isStatusCompleted = responseData.Status__c === 'Completed';
                this.questions.forEach(question => {
                    this.template.querySelector(`[data-id="${question.Key__c}"]`).value = responseData[question.Key__c];
                });

                if (validationFlag === 'Warnings Returned') {
                    this.handleValidationWarnings();
                } else if (validationFlag === 'Errors Returned') {
                    // Trigger error warnings
                    await this.handleSaveComplete(true);
                }
                this.savedFormData = this.constructRecordData();
            } else {
                this.isStatusCompleted = false;
                this.savedFormData = null;
            }
        } catch(error) {
            console.error(error);
            this.displayErrorMessages(error?.body?.message);
        }
    }

    getPlaceholderText(questionType) {
        switch(questionType) {
            case DATE_RESPONSE_DATE_TYPE:
                return 'Please select date';
            default:
                return null;
        }
    }
 
    /**
     * Handle button clicks on the banner (qiReportingSummaryBanner)
     */
    async handleBannerButtonClick(message) {
        if (message.buttonClicked === 'close') {
            const shouldNavigate = await this.handleSaveData(true);

            if (shouldNavigate && message.buttonClicked === 'close') {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'Quality_Indicator_Details__c'
                    }
                }, true);
            }
        } else {
            if (await this.showDraftVersionWarningIfRequired()) {
                return;
            }
            await this.handleSaveData(false);
        }
    }

    /**
     * Handle saving data depending on 1) read-only status 2) section is in progress or completed.
     * Optionally the isNavigation parameter can be passed if the section is completed and the user is trying
     * to navigate away from the section. If there are errors saving the completed section, an "unsaved changes" 
     * warning will be displayed to the user and they have the option to continue navigating or stay on the page.
     * @param {*} isNavigation True if the action is navigating away from the section, false otherwise
     * @returns True if the user wants to continue navigating away with unsaved changes, false otherwise
     */
    @api
    async handleSaveData(isNavigation) {
        if (this.isReadOnly || this.isDraftVersionRequired) {
            return true;
        }
        if (!this.qiSummaryVersionId && !this.isStatusCompleted) {
            const isInputValid = this.checkInputValidity(true);
            if (!isInputValid) {
                if (isNavigation) {
                    const shouldNavigateWithUnsavedChanges = await this.showUnsavedChangesWarning();
                    return shouldNavigateWithUnsavedChanges;
                } else {
                    return false;
                }
            }
            await this.handleSaveInProgress();
        } else {
            const isInputValid = this.checkInputValidity(false);

            // Client-side validation errors
            if (!isInputValid) {
                if (isNavigation) {
                    const shouldNavigateWithUnsavedChanges = await this.showUnsavedChangesWarning();
                    return shouldNavigateWithUnsavedChanges;
                } else {
                    return false;
                }
            }
            await this.handleSaveComplete();

            // Server-side validation errors
            if (isNavigation && this.sectionHasErrors()) {
                const shouldNavigateWithUnsavedChanges = await this.showUnsavedChangesWarning();
                return shouldNavigateWithUnsavedChanges;
            }
        }
        return true;
    }

    async handleSaveInProgress() {
        this.setLoading(true);
        const hasWarnings = this.handleValidationWarnings();
        const jsonString = this.constructRecordData();
        if (this.isFormDataChanged()) {
            try {
                await saveFormSectionInProgress({
                    formData: jsonString,
                    recordTypeId: this.recordTypeId,
                    summaryId: this.qiSummaryId,
                    warningFlag: hasWarnings
                });
                this.showSuccessToast('Your quality indicator data has been saved');
                this.fireErrorCssRemoveEvent(this.questionSectionType, false,hasWarnings);
            } catch (error) {
                console.error(error);
                this.displayErrorMessages(error?.body?.message);
            }
        }
        this.setLoading(false);
    }

    async handleSaveComplete(validateOnly) {
        if (await this.showDraftVersionWarningIfRequired()) {
            return;
        }
        let flag=false;
        this.setLoading(true);
        if (this.checkInputValidity(false)) {
            const hasWarnings = this.handleValidationWarnings();
            const jsonString = this.constructRecordData();
            const isValidateOnly = validateOnly === true;
            if (isValidateOnly || (!this.isStatusCompleted && !this.isQualityIndicatorTargetsSection) || this.isFormDataChanged()) {
                try {
                    // Check errors when trying to complete the Quality Indicator Detail record
                    let fieldToErrorsMapJSON;
                    if (this.qiSummaryVersionId) {
                        fieldToErrorsMapJSON = await saveFormSectionVersionComplete({
                            formData: jsonString,
                            versionRecordTypeId: this.recordTypeId,
                            recordTypeName: this.questionSectionType,
                            summaryId: this.qiSummaryId,
                            summaryVersionId: this.qiSummaryVersionId,
                            warningFlag: hasWarnings
                        });
                    } else {
                        fieldToErrorsMapJSON = await saveFormSectionComplete({
                            formData: jsonString,
                            recordTypeId: this.recordTypeId,
                            summaryId: this.qiSummaryId,
                            warningFlag: hasWarnings,
                            validateOnly: isValidateOnly
                        });
                        flag=true;
                    }

                    if (fieldToErrorsMapJSON) { 
                        const fieldToErrorsMap = JSON.parse(fieldToErrorsMapJSON);
                        const errorMessages = Object.keys(fieldToErrorsMap).map(field => {
                            if(flag && fieldToErrorsMap){
                                this.fireErrorCssRemoveEvent(this.questionSectionType,true ,false);
                            }
                            flag=false;
                            return this.constructErrorMessage(field, fieldToErrorsMap[field]);
                        });
                        this.displayErrorMessages(JSON.stringify(errorMessages));
                        this.handleValidationErrors(fieldToErrorsMap);
                        this.setSuccessMessage(false);
                    } else {
                        if (!isValidateOnly) {
                            this.isStatusCompleted = true;
                            this.clearValidationErrors();
                            this.clearErrorMessages();
                            this.setSuccessMessage(true);   
                            this.showSuccessToast('Your quality indicator data has been saved');      
                        }
                        this.fireErrorCssRemoveEvent(this.questionSectionType, false,false);
                    }

                    const payload = {Data_Saved: 'yes'};
                    publish(this.messageContext , DATA_SAVED_CHANNEL, payload );
                } catch (error) {
                    // Something else went wrong on the server side
                    console.error(error);
                    this.displayErrorMessages(error?.body?.message);
                }
            }
        }
        this.setLoading(false);
    }

    /**
     * Checks validity of all inputs as configured in the validation error setting.
     * The parameter `ignoreRequiredValidationError` is used when the domain is still in progrss
     * as required fields are only checked when they are trying to complete the domain.
     * 
     * For all other validations they are enforced regardless of in progress or completed, because
     * there are equivalent validations configured in Salesforce (e.g. Field-level restriction on
     * text field being max. 1000 chars).
     * 
     * @returns True if inputs are valid, false otherwise
     */
    checkInputValidity(ignoreRequiredValidationError) {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();

            const isRequiredValidationError = inputCmp.validity.valueMissing;
            if (isRequiredValidationError && ignoreRequiredValidationError) {
                return validSoFar && true;
            }

            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    }

    /**
     * Navigate to the previous section
     * @note Data is saved - see navigation event handler
     */
    async handleBack() {
        this.fireNavigationEvent(this.questionSectionTypeIndex - 1);
    }

    /**
     * Navigate to the next section
     * @note Data is saved - see navigation event handler
     */
    async handleNext() {
        this.fireNavigationEvent(this.questionSectionTypeIndex + 1);

    }
    fireErrorCssRemoveEvent(section, error,hasWarnings){
        this.dispatchEvent(new CustomEvent('cssremove', { detail: {
            section:section,
            error:error,
            hasWarnings:hasWarnings
        }
        }));

    }

    fireNavigationEvent(index) {
        this.dispatchEvent(new CustomEvent('navigation', { detail: index }));
    }

    @api
    get disableBackOnFirstSection() {
        return this.questionSectionTypeIndex === 0;
    }

    /**
     * Do not allow navigation to the submission page when read-only. As the submission page is not counted as 
     * part of the question sections, disable the next button when on the last question section and read-only.
     */
    @api
    get disableNextOnReadOnlyAndLastSection() {
        return this.isReadOnly && this.questionSectionTypeIndex === (this.questionSectionLength-1);
    }

    /**
     * Shows or hides the loading spinner
     * @param {boolean} isLoading Whether the loading spinner is displayed
     */
    setLoading(isLoading) {
        this.isLoading = isLoading;
    }

    //built a list of objects with the errors returned 
    displayErrorMessages(errorMessages) {
        if(errorMessages) {
            const errorObject = JSON.parse(errorMessages);
            this.errorMessageMap = [];
            for (let step = 0; step < errorObject.length; step++) {
                const obj = {};
                obj.key = step;
                obj.value = errorObject[step];
                this.errorMessageMap.push(obj); 
            }
        }
    }

    clearErrorMessages() {
        this.errorMessageMap = null;
    }

    setSuccessMessage(isSuccess) {
        this.isSuccess = isSuccess;
    }

    /**
     * Jumps to the field with the error when the error message is clicked
     */
    onErrorMessageClick(event) {
        const index = event.target.dataset.id;
        const messageObject = this.errorMessageMap[index];
        const field = this.getFieldFromErrorMessage(messageObject.value);
        const element = this.template.querySelector(`[data-id="${field}"]`);
        if (element) {
            element.scrollIntoView({
                behavior: 'smooth'
            });
        }
    }

    /**
     * Returns an error message containing question text and error
     * @param {string} field Field API name where the error occurred
     * @param {string} error Error that occurred
     * @returns Error message containing question text and error
     */
    constructErrorMessage(field, error) {
        const questionWithError = this.questions.find(question => question.Key__c === field);
        const questionText = questionWithError.Question_Library__r.Question__c;
        return `${questionText}: ${error}`;
    }

    /**
     * Returns the field where the error occurred from an error message
     * @param {string} message Message formatted as '<question text>: <error message>'
     * @see constructErrorMessage function
     * @returns Field where the error occurred
     */
    getFieldFromErrorMessage(message) {
        const questionText = message.split(':')[0];
        const questionWithError = this.questions.find(question => question.Question_Library__r.Question__c === questionText);
        return questionWithError.Key__c;
    }

    /**
     * Checks whether there is at least one error in the current section of the form
     * @returns True if there is at least one error, false otherwise
     */
    sectionHasErrors() {
        const hasError = this.questions.find(question => question.error != null);
        return hasError;
    }

    /**
     * Constructs the Quality Indicator Details record data from the values of
     * the input fields
     * @returns JSON to be passed to the Apex controller
     */
    constructRecordData() {
        const qualityIndicatorDetails = {};
        const inputValuesArray = this.template.querySelectorAll('lightning-input');
        inputValuesArray.forEach(item => {   
            if (item.value === '') { // no value in input
                qualityIndicatorDetails[item.name] = null;
            } else if (item.type === NUMBER_RESPONSE_DATA_TYPE) {
                qualityIndicatorDetails[item.name] = Number(item.value);
            } else {
                qualityIndicatorDetails[item.name] = item.value;
            }
        });
        return JSON.stringify(qualityIndicatorDetails);
    }

    /**
     * Confirmation modal displayed to the user when they are navigating away from the section
     * with unsaved changes
     * @returns True if user wants to continue navigating away, false otherwise
     */
    async showUnsavedChangesWarning() {
        const result = await LightningConfirm.open({
            message: 'You have unsaved changes on this section. Would you like to continue?',
            label: 'Warning',
            theme: 'warning'
        });
        return result;
    }

    @api
    get questionSectionTypeFormatted() {
        if(this.questionSectionType === QIT_LABEL) {
            return QIT_TITLE_REPLACEMENT;
        }
        return toSentenceCase(this.questionSectionType);
    }

    @api
    get isQualityIndicatorTargetsSection() {
        return this.questionSectionType === QIT_LABEL;
    }

    async showDraftVersionWarningIfRequired() {
        if (this.isDraftVersionRequired) {
            const shouldCreateDraftVersion = await draftVersionModal.open({
                label: 'Draft version warning',
                size: 'small'
            });
            
            if (shouldCreateDraftVersion) {
                this.setLoading(true);
                try {
                    const hasWarnings = this.handleValidationWarnings();
                    const jsonString = this.constructRecordData();
                    await createDraftVersion({
                        formData: jsonString,
                        recordTypeId: this.recordTypeId,
                        recordTypeName: this.questionSectionType,
                        summaryId: this.qiSummaryId,
                        warningFlag: hasWarnings
                    });
                    
                    // Refresh browser page on success in order to display new draft version
                    window.location.reload();
                } catch (error) {
                    console.error(error);
                    this.setLoading(false);
                }
            }
        }
        return this.isDraftVersionRequired;
    }

    isFormDataChanged() {
        const currentFormData = this.constructRecordData();
        return currentFormData !== this.savedFormData;
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: null,
            message,
            variant: 'success',
            mode: 'dismissible'
        });
        this.dispatchEvent(event);
    }
}