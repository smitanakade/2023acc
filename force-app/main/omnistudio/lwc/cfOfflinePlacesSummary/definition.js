let definition =
      {"dataSource":{"type":"DataRaptor","value":{"dsDelay":"","bundle":"OfflinePlaces_Extract","bundleType":"","inputMap":{"AllotmentId":"{recordId}"},"resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"enableLwc":true,"isFlex":true,"isRepeatable":false,"lwc":{"DeveloperName":"cfOfflinePlacesSummary_2_GPMS","Id":"0Rb9r0000002z2bCAA","ManageableState":"unmanaged","MasterLabel":"cfOfflinePlacesSummary_2_GPMS","NamespacePrefix":"c"},"selectableMode":"Multi","states":[{"actions":[],"childCards":[],"components":{"layer-0":{"children":[{"children":[{"class":"slds-col ","element":"flexIcon","elementLabel":"Block-0-Icon-0","key":"element_element_block_0_0_flexIcon_0_0","name":"Icon","parentElementKey":"element_block_0_0","property":{"card":"{card}","extraclass":"slds-icon_container slds-icon-standard-visits ","iconName":"standard:visits","iconType":"Salesforce SVG","imgsrc":"","record":"{record}","size":"small","variant":"inverse"},"size":{"default":"1","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_xx-small slds-p-left_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:xx-small","size":"xx-small","type":"bottom"},{"label":"left:xx-small","size":"xx-small","type":"left"}],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-bottom_xx-small slds-p-left_xx-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"bottom:xx-small","size":"xx-small","type":"bottom"},{"label":"left:xx-small","size":"xx-small","type":"left"}],"size":{"default":"1","isResponsive":false},"sizeClass":"slds-size_1-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"element"},{"class":"slds-col ","element":"outputField","elementLabel":"Block-0-Text-1","key":"element_element_block_0_0_outputField_1_0","name":"Text","parentElementKey":"element_block_0_0","property":{"card":"{card}","mergeField":"%3Cdiv%3E%3Cstrong%3EOffline%20Places%3C/strong%3E%3C/div%3E","record":"{record}"},"size":{"default":"10","isResponsive":false},"stateIndex":0,"styleObject":{"size":{"default":"10","isResponsive":false},"sizeClass":"slds-size_10-of-12 "},"type":"text"},{"class":"slds-col ","element":"flexDatatable","elementLabel":"Block-0-Datatable-2","key":"element_element_block_0_0_flexDatatable_2_0","name":"Datatable","parentElementKey":"element_block_0_0","property":{"card":"{card}","cellLevelEdit":true,"groupOrder":"asc","issearchavailable":false,"issortavailable":true,"pagelimit":3,"record":"{record}","styles":{"cellBorderType":["border_top","border_right","border_bottom","border_left"],"cellMargin":[],"cellPadding":[],"headFontWeight":"bold","headTextDecoration":"","rowBgColor":"","tableBorderType":["border_top","border_right","border_bottom","border_left"],"tableBorderWidth":"2"},"columns":[{"editable":false,"fieldName":"DateOfNotification","label":"Date of Notification","searchable":false,"sortable":true,"type":"text","visible":true},{"fieldName":"OfflineStartDate","label":"Offline Start Date","searchable":false,"sortable":true,"type":"text"},{"editable":false,"fieldName":"ExpectedEndDate","label":"Expected End Date","searchable":"false","sortable":false,"type":"text","visible":true},{"editable":false,"fieldName":"OfflineEndDate","label":"Offline End Date","searchable":false,"sortable":false,"type":"text","visible":true},{"editable":"false","fieldName":"PrimaryReason","label":"Primary Reason","searchable":"false","sortable":"false","type":"text","visible":"true"},{"editable":"false","fieldName":"Offline","label":"Care Type: Residential","searchable":"false","sortable":"false","type":"number","visible":"true"},{"editable":"false","fieldName":"GeneralAccess","label":"Target Group: General Access","searchable":"false","sortable":"false","type":"number","visible":"true"},{"editable":"false","fieldName":"SpecialNeedsKeyIssues","label":"Target Group: Special Needs and Key Issues","searchable":"false","sortable":"false","type":"number","visible":"true"},{"editable":"false","fieldName":"NotSpecified","label":"Target Group: Not Specified","searchable":"false","sortable":"false","type":"number","visible":"true"},{"editable":"false","fieldName":"Comments","label":"Comment","searchable":"false","sortable":"false","type":"textarea","visible":"true"}],"records":"{records}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":[],"width":""},"class":" ","container":{"class":""},"elementStyleProperties":{"styles":{"cellBorderType":["border_top","border_right","border_bottom","border_left"],"cellMargin":[],"cellPadding":[],"headFontWeight":"bold","headTextDecoration":"","rowBgColor":"","tableBorderType":["border_top","border_right","border_bottom","border_left"],"tableBorderWidth":"2"}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"#cccccc","radius":"","style":"","type":[],"width":""},"class":" ","container":{"class":""},"elementStyleProperties":{"styles":{"cellBorderType":["border_top","border_right","border_bottom","border_left"],"cellMargin":[],"cellPadding":[],"headFontWeight":"bold","headTextDecoration":"","rowBgColor":"","tableBorderType":["border_top","border_right","border_bottom","border_left"],"tableBorderWidth":"2"}},"inlineStyle":"","margin":[],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"element"}],"class":"slds-col ","element":"block","elementLabel":"Block-0","name":"Block","property":{"card":"{card}","collapsedByDefault":false,"collapsible":false,"label":"Block","record":"{record}"},"size":{"default":"12","isResponsive":false},"stateIndex":0,"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}},"styleObjects":[{"conditionString":"","conditions":"default","draggable":false,"key":0,"label":"Default","name":"Default","styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-p-around_x-small ","container":{"class":""},"elementStyleProperties":{},"inlineStyle":"","margin":[],"padding":[{"label":"around:x-small","size":"x-small","type":"around"}],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""}}}],"type":"block"}]}},"conditions":{"group":[],"id":"state-condition-object","isParent":true},"definedActions":{"actions":[]},"documents":[],"fields":[],"isSmartAction":false,"name":"Active","omniscripts":[],"smartAction":{},"styleObject":{"background":{"color":"","image":"","position":"","repeat":"","size":""},"border":{"color":"","radius":"","style":"","type":"","width":""},"class":"slds-theme_shade slds-card slds-m-top_x-small slds-m-bottom_x-small ","container":{"class":"slds-card"},"elementStyleProperties":{},"inlineStyle":"","margin":[{"label":"top:x-small","size":"x-small","type":"top"},{"label":"bottom:x-small","size":"x-small","type":"bottom"}],"padding":[],"size":{"default":"12","isResponsive":false},"sizeClass":"slds-size_12-of-12 ","style":"      \n         ","text":{"align":"","color":""},"theme":"theme_shade"}}],"theme":"slds","title":"OfflinePlacesSummary","Id":"0koBm00000005m6IAA","OmniUiCardKey":"OfflinePlacesSummary/GPMS/2.0","OmniUiCardType":"Parent"};
  export default definition