import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getDocumentTrackerRecords from '@salesforce/apex/DocumentController.getDocumentTrackerRecords';
//import updateDocumentVerificationStatus from '@salesforce/apex/DocumentController.updateDocumentVerificationStatus';
import deleteDocument from '@salesforce/apex/DocumentController.deleteDocument';

import { subscribe, MessageContext } from 'lightning/messageService';
import SAMPLEMC from '@salesforce/messageChannel/RefreshComponentChannel__c';

export default class DocumentChecklist extends LightningElement {

    @api recordId;// ='00QH4000001zuECMAY';

    @track documentList1;
    @track documents;

    @track receivedMessage ='';
    @track uploadDocByCustomerSelected = true;
    @track receivedMessage = '';
    @track isModalOpen = false;
    @track isPreviewModalOpen = false;
    @track fileUrl = '';
    @track isPdf = false;
    @track isImage = false;

    // Inject the message context
     @wire(MessageContext)
     messageContext;

    renderedCallback(){
       this.subscribeToMessageChannel();
    }
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            SAMPLEMC,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.receivedMessage = message.message;
        this.receivedMessagefromKYC = message.SendKycMethod;
        if (this.receivedMessage === 'refresh') {
            this.refreshPage();
            this.uploadDocByCustomerSelected = true;
        }
    }

    get columns() {
        return [
            { label: 'Document Name', className: 'slds-text-align_left' },
            { label: 'Preview', className: 'slds-text-align_left' },
            { label: 'CreatedDate', className: 'slds-text-align_left' },
            // { label: 'Verification Status', className: 'slds-text-align_center' },
            // { label: 'Verification DateTime', className: 'slds-text-align_center' },
            { label: 'Delete', className: 'slds-text-align_center' }
        ];
    }

   

    wiredDocumentListResult;
    

    refreshPage() {
        refreshApex(this.wiredDocumentListResult)
            .then(() => {
                console.log('refreshApex successful');
            })
            .catch(error => {
                console.error('refreshApex error: ', error);
            });
    }

    @wire(getDocumentTrackerRecords,  {recordId: '$recordId'})

            retrievedDocuments(result) {
                this.wiredDocumentListResult = result;
                const { data, error } = result;
                if (data) {
                    this.documents = data;
                    console.log('this.documentList : ' + JSON.stringify(this.documents));
                } else if (error) {
                    console.log('error: ', error);
                }
    }

   // Getter to mask DOCNumber
    //  get maskedDocuments() {
    //     if (!this.documents) return [];
    //     return this.documents.map(doc => {
    //         return {
    //             ...doc,
    //             maskedDOCNumber: this.maskDocumentNumber(doc.DOCNumber)
    //         };
    //     });
    // }

// Method to mask DOCNumber
// maskDocumentNumber(docNumber) {
//     if (!docNumber) return ''; 

//     const length = docNumber.length;
//     if (length <= 4) {
//         return docNumber; 
//     }

//     const maskedPart = '*'.repeat(length - 4); 
//     const visiblePart = docNumber.slice(-4); // Get the last 4 characters
//     return maskedPart + visiblePart;
// }
    // get checkboxClass() {
    //     return this.documents.verificationStatus ? 'green-checkbox' : 'red-checkbox';
    // }

    // Modal and file preview handling variables
    

    // Handle file upload
    // handleFileChange(event) {
    //     const file = event.target.files[0];
    //     const documentId = event.target.dataset.id; 
    //     if (file) {
    //         const document = this.documentList.find(doc => doc.id === documentId);
    //         document.file = file;
    //         document.uploaded = true;
    //         this.documentList = [...this.documentList];
    //     }
    // }

    

    // handleFileUploadClick(event) {
    //     const documentId = event.target.dataset.id;
    //     const inputElement = this.template.querySelector(`.file-input-${documentId}`);
    //     if (inputElement) {
    //         inputElement.click();  
    //     }
    // }
   
    handlePreview(event) {
        const contentDocumentId = event.currentTarget.dataset.id;
        const fileExtension  = event.currentTarget.dataset.FileExtension;
        this.fileUrl = `/sfc/servlet.shepherd/document/download/${contentDocumentId}`;
        console.log('this.fileUrl : '+this.fileUrl);
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.fileUrl = null;
    }

    // Close the preview modal
    closePreviewModal() {
        this.isPreviewModalOpen = false;
        this.fileUrl = ''; // Reset file URL
    }

    currentDocumentTrackerId;
    handlePreview(event) {
        const contentDocumentId = event.currentTarget.dataset.id;
        this.currentDocumentTrackerId = contentDocumentId;
        const document = this.documents.find(doc => doc.ContentDocumentId === contentDocumentId);
        if (document) {
            const fileExtension = document.FileExtension;
            this.fileUrl = `/sfc/servlet.shepherd/document/download/${contentDocumentId}`; 
            // Check the file extension and determine how to display the preview
            if (fileExtension === 'pdf') {
                this.isPdf = true;
                this.isImage = false;
            } else if (['jpg', 'jpeg', 'png', 'gif'].includes(fileExtension)) {
                this.isPdf = false;
                this.isImage = true;
            } else if (['doc', 'docx', 'xls', 'xlsx'].includes(fileExtension)) {
                this.isPdf = false;
                this.isImage = false;
            } else {
                this.isPdf = false;
                this.isImage = true;
            }
    
            // Open the modal for preview
            this.isModalOpen = true;
        } else {
            console.error('Document not found for ContentDocumentId: ' + contentDocumentId);
        }
    }

    verifyDocumentHandler(event){
        // const contentDocumentId = event.currentTarget.dataset.id;
        // const document = this.documents.find(doc => doc.ContentDocumentId === contentDocumentId);
        // if (document) {
        //     const docTrackerId = document.DocTrackerId;
        //     console.log('docTrackerId : ' + docTrackerId);
        //     // Call Apex method to update verification status
        //     updateDocumentVerificationStatus({ docTrackerId })
        //         .then(() => {
        //             this.refreshPage();
        //             this.closeModal();
        //         })
        //         .catch(error => {
        //             console.error('Error updating verification status: ', error);
        //         });
        // } else {
        //     console.error('Document not found for ContentDocumentId: ' + contentDocumentId);
        // } 
    }
    deleteHandler(event){
        const contentDocumentId = event.currentTarget.dataset.id;
        console.log('docTrackerId : '+contentDocumentId);
        
         deleteDocument({ contentDocumentId })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Document Deleted Successfully',
                            variant: 'Success'
                        }) 
                    );
                    this.refreshPage();
                })
                .catch(error => {
                    console.error('Error deleting record status: ', error);
                });
     }
}