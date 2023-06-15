import { LightningElement,wire } from 'lwc';
import getStarRatingHistory from '@salesforce/apex/ExtractCalculationReportController.getStarRatingHistory';
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import jszip from "@salesforce/resourceUrl/jszip";


const FILE_NAME = 'Calculation Extract.zip';
const HEADER = {"SF_Service_Id__r.Account.Integration_ID__c":"Provider Id",
"SF_Service_Id__r.Account.Name":"Provider Name",
"SF_Service_Id__r.Integration_ID__c":"Service ID",
"SF_Service_Id__r.Name":"Service Name",
"dateOfExtract":"Date of extract",
"STAR_Rating_Calculation__c":"Overall Star Rating",
"Service_Compliance_Id__r.Service_Compliance_Rating__c":"Service Compliance Rating",
"Service_Compliance_Id__r.Regulatory_Decision__r.Name" : "Regulatory Id",
"Service_Compliance_Id__r.Regulatory_Decision__r.ViolationType.Name":"Decision Type",
"Service_Compliance_Id__r.Regulatory_Decision__r.Service_Compliance_Rating_Effect__c":"SCR effect",
"Service_Compliance_Id__r.Regulatory_Decision__r.Date_Decision_Applied__c":"Start date",
"Service_Compliance_Id__r.Regulatory_Decision__r.Date_Decision_Ends__c":"End date",
"Quality_Indicator_Id__r.Quality_Indicator_Rating__c":"Quality Measures rating",
"Quality_Indicator_Id__r.Risk_Adjusted_PI_Level2__c":"% Stage 2 PI - risk adj",
"Quality_Indicator_Id__r.QI_Sector_Avg_PI_S2__c":"% Stage 2 PI - nat avg risk adj",
"Quality_Indicator_Id__r.Risk_Adjusted_PI_Level3__c":"% Stage 3 PI - risk adj",
"Quality_Indicator_Id__r.QI_Sector_Avg_PI_S3__c":"% Stage 3 PI - nat avg risk adj",
"Quality_Indicator_Id__r.Risk_Adjusted_PI_Level4__c":"% Stage 4 PI - risk adj",
"Quality_Indicator_Id__r.QI_Sector_Avg_PI_S4__c":"% Stage 4 PI - nat avg risk adj",
"Quality_Indicator_Id__r.Risk_Adjusted_DT_PI__c":"% Deep tissue PI - risk adj",
"Quality_Indicator_Id__r.QI_Sector_Avg_PI_DT__c":"% Deep Tissue PI - nat avg risk adj",
"Quality_Indicator_Id__r.Risk_Adjusted_Unstageable_PI__c":"% Unstageable PI - risk adj",
"Quality_Indicator_Id__r.QI_Sector_Avg_PI_Unstageable__c":"% Unstageable PI - nat avg risk adj",
"Quality_Indicator_Id__r.QI_Observed_Physical_Restraint__c":"% physically restrained",
"Quality_Indicator_Id__r.PI_Compare_with_National_Average__c":"% physically restrained - nat avg",
"Quality_Indicator_Id__r.Risk_Adjusted_SUWL__c":"% unplanned weight loss - risk adj",
"Quality_Indicator_Id__r.UWL_Compare_with_National_Average__c":"% unplanned weight loss - nat avg risk adj",
"Quality_Indicator_Id__r.Risk_Adjusted_Falls_with_injury__c":"% falls - risk adj",
"Quality_Indicator_Id__r.FALLS_Compare_with_National_Average__c":"% falls - nat avg risk adj",
"Quality_Indicator_Id__r.Risk_Adjusted_Falls_with_Major_injury__c":"% falls - major injury - risk adj",
"Quality_Indicator_Id__r.FMI_Compare_with_National_Average__c":"% falls - major injury - nat avg risk adj",
"Quality_Indicator_Id__r.QI_Observed_Polypharmacy__c":"% 9 or more meds",
"Quality_Indicator_Id__r.Pres_Med_Compare_with_National_Average__c":"% 9 or more meds - nat avg",
"Quality_Indicator_Id__r.QI_Observed_APSY__c":"% antipsychotics (w/o diagnosis)",
"Quality_Indicator_Id__r.Antipsy_Compare_with_National_Average__c":"% antipsychotics (w/o diagnosis) - nat avg",
"Consumer_Experience_Id__r.Consumer_Experience_Rating__c":"Residents Experience rating",
"Consumer_Experience_Id__r.Food_Always__c":"Survey Q1 - Always",
"Consumer_Experience_Id__r.Food_Most_of_the_time__c":"Survey Q1 - Most",
"Consumer_Experience_Id__r.Food_Some_of_the_time__c":"Survey Q1 - Some",
"Consumer_Experience_Id__r.Food_Never__c":"Survey Q1 - None ",
"Consumer_Experience_Id__r.Safety_Always__c":"Survey Q2 - Always",
"Consumer_Experience_Id__r.Safety_Most_of_the_time__c":"Survey Q2 - Most",
"Consumer_Experience_Id__r.Safety_Some_of_the_time__c":"Survey Q2 - Some",
"Consumer_Experience_Id__r.Safety_Never__c":"Survey Q2 - None ",
"Consumer_Experience_Id__r.Operation_Always__c":"Survey Q3 - Always",
"Consumer_Experience_Id__r.Operation_Most_of_the_time__c":"Survey Q3 - Most",
"Consumer_Experience_Id__r.Operation_Some_of_the_time__c":"Survey Q3 - Some",
"Consumer_Experience_Id__r.Operation_Never__c":"Survey Q3 - None ",
"Consumer_Experience_Id__r.Care_Need_Always__c":"Survey Q4 - Always",
"Consumer_Experience_Id__r.Care_Need_Most_of_the_time__c":"Survey Q4 - Most",
"Consumer_Experience_Id__r.Care_Need_Some_of_the_time__c":"Survey Q4 - Some",
"Consumer_Experience_Id__r.Care_Need_Never__c":"Survey Q4 - None ",
"Consumer_Experience_Id__r.Competent_Always__c":"Survey Q5 - Always",
"Consumer_Experience_Id__r.Competent_Most_of_the_time__c":"Survey Q5 - Most",
"Consumer_Experience_Id__r.Competent_Some_of_the_time__c":"Survey Q5 - Some",
"Consumer_Experience_Id__r.Competent_Never__c":"Survey Q5 - None ",
"Consumer_Experience_Id__r.Independent_Always__c":"Survey Q6 - Always",
"Consumer_Experience_Id__r.Independent_Most_of_the_time__c":"Survey Q6 - Most",
"Consumer_Experience_Id__r.Independent_Some_of_the_time__c":"Survey Q6 - Some",
"Consumer_Experience_Id__r.Independent_Never__c":"Survey Q6 - None ",
"Consumer_Experience_Id__r.Explain_Always__c":"Survey Q7 - Always",
"Consumer_Experience_Id__r.Explain_Most_of_the_time__c":"Survey Q7 - Most",
"Consumer_Experience_Id__r.Explain_Some_of_the_time__c":"Survey Q7 - Some",
"Consumer_Experience_Id__r.Explain_Never__c":"Survey Q7 - None ",
"Consumer_Experience_Id__r.Respect_Always__c":"Survey Q8 - Always",
"Consumer_Experience_Id__r.Respect_Most_of_the_time__c":"Survey Q8 - Most",
"Consumer_Experience_Id__r.Respect_Some_of_the_time__c":"Survey Q8 - Some",
"Consumer_Experience_Id__r.Respect_Never__c":"Survey Q8 - None ",
"Consumer_Experience_Id__r.Follow_Up_Always__c":"Survey Q9 - Always",
"Consumer_Experience_Id__r.Follow_Up_Most_of_the_time__c":"Survey Q9 - Most",
"Consumer_Experience_Id__r.Follow_Up_Some_of_the_time__c":"Survey Q9 - Some",
"Consumer_Experience_Id__r.Follow_Up_Never__c":"Survey Q9 - None ",
"Consumer_Experience_Id__r.Caring_Always__c":"Survey Q10 - Always",
"Consumer_Experience_Id__r.Caring_Most_of_the_time__c":"Survey Q10 - Most",
"Consumer_Experience_Id__r.Caring_Some_of_the_time__c":"Survey Q10 - Some",
"Consumer_Experience_Id__r.Caring_Never__c":"Survey Q10 - None ",
"Consumer_Experience_Id__r.Voice_Always__c":"Survey Q11 - Always",
"Consumer_Experience_Id__r.Voice_Most_of_the_time__c":"Survey Q11 - Most",
"Consumer_Experience_Id__r.Voice_Some_of_the_time__c":"Survey Q11 - Some",
"Consumer_Experience_Id__r.Voice_Never__c":"Survey Q11 - None ",
"Consumer_Experience_Id__r.Home_Always__c":"Survey Q12 - Always",
"Consumer_Experience_Id__r.Home_Most_of_the_time__c":"Survey Q12 - Most",
"Consumer_Experience_Id__r.Home_Some_of_the_time__c":"Survey Q12 - Some",
"Consumer_Experience_Id__r.Home_Never__c":"Survey Q12 - None ",
"Care_Minutes_Id__r.Care_Minutes_Rating__c":"Staffing Rating",
"Care_Minutes_Id__r.Registered_Nurse_Care_Minutes_Target__c":"Total RN - Target",
"Care_Minutes_Id__r.Actual_Registered_Nursing_Minutes__c":"Total RN - Actual",
"Care_Minutes_Id__r.Total_Care_Minutes_Target__c":"Total staffing - Target",
"Care_Minutes_Id__r.Actual_Care_Minutes__c":"Total staffing - Actual"};

export default class ExtractCalculationReport extends LightningElement {

    data;
    error;
    isLoading = true;

    jsLibInitialized = false;
    connectedCallback() {
        if (!this.jsLibInitialized) {
            loadScript(this, jszip).then(() => {
                this.jsLibInitialized = true;
            });
        }
    }

    get providerCount (){
        if(!this.data){
            return 0;
        }

        const serviceIds = this.data.map(x => x.SF_Service_Id__r.Integration_ID__c);
        const serviceIdsSet = new Set(serviceIds);
        return serviceIdsSet.size;
    }

    get downloadDisabled(){
        return (this.providerCount === 0 || this.isLoading);
    }

    @wire(getStarRatingHistory)
    wiredRecords({error, data}) {
        if (data) {
            this.data = JSON.parse(JSON.stringify(data));
            this.isLoading = false;
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
        else{
            this.error = undefined;
        }
    }

    handleDownload(){

        this.isLoading = true;
        try{

        const today = new Date();
        const formatDate = `${today.getDate()}${today.getMonth() + 1}${today.getFullYear()}`;
        const dateOfExtract = `${today.getDate()}/${today.getMonth() + 1}/${today.getFullYear()}`;

        const serviceIds = this.data.map(x => x.SF_Service_Id__r.Integration_ID__c);
        const serviceIdsSet = new Set(serviceIds);

        this.data.map(x => {
            x.dateOfExtract = dateOfExtract;
        });

        let csvDataMap = {};
        for(const key of serviceIdsSet){
            const providerData = this.data.filter(x => x.SF_Service_Id__r.Integration_ID__c === key);
            const csvContent  = this.convertToCSV(providerData);
            csvDataMap[`${providerData[0].SF_Service_Id__r.Integration_ID__c}_${providerData[0].SF_Service_Id__r.Name}_${formatDate}`] =  csvContent;
        }
        this.downloandZipFile(csvDataMap);
        }
        catch(e){
            this.isLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error in Downloading',
                message: `Unexpected error occured in downloading, please try again later.`,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
    }


    convertToCSV(objArray){
        const columnDelimiter = ',';
        const lineDelimiter = '\r\n';
        const actualHeaderKey = Object.keys(HEADER);
        const headerToShow = Object.values(HEADER) ;
        let str = '';
        str+=headerToShow.join(columnDelimiter) ;
        str+=lineDelimiter;
        const data = typeof objArray !=='object' ? JSON.parse(objArray):objArray;

        data.forEach(obj=>{
            let line = '';
            let firstItem = true;
            actualHeaderKey.forEach(key=>{
                if(!firstItem){
                    line += columnDelimiter;
                }
                const strItem = this.getFieldValue(obj, key);
                line += (strItem !== undefined && strItem !== null ? strItem : '');
                firstItem = false;
            });
            str+=line+lineDelimiter;
        });
        return str;
    }

    getFieldValue(obj, key){
        if(key.includes('.')){
            const arr =  key.split('.');
            return this.getValue(arr,obj);
        }else{
            return obj[key];
        }
    }
    getValue(arr, obj) {
        const [first, ...rest] = arr;
        return typeof(obj[first]) === "object" ? this.getValue(rest, obj[first]) : obj[first];
    }

    downloandZipFile(csvDataMap){
        const lwcThisContext = this;
        const zip = new JSZip();

        Object.keys(csvDataMap).forEach(key=>{
            zip.file( `${key}.csv`, csvDataMap[key]);
        });

        zip.generateAsync({
            type: "blob"
        }).then(function (content) {
            const a = document.createElement("a");
            a.href = URL.createObjectURL(content);
            a.download = FILE_NAME;
            a.click();

            lwcThisContext.isLoading = false;
            const evt = new ShowToastEvent({
                title: 'File Download started',
                message: `${FILE_NAME} is downloading in progress, open the file once it is downloaded in the local machine. `,
                variant: 'success',
            });
            lwcThisContext.dispatchEvent(evt);
        });
    }

}