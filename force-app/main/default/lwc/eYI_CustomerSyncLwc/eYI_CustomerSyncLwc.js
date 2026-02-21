import { LightningElement, api , wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import CustomerMasterSync from '@salesforce/apex/EYI_CustomerMasterSyncLwcController.customerMasterSync';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Opportunity.EYI_SAP_Customer_Number__c'];

export default class EYI_CustomerSyncLwc extends  NavigationMixin(LightningElement) {
    isSyncButtonDisabled = false;
    isPaymentSyncDisabled = false;
    isValidateButtonDisabled = false;
    messageDisplay;
    @api recordId;
    isMessage = false;
    isRed=false;
    isGreen = false;
    isLoading = false;
    isOrange = false;
    warningDisplay;


    @wire(CurrentPageReference)
        setPageReference(currentPageReference) {
            // Retrieve the query parameters from the current page
            if (currentPageReference) {
                this.currentUrl = window.location.href;
                console.log('this.currentUrl-->'+this.currentUrl);
                this.recordId = currentPageReference.state.recordId;
            }
        }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredOpportunity({ data, error }) {
        if (data) {
            if(data.fields.EYI_SAP_Customer_Number__c.value==null || data.fields.EYI_SAP_Customer_Number__c.value==''){
                this.isSyncButtonDisabled = false;
                this.isPaymentSyncDisabled = true;
            }else{
                this.isSyncButtonDisabled = true;
                this.isPaymentSyncDisabled = false;
            }
        } else if (error) {
            console.error('Error loading opportunity', error);
        }
    }

      validateCustomerData(){
        this.isLoading = true;
        this.isGreen = false;
        this.isRed = false;
        this,this.isGreen=false;
        CustomerMasterSync({
            recordId: this.recordId, TestRun:'X'
        })
        .then(result => {
            console.log('result-->'+JSON.stringify(result));
           if (result.type.toLowerCase().includes('s')) {
               // this.messageDisplay = result.message;
                 this.isSyncButtonDisabled = false;
                 this.isValidateButtonDisabled = true;
                 console.log('loading--'+this.isLoading);
                 this.isGreen = true;
                 //change
                 this.isLoading = true;
                this.isGreen = false;
                this.isRed = false;
                CustomerMasterSync({
                    recordId: this.recordId, TestRun:''
                })
                .then(result => {
                    console.log('result-->'+JSON.stringify(result));
                    if (result.type.toLowerCase().includes('s')) {
                        this.messageDisplay = result.message;
                        this.isSyncButtonDisabled = true;
                        this.isValidateButtonDisabled = true;
                        
                        this.isGreen = true;

                    }else if (!result.type.toLowerCase().includes('s')) {
                        this.messageDisplay = result.message;
                        this.isRed=true;
                    }   
                    this.isMessage = true;
                    this.isLoading = false;
                }).catch(error => {
                    console.log('error-->'+JSON.stringify(error));
                    this.isLoading = false;
                });



            }else if (!result.type.toLowerCase().includes('s')) {
                this.messageDisplay = result.message;
                this.isRed=true;
                this.isLoading = false;
            }   
            this.isMessage = true;
            //this.isLoading = false;
        }).catch(error => {
            console.log('error-->'+JSON.stringify(error));
            this.isLoading = false;
        });
    }

    synCustomerData(){
        this.isLoading = true;
        this.isGreen = false;
        this.isRed = false;
        brokerVendorSync({
            recAccId: this.recordId,TestRun:''
        })
        .then(result => {
            console.log('result-->'+JSON.stringify(result));
            if(result.type =='S'){
                this.messageDisplay = result.message;
                 this.isSyncButtonDisabled = true;
                 this.isValidateButtonDisabled = true;
                 
                 this.isGreen = true;

            }else if(result.type !='S'){
                this.messageDisplay = result.message;
                this.isRed=true;
            }   
            this.isMessage = true;
            this.isLoading = false;
        }).catch(error => {
            console.log('error-->'+JSON.stringify(error));
            this.isLoading = false;
        });

    }
     connectedCallback(){
        console.log('ID is-->'+this.recordId);
        /*checkProjectMap({recordId:this.recordId}).
        then(result => {
            console.log('result-->'+JSON.stringify(result));
            if(result){
                if(result.type!=null && result.type =='ERROR') {
                    this.isRed=true;
                    this.isSyncButtonDisabled = true;
                
                }
                if(result.projectMapMsg!=null) this.messageDisplay=result.projectMapMsg;
                if(result.bankMapMsg!=null){
                    this.isOrange = true;
                    this.warningDisplay=result.bankMapMsg;
                }
            }

        })
        .catch(error => {
            console.log('error-->'+error);
        });*/
    }

    async synCustomerDataCall(event){
        try { 
        console.log('Inside async');
        await this.validateBrokerData();
        console.log('this.messageDisplay-->'+this.messageDisplay);
        if(this.messageDisplay!=null && this.messageDisplay.includes('ok')){
            await this.synCustomerData();
        };
    }
    catch (error) {
            // Catch and log any errors in the process
            console.error('Error during synCustomerDataCall:', error);
        }
    }
    navigateToPaymentReceipt() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Payment_Receipt_Creation' // Use the API name of the Lightning Tab you created
            },
            state: {
                c__recordId: this.recordId // Pass parameters if needed
            }
        });
    }

}