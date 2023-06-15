let definition =
      {"dataSource":{"type":"IntegrationProcedures","value":{"dsDelay":"","ipMethod":"Allotment_Historical","vlocityAsync":false,"inputMap":{"ServiceId":"{recordId}"},"resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"dynamicCanvasWidth":{"type":"desktop"},"enableLwc":true,"events":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1660630429495-df9103vyq","label":"Action","stateAction":{"Web Page":{"targetName":"/apex"},"displayName":"Action","id":"flex-action-1660689571785","message":"{\"type\":\"IntegrationProcedures\",\"value\":{\"dsDelay\":\"\",\"ipMethod\":\"Summary_Summary\",\"vlocityAsync\":false,\"resultVar\":\"\",\"bundleType\":\"Extract\"},\"orderBy\":{\"name\":\"\",\"isReverse\":\"\"},\"contextVariables\":[]}","openUrlIn":"Current Window","responseNode":"","targetType":"Web Page","type":"DataAction","vlocityIcon":"standard-default"}}],"channelname":"PlacesSummary","displayLabel":"PlacesSummary:data","element":"action","eventLabel":"pubsub","eventname":"data","eventtype":"pubsub","key":"event-0","recordIndex":"0","showSpinner":"false"}],"isFlex":true,"lwc":{"DeveloperName":"cfPlacesTrackerHistorical_Parent_2_GPMS","Id":"0RbBm0000003EpdKAE","MasterLabel":"cfPlacesTrackerHistorical_Parent_2_GPMS","NamespacePrefix":"c","ManageableState":"unmanaged"},"osSupport":false,"selectableMode":"Multi","states":[{"actions":[],"blankCardState":false,"childCards":["PlacesTrackerHistorical_Flexible_Child"],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"childCardPreview","elementLabel":"FlexCard-0","name":"FlexCard","property":{"cardName":"PlacesTrackerHistorical_Flexible_Child","cardNode":"{record.Allotment}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Flexible - MPS"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}]}},"conditions":{"group":[{"field":"Service.CareType","hasMergeField":false,"id":"state-new-condition-14","operator":"==","type":"custom","value":"Flexible"},{"id":"state-new-condition-51","field":"Service.CareSubType","operator":"==","value":"Multi-Purpose Service","type":"custom","hasMergeField":false,"logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Flexible - MPS","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-theme_shade slds-card slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_shade"}},{"actions":[],"blankCardState":false,"childCards":["PlacesTrackerHistorical_Flexible_Child_IP"],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"childCardPreview","elementLabel":"FlexCard-0","name":"FlexCard","property":{"cardName":"PlacesTrackerHistorical_Flexible_Child_IP","cardNode":"{record.Allotment}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Flexible - Innovative Pool"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}]}},"conditions":{"group":[{"field":"Service.CareType","hasMergeField":false,"id":"state-new-condition-14","operator":"==","type":"custom","value":"Flexible"},{"id":"state-new-condition-69","field":"Service.CareSubType","operator":"==","value":"Innovative Pool","type":"custom","hasMergeField":false,"logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Flexible - Innovative Pool","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-theme_shade slds-card slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_shade"}},{"actions":[],"blankCardState":false,"childCards":["PlacesTrackerHistorical_Flexible_Child_Transition"],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"childCardPreview","elementLabel":"FlexCard-0","name":"FlexCard","property":{"cardName":"PlacesTrackerHistorical_Flexible_Child_Transition","cardNode":"{record.Allotment}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Flexible - Transition"},"size":{"default":"12","isResponsive":false},"stateIndex":2,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}]}},"conditions":{"group":[{"field":"Service.CareType","hasMergeField":false,"id":"state-new-condition-14","operator":"==","type":"custom","value":"Flexible"},{"id":"state-new-condition-140","field":"Service.CareSubType","operator":"==","value":"Transition Care","type":"custom","hasMergeField":false,"logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Flexible - Transition","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-theme_shade slds-card slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_shade"}},{"actions":[],"blankCardState":false,"childCards":["PlacesTrackerHistorical_Flexible_Child_STRC"],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"childCardPreview","elementLabel":"FlexCard-0","name":"FlexCard","property":{"cardName":"PlacesTrackerHistorical_Flexible_Child_STRC","cardNode":"{record.Allotment}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Flexible - STRC"},"size":{"default":"12","isResponsive":false},"stateIndex":3,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}]}},"conditions":{"group":[{"field":"Service.CareType","hasMergeField":false,"id":"state-new-condition-14","operator":"==","type":"custom","value":"Flexible"},{"id":"state-new-condition-140","field":"Service.CareSubType","operator":"==","value":"Short-Term Restorative Care (STRC)","type":"custom","hasMergeField":false,"logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Flexible - STRC","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-theme_shade slds-card slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_shade"}},{"actions":[],"childCards":["PlacesTrackerHistorical_Residential_Child"],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"childCardPreview","elementLabel":"FlexCard-0","name":"FlexCard","property":{"cardName":"PlacesTrackerHistorical_Residential_Child","cardNode":"{record}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Residential"},"size":{"default":"12","isResponsive":false},"stateIndex":1,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}]}},"conditions":{"group":[{"field":"Service.CareType","hasMergeField":false,"id":"state-new-condition-21","operator":"==","type":"custom","value":"Residential"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Residential","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-theme_shade slds-card slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_shade"}}],"theme":"slds","title":"PlacesTrackerHistorical_Parent","Id":"0koBm0000000FzxIAE","OmniUiCardKey":"PlacesTrackerHistorical_Parent/GPMS/2.0","OmniUiCardType":"Parent"};
  export default definition