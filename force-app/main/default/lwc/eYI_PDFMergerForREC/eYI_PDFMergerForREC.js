import { LightningElement, api,wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import pdflib from "@salesforce/resourceUrl/pdfLib";
import { loadScript } from "lightning/platformResourceLoader";
import getData from '@salesforce/apex/EYI_DocData.getData';
import getRecordsId from '@salesforce/apex/EYI_DocData.getRecordsId';
import createContentVersion from '@salesforce/apex/EYI_DocData.createContentVersion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EYI_PDFMergerForREC extends NavigationMixin(LightningElement) {
    @api recordId
    docData = []
    error
    ids ='' 

    @wire(getRecordsId, {
        accId: '$recordId'
    }) wiredContacts({ error, data }) {
        if (data) {
         this.ids = data
         console.log('data Id '+this.ids)
        // this.navigateToFiles()
        }  else if (error) {
            // Handle the error
            console.error('Error retrieving records: ', error);
        }
    } 

    renderedCallback() {
        console.log('Inside renderedCallback');
        loadScript(this, pdflib).then(() => {
            console.log('PDF library loaded');
        }).catch(error => {
            console.error('Error loading PDF library:', error);
        });;

        console.log('recode id  ' + this.recordId)
        if (this.recordId) {
            getData({ accountId: this.recordId })
                .then((result) => {
                    this.docData = JSON.parse(JSON.stringify(result));
                    console.log('Size of File are ' + this.docData.length)
                    this.error = undefined;
                  // this.createPdf()
                })
                .catch((error) => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please add files to merge. There is no documents present' + error,
                        variant: 'Error',
                    });
                    console.log('error while calling ' + error)
                })
        }
    }

    async createPdf() {
       console.log('Inside createPdf');
        try {
            const pdfDoc = await PDFLib.PDFDocument.create(); // Create a new PDF document
            console.log('PDF document created:', pdfDoc);
    
            if (this.docData.length < 1) {
                console.log('No document data found');
                this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please add files to merge. There is no documents present',
                variant: 'Error',
                }));
                return;
            }
    
            // Process the first document data
            let tempBytes ;
            let page;
            
            //Uint8Array.from(atob(this.docData[0]), (c) => c.charCodeAt(0));
            /*console.log('First document tempBytes:', tempBytes);
    
            const [firstPage] = await pdfDoc.embedPdf(tempBytes); // Embed the first page
            const americanFlagDims = firstPage.scale(0.99);
            let page = pdfDoc.addPage();
            page.drawPage(firstPage, {
                ...americanFlagDims,
                x: page.getWidth() - americanFlagDims.width,
                y: page.getHeight() - americanFlagDims.height - 10,
            });*/
            console.log('**');
            // Process additional documents (if any)
            if (this.docData && this.docData.length > 0) {
                for (let i = 0; i < this.docData.length; i++) {
                    tempBytes = this.base64ToUint8Array(this.docData[i]);
                    const [firstPage] = await pdfDoc.embedPdf(tempBytes);
                    console.log('Processing document', i, 'with tempBytes:', tempBytes);
    
                    // Load the PDF document from bytes
                    const usConstitutionPdf = await PDFLib.PDFDocument.load(tempBytes);
                    console.log('Loaded document:', usConstitutionPdf);
                    
                    // Embed pages from the loaded document
                    for (let j = 0; j < usConstitutionPdf.getPages().length; j++) {
                        page = pdfDoc.addPage();
                        console.log('page : '+page);
                        const preamble = await pdfDoc.embedPage(usConstitutionPdf.getPages()[j]);
                        console.log('preamble : '+preamble);
                        const americanFlagDims = firstPage.scale(0.99);
                        console.log('Embedded page:', preamble);
    
                        const preambleDims = preamble.scale(0.95);
                        page.drawPage(preamble, {
                            ...preambleDims,
                            x: page.getWidth() - americanFlagDims.width,
                            y: page.getHeight() - americanFlagDims.height - 10,
                        });
                    }
                }
            }
           /* let tempBytes = this.base64ToUint8Array(this.docData[0]);
        console.log('First document tempBytes:', tempBytes);

        // Load the first PDF document
        const firstPdfDoc = await PDFLib.PDFDocument.load(tempBytes);
        console.log('Loaded first PDF document:', firstPdfDoc.getPages().length);

        // Embed all pages from the first document
        for (let i = 0; i < firstPdfDoc.getPages().length; i++) {
            console.log('inside firstPdf for');
            const firstPdfPage = firstPdfDoc.getPages()[i];
            console.log('firstPdfPage : '+firstPdfPage);

            // Embed the page into the new PDF
            const [embeddedPage] = await pdfDoc.embedPage(firstPdfPage);

            // Create a new page in the new PDF with the same size as the source page
            const page = pdfDoc.addPage(firstPdfPage.getSize());
            console.log('&&');
            page.drawPage(embeddedPage);
            console.log('inside last of firstPdf for');
        }

        // Process additional documents (if any)
        if (this.docData.length > 1) {
            for (let i = 1; i < this.docData.length; i++) {
                tempBytes = this.base64ToUint8Array(this.docData[i]);
                console.log('Processing document', i, 'with tempBytes:', tempBytes);

                // Load the second PDF document
                const secondPdfDoc = await PDFLib.PDFDocument.load(tempBytes);
                console.log('Loaded second PDF document:', secondPdfDoc);

                // Embed all pages from the second document
                for (let j = 0; j < secondPdfDoc.getPages().length; j++) {
                    const secondPdfPage = secondPdfDoc.getPages()[j];
                    const [embeddedPage] = await pdfDoc.embedPage(secondPdfPage);
                    const page = pdfDoc.addPage();
                    page.drawPage(embeddedPage);
                }
            }
        }*/

    
            // Save the final PDF document as bytes
            const pdfBytes = await pdfDoc.save();
            console.log('PDF created successfully, saving it...');
            this.savePdfToSalesforce(pdfBytes);
           // this.saveByteArray("REC My PDF", pdfBytes);
            
    
        } catch (error) {
            console.error('Error creating PDF:', error);
        }
    }

    base64ToUint8Array(base64String) {
        const binaryString = atob(base64String);
        const len = binaryString.length;
        const uint8Array = new Uint8Array(len);
    
        for (let i = 0; i < len; i++) {
            uint8Array[i] = binaryString.charCodeAt(i);
        }
    
        return uint8Array;
    }
    saveByteArray(pdfName, byte) {
        var blob = new Blob([byte], { type: "application/pdf" });
        var link = document.createElement("a");
        link.href = window.URL.createObjectURL(blob);
        var fileName = pdfName;
        link.download = fileName;
        link.click();
    }

    navigateToFiles() {
        console.log('Inside navigateToFiles');
        this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
              pageName: 'filePreview'
          },
          state : {
              recordIds: this.ids,
              
          }
        })
      }


      async savePdfToSalesforce(pdfBytes) {
        try {
            const base64Pdf = await this.uint8ArrayToBase64(pdfBytes);
            console.log('Calling Apex with PDF of size:', base64Pdf.length);

            await createContentVersion({
                base64Pdf: base64Pdf,
                fileName: 'REC_Merged_PDF.pdf',
                recordId: this.recordId
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'PDF saved and linked to record successfully!',
                variant: 'success',
            }));
            console.log('PDF saved to Salesforce.');
        } catch (error) {
            console.error('Error saving PDF to Salesforce:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to save PDF: ' + (error.body?.message || error.message),
                variant: 'error',
            }));
        }
    }
    uint8ArrayToBase64(uint8Array) {
        return new Promise((resolve, reject) => {
            const blob = new Blob([uint8Array]);
            const reader = new FileReader();
    
            reader.onloadend = function() {
                const base64 = reader.result.split(',')[1]; // Remove the "data:application/pdf;base64," prefix
                resolve(base64);
            };
    
            reader.onerror = function(error) {
                reject(error);
            };
    
            reader.readAsDataURL(blob);
        });
    }
}