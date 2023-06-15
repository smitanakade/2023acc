export const OMNIDEF = {"userTimeZone":600,"userProfile":"System Administrator","userName":"audrey.mclean@health.gov.au.r3dev","userId":"005Bm000001YYIDIA4","userCurrencyCode":"AUD","timeStamp":"2023-05-15T05:44:50.382Z","sOmniScriptId":"0jNBm0000003KrpMAE","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":""},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"scrollBehavior":"smooth","saveURLPatterns":{},"saveObjectId":"","saveNameTemplate":"Create Approved Provider","saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":10,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge","dispOutsideOmni":false}],"message":{},"mergeSavedData":false,"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":false,"errorMessage":{"default":"Error-Bugger","custom":[]},"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"currentLanguage":"en_US","currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":false,"allowCancel":true},"prefillJSON":"{}","lwcId":"63cf26b0-68b7-cd40-a76e-d8c0c05b5090","labelMap":{"LineBreak39":"BenchmarkingOrganisation:BMDetail:LineBreak39","BMName":"BenchmarkingOrganisation:BMDetail:BMName","BMInformation":"BenchmarkingOrganisation:BMDetail:BMInformation","BMDetail":"BenchmarkingOrganisation:BMDetail","NavigateAction_IFNoAccount":"NavigateAction_IFNoAccount","NavigateAction_Account":"NavigateAction_Account","CreateRecords":"CreateRecords","BenchmarkingOrganisation":"BenchmarkingOrganisation","SetValues":"SetValues","CANCEL":"CANCEL"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Cancel Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Object","targetName":"Account","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"showCancelPrompt":true,"show":null,"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"Cancel","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"CANCEL","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bCancel":true,"JSONPath":"CANCEL","lwcId":"lwc0"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[true,false],"show":null,"pubsub":false,"message":{},"label":"SetValues","elementValueMap":{"RemoveSearchExisting":true,"ShowEffectiveDateOverride":"=\"Yes\"","SelectionOverride":"=\"Both Addresses\"","RecordType":"Benchmarker","Origin":"=\"OmniScript\"","LocationRecordTypeOverride":"=\"Account Address\"","AddressRecordTypeOverride":"=\"Physical Address\"","ABNAction":"CreateNewAccount"},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetValues","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues","lwcId":"lwc1"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Done","message":{},"label":"Benchmarker Organisation Details","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"BenchmarkingOrganisation":"","BMName":"","BMDetail":""},"aggElements":{}},"offSet":0,"name":"BenchmarkingOrganisation","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Block","rootIndex":2,"response":null,"propSetMap":{"bus":true,"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"label":"","hide":false,"controlWidth":12,"conditionType":"Hide if False","collapse":false,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"BMDetail","level":1,"JSONPath":"BenchmarkingOrganisation:BMDetail","indexInParent":0,"index":0,"children":[{"response":null,"level":2,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":2,"response":null,"propSetMap":{"textKey":"","text":"<h2><span style=\"color: #52386b;\"><strong>Benchmarker Details</strong></span></h2>","show":null,"sanitize":false,"label":"TextBlock1","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"BMInformation","level":2,"JSONPath":"BenchmarkingOrganisation:BMDetail|1:BMInformation","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc2000-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":1,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","placeholder":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Account Name","inputWidth":12,"hide":false,"helpTextPos":"","helpText":"Please enter the Name registered with ASIC (if applicable)","help":true,"disOnTplt":false,"defaultValue":"","debounceValue":0,"controlWidth":6,"conditionType":"Hide if False","autocomplete":null,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"BMName","level":2,"JSONPath":"BenchmarkingOrganisation:BMDetail|1:BMName","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2001-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":2,"eleArray":[{"type":"Line Break","rootIndex":2,"response":null,"propSetMap":{"show":null,"padding":10,"label":"LineBreak39","HTMLTemplateId":""},"name":"LineBreak39","level":2,"JSONPath":"BenchmarkingOrganisation:BMDetail|1:LineBreak39","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bLineBreak":true,"lwcId":"lwc2002-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bBlock":true,"lwcId":"lwc20-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"BenchmarkingOrganisation","lwcId":"lwc2"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"toastComplete":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":null,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"CreateRecords","integrationProcedureKey":"BenchmarkerProvider_Create","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"CreateRecords","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"CreateRecords","lwcId":"lwc3"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Record","targetName":"Account","targetLWCLayout":"lightning","targetId":"%AccountId%","targetFilter":"Recent","ssm":false,"show":{"group":{"rules":[{"field":"AccountId","data":null,"condition":"<>"}],"operator":"AND"}},"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"NavigateAction","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"NavigateAction_Account","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction_Account","lwcId":"lwc4"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Object","targetName":"Account","targetLWCLayout":"lightning","targetId":"%AccountId%","targetFilter":"Recent","ssm":false,"show":{"group":{"rules":[{"field":"AccountId","data":null,"condition":"="}],"operator":"AND"}},"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"NavigateAction","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"NavigateAction_IFNoAccount","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction_IFNoAccount","lwcId":"lwc5"}],"bReusable":false,"bpVersion":1,"bpType":"Benchmarker","bpSubType":"Create","bpLang":"English","bHasAttachment":false,"lwcVarMap":{}};