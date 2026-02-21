import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/EYI_Brokerage__c.Stages__c';
import ID_FIELD from '@salesforce/schema/EYI_Brokerage__c.Id';

export default class BrokerageFileUpload extends LightningElement {
    @api recordId;

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('Uploaded file:', uploadedFiles[0].name);

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = 'Invoice Received';

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                console.log('Status updated to "Invoice Received"');
                // Optionally show toast
            })
            .catch(error => {
                console.error('Error updating status:', error);
            });
    }
}