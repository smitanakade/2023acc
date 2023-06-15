let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{"isReverse":"","name":""},"type":"Custom","value":{"body":"{\n      \"Name\": \"Combine Residential 2\",\n      \"EffectiveDate\": \"2/8/2022\",\n      \"DecisionDueDate\": \"27/8/2022\",\n      \"File\": \"AXCIDJR-123\",\n      \"NonOperationalService\": [\n        {\n          \"Name\": \"Residential No 1\",\n          \"Id\": \"0cE9r0000000LfZEAU\",\n          \"IntegrationId\": \"000593\",\n          \"Status\": \"Taken to be approved\"\n        },\n        {\n          \"Name\": \"Residential No 2\",\n          \"Id\": \"0cE9r0000000MGfEAM\",\n          \"IntegrationId\": \"000606\",\n          \"Status\": \"Taken to be approved\"\n        }\n      ],\n      \"Id\": \"0cE9r0000000Ma1EAE\",\n      \"IntegrationID\": \"000612\",\n      \"ProposedDate\": \"11/8/2022\",\n      \"Service\": {\n        \"Name\": \"Residential 2\",\n        \"RACSId\": \"URJDCS\",\n        \"Address\": \"SYDNEY AVENUE, CAMP HILL, QLD, 4152\",\n\"IntegrationId\": \"000608\",\n        \"Status\": \"Operational\"\n      },\n      \"ReceivedDate\": \"3/8/2022\",\n      \"Comment\": \"Comment\\nThis is approved\",\n      \"Status\": \"Approved\"\n    }","dsDelay":"","resultVar":""}},"enableLwc":true,"events":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"isTrackingDisabled":true,"key":"1660317462944-zlpmzhygj","label":"Action","stateAction":{"Web Page":{"targetName":"/apex"},"displayName":"Action","eventName":"reload","id":"flex-action-1660317462974","openUrlIn":"Current Window","targetType":"Web Page","type":"cardAction","vlocityIcon":"standard-default"}}],"channelname":"ServiceCombine_SelectApplication","displayLabel":"ServiceCombine_SelectApplication:data","element":"action","eventLabel":"pubsub","eventname":"data","eventtype":"pubsub","key":"event-0","recordIndex":"0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"isTrackingDisabled":true,"key":"1660476252191-to2vf2vak","label":"Update Continue Service","stateAction":{"displayName":"Action","elementId":"SelectedResult","extraParams":{"SelectedService":"{SelectedService}"},"hasExtraParams":true,"id":"flex-action-1660477410744","openUrlIn":"Current Window","type":"updateOmniScript","vlocityIcon":"standard-default"}}],"channelname":"ServiceCombine_SelectApplication","displayLabel":"selectcards_SelectedService","element":"action","eventLabel":"custom event","eventname":"selectcards_SelectedService","eventtype":"event","key":"event-1","recordIndex":"0","showSpinner":"false"}],"isFlex":true,"isRepeatable":true,"listenToWidthResize":false,"lwc":{"DeveloperName":"cfServiceCombine_SelectApplication_1_GPMS","Id":"0Rb9r00000023kzCAA","ManageableState":"unmanaged","MasterLabel":"cfServiceCombine_SelectApplication_1_GPMS","NamespacePrefix":"c"},"osSupport":true,"selectableMode":"Single","selectedCardsLabel":"SelectedService","states":[{"actions":[],"blankCardState":false,"childCards":["ServiceCombine_SelectApplicationTable"],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"action","elementLabel":"SelectThisService","name":"Action","property":{"actionList":[{"actionIndex":0,"draggable":true,"isOpen":true,"key":"1660321523437-vzwko5mwq","label":"SelectServices","stateAction":{"eventName":"selectcards","extraParams":{"SelectedServiceCareType":"{CareType}","SelectedServiceId":"{Id}","SelectedServiceName":"{Name}"},"hasExtraParams":true,"id":"flex-action-1660476105666","openUrlIn":"Current Window","subType":"Custom","type":"cardAction"}}],"buttonVariant":"brand","card":"{card}","displayAsButton":true,"flyoutDetails":{},"hideActionIcon":true,"iconName":"standard-default","iconSize":"x-small","label":"\\Application: {Name}","record":"{record}","showSpinner":"false","stateObj":"{record}","styles":{"label":{"color":"#000000","fontSize":"30px","textAlign":""}}},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_large ","container":{"class":""},"elementStyleProperties":{"iconSize":"x-small","styles":{"label":{"color":"#000000","fontSize":"30px","textAlign":""}}},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:large","size":"large","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_large ","container":{"class":""},"elementStyleProperties":{"iconSize":"x-small","styles":{"label":{"color":"#000000","fontSize":"30px","textAlign":""}}},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:large","size":"large","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"element","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-0","key":"element_element_block_1_0_outputField_0_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22text-decoration:%20underline;%20font-size:%2010pt;%22%3E%3Cstrong%3EApplication%20Summary%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"OperationalTitle-Text-7","key":"element_element_block_1_0_outputField_1_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EReceived%20date%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-1-clone-0","key":"element_element_block_1_0_outputField_2_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BReceivedDate%7D%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-2-clone-0","key":"element_element_block_1_0_outputField_3_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EDecision%20Due%20Date%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-3-clone-0","key":"element_element_block_1_0_outputField_4_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BDecisionDueDate%7D%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-4-clone-0","key":"element_element_block_1_0_outputField_5_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EProposed%20Date%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-5-clone-0","key":"element_element_block_1_0_outputField_6_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BProposedDate%7D%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-6-clone-0","key":"element_element_block_1_0_outputField_7_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EComments%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-7-clone-0","key":"element_element_block_1_0_outputField_8_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BComment%7DComments%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-8-clone-0","key":"element_element_block_1_0_outputField_9_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EStatus%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-9-clone-0","key":"element_element_block_1_0_outputField_10_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BStatus%7D%3C/div%3E","record":"{record}"},"size":{"default":"10","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"10","isResponsive":false},"sizeClass":"slds-size_10-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-10-clone-0","key":"element_element_block_1_0_outputField_11_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EEffective%20Date%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-Text-11-clone-0","key":"element_element_block_1_0_outputField_12_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BEffectiveDate%7D%3C/div%3E","record":"{record}"},"size":{"default":"10","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"10","isResponsive":false},"sizeClass":"slds-size_10-of-12 "},"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Block-2","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_large ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:large","size":"large","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_large ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:large","size":"large","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"block"},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-1","key":"element_element_block_2_0_outputField_0_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22text-decoration:%20underline;%20font-size:%2010pt;%22%3E%3Cstrong%3EContinuing%20Service%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Continuing Service-Text-1-clone-0","key":"element_element_block_2_0_outputField_1_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EService%20name%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"OperationalTitle-Text-6","key":"element_element_block_2_0_outputField_2_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BService.Name%7D%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Continuing Service-Text-4-clone-0","key":"element_element_block_2_0_outputField_3_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EStatus%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"OperationalTitle-Text-8","key":"element_element_block_2_0_outputField_4_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BService.Status%7D%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Continuing Service-Text-5-clone-0","key":"element_element_block_2_0_outputField_5_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EIntegration%20Id%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Continuing Service-Text-7-clone-0","key":"element_element_block_2_0_outputField_6_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BService.IntegrationId%7D%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Continuing Service-Text-3-clone-0","key":"element_element_block_2_0_outputField_7_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3ERACS%20Id%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Continuing Service-Text-4-clone-0","key":"element_element_block_2_0_outputField_8_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BService.RACSId%7D%3C/div%3E","record":"{record}"},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"OperationalTitle-Text-3","key":"element_element_block_2_0_outputField_9_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3EAddress%3C/div%3E","record":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"OperationalTitle-Text-4","key":"element_element_block_2_0_outputField_10_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%7BService.Address%7D%3C/div%3E","record":"{record}"},"size":{"default":"10","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"10","isResponsive":false},"sizeClass":"slds-size_10-of-12 "},"type":"text"}],"class":"slds-col ","element":"block","elementLabel":"Continuing Service","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_large ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:large","size":"large","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_large ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:large","size":"large","type":"bottom"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"block","userUpdatedElementLabel":true},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Non Continuing Service-Text-0","key":"element_element_block_3_0_outputField_0_0","name":"Text","parentElementKey":"element_block_3_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22text-decoration:%20underline;%20font-size:%2010pt;%22%3E%3Cstrong%3ENon%20continuing%20Service(s)%3C/strong%3E%3C/span%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Non Continuing Service-FlexCard-2","key":"element_element_block_3_0_childCardPreview_1_0","name":"FlexCard","parentElementKey":"element_block_3_0","property":{"cardName":"ServiceCombine_SelectApplicationTable","cardNode":"{record.NonOperationalService}","data-conditions":{"group":[],"id":"state-condition-object","isParent":true},"isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Non Continuing Service","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"block","userUpdatedElementLabel":true}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Services","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":"border_top","width":"2"},"class":"slds-card slds-border_top slds-p-around_x-small slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #cccccc 2px solid; \n         ","text":{"align":"","color":""}}}],"theme":"slds","title":"ServiceCombine_SelectApplication","Id":"0ko9r00000008FJAAY","OmniUiCardKey":"ServiceCombine_SelectApplication/GPMS/1.0"};
  export default definition