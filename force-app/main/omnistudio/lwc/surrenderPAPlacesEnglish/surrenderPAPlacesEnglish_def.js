export const OMNIDEF = {"userTimeZone":600,"userProfile":"System Administrator","userName":"namrata.gurjar@health.gov.au.r3dev","userId":"005Bm000001mh25IAA","userCurrencyCode":"AUD","timeStamp":"2023-04-21T06:40:18.617Z","sOmniScriptId":"0jNBm000000191FMAQ","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":""},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"scrollBehavior":"auto","saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge","dispOutsideOmni":false}],"message":{},"mergeSavedData":false,"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":true,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"currentLanguage":"en_US","currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":false,"allowCancel":true},"prefillJSON":"{}","lwcId":"67a77a6a-35c9-2029-dd0a-55c5beb934b7","labelMap":{"TodayDate":"NotificationOfSurrenderDetails:TodayDate","CompareWithSurrenderEffectiveDate":"NotificationOfSurrenderDetails:CompareWithSurrenderEffectiveDate","PAPeriodEndDateValidationFormula":"NotificationOfSurrenderDetails:PAPeriodEndDateValidationFormula","DateOfAllotmentValidationFormula":"NotificationOfSurrenderDetails:DateOfAllotmentValidationFormula","CommentOnSurrender":"NotificationOfSurrenderDetails:CommentOnSurrender","LineBreak2":"NotificationOfSurrenderDetails:LineBreak2","LinkToDocuments":"NotificationOfSurrenderDetails:LinkToDocuments","Messaging2":"NotificationOfSurrenderDetails:Messaging2","Messaging1":"NotificationOfSurrenderDetails:Messaging1","LineBreak1":"NotificationOfSurrenderDetails:LineBreak1","SurrenderEffectiveDate":"NotificationOfSurrenderDetails:SurrenderEffectiveDate","NotificationReceivedDate":"NotificationOfSurrenderDetails:NotificationReceivedDate","LineBreak5":"NotificationOfSurrenderDetails:LineBreak5","CustomLWC1":"NotificationOfSurrenderDetails:CustomLWC1","LineBreak3":"NotificationOfSurrenderDetails:LineBreak3","TextBlock1":"NotificationOfSurrenderDetails:TextBlock1","TextBlock3":"Error:TextBlock3","TextBlock6":"Error:TextBlock6","TextBlock2":"Error:TextBlock2","NavigateAction":"NavigateAction","SurrenderPA_Places":"SurrenderPA_Places","NotificationOfSurrenderDetails":"NotificationOfSurrenderDetails","NavigateAction1":"NavigateAction1","Error":"Error","SetErrorHandlingValues":"SetErrorHandlingValues","Allotments_UsedForFlexCard":"Allotments_UsedForFlexCard","CANCEL":"CANCEL"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Cancel Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Record","targetName":"Allotment__c","targetLWCLayout":"lightning","targetId":"%AllotmentId%","targetFilter":"Recent","ssm":false,"show":null,"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"Cancel","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"CANCEL","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bCancel":true,"JSONPath":"CANCEL","lwcId":"lwc0"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[true,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"Allotments_UsedForFlexCard","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"dataRaptor Input Parameters":[{"inputParam":"AllotmentId","element":"AllotmentId"}],"controlWidth":12,"businessEvent":"","businessCategory":"","bundle":"Allotment_Extract","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"Allotments_UsedForFlexCard","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"Allotments_UsedForFlexCard","lwcId":"lwc1"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[true,false],"show":null,"pubsub":false,"message":{},"label":"SetSetErrorHandlingValuesValues","elementValueMap":{"LaunchedFrom":"=\"Allotment\"","EventType":"=\"Surrender\""},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetErrorHandlingValues","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetErrorHandlingValues","lwcId":"lwc2"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"ProvisionalPlacesNumber","data":"0","condition":"="},{"group":{"rules":[{"data":"Not Applicable","condition":"=","field":"WaiverType"},{"data":"S14-1","condition":"=","field":"AllotmentSubType"},{"data":null,"condition":"=","field":"MarkDocumentsAsSent"},{"group":{"rules":[{"data":"Residential","condition":"=","field":"ServiceCareSubType"},{"data":"Short-Term Restorative Care (STRC)","condition":"=","field":"ServiceCareSubType"}],"operator":"OR"}}],"operator":"AND"}}],"operator":"OR"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Exit","message":{},"label":"Error","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"Error":""},"aggElements":{}},"offSet":0,"name":"Error","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":3,"response":null,"propSetMap":{"textKey":"","text":"<h2>This service has the following issues:</h2>","show":null,"sanitize":false,"label":"TextBlock2","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock2","level":1,"JSONPath":"Error:TextBlock2","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc30-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Text Block","rootIndex":3,"response":null,"propSetMap":{"textKey":"","text":"<ul>\n<li>This service has no provisional places</li>\n</ul>","show":{"group":{"rules":[{"field":"ProvisionalPlacesNumber","condition":"=","data":"0"}],"operator":"AND"}},"sanitize":false,"label":"TextBlock2","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock6","level":1,"JSONPath":"Error:TextBlock6","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc31-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Text Block","rootIndex":3,"response":null,"propSetMap":{"HTMLTemplateId":"","controlWidth":12,"dataJSON":false,"label":"TextBlock2","sanitize":false,"show":{"group":{"rules":[{"data":"Not Applicable","condition":"=","field":"WaiverType"},{"data":"S14-1","condition":"=","field":"AllotmentSubType"},{"data":null,"condition":"=","field":"MarkDocumentsAsSent"},{"group":{"rules":[{"data":"Residential","condition":"=","field":"ServiceCareSubType"},{"data":"Short-Term Restorative Care (STRC)","condition":"=","field":"ServiceCareSubType"}],"operator":"OR"}}],"operator":"AND"}},"text":"<ul>\n<li><span class=\"NormalTextRun SCXW167072363 BCX0\">Documents must be marked as sent</span> <span class=\"NormalTextRun SCXW167072363 BCX0\">b</span><span class=\"NormalTextRun SCXW167072363 BCX0\">efore you can create a new event</span></li>\n</ul>","textKey":""},"name":"TextBlock3","level":1,"JSONPath":"Error:TextBlock3","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc32-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Error","lwcId":"lwc3"},{"type":"Navigate Action","propSetMap":{"targetName":"Allotment__c","businessEvent":"","businessCategory":"","targetLWCLayout":"lightning","replace":true,"iconPosition":"left","iconVariant":"","iconName":"","variant":"brand","targetId":"%AllotmentId%","targetFilter":"Recent","loginAction":"login","recordAction":"view","objectAction":"home","targetType":"Record","message":{},"pubsub":false,"ssm":false,"wpm":false,"HTMLTemplateId":"","show":{"group":{"rules":[{"data":"Not Applicable","condition":"=","field":"WaiverType"},{"data":"S14-1","condition":"=","field":"AllotmentSubType"},{"data":null,"condition":"=","field":"MarkDocumentsAsSent"},{"group":{"rules":[{"data":"Residential","condition":"=","field":"ServiceCareSubType"},{"data":"Short-Term Restorative Care (STRC)","condition":"=","field":"ServiceCareSubType"}],"operator":"OR"}}],"operator":"AND"}},"validationRequired":"Submit","label":"NavigateAction1","controlWidth":12,"aggElements":{}},"offSet":0,"name":"NavigateAction1","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction1","lwcId":"lwc4"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"ProvisionalPlacesNumber","data":"0","condition":">"}],"operator":"AND"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Notification of Surrender Details","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"NotificationOfSurrenderDetails":"","NotificationReceivedDate":"","SurrenderEffectiveDate":"","LinkToDocuments":"","CommentOnSurrender":""},"aggElements":{"CustomLWC1":"","DateOfAllotmentValidationFormula":"","PAPeriodEndDateValidationFormula":"","CompareWithSurrenderEffectiveDate":"","TodayDate":""}},"offSet":0,"name":"NotificationOfSurrenderDetails","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":5,"response":null,"propSetMap":{"textKey":"","text":"<p><strong>Service Name:</strong> %ServiceName%<br /><br /><strong>Service Address:</strong> %Location%</p>","show":null,"sanitize":false,"label":"TextBlock1","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock1","level":1,"JSONPath":"NotificationOfSurrenderDetails:TextBlock1","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc50-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Line Break","rootIndex":5,"response":null,"propSetMap":{"show":null,"padding":15,"label":"LineBreak5","HTMLTemplateId":""},"name":"LineBreak3","level":1,"JSONPath":"NotificationOfSurrenderDetails:LineBreak3","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bLineBreak":true,"lwcId":"lwc51-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Custom Lightning Web Component","rootIndex":5,"response":null,"propSetMap":{"show":null,"lwcName":"cfSurrenderPlacesAllotment","label":"CustomLWC1","hide":false,"customAttributes":[{"source":"true","name":"parent-data"},{"source":"%Provisional%","name":"records"}],"controlWidth":12,"conditionType":"Hide if False","bStandalone":true},"name":"CustomLWC1","level":1,"JSONPath":"NotificationOfSurrenderDetails:CustomLWC1","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bcustomlightningwebcomponent1":true,"lwcId":"lwc52-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Line Break","rootIndex":5,"response":null,"propSetMap":{"show":null,"padding":15,"label":"LineBreak5","HTMLTemplateId":""},"name":"LineBreak5","level":1,"JSONPath":"NotificationOfSurrenderDetails:LineBreak5","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bLineBreak":true,"lwcId":"lwc53-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":4,"eleArray":[{"type":"Date","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"modelDateFormat":"yyyy-MM-dd","minDate":"","maxDate":"TODAY","label":"Notification Received Date","inputWidth":12,"hide":false,"helpTextPos":"","helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"dateType":"string","dateFormat":"D/M/YYYY","controlWidth":4,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"NotificationReceivedDate","level":1,"JSONPath":"NotificationOfSurrenderDetails:NotificationReceivedDate","indexInParent":4,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc54-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":5,"eleArray":[{"type":"Date","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"modelDateFormat":"yyyy-MM-dd","minDate":"","maxDate":"","label":"Surrender Effective Date","inputWidth":12,"hide":false,"helpTextPos":"","helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"dateType":"string","dateFormat":"D/M/YYYY","controlWidth":4,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SurrenderEffectiveDate","level":1,"JSONPath":"NotificationOfSurrenderDetails:SurrenderEffectiveDate","indexInParent":5,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc55-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":6,"eleArray":[{"type":"Line Break","rootIndex":5,"response":null,"propSetMap":{"show":null,"padding":10,"label":"LineBreak1","HTMLTemplateId":""},"name":"LineBreak1","level":1,"JSONPath":"NotificationOfSurrenderDetails:LineBreak1","indexInParent":6,"index":0,"children":[],"bHasAttachment":false,"bLineBreak":true,"lwcId":"lwc56-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":7,"eleArray":[{"type":"Validation","rootIndex":5,"response":null,"propSetMap":{"validateExpression":{"group":{"rules":[{"field":"DateOfAllotmentValidationFormula","data":"GOOD","condition":"="}],"operator":"AND"}},"show":{"group":{"rules":[{"field":"DateOfAllotmentValidationFormula","data":"BAD","condition":"="}],"operator":"AND"}},"messages":[{"value":true,"type":"Success","text":"","active":false},{"value":false,"type":"Requirement","text":"Notification Received Date cannot precede Date of Allotment","active":true}],"label":"Messaging1","hideLabel":true,"controlWidth":12,"HTMLTemplateId":""},"name":"Messaging1","level":1,"JSONPath":"NotificationOfSurrenderDetails:Messaging1","indexInParent":7,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc57-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":8,"eleArray":[{"type":"Validation","rootIndex":5,"response":null,"propSetMap":{"validateExpression":{"group":{"rules":[{"field":"PAPeriodEndDateValidationFormula","data":"GOOD","condition":"="}],"operator":"AND"}},"show":null,"messages":[{"value":true,"type":"Success","text":"","active":false},{"value":false,"type":"Requirement","text":"Surrender Effective Date cannot be later than PA Period End Date","active":true}],"label":"Messaging2","hideLabel":true,"controlWidth":12,"HTMLTemplateId":""},"name":"Messaging2","level":1,"JSONPath":"NotificationOfSurrenderDetails:Messaging2","indexInParent":8,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc58-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":9,"eleArray":[{"type":"Text","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","placeholder":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Link to Documents","inputWidth":12,"hide":false,"helpTextPos":"bottom-left","helpText":"User can enter TRIM reference documents","help":true,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":8,"conditionType":"Hide if False","autocomplete":null,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"LinkToDocuments","level":1,"JSONPath":"NotificationOfSurrenderDetails:LinkToDocuments","indexInParent":9,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc59-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":10,"eleArray":[{"type":"Line Break","rootIndex":5,"response":null,"propSetMap":{"show":null,"padding":10,"label":"LineBreak2","HTMLTemplateId":""},"name":"LineBreak2","level":1,"JSONPath":"NotificationOfSurrenderDetails:LineBreak2","indexInParent":10,"index":0,"children":[],"bHasAttachment":false,"bLineBreak":true,"lwcId":"lwc510-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":11,"eleArray":[{"type":"Text Area","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","placeholder":"","pattern":"","minLength":0,"maxLength":255,"label":"Comment on Surrender","inputWidth":12,"hide":false,"helpTextPos":"","helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":8,"conditionType":"Hide if False","autocomplete":null,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"CommentOnSurrender","level":1,"JSONPath":"NotificationOfSurrenderDetails:CommentOnSurrender","indexInParent":11,"index":0,"children":[],"bHasAttachment":false,"bTextarea":true,"lwcId":"lwc511-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":12,"eleArray":[{"type":"Formula","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"mask":null,"label":"Date of Allotment Validation Formula","inputWidth":12,"hideGroupSep":false,"hide":true,"expression":"IF(%NotificationReceivedDate% < %DateOfAllotment%, 'BAD', 'GOOD')","disOnTplt":false,"dateFormat":"MM-dd-yyyy","dataType":null,"controlWidth":12,"HTMLTemplateId":""},"name":"DateOfAllotmentValidationFormula","level":1,"JSONPath":"NotificationOfSurrenderDetails:DateOfAllotmentValidationFormula","indexInParent":12,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc512-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":13,"eleArray":[{"type":"Formula","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"mask":null,"label":"PA Period End Date Validation Formula","inputWidth":12,"hideGroupSep":false,"hide":true,"expression":"IF(%SurrenderEffectiveDate% > %PAPeriodEndDate%, 'BAD', 'GOOD')","disOnTplt":false,"dateFormat":"MM-dd-yyyy","dataType":null,"controlWidth":12,"HTMLTemplateId":""},"name":"PAPeriodEndDateValidationFormula","level":1,"JSONPath":"NotificationOfSurrenderDetails:PAPeriodEndDateValidationFormula","indexInParent":13,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc513-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":14,"eleArray":[{"type":"Formula","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"mask":null,"label":"Compare With Surrender Effective Date","inputWidth":12,"hideGroupSep":false,"hide":true,"expression":"IF(%SurrenderEffectiveDate% > %TodayDate%, 'FUTURE', 'PAST')","disOnTplt":false,"dateFormat":"MM-dd-yyyy","dataType":null,"controlWidth":3,"HTMLTemplateId":""},"name":"CompareWithSurrenderEffectiveDate","level":1,"JSONPath":"NotificationOfSurrenderDetails:CompareWithSurrenderEffectiveDate","indexInParent":14,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc514-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":15,"eleArray":[{"type":"Formula","rootIndex":5,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"mask":null,"label":"Today Date","inputWidth":12,"hideGroupSep":false,"hide":true,"expression":"DATE(YEAR(TODAY()),MONTH(TODAY()),DAYOFMONTH(TODAY())+1)","disOnTplt":false,"dateFormat":"YYYY-MM-DD","dataType":"Date","controlWidth":null,"HTMLTemplateId":""},"name":"TodayDate","level":1,"JSONPath":"NotificationOfSurrenderDetails:TodayDate","indexInParent":15,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc515-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"NotificationOfSurrenderDetails","lwcId":"lwc5"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"toastComplete":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"ProvisionalPlacesNumber","data":"0","condition":">"}],"operator":"AND"}},"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"SurrenderPA_Places","integrationProcedureKey":"SurrenderPA_Places","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SurrenderPA_Places","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"SurrenderPA_Places","lwcId":"lwc6"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Record","targetName":"Allotment__c","targetLWCLayout":"lightning","targetId":"%AllotmentId%","targetFilter":"Recent","ssm":false,"show":null,"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"NavigateAction","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"NavigateAction","level":0,"indexInParent":7,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction","lwcId":"lwc7"}],"bReusable":false,"bpVersion":3,"bpType":"SurrenderPA","bpSubType":"Places","bpLang":"English","bHasAttachment":false,"lwcVarMap":{"Provisional":null}};