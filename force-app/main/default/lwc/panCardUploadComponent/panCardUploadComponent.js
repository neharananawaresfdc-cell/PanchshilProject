import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveDocument from '@salesforce/apex/DocumentController.saveDocument';
import { publish, MessageContext } from 'lightning/messageService';
import REFRESHCC from '@salesforce/messageChannel/RefreshComponentChannel__c';
import { getRecord } from 'lightning/uiRecordApi';
import CUSTOMER_NUMBER_FIELD from '@salesforce/schema/Opportunity.EYI_SAP_Customer_Number__c';
import CUSTOMER_NAME_FIELD from '@salesforce/schema/Opportunity.Name';

export default class PanCardUploadComponent extends LightningElement {
    @api recordId;
    @track fileContent;
    @track fileName;
    @track isFileUploaded = false;
    @track customerNumber;
    @track customerName;
    @track isindex2Uploaded = false;
    @track isRegiFileUploaded = false;
    @track regFileContent;
    @track regFileName;
    @track indexFileContent;
    @track indexFileName;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: [CUSTOMER_NUMBER_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.customerNumber = data.fields.EYI_SAP_Customer_Number__c.value;
        } else if (error) {
            console.error('Error fetching customer number:', error);
            this.customerNumber = 'Unknown Customer';
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: [CUSTOMER_NAME_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.customerName = data.fields.Name.value;
            console.log('Customer Name',this.customerName);
        } else if (error) {
            console.error('Error fetching customer Name:', error);
            this.customerNumber = 'Unknown Customer';
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: [CUSTOMER_NAME_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.customerName = data.fields.Name.value;
            console.log('Customer Name',this.customerName);
        } else if (error) {
            console.error('Error fetching customer Name:', error);
            this.customerNumber = 'Unknown Customer';
        }
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.fileContent = reader.result.split(',')[1];
                const extension = file.name.split('.').pop();
                const currentDate = new Date().toISOString().slice(0, 10).replace(/-/g, ''); // YYYYMMDD
                this.fileName = `PANCARD_${this.customerName}.${extension}`;
                this.isFileUploaded = true;
            };
            reader.readAsDataURL(file);
        }
    }
    handleindex2Change(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.indexFileContent = reader.result.split(',')[1];
                const extension = file.name.split('.').pop();
                const currentDate = new Date().toISOString().slice(0, 10).replace(/-/g, ''); // YYYYMMDD
                this.indexFileName = `INDEX2_${this.customerName}.${extension}`;
                this.isindex2Uploaded = true;
            };
            reader.readAsDataURL(file);
        }
    }
    handleRegiFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.regFileContent = reader.result.split(',')[1];
                const extension = file.name.split('.').pop();
                const currentDate = new Date().toISOString().slice(0, 10).replace(/-/g, ''); // YYYYMMDD
                this.regFileName = `REGISTRATION_${this.customerName}.${extension}`;
                this.isRegiFileUploaded = true;
            };
            reader.readAsDataURL(file);
        }
    }

    handleSave() {
        if (!this.isFileUploaded && !this.isindex2Uploaded && !this.isRegiFileUploaded) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please upload a file before saving.',
                    variant: 'error'
                })
            );
            return;
        }
        if(this.isFileUploaded){
            saveDocument({ fileContent: this.fileContent, fileName: this.fileName, recordId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'PAN Card uploaded successfully!',
                        variant: 'success'
                    })
                );

                publish(this.messageContext, REFRESHCC, { message: 'refresh' });
                this.resetForm();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
        if(this.isindex2Uploaded){
            saveDocument({ fileContent: this.indexFileContent, fileName: this.indexFileName, recordId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Index 2 uploaded successfully!',
                        variant: 'success'
                    })
                );

                publish(this.messageContext, REFRESHCC, { message: 'refresh' });
                this.resetForm();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
        if(this.isRegiFileUploaded){
            saveDocument({ fileContent: this.regFileContent, fileName: this.regFileName, recordId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Registration Document uploaded successfully!',
                        variant: 'success'
                    })
                );

                publish(this.messageContext, REFRESHCC, { message: 'refresh' });
                this.resetForm();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
    }

    resetForm() {
        this.fileContent = '';
        this.fileName = '';
        this.regFileContent = '';
        this.regFileName = '';
        this.indexFileContent = '';
        this.indexFileName = '';
        this.isFileUploaded = false;
        this.isindex2Uploaded = false;
        this.isRegiFileUploaded = false;
    }
}