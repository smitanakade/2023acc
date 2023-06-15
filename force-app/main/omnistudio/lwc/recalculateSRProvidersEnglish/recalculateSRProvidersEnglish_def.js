export const OMNIDEF = {"userTimeZone":660,"userProfile":"System Administrator","userName":"audrey.mclean@accenture.com.prvddev","userId":"0059r000001R3CeAAK","userCurrencyCode":"AUD","timeStamp":"2022-11-16T22:47:00.751Z","sOmniScriptId":"0jN9r00000018jVEAQ","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":""},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"scrollBehavior":"auto","saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge","dispOutsideOmni":false}],"message":{},"mergeSavedData":false,"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":true,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"currentLanguage":"en_US","currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":false,"allowCancel":true},"prefillJSON":"{}","lwcId":"fcac34a6-1ff8-76cd-c988-6b7635e16327","labelMap":{"DataRaptorExtractAction1":"DataRaptorExtractAction1","SetDomain":"Step0_Providers:Block1:SetDomain","br":"Step0_Providers:Block1:br","TextBlock1":"Step0_Providers:Block1:TextBlock1","SetProv-Block":"Step0_Providers:Block2:SetProv-Block","Block2":"Step0_Providers:Block2","Block1":"Step0_Providers:Block1","TextBlock5":"Warning_Role:TextBlock5","NavigateAction1":"Warning_Time:NavigateAction1","TextBlock2":"Warning_Time:TextBlock2","NavigateAction2":"Step1_Services:NavigateAction2","CustomLWC1":"Step1_Services:CustomLWC1","TextBlock3":"Step1_Services:TextBlock3","TextBlock4":"Step1_Services:TextBlock4","Warning_Time":"Warning_Time","IPCallAllDomainsIP":"IPCallAllDomainsIP","IPCallDomainIPs":"IPCallDomainIPs","SetValues3":"SetValues3","SetErrors5":"SetErrors5","DataRaptorTransformAction1":"DataRaptorTransformAction1","Step1_Services":"Step1_Services","DRGetProviderServices":"DRGetProviderServices","SetValues2":"SetValues2","SetErrors1":"SetErrors1","Step0_Providers":"Step0_Providers","Warning_Role":"Warning_Role","HasCustomPermission":"HasCustomPermission","GetUserDetails":"GetUserDetails","SetValues1":"SetValues1","SetProv":"Step0_Providers:Block2:SetProv-Block:SetProv"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[true,false],"show":null,"pubsub":false,"message":{},"label":"SetValues1","elementValueMap":{"recordId":"%ContextId%"},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetValues1","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues1","lwcId":"lwc0"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[true,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"GetUserDetails","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"dataRaptor Input Parameters":[{"inputParam":"UserID","element":"userId"}],"controlWidth":12,"businessEvent":"","businessCategory":"","bundle":"SRQI_DR_ExtractUserEmail","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"GetUserDetails","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"GetUserDetails","lwcId":"lwc1"},{"type":"Remote Action","propSetMap":{"businessEvent":"","businessCategory":"","useContinuation":false,"enableActionMessage":false,"enableDefaultAbort":false,"errorMessage":{"default":null,"custom":[]},"svgIcon":"","svgSprite":"","pubsub":false,"message":{},"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"showPersistentComponent":[true,false],"redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectNextWidth":3,"redirectNextLabel":"Next","redirectTemplateUrl":"vlcAcknowledge.html","redirectPageName":"","validationRequired":"Step","failureAbortMessage":"Are you sure?","failureGoBackLabel":"Go Back","failureAbortLabel":"Abort","failureNextLabel":"Continue","postMessage":"Done","inProgressMessage":"In Progress","extraPayload":{"userId":"%userId%"},"responseJSONNode":"hasCustomPermission","responseJSONPath":"","sendJSONNode":"","sendJSONPath":"","postTransformBundle":"","preTransformBundle":"","remoteTimeout":30000,"remoteOptions":{"postTransformBundle":"","preTransformBundle":""},"remoteMethod":"getUserCustomPermissions","remoteClass":"SRQIUserCustomPermissions","label":"HasCustomPermission","controlWidth":12,"aggElements":{}},"offSet":0,"name":"HasCustomPermission","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"bRemoteAction":true,"JSONPath":"HasCustomPermission","lwcId":"lwc2"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"hasCustomPermission:result","data":"false","condition":"="}],"operator":"OR"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":"0","previousLabel":"Previous","nextWidth":"0","nextLabel":"Next","message":{},"label":"Access Denied","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"Warning_Role":""},"aggElements":{}},"offSet":0,"name":"Warning_Role","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":3,"response":null,"propSetMap":{"textKey":"","text":"<p>The ability to recalculate the Star Rating of a Provider's Services is restricted to Department officers who have the \"Star Ratings Administrator\" custom permission.</p>","show":null,"sanitize":false,"label":"TextBlock5","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock5","level":1,"JSONPath":"Warning_Role:TextBlock5","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc30-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Warning_Role","lwcId":"lwc3"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Select the provider to be recalculated","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"Step0_Providers":"","SetDomain":"","Block1":"","SetProv":"","SetProv-Block":"","Block2":""},"aggElements":{}},"offSet":0,"name":"Step0_Providers","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Block","rootIndex":4,"response":null,"propSetMap":{"bus":true,"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"label":"","hide":false,"controlWidth":6,"conditionType":"Hide if False","collapse":false,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"Block1","level":1,"JSONPath":"Step0_Providers:Block1","indexInParent":0,"index":0,"children":[{"response":null,"level":2,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":4,"response":null,"propSetMap":{"textKey":"","text":"<p><span data-lucid-type=\"application/vnd.lucid.text\" data-lucid-content=\"{&quot;t&quot;:&quot;Note: Recalculating an individual domain will automatically recalculate Total as the final process step&quot;,&quot;m&quot;:[{&quot;s&quot;:0,&quot;n&quot;:&quot;s&quot;,&quot;v&quot;:22.22222222222222,&quot;e&quot;:103},{&quot;s&quot;:0,&quot;n&quot;:&quot;c&quot;,&quot;v&quot;:&quot;3a414aff&quot;,&quot;e&quot;:103}]}\">Note: Recalculating an individual domain will automatically recalculate Total as the final step in the recalculation process</span></p>","show":null,"sanitize":false,"label":"TextBlock1","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock1","level":2,"JSONPath":"Step0_Providers:Block1|1:TextBlock1","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc4000-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":1,"eleArray":[{"type":"Line Break","rootIndex":4,"response":null,"propSetMap":{"show":null,"padding":10,"label":"LineBreak1","HTMLTemplateId":""},"name":"br","level":2,"JSONPath":"Step0_Providers:Block1|1:br","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bLineBreak":true,"lwcId":"lwc4001-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":2,"eleArray":[{"type":"Radio","rootIndex":4,"response":null,"propSetMap":{"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"options":[{"value":"Consumer Experience Report","name":"callCER","developerName":null,"autoAdv":null},{"value":"Quality Indicator","name":"callQI","developerName":null,"autoAdv":null},{"value":"Care Minutes","name":"callCM","developerName":null,"autoAdv":null},{"value":"Overall Star Rating ONLY","name":"callTotal","developerName":null,"autoAdv":null},{"value":"ALL Subdomains","name":"callAll","developerName":null,"autoAdv":null}],"optionWidth":100,"optionSource":{"type":"","source":""},"optionHeight":100,"label":"","imageCountInRow":3,"horizontalMode":false,"hide":false,"helpTextPos":"","helpText":"","help":false,"enableCaption":true,"disOnTplt":false,"defaultValue":null,"controllingField":{"type":"","source":"","element":""},"controlWidth":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SetDomain","level":2,"JSONPath":"Step0_Providers:Block1|1:SetDomain","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bRadio":true,"lwcId":"lwc4002-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bBlock":true,"lwcId":"lwc40-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Block","rootIndex":4,"response":null,"propSetMap":{"bus":true,"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"label":"","hide":false,"controlWidth":6,"conditionType":"Hide if False","collapse":false,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"Block2","level":1,"JSONPath":"Step0_Providers:Block2","indexInParent":1,"index":0,"children":[{"response":null,"level":2,"indexInParent":0,"eleArray":[{"type":"Type Ahead Block","rootIndex":4,"response":null,"propSetMap":{"useDataJson":false,"typeAheadKey":"Name","showInputWidth":false,"show":{"group":{"rules":[{"field":"ContextId","condition":"=","data":null}],"operator":"AND"}},"required":false,"readOnly":false,"newItemLabel":"","minLength":0,"maxLength":255,"label":"Select Provider","inputWidth":12,"hideMap":true,"hideEditButton":true,"helpTextPos":"","helpText":"","help":false,"googleTransformation":{"street":"","postal_code":"","locality":"","country":"","administrative_area_level_2":"","administrative_area_level_1":""},"googleMapsAPIKey":"","googleAddressCountry":"all","enableLookup":false,"enableGoogleMapsAutocomplete":false,"editMode":false,"disableDataFilter":false,"debounceValue":0,"dataProcessorFunction":"","dataJsonPath":"","controlWidth":12,"conditionType":"Hide if False","callFrequency":300,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SetProv-Block","level":2,"JSONPath":"Step0_Providers:Block2|1:SetProv-Block","indexInParent":0,"index":0,"children":[{"response":null,"level":3,"indexInParent":0,"eleArray":[{"type":"Type Ahead","rootIndex":0,"response":null,"propSetMap":{"taAction":{"type":"DataRaptor Extract Action","rootIndex":4,"response":null,"propSetMap":{"_di":1,"repeat":false,"readOnly":false,"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[true,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"DataRaptorExtractAction1","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"dataRaptor Input Parameters":[],"controlWidth":12,"businessEvent":"","businessCategory":"","bundle":"SRQI_DR_ExtractProvsforRecalc","HTMLTemplateId":""},"name":"DataRaptorExtractAction1","level":3,"JSONPath":"Step0_Providers:Block2|1:SetProv-Block:SetProv","indexInParent":0,"index":0,"children":[],"bHasAttachment":false},"useDataJson":false,"typeAheadKey":"Name","showInputWidth":false,"show":{"group":{"rules":[{"field":"ContextId","condition":"=","data":null}],"operator":"AND"}},"required":false,"readOnly":false,"newItemLabel":"","minLength":0,"maxLength":255,"label":"Select Provider","inputWidth":12,"hideMap":true,"hideEditButton":true,"helpTextPos":"","helpText":"","help":false,"googleTransformation":{"street":"","postal_code":"","locality":"","country":"","administrative_area_level_2":"","administrative_area_level_1":""},"googleMapsAPIKey":"","googleAddressCountry":"all","enableLookup":false,"enableGoogleMapsAutocomplete":false,"editMode":false,"disableDataFilter":false,"debounceValue":0,"dataProcessorFunction":"","dataJsonPath":"","controlWidth":12,"conditionType":"Hide if False","callFrequency":300,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SetProv","level":3,"JSONPath":"Step0_Providers:Block2|1:SetProv-Block:SetProv","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTypeahead":true,"lwcId":"lwc410000-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bTypeaheadBlock":true,"lwcId":"lwc4100-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bBlock":true,"lwcId":"lwc41-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Step0_Providers","lwcId":"lwc4"},{"type":"Set Errors","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"SetProv","data":"","condition":"="},{"data":null,"condition":"=","field":"ContextId"}],"operator":"AND"}},"pubsub":false,"message":{},"label":"SetErrors1","elementErrorMap":{"SetProv":"Please select a provider to continue"},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetErrors1","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bSetErrors":true,"JSONPath":"SetErrors1","lwcId":"lwc5"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[true,false],"show":null,"pubsub":false,"message":{},"label":"SetValues2","elementValueMap":{"recordId":"=IF(%recordId% = null, %Step0_Providers:Block2:SetProv-Block:Id%, %recordId%)"},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetValues2","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues2","lwcId":"lwc6"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[true,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"DataRaptorExtractAction1","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"dataRaptor Input Parameters":[{"inputParam":"recordId","element":"recordId"}],"controlWidth":12,"businessEvent":"","businessCategory":"","bundle":"SRQI_DR_ExtractOpServForProvider","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"DRGetProviderServices","level":0,"indexInParent":7,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"DRGetProviderServices","lwcId":"lwc7"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Provider Services","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":"efg","custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"Step1_Services":""},"aggElements":{"CustomLWC1":""}},"offSet":0,"name":"Step1_Services","level":0,"indexInParent":8,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":8,"response":null,"propSetMap":{"textKey":"","text":"<p>%ProviderName% has no associated Services&nbsp;</p>\n<p></p>\n<p>Please select a provider with associated services to continue</p>","show":{"group":{"rules":[{"field":"ServIds:ServID","data":"0","condition":"="}],"operator":"AND"}},"sanitize":false,"label":"TextBlock3","dataJSON":true,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock4","level":1,"JSONPath":"Step1_Services:TextBlock4","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc80-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Text Block","rootIndex":8,"response":null,"propSetMap":{"textKey":"","text":"<p>%ProviderName% has the following services with the following statuses:</p>\n<p><em><span style=\"font-size: 14px;\">Please note, any service that is not operational will not be recalculated by this process</span></em></p>","show":{"group":{"rules":[{"field":"ServIds:ServID","data":"0","condition":"<>"}],"operator":"AND"}},"sanitize":false,"label":"TextBlock3","dataJSON":true,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock3","level":1,"JSONPath":"Step1_Services:TextBlock3","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc81-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Custom Lightning Web Component","rootIndex":8,"response":null,"propSetMap":{"show":{"group":{"rules":[{"field":"ServIds:ServID","data":"0","condition":"<>"}],"operator":"AND"}},"lwcName":"cfSRQI_FC_ServStatus","label":"CustomLWC1","hide":false,"customAttributes":[{"source":"%recordId%","name":"record-id"}],"controlWidth":12,"conditionType":"Hide if False","bStandalone":false},"name":"CustomLWC1","level":1,"JSONPath":"Step1_Services:CustomLWC1","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bcustomlightningwebcomponent1":true,"lwcId":"lwc82-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Navigate Action","rootIndex":8,"response":null,"propSetMap":{"wpm":false,"variant":"outline-brand","validationRequired":"Submit","targetType":"Record","targetName":"Account","targetLWCLayout":"lightning","targetId":"%recordId%","targetFilter":"Recent","ssm":false,"show":null,"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"Cancel","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":3,"businessEvent":"","businessCategory":"","HTMLTemplateId":""},"name":"NavigateAction2","level":1,"JSONPath":"Step1_Services:NavigateAction2","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bNavigate":true,"lwcId":"lwc83-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Step1_Services","lwcId":"lwc8"},{"type":"DataRaptor Transform Action","propSetMap":{"businessEvent":"","businessCategory":"","enableActionMessage":false,"enableDefaultAbort":false,"errorMessage":{"default":null,"custom":[]},"pubsub":false,"message":{},"ssm":false,"wpm":false,"HTMLTemplateId":"","show":{"group":{"rules":[{"field":"%Step1_Services:ServCount%","condition":"<","data":"2"}],"operator":"AND"}},"showPersistentComponent":[true,false],"redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectNextWidth":3,"redirectNextLabel":"Next","redirectTemplateUrl":"vlcAcknowledge.html","redirectPageName":"","validationRequired":"Submit","failureAbortMessage":"Are you sure?","failureGoBackLabel":"Go Back","failureAbortLabel":"Abort","failureNextLabel":"Continue","postMessage":"Done","inProgressMessage":"In Progress","responseJSONNode":"","responseJSONPath":"","sendJSONNode":"ServIdforXform","sendJSONPath":"ServIds","remoteTimeout":30000,"bundle":"SRQI_DR_TransformServIDtoList","ignoreCache":false,"label":"DataRaptorTransformAction1","controlWidth":12,"aggElements":{}},"offSet":0,"name":"DataRaptorTransformAction1","level":0,"indexInParent":9,"bHasAttachment":false,"bEmbed":false,"bDataRaptorTransformAction":true,"JSONPath":"DataRaptorTransformAction1","lwcId":"lwc9"},{"type":"Set Errors","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"ServIds:ServID","data":"0","condition":"="}],"operator":"AND"}},"pubsub":false,"message":{},"label":"SetErrors5","elementErrorMap":{"CustomLWC1":"xyz"},"controlWidth":10,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetErrors5","level":0,"indexInParent":10,"bHasAttachment":false,"bEmbed":false,"bSetErrors":true,"JSONPath":"SetErrors5","lwcId":"lwc10"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[true,false],"show":null,"pubsub":false,"message":{},"label":"SetValues3","elementValueMap":{"ServIds":"%ServIds%"},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetValues3","level":0,"indexInParent":11,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues3","lwcId":"lwc11"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"SetDomain","data":"callAll","condition":"<>"}],"operator":"AND"}},"sendOnlyExtraPayload":true,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"queueableChainable":true,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"lwcComponentOverride":"","label":"IntegrationProcedureAction1","invokeMode":"fireAndForget","integrationProcedureKey":"Recalculation_Subdomain","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"SetDomain":"%Step0_Providers:Block1:SetDomain%","ServIds":"%ServIds%","Email":"%Email%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"IPCallDomainIPs","level":0,"indexInParent":12,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"IPCallDomainIPs","lwcId":"lwc12"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"SetDomain","data":"callAll","condition":"="}],"operator":"AND"}},"sendOnlyExtraPayload":true,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"queueableChainable":true,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"IPCallAllDomainsIP","invokeMode":"fireAndForget","integrationProcedureKey":"Recalculation_AllSubdomains","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"SetDomain":"%Step2_Domains:SetDomain%","ServIds":"%ServIds%","RPId":"%RPId%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"IPCallAllDomainsIP","level":0,"indexInParent":13,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"IPCallAllDomainsIP","lwcId":"lwc13"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":"0","previousLabel":"Previous","nextWidth":"0","nextLabel":"Next","message":{},"label":"Success","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"Warning_Time":""},"aggElements":{}},"offSet":0,"name":"Warning_Time","level":0,"indexInParent":14,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":14,"response":null,"propSetMap":{"textKey":"","text":"<p>Recalculating the %Step2_Domains:SetDomain% rating for a provider's services is a time consuming operation. Please check these records periodically for process completion</p>","show":null,"sanitize":false,"label":"TextBlock2","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"TextBlock2","level":1,"JSONPath":"Warning_Time:TextBlock2","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc140-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Navigate Action","rootIndex":14,"response":null,"propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Record","targetName":"Account","targetLWCLayout":"lightning","targetId":"%recordId%","targetFilter":"Recent","ssm":false,"show":null,"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"Done","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":2,"businessEvent":"","businessCategory":"","HTMLTemplateId":""},"name":"NavigateAction1","level":1,"JSONPath":"Warning_Time:NavigateAction1","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bNavigate":true,"lwcId":"lwc141-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Warning_Time","lwcId":"lwc14"}],"bReusable":false,"bpVersion":8,"bpType":"RecalculateSR","bpSubType":"Providers","bpLang":"English","bHasAttachment":false,"lwcVarMap":{"recordId":null}};