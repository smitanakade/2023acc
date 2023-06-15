let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[]},"definedActions":{"actions":[]},"name":"Active","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small"}],"margin":[{"type":"bottom","size":"x-small"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12","class":"slds-card slds-p-around_x-small slds-m-bottom_x-small"},"components":{"layer-0":{"children":[{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cp%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3ECombine%20Application%20Details%3C/span%3E%3C/strong%3E%3C/p%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-0"},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-4"},{"name":"ReceivedDate","element":"outputField","size":{"isResponsive":false,"default":"4"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"","record":"{record}","fieldName":"ReceivedDate","label":"Received Date","card":"{card}","type":"date","format":"D/M/YYYY"},"type":"field","styleObject":{"sizeClass":"slds-size_4-of-12 ","size":{"isResponsive":false,"default":"4"}},"elementLabel":"ReceivedDate-1"},{"name":"ProposedDate","element":"outputField","size":{"isResponsive":false,"default":"4"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"","record":"{record}","fieldName":"ProposedDate","label":"Proposed Date","card":"{card}","type":"date","format":"D/M/YYYY"},"type":"field","styleObject":{"size":{"isResponsive":false,"default":"4"},"sizeClass":"slds-size_4-of-12 "},"elementLabel":"ProposedDate-2"},{"name":"DecisionDueBy","element":"outputField","size":{"isResponsive":false,"default":"4"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"","record":"{record}","fieldName":"DecisionDueBy","label":"Decision Due By","card":"{card}","type":"date","format":"D/M/YYYY"},"type":"field","styleObject":{"size":{"isResponsive":false,"default":"4"},"sizeClass":"slds-size_4-of-12 "},"elementLabel":"DecisionDueBy-3"},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%3E&nbsp;%3C/div%3E%0A%3Cdiv%3E&nbsp;%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-4-clone-1"},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cp%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3EContinuing%20Service%20Details%3C/span%3E%3C/strong%3E%3C/p%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-5"},{"name":"FlexCard","element":"childCardPreview","size":{"isResponsive":false,"default":12},"stateIndex":0,"class":"slds-col ","property":{"cardName":"CombineSummary","recordId":"{recordId}","cardNode":"{record.ContinuingService}","selectedState":"Active","isChildCardTrackingEnabled":false},"type":"element","styleObject":{"size":{"isResponsive":false,"default":12},"sizeClass":"slds-size_12-of-12"},"elementLabel":"FlexCard-6"},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%3E&nbsp;%3C/div%3E%0A%3Cdiv%3E&nbsp;%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-4-clone-0"},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cp%3E%3Cstrong%3E%3Cspan%20style=%22font-size:%2024pt;%22%3EDiscontinuing%20Service%20Details%3C/span%3E%3C/strong%3E%3C/p%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-7"},{"name":"FlexCard","element":"childCardPreview","size":{"isResponsive":false,"default":12},"stateIndex":0,"class":"slds-col ","property":{"cardName":"DisConCombineSummary","recordId":"{recordId}","cardNode":"{record.DiscontinuingService}","selectedState":"Active","isChildCardTrackingEnabled":false},"type":"element","styleObject":{"size":{"isResponsive":false,"default":12},"sizeClass":"slds-size_12-of-12"},"elementLabel":"FlexCard-8"}]}},"childCards":["CombineSummary","DisConCombineSummary"],"actions":[],"omniscripts":[],"documents":[]}],"dataSource":{"type":"Custom","value":{"dsDelay":"","body":"{\n\t\"ReceivedDateText\": \"21/3/2023\",\n\t\"ProposedDateText\": \"1/3/2023\",\n\t\"DecisionDueBy\": \"15/3/2023\",\n\t\"DecisionDueByLoad\": \"2023-3-15\",\n\t\"ReceivedDate\": \"2023-03-21\",\n\t\"ProposedDate\": \"2023-03-01\",\n\t\"ContinuingService\": [\n\t\t{\n\t\t\t\"Id\": \"0cEBm0000000sMzMAI\",\n\t\t\t\"AddressState\": \"VIC\",\n\t\t\t\"AddressId\": \"a2IBm000000AcwrMAC\",\n\t\t\t\"RACSID\": \"6323425\",\n\t\t\t\"ProvisionalPlaces\": 0,\n\t\t\t\"Accredited\": {\n\t\t\t\t\"Status\": \"Accredited\"\n\t\t\t},\n\t\t\t\"ACMPSNotified\": \"Yes\",\n\t\t\t\"Name\": \"Squad C Residential B1\",\n\t\t\t\"IntegrationID\": \"SRV-16954\",\n\t\t\t\"Certified\": {\n\t\t\t\t\"Status\": \"Certified\"\n\t\t\t},\n\t\t\t\"FullAddress\": \"33 ERANG DRIVE, MOUNT ELIZA, VIC, 3930\",\n\t\t\t\"CareType\": \"Residential\",\n\t\t\t\"DateFirstOpened\": \"2023-03-15\",\n\t\t\t\"Status\": \"Operational\"\n\t\t}\n\t],\n\t\"DiscontinuingService\": [\n\t\t{\n\t\t\t\"Id\": \"0cEBm0000000sd7MAA\",\n\t\t\t\"AddressState\": \"VIC\",\n\t\t\t\"AddressId\": \"a2IBm000000AcwrMAC\",\n\t\t\t\"RACSID\": \"40986\",\n\t\t\t\"ProvisionalPlaces\": 0,\n\t\t\t\"ACMPSNotified\": \"No\",\n\t\t\t\"Name\": \"Squad C Residential C1\",\n\t\t\t\"IntegrationID\": \"SRV-16957\",\n\t\t\t\"Certified\": {\n\t\t\t\t\"Status\": \"Certified\"\n\t\t\t},\n\t\t\t\"FullAddress\": \"33 ERANG DRIVE, MOUNT ELIZA, VIC, 3930\",\n\t\t\t\"CareType\": \"Residential\",\n\t\t\t\"Status\": \"Operational\",\n\t\t\t\"DateFirstOpened\": \"2023-03-15\"\n\t\t},\n\t\t{\n\t\t\t\"Id\": \"0cEBm0000000sBhMAI\",\n\t\t\t\"AddressState\": \"VIC\",\n\t\t\t\"AddressId\": \"a2IBm000000AcwrMAC\",\n\t\t\t\"RACSID\": \"637\",\n\t\t\t\"ProvisionalPlaces\": 0,\n\t\t\t\"ACMPSNotified\": \"Yes\",\n\t\t\t\"Name\": \"Squad C Residential A1\",\n\t\t\t\"IntegrationID\": \"SRV-16953\",\n\t\t\t\"Certified\": {\n\t\t\t\t\"Status\": \"Certified\"\n\t\t\t},\n\t\t\t\"FullAddress\": \"33 ERANG DRIVE, MOUNT ELIZA, VIC, 3930\",\n\t\t\t\"CareType\": \"Residential\",\n\t\t\t\"Status\": \"Operational\",\n\t\t\t\"DateFirstOpened\": \"2023-03-15\"\n\t\t}\n\t]\n}","resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"title":"DisplayServiceCombineSummary","enableLwc":true,"isFlex":true,"theme":"slds","selectableMode":"Multi","events":[{"eventname":"data","channelname":"DisplayServiceCombineSummary","element":"action","eventtype":"pubsub","recordIndex":"0","actionList":[{"key":"1679609243508-k1ksh271g","label":"Action","draggable":false,"isOpen":true,"card":"{card}","stateAction":{"id":"flex-action-1679612828372","type":"DataAction","displayName":"Action","vlocityIcon":"standard-default","targetType":"Web Page","openUrlIn":"Current Window","Web Page":{"targetName":"/apex"},"message":"{\"type\":\"Custom\",\"value\":{\"dsDelay\":\"\",\"body\":\"{\\n\\t\\\"ReceivedDateText\\\": \\\"21/3/2023\\\",\\n\\t\\\"ProposedDateText\\\": \\\"1/3/2023\\\",\\n\\t\\\"DecisionDueBy\\\": \\\"15/3/2023\\\",\\n\\t\\\"DecisionDueByLoad\\\": \\\"2023-3-15\\\",\\n\\t\\\"ReceivedDate\\\": \\\"2023-03-21\\\",\\n\\t\\\"ProposedDate\\\": \\\"2023-03-01\\\",\\n\\t\\\"ContinuingService\\\": [\\n\\t\\t{\\n\\t\\t\\t\\\"Id\\\": \\\"0cEBm0000000sMzMAI\\\",\\n\\t\\t\\t\\\"AddressState\\\": \\\"VIC\\\",\\n\\t\\t\\t\\\"AddressId\\\": \\\"a2IBm000000AcwrMAC\\\",\\n\\t\\t\\t\\\"RACSID\\\": \\\"6323425\\\",\\n\\t\\t\\t\\\"ProvisionalPlaces\\\": 0,\\n\\t\\t\\t\\\"Accredited\\\": {\\n\\t\\t\\t\\t\\\"Status\\\": \\\"Accredited\\\"\\n\\t\\t\\t},\\n\\t\\t\\t\\\"ACMPSNotified\\\": \\\"Yes\\\",\\n\\t\\t\\t\\\"Name\\\": \\\"Squad C Residential B1\\\",\\n\\t\\t\\t\\\"IntegrationID\\\": \\\"SRV-16954\\\",\\n\\t\\t\\t\\\"Certified\\\": {\\n\\t\\t\\t\\t\\\"Status\\\": \\\"Certified\\\"\\n\\t\\t\\t},\\n\\t\\t\\t\\\"FullAddress\\\": \\\"33 ERANG DRIVE, MOUNT ELIZA, VIC, 3930\\\",\\n\\t\\t\\t\\\"CareType\\\": \\\"Residential\\\",\\n\\t\\t\\t\\\"DateFirstOpened\\\": \\\"2023-03-15\\\",\\n\\t\\t\\t\\\"Status\\\": \\\"Operational\\\"\\n\\t\\t}\\n\\t],\\n\\t\\\"DiscontinuingService\\\": [\\n\\t\\t{\\n\\t\\t\\t\\\"Id\\\": \\\"0cEBm0000000sd7MAA\\\",\\n\\t\\t\\t\\\"AddressState\\\": \\\"VIC\\\",\\n\\t\\t\\t\\\"AddressId\\\": \\\"a2IBm000000AcwrMAC\\\",\\n\\t\\t\\t\\\"RACSID\\\": \\\"40986\\\",\\n\\t\\t\\t\\\"ProvisionalPlaces\\\": 0,\\n\\t\\t\\t\\\"ACMPSNotified\\\": \\\"No\\\",\\n\\t\\t\\t\\\"Name\\\": \\\"Squad C Residential C1\\\",\\n\\t\\t\\t\\\"IntegrationID\\\": \\\"SRV-16957\\\",\\n\\t\\t\\t\\\"Certified\\\": {\\n\\t\\t\\t\\t\\\"Status\\\": \\\"Certified\\\"\\n\\t\\t\\t},\\n\\t\\t\\t\\\"FullAddress\\\": \\\"33 ERANG DRIVE, MOUNT ELIZA, VIC, 3930\\\",\\n\\t\\t\\t\\\"CareType\\\": \\\"Residential\\\",\\n\\t\\t\\t\\\"Status\\\": \\\"Operational\\\",\\n\\t\\t\\t\\\"DateFirstOpened\\\": \\\"2023-03-15\\\"\\n\\t\\t},\\n\\t\\t{\\n\\t\\t\\t\\\"Id\\\": \\\"0cEBm0000000sBhMAI\\\",\\n\\t\\t\\t\\\"AddressState\\\": \\\"VIC\\\",\\n\\t\\t\\t\\\"AddressId\\\": \\\"a2IBm000000AcwrMAC\\\",\\n\\t\\t\\t\\\"RACSID\\\": \\\"637\\\",\\n\\t\\t\\t\\\"ProvisionalPlaces\\\": 0,\\n\\t\\t\\t\\\"ACMPSNotified\\\": \\\"Yes\\\",\\n\\t\\t\\t\\\"Name\\\": \\\"Squad C Residential A1\\\",\\n\\t\\t\\t\\\"IntegrationID\\\": \\\"SRV-16953\\\",\\n\\t\\t\\t\\\"Certified\\\": {\\n\\t\\t\\t\\t\\\"Status\\\": \\\"Certified\\\"\\n\\t\\t\\t},\\n\\t\\t\\t\\\"FullAddress\\\": \\\"33 ERANG DRIVE, MOUNT ELIZA, VIC, 3930\\\",\\n\\t\\t\\t\\\"CareType\\\": \\\"Residential\\\",\\n\\t\\t\\t\\\"Status\\\": \\\"Operational\\\",\\n\\t\\t\\t\\\"DateFirstOpened\\\": \\\"2023-03-15\\\"\\n\\t\\t}\\n\\t]\\n}\",\"resultVar\":\"\"},\"orderBy\":{\"name\":\"\",\"isReverse\":\"\"},\"contextVariables\":[]}"},"actionIndex":0}],"showSpinner":"false","key":"event-0","displayLabel":"DisplayServiceCombineSummary:data","eventLabel":"pubsub"}],"isRepeatable":true,"Id":"0koBm0000000DV7IAM","OmniUiCardKey":"DisplayServiceCombineSummary/GPMS/1.0","OmniUiCardType":"Parent"};
  export default definition