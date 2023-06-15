export const OMNIDEF = {"userTimeZone":600,"userProfile":"System Administrator","userName":"scott.naughton@health.gov.au.gpmsdev1","userId":"0059r000000oYZiAAM","userCurrencyCode":"AUD","timeStamp":"2022-09-15T22:10:36.993Z","sOmniScriptId":"0jN9r0000000h09EAA","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"currentLanguage":"en_US","scrollBehavior":"auto","disableUnloadWarn":true,"stepChartPlacement":"right","stylesheet":{"lightningRtl":"","newportRtl":"","lightning":"","newport":""},"errorMessage":{"custom":[]},"consoleTabIcon":"custom:custom18","consoleTabTitle":null,"rtpSeed":false,"showInputWidth":false,"currencyCode":"","autoFocus":false,"pubsub":false,"message":{},"ssm":false,"wpm":false,"consoleTabLabel":"New","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","cancelSource":"%ContextId%","allowCancel":true,"cancelType":"SObject","visualforcePagesAvailableInPreview":{},"mergeSavedData":false,"hideStepChart":true,"timeTracking":false,"knowledgeArticleTypeQueryFieldsMap":{},"lkObjName":null,"bLK":false,"enableKnowledge":false,"trackingCustomData":{},"seedDataJSON":{},"elementTypeToHTMLTemplateMapping":{},"autoSaveOnStepNext":false,"saveURLPatterns":{},"saveObjectId":"%ContextId%","saveContentEncoded":false,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveNameTemplate":null,"allowSaveForLater":false,"persistentComponent":[{"modalConfigurationSetting":{"modalSize":"lg","modalController":"ModalProductCtrl","modalHTMLTemplateId":"vlcProductConfig.html"},"itemsKey":"cartItems","id":"vlcCart","responseJSONNode":"","responseJSONPath":"","sendJSONNode":"","sendJSONPath":"","postTransformBundle":"","preTransformBundle":"","remoteOptions":{"postTransformBundle":"","preTransformBundle":""},"remoteTimeout":30000,"remoteMethod":"","remoteClass":"","label":"","render":false},{"modalConfigurationSetting":{"modalSize":"lg","modalController":"","modalHTMLTemplateId":""},"itemsKey":"knowledgeItems","id":"vlcKnowledge","postTransformBundle":"","preTransformBundle":"","remoteOptions":{"postTransformBundle":"","preTransformBundle":""},"remoteTimeout":30000,"remoteMethod":"","remoteClass":"","label":"","dispOutsideOmni":false,"render":false}]},"prefillJSON":"{}","lwcId":"e6de440b-8e61-a284-8392-7b8bc60112c0","labelMap":{"IsPostcodeValid2":"PostalAddress_DataEntry:PostAddress_DE:IsPostcodeValid2","PostAddress_FullAddress":"PostalAddress_DataEntry:PostAddress_DE:PostAddress_FullAddress","PostAddress_Country_DE":"PostalAddress_DataEntry:PostAddress_DE:PostAddress_Country_DE","PostcodeDisplay_PostalAddress":"PostalAddress_DataEntry:PostAddress_DE:PostcodeDisplay_PostalAddress","StateDisplay_PostalAddress":"PostalAddress_DataEntry:PostAddress_DE:StateDisplay_PostalAddress","CityDisplay_PostalAddress":"PostalAddress_DataEntry:PostAddress_DE:CityDisplay_PostalAddress","StreetDisplay_PostalAddress":"PostalAddress_DataEntry:PostAddress_DE:StreetDisplay_PostalAddress","PostAddress_CareOf_DE":"PostalAddress_DataEntry:PostAddress_DE:PostAddress_CareOf_DE","AsAboveAddress":"PhysicalAddress:PhysAddress:AsAboveAddress","LineBreak20":"PhysicalAddress:PhysAddress:LineBreak20","IsPostcodeValid":"PhysicalAddress:PhysAddress:IsPostcodeValid","PhysAddress_FullAddress":"PhysicalAddress:PhysAddress:PhysAddress_FullAddress","PhysAddress_LocationType":"PhysicalAddress:PhysAddress:PhysAddress_LocationType","CountryDisplay_PhysicalAddress":"PhysicalAddress:PhysAddress:CountryDisplay_PhysicalAddress","PostcodeDisplay_PhysicalAddress":"PhysicalAddress:PhysAddress:PostcodeDisplay_PhysicalAddress","StateDisplay_PhysicalAddress":"PhysicalAddress:PhysAddress:StateDisplay_PhysicalAddress","CityDisplay_PhysicalAddress":"PhysicalAddress:PhysAddress:CityDisplay_PhysicalAddress","StreetDisplay_PhysicalAddress":"PhysicalAddress:PhysAddress:StreetDisplay_PhysicalAddress","Messaging2":"PostalAddress_DataEntry:Messaging2","PostAddress_DE":"PostalAddress_DataEntry:PostAddress_DE","Messaging1":"PhysicalAddress:Messaging1","PhysAddress":"PhysicalAddress:PhysAddress","NavigateAction":"NavigateAction","UpdateAddresses":"UpdateAddresses","SetPostalAddressDetails":"SetPostalAddressDetails","PostalAddress_DataEntry":"PostalAddress_DataEntry","PhysicalAddress":"PhysicalAddress","SetAccountAddressValues":"SetAccountAddressValues","CANCEL":"CANCEL"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Cancel Action","propSetMap":{"targetName":"Account","businessEvent":"","businessCategory":"","targetLWCLayout":"lightning","replace":true,"iconPosition":"left","iconVariant":"","iconName":"","variant":"brand","targetId":"%CurrentRecordId%","targetFilter":"Recent","loginAction":"login","recordAction":"view","objectAction":"home","targetType":"Record","message":{},"pubsub":false,"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"validationRequired":"Submit","label":"Cancel","controlWidth":12,"aggElements":{}},"offSet":0,"name":"CANCEL","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bCancel":true,"JSONPath":"CANCEL","lwcId":"lwc0"},{"type":"Set Values","propSetMap":{"pubsub":false,"message":{},"ssm":false,"wpm":false,"HTMLTemplateId":"","show":null,"showPersistentComponent":[true,false],"elementValueMap":{"LocationId":"=%LocationId1%","CurrentRecordId":"=%CurrentRecordId1%","LocationRecordType":"=%RecordType1%","AddressRecordType":"=%AddressType1%","Action":"=%Action1%","Type_AccountPostal":"PostalAddress","Type_AccountPhysical":"PhysicalAddress"},"label":"SetValues","controlWidth":12,"aggElements":{}},"offSet":0,"name":"SetAccountAddressValues","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetAccountAddressValues","lwcId":"lwc1"},{"type":"Step","propSetMap":{"label":"Physical Address","validationRequired":true,"previousLabel":"Previous","previousWidth":3,"nextLabel":"Next","nextWidth":"3","cancelLabel":"Cancel","cancelMessage":"Are you sure?","saveLabel":"Save for later","saveMessage":"Are you sure you want to save it for later?","completeLabel":"Complete","completeMessage":"Are you sure you want to complete the script?","instruction":"","showPersistentComponent":[true,false],"remoteClass":"","remoteMethod":"","remoteTimeout":30000,"remoteOptions":{},"knowledgeOptions":{"language":"English","publishStatus":"Online","keyword":"","dataCategoryCriteria":"","remoteTimeout":30000,"typeFilter":""},"show":{"group":{"rules":[{"data":"Physical","condition":"=","field":"AddressRecordType"},{"data":null,"condition":"=","field":"AddressRecordType"}],"operator":"OR"}},"conditionType":"Hide if False","HTMLTemplateId":"","instructionKey":"","chartLabel":null,"allowSaveForLater":false,"errorMessage":{"custom":[],"default":null},"wpm":false,"ssm":false,"message":{},"pubsub":false,"businessCategory":"","businessEvent":"","uiElements":{"PhysicalAddress":"","StreetDisplay_PhysicalAddress":"","CityDisplay_PhysicalAddress":"","StateDisplay_PhysicalAddress":"","PostcodeDisplay_PhysicalAddress":"","AsAboveAddress":"","PhysAddress":""},"aggElements":{"CountryDisplay_PhysicalAddress":"","PhysAddress_LocationType":"","PhysAddress_FullAddress":"","IsPostcodeValid":""}},"offSet":0,"name":"PhysicalAddress","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Block","rootIndex":2,"response":null,"propSetMap":{"bus":true,"controlWidth":8,"label":"","collapse":false,"repeat":false,"repeatClone":false,"repeatLimit":null,"show":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":"","hide":false},"name":"PhysAddress","level":1,"JSONPath":"PhysicalAddress:PhysAddress","indexInParent":0,"index":0,"children":[{"response":null,"level":2,"indexInParent":0,"eleArray":[{"type":"Text Area","rootIndex":2,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","maxLength":255,"minLength":0,"ptrnErrText":"","pattern":"","helpTextPos":"","helpText":"Enter Street Address and include additional address details e.g. Building Name, Suite, Shop Number, etc.","help":true,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"Address","controlWidth":12},"name":"StreetDisplay_PhysicalAddress","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:StreetDisplay_PhysicalAddress","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextarea":true,"lwcId":"lwc2000-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":1,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","maxLength":255,"minLength":0,"ptrnErrText":"","pattern":"","mask":"","helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"Suburb/Town","controlWidth":5},"name":"CityDisplay_PhysicalAddress","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:CityDisplay_PhysicalAddress","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2001-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":2,"eleArray":[{"type":"Select","rootIndex":2,"response":null,"propSetMap":{"lwcComponentOverride":"","disOnTplt":false,"hide":false,"HTMLTemplateId":"","accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"controllingField":{"source":"","type":"","element":""},"optionSource":{"source":"","type":""},"options":[{"autoAdv":null,"value":"ACT","name":"ACT"},{"autoAdv":null,"value":"NSW","name":"NSW"},{"autoAdv":null,"value":"QLD","name":"QLD"},{"autoAdv":null,"value":"VIC","name":"VIC"},{"name":"NT","value":"NT","autoAdv":null},{"name":"SA","value":"SA","autoAdv":null},{"name":"WA","value":"WA","autoAdv":null},{"autoAdv":null,"value":"TAS","name":"TAS"}],"helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"State/Territory","controlWidth":4},"name":"StateDisplay_PhysicalAddress","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:StateDisplay_PhysicalAddress","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bSelect":true,"lwcId":"lwc2002-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":3,"eleArray":[{"type":"Text","rootIndex":2,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","maxLength":4,"minLength":4,"ptrnErrText":"","pattern":"","mask":"9999","helpTextPos":"","helpText":"","help":false,"defaultValue":"","readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"Postcode","controlWidth":3},"name":"PostcodeDisplay_PhysicalAddress","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:PostcodeDisplay_PhysicalAddress","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc2003-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":4,"eleArray":[{"type":"Formula","rootIndex":2,"response":null,"propSetMap":{"disOnTplt":false,"HTMLTemplateId":"","dateFormat":"MM-dd-yyyy","hideGroupSep":false,"dataType":null,"mask":null,"show":null,"hide":true,"expression":"\"Australia\"","inputWidth":12,"showInputWidth":false,"label":"Country","controlWidth":3},"name":"CountryDisplay_PhysicalAddress","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:CountryDisplay_PhysicalAddress","indexInParent":4,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc2004-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":5,"eleArray":[{"type":"Formula","rootIndex":2,"response":null,"propSetMap":{"disOnTplt":false,"HTMLTemplateId":"","dateFormat":"MM-dd-yyyy","hideGroupSep":false,"dataType":null,"mask":null,"show":null,"hide":true,"expression":"\"Physical Address\"","inputWidth":12,"showInputWidth":false,"label":"PhysAddress_LocationType","controlWidth":5},"name":"PhysAddress_LocationType","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:PhysAddress_LocationType","indexInParent":5,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc2005-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":6,"eleArray":[{"type":"Formula","rootIndex":2,"response":null,"propSetMap":{"disOnTplt":false,"HTMLTemplateId":"","dateFormat":"MM-dd-yyyy","hideGroupSep":false,"dataType":null,"mask":null,"show":null,"hide":true,"expression":"%StreetDisplay_PhysicalAddress% + ', ' + %CityDisplay_PhysicalAddress% + ', ' + %StateDisplay_PhysicalAddress% + ', ' + %PostcodeDisplay_PhysicalAddress% + ', ' + %CountryDisplay_PhysicalAddress%","inputWidth":12,"showInputWidth":false,"label":"PhysAddress_FullAddress","controlWidth":4},"name":"PhysAddress_FullAddress","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:PhysAddress_FullAddress","indexInParent":6,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc2006-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":7,"eleArray":[{"type":"Formula","rootIndex":2,"response":null,"propSetMap":{"disOnTplt":false,"HTMLTemplateId":"","dateFormat":"MM-dd-yyyy","hideGroupSep":false,"dataType":null,"mask":null,"show":null,"hide":true,"expression":"IF (%StateDisplay_PhysicalAddress% = 'ACT' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 200 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=299, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'ACT' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 2600 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=2619, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'ACT' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 2900 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=2920, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'NSW' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 1000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=2599, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'NSW' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 2620 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=2899, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'NSW' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 2921 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=2999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'VIC' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 8000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=8999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'VIC' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 3000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=3999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'TAS' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 7000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=7999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'SA' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 5000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=5999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'WA' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 6000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=6999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'NT' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 800 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'QLD' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 9000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'QLD' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 4000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=4999, 'GOOD' ,IF (%StateDisplay_PhysicalAddress% = 'QLD' & NUMBER(%PostcodeDisplay_PhysicalAddress%) >= 9000 & NUMBER(%PostcodeDisplay_PhysicalAddress%) <=9999, 'GOOD','BAD')))))))))))))))","inputWidth":12,"showInputWidth":false,"label":"IsPostcodeValid","controlWidth":4},"name":"IsPostcodeValid","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:IsPostcodeValid","indexInParent":7,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc2007-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":8,"eleArray":[{"type":"Line Break","rootIndex":2,"response":null,"propSetMap":{"label":"LineBreak5","padding":20,"show":null,"HTMLTemplateId":""},"name":"LineBreak20","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:LineBreak20","indexInParent":8,"index":0,"children":[],"bHasAttachment":false,"bLineBreak":true,"lwcId":"lwc2008-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":9,"eleArray":[{"type":"Checkbox","rootIndex":2,"response":null,"propSetMap":{"controlWidth":12,"label":"Checkbox1","repeat":false,"repeatClone":false,"repeatLimit":null,"readOnly":false,"defaultValue":false,"help":false,"helpText":"","helpTextPos":"","checkLabel":"Postal address same as Physical Address","show":{"group":{"rules":[{"field":"AddressRecordType","condition":"=","data":""}],"operator":"AND"}},"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":"","hide":false,"disOnTplt":false},"name":"AsAboveAddress","level":2,"JSONPath":"PhysicalAddress:PhysAddress|1:AsAboveAddress","indexInParent":9,"index":0,"children":[],"bHasAttachment":false,"bCheckbox":true,"lwcId":"lwc2009-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bBlock":true,"lwcId":"lwc20-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Validation","rootIndex":2,"response":null,"propSetMap":{"HTMLTemplateId":"","show":{"group":{"rules":[{"field":"IsPostcodeValid","condition":"=","data":"BAD"},{"data":null,"condition":"<>","field":"PostcodeDisplay_PhysicalAddress"}],"operator":"AND"}},"hideLabel":true,"messages":[{"active":false,"text":"","type":"Success","value":true},{"active":true,"text":"The postcode entered is not valid for the state","type":"Requirement","value":false}],"validateExpression":{"group":{"rules":[{"field":"IsPostcodeValid","condition":"=","data":"GOOD"}],"operator":"AND"}},"label":"Messaging1","controlWidth":12},"name":"Messaging1","level":1,"JSONPath":"PhysicalAddress:Messaging1","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc21-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"PhysicalAddress","lwcId":"lwc2"},{"type":"Step","propSetMap":{"businessEvent":"","businessCategory":"","pubsub":false,"message":{},"ssm":false,"wpm":false,"errorMessage":{"default":null,"custom":[]},"allowSaveForLater":false,"chartLabel":null,"instructionKey":"","HTMLTemplateId":"","conditionType":"Hide if False","show":{"group":{"rules":[{"data":"Postal","condition":"=","field":"AddressRecordType"},{"data":"false","condition":"=","field":"AsAboveAddress"}],"operator":"OR"}},"knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"dataCategoryCriteria":"","keyword":"","publishStatus":"Online","language":"English"},"remoteOptions":{},"remoteTimeout":30000,"remoteMethod":"","remoteClass":"","showPersistentComponent":[true,false],"instruction":"","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","cancelMessage":"Are you sure?","cancelLabel":"Cancel","nextWidth":3,"nextLabel":"Next","previousWidth":3,"previousLabel":"Previous","validationRequired":true,"label":"Postal Address","uiElements":{"PostalAddress_DataEntry":"","PostAddress_CareOf_DE":"","StreetDisplay_PostalAddress":"","CityDisplay_PostalAddress":"","StateDisplay_PostalAddress":"","PostcodeDisplay_PostalAddress":"","PostAddress_DE":""},"aggElements":{"PostAddress_Country_DE":"","PostAddress_FullAddress":"","IsPostcodeValid2":""}},"offSet":0,"name":"PostalAddress_DataEntry","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Block","rootIndex":3,"response":null,"propSetMap":{"bus":true,"hide":false,"HTMLTemplateId":"","accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"collapse":false,"label":"","controlWidth":8},"name":"PostAddress_DE","level":1,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE","indexInParent":0,"index":0,"children":[{"response":null,"level":2,"indexInParent":0,"eleArray":[{"type":"Text","rootIndex":3,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","maxLength":255,"minLength":0,"ptrnErrText":"","pattern":"","mask":"","helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":false,"inputWidth":12,"showInputWidth":false,"label":"Care of","controlWidth":12},"name":"PostAddress_CareOf_DE","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:PostAddress_CareOf_DE","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc3000-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":1,"eleArray":[{"type":"Text Area","rootIndex":3,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","maxLength":255,"minLength":0,"ptrnErrText":"","pattern":"","helpTextPos":"bottom-right","helpText":"Enter Street Address and include additional address details e.g. Building Name, Suite, Shop Number, etc.","help":true,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"Address","controlWidth":12},"name":"StreetDisplay_PostalAddress","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:StreetDisplay_PostalAddress","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bTextarea":true,"lwcId":"lwc3001-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":2,"eleArray":[{"type":"Text","rootIndex":3,"response":null,"propSetMap":{"autocomplete":null,"disOnTplt":false,"hide":false,"HTMLTemplateId":"","debounceValue":0,"accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"placeholder":"","maxLength":50,"minLength":0,"ptrnErrText":"","pattern":"","mask":"","helpTextPos":"","helpText":"","help":false,"defaultValue":"","readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"Suburb/Town","controlWidth":5},"name":"CityDisplay_PostalAddress","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:CityDisplay_PostalAddress","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc3002-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":3,"eleArray":[{"type":"Select","rootIndex":3,"response":null,"propSetMap":{"disOnTplt":false,"hide":false,"HTMLTemplateId":"","accessibleInFutureSteps":false,"conditionType":"Hide if False","show":null,"controllingField":{"source":"","type":"","element":""},"optionSource":{"source":"","type":""},"options":[{"name":"ACT","value":"ACT","autoAdv":null},{"name":"NSW","value":"NSW","autoAdv":null},{"name":"QLD","value":"QLD","autoAdv":null},{"name":"VIC","value":"VIC","autoAdv":null},{"autoAdv":null,"value":"NT","name":"NT"},{"autoAdv":null,"value":"SA","name":"SA"},{"autoAdv":null,"value":"WA","name":"WA"},{"autoAdv":null,"value":"TAS","name":"TAS"}],"helpTextPos":"","helpText":"","help":false,"defaultValue":null,"readOnly":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"required":true,"inputWidth":12,"showInputWidth":false,"label":"State/Territory","controlWidth":4},"name":"StateDisplay_PostalAddress","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:StateDisplay_PostalAddress","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bSelect":true,"lwcId":"lwc3003-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":4,"eleArray":[{"type":"Text","rootIndex":3,"response":null,"propSetMap":{"controlWidth":3,"label":"Postcode","showInputWidth":false,"inputWidth":12,"required":true,"repeat":false,"repeatClone":false,"repeatLimit":null,"readOnly":false,"defaultValue":"","help":false,"helpText":"","helpTextPos":"","mask":"9999","pattern":"","ptrnErrText":"","minLength":4,"maxLength":4,"placeholder":"","show":null,"conditionType":"Hide if False","accessibleInFutureSteps":false,"debounceValue":0,"HTMLTemplateId":"","hide":false,"disOnTplt":false,"autocomplete":null},"name":"PostcodeDisplay_PostalAddress","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:PostcodeDisplay_PostalAddress","indexInParent":4,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc3004-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":5,"eleArray":[{"type":"Formula","rootIndex":3,"response":null,"propSetMap":{"disOnTplt":false,"HTMLTemplateId":"","dateFormat":"MM-dd-yyyy","hideGroupSep":false,"dataType":null,"mask":null,"show":null,"hide":true,"expression":"\"Australia\"","inputWidth":12,"showInputWidth":false,"label":"Country","controlWidth":3},"name":"PostAddress_Country_DE","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:PostAddress_Country_DE","indexInParent":5,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc3005-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":6,"eleArray":[{"type":"Formula","rootIndex":3,"response":null,"propSetMap":{"controlWidth":4,"label":"PostAddress_FullAddress","showInputWidth":false,"inputWidth":12,"expression":"%StreetDisplay_PostalAddress% + ', ' + %CityDisplay_PostalAddress% + ', ' + %StateDisplay_PostalAddress% + ', ' + %PostcodeDisplay_PostalAddress% + ', ' + %PostAddress_Country_DE%","hide":true,"show":null,"mask":null,"dataType":null,"hideGroupSep":false,"dateFormat":"MM-dd-yyyy","HTMLTemplateId":"","disOnTplt":false},"name":"PostAddress_FullAddress","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:PostAddress_FullAddress","indexInParent":6,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc3006-0"}],"bHasAttachment":false},{"response":null,"level":2,"indexInParent":7,"eleArray":[{"type":"Formula","rootIndex":3,"response":null,"propSetMap":{"disOnTplt":false,"HTMLTemplateId":"","dateFormat":"MM-dd-yyyy","hideGroupSep":false,"dataType":null,"mask":null,"show":null,"hide":true,"expression":"IF (%StateDisplay_PostalAddress% = 'ACT' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 200 & NUMBER(%PostcodeDisplay_PostalAddress%) <=299, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'ACT' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 2600 & NUMBER(%PostcodeDisplay_PostalAddress%) <=2619, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'ACT' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 2900 & NUMBER(%PostcodeDisplay_PostalAddress%) <=2920, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'NSW' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 1000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=2599, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'NSW' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 2620 & NUMBER(%PostcodeDisplay_PostalAddress%) <=2899, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'NSW' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 2921 & NUMBER(%PostcodeDisplay_PostalAddress%) <=2999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'VIC' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 8000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=8999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'VIC' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 3000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=3999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'TAS' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 7000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=7999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'SA' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 5000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=5999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'WA' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 6000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=6999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'NT' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 800 & NUMBER(%PostcodeDisplay_PostalAddress%) <=999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'QLD' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 9000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'QLD' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 4000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=4999, 'GOOD' ,IF (%StateDisplay_PostalAddress% = 'QLD' & NUMBER(%PostcodeDisplay_PostalAddress%) >= 9000 & NUMBER(%PostcodeDisplay_PostalAddress%) <=9999, 'GOOD','BAD')))))))))))))))","inputWidth":12,"showInputWidth":false,"label":"IsPostcodeValid","controlWidth":4},"name":"IsPostcodeValid2","level":2,"JSONPath":"PostalAddress_DataEntry:PostAddress_DE|1:IsPostcodeValid2","indexInParent":7,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc3007-0"}],"bHasAttachment":false}],"bHasAttachment":false,"bBlock":true,"lwcId":"lwc30-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Validation","rootIndex":3,"response":null,"propSetMap":{"controlWidth":12,"label":"Messaging1","validateExpression":{"group":{"rules":[{"data":"GOOD","condition":"=","field":"IsPostcodeValid2"}],"operator":"AND"}},"messages":[{"value":true,"type":"Success","text":"","active":false},{"value":false,"type":"Requirement","text":"The postcode entered is not valid for the state","active":true}],"hideLabel":true,"show":{"group":{"rules":[{"data":"BAD","condition":"=","field":"IsPostcodeValid2"},{"field":"PostcodeDisplay_PostalAddress","condition":"<>","data":null}],"operator":"AND"}},"HTMLTemplateId":""},"name":"Messaging2","level":1,"JSONPath":"PostalAddress_DataEntry:Messaging2","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc31-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"PostalAddress_DataEntry","lwcId":"lwc3"},{"type":"Set Values","propSetMap":{"controlWidth":12,"label":"SetPostalAddressDetails","elementValueMap":{"PostalAddress":{"PostAddress":{"PostAddress_FullAddress":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, %PhysicalAddress:PhysAddress:PhysAddress_FullAddress%,%PostalAddress_DataEntry:PostAddress_DE:PostAddress_FullAddress%)","PostAddress_Country":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, %PhysicalAddress:PhysAddress:CountryDisplay_PhysicalAddress%,%PostalAddress_DataEntry:PostAddress_DE:PostAddress_Country_DE%)","PostAddress_POBox":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, null ,%PostalAddress_DataEntry:PostAddress_DE:PostAddress_POBox_DE%)","PostAddress_CareOf":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, null ,%PostalAddress_DataEntry:PostAddress_DE:PostAddress_CareOf_DE%)","PostAddress_LocationType":"Postal Address","PostAddress_SuburbTown":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, %PhysicalAddress:PhysAddress:CityDisplay_PhysicalAddress%,%PostalAddress_DataEntry:PostAddress_DE:CityDisplay_PostalAddress%)","PostAddress_StateTerritory":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, %PhysicalAddress:PhysAddress:StateDisplay_PhysicalAddress%,%PostalAddress_DataEntry:PostAddress_DE:StateDisplay_PostalAddress%)","PostAddress_Postcode":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, %PhysicalAddress:PhysAddress:PostcodeDisplay_PhysicalAddress%,%PostalAddress_DataEntry:PostAddress_DE:PostcodeDisplay_PostalAddress%)","PostAddress_Address":"=IF(%PhysicalAddress:PhysAddress:AsAboveAddress% = true, %PhysicalAddress:PhysAddress:StreetDisplay_PhysicalAddress%,%PostalAddress_DataEntry:PostAddress_DE:StreetDisplay_PostalAddress%)"}}},"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"AddressRecordType","condition":"=","data":null}],"operator":"AND"}},"HTMLTemplateId":"","wpm":false,"ssm":false,"message":{},"pubsub":false,"aggElements":{}},"offSet":0,"name":"SetPostalAddressDetails","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetPostalAddressDetails","lwcId":"lwc4"},{"type":"Integration Procedure Action","propSetMap":{"invokeMode":"fireAndForget","businessEvent":"","businessCategory":"","enableActionMessage":false,"enableDefaultAbort":false,"errorMessage":{"default":null,"custom":[]},"svgIcon":"","svgSprite":"","pubsub":false,"message":{},"ssm":false,"wpm":false,"HTMLTemplateId":"","show":{"group":{"rules":[{"field":"AddressRecordType","condition":"<>","data":null}],"operator":"AND"}},"showPersistentComponent":[true,false],"redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectNextWidth":3,"redirectNextLabel":"Next","redirectTemplateUrl":"vlcAcknowledge.html","redirectPageName":"","validationRequired":"Step","failureAbortMessage":"Are you sure?","failureGoBackLabel":"Go Back","failureAbortLabel":"Abort","failureNextLabel":"Continue","postMessage":"Done","inProgressMessage":"In Progress","extraPayload":{},"responseJSONNode":"","responseJSONPath":"","sendJSONNode":"","sendJSONPath":"","postTransformBundle":"","preTransformBundle":"","remoteTimeout":30000,"remoteOptions":{"chainable":false,"useFuture":false,"postTransformBundle":"","preTransformBundle":""},"useContinuation":false,"integrationProcedureKey":"LocationAddress_CreateAddress","label":"UpdateAddresses","controlWidth":12,"aggElements":{}},"offSet":0,"name":"UpdateAddresses","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"UpdateAddresses","lwcId":"lwc5"},{"type":"Navigate Action","propSetMap":{"targetName":"Account","businessEvent":"","businessCategory":"","targetLWCLayout":"lightning","replace":true,"iconPosition":"left","iconVariant":"","iconName":"","variant":"brand","targetId":"%CurrentRecordId%","targetFilter":"Recent","loginAction":"login","recordAction":"view","objectAction":"home","targetType":"Record","message":{},"pubsub":false,"ssm":false,"wpm":false,"HTMLTemplateId":"","show":{"group":{"rules":[{"field":"AddressRecordType","condition":"<>","data":null}],"operator":"AND"}},"validationRequired":"Submit","label":"NavigateAction","controlWidth":12,"aggElements":{}},"offSet":0,"name":"NavigateAction","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction","lwcId":"lwc6"}],"bReusable":true,"bpVersion":4,"bpType":"Address_Accounts","bpSubType":"Accounts_Create","bpLang":"English","bHasAttachment":false,"lwcVarMap":{}};