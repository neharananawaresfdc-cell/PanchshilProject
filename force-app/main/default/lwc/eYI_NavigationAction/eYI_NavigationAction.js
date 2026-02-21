import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getPaymentReceiptDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.getPaymentReceiptDetails';
import checkCaseStatus from '@salesforce/apex/EYI_SAP_CancellationPaymentController.checkCaseStatus';
import cancellationRecStartWith from '@salesforce/label/c.Cancellation_RecordId';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

const OPPORTUNITY_FIELD = 'Case.EYI_Opportunity__c';
const FIELDS = [OPPORTUNITY_FIELD];

export default class EYI_NavigationAction extends NavigationMixin(LightningElement) {
    @api recordId;
    showErrorScreen = false;
    showCaseErrScreen = false;
    opportunityId;
    errorMessage
    

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef && pageRef.state) {
            this.recordId = pageRef.state.recordId || pageRef.state.c__recordId;
            console.log('recordId from pageRef:', this.recordId);
            this.checkPaymentDetails();
            /*if (this.recordId && this.recordId.startsWith(cancellationRecStartWith)) {
                console.log('Received Cancellation Id');
                this.checkCaseStatus()
                //this.navigateToTabInNewWindow(this.recordId);
            } else if (this.recordId && this.recordId.startsWith('006')) {
                console.log('Received Opportunity Id');
                this.checkPaymentDetails();
            }*/
        }
    }

    
    checkCaseStatus() {
        checkCaseStatus({ recordId: this.recordId })
            .then(result => {
                console.log('Apex Result:', result);
                if (result.type === 's') {
                    this.navigateToTabInNewWindow(this.recordId);
                } else {
                    this.errorMessage = result.message;
                    this.showCaseErrScreen = true;
                }
            })
            .catch(error => {
                console.error('Error calling Apex:', error);
                this.errorMessage = 'Unexpected error occurred';
                this.showCaseErrScreen = true;
            });
    }

    checkPaymentDetails() {
        getPaymentReceiptDetails({ recordId: this.recordId })
            .then(result => {
                console.log('getPaymentReceiptDetails result:', result);
                if (result === true) {
                    this.showErrorScreen = true;
                } else {
                    this.checkCaseStatus();
                }
            })
            .catch(error => {
                console.error('Error in fetching Payment Receipt Details:', error);
            });
    }

    navigateToTabInNewWindow(recordIdToPass) {
        if (!recordIdToPass) {
            console.error('recordId is undefined');
            return;
        }

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Cancellation_Case' //Payment_Cancellation_Details_Case
            },
            state: {
                c__recordId: recordIdToPass
            }
        }).then(url => {
            window.open(url, '_blank');
            this.dispatchEvent(new CloseActionScreenEvent());
        }).catch(error => {
            console.error('Error generating URL:', error);
        });
    }
}