let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{"isReverse":"","name":""},"type":"IntegrationProcedures","value":{"dsDelay":"","inputMap":{"accountId":"{recordId}"},"ipMethod":"ServiceCreation_Extract","resultVar":"","vlocityAsync":false}},"enableLwc":true,"isFlex":true,"lwc":{"DeveloperName":"cfServiceCreation_Header_8_ApprovedProvider","Id":"0RbBm00000023ufKAA","MasterLabel":"cfServiceCreation_Header_8_ApprovedProvider","NamespacePrefix":"c","ManageableState":"unmanaged"},"selectableMode":"Multi","states":[{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"action","elementLabel":"Action-2","name":"Action","property":{"actionList":[{"actionIndex":0,"draggable":true,"isOpen":true,"key":"1659938304839-wqg7b5wsk","label":"Action","stateAction":{"channelName":"close_modal","flyoutLwc":"service-create-english","flyoutParams":{"APCareTypeCount":"{APCareTypeCount}","CertificationRTId":"{CertificationRTId}","FireSafetyRTId":"{FireSafetyRTId}","FlexibleCareCount":"{FlexibleCareCount}","HomeCareCount":"{HomeCareCount}","NATSIFACCareCount":"{NATSIFACCareCount}","PrivacySpaceRTId":"{PrivacySpaceRTId}","ProviderName":"{ProviderName}","RecordType":"{RecordType}","ResidentialCareCount":"{ResidentialCareCount}","accountId":"{recordId}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1668393742672","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"Service/Create/English","type":"Flyout"}}],"buttonVariant":"brand","card":"{card}","displayAsButton":true,"flyoutChannel":"close_modal","flyoutDetails":{"openFlyoutIn":"Modal"},"hideActionIcon":true,"iconName":"standard-default","label":"New","record":"{record}","showSpinner":"false","stateObj":"{record}","styles":{"label":{"textAlign":"left"}}},"size":{"default":"1","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"label":{"textAlign":"left"}}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"label":{"textAlign":"left"}}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","text":{"align":"","color":""}}}],"type":"element"}]}},"conditions":{"group":[{"group":[{"field":"PermissionName","hasMergeField":false,"id":"state-new-condition-368","operator":"==","type":"custom","value":"GPMS_System_Administrators"},{"id":"state-new-condition-1","field":"PermissionName","operator":"==","value":" System_Admin_Users","type":"custom","hasMergeField":false,"logicalOperator":"||"}],"id":"state-new-group-369"},{"group":[{"field":"HomeCareCount","hasMergeField":false,"id":"state-new-condition-385","operator":">=","type":"custom","value":"1"},{"field":"ResidentialCareCount","hasMergeField":false,"id":"state-new-condition-417","logicalOperator":"||","operator":">=","type":"custom","value":"1"},{"field":"FlexibleCareCount","hasMergeField":false,"id":"state-new-condition-465","logicalOperator":"||","operator":">=","type":"custom","value":"1"},{"field":"NATSIFACCareCount","hasMergeField":false,"id":"state-new-condition-313","logicalOperator":"||","operator":">=","type":"custom","value":"1"}],"id":"state-new-group-386","logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Service With New Button","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":[],"width":""},"class":"slds-theme_default  ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_default"}},{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"action","elementLabel":"Action-2","name":"Action","property":{"actionList":[{"actionIndex":0,"draggable":true,"isOpen":true,"key":"1659938304839-wqg7b5wsk","label":"Action","stateAction":{"channelName":"close_modal","flyoutLwc":"service-create-english","flyoutParams":{"APCareTypeCount":"{APCareTypeCount}","CertificationRTId":"{CertificationRTId}","FireSafetyRTId":"{FireSafetyRTId}","FlexibleCareCount":"{FlexibleCareCount}","HomeCareCount":"{HomeCareCount}","NATSIFACCareCount":"{NATSIFACCareCount}","PrivacySpaceRTId":"{PrivacySpaceRTId}","ProviderName":"{ProviderName}","RecordType":"{RecordType}","ResidentialCareCount":"{ResidentialCareCount}","accountId":"{recordId}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1668393742672","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"Service/Create/English","type":"Flyout"}}],"buttonVariant":"brand","card":"{card}","displayAsButton":true,"flyoutChannel":"close_modal","flyoutDetails":{"openFlyoutIn":"Modal"},"hideActionIcon":true,"iconName":"standard-default","label":"New","record":"{record}","showSpinner":"false","stateObj":"{record}","styles":{"label":{"textAlign":"left"}}},"size":{"default":"1","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"label":{"textAlign":"left"}}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"label":{"textAlign":"left"}}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","text":{"align":"","color":""}}}],"type":"element"}]}},"conditions":{"group":[{"group":[{"field":"PermissionName","hasMergeField":false,"id":"state-new-condition-368","operator":"==","type":"custom","value":"STOs"}],"id":"state-new-group-369"},{"group":[{"field":"HomeCareCount","hasMergeField":false,"id":"state-new-condition-385","operator":">=","type":"custom","value":"1"},{"field":"ResidentialCareCount","hasMergeField":false,"id":"state-new-condition-417","logicalOperator":"||","operator":">=","type":"custom","value":"1"},{"field":"FlexibleCareCount","hasMergeField":false,"id":"state-new-condition-465","logicalOperator":"||","operator":">=","type":"custom","value":"1"}],"id":"state-new-group-386","logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Service With New Button","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":[],"width":""},"class":"slds-theme_default  ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_default"}},{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"action","elementLabel":"Action-2","name":"Action","property":{"actionList":[{"actionIndex":0,"draggable":true,"isOpen":true,"key":"1659938304839-wqg7b5wsk","label":"Action","stateAction":{"channelName":"close_modal","flyoutLwc":"service-create-english","flyoutParams":{"APCareTypeCount":"{APCareTypeCount}","CertificationRTId":"{CertificationRTId}","FireSafetyRTId":"{FireSafetyRTId}","FlexibleCareCount":"{FlexibleCareCount}","HomeCareCount":"{HomeCareCount}","NATSIFACCareCount":"{NATSIFACCareCount}","PrivacySpaceRTId":"{PrivacySpaceRTId}","ProviderName":"{ProviderName}","RecordType":"{RecordType}","ResidentialCareCount":"{ResidentialCareCount}","accountId":"{recordId}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1668393742672","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"Service/Create/English","type":"Flyout"}}],"buttonVariant":"brand","card":"{card}","displayAsButton":true,"flyoutChannel":"close_modal","flyoutDetails":{"openFlyoutIn":"Modal"},"hideActionIcon":true,"iconName":"standard-default","label":"New","record":"{record}","showSpinner":"false","stateObj":"{record}","styles":{"label":{"textAlign":"left"}}},"size":{"default":"1","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"label":{"textAlign":"left"}}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"container":{"class":""},"elementStyleProperties":{"styles":{"label":{"textAlign":"left"}}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","text":{"align":"","color":""}}}],"type":"element"}]}},"conditions":{"group":[{"group":[{"field":"PermissionName","hasMergeField":false,"id":"state-new-condition-368","operator":"==","type":"custom","value":"NATSIFAC"}],"id":"state-new-group-369"},{"group":[{"field":"NATSIFACCareCount","hasMergeField":false,"id":"state-new-condition-385","operator":">=","type":"custom","value":"1"}],"id":"state-new-group-386","logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Service With New Button","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":[],"width":""},"class":"slds-theme_default  ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_default"}},{"actions":[],"blankCardState":true,"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"flexIcon","elementLabel":"Block-0-Icon-0","name":"Icon","property":{"card":"{card}","extraclass":"slds-icon_container slds-icon-standard-service-contract ","iconName":"standard:app","iconType":"Salesforce SVG","imgsrc":"","record":"{record}","size":"small","variant":"inverse"},"size":{"default":"1","isResponsive":false},"stateIndex":2,"styleObject":{"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 "},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-Text-1","name":"Text","property":{"card":"{card}","mergeField":"%3Cdiv%20class=%22slds-text-heading_small%22%3E%3Cstrong%3EServices%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"7","isResponsive":false},"stateIndex":2,"styleObject":{"size":{"default":"7","isResponsive":false},"sizeClass":"slds-size_7-of-12 "},"type":"text"}]}},"conditions":{"group":[{"field":"PermissionName","hasMergeField":false,"id":"state-new-condition-9","operator":"==","type":"custom","value":"ACQSC User​s"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Service","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":["border_top","border_right","border_bottom","border_left"],"width":""},"class":"slds-theme_shade slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ","text":{"align":"","color":""},"theme":"theme_shade"}},{"actions":[],"blankCardState":true,"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"flexIcon","elementLabel":"Block-0-Icon-0","name":"Icon","property":{"card":"{card}","extraclass":"slds-icon_container slds-icon-standard-service-contract ","iconName":"standard:app","iconType":"Salesforce SVG","imgsrc":"","record":"{record}","size":"small","variant":"inverse"},"size":{"default":"1","isResponsive":false},"stateIndex":2,"styleObject":{"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 "},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-Text-1","name":"Text","property":{"card":"{card}","mergeField":"%3Cdiv%20class=%22slds-text-heading_small%22%3E%3Cstrong%3EServices%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"7","isResponsive":false},"stateIndex":2,"styleObject":{"size":{"default":"7","isResponsive":false},"sizeClass":"slds-size_7-of-12 "},"type":"text"}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Service","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":["border_top","border_right","border_bottom","border_left"],"width":""},"class":"slds-theme_shade slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ","text":{"align":"","color":""},"theme":"theme_shade"}}],"theme":"slds","title":"ServiceCreation_Header","Id":"0koBm00000005XZIAY","OmniUiCardKey":"ServiceCreation_Header/ApprovedProvider/8.0","OmniUiCardType":"Parent"};
  export default definition