let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-0","field":"ValidAddress","operator":"!=","value":"Invalid","type":"custom","hasMergeField":false}]},"name":"MultipleAddresses","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small","label":"around:x-small"}],"margin":[{"type":"around","size":"none","label":"around:none"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12 ","class":"slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small slds-m-around_none ","background":{"color":"","image":"","size":"","repeat":"","position":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"","color":"#cccccc","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","style":"     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         "},"blankCardState":false,"components":{"layer-0":{"children":[{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"7"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2012pt;%22%3E%7Blong_label%7D%3C/span%3E%3C/strong%3E%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_7-of-12 ","size":{"isResponsive":false,"default":"7"}},"elementLabel":"Text-0"},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"5"},"stateIndex":0,"class":"slds-col ","property":{"label":"Select This Address","iconName":"standard-default","record":"{record}","card":"{card}","stateObj":"{record}","actionList":[{"stateAction":{"id":"flex-action-1666814044354","type":"updateOmniScript","openUrlIn":"Current Window","elementId":"SelectedAddress","hasExtraParams":true,"extraParams":{"AddressRecordType":"{AddressRecordType}","LocationRecordType":"{LocationRecordType}","CurrentServiceId":"{CurrentRecordId}","LocationId":"{LocationId}","Street":"{st_addr}","Sub_addr":"{sub_addr}","gnaf_pid":"{gnaf_pid}","Postcode":"{postal}","City":"{nbrhd}","State":"{region}","Country":"Australia","Latitude":"{latitude}","Longitude":"{longitude}","Source":"FlexCard","SingleLineAddress":"{long_label}","OriginalSelectedlnput":"{OriginalInput}","OriginalSelectedSingleLinelnput":"{OriginalInputSingleLine}","add_num":"{add_num}","st_name":"{st_name}","st_type":"{st_type}","st_dir":"{st_dir}","unit_type":"{unit_type}","unit_name":"{unit_name}","level_type":"{level_type}","level_name":"{level_name}","add_bldg":"{add_bldg}","place_name":"{place_name}"}},"key":"1658209351149-7kvz79uh5","label":"SelectedAddress","draggable":false,"isOpen":true,"actionIndex":0}],"showSpinner":"false","flyoutDetails":{},"displayAsButton":true,"buttonVariant":"brand","hideActionIcon":true,"iconOnly":false},"type":"element","styleObject":{"sizeClass":"slds-size_5-of-12 ","size":{"isResponsive":false,"default":"5"}},"elementLabel":"SelectThisAddress","userUpdatedElementLabel":true},{"name":"Text","element":"baseInputElement","size":{"isResponsive":false,"default":"1"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","type":"text","card":"{card}","propertyObj":{"label":"Score","fieldBinding":"{score}","readOnly":true}},"type":"element","styleObject":{"size":{"isResponsive":false,"default":"1"},"padding":[{"type":"right","size":"small"}],"margin":[{"type":"bottom","size":"xx-small"}],"class":"slds-p-right_x-small","sizeClass":"slds-size_1-of-12 "},"elementLabel":"Score","userUpdatedElementLabel":true},{"name":"Text","element":"baseInputElement","size":{"isResponsive":false,"default":"2"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","type":"text","card":"{card}","propertyObj":{"label":"Latitude","value":"{latitude}","readOnly":true,"fieldBinding":"{latitude}"}},"type":"element","styleObject":{"padding":[{"type":"right","size":"small"}],"margin":[{"type":"bottom","size":"xx-small"}],"class":"slds-p-right_x-small","sizeClass":"slds-size_2-of-12 ","size":{"isResponsive":false,"default":"2"}},"elementLabel":"Text-3"},{"name":"Text","element":"baseInputElement","size":{"isResponsive":false,"default":"2"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","type":"text","card":"{card}","propertyObj":{"label":"Longitude","value":"{longitude}","readOnly":true,"fieldBinding":"{longitude}"}},"type":"element","styleObject":{"padding":[{"type":"right","size":"small"}],"margin":[{"type":"bottom","size":"xx-small"}],"class":"slds-p-right_x-small","sizeClass":"slds-size_2-of-12 ","size":{"isResponsive":false,"default":"2"}},"elementLabel":"Text-4"}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]},{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-10","field":"ValidAddress","operator":"==","value":"Invalid","type":"custom","hasMergeField":false}]},"name":"MultipleAddresses","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small","label":"around:x-small"}],"margin":[{"type":"around","size":"none","label":"around:none"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12 ","class":"slds-card  slds-p-around_x-small slds-m-around_none ","background":{"color":"","image":"","size":"","repeat":"","position":""},"border":{"type":[],"width":"","color":"#cccccc","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","style":"      \n         "},"blankCardState":false,"components":{"layer-0":{"children":[{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"8"},"stateIndex":1,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Ch3%3E%3Cstrong%3ENo%20valid%20addresses%20have%20been%20found.%3C/strong%3E%3C/h3%3E%0A%3Cdiv%3E&nbsp;%3C/div%3E%0A%3Cdiv%3E%3Cstrong%3EEither%20return%20to%20previous%20screen%20to%20try%20again%20or%20select%20to%20proceed%20with%20an%20unvalidated%20address%3C/strong%3E%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_8-of-12 ","size":{"isResponsive":false,"default":"8"}},"elementLabel":"Text-0"}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]}],"dataSource":{"type":"Custom","value":{"dsDelay":"","body":"{\n\t\"territory\": \"\",\n\t\"add_num_to\": \"\",\n\t\"sub_region\": \"\",\n\t\"add_range\": \"\",\n\t\"AddressRecordType\": \"Physical\",\n\t\"url\": \"\",\n\t\"bldg_name\": \"\",\n\t\"latitude_min\": -26.694802008037517,\n\t\"LocationId\": \"a1p9r0000003gnVAAQ\",\n\t\"federal_electorate\": \"FISHER\",\n\t\"add_num\": \"345\",\n\t\"st_name\": \"CHEVALLUM\",\n\t\"add_bldg\": \"\",\n\t\"st_dir\": \"\",\n\t\"side\": \"\",\n\t\"short_label\": \"345 CHEVALLUM ROAD\",\n\t\"place_name\": \"\",\n\t\"metro_area\": \"\",\n\t\"lang_code\": \"ENG\",\n\"ValidAddress\": \"Valid\",\n\t\"gnaf_pid\": \"GAQLD160945831\",\n\t\"level_type\": \"\",\n\t\"unit_type\": \"\",\n\t\"LocationRecordType\": \"ServiceAddress\",\n\t\"st_pre_type\": \"\",\n\t\"st_addr\": \"345 CHEVALLUM ROAD\",\n\t\"lga\": \"SUNSHINE COAST REGIONAL\",\n\t\"latitude\": -26.693802008038524,\n\t\"state_electorate\": \"NICKLIN\",\n\t\"city\": \"\",\n\t\"distance\": 0,\n\t\"postal_ext\": \"\",\n\t\"status\": \"M\",\n\t\"leagal_parcel_id\": \"10/RP881319\",\n\t\"ex_info\": \"\",\n\t\"region\": \"QLD\",\n\t\"postal\": \"4555\",\n\t\"region_abbr\": \"QLD\",\n\t\"bldg_type\": \"\",\n\t\"district\": \"\",\n\t\"long_label\": \"345 CHEVALLUM ROAD, CHEVALLUM, QLD, 4555\",\n\t\"success\": \"OK\",\n\t\"meshblock\": \"30428570000\",\n\t\"phone\": \"\",\n\t\"place_addr\": \"345 CHEVALLUM ROAD, CHEVALLUM, QLD, 4555\",\n\t\"level_name\": \"\",\n\t\"unit_name\": \"\",\n\t\"sa1\": 31606144412,\n\t\"longitude\": 152.99118449499886,\n\t\"sector\": \"\",\n\t\"st_pre_dir\": \"\",\n\t\"block\": \"\",\n\t\"rank\": 20,\n\t\"display_longitude\": 152.99118449499886,\n\t\"zone\": \"\",\n\t\"sub_addr\": \"\",\n\t\"score\": 100,\n\t\"longitude_min\": 152.9901844949994,\n\t\"match_addr\": \"345 CHEVALLUM ROAD, CHEVALLUM, QLD, 4555\",\n\t\"type\": \"\",\n\t\"full_address\": \"345 CHEVALLUM ROAD CHEVALLUM QLD 4555\",\n\t\"st_type\": \" ROAD\",\n\t\"display_latitude\": -26.693802008038524,\n\t\"longitude_max\": 152.9921844949983,\n\t\"nbrhd\": \"CHEVALLUM\",\n\t\"CurrentRecordId\": \"0cE9r00000004RpEAI\",\n\t\"latitude_max\": -26.69280200803953,\n\t\"addr_type\": \"PointAddress\",\n\t\"country\": \"\",\n\t\"add_num_from\": \"\",\n\"OriginalInputSingleLine\": \"100 Collins Street Melbourne\",\n\"OriginalInput\": \"dHA9MCNsb2M9NDI2MjAjbG5nPTAjaG49MiNsYnM9MTA5OjQ4ODU3NjA0\"\n}","resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"title":"LocationServicesAddressMultiSelect","enableLwc":true,"isFlex":true,"theme":"slds","selectableMode":"Multi","lwc":{"DeveloperName":"cfLocationServicesAddressMultiSelect_1_GPMS","Id":"0Rb9r0000001n8LCAQ","MasterLabel":"cfLocationServicesAddressMultiSelect_1_GPMS","NamespacePrefix":"c","ManageableState":"unmanaged"},"isRepeatable":true,"osSupport":false,"events":[{"eventname":"data","channelname":"LocationServicesAddressMultiSelect","element":"action","eventtype":"pubsub","recordIndex":"0","actionList":[{"key":"1659075287565-qnm9yf1c4","label":"Action","draggable":false,"isOpen":true,"card":"{card}","stateAction":{"id":"flex-action-1659075287613","type":"cardAction","displayName":"Action","vlocityIcon":"standard-default","targetType":"Web Page","openUrlIn":"Current Window","Web Page":{"targetName":"/apex"},"eventName":"reload"},"actionIndex":0,"isTrackingDisabled":true}],"showSpinner":"false","key":"event-0","displayLabel":"LocationServicesAddressMultiSelect:data","eventLabel":"pubsub"}],"Id":"0ko9r00000005sXAAQ","OmniUiCardKey":"LocationServicesAddressMultiSelect/GPMS/1.0","OmniUiCardType":"Parent"};
  export default definition