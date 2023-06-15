let definition =
      {"dataSource":{"type":"DataRaptor","value":{"dsDelay":"","bundle":"AllotmentDetails_Extract","bundleType":"","inputMap":{"AllotmentId":"{recordId}"},"resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"enableLwc":true,"events":[{"actionList":[{"key":"1684128008040-6fdbc8xd2","label":"Action","draggable":false,"isOpen":true,"card":"{card}","stateAction":{"id":"test-action","type":"Custom","displayName":"Action","vlocityIcon":"standard-default","targetType":"Web Page","openUrlIn":"Current Window","Web Page":{"targetName":"/apex"}}}],"channelname":"PlacesAllotmentTracker","displayLabel":"selectcards_PlacesAllotmentTracker","element":"action","eventLabel":"custom event","eventname":"selectcards_PlacesAllotmentTracker","eventtype":"event","key":"event-0","recordIndex":"0","showSpinner":"false"},{"actionList":[{"card":"{card}","draggable":false,"isOpen":true,"key":"1664769811602-74rdgtto5","label":"Action","stateAction":{"Web Page":{"targetName":"/apex"},"displayName":"Action","id":"test-action","openUrlIn":"Current Window","targetType":"Web Page","type":"Custom","vlocityIcon":"standard-default"}}],"channelname":"PlacesAllotmentTracker","displayLabel":"PlacesAllotmentTracker:test","element":"action","eventLabel":"pubsub","eventname":"test","eventtype":"pubsub","key":"event-1","recordIndex":"0","showSpinner":"false"}],"isFlex":true,"isRepeatable":true,"listenToWidthResize":true,"lwc":{"DeveloperName":"cfPlacesAllotmentTracker_8_GPMS","Id":"0RbBm00000056nxKAA","MasterLabel":"cfPlacesAllotmentTracker_8_GPMS","NamespacePrefix":"c","ManageableState":"unmanaged"},"osSupport":true,"selectableMode":"Multi","states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-11","field":"CombineLock","operator":"==","value":"true","type":"custom","hasMergeField":false}]},"name":"CombineLock","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small"}],"margin":[{"type":"around","size":"none"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12","class":"slds-card slds-p-around_x-small slds-m-bottom_x-small"},"blankCardState":false,"components":{"layer-0":{"children":[{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%20class=%22slds-text-align_center%22%3E%3Cspan%20style=%22color:%20#ff0000;%22%3E%3Cstrong%3E%3Cspan%20class=%22ui-provider%20gz%20b%20c%20d%20e%20f%20g%20h%20i%20j%20k%20l%20m%20n%20o%20p%20q%20r%20s%20t%20u%20v%20w%20x%20y%20z%20ab%20ac%20ae%20af%20ag%20ah%20ai%20aj%20ak%22%20dir=%22ltr%22%3E%3Cspan%20class=%22ui-provider%20gp%20b%20c%20d%20e%20f%20g%20h%20i%20j%20k%20l%20m%20n%20o%20p%20q%20r%20s%20t%20u%20v%20w%20x%20y%20z%20ab%20ac%20ae%20af%20ag%20ah%20ai%20aj%20ak%22%20dir=%22ltr%22%3EPlaces%20events%20cannot%20be%20created%20as%20this%20service%20is%20in%20the%20process%20of%20being%20combined%20or%20is%20a%20discontinuing%20service.%3C/span%3E%3C/span%3E%3C/strong%3E%3C/span%3E%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-0"}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]},{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"action","elementLabel":"Action-3","name":"Action","property":{"actionList":[{"actionIndex":0,"draggable":false,"isOpen":true,"key":"1671421750495-iw3bij3jw","label":"Cease Places","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","flyoutLwc":"n-a-t-s-i-f-a-c-places-cease-english","flyoutParams":{"AllotmentId":"{AllotmentId}","DateOfAllotment":"{DateOfAllotment}","GPMSInactive":"{GPMSInactive}","GPMSOperational":"{GPMSOperational}","Location":"{Location}","ProviderName":"{ProviderName}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671581739358","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"NATSIFACPlaces/Cease/English","type":"Flyout"}}],"buttonVariant":"brand","card":"{card}","displayAsButton":true,"flyoutChannel":"close_modal","flyoutDetails":{"openFlyoutIn":"Modal"},"hideActionIcon":true,"iconName":"standard-default","label":"Cease Places","reRenderFlyout":true,"record":"{record}","showSpinner":"false","stateObj":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":1,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"element"},{"class":"slds-col ","element":"action","elementLabel":"Action-3-clone-0","name":"Action","property":{"actionList":[{"actionIndex":0,"draggable":false,"isOpen":true,"key":"1671421750495-iw3bij3jw","label":"Reinstate Places","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","flyoutLwc":"n-a-t-s-i-f-a-c-places-reinstate-english","flyoutParams":{"AllotmentId":"{AllotmentId}","DateOfAllotment":"{DateOfAllotment}","GPMSCeased":"{GPMSCeased}","Location":"{Location}","ProviderName":"{ProviderName}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671581727246","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"NATSIFACPlaces/Reinstate/English","type":"Flyout"}}],"buttonVariant":"brand","card":"{card}","displayAsButton":true,"flyoutChannel":"close_modal","flyoutDetails":{"openFlyoutIn":"Modal"},"hideActionIcon":true,"iconName":"standard-default","label":"Reinstate Places","reRenderFlyout":true,"record":"{record}","showSpinner":"false","stateObj":"{record}"},"size":{"default":"2","isResponsive":false},"stateIndex":1,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"element"}]}},"conditions":{"group":[{"id":"state-new-condition-0","field":"ServiceCareSubType","operator":"==","value":"National Aboriginal and Torres Strait Islander Flexible Aged Care Program","type":"custom","hasMergeField":false},{"id":"state-new-condition-2","field":"AllotmentSubType","operator":"==","value":"National Aboriginal and Torres Strait Islander Flexible Aged Care Program","type":"custom","hasMergeField":false,"logicalOperator":"&&"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"NATSIFAC_ONLY","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":["border_top","border_right","border_bottom","border_left"],"width":""},"class":"slds-theme_shade slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ","text":{"align":"","color":""},"theme":"theme_shade"}},{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"class":"slds-col ","element":"flexMenu","elementLabel":"Menu-0","name":"Menu","property":{"card":"{card}","iconName":"utility:down","iconPosition":"right","iconSize":"x-small","label":"General","menuItems":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1669689166781-2m3fpx1ca","label":"Record S14-5(4) Conditions ","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"record-conditions-places-english","flyoutParams":{"AllotmentId":"{AllotmentId}","CareType":"{CareType}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1669689249377","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"RecordConditions/Places/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Record S14-5(4) Conditions ","name":"menu-item-1669689166776-0","showSpinner":"false"}],"overflow":true,"position":"left","record":"{record}","size":"small","type":"action","variant":"brand"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"element"},{"class":"slds-col ","element":"flexMenu","elementLabel":"Menu-1","name":"Menu","property":{"card":"{card}","iconName":"utility:down","iconPosition":"right","iconSize":"x-small","label":"Provisional Places","menuItems":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671418437909-5vk2d6cel","label":"Bring Online","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"places-event-bring-online-places-event-bring-online-english","flyoutParams":{"AllotmentId":"{AllotmentId}","Location":"{Location}","ServiceCareType":"{ServiceCareType}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1673991140464","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"PlacesEventBringOnline/PlacesEventBringOnline/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Bring Online","name":"menu-item-1671418437907-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671418691191-0r1jvchh5","label":"Extend PA Period","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"places-extend-p-a-places-extend-p-a-english","flyoutParams":{"AllotmentId":"{AllotmentId}","AllotmentSubType":"{AllotmentSubType}","DateOfAllotment":"{DateOfAllotment}","Location":"{Location}","MarkDocumentsAsSent":"{MarkDocumentsAsSent}","NumberofPlaces":"{NumberofPlaces}","OriginalPAPeriodEndDate":"{OriginalPAPeriodEndDate}","PAPeriodEndDate":"{PAPeriodEndDate}","Provisional":"{Provisional}","ProvisionalPlacesNumber":"{ProvisionalPlacesNumber}","ServiceCareSubType":"{ServiceCareSubType}","ServiceCareType":"{ServiceCareType}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}","SizeOfCurrentProvisional":"{SizeOfCurrentProvisional}","WaiverType":"{WaiverType}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1681693528804","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"PlacesExtendPA/PlacesExtendPA/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Extend PA Period","name":"menu-item-1671418691188-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671418719088-ajic7cocb","label":"Surrender","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"surrender-p-a-places-english","flyoutParams":{"AllotmentId":"{AllotmentId}","DateOfAllotment":"{DateOfAllotment}","Location":"{Location}","ObjectIdForEventValidation":"{ObjectIdForEventValidation}","ObjectTypeForEventValidation":"{ObjectTypeForEventValidation}","PAPeriodEndDate":"{PAPeriodEndDate}","Provisional":"{Provisional}","ProvisionalPlacesNumber":"{ProvisionalPlacesNumber}","ServiceCareType":"{ServiceCareType}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}","SizeOfCurrentProvisional":"{SizeOfCurrentProvisional}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671420437901","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"SurrenderPA/Places/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Surrender","name":"menu-item-1671418719084-0","showSpinner":"false"}],"overflow":true,"position":"left","record":"{record}","size":"small","type":"action","variant":"brand"},"size":{"default":"2","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"element"},{"class":"slds-col ","element":"flexMenu","elementLabel":"Menu-3","name":"Menu","property":{"card":"{card}","iconName":"utility:down","iconPosition":"right","iconSize":"x-small","label":"Places Taken Effect","menuItems":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671419003310-q2vyb1jw3","label":"Cease S14-9 Places","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"ceased-places-emergency-english","flyoutParams":{"AllotmentId":"{AllotmentId}","AllotmentType":"{AllotmentType}","Location":"{Location}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671604388087","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"CeasedPlaces/Emergency/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","iconPosition":"left","label":"Cease S14-9 Places","name":"menu-item-1671419003308-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671419026734-p4za774pv","label":"Change Care Setting","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"places-change-care-setting-english","flyoutParams":{"AllotmentId":"{AllotmentId}","Location":"{Location}","NumberofPlaces":"{NumberofPlaces}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671420798544","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"Places/ChangeCareSetting/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Change Care Setting","name":"menu-item-1671419026731-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671419141712-eu9io8pe4","label":"Convert Care Level Mix","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"care-level-convert-english","flyoutParams":{"AllotmentId":"{AllotmentId}","Location":"{Location}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671420878075","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"CareLevel/Convert/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Convert Care Level Mix","name":"menu-item-1671419141710-0","showSpinner":"false"}],"overflow":true,"position":"left","record":"{record}","size":"small","type":"action","variant":"brand"},"size":{"default":"3","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 "},"type":"element"}]}},"conditions":{"group":[{"field":"ServiceCareType","hasMergeField":false,"id":"state-new-condition-11","operator":"!=","type":"custom","value":"National Aboriginal and Torres Strait Islander Flexible Aged Care Program"},{"field":"AllotmentSubType","hasMergeField":false,"id":"state-new-condition-30","logicalOperator":"&&","operator":"==","type":"custom","value":"S14-9"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"NOT_NATSIFAC","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":["border_top","border_right","border_bottom","border_left"],"width":""},"class":"slds-theme_shade slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ","text":{"align":"","color":""},"theme":"theme_shade"}},{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":12},"stateIndex":3,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%20class=%22slds-text-align_center%22%3E%3Cstrong%3E%3Cspan%20class=%22ui-provider%20gp%20b%20c%20d%20e%20f%20g%20h%20i%20j%20k%20l%20m%20n%20o%20p%20q%20r%20s%20t%20u%20v%20w%20x%20y%20z%20ab%20ac%20ae%20af%20ag%20ah%20ai%20aj%20ak%22%20dir=%22ltr%22%20style=%22color:%20#e03e2d;%22%3EThe%20'Variation'%20event%20button%20is%20not%20visible%20as%20an%20incomplete%20Variation%20event%20has%20been%20started.%20Please%20go%20to%20the%20Variation%20event%20in%20the%20Events%20table%20to%20cancel%20this%20event%20before%20performing%20a%20new%20Variation%20event%20or%20other%20events.%3C/span%3E%3C/strong%3E%3C/div%3E","card":"{card}","data-conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-54","field":"VariationEventType","operator":"==","value":"Variation","type":"custom","hasMergeField":false},{"id":"state-new-condition-63","field":"VariationEventStatus","operator":"==","value":"Inactive","type":"custom","hasMergeField":false,"logicalOperator":"&&"}]}},"type":"text","styleObject":{"size":{"isResponsive":false,"default":12},"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-0"},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":3,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%20class=%22slds-text-align_center%22%3E%3Cstrong%3E%3Cspan%20class=%22ui-provider%20gp%20b%20c%20d%20e%20f%20g%20h%20i%20j%20k%20l%20m%20n%20o%20p%20q%20r%20s%20t%20u%20v%20w%20x%20y%20z%20ab%20ac%20ae%20af%20ag%20ah%20ai%20aj%20ak%22%20dir=%22ltr%22%20style=%22color:%20#e03e2d;%22%3EThe%20'Vary%20by%20Provider%20or%20Secretary'%20event%20button%20is%20not%20visible%20as%20an%20incomplete%20PA%20Variation%20event%20has%20been%20started.%20Please%20go%20to%20the%20PA%20Variation%20event%20in%20the%20Events%20table%20to%20cancel%20this%20event%20before%20performing%20a%20new%20PA%20Variation%20event%20or%20other%20events.%3C/span%3E%3C/strong%3E%3C/div%3E","card":"{card}","data-conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-125","field":"PAVariationEventRecordType","operator":"==","value":"Variations_by_Provider_Secretary","type":"custom","hasMergeField":false},{"id":"state-new-condition-136","field":"PAVariationStatus","operator":"==","value":"Inactive","type":"custom","hasMergeField":false,"logicalOperator":"&&"}]}},"type":"text","styleObject":{"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12 "},"elementLabel":"Text-6"},{"name":"Block","element":"block","size":{"isResponsive":false,"default":"12"},"stateIndex":3,"class":"slds-col ","property":{"label":"Block","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}"},"type":"block","styleObject":{"padding":[{"type":"around","size":"x-small","label":"around:x-small"}],"class":"slds-theme_shade slds-border_bottom slds-border_right slds-border_top slds-border_left slds-p-around_x-small ","sizeClass":"slds-size_12-of-12 ","margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"size":{"isResponsive":false,"default":"12"},"container":{"class":""},"border":{"type":["border_bottom","border_right","border_top","border_left"],"width":"1","color":"#cccccc","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","style":"     border-bottom: #cccccc 1px solid;border-right: #cccccc 1px solid;border-top: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ","theme":"theme_shade"},"children":[{"class":"slds-col ","element":"flexMenu","elementLabel":"Menu-2","name":"Menu","property":{"card":"{card}","iconName":"utility:down","iconPosition":"right","iconSize":"x-small","label":"General","menuItems":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1669689166781-2m3fpx1ca","label":"Record S14-5(4) Conditions ","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"record-conditions-places-english","flyoutParams":{"AllotmentId":"{AllotmentId}","CareType":"{CareType}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1669689249377","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"RecordConditions/Places/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Record S14-5(4) Conditions ","name":"menu-item-1669689166776-0","showSpinner":"false"}],"overflow":true,"position":"left","record":"{record}","size":"small","type":"action","variant":"brand"},"size":{"default":"2","isResponsive":false},"stateIndex":3,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"element","key":"element_element_block_2_3_flexMenu_0_3","parentElementKey":"element_block_2_3"},{"class":"slds-col ","element":"flexMenu","elementLabel":"Menu-3","name":"Menu","property":{"card":"{card}","iconName":"utility:down","iconPosition":"right","iconSize":"x-small","label":"Provisional Places","menuItems":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671418437909-5vk2d6cel","label":"Bring Online","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"places-event-bring-online-places-event-bring-online-english","flyoutParams":{"AllotmentId":"{AllotmentId}","Location":"{Location}","ServiceCareType":"{ServiceCareType}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1673991140464","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"PlacesEventBringOnline/PlacesEventBringOnline/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Bring Online","name":"menu-item-1671418437907-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671418691191-0r1jvchh5","label":"Extend PA Period","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"places-extend-p-a-places-extend-p-a-english","flyoutParams":{"AllotmentId":"{AllotmentId}","AllotmentSubType":"{AllotmentSubType}","DateOfAllotment":"{DateOfAllotment}","Location":"{Location}","MarkDocumentsAsSentDefault":"{MarkDocumentsAsSentDefault}","NumberofPlaces":"{NumberofPlaces}","OriginalPAPeriodEndDate":"{OriginalPAPeriodEndDate}","PAPeriodEndDate":"{PAPeriodEndDate}","Provisional":"{Provisional}","ProvisionalPlacesNumber":"{ProvisionalPlacesNumber}","ServiceCareSubType":"{ServiceCareSubType}","ServiceCareType":"{ServiceCareType}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}","SizeOfCurrentProvisional":"{SizeOfCurrentProvisional}","WaiverType":"{WaiverType}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1682489695885","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"PlacesExtendPA/PlacesExtendPA/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Extend PA Period","name":"menu-item-1671418691188-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671418719088-ajic7cocb","label":"Surrender","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"surrender-p-a-places-english","flyoutParams":{"AllotmentId":"{AllotmentId}","DateOfAllotment":"{DateOfAllotment}","Location":"{Location}","ObjectIdForEventValidation":"{ObjectIdForEventValidation}","ObjectTypeForEventValidation":"{ObjectTypeForEventValidation}","PAPeriodEndDate":"{PAPeriodEndDate}","Provisional":"{Provisional}","ProvisionalPlacesNumber":"{ProvisionalPlacesNumber}","ServiceCareType":"{ServiceCareType}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}","SizeOfCurrentProvisional":"{SizeOfCurrentProvisional}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671420437901","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"SurrenderPA/Places/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Surrender","name":"menu-item-1671418719084-0","showSpinner":"false"},{"actionList":[{"key":"1684139371542-vgxydjfts","label":"Action","draggable":true,"isOpen":false,"card":"{card}","stateAction":{"id":"test-action","type":"Custom","displayName":"Action","vlocityIcon":"standard-default","targetType":"Web Page","openUrlIn":"Current Window","Web Page":{"targetName":"/apex"}}},{"actionIndex":0,"card":"{card}","contextId":"\\{AllotmentId}","draggable":true,"isOpen":false,"key":"1671496503469-nt608q3yy","label":"Vary by Provider or Secretary","stateAction":{"actionConditions":{"group":[],"id":"state-condition-object","isParent":true},"displayName":"Action","hasExtraParams":false,"id":"flex-action-1684138731831","isLwcOS":true,"layoutType":"lightning","omniType":{"Id":"0jN9r0000001Qy9EAE","Name":"PAVariation/RecordNoticeToVary/English","isLwcOs":true},"openUrlIn":"Current Window","tabLabel":"Vary by Provider or Secretary:  {AllotmentName}","type":"OmniScript","vlocityIcon":"standard-default"},"isTrackingDisabled":true}],"iconName":"standard:default","label":"Vary by Provider or Secretary","name":"menu-item-1671496503467-0","showSpinner":"false","actionConditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-508","field":"PAVariationStatus","operator":"!=","value":"Inactive","type":"custom","hasMergeField":false},{"id":"state-new-condition-513","field":"PAVariationEventRecordType","operator":"!=","value":"Variations_by_Provider_Secretary","type":"custom","hasMergeField":false,"logicalOperator":"&&"}]}}],"overflow":true,"position":"left","record":"{record}","size":"small","type":"action","variant":"brand","data-conditions":{"id":"state-condition-object","isParent":true,"group":[]}},"size":{"default":"2","isResponsive":false},"stateIndex":3,"styleObject":{"size":{"default":"2","isResponsive":false},"sizeClass":"slds-size_2-of-12 "},"type":"element","key":"element_element_block_2_3_flexMenu_1_3","parentElementKey":"element_block_2_3"},{"class":"slds-col ","element":"flexMenu","elementLabel":"Menu-4","name":"Menu","property":{"card":"{card}","iconName":"utility:down","iconPosition":"right","iconSize":"x-small","label":"Places Taken Effect","menuItems":[{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671419003310-q2vyb1jw3","label":"Cease S14-9 Places","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"ceased-places-emergency-english","flyoutParams":{"AllotmentId":"{AllotmentId}","AllotmentType":"{AllotmentType}","Location":"{Location}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671604388087","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"CeasedPlaces/Emergency/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","iconPosition":"left","label":"Cease S14-9 Places","name":"menu-item-1671419003308-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671419026734-p4za774pv","label":"Change Care Setting","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"places-change-care-setting-english","flyoutParams":{"AllotmentId":"{AllotmentId}","Location":"{Location}","NumberofPlaces":"{NumberofPlaces}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671420798544","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"Places/ChangeCareSetting/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Change Care Setting","name":"menu-item-1671419026731-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","draggable":false,"isOpen":true,"key":"1671419141712-eu9io8pe4","label":"Convert Care Level Mix","reRenderFlyout":true,"stateAction":{"channelName":"close_modal","displayName":"Action","flyoutLwc":"care-level-convert-english","flyoutParams":{"AllotmentId":"{AllotmentId}","Location":"{Location}","ServiceId":"{ServiceId}","ServiceName":"{ServiceName}"},"flyoutType":"OmniScripts","hasExtraParams":true,"id":"flex-action-1671420878075","layoutType":"lightning","openFlyoutIn":"Modal","openUrlIn":"Current Window","osName":"CareLevel/Convert/English","type":"Flyout","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Convert Care Level Mix","name":"menu-item-1671419141710-0","showSpinner":"false"},{"actionList":[{"actionIndex":0,"card":"{card}","contextId":"\\{AllotmentId}","draggable":false,"isOpen":true,"key":"1671419747745-rf64g6wf0","label":"Variation","reRenderFlyout":true,"stateAction":{"actionConditions":{"group":[],"id":"state-condition-object","isParent":true},"displayName":"Action","extraParams":{"AllotmentId":"{AllotmentId}","EventType":"\"Variation\""},"hasExtraParams":true,"id":"flex-action-1684292962201","isLwcOS":true,"layoutType":"lightning","omniType":{"Id":"0jN9r00000022wzEAA","Name":"Variation/RecordNoticeToVary/English","isLwcOs":true},"openUrlIn":"Current Window","tabLabel":"Variation: {AllotmentName}","type":"OmniScript","vlocityIcon":"standard-default"}}],"iconName":"standard:default","label":"Variation","name":"menu-item-1671419747742-0","showSpinner":"false","actionConditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-1470","field":"VariationEventStatus","operator":"!=","value":"Inactive","type":"custom","hasMergeField":false},{"id":"state-new-condition-1477","field":"VariationEventType","operator":"!=","value":"Variation","type":"custom","hasMergeField":false,"logicalOperator":"&&"}]}}],"overflow":true,"position":"left","record":"{record}","size":"small","type":"action","variant":"brand","data-conditions":{"id":"state-condition-object","isParent":true,"group":[]}},"size":{"default":"3","isResponsive":false},"stateIndex":3,"styleObject":{"size":{"default":"3","isResponsive":false},"sizeClass":"slds-size_3-of-12 "},"type":"element","key":"element_element_block_2_3_flexMenu_2_3","parentElementKey":"element_block_2_3"}],"elementLabel":"Block-1","styleObjects":[{"key":0,"conditions":"default","styleObject":{"padding":[{"type":"around","size":"x-small","label":"around:x-small"}],"class":"slds-theme_shade slds-border_bottom slds-border_right slds-border_top slds-border_left slds-p-around_x-small ","sizeClass":"slds-size_12-of-12 ","margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"size":{"isResponsive":false,"default":"12"},"container":{"class":""},"border":{"type":["border_bottom","border_right","border_top","border_left"],"width":"1","color":"#cccccc","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","style":"     border-bottom: #cccccc 1px solid;border-right: #cccccc 1px solid;border-top: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ","theme":"theme_shade"},"label":"Default","name":"Default","conditionString":"","draggable":false}]}]}},"conditions":{"group":[{"field":"ServiceCareType","hasMergeField":false,"id":"state-new-condition-11","operator":"!=","type":"custom","value":"National Aboriginal and Torres Strait Islander Flexible Aged Care Program"},{"field":"AllotmentSubType","hasMergeField":false,"id":"state-new-condition-46","logicalOperator":"&&","operator":"!=","type":"custom","value":"S14-9"}],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"NOT_NATSIFAC","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":["border_top","border_right","border_bottom","border_left"],"width":""},"class":"slds-theme_default slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"     border-top: #ccc 1px solid;border-right: #ccc 1px solid;border-bottom: #ccc 1px solid;border-left: #ccc 1px solid; \n         ","text":{"align":"","color":""},"theme":"theme_default"}}],"theme":"slds","title":"PlacesAllotmentTracker","Id":"0koBm0000000OiHIAU","OmniUiCardKey":"PlacesAllotmentTracker/GPMS/8.0","OmniUiCardType":"Parent"};
  export default definition