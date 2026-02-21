import { LightningElement, api , wire,track} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import CarParkingSync from '@salesforce/apex/EYI_CarParkingSyncLwcController.CarParkingSync';
import getSyncValue from '@salesforce/apex/EYI_PricingCallout.getSyncValue';
// added by Mrinal to store the error message for already synced records
import syncMessageLabel from '@salesforce/label/c.EYI_SAP_is_synced_message';
export default class EYI_CarParkingSyncLwc extends LightningElement {
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
    @track syncedMessage = syncMessageLabel;
    @track isSync = false;

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
        CarParkingSync({
            recordId: this.recordId
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
                CarParkingSync({
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
                    console.log('error-->'+error);
                    this.isLoading = false;
                });



            }else if (!result.type.toLowerCase().includes('S')) {
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
        @wire(getSyncValue, { projectId: '$recordId', lwc: 'Car Park' })
    getSyncValue({ error, data }) {
        if (data !== undefined) {
            this.isSync = data;
            this.isSyncButtonDisabled = data;
        } else if (error) {
            console.error('Error fetching flag:', error);
        }
    }

}