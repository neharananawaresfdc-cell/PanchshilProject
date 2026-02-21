import { LightningElement, api, track, wire } from 'lwc';
import saveData from '@salesforce/apex/EYI_SAP_DemandReceiptController.createLineItemsWithReceipt';
import fetchTableData from '@salesforce/apex/EYI_SAP_DemandReceiptController.getApiData';
import getPDCDetails from '@salesforce/apex/EYI_SAP_DemandReceiptController.getPDCDetails';
import getOpportunityInfo from '@salesforce/apex/EYI_SAP_DemandReceiptController.getOpportunityInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import getPicklistValues from '@salesforce/apex/EYI_SAP_DemandReceiptController.getPicklistValues';
import checkDuplicateNumber from '@salesforce/apex/EYI_SAP_DemandReceiptController.checkDuplicateNumber';
//import getPaymentReceiptList from '@salesforce/apex/EYI_SAP_DemandReceiptController.getPaymentReceiptList';
import getBookingSalesOrder from '@salesforce/apex/EYI_SAP_DemandReceiptController.getBookingSalesOrder';
import getApplicants from '@salesforce/apex/EYI_SAP_DemandReceiptController.getApplicants';

export default class eYI_Opportunity_PaymentReceiptCreation extends LightningElement {
    @api recordId;
    @track data = [];
    @track draftValues = [];
    @track isLoading = false;
    @track calculatedAmount = 0;
    @track createAdvance = false;
    @track showLineItems = false;
    @track advanceAmount = 0;
    @track showFetchButton = false;
    @track showSaveButton = false;
    @track showPaymentReceipt = false;
    @track showNonBankableCheque = false;
    @track paymentAmount = 0;
    @track lineItemSize = 0 ;
    @track demandedAmount = 0;
    @track isSaveDisabled = true;
    @track paymentPicklistOptions = [ { label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' } ]
    @track selectedReceiptId ='' ;
    @track receiptList=[];
    @track disableFields;
    @track showRealizationDate = false;
    @track opportunityName;
    @track inventoryNumber;
    @track showChannelFields = false;
    @track isNonBankable = false;
    @track isPDC = false;


    @track formData = {
        PaymentAlreadyDone:'No',
        ReceiptSelect:'',
        InstrumentNumber: '',
        InstrumentDate: '',
        RealizationDate: '',
        PaymentAmount: '',
        BankName: '',
        paymentMode: '',
        TransactionType: '',
        CategoryofFunnding:'',
        NonBankablePayment: false,
        Remarks: '',
        advanceAmount:'',
        ReceivedFrom:'',
        ChannelNumber:'',
        ChannelDate:''
        
    };
    @track uploadedFileId = null;
    @track uploadedFiles = [];
    @track picklistOptions = {};
    @track hasSalesOrder = false;
    @track showInputInstead = false;
    @track applicantOptions = [];
    @track isSaving = false;
    get cardTitle() {
        return `Payment Receipt Details - ${this.opportunityName} - ${this.inventoryNumber}`;
    }


    columns = [
        // { label: 'Customer Number', fieldName: 'companyCode', type: 'text' },

        { label: 'Inv Ref', fieldName: 'INV_REF', type: 'text', wrapText: true, initialWidth: 110 },
        { label: 'Item Text', fieldName: 'ITEM_TEXT', type: 'text', wrapText: true, initialWidth: 180 },
        { label: 'Ref Doc No', fieldName: 'REF_DOC_NO', type: 'text', wrapText: true, initialWidth: 180 },
        //{ label: 'FI Doc No.', fieldName: 'fiDocumentNo', type: 'text', wrapText: true, initialWidth: 120 },
        { label: 'Fiscal Year', fieldName: 'fiscalYear', type: 'text', wrapText: true, initialWidth: 100 },
        { label: 'Line Item', fieldName: 'lineItemNo', type: 'text', wrapText: true, initialWidth: 90 },
        { label: 'Billed Amount', fieldName: 'amountLocalCurrency', type: 'currency', wrapText: true, initialWidth: 130 },
        { label: 'Adjst Amt', fieldName: 'inputValue', type: 'currency', wrapText: true, initialWidth: 130 },
        { label: 'Outstanding Amt', fieldName: 'outstanding', type: 'currency', wrapText: true, initialWidth: 150 },
        { label: 'Billing Doc.', fieldName: 'billingDoc', type: 'text', wrapText: true, initialWidth: 130 },
        { label: 'Ref 1', fieldName: 'milestoneNo', type: 'text', wrapText: true, initialWidth: 100 },
        { label: 'Ref 2', fieldName: 'unitCodeSAP', type: 'text', wrapText: true, initialWidth: 130 },
        { label: 'Ref 3', fieldName: 'paymentBifurcation', type: 'text', wrapText: true, initialWidth: 130 },
        { label: 'Sp G/L Ind', fieldName: 'SP_GL_IND', type: 'text', wrapText: true, initialWidth: 100 },
        { label: 'Doc Type', fieldName: 'DOC_TYPE', type: 'text', wrapText: true, initialWidth: 100 },
        { label: 'Posting Date', fieldName: 'PSTNG_DATE', type: 'date', wrapText: true, initialWidth: 130 },
        { label: 'DB Ind', fieldName: 'DB_CR_IND', type: 'text', wrapText: true, initialWidth: 90 },
    ];

    resetForm(){
        this.formData.BankName = '';
        this.formData.InstrumentNumber = '';
        this.formData.paymentMode = '';
        this.formData.ReceiptSelect = '';
        this.formData.NonBankablePayment = '';
        this.formData.ChequeDdNumber = '';
        this.formData.PaymentAmount = '';
        this.formData.TransactionType = '';
        this.formData.CategoryofFunnding = '';
        this.formData.Remarks = '';
        this.formData.InstrumentDate = '';
        this.formData.RealizationDate = '';
        this.formData.ReceivedFrom = '';
    }

    get showChequeDdNumber() {
        const mode = this.formData?.paymentMode;
        return mode === 'Cheque' || mode === 'DD' || mode === 'PDC Cheque';
    }


    connectedCallback() {
        console.log('inside Connected Callback');
        console.log('this.paymentReceiptId ==> ', this.paymentReceiptId);
       // this.loadPicklistOptions('EYI_Payment_Receipt__c', ['EYI_Bank_Name__c', 'EYI_Mode_of_Payment__c', 'EYI_Transaction_Type__c']);
         //this.getBookignNumber();
    }
    getBookignNumber(){

        getBookingSalesOrder({ opportunityId: this.recordId })

        .then(salesOrderNumber => {
            console.log('salesOrderNumber :: '+salesOrderNumber);
            
            this.hasSalesOrder = !!salesOrderNumber; // Convert to boolean

            this.loadPicklistOptions('EYI_Payment_Receipt__c', ['EYI_Bank_Name__c', 'EYI_Mode_of_Payment__c', 'EYI_Transaction_Type__c','EYI_Category_of_Funding__c']);

        })

        .catch(error => {
            console.error('Error fetching Sales Order Number:', error);
        });
    }

    @wire(CurrentPageReference)
    setPageReference(currentPageReference) {
        if (currentPageReference) {
            let recordId  = currentPageReference.state.c__recordId;
            let paymentReceiptId = currentPageReference.state.c__receiptId;

            if(recordId != ''){
                this.recordId = recordId;
                console.log('inside wire recordId ==> ',this.recordId);
                this.getBookignNumber();
                this.fetchOpportunityInfo();
            }

            if(paymentReceiptId != ''){
                this.paymentReceiptId = paymentReceiptId;
                this.fetchPDCDetails();
            }
        }
    }

    async fetchOpportunityInfo() {
        try {
            console.log('fetchOpportunityInfo recordId ==> ',this.recordId);
            const result = await getOpportunityInfo({ recordId: this.recordId });
            console.log('opp Result ==> ', result);

            this.opportunityName = result.Name;

            // Safely access nested properties
            this.inventoryNumber = result.EYI_Inventory__r?.EYI_Inventory_Number__c || 'NA';
            this.loadApplicants();
        } catch (error) {
            console.error('Picklist load error:', error);
        }
    }
    fetchPDCDetails(){
        console.log('Inside fetching PDC details');
        
        getPDCDetails({ recordId: this.paymentReceiptId })
            .then(result => {
                console.log('result : '+JSON.stringify(result));
                this.showRealizationDate = true;
                this.showNonBankableCheque = true ;
                this.isPDC = true;
                this.isNonBankable = false;
                this.recordId = result.EYI_Opportunity__c;
                this.formData = {
                    InstrumentDate: result.EYI_Instrument_Date__c || '',
                    RealizationDate: result.EYI_Cheque_Realization_Date__c || '',
                    PaymentAmount: result.EYI_Amount__c || '',
                    BankName: result.EYI_Bank_Name__c || '',
                    paymentMode: result.EYI_Mode_of_Payment__c || '',
                    TransactionType: result.EYI_Transaction_Type__c || '',
                    CategoryofFunnding: result.EYI_Category_of_Funding__c || '',
                    NonBankablePayment: false,
                    Remarks: result.EYI_Remarks__c || '',
                    ChequeDdNumber: result.EYI_Check_number__c || '',
                    ReceivedFrom: result.ReceivedFrom || '',
                };   
                console.log('formData PDC ==> ',this.formData);
                this.disableFields = true;
            })
            .catch(error => {
                console.error('Error fetching applicants:', error);
            });
    }
    loadApplicants() {
        getApplicants({ opportunityId: this.recordId })
            .then(result => {
                if (result.length === 0) {
                    this.showInputInstead = true;
                    this.formData.ReceivedFrom =  this.opportunityName;
                    return;
                }

                this.applicantOptions = result.map(app => ({
                    label: app.Name,
                    value: app.Name
                }));

                // Default selection to Primary applicant if available
                const primary = result.find(app => app.EYI_Applicant_Type__c === 'Primary');
                this.formData.ReceivedFrom = primary ? primary.Name : result[0].Name;
            })
            .catch(error => {
                console.error('Error fetching applicants:', error);
               // this.showInputInstead = true;
            });
    }

    loadPicklistOptions(objectApiName, fieldApiNames) {
        this.paymentPicklistOptions;
        console.log('Payment Picklist Options '+JSON.stringify(this.paymentPicklistOptions));
        this.receiptList;
            getPicklistValues({ objectApiName, fieldApiNames })
        .then(result => {
            for (const field in result) {
                let options = result[field].map(val => ({
                    label: val,
                    value: val
                }));

                // Condition: remove "Token" if Sales Order exists
                console.log('this.hasSalesOrder :: '+this.hasSalesOrder);
                
                if (field === 'EYI_Transaction_Type__c' && this.hasSalesOrder == true) {
                    options = options.filter(option => option.value !== 'Token');
                }
                if (field === 'EYI_Transaction_Type__c' && this.hasSalesOrder == false ) {
                    options = options.filter(option => option.value !== 'Demand'  && option.value !== 'TDS' && option.value !== 'Advance');
                }
                this.picklistOptions[field] = options;
            }

            //console.log('Final Picklist Options:', JSON.stringify(this.picklistOptions));
        })
        .catch(error => {
            console.error('Picklist load error:', error);
        });
    }

    getPaymentReceiptList() {
        console.log('inside getPaymentList '+this.recordId);
        getPaymentReceiptList({ opptyId: this.recordId })
            .then(result => {
                console.log('inside result');
                this.receiptList = result.map(r => ({
                    label: r.Name,
                    value: r.Id,
                    InstrumentNumber:  r.EYI_Instrument_Number__c,
                    PaymentAlreadyDone:'Yes',
                    InstrumentDate: r.EYI_Instrument_Date__c,
                    PaymentAmount: r.EYI_Amount__c,
                    BankName: r.EYI_Bank_Name__c,
                    paymentMode: r.EYI_Mode_of_Payment__c,
                    ChequeDdNumber:r.EYI_Check_number__c,
                    TransactionType: r.EYI_Transaction_Type__c,
                    NonBankablePayment: r.EYI_Non_Bankable_Payment__c,
                    Remarks: r.EYI_Remarks__c

                }));
                console.log('result '+JSON.stringify(result));
            })
            .catch(error => {
                console.error('Error fetching receipt details:', error);
            });
    }

    handleInputChange(event) {
        const { name, value } = event.target;
        try {
            this.handleFieldChange(name, value);
        } catch (error) {
            console.error('Error in handleInputChange:', error);
        }
    }

    handleFieldChange(name, value) {
        this.formData[name] = value;

        // Handle Bank Name
        if (name === 'EYI_Bank_Name__c' || name === 'BankName') {
            this.formData.BankName = value;
        }

        // Handle Cheque/DD Number
        if (name === 'ChequeDdNumber') {
            this.formData.ChequeDdNumber = value;
        }
        // Handle Instrument Number
        if (name === 'InstrumentNumber') {
            this.validateInstrumentNumber();
        }

        // Handle Payment Amount
        if (name === 'PaymentAmount') {
            this.formData.PaymentAmount = value;
            this.showLineItems = false;
            this.recalculateAmounts();
        }

        // Handle Transaction Type (but don't override payment mode behavior)
        if (name === 'EYI_Transaction_Type__c' || name === 'TransactionType') {
            this.showLineItems = false;
            this.data = [];
            this.demandedAmount = 0 ;
            this.paymentAmount = 0; 
            this.advanceAmount = 0 ;

            this.formData.TransactionType = value;
            if(value == 'TDS'){
                this.showChannelFields = true;
            }else{
                this.showChannelFields = false;
            }
        }
        if (name === 'EYI_Category_of_Funding__c') {
            this.formData.CategoryofFunnding = value;
        }

        if (name === 'applicant') {
            this.formData.ReceivedFrom = value;
        }

        // Handle Mode of Payment
        if (name === 'EYI_Mode_of_Payment__c' || name === 'paymentMode') {
            this.formData.paymentMode = value;

            if (value === 'PDC Cheque') {
                console.log('inside PDC Cheque');
                this.showRealizationDate = true;
                this.showNonBankableCheque = true;
                this.NonBankablePayment = true;
                this.formData.NonBankablePayment = true;
            } else {
                this.showRealizationDate = false;
                this.formData.RealizationDate = '';
                this.showNonBankableCheque = false;
                this.NonBankablePayment = false;
                this.formData.NonBankablePayment = false;
            }
        }

        // Unified button control logic
        const mode = this.formData.paymentMode;
        const txn = this.formData.TransactionType;

        if (mode === 'PDC Cheque') {
            this.showSaveButton = true;
            this.NonBankablePayment = true;
            this.showFetchButton = false;
        } else if (txn === 'Advance' || txn === 'Token' || txn ==='TDS') {
            this.showSaveButton = true;
            this.showFetchButton = false;
        } else if (txn === 'Demand') {
            this.showSaveButton = false;
            this.showFetchButton = true;
        } else {
            this.showSaveButton = false;
            this.showFetchButton = false;
        }

        if (name === 'NonBankablePayment') {
            this.formData.NonBankablePayment = this.NonBankablePayment;
        }
         if (name === 'ChannelNumber') {
            this.formData.ChannelNumber = value;
        }

        if (name === 'ChannelDate') {
            this.formData.ChannelDate = value;
        }

        console.log('this.formdata ==> ', this.formData);
    }


    async validatePaymentReceipt() {
        let allValid = true;
        const inputFields = this.template.querySelectorAll('.validate');

        console.log('inputFields ==> ', inputFields);
        for (const inputField of inputFields) {
            inputField.setCustomValidity('');
            const value = inputField.value;
            const name = inputField.name || inputField.dataset.name;

            // Payment Amount validation
            if (name === 'PaymentAmount') {
                if (!value || value.trim() === '') {
                    inputField.setCustomValidity('Payment Amount is required.');
                } else if (isNaN(value) || parseFloat(value) <= 0) {
                    inputField.setCustomValidity('Payment Amount must be a valid positive number.');
                } else if (value.length > 18) {
                    inputField.setCustomValidity('Payment Amount maximum length is 18 digits.');
                }
            }

            // Bank Name validation
            if (name === 'EYI_Bank_Name__c' && (!value || value.length > 25)) {
                inputField.setCustomValidity('Bank Name maximum length is 25 characters.');
            }

            // Bank Name validation
            if (name === 'EYI_Bank_Name__c' && (!value || value.length > 25)) {
                inputField.setCustomValidity('Bank Name maximum length is 25 characters.');
            }

            // Conditional validation for Instrument or Cheque/DD Number
            if (name === 'InstrumentNumber' || name === 'ChequeDdNumber') {
                const mode = this.formData.paymentMode;
                const isChequeOrDD = mode === 'Cheque' || mode === 'DD';

                const shouldCheck =
                    (name === 'InstrumentNumber' && !isChequeOrDD) ||
                    (name === 'ChequeDdNumber' && isChequeOrDD);

                if (shouldCheck) {
                    if (!value || value.trim() === '') {
                        inputField.setCustomValidity(`${name === 'InstrumentNumber' ? 'Instrument' : 'Cheque/DD'} Number is required.`);
                    } else if (
                        name === 'ChequeDdNumber' &&
                        (!/^\d{6,9}$/.test(value.trim()))
                    ) {
                        inputField.setCustomValidity('Cheque/DD Number must be between 6 to 9 digits.');
                    } else if (
                        name === 'InstrumentNumber' &&
                        value.length > 22
                    ) {
                        inputField.setCustomValidity('Instrument Number maximum length is 22 digits.');
                    } else {
                        try {
                            let params = { fieldType: name, value };

                            if (name === 'ChequeDdNumber') {
                                const bankName = this.formData.EYI_Bank_Name__c;
                                if (!bankName || bankName.trim() === '') {
                                    inputField.setCustomValidity('Bank Name is required for Cheque/DD validation.');
                                    return;
                                }
                                params.bankName = bankName;
                            }
                            console.log('params.bankName : '+params.bankName);
                            
                            console.log('params : '+JSON.stringify(params));
                            
                            const result = await checkDuplicateNumber(params);

                            if (result === 'DUPLICATE') {
                                const label = name === 'InstrumentNumber' ? 'Instrument' : 'Cheque/DD';
                                inputField.setCustomValidity(`${label} Number${name === 'ChequeDdNumber' ? ' and Bank Name' : ''} already exists.`);
                            } else {
                                inputField.setCustomValidity('');
                            }
                        } catch (err) {
                            console.error('Duplicate check error:', err);
                            inputField.setCustomValidity(`Error checking ${name}. Try again.`);
                        }
                    }
                }
            }

            inputField.reportValidity();
            if (!inputField.checkValidity()) {
                console.log('inside checkValidity');
                allValid = false;
            }
        }
        console.log('allValid --> ',allValid);
        return allValid;
    }

    async handleSave() {

        let isValid;
        if(!this.isPDC){
            isValid = await this.validatePaymentReceipt();
            console.log('payment valid -->', isValid);
        }else{
            isValid = true;
        }
        if (!isValid) return;

        //this.isLoading = true;
        this.isSaving = true;
        const draftValues = Object.values(this.draftValues);
        const dataArray = Array.isArray(this.data) ? this.data : Object.values(this.data);

        const updatedRecords = dataArray.map(record => {
            const draft = draftValues.find(d => d.id == record.id);
            return {
                ...record,
                inputValue: draft ? draft.inputValue : (record.inputValue || '')
            };
        });

        console.log('updatedRecords : ' + updatedRecords);
        console.log('this.formData : ' + this.formData);
        console.log('form data===> ' + JSON.stringify(this.formData));
        console.log('this.uploadedFileId : ' + this.uploadedFileId);
        console.log('this.createAdvance : ' + this.createAdvance);
        console.log('this.advanceAmount : ' + this.advanceAmount);

        if (this.demandedAmount > this.paymentAmount && this.advanceAmount > 0) {
            this.showToast('Error', 'Please adjust all the balance amount and then save.', 'error');
           // this.isLoading = false;
            this.isSaving = false;
        } else if (this.demandedAmount < this.paymentAmount && this.draftValues.length !== this.data.length) {
            this.showToast('Error', 'Please adjust all the line items and then save.', 'error');
            //this.isLoading = false;
            this.isSaving = false;
        } else {
            this.isSaveDisabled = true;
            saveData({
                updatedRecords,
                opptyId: this.recordId,
                formData: this.formData,
                fileId: this.uploadedFileId
            })
            .then((resultMessage) => {
                const message = resultMessage || 'Data saved successfully.';
                this.showToast('Success', message, 'success');
                //window.location.reload();
                setTimeout(() => {
                    window.location.reload();
                }, 3000);
            })
            .catch(error => {
                this.isSaveDisabled = false;
                console.error('Save error:', error);
                const errMsg = error?.body?.message || 'An unexpected error occurred during save.';
                this.showToast('Error', 'Error saving data: ' + errMsg, 'error');
                //this.isLoading = false;
                this.isSaving = false;
            });
        }
    }

    paymentReceiptValidation() {
        const requiredFields = ['InstrumentDate', 'PaymentAmount', 'paymentMode', 'TransactionType','RealizationDate','CategoryofFunnding'];
        for (let field of requiredFields) {
            if (!this.formData[field] || this.formData[field].trim() === '') {
                this.showToast('Error', `Please fill in all required fields. Missing: ${field}`, 'error');
                return false;
            }
        }

        if ((!this.formData['InstrumentNumber'] || this.formData['InstrumentNumber'].trim() === '') &&
            (!this.formData['ChequeDdNumber'] || this.formData['ChequeDdNumber'].trim() === '')) {
            this.showToast('Error', 'Either Instrument Number or Cheque/DD Number is mandatory.', 'error');
            return false;
        }

        const paymentAmount = parseFloat(this.formData.PaymentAmount);
        if (isNaN(paymentAmount) || paymentAmount <= 0) {
            this.showToast('Error', 'Payment Amount must be a valid positive number.', 'error');
            return false;
        }
        
        let validationResult = { isValid: true };
        if (this.formData.TransactionType !== 'Advance') {
            validationResult = this.validateAdjustedAmounts(this.data, this.draftValues);
            if (!validationResult.isValid) {
                this.showToast('Validation Error', validationResult.message, 'error');
                return false;
            }
        }

        if ((this.formData.PaymentMode === 'Cheque' || this.formData.PaymentMode === 'DD') && !this.uploadedFileId) {
            this.showToast('Error', 'File upload is mandatory for Cheque and DD payment modes.', 'error');
            return false;
        }

        return true; // Validation passed
    }

    async handleFetchLineItems() {
        this.data = [];
        this.draftValues = [];
        let isValid;

        if(!this.isPDC){
            isValid = await this.validatePaymentReceipt();
            console.log('payment valid -->', isValid);
        }else{
            isValid = true;
        }
        if (!isValid) return;

        console.log('after click button');
        this.isLoading = true;
        this.showLineItems = true;

        fetchTableData({ recordId: this.recordId })
            .then(result => {
                this.data = result.map(row => ({
                    ...row,
                    PSTNG_DATE: /^\d{8}$/.test(row.PSTNG_DATE)
                        ? `${row.PSTNG_DATE.slice(0, 4)}-${row.PSTNG_DATE.slice(4, 6)}-${row.PSTNG_DATE.slice(6, 8)}`
                        : row.PSTNG_DATE
                }));

                this.isLoading = false;
                console.log('fetchTableData result:', JSON.stringify(this.data));
                console.log('data :: ' + JSON.stringify(this.data.INV_REF));

                this.lineItemSize = this.data.length;
                this.paymentAmount = this.formData.PaymentAmount;
                this.demandedAmount = this.data.reduce((sum, row) => sum + (parseFloat(row.outstanding) || 0), 0);
                console.log('==paymentAmount== ', this.paymentAmount);

                this.recalculateAmounts();

                if (!this.data || this.data.length === 0) {
                    this.showToast('No Records', 'No open line items found for this opportunity.', 'info');
                    this.showLineItems = false;
                }
            })
            .catch(error => {
                console.error('Error loading data:', error);
                this.showToast('Error', 'Error loading data: ' + error.body.message, 'error');
                this.isLoading = false;
            });
    }

    validateAdjustedAmounts(dataArray, draftValues) {
        console.log('inside validateAdjusted');
        let recalculatedSelectedAmount = 0;

        for (const record of dataArray) {
            const draft = draftValues.find(d => d.id == record.id);
            const inputValueStr = draft ? draft.inputValue : (record.inputValue || '');
            const inputValue = parseFloat(inputValueStr) || 0;

            const outstanding = parseFloat(record.outstanding) || 0;
            const amountLocalCurrency = parseFloat(record.amountLocalCurrency) || 0;

            if (record.outstanding != null && inputValue > outstanding) {
                return {
                    isValid: false,
                    message: `Adjusted amount for the line item ${record.fiDocumentNo} exceeds the outstanding amount.`
                };
            }

            if (inputValue > amountLocalCurrency) {
                return {
                    isValid: false,
                    message: `Adjusted amount for the line item ${record.fiDocumentNo} exceeds the Principal/Tax amount.`
                };
            }

            recalculatedSelectedAmount += inputValue;
        }

        const paymentAmount = parseFloat(this.formData.PaymentAmount) || 0;
        const epsilon = 0.01;


        if (this.createAdvance) {
            if (recalculatedSelectedAmount > paymentAmount) {
                return {
                    isValid: false,
                    message: `Total adjusted amount must be less than payment Amount when 'Create Advance' is selected.`
                };
            }
        } else {
            if (Math.abs(paymentAmount - recalculatedSelectedAmount) > epsilon) {
                return {
                    isValid: false,
                    message: `Please adjust the payment amount to match the total adjustment amount!`
                };
            }
        }

        this.advanceAmount = this.createAdvance ? 0 : parseFloat((paymentAmount - recalculatedSelectedAmount).toFixed(2));

        return {
            isValid: true
        };
    }


    handleCellChange(event) {
        const newDrafts = event.detail.draftValues || [];
        console.log('inside handle cell change');

        newDrafts.forEach(newDraft => {
            const existingIndex = this.draftValues.findIndex(d => d.id == newDraft.id);
            if (existingIndex !== -1) {
                this.draftValues[existingIndex] = { ...this.draftValues[existingIndex], ...newDraft };
            } else {
                this.draftValues.push(newDraft);
            }
        });

        let totalAdjusted = 0;
        this.draftValues.forEach(draft => {
            const val = parseFloat(draft.inputValue) || 0;
            totalAdjusted += val;
        });

        this.recalculateAmounts();
        // this.calculatedAmount = parseFloat(totalAdjusted.toFixed(2));

        // const paymentAmount = parseFloat(this.formData.PaymentAmount) || 0;
        // let advance = paymentAmount - totalAdjusted;
        // this.advanceAmount = advance >= 0 ? parseFloat(advance.toFixed(2)) : 0;

        const datatable = this.template.querySelector('lightning-datatable');
        if (datatable) {
            datatable.draftValues = this.draftValues;
        }
    }

    recalculateAmounts() {
        let totalAdjusted = 0;
        this.draftValues.forEach(draft => {
            const val = parseFloat(draft.inputValue) || 0;
            totalAdjusted += val;
        });

        this.calculatedAmount = parseFloat(totalAdjusted.toFixed(2));
        let paymentAmount = parseFloat(this.formData.PaymentAmount) || 0;
        let advanceOthAdv =0;
        this.formPaymentAmount = paymentAmount; // Anu created formPayment
        this.advanceAmount = paymentAmount;
        console.log('=this.advanceAmount==',this.advanceAmount )
        if (Array.isArray(this.data)) {
            this.data.forEach(da => {
            console.log('==da.paymentBifurcation==', da.paymentBifurcation);
            
            if (da.paymentBifurcation === 'ADV'){
                const amount = Number(da.amountLocalCurrency) || 0;
                
                console.log('amount of ADV and OTH==' +amount)
                                                  
                 if (this.showPaymentReceipt)
                {
                   
                   console.log('inside showpaymentReceipt');
                   advanceOthAdv = advanceOthAdv+ amount;
                   console.log('this.advanceAmount==', advanceOthAdv);
                }
                else {
                
                console.log('==da.amountLocalCurrency==', amount);
                paymentAmount += amount;
                }
            }
        });
        }
       let advance =0;
       if (this.showPaymentReceipt){
                           console.log('advance in OTH 1==', advanceOthAdv);

        this.formPaymentAmount = advanceOthAdv;
         advance = advanceOthAdv - totalAdjusted;     
                            console.log('advance in OTH 2==', advance);
 
       } else {
        this.formPaymentAmount = paymentAmount; 
        advance = paymentAmount - totalAdjusted;   
         console.log('advance in Normal==', advance);
       }
                console.log('advance outside==', advance);

       this.advanceAmount = advance >= 0 ? parseFloat(advance.toFixed(2)) : 0;
                       console.log('advanceAmount outside==', this.advanceAmount);

        this.formData.advanceAmount = this.advanceAmount;
    }

    handleUploadFinished(event) {

        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            this.uploadedFileId = uploadedFiles[0].documentId;
            this.showToast('Success', 'File uploaded successfully.', 'success');
        }
        this.uploadedFiles = uploadedFiles.map(file => ({
            name: file.name,
            documentId: file.documentId
        }));
    }

    previewFile(event) {
        const docId = event.target.dataset.id;
        //window.open(`/sfc/servlet.shepherd/document/download/${docId}`, '_blank');
        window.open(`https://panchshil.lightning.force.com/${docId}`, '_blank');

    }

    removeFile(event) {
        const docIdToRemove = event.target.dataset.id;
        this.uploadedFiles = this.uploadedFiles.filter(file => file.documentId !== docIdToRemove);
    }

    handleAdvanceToggle(event) {
        this.createAdvance = event.target.checked;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }


    /*
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('Selected rows:', selectedRows);
        console.log('Advance inside handle row:', this.advanceAmount);

        // Track valid selection
        const newSelectedRowIds = new Set();
        let cumulativeAmount = 0;
        console.log('cumulativeAmount initial:', cumulativeAmount);
        console.log('this.PaymentAmount ==> ', this.paymentAmount);
        console.log('this.advanceAmount ==>', this.advanceAmount);
        //console.log('this.formPaymentAmount ==>', this.formPaymentAmount);
        this.recalculateAmounts();

        // Filter valid rows based on remaining advanceAmount
        for (let row of selectedRows) {
            const rowAmount = (parseFloat(row.outstanding) || parseFloat(row.amountLocalCurrency) || 0) ;
            //Anu's changes- replaced with formpayment
            if (this.advanceAmount > 0){
                if (cumulativeAmount + rowAmount <= this.paymentAmount) {
                    newSelectedRowIds.add(row.id);
                    cumulativeAmount += rowAmount;
                }else {
                    console.log('inside Advance condition');
                    newSelectedRowIds.add(row.id);
                    cumulativeAmount += this.advanceAmount;
                }
            }

        }
        console.log('cumulativeAmount final:', cumulativeAmount);

        // Anu Changes - Update the tracked selected rows
        if(newSelectedRowIds!=null || newSelectedRowIds!=undefined){
             this.selectedRowIds = newSelectedRowIds;
        } else {
              this.selectedRowIds = selectedRows;
        }

        // Reflect valid selection back in the datatable
        const datatable = this.template.querySelector('lightning-datatable');
        if (datatable) {
            datatable.selectedRows = Array.from(this.selectedRowIds);
        }
        /*
        this.draftValues = Array.from(this.selectedRowIds).map(id => {
            const row = selectedRows.find(r => r.id === id);
            const rowAmount = parseFloat(row.amountLocalCurrency) ?? 0;
            const outstandingAmount = parseFloat(row.outstanding) ?? 0;
            return {
                id: row.id,
                inputValue: (this.advanceAmount < rowAmount) 
                    ? (this.advanceAmount ?? 0).toFixed(2) 
                    : (outstandingAmount || rowAmount || 0).toFixed(2)
                };
        });

        console.log('Before setting draftValues:', JSON.stringify(this.draftValues));
        var dataSize = this.draftValues.length;
        var counter=0;

        if(this.advanceAmount > 0){            
            this.draftValues = Array.from(this.selectedRowIds).map(id => {
                console.log('inside draft values');
                const row = selectedRows.find(r => r.id === id);
                counter+=1;
                console.log('this.row',row);
                return { 
                    id: row.id, 
                    inputValue: ((this.advanceAmount < row.outstanding)&& (dataSize < counter) ) 
                        ? (this.advanceAmount ?? 0).toFixed(2) 
                        : (parseFloat(row.outstanding) || parseFloat(row.amountLocalCurrency) || 0).toFixed(2)
                }; 
            });
            console.log('After setting draftValues:', JSON.stringify(this.draftValues));
        }
        if(this.advanceAmount == 0 || this.lineItemSize == this.draftValues.length  ){
            this.isSaveDisabled = false;
        }

        /*
        // Set draft values for editable fields
        this.draftValues = Array.from(this.selectedRowIds).map(id => {
            const row = selectedRows.find(r => r.id === id);
            return {
                id: row.id,
                inputValue: (this.advanceAmount < parseFloat(row.amountLocalCurrency)) 
                    ? this.advanceAmount.toFixed(2) 
                    : (parseFloat(row.outstanding) || parseFloat(row.amountLocalCurrency) || 0).toFixed(2)
            };
        });
    } */

    selectedRowIds = new Set();
    previouslySelectedRows = new Set(); // to track previously selected rows

    // Added by Rishikesh on 16 june to restructure entire logic
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows || [];
        const newSelectionSet = new Set(selectedRows.map(row => row.id));

        // Detect new selections
        const previouslySelected = this.previouslySelectedRows || new Set();
        const newlySelected = [...newSelectionSet].filter(id => !previouslySelected.has(id));

        // Prevent new selections if balance is 0
        if (this.advanceAmount === 0 && newlySelected.length > 0) {
            this.showToast('Warning', 'Balance is zero. Please unselect an existing row before adding another.', 'Warning');

            // Revert selection to previous valid state
            const datatable = this.template.querySelector('lightning-datatable');
            if (datatable) {
                datatable.selectedRows = Array.from(previouslySelected);
            }
            return;
        }

        // Update selection tracking
        this.selectedRowIds = newSelectionSet;
        this.previouslySelectedRows = newSelectionSet;

        // Remove deselected rows from draftValues
        const deselected = [...previouslySelected].filter(id => !newSelectionSet.has(id));
        this.draftValues = this.draftValues.filter(d => !deselected.includes(d.id));

        // Add missing selected rows to draftValues
        this.rebuildDraftValues(selectedRows);

        this.recalculateAmounts();

        this.isSaveDisabled = !(this.advanceAmount === 0 || this.lineItemSize === this.draftValues.length);
    }

    // Added by Rishikesh on 16 june to restructure entire logic
    rebuildDraftValues(selectedRows) {
        let counter = this.draftValues.length;

        selectedRows.forEach(row => {
            const existing = this.draftValues.find(d => d.id === row.id);
            if (!existing) {
                const rowAmount = parseFloat(row.outstanding) || parseFloat(row.amountLocalCurrency) || 0;
                const inputValue = (
                    (this.advanceAmount < rowAmount && this.advanceAmount > 0)
                        ? this.advanceAmount
                        : rowAmount
                );
                this.draftValues.push({
                    id: row.id,
                    inputValue: inputValue.toFixed(2)
                });
                counter++;
            }
        });
    }
}