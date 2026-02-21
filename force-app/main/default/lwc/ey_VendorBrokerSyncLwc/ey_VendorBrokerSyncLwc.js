import { LightningElement, api , wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import brokerVendorSync from '@salesforce/apex/EYI_BrokerVendorSyncLwcController.brokerVendorSync';
import checkProjectMap from '@salesforce/apex/EYI_BrokerVendorSyncLwcController.checkProjectMap';


export default class Ey_VendorBrokerSyncLwc extends LightningElement {
    isSyncButtonDisabled = false;
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


     validateBrokerData(){
        this.isLoading = true;
        this.isGreen = false;
        this.isRed = false;
        this,this.isGreen=false;
        brokerVendorSync({
            recAccId: this.recordId,TestRun:'X'
        })
        .then(result => {
            console.log('result-->'+JSON.stringify(result));
            if(result.type =='S'){
               // this.messageDisplay = result.message;
                 this.isSyncButtonDisabled = false;
                 this.isValidateButtonDisabled = true;
                 console.log('loading--'+this.isLoading);
                 this.isGreen = true;
                 //change
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
                    console.log('error-->'+error);
                    this.isLoading = false;
                });



            }else if(result.type !='S'){
                this.messageDisplay = result.message;
                this.isRed=true;
                this.isLoading = false;
            }   
            this.isMessage = true;
            //this.isLoading = false;
        }).catch(error => {
            console.log('error-->'+error);
            this.isLoading = false;
        });
    }

    synBrokerData(){
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
            console.log('error-->'+error);
            this.isLoading = false;
        });

    }

    connectedCallback(){
        console.log('ID is-->'+this.recordId);
        checkProjectMap({recordId:this.recordId}).
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
        });
    }

    async synBrokerDataCall(event){
        try { 
        console.log('Inside async');
        await this.validateBrokerData();
        console.log('this.messageDisplay-->'+this.messageDisplay);
        if(this.messageDisplay!=null && this.messageDisplay.includes('ok')){
            await this.synBrokerData();
        };
    }
    catch (error) {
            // Catch and log any errors in the process
            console.error('Error during synBrokerDataCall:', error);
        }
        
        
    }

}