import { LightningElement, api , wire, track} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import BookingsSync from '@salesforce/apex/EYI_SAPBookingsSyncLwcController.BookingsSync';
import validateBookingDetails from '@salesforce/apex/EYI_SAPBookingsSyncLwcController.validateBookingDetails';
// added by Mrinal to store the error message for already synced records
//import syncMessageLabel from '@salesforce/label/c.EYI_SAP_is_synced_message';

export default class EYI_BookingSAPSync extends LightningElement {
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
        BookingsSync({
            recordId: this.recordId
        })
.then(result => {
            console.log('result-->'+JSON.stringify(result));
            if (result != undefined && result.type != undefined && result.type.toLowerCase().includes('s') && !this.isSync) {
                 this.isLoading = false;
                 this.messageDisplay = result.message;
                 this.isSyncButtonDisabled = true;
                 this.isValidateButtonDisabled = true;
                 console.log('loading--'+this.isLoading);
                 this.isGreen = true;
                 //change
                 
                //this.isGreen = false;
                /*BookingsSync({
                    recordId: this.recordId
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
                    console.log('error-->'+JSON.stringify(error) );
                    this.isLoading = false;
                });*/



            }else if (result != undefined && result.type != undefined && !result.type.toLowerCase().includes('S')) {
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
     connectedCallback(){
        console.log('ID is-->'+this.recordId);
        this.validateBookingDetails();
    }

    validateBookingDetails(){
        validateBookingDetails({
            recordId: this.recordId
        })
        .then(result => {
            console.log('result-->'+JSON.stringify(result));
            if(result){
                if(result.type!=null && result.type =='ERROR') {
                    this.isRed=true;
                    this.isSyncButtonDisabled = true;
                
                }
                if(result.projectMapMsg!=null) this.messageDisplay=result.projectMapMsg;
                // if(result.bankMapMsg!=null){
                //     this.isOrange = true;
                //     this.warningDisplay=result.bankMapMsg;
                // }
            }
        })
        .catch(error => {
            console.log('error-->'+error);
        })

    }

}