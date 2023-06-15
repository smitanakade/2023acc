let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{"isReverse":"","name":""},"type":"ApexRemote","value":{"dsDelay":"","inputMap":{"ApplicationId":"{recordId}","Type":"applicationAATReview"},"remoteClass":"GPMSApplicationDecisionLog","remoteMethod":"DecisionLog","resultVar":"result","vlocityAsync":false}},"enableLwc":true,"isFlex":true,"isRepeatable":false,"listenToWidthResize":true,"lwc":{"DeveloperName":"cfApplicationAATReviewDecisionLog_1_GPMS","Id":"0RbBm0000002fDZKAY","MasterLabel":"cfApplicationAATReviewDecisionLog_1_GPMS","NamespacePrefix":"c","ManageableState":"unmanaged"},"osSupport":true,"selectableMode":"Multi","states":[{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-0","name":"Text","property":{"card":"{card}","mergeField":"%3Cdiv%20class=%22slds-text-title%20slds-text-heading_small%22%3E%3Cem%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2014pt;%22%3EAAT%20Review%20Log%3C/span%3E%3C/strong%3E%3C/em%3E%3C/div%3E%0A%3Cdiv%20class=%22slds-text-title%20slds-text-heading_small%22%3E&nbsp;%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"flexDatatable","elementLabel":"Datatable-1","name":"Datatable","property":{"card":"{card}","cellLevelEdit":false,"columns":[{"editable":"false","fieldName":"Date","format":"D/M/YYYY","label":"Date","searchable":false,"sortable":"false","type":"text","userSelectable":"false","visible":"true"},{"editable":"false","fieldName":"Status","label":"Status","searchable":false,"sortable":"false","type":"text","userSelectable":"false","visible":"true"},{"editable":"false","fieldName":"Owner","label":"Owner","searchable":false,"sortable":"false","type":"text","userSelectable":"false","visible":"true"},{"editable":"false","fieldName":"Recommendation","label":"Recommendation","searchable":true,"sortable":true,"type":"text","userSelectable":"false","visible":"true"},{"editable":"false","fieldName":"Comment","label":"Comment","searchable":true,"sortable":true,"type":"textarea","userSelectable":"false","visible":"true"}],"groupNameWrapperClass":"","groupOrder":"asc","hideTableHeader":false,"issearchavailable":false,"issortavailable":false,"pagelimit":3,"record":"{record}","records":"{records}","rowDeleteDependentColumn":"","styles":{"cellMargin":[],"cellPadding":[],"headBgColor":"","tableBorderType":[],"tableBorderWidth":""}},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"cellMargin":[],"cellPadding":[],"headBgColor":"","tableBorderType":[],"tableBorderWidth":""}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"cellMargin":[],"cellPadding":[],"headBgColor":"","tableBorderType":[],"tableBorderWidth":""}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12","text":{"align":"","color":""}}}],"type":"element"}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Active","omniscripts":[],"smartAction":{},"styleObject":{"class":"slds-card slds-p-around_x-small slds-m-bottom_x-small","container":{"class":"slds-card"},"margin":[{"size":"x-small","type":"bottom"}],"padding":[{"size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12"}},{"actions":[],"blankCardState":true,"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-0","name":"Text","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3EThis%20application%20has%20no%20AAT%20Review%20Outcome%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"BlankState","omniscripts":[],"smartAction":{},"styleObject":{"class":"slds-card slds-p-around_x-small slds-m-bottom_x-small","container":{"class":"slds-card"},"margin":[{"size":"x-small","type":"bottom"}],"padding":[{"size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12"}}],"theme":"slds","title":"ApplicationAATReviewDecisionLog","Id":"0koBm000000023SIAQ","OmniUiCardKey":"ApplicationAATReviewDecisionLog/GPMS/1.0","OmniUiCardType":"Parent"};
  export default definition