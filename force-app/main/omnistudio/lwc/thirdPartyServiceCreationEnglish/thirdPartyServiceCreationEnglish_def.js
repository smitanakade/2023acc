export const OMNIDEF = {"userTimeZone":660,"userProfile":"System Administrator","userName":"lavanya.uddarraju@health.gov.au.dohsit1.prvddev","userId":"0059r000001a9QnAAI","userCurrencyCode":"AUD","timeStamp":"2022-11-13T21:05:35.995Z","sOmniScriptId":"0jN9r0000000xg1EAA","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"currentLanguage":"en_US","scrollBehavior":"auto","disableUnloadWarn":true,"stepChartPlacement":"right","stylesheet":{"lightningRtl":"","newportRtl":"","lightning":"","newport":""},"errorMessage":{"custom":[]},"consoleTabIcon":"custom:custom18","consoleTabTitle":null,"rtpSeed":false,"showInputWidth":false,"currencyCode":"","autoFocus":false,"pubsub":false,"message":{},"ssm":false,"wpm":false,"consoleTabLabel":"New","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","cancelSource":"%ContextId%","allowCancel":true,"cancelType":"SObject","visualforcePagesAvailableInPreview":{},"mergeSavedData":false,"hideStepChart":true,"timeTracking":false,"knowledgeArticleTypeQueryFieldsMap":{},"lkObjName":null,"bLK":false,"enableKnowledge":false,"trackingCustomData":{},"seedDataJSON":{},"elementTypeToHTMLTemplateMapping":{},"autoSaveOnStepNext":false,"saveURLPatterns":{},"saveObjectId":"%ContextId%","saveContentEncoded":false,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveNameTemplate":null,"allowSaveForLater":false,"persistentComponent":[{"modalConfigurationSetting":{"modalSize":"lg","modalController":"ModalProductCtrl","modalHTMLTemplateId":"vlcProductConfig.html"},"itemsKey":"cartItems","id":"vlcCart","responseJSONNode":"","responseJSONPath":"","sendJSONNode":"","sendJSONPath":"","postTransformBundle":"","preTransformBundle":"","remoteOptions":{"postTransformBundle":"","preTransformBundle":""},"remoteTimeout":30000,"remoteMethod":"","remoteClass":"","label":"","render":false},{"modalConfigurationSetting":{"modalSize":"lg","modalController":"","modalHTMLTemplateId":""},"itemsKey":"knowledgeItems","id":"vlcKnowledge","postTransformBundle":"","preTransformBundle":"","remoteOptions":{"postTransformBundle":"","preTransformBundle":""},"remoteTimeout":30000,"remoteMethod":"","remoteClass":"","label":"","dispOutsideOmni":false,"render":false}]},"prefillJSON":"{}","lwcId":"f90c919d-8336-0929-e7f4-49d25af02878","labelMap":{"ServiceContractEndDate":"AttachServiceSDO:ServiceContractEndDate","ServiceContractStartDate":"AttachServiceSDO:ServiceContractStartDate","Service":"AttachServiceSDO:Service","AssociatedAccountsSDO":"AttachServiceSDO:AssociatedAccountsSDO","Comments":"AttachServiceMCOrAO:Comments","Reason":"AttachServiceMCOrAO:Reason","AssociationEndDate":"AttachServiceMCOrAO:AssociationEndDate","AssociationStartDate":"AttachServiceMCOrAO:AssociationStartDate","LinkService":"AttachServiceMCOrAO:LinkService","AssociatedAccountsMCOrAO":"AttachServiceMCOrAO:AssociatedAccountsMCOrAO","NavigateAction":"NavigateAction","IntegrationProcedureAction":"IntegrationProcedureAction","AttachServiceSDO":"AttachServiceSDO","AttachServiceMCOrAO":"AttachServiceMCOrAO","SetValues":"SetValues","ACORoleExtract":"ACORoleExtract","CANCEL":"CANCEL"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Cancel Action","propSetMap":{"targetName":"Account_Relationship__c","businessEvent":"","businessCategory":"","targetLWCLayout":"lightning","replace":true,"iconPosition":"left","iconVariant":"","iconName":"","variant":"brand","targetId":"%AccountRelationshipId%","targetFilter":"Recent","loginAction":"login","recordAction":"view","objectAction":"home","targetType":"Record","message":{},"pubsub":false,"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"validationRequired":"Submit","label":"Cancel","controlWidth":12,"aggElements":{}},"offSet":0,"name":"CANCEL","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bCancel":true,"JSONPath":"CANCEL","lwcId":"lwc0"},{"type":"DataRaptor Extract Action","propSetMap":{"businessEvent":"","businessCategory":"","enableActionMessage":false,"enableDefaultAbort":false,"errorMessage":{"default":null,"custom":[]},"pubsub":false,"message":{},"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"showPersistentComponent":[true,false],"redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectNextWidth":3,"redirectNextLabel":"Next","redirectTemplateUrl":"vlcAcknowledge.html","redirectPageName":"","validationRequired":"Step","failureAbortMessage":"Are you sure?","failureGoBackLabel":"Go Back","failureAbortLabel":"Abort","failureNextLabel":"Continue","postMessage":"Done","inProgressMessage":"In Progress","responseJSONNode":"","responseJSONPath":"","remoteTimeout":30000,"dataRaptor Input Parameters":[{"inputParam":"AccountRelationshipId","element":"AccountRelationshipId"}],"ignoreCache":false,"bundle":"ACORoleExtract","label":"ACORoleExtract","controlWidth":12,"aggElements":{}},"offSet":0,"name":"ACORoleExtract","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"ACORoleExtract","lwcId":"lwc1"},{"type":"Set Values","propSetMap":{"pubsub":false,"message":{},"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"showPersistentComponent":[true,false],"elementValueMap":{"AOtoServiceRecordTypeId":"=%AOtoServiceRecordTypeId%","SDOtoServiceRecordTypeId":"=%SDOtoServiceRecordTypeId%","MCtoServiceRecordTypeId":"=%MCtoServiceRecordTypeId%","AccountRelationshipId":"=%AccountRelationshipId%","RecordType":"=%RecordTypeName%","AccountRelationship":"=%AccountRelationshipName%","AccountId":"=%AccountId%","Owner":"=%OwnerName%"},"label":"SetValues","controlWidth":12,"aggElements":{}},"offSet":0,"name":"SetValues","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues","lwcId":"lwc2"},{"type":"Step","propSetMap":{"businessEvent":"","businessCategory":"","pubsub":false,"message":{},"ssm":false,"wpm":false,"errorMessage":{"default":null,"custom":[]},"allowSaveForLater":true,"chartLabel":null,"instructionKey":"","HTMLTemplateId":"","conditionType":"Hide if False","show":{"group":{"rules":[{"field":"RecordTypeName","condition":"=","data":"Provider_to_Management_Company"},{"data":"Provider_to_Administrative_Organisation","condition":"=","field":"RecordTypeName"}],"operator":"OR"}},"knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"dataCategoryCriteria":"","keyword":"","publishStatus":"Online","language":"English"},"remoteOptions":{},"remoteTimeout":30000,"remoteMethod":"","remoteClass":"","showPersistentComponent":[true,false],"instruction":"","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","cancelMessage":"Are you sure?","cancelLabel":"Cancel","nextWidth":3,"nextLabel":"Next","previousWidth":3,"previousLabel":"Previous","validationRequired":true,"label":"Attach Service","uiElements":{"AttachServiceMCOrAO":"","AssociatedAccountsMCOrAO":"","LinkService":"","AssociationStartDate":"","AssociationEndDate":"","Reason":"","Comments":""},"aggElements":{}},"offSet":0,"name":"AttachServiceMCOrAO","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text","rootIndex":3,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","maxLength":255,"minLength":0,"ptrnErrText":"","pattern":"","mask":"","helpTextPos":"","helpText":"","help":false,"defaultValue":"%AccountRelationship%","readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":false,"inputWidth":12,"showInputWidth":false,"label":"Associated Accounts","controlWidth":6},"name":"AssociatedAccountsMCOrAO","level":1,"JSONPath":"AttachServiceMCOrAO:AssociatedAccountsMCOrAO","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc30-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Lookup","rootIndex":3,"response":null,"propSetMap":{"errorMessage":{"default":null,"custom":[]},"clearValue":true,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","dataSource":{"mapItems":{"inputParameters":[{"inputParam":"Account","element":"AccountId"}],"phase2MapItems":[{"DomainObjectCreationOrder__c":1,"DomainObjectAPIName__c":"JSON","InterfaceFieldAPIName__c":"AccountServices:Id","DomainObjectFieldAPIName__c":"name"},{"DomainObjectCreationOrder__c":1,"DomainObjectAPIName__c":"JSON","InterfaceFieldAPIName__c":"AccountServices:Name","DomainObjectFieldAPIName__c":"value"}],"phase1MapItems":[{"DomainObjectFieldAPIName__c":"AccountServices","InterfaceObjectLookupOrder__c":1,"FilterValue__c":"Account","FilterOperator__c":"=","InterfaceFieldAPIName__c":"AccountId","InterfaceObjectName__c":"BusinessLicense"}]},"type":"SObject"},"helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"Link Service","controlWidth":6},"name":"LinkService","level":1,"JSONPath":"AttachServiceMCOrAO:LinkService","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bLookup":true,"lwcId":"lwc31-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Date","rootIndex":3,"response":null,"propSetMap":{"maxDate":"","minDate":"","disOnTplt":false,"hide":false,"HTMLTemplateId":"","accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"dateFormat":"dd/MM/yyyy","modelDateFormat":"yyyy-MM-dd","dateType":"string","helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"Association Start Date","controlWidth":6},"name":"AssociationStartDate","level":1,"JSONPath":"AttachServiceMCOrAO:AssociationStartDate","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc32-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Date","rootIndex":3,"response":null,"propSetMap":{"maxDate":"","minDate":"","disOnTplt":false,"hide":false,"HTMLTemplateId":"","accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"dateFormat":"dd/MM/yyyy","modelDateFormat":"yyyy-MM-dd","dateType":"string","helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":false,"inputWidth":12,"showInputWidth":false,"label":"Association End Date","controlWidth":6},"name":"AssociationEndDate","level":1,"JSONPath":"AttachServiceMCOrAO:AssociationEndDate","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc33-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":4,"eleArray":[{"type":"Text Area","rootIndex":3,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Optional if False","show":{"group":{"rules":[{"field":"AssociationEndDate","condition":"<>","data":null}],"operator":"AND"}},"placeholder":"","maxLength":5000,"minLength":0,"ptrnErrText":"","pattern":"","helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":false,"inputWidth":12,"showInputWidth":false,"label":"Reason","controlWidth":6},"name":"Reason","level":1,"JSONPath":"AttachServiceMCOrAO:Reason","indexInParent":4,"index":0,"children":[],"bHasAttachment":false,"bTextarea":true,"lwcId":"lwc34-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":5,"eleArray":[{"type":"Text Area","rootIndex":3,"response":null,"propSetMap":{"controlWidth":6,"label":"Comments","showInputWidth":false,"inputWidth":12,"required":false,"repeat":false,"repeatClone":false,"repeatLimit":null,"readOnly":false,"defaultValue":null,"help":false,"helpText":"","helpTextPos":"","pattern":"","ptrnErrText":"","minLength":0,"maxLength":5000,"placeholder":"","show":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"debounceValue":0,"HTMLTemplateId":"","hide":false,"disOnTplt":false,"autocomplete":null},"name":"Comments","level":1,"JSONPath":"AttachServiceMCOrAO:Comments","indexInParent":5,"index":0,"children":[],"bHasAttachment":false,"bTextarea":true,"lwcId":"lwc35-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"AttachServiceMCOrAO","lwcId":"lwc3"},{"type":"Step","propSetMap":{"label":"Attach Service","validationRequired":true,"previousLabel":"Previous","previousWidth":3,"nextLabel":"Next","nextWidth":3,"cancelLabel":"Cancel","cancelMessage":"Are you sure?","saveLabel":"Save for later","saveMessage":"Are you sure you want to save it for later?","completeLabel":"Complete","completeMessage":"Are you sure you want to complete the script?","instruction":"","showPersistentComponent":[true,false],"remoteClass":"","remoteMethod":"","remoteTimeout":30000,"remoteOptions":{},"knowledgeOptions":{"language":"English","publishStatus":"Online","keyword":"","dataCategoryCriteria":"","remoteTimeout":30000,"typeFilter":""},"show":{"group":{"rules":[{"field":"RecordTypeName","condition":"=","data":"Provider_to_Service_Delivery_Organisation"}],"operator":"AND"}},"conditionType":"Hide if False","HTMLTemplateId":"","instructionKey":"","chartLabel":null,"allowSaveForLater":true,"errorMessage":{"custom":[],"default":null},"wpm":false,"ssm":false,"message":{},"pubsub":false,"businessCategory":"","businessEvent":"","uiElements":{"AttachServiceSDO":"","AssociatedAccountsSDO":"","Service":"","ServiceContractStartDate":"","ServiceContractEndDate":""},"aggElements":{}},"offSet":0,"name":"AttachServiceSDO","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text","rootIndex":4,"response":null,"propSetMap":{"controlWidth":6,"label":"Associated Accounts","showInputWidth":false,"inputWidth":12,"required":false,"repeat":false,"repeatClone":false,"repeatLimit":null,"readOnly":false,"defaultValue":"%AccountRelationship%","help":false,"helpText":"","helpTextPos":"","mask":"","pattern":"","ptrnErrText":"","minLength":0,"maxLength":255,"placeholder":"","show":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"debounceValue":0,"HTMLTemplateId":"","hide":false,"disOnTplt":false,"autocomplete":null},"name":"AssociatedAccountsSDO","level":1,"JSONPath":"AttachServiceSDO:AssociatedAccountsSDO","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc40-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Lookup","rootIndex":4,"response":null,"propSetMap":{"controlWidth":6,"label":"Service","showInputWidth":false,"inputWidth":12,"required":true,"repeat":false,"repeatClone":false,"repeatLimit":null,"readOnly":false,"defaultValue":null,"help":false,"helpText":"","helpTextPos":"","dataSource":{"type":"SObject","mapItems":{"phase1MapItems":[{"InterfaceObjectName__c":"BusinessLicense","InterfaceFieldAPIName__c":"AccountId","FilterOperator__c":"=","FilterValue__c":"Account","InterfaceObjectLookupOrder__c":1,"DomainObjectFieldAPIName__c":"AccountServices"}],"phase2MapItems":[{"DomainObjectFieldAPIName__c":"name","InterfaceFieldAPIName__c":"AccountServices:Id","DomainObjectAPIName__c":"JSON","DomainObjectCreationOrder__c":1},{"DomainObjectFieldAPIName__c":"value","InterfaceFieldAPIName__c":"AccountServices:Name","DomainObjectAPIName__c":"JSON","DomainObjectCreationOrder__c":1}],"inputParameters":[{"element":"AccountId","inputParam":"Account"}]}},"placeholder":"","show":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":"","hide":false,"disOnTplt":false,"clearValue":true,"errorMessage":{"custom":[],"default":null}},"name":"Service","level":1,"JSONPath":"AttachServiceSDO:Service","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bLookup":true,"lwcId":"lwc41-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Date","rootIndex":4,"response":null,"propSetMap":{"controlWidth":6,"label":"Service Contract Start Date","showInputWidth":false,"inputWidth":12,"required":true,"repeat":false,"repeatClone":false,"repeatLimit":null,"readOnly":false,"defaultValue":null,"help":false,"helpText":"","helpTextPos":"","dateType":"string","modelDateFormat":"yyyy-MM-dd","dateFormat":"dd/MM/yyyy","show":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":"","hide":false,"disOnTplt":false,"minDate":"","maxDate":""},"name":"ServiceContractStartDate","level":1,"JSONPath":"AttachServiceSDO:ServiceContractStartDate","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc42-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Date","rootIndex":4,"response":null,"propSetMap":{"controlWidth":6,"label":"Service Contract End Date","showInputWidth":false,"inputWidth":12,"required":false,"repeat":false,"repeatClone":false,"repeatLimit":null,"readOnly":false,"defaultValue":null,"help":false,"helpText":"","helpTextPos":"","dateType":"string","modelDateFormat":"yyyy-MM-dd","dateFormat":"dd/MM/yyyy","show":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":"","hide":false,"disOnTplt":false,"minDate":"","maxDate":""},"name":"ServiceContractEndDate","level":1,"JSONPath":"AttachServiceSDO:ServiceContractEndDate","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc43-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"AttachServiceSDO","lwcId":"lwc4"},{"type":"Integration Procedure Action","propSetMap":{"businessEvent":"","businessCategory":"","enableActionMessage":false,"enableDefaultAbort":false,"errorMessage":{"default":null,"custom":[]},"svgIcon":"","svgSprite":"","pubsub":false,"message":{},"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"showPersistentComponent":[true,false],"redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectNextWidth":3,"redirectNextLabel":"Next","redirectTemplateUrl":"vlcAcknowledge.html","redirectPageName":"","validationRequired":"Step","failureAbortMessage":"Are you sure?","failureGoBackLabel":"Go Back","failureAbortLabel":"Abort","failureNextLabel":"Continue","postMessage":"Done","inProgressMessage":"In Progress","extraPayload":{},"responseJSONNode":"","responseJSONPath":"","sendJSONNode":"","sendJSONPath":"","postTransformBundle":"","preTransformBundle":"","remoteTimeout":30000,"remoteOptions":{"chainable":false,"useFuture":false,"postTransformBundle":"","preTransformBundle":""},"useContinuation":false,"integrationProcedureKey":"ThirdParty_AttachService","label":"IntegrationProcedureAction","controlWidth":12,"aggElements":{}},"offSet":0,"name":"IntegrationProcedureAction","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"IntegrationProcedureAction","lwcId":"lwc5"},{"type":"Navigate Action","propSetMap":{"targetName":"Account_Relationship__c","businessEvent":"","businessCategory":"","targetLWCLayout":"lightning","replace":true,"iconPosition":"left","iconVariant":"","iconName":"","variant":"brand","targetId":"%AccountRelationshipId%","targetFilter":"Recent","loginAction":"login","recordAction":"view","objectAction":"home","targetType":"Record","message":{},"pubsub":false,"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"validationRequired":"Submit","label":"NavigateAction","controlWidth":12,"aggElements":{}},"offSet":0,"name":"NavigateAction","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction","lwcId":"lwc6"}],"bReusable":false,"bpVersion":4,"bpType":"ThirdParty","bpSubType":"ServiceCreation","bpLang":"English","bHasAttachment":false,"lwcVarMap":{}};