import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveDocument from '@salesforce/apex/DocumentController.saveDocument';

 import { publish, MessageContext } from 'lightning/messageService';
 import SAMPLEMC from '@salesforce/messageChannel/RefreshComponentChannel__c';



export default class DocumentUploadComponent extends LightningElement {
    @api recordId;
    @track documentName
    @track fileContent;
    @track fileName;
    @track isFileUploaded = false;

     @wire(MessageContext)
     messageContext;

    connectedCallback(){
        console.log('Master this.recordId :: '+this.recordId);
    }

    handleDocumentNameChange(event) {
        this.documentName = event.detail.value;
        console.log('this.documentName : '+this.documentName);
    }
    
    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.fileContent = reader.result.split(',')[1];
                this.fileName = file.name;
                console.log('this.fileName : '+this.fileName);
                
            };
            reader.readAsDataURL(file);
            this.isFileUploaded = true;
        }
    }

    handleSave() {

        if(!this.documentName){
            this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter document Name',
                        variant: 'Error'
                    }) 
                );

        }else{
            console.log('fileName : '+this.documentName);
            console.log('recordId : '+this.recordId);
            let extension = this.fileName.split('.').pop(); 
            console.log('extension '+extension);
            
            let fullFileName = this.documentName+'.'+extension;
            console.log('fullFileName : '+fullFileName);
            
            
            saveDocument({ fileContent: this.fileContent, fileName: fullFileName, recordId: this.recordId })
            .then(() => {
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Success',
                //         message: 'Document Uploaded Successfully',
                //         variant: 'Success'
                //     }) 
                // );

                const message = {
                    message: 'refresh'
                };
                publish(this.messageContext, SAMPLEMC, message);
                
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
        this.documentName = '';
        this.fileContent = '';
        this.fileName = '';
        this.isFileUploaded = false;
    }
}