import { LightningElement, track, wire,api } from 'lwc';
import getBookingForm from '@salesforce/apex/EYI_eSignBookingForm.getBookingForm';
import getContentDistributionURL from '@salesforce/apex/EYI_eSignBookingForm.getContentDistributionURL';
import getDocBase64 from '@salesforce/apex/EYI_eSignBookingForm.getDocBase64';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PanchShilLogo from '@salesforce/resourceUrl/PanchShilLogo';
import pdfLib from '@salesforce/resourceUrl/PDFJSLib';
import pdfWorkerJS from '@salesforce/resourceUrl/PDFWorkerJS';
import { loadScript } from 'lightning/platformResourceLoader';


export default class EYI_eSignBookingForm extends LightningElement {
    @api recordId;
    @track postUrl;
    @track esignrequest
    error
    enableESign = false
    imageUrl = PanchShilLogo
    showSpinner = false
    disableInitiateBtn = false
    showPreview = false
    foundPageCount = false
    @track fileURL
    versionId = '068C4000004KK8MIAW'
     
    @wire(CurrentPageReference)
    setPageReference(currentPageReference) {
       if (currentPageReference) {
            console.log('currentUrl:'+ JSON.stringify(window.location.href));
            this.recordId = currentPageReference.state.recappid;
            console.log('recordId: ' + this.recordId);
       }
    }

    handlePreview(event){
        getContentDistributionURL({ recordId2: this.recordId })
        .then(result =>{
            console.log('Response: ' + JSON.stringify(result));
            window.open(result);
        })
        .catch(error=>{
            console.log('ERROR');
        });
    }

    handlePreviewTestingNotUsed(event){
        //this.fileURL = 'https://panchshilrealtyorg--devorg.sandbox.my.salesforce.com/sfc/p/C4000001JGba/a/C4000000E4uz/JjJmgHjqQ1boMrWI0JJP8CMmB5h8cmcxL8OB_4_BKhM'
        //this.fileURL = 'https://panchshilrealtyorg--devorg.sandbox.file.force.com/sfc/dist/version/download/?oid=00DC4000001JGba&ids=068C4000004KK8M&d=%2Fa%2FC4000000E4uz%2FJjJmgHjqQ1boMrWI0JJP8CMmB5h8cmcxL8OB_4_BKhM&asPdf=false'
        //this.fileURL = 'https://panchshilrealtyorg--devorg.sandbox.my.salesforce.com' + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL&versionId=068C4000004KK8MIAW';
        //this.fileURL= 'https://panchshilrealtyorg--devorg.sandbox.my.salesforce.com/sfc/servlet.shepherd/version/download/068C4000004KK8MIAW'
        //this.fileURL = 'https://panchshilrealtyorg--devorg.sandbox.my.salesforce.com' + '/sfc/servlet.shepherd/version/renditionDownload?rendition=PREVIEW&versionId=068C4000004KK8MIAW';
        //this.fileURL = '/sfc/servlet.shepherd/document/download/069C4000004JLXvIAO';
        //this.fileURL = 'https://panchshilrealtyorg--devorg.sandbox.my.salesforce.com/sfc/p/C4000001JGba/a/C4000000E4uz/JjJmgHjqQ1boMrWI0JJP8CMmB5h8cmcxL8OB_4_BKhM';
        window.open('https://panchshilrealtyorg--devorg.sandbox.my.salesforce.com/sfc/p/C4000001JGba/a/C4000000E4uz/JjJmgHjqQ1boMrWI0JJP8CMmB5h8cmcxL8OB_4_BKhM');
        //this.showPreview = true;
    }
    @track base64Content;
    @track pageCount;
    pdfLibInitialized = false;

    @wire(getDocBase64, { recordId: '$recordId' })
    wiredRecord({ error, data }) {
        if (data) {
            this.showSpinner = true;
            this.base64Content = data.replace(/\s/g, ''); // Remove any whitespace characters
            this.initializePdfLib();
        } else if (error) {
            console.error('Error retrieving record:', error);
        }
    }

    renderedCallback() {
        if (this.pdfjsLibInitialized) {
            return;
        }
        this.pdfjsLibInitialized = true;

        Promise.all([
            loadScript(this, pdfLib ),
            loadScript(this, pdfWorkerJS )
        ])
        .then(() => {
            console.log('pdf.js and pdf.worker.js loaded successfully');
            pdfLib.GlobalWorkerOptions.workerSrc = pdfWorkerJS ;
            
            
        })
        .catch(error => {
            console.error('Error loading pdf.js or pdf.worker.js', error);
        });
    }

    initializePdfLib() {
        console.log('blob12', this.base64Content);
        if (this.base64Content) {
            this.getPageCount(this.base64Content);
        }
    }

    async getPageCount(base64Content) {
        try {
            console.log('blob3', base64Content);
            const pdfData = atob(base64Content);
            console.log('blob4', pdfData);
            const loadingTask = window.pdfjsLib.getDocument({ data: pdfData });
            console.log('blob5', JSON.stringify(loadingTask));
            const pdfDoc = await loadingTask.promise;
            this.pageCount = pdfDoc.numPages;
            if(Number(this.pageCount) > Number(0) ){
                this.showSpinner = false;
                this.foundPageCount = true;
            }
            console.log('Page count:', this.pageCount);
        } catch (error) {
            console.error('Error decoding base64 or loading PDF:', JSON.stringify(error));
        }
    }
    // @wire(getDocBase64, { recordId: '$recordId'})
    //     wiredRecord({ error, data }) {
    //         console.log('data234',data);
    //         if (data) {
    //             this.getPageCount(data);
                
    //             //this.selectedOpptyId = data.fields.EYI_Opportunity__c.value;
    //         } else if (error) {
    //             console.error('Error retrieving record:', error);
    //         }
    //     }

    //     async getPageCount(base64Content) {
    //         const pdfData = atob(base64Content);
    //         const pdfDoc = await PDFDocument.load(pdfData);
    //         console.log('checkpdfcount',JSON.stringify(pdfDoc.getPageCount()));
    //         return pdfDoc.getPageCount();
    //     }
    handleInitiate(event){
        this.showSpinner = true
        //this.enableESign = true;
        getBookingForm({ recordId2: this.recordId, totalPageCount:this.pageCount })
       .then(result => {
            console.log('Response: ' + JSON.stringify(result));
            if(Object.keys(result).length >= 2){
                this.postUrl = result.posturl;
                this.esignrequest= result.esignRequest;
                this.showSpinner = false;
                this.disableInitiateBtn = true;
                this.enableESign = true;
            }else{
                this.error = result.error;
            }
       })
       .catch(error => {
           console.log('Error: ' + JSON.stringify(error));
       });
    }
    
}