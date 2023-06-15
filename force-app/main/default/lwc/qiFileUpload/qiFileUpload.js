import { LightningElement , wire} from 'lwc';

//import message service features 
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';


export default class QIReportingPeriodHeader extends NavigationMixin(LightningElement){
    prvPage;
    provider;
    
    //get qiSummaryId
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.prvPage = currentPageReference.state?.prvPage;
            this.provider = currentPageReference.state?.provider;
        }
    }

    /**
     * Navigate to a page
     */
    handleBack(){
        if (this.prvPage){
            this.navigateToPage(this.prvPage , null , null);
        } else {
            window.history.back();
        }
    }

    /**
     * Navigate to a specific community page and send QISummary Id.
     * @param {*} pageName - Page to navigate to
     */
    navigateToPage(pageName , currentPage , provider) {
        if (pageName) {
            this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: pageName
                    },
                    state: {
                        prvPage: currentPage,
                        provider: provider
                    }
                },
                true
            );
        }
    }
}