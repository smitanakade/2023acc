import { LightningElement, api } from 'lwc';
import cometd from "@salesforce/resourceUrl/cometd";
import { loadScript } from "lightning/platformResourceLoader";
import getSessionId from '@salesforce/apex/OrgSwitcher.getSessionId';
import { NavigationMixin } from "lightning/navigation";
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from "lightning/flowSupport";


export default class EmpApiLWC extends NavigationMixin(LightningElement) {
    asyncEvent;
    channel = 'OrganisationSwitcherPlatformEvent__e';
    @api userId;
    @api acrId;
    @api loginFlow;
    libInitialized = false;
    sessionId;
    error;
    connectedCallback(){        
        this.getSessionId();
    }
    getSessionId(){
        getSessionId()
        .then((data) => {
            this.sessionId = data;
            this.error = undefined;
            loadScript(this, cometd)
            .then(() => {
                this.initializecometd();
            });
        }).catch(() => {
            this.error = 'Failed to get session ID';
        });
    }
    initializecometd() {
        if (this.libInitialized) {
            return;
        }
        this.libInitialized = true;
        const lwcThisContext = this;
        const timeoutDelay = 20000;
        let cometdlib = new window.org.cometd.CometD();
        cometdlib.configure({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/53.0/',
            requestHeaders: { Authorization: 'OAuth ' + this.sessionId},
            appendMessageTypeToURL : false,
            logLevel: 'debug'
        });
        setTimeout(() => {
            if(this.loginFlow){
                this.handleFlowFinished();
            }
            else {
                this.handleRedirect();
            }
            
        }, timeoutDelay);
        cometdlib.websocketEnabled = false;
        cometdlib.handshake(function(status) {
            if (status.successful) {
                cometdlib.subscribe('/event/'+ lwcThisContext.channel, function(message){
                    const userIdLen = 15;
                    const delay = 200;
                    const eventPublishedBy = message.data.payload.CreatedById.slice(0,userIdLen);                    
                    if(eventPublishedBy === lwcThisContext.userId && 
                        message.data.payload.accountContactRelationId__c === lwcThisContext.acrId){
                        if (message.data.payload.PermissionChangeSuccessful__c){
                            if (lwcThisContext.loginFlow) {
                                setTimeout(() => {
                                    lwcThisContext.handleFlowFinished();
                                }, delay);
                            } else {
                                setTimeout(() => {
                                    lwcThisContext.handleRedirect();
                                }, delay);
                                // Adding small delay to ensure the active tab event is handled first
                            }
                        }else {
                            lwcThisContext.handleError();
                        }
                    }
                });
            } else {
                lwcThisContext.handleError(); 
            }
        });
    }
    handleRedirect() {
        const asyncDelay = 1000;

        this.asyncEvent = setTimeout(() => {
            window.location = `${window.location.origin}/serviceproviderportal/s/`;
        }, asyncDelay);      
    }
    handleFlowFinished() {
        this.error = 'Click finish to complete login';
    }
    handleError (){
        this.error = 'Attempt to switch failed. Please Try again later';
    }
}