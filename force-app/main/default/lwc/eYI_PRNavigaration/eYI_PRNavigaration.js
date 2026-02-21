import { LightningElement,wire,track,api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['EYI_Payment_Receipt__c.EYI_Opportunity__c'];

export default class EYI_PRNavigaration extends  NavigationMixin(LightningElement) {
    @api recordId;
    opptyId;           

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
    wiredReceiptRecord({ error, data }) {
        if (data) {
            this.opptyId = data.fields.EYI_Opportunity__c.value;
            console.log('  data.fields ==>  ', data.fields);
            console.log('  data.fields.value ==>  ', data.fields.EYI_Opportunity__c.value);
            console.log('Opportunity Id:', this.opptyId);
            this.navigateToPaymentReceipt(); // Navigate only after both IDs are ready
        } else if (error) {
            console.error('Error fetching Opportunity Id:', error);
        }
    }

    navigateToPaymentReceipt() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Payment_Receipt_Creation'
            },
            state: {
                c__receiptId: this.recordId,   // Receipt Id
                c__recordId: this.opptyId      // Opportunity Id
            }
        });
    }
}