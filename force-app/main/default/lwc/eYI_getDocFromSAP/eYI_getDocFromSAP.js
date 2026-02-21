import { LightningElement,api,wire,track } from 'lwc';
import getRecordData from '@salesforce/apex/EYI_RecordDataController.getRecordData';
import downloadPDF from '@salesforce/apex/EYI_GenerateBillingPDFController.getGeneratingFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EYI_getDocFromSAP extends LightningElement {

@api isLoadedpdf = false;
@api recordId; // Automatically gets the current record's ID
@api objectApiName; // Automatically gets the current record's Object API Name
@api indicator;
@api isReceipt = false;
@api isDemand = false;
@api isDebitNote = false;
@api isCreditNote = false;
@api isInterestLetter = false;
@api isSOA = false;
@track isLoading =false;


@track requestData = {
    GetSapDocument:{
        DocumentNo: null,
        CompanyCode: null,
        AccountingDocNo: null,
        FiscalYear: null,
        DocumentType: null
    }
};

error;
@track recordData;

    @wire(getRecordData, { recordId: '$recordId', objectApiName: '$objectApiName' })
    wiredRecord({ error, data }) {
        if (data) {
            if(this.indicator == 'RECEIPT'){
                this.isReceipt = true;
            }else if(this.indicator == 'DEMAND'){
                this.isDemand = true;
            }else if(this.indicator == 'DEBIT_NOTE'){
                this.isDebitNote = true;
            }else if(this.indicator == 'CREDIT_NOTE'){
                this.isCreditNote = true;
            }else if(this.indicator == 'SOA'){
                this.isSOA = true;
            }else if(this.indicator == 'INTEREST'){
                this.isInterestLetter = true;
            }
            console.log('data-->'+JSON.stringify(data));
            this.recordData = data;
            this.error = undefined;
        } else if (error) {
            console.log('error'+JSON.stringify(error));
            this.error = error;
            this.recordData = undefined;
        }
    }


    handleClick(){
         this.isLoadedpdf = true;
         this.isLoading = true;
                if (this.recordData == undefined) {
                    const evt = new ShowToastEvent({
                        title: 'Data Error',
                        message: 'Customer Number or Sales Order Number Not Present',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                } else {
                    console.log('in else part of handleclick')
                    if(this.indicator == 'RECEIPT'){
                        console.log('insideif')
                        this.requestData.GetSapDocument.CompanyCode = this.recordData.EYI_SAP_Company_Code__c,
                        console.log('this.requestData.GetSapDocument.CompanyCode : '+this.requestData.EYI_SAP_Company_Code__c);
                        this.requestData.GetSapDocument.AccountingDocNo = this.recordData.EYI_SAP_Document_Number__c,
                        console.log('this.requestData.GetSapDocument.AccountingDocNo : '+this.requestData.GetSapDocument.AccountingDocNo);
                        this.requestData.GetSapDocument.FiscalYear  = this.recordData.EYI_Fiscal_Year__c,
                        console.log('this.requestData.GetSapDocument.FiscalYear : '+this.requestData.GetSapDocument.FiscalYear);
                        this.requestData.GetSapDocument.DocumentType  = 'RECEIPT'
                    }
                    else if(this.indicator == 'DEMAND'){
                        console.log('insideif')
                        this.requestData.GetSapDocument.DocumentNo = this.recordData.EYI_SAP_Demand_Number__c,
                      
                        this.requestData.GetSapDocument.DocumentType  = 'DEMAND'
                    }
                    else if(this.indicator == 'DEBIT_NOTE'){
                        console.log('insideif')
                        this.requestData.GetSapDocument.DocumentNo = this.recordData.EYI_SAP_Demand_Number__c,
                        this.requestData.GetSapDocument.DocumentType  = 'DEBIT_NOTE'
                    }
                    else if(this.indicator == 'CREDIT_NOTE'){
                        console.log('insideif')
                        this.requestData.GetSapDocument.DocumentNo = this.recordData.EYI_SAP_Demand_Number__c,
                        this.requestData.GetSapDocument.DocumentType  = 'CREDIT_NOTE'
                    }
                    else if(this.indicator == 'SOA'){
                        console.log('insideif')
                        this.requestData.GetSapDocument.DocumentNo = this.recordData.EYI_Opp_Customer_Number__c,
                        this.requestData.GetSapDocument.DocumentType  = 'SOA'
                    }
                    else if(this.indicator == 'INTEREST'){
                        console.log('insideif')
                        this.requestData.GetSapDocument.DocumentNo = this.recordData.EYI_Opp_Customer_Number__c,
                        this.requestData.GetSapDocument.DocumentType  = 'INTEREST'
                    }
                    console.log('datapost-->'+JSON.stringify(this.requestData));
                    
             
                    console.log(JSON.stringify(this.requestData));
                    this.jsonString = JSON.stringify(this.requestData);
                    console.log('this.jsonString-->' + this.jsonString);
                    this.getPdf(this.jsonString);
                }

    }


    getPdf(data){
        console.log('data '+data);
        downloadPDF({ requestJsonString: data,/*bookingId:this.idBooking*/ }).then(response => {
            console.log('response-->'+response);
            if (response) {
                
                const byteCharacters = atob(response);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: 'application/pdf' });
                // Generate a URL for the blob
                const pdfURL = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = pdfURL;
                a.target = '_blank';
                a.rel = 'noopener noreferrer';
                a.click();
                this.isLoading = false;
                //window.open(pdfURL);
            } else {
                this.isLoading = false;
                const evt = new ShowToastEvent({
                    title: 'Data Error',
                    message: 'No data from SAP',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Error: ' + JSON.stringify(error));
            const evt = new ShowToastEvent({
                title: 'Data Error',
                message: 'Something Went wrong',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
    }
    



}