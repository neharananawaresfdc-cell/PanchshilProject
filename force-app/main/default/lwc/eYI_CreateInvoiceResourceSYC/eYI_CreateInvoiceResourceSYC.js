import { LightningElement,api,wire,track } from 'lwc';
import buildRequestBodyFromAccount from '@salesforce/apex/EYI_CreateInvoiceResource.buildRequestBodyFromAccount';
import validateInvoiceSync from '@salesforce/apex/EYI_CreateInvoiceResource.validateInvoiceSync';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import PO_NUMBER_FIELD from '@salesforce/schema/EYI_Brokerage__c.EYI_SAP_PO_Number__c';
import { getRecord } from 'lightning/uiRecordApi';


const FIELDS = [PO_NUMBER_FIELD];

export default class EYI_CreateInvoiceResourceSYC extends LightningElement {
@api message;
@api recordId; // Available when LWC is opened as Quick Action
@track syncButtonVisibility= false;
messageDisplay;
isMessage = false;
isRed=false;
isGreen = false;
isLoading = false;
warningDisplay;
poNumber;
isSyncDisabled = false;

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef && pageRef.state) {
            this.recordId = pageRef.state.recordId || pageRef.state.c__recordId;
            console.log('recordId from pageRef:', this.recordId);
            this.validateInvoiceData();
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.poNumber = data.fields[PO_NUMBER_FIELD.fieldApiName].value;
            this.isSyncDisabled = this.poNumber !== null && this.poNumber !== '';
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }

    validateInvoiceData(){
        this.isLoading = true;
        this.isGreen = false;
        this.isRed = false;
        this.isGreen=false;
        validateInvoiceSync({
            recInvoiceId: this.recordId
        })
        .then(result => {
            console.log('result-->'+JSON.stringify(result));
                    if (result.type.toLowerCase().includes('s')) {
                        console.log('Inside If');
                        
                        this.messageDisplay = result.message;
                        this.syncButtonVisibility = true;
                        this.isSyncDisabled = false;
                        this.isGreen = true;

                    }else if (!result.type.toLowerCase().includes('s')) {
                        console.log('Inside else');
                        this.messageDisplay = result.message;
                        this.isRed=true;
                    }   
                    this.isMessage = true;
                    this.isLoading = false;
                    console.log('this.syncButtonVisibility: '+this.syncButtonVisibility);
                    
        })
        .catch(error => {
            console.log('error-->'+error);
            this.isLoading = false;
        });
    }

    

    connectedCallback() {
        // Automatically invoke method when quick action opens
       
        //this.recordId = this.currentPageReference.state.c__brokerageId;
        console.log('recordIDCRS2',this.recordId);
        
    }
    handleCallInvoiceAPI() {
        this.isLoading = true;
        this.isGreen = false;
        this.isRed = false;
        this.isGreen=false;
        // Call the Apex method
        buildRequestBodyFromAccount({ recordId: this.recordId })
            .then(result => {
                console.log('API Request Body:', result);
                if (result.type.toLowerCase().includes('s')) {
                    this.messageDisplay = result.message;
                    this.syncButtonVisibility = true;
                    this.isSyncDisabled = true;
                    this.isGreen = true;

                }else if (!result.type.toLowerCase().includes('s')) {
                    this.messageDisplay = result.message;
                    this.isRed=true;
                }   
                this.isMessage = true;
                this.isLoading = false;
                // Optional: show success toast
               // this.showToast('Success', 'Invoice created successfully', 'success');
            })
            .catch(error => {
                console.error('Error calling invoice API:', error);
                this.isLoading = false;
                // Optional: show error toast
               // this.showToast('Error', error?.body?.message || error.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}