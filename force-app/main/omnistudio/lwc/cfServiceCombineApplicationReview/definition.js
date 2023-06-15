let definition =
      {"dataSource":{"contextVariables":[],"orderBy":{"isReverse":"","name":""},"type":"Custom","value":{"body":"{\"Accreditation\":{\"EndDate\":\"2023-11-02\",\"StartDate\":\"2023-03-25\"},\"SpecialPurpose\":[{\"EndDate\":\"2023-04-12\",\"SpecialPurpose\":\"Significant Refurbishment\",\"StartDate\":\"2023-04-04\"},{\"EndDate\":\"2023-04-12\",\"SpecialPurpose\":\"Indigenous Specialisation\",\"StartDate\":\"2023-04-04\"}],\"HasSpecialPurpose\":true,\"NewServiceName\":\"kkjkj\",\"ContinuingPOC\":{\"Contact\":\"003Bm000003pO3NIAU\",\"Name\":\"MS Testing\",\"Salutation\":\"Abbot\",\"Id\":\"a2TBm0000006wKfMAI\",\"LastName\":\"Testing\",\"IntegrationId\":\"CRL-126453\",\"Birthday\":\"24/12/1975\",\"CRType\":\"Point of Contact\",\"FirstName\":\"MS\",\"Position\":\"position\",\"StartDate\":\"2023-04-04\",\"Role\":\"Primary Contact\"},\"ContinuingKP\":[{\"Name\":\"First Last\",\"Contact\":\"003Bm000005qVPpIAM\",\"Salutation\":\"Ms\",\"LastName\":\"Last\",\"Id\":\"a2TBm0000006wMHMAY\",\"IntegrationId\":\"CRL-126454\",\"CRType\":\"Key Personnel\",\"FirstName\":\"First\",\"Position\":\"Postiion\",\"StartDate\":\"2023-04-12\",\"Role\":\"Aged Care Service Manager\"},{\"Name\":\"First Last\",\"Contact\":\"003Bm000005qVPpIAM\",\"Salutation\":\"Ms\",\"LastName\":\"Last\",\"Id\":\"a2TBm0000006wNtMAI\",\"IntegrationId\":\"CRL-126455\",\"CRType\":\"Key Personnel\",\"FirstName\":\"First\",\"Position\":\"Postiion\",\"StartDate\":\"2023-04-12\",\"Role\":\"Aged Care Service Manager\"}],\"ContinuingService\":{\"PostCode\":\"3930\",\"RACSID\":\"637\",\"Id\":\"0cEBm0000000sBhMAI\",\"State\":\"VIC\",\"ProviderName\":\"Squad C AP\",\"ProvisionalPlacesFormula\":\"Yes\",\"Name\":\"Squad C Residential A1\",\"ACMPSNotified\":\"Yes\",\"AccreditedStatus\":\"Yes\",\"City\":\"MOUNT ELIZA\",\"IntegrationID\":\"SRV-16953\",\"CertifiedStatus\":\"Yes\",\"FullAddress\":\"33, ERANG, DRIVE, MOUNT ELIZA, VIC, 3930\",\"DateFirstOpened\":\"2023-03-15\",\"Status\":\"Operational\"}}","dsDelay":"","resultVar":""}},"enableLwc":true,"isFlex":true,"lwc":{"DeveloperName":"cfServiceCombineApplicationReview_1_GPMS","Id":"0RbBm0000003mL3KAI","ManageableState":"unmanaged","MasterLabel":"cfServiceCombineApplicationReview_1_GPMS","NamespacePrefix":"c"},"selectableMode":"Multi","states":[{"actions":[],"childCards":["ServiceCombine_SpecialPurpose","ServiceCombine_ServiceContactSummary","ServiceCombine_ServiceContactSummary","ServiceCombine_ServiceContactSummary","ServiceCombine_ServiceContactSummary"],"components":{"layer-0":{"children":[{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-1","key":"element_element_block_0_0_outputField_0_0","name":"Text","parentElementKey":"element_block_0_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3EService%20Details%3C/span%3E%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"EventStatus-2","key":"element_element_block_0_0_outputField_1_0","name":"EventStatus","parentElementKey":"element_block_0_0","property":{"card":"{card}","fieldName":"ContinuingService.IntegrationID","label":"Integration Id","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-1-clone-0","key":"element_element_block_0_0_outputField_2_0","name":"EventStatus","parentElementKey":"element_block_0_0","property":{"card":"{card}","fieldName":"ContinuingService.RACSID","label":"RACS Id","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-2-clone-0","key":"element_element_block_0_0_outputField_3_0","name":"EventStatus","parentElementKey":"element_block_0_0","property":{"card":"{card}","fieldName":"ContinuingService.ACMPSNotified","label":"ACMPS Notified","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-3-clone-0","key":"element_element_block_0_0_outputField_4_0","name":"EventStatus","parentElementKey":"element_block_0_0","property":{"card":"{card}","fieldName":"ContinuingService.Name","label":"Current Name","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-4-clone-0","key":"element_element_block_0_0_outputField_5_0","name":"EventStatus","parentElementKey":"element_block_0_0","property":{"card":"{card}","fieldName":"NewServiceName","label":"New Name","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-5-clone-0","key":"element_element_block_0_0_outputField_6_0","name":"EventStatus","parentElementKey":"element_block_0_0","property":{"card":"{card}","fieldName":"ContinuingService.DateFirstOpened","format":"D/M/YYYY","label":"Date Opened","labelclass":"","placeholder":"","record":"{record}","type":"date","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-6-clone-0","key":"element_element_block_0_0_outputField_7_0","name":"EventStatus","parentElementKey":"element_block_0_0","property":{"card":"{card}","fieldName":"ContinuingService.ProviderName","label":"Linked to Provider","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"6","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"6","isResponsive":false},"sizeClass":"slds-size_6-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"6","isResponsive":false},"sizeClass":"slds-size_6-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"}],"class":"slds-col ","element":"block","elementLabel":"Block-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"class":"slds-p-around_x-small","padding":[{"size":"x-small","type":"around"}],"sizeClass":"slds-size_12-of-12"},"type":"block"},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-1","key":"element_element_block_1_0_outputField_0_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3ECurrent%20Accreditation%3C/span%3E%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-clone-0-Text-1-clone-0","key":"element_element_block_1_0_outputField_1_0","name":"Text","parentElementKey":"element_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"ContinuingService.AccreditedStatus","hasMergeField":false,"id":"state-new-condition-7","operator":"==","type":"custom","value":"No"}],"id":"state-condition-object","isParent":true},"mergeField":"%3Cdiv%20class=%22slds-text-align_center%22%3E%3Cem%3EHas%20no%20Accreditation.%3C/em%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-5-clone-0","key":"element_element_block_1_0_outputField_2_0","name":"EventStatus","parentElementKey":"element_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"ContinuingService.AccreditedStatus","hasMergeField":false,"id":"state-new-condition-43","operator":"==","type":"custom","value":"Yes"}],"id":"state-condition-object","isParent":true},"fieldName":"Accreditation.StartDate","format":"D/M/YYYY","label":"Accreditation Start Date","labelclass":"","placeholder":"","record":"{record}","type":"date","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-clone-0-EventStatus-1-clone-0","key":"element_element_block_1_0_outputField_3_0","name":"EventStatus","parentElementKey":"element_block_1_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"ContinuingService.AccreditedStatus","hasMergeField":false,"id":"state-new-condition-38","operator":"==","type":"custom","value":"Yes"}],"id":"state-condition-object","isParent":true},"fieldName":"Accreditation.EndDate","format":"D/M/YYYY","label":"Accreditation End Date","labelclass":"","placeholder":"","record":"{record}","type":"date","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"}],"class":"slds-col ","element":"block","elementLabel":"Block-0-clone-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"class":"slds-p-around_x-small","padding":[{"size":"x-small","type":"around"}],"sizeClass":"slds-size_12-of-12"},"type":"block"},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-1","key":"element_element_block_2_0_outputField_0_0","name":"Text","parentElementKey":"element_block_2_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3ECurrent%20Certification%3C/span%3E%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-5-clone-0","key":"element_element_block_2_0_outputField_1_0","name":"EventStatus","parentElementKey":"element_block_2_0","property":{"card":"{card}","fieldName":"Accreditation.StartDate","format":"D/M/YYYY","label":"Accreditation Start Date","labelclass":"","placeholder":"","record":"{record}","type":"date","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-clone-0-EventStatus-1-clone-0","key":"element_element_block_2_0_outputField_2_0","name":"EventStatus","parentElementKey":"element_block_2_0","property":{"card":"{card}","fieldName":"Accreditation.EndDate","format":"D/M/YYYY","label":"Accreditation End Date","labelclass":"","placeholder":"","record":"{record}","type":"date","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"}],"class":"slds-col ","element":"block","elementLabel":"Block-1-clone-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"class":"slds-p-around_x-small","padding":[{"size":"x-small","type":"around"}],"sizeClass":"slds-size_12-of-12"},"type":"block"},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-clone-0-Text-0","key":"element_element_block_3_0_outputField_0_0","name":"Text","parentElementKey":"element_block_3_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3ESpecial%20Purpose%3C/span%3E%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-2-clone-0-Text-1","key":"element_element_block_3_0_outputField_1_0","name":"Text","parentElementKey":"element_block_3_0","property":{"card":"{card}","data-conditions":{"group":[{"field":"HasSpecialPurpose","hasMergeField":false,"id":"state-new-condition-7","operator":"==","type":"custom","value":"false"}],"id":"state-condition-object","isParent":true},"mergeField":"%3Cdiv%20class=%22slds-text-align_center%22%3E%3Cem%3EHas%20no%20Special%20Purpose.%3C/em%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-2-clone-0-FlexCard-2","key":"element_element_block_3_0_childCardPreview_3_0","name":"FlexCard","parentElementKey":"element_block_3_0","property":{"cardName":"ServiceCombine_SpecialPurpose","cardNode":"{record.SpecialPurpose}","data-conditions":{"group":[{"field":"HasSpecialPurpose","hasMergeField":false,"id":"state-new-condition-0","operator":"==","type":"custom","value":"true"}],"id":"state-condition-object","isParent":true},"isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-2-clone-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"class":"slds-p-around_x-small","padding":[{"size":"x-small","type":"around"}],"sizeClass":"slds-size_12-of-12"},"type":"block"},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Text-1","key":"element_element_block_4_0_outputField_0_0","name":"Text","parentElementKey":"element_block_4_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3ECurrent%20Physical%20Address%3C/span%3E%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-EventStatus-5-clone-0","key":"element_element_block_4_0_outputField_1_0","name":"EventStatus","parentElementKey":"element_block_4_0","property":{"card":"{card}","fieldName":"ContinuingService.FullAddress","format":"D/M/YYYY, h:mm a","label":"Address","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-clone-0-EventStatus-1-clone-0","key":"element_element_block_4_0_outputField_2_0","name":"EventStatus","parentElementKey":"element_block_4_0","property":{"card":"{card}","fieldName":"ContinuingService.City","format":"D/M/YYYY, h:mm a","label":"Suburb or Town","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-3-clone-0-EventStatus-2-clone-0","key":"element_element_block_4_0_outputField_3_0","name":"EventStatus","parentElementKey":"element_block_4_0","property":{"card":"{card}","fieldName":"ContinuingService.State","format":"D/M/YYYY, h:mm a","label":"State","labelclass":"","placeholder":"","record":"{record}","type":"datetime","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-3-clone-0-EventStatus-3-clone-0","key":"element_element_block_4_0_outputField_4_0","name":"EventStatus","parentElementKey":"element_block_4_0","property":{"card":"{card}","fieldName":"ContinuingService.PostCode","format":"D/M/YYYY, h:mm a","label":"Post Code","labelclass":"","placeholder":"","record":"{record}","type":"text","valueclass":""},"size":{"default":"4","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"","container":{"class":""},"elementStyleProperties":{"labelclass":"","valueclass":""},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"4","isResponsive":false},"sizeClass":"slds-size_4-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"field"}],"class":"slds-col ","element":"block","elementLabel":"Block-3-clone-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"class":"slds-p-around_x-small","padding":[{"size":"x-small","type":"around"}],"sizeClass":"slds-size_12-of-12"},"type":"block"},{"children":[{"class":"slds-col ","element":"outputField","elementLabel":"Block-5-clone-0-Text-0","key":"element_element_block_5_0_outputField_0_0","name":"Text","parentElementKey":"element_block_5_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3EContact%20Relationship%3C/span%3E%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-5-clone-0-Text-2","key":"element_element_block_5_0_outputField_1_0","name":"Text","parentElementKey":"element_block_5_0","property":{"card":"{card}","mergeField":"%3Cul%3E%0A%3Cli%3E%3Cstrong%3EContinuing%20Service%20-%20Key%20Personnel%3C/strong%3E%3C/li%3E%0A%3C/ul%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-5-clone-0-FlexCard-3","key":"element_element_block_5_0_childCardPreview_2_0","name":"FlexCard","parentElementKey":"element_block_5_0","property":{"cardName":"ServiceCombine_ServiceContactSummary","cardNode":"{record.ContinuingKP}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":12,"isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":12,"isResponsive":false},"sizeClass":"slds-size_12-of-12"},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-5-clone-0-Text-1-clone-0","key":"element_element_block_5_0_outputField_3_0","name":"Text","parentElementKey":"element_block_5_0","property":{"card":"{card}","mergeField":"%3Cul%3E%0A%3Cli%3E%3Cstrong%3EContinuing%20Service%20-%20Point%20of%20Contact%3C/strong%3E%3C/li%3E%0A%3C/ul%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-5-clone-0-FlexCard-4","key":"element_element_block_5_0_childCardPreview_4_0","name":"FlexCard","parentElementKey":"element_block_5_0","property":{"cardName":"ServiceCombine_ServiceContactSummary","cardNode":"{record.ContinuingPOC}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":12,"isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":12,"isResponsive":false},"sizeClass":"slds-size_12-of-12"},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-5-clone-0-Text-1-clone-1","key":"element_element_block_5_0_outputField_5_0","name":"Text","parentElementKey":"element_block_5_0","property":{"card":"{card}","mergeField":"%3Cul%3E%0A%3Cli%3E%3Cstrong%3EDiscontinuing%20Service%20-%20Key%20Personnel%3C/strong%3E%3C/li%3E%0A%3C/ul%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-5-clone-0-FlexCard-5","key":"element_element_block_5_0_childCardPreview_6_0","name":"FlexCard","parentElementKey":"element_block_5_0","property":{"cardName":"ServiceCombine_ServiceContactSummary","cardNode":"{record.ConKP}","data-conditions":{"group":[],"id":"state-condition-object","isParent":true},"isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":12,"isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":12,"isResponsive":false},"sizeClass":"slds-size_12-of-12"},"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-5-clone-0-Text-3-clone-0","key":"element_element_block_5_0_outputField_7_0","name":"Text","parentElementKey":"element_block_5_0","property":{"card":"{card}","mergeField":"%3Cul%3E%0A%3Cli%3E%3Cstrong%3EDiscontinuing%20Service%20-%20Point%20of%20Contact%3C/strong%3E%3C/li%3E%0A%3C/ul%3E","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"sizeClass":"slds-size_12-of-12"},"type":"text"},{"class":"slds-col ","element":"childCardPreview","elementLabel":"Block-5-clone-0-FlexCard-6","key":"element_element_block_5_0_childCardPreview_8_0","name":"FlexCard","parentElementKey":"element_block_5_0","property":{"cardName":"ServiceCombine_ServiceContactSummary","cardNode":"{record.ConPOC}","isChildCardTrackingEnabled":false,"recordId":"{recordId}","selectedState":"Active"},"size":{"default":12,"isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":12,"isResponsive":false},"sizeClass":"slds-size_12-of-12"},"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-5-clone-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"class":"slds-p-around_x-small","padding":[{"size":"x-small","type":"around"}],"sizeClass":"slds-size_12-of-12"},"type":"block"}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Active","omniscripts":[],"smartAction":{},"styleObject":{"class":"slds-card slds-p-around_x-small slds-m-bottom_x-small","container":{"class":"slds-card"},"margin":[{"size":"x-small","type":"bottom"}],"padding":[{"size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12"}}],"theme":"slds","title":"ServiceCombineApplicationReview","Id":"0koBm0000000K1xIAE","OmniUiCardKey":"ServiceCombineApplicationReview/GPMS/1.0","OmniUiCardType":"Parent"};
  export default definition