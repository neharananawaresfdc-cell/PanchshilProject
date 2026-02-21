import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import fetchCustomerLedger from '@salesforce/apex/EYI_CustomerLedgerController.fetchCustomerLedger';
const FIELDS = [
    'Opportunity.EYI_SAP_Customer_Number__c','Opportunity.Name',
    'Opportunity.Registration_Date__c','Opportunity.Possession_Formalities_Done_Date__c',
    'Opportunity.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c',
    'Opportunity.EYI_Inventory__r.EYI_Saleable_Area__c',
    'Opportunity.EYI_Inventory__r.EYI_Inventory_Number__c',
    'Opportunity.EYI_Inventory__r.EYI_Apartment_Ready_Date__c',
    'Opportunity.SyncedQuote.EYI_Base_Rate_PSF__c',
    'Opportunity.SyncedQuote.EYI_Base_Rate_Discount_PSF__c',
    'Opportunity.EYI_REC__r.Name'
    
];
export default class CustomerLedgerReport extends LightningElement {
    @track customerNumber;
    @track companyCode;
    @track customerName;
    @track psrSqftRate;
    @track registrationDate;
    @track possessionDate;
    @track aptmtReadyDate;
    @track saleableArea;
    @track recName;
    @track unitNumber;
    @api recordId;
    @track ledgerData = []; 
    @track fullData = [];  
    @track exportData = [];
    @track error;
    @track showDataTable = false;
    @track fileName;
    isLoading  = false;
    pageSize = 50;
    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;
    isDisableNext = true;
    isDisablePrev = true;

    columns = [
        { label: 'Invoice', fieldName: 'INVOICE',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Company Code', fieldName: 'COMPANYCODE',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Customer Code', fieldName: 'CUSTOMERCODE' },
        { label: 'Payment Milestone', fieldName: 'PAYMENTMILESTONE' },
        { label: 'Demand Raised Date', fieldName: 'DEMANDRAISEDDATE', type: 'date' },
        { label: 'Due Date', fieldName: 'DUEDATE', type: 'date' },
        { label: 'Principal Amount', fieldName: 'PRINCIPALAMOUNT', type: 'number',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'GST Amount', fieldName: 'GSTAMOUNT', type: 'number',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Total Receivable', fieldName: 'TOTALRECEIVABLE', type: 'number',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Payment Received', fieldName: 'PAYMENTRECEIVED', type: 'number',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Other Adjustment', fieldName: 'OTHERADJUSTMENT', type: 'number',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Total Outstanding', fieldName: 'TOTALOUTSTANDING', type: 'number',cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Doc Number', fieldName: 'DOCNUMBER' },
        { label: 'Received Date', fieldName: 'RECEIVEDDATE', type: 'date' },
        { label: 'Source of Payment', fieldName: 'SOURCEOFPAYMENT' },
        { label: 'Bank Details', fieldName: 'BANKDETAILS' },
        { label: 'Instrument Number', fieldName: 'INSTRUMENTNUMBER' },
        { label: 'Instrument Date', fieldName: 'INSTRUMENTDATE', type: 'date' },
    ];

    // @wire(getRecord, { recordId: '$recordId', fields: 'Opportunity.EYI_SAP_Customer_Number__c' })
    // wiredRecord({ error, data }) {
    //     if (data) {
    //         this.customerNumber = data.fields.EYI_SAP_Customer_Number__c.value; 
    //     } else if (error) {
    //         console.error('Error loading record:', error);
    //     }
    // }
    connectedCallback(){
        console.log('recordId : '+this.recordId);
        this.ledgerData = [];
        this.fullData =[];
    }
     @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.c__recordId;
            console.log('this.recordId : '+this.recordId);
            
          //  this.getCustomerLedgerDetails();
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.clearState();
            this.customerNumber = data.fields.EYI_SAP_Customer_Number__c.value ? data.fields.EYI_SAP_Customer_Number__c.value :'' ;
            this.customerName = data.fields.Name.value ? data.fields.Name.value :'';
            this.fileName = 'Customer Ledger Details of '+this.customerName+'-'+this.customerNumber;
            this.registrationDate = data.fields.Registration_Date__c.value ? data.fields.Registration_Date__c.value : '';
            this.possessionDate = data.fields.Possession_Formalities_Done_Date__c.value ? data.fields.Possession_Formalities_Done_Date__c.value : '';
            const project = data.fields.EYI_Project_Enquired__r;
            if (project && project.value && project.value.fields.EYI_SAP_Company_Code__c) {
                this.companyCode = project.value.fields.EYI_SAP_Company_Code__c.value;
            }
            const rec = data.fields.EYI_REC__r;
            if(rec && rec.value && rec.value.fields.Name){
                this.recName = rec.value.fields.Name.value;
            }
           const inventory = data.fields.EYI_Inventory__r;
           if (inventory && inventory.value && inventory.value.fields.EYI_Saleable_Area__c) {
                this.saleableArea = inventory.value.fields.EYI_Saleable_Area__c.value;
            }
            if(inventory && inventory.value && inventory.value.fields.EYI_Inventory_Number__c){
                this.unitNumber = inventory.value.fields.EYI_Inventory_Number__c.value;
            }
            if (inventory && inventory.value && inventory.value.fields.EYI_Apartment_Ready_Date__c) {
                this.aptmtReadyDate = inventory.value.fields.EYI_Apartment_Ready_Date__c.value;
            }
            const syncQuote = data.fields.SyncedQuote;
            if(syncQuote && syncQuote.value ) {
                if(syncQuote.value.fields.EYI_Base_Rate_PSF__c && syncQuote.value.fields.EYI_Base_Rate_Discount_PSF__c){
                   const baseRate = syncQuote.value.fields.EYI_Base_Rate_PSF__c.value;
                   const discountRate = syncQuote.value.fields.EYI_Base_Rate_Discount_PSF__c.value;
                    this.psrSqftRate =discountRate ? baseRate - discountRate : baseRate;
                }else{
                   this.psrSqftRate =  syncQuote.value.fields.EYI_Base_Rate_PSF__c ;
                }
            }
            
        } else if (error) {
            console.error('Error loading record:', error);
        }
    }
    clearState() {
        this.showDataTable = false;
        this.ledgerData = [];
        this.fullData = [];
        this.exportData = [];
        this.totalRecords = 0;
        this.totalPages = 0;
        this.pageNumber = 1;
    }
    get fieldSummary() {
    return [
        { label: 'Customer Number', value: this.customerNumber },
        { label: 'Customer Name', value: this.customerName },
        { label: 'Unit Number', value: this.unitNumber },
        { label: 'File Name', value: this.fileName },
        { label: 'Registration Date', value: this.registrationDate },
        { label: 'Possession Date', value: this.possessionDate },
        { label: 'Company Code', value: this.companyCode },
        { label: 'REC Name', value: this.recName },
        { label: 'Saleable Area', value: this.saleableArea },
        { label: 'Apartment Ready Date', value: this.aptmtReadyDate },
        { label: 'Per Sqft Rate', value: this.psrSqftRate }
    ];
}

   handleSearch() {
    if (!this.customerNumber && !this.companyCode) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Customer Number and Company Code is Required.',
            variant: 'error',
        }));
        return;
    }
    if (!this.customerNumber) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Customer Number is Required.',
            variant: 'error',
        }));
        return;
    }
    if (!this.companyCode) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Company Code is Required.',
            variant: 'error',
        }));
        return;
    }
    console.log('this.customerNumber : '+this.customerNumber);
    console.log('this.companyCode : '+this.companyCode);
    
    this.isLoading = true;

    fetchCustomerLedger({ customerNumber: this.customerNumber, companyCode: this.companyCode})
        .then(result => {
            this.isLoading = false;
        const outer = JSON.parse(result);
        const parsedResult = outer["n0:ZSD_CUSTOMER_LEDGER_SFResponse"]?.EX_OUTPUT;
            if (parsedResult/*parsedData && parsedData.ledgerResponse*/) {
                console.log('parsedData.ledgerResponse : '+parsedResult);
                this.showDataTable = true;
                this.fullData = Array.isArray(parsedResult?.item)
    ? parsedResult.item.map(entry => {
        return {
            ...entry,
            DEMANDRAISEDDATE: this.convertSAPDate(entry.DEMANDRAISEDDATE),
            DUEDATE: this.convertSAPDate(entry.DUEDATE),
            RECEIVEDDATE: this.convertSAPDate(entry.RECEIVEDDATE),
            INSTRUMENTDATE: this.convertSAPDate(entry.INSTRUMENTDATE)
        };
    })
    : [];
    this.exportData = this.fullData;
                this.totalRecords = this.fullData.length;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.pageNumber = 1;
                this.updatePagination();
                this.error = undefined;
            } else {
                this.fullData = [];
                this.ledgerData = [];
                this.totalRecords = 0;
                this.totalPages = 0;
                this.error = 'No ledger data found.';
                this.dispatchEvent(new ShowToastEvent({
                        title: 'No Data',
                        message: 'No ledger data found.',
                        variant: 'info'
                }));
            }
        })
        .catch(error => {
            this.isLoading = false;
            console.error('Error fetching ledger data:', error);
            this.error = 'Failed to parse ledger data.';
            this.fullData = [];
            this.ledgerData = [];
            this.totalRecords = 0;
            this.totalPages = 0;
        });
}
    convertSAPDate(sapDateStr) {
        if (!sapDateStr || sapDateStr === '00000000') return '';

        const year = sapDateStr.substring(0, 4);
        const month = sapDateStr.substring(4, 6);
        const day = sapDateStr.substring(6, 8);
        return `${year}-${month}-${day}`;
    }

    updatePagination() {
    const startIndex = (this.pageNumber - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;

    const currentPageData = this.fullData.slice(startIndex, endIndex);
    this.ledgerData = currentPageData;

    /*let totalPrincipal = 0;
    let totalGst = 0;
    let totalReceivable = 0;
    let totalReceived = 0;
    let totalAdjustment = 0;
    let totalOutstanding = 0;

    const uniqueInvoices = new Set();

    currentPageData.forEach(row => {
        if (!uniqueInvoices.has(row.INVOICE)) {
            console.log('*');
            uniqueInvoices.add(row.INVOICE);
            totalPrincipal += parseFloat(row.PRINCIPALAMOUNT || 0);
            totalGst += parseFloat(row.GSTAMOUNT || 0);
            totalReceivable += parseFloat(row.TOTALRECEIVABLE || 0);
        }

        //totalGst += parseFloat(row.GSTAMOUNT || 0);
        
        totalReceived += parseFloat(row.PAYMENTRECEIVED || 0);
        totalAdjustment += parseFloat(row.OTHERADJUSTMENT || 0);
        row.rowClass = '';
    });
    totalOutstanding = totalReceivable - totalReceived
    const totalRow = {
        INVOICE: 'Total',
        COMPANYCODE: '',
        CUSTOMERCODE: '',
        PAYMENTMILESTONE: '',
        DEMANDRAISEDDATE: '',
        DUEDATE: '',
        PRINCIPALAMOUNT: totalPrincipal,
        GSTAMOUNT: totalGst,
        TOTALRECEIVABLE: totalReceivable,
        PAYMENTRECEIVED: totalReceived,
        OTHERADJUSTMENT: totalAdjustment,
        TOTALOUTSTANDING: totalOutstanding,
        DOCNUMBER: '',
        RECEIVEDDATE: '',
        SOURCEOFPAYMENT: '',
        BANKDETAILS: '',
        INSTRUMENTNUMBER: '',
        INSTRUMENTDATE: '',
        rowClass: 'slds-text-title_bold' // Highlight total row
    };

    this.ledgerData = [...currentPageData, totalRow];*/

    this.isDisablePrev = this.pageNumber === 1;
    this.isDisableNext = this.pageNumber === this.totalPages || this.totalPages === 0;
}  

    firstPage() {
        if (this.pageNumber !== 1) {
            this.pageNumber = 1;
            this.updatePagination();
        }
    }

    lastPage() {
        if (this.pageNumber !== this.totalPages) {
            this.pageNumber = this.totalPages;
            this.updatePagination();
        }
    }

    previous() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.updatePagination();
        }
    }

    next() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.updatePagination();
        }
    }
}