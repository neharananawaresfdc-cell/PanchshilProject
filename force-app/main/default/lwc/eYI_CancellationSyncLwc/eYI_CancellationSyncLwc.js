import { LightningElement,api,track,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import CancellationMasterSync from '@salesforce/apex/EYI_CaseCancellationMasterSyncController.CancellationMasterSync'; //EYI_CancellationMasterSyncLwcController

export default class EYI_CancellationSyncLwc extends LightningElement {

    @api recordId;
    isSyncButtonDisabled = false;
    isValidateButtonDisabled = false;
    messageDisplay;
    isMessage = false;
    isRed=false;
    isGreen = false;
    isLoading = false;
    isOrange = false;
    warningDisplay;

    connectedCallback(){
        //console.log('this.record Id : '+this.recordId);
    }

    @wire(CurrentPageReference)
        getPageReference(pageRef) {
            if (pageRef && pageRef.state) {
                this.recordId = pageRef.state.recordId || pageRef.state.c__recordId;
                console.log('recordId from pageRef:', this.recordId);
            }
        }

    validateCancellationData(){
        console.log('inside validateCancellationData');
        this.isLoading = true;
        CancellationMasterSync({
            recordId: this.recordId
        })
        .then(result => {
            console.log('result-->'+JSON.stringify(result));
                    if (result.message.toLowerCase().includes('successfully')) {
                        this.messageDisplay = result.message;
                        this.isSyncButtonDisabled = true;
                        this.isValidateButtonDisabled = true;
                        
                        this.isGreen = true;

                    }else if (!result.message.toLowerCase().includes('successfully')) {
                        this.messageDisplay = result.message;
                        this.isRed=true;
                    }   
                    this.isMessage = true;
                    this.isLoading = false;

        })
        .catch(error => {
            console.log('error-->'+error);
            this.isLoading = false;
        });

        
    }

}