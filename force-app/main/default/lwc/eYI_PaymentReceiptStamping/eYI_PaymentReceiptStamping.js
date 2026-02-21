import { LightningElement, api, track } from 'lwc';
import saveData from '@salesforce/apex/EYI_SAP_DemandReceiptController.createLineItems';
import fetchTableData from '@salesforce/apex/EYI_SAP_DemandReceiptController.getApiData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PaymentReceiptStamping extends LightningElement {
    @api recordId;
    @track data = [];
    @track columns = [
        { label: 'Customer Number', fieldName: 'companyCode', type: 'text' },
        { label: 'Customer Name', fieldName: 'customerNumber', type: 'text' },
        { label: 'FI Document No.', fieldName: 'fiDocumentNo', type: 'text' },
        { label: 'Fiscal Year', fieldName: 'fiscalYear', type: 'text' },
        { label: 'Number of Line Item Within Accounting Document', fieldName: 'lineItemNo', type: 'text' },
        { label: 'Principal/Tax Amount', fieldName: 'amountLocalCurrency', type: 'currency' },
        { label: 'Adjustment Amount', fieldName: 'inputValue', type: 'currency', editable: true },
        { label: 'Outstanding Amount', fieldName: 'outstanding', type: 'currency' },
        { label: 'Billing Doc.', fieldName: 'billingDoc', type: 'text' },
        { label: 'Milestone No.', fieldName: 'milestoneNo', type: 'text' },
        { label: 'Unit Code (SAP)', fieldName: 'unitCodeSAP', type: 'text' },
        { label: 'Bifurcation of Payment (SC/GST/OTH)', fieldName: 'paymentBifurcation', type: 'text' }
       
        
    ];
    @track draftValues = [];
    @track selectedRowIds = [];
    @track isLoading = false;
    @track createAdvance = false;
    @track selectedAmountSummary = 0;
    @track paymentAmount = 0;
    @track showTable = false; // Controls visibility of table + UI

    fetchData() {
        this.isLoading = true;
        fetchTableData({ recordId: this.recordId })
            .then(result => {
                if (result && result.length > 0) {
                    this.data = result;
                    this.showTable = true;
                } else {
                    this.data = [];
                    this.showTable = false;
                    this.showToast('Info', 'No data found for this record.', 'info');
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching data:', error);
                this.showToast('Error', 'Error fetching data: ' + error.body.message, 'error');
                this.isLoading = false;
                this.showTable = false;
            });
    }

    handleToggleChange(event) {
        this.createAdvance = event.target.checked;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowIds = selectedRows.map(row => row.id);

        let total = 0;
        let inputTotal = 0;
        selectedRows.forEach(row => {
            const val = parseFloat(row.amountLocalCurrency);
            const inputVal = parseFloat(row.inputValue);
            if (!isNaN(val)) {
                total += val;
                inputTotal += inputVal;
            }
        });
        this.selectedAmountSummary = total.toFixed(2);
    }

    handleSave(event) {
        this.isLoading = true;
    
        // Get the advance amount input from the DOM
        const paymentAmount = this.paymentAmount
    
        // Validate advance amount vs selected amount
        
    
        const draftValues = Object.values(event.detail?.draftValues || this.draftValues);
        const dataArray = Array.isArray(this.data) ? this.data : Object.values(this.data);
        let recalculatedSelectedAmount = 0;
        
        const updatedRecords = dataArray.map(record => {
            const draft = draftValues.find(d => d.id == record.id);
            const inputValueStr = draft ? draft.inputValue : (record.inputValue || '');
            const inputValue = parseFloat(inputValueStr) || 0;
            recalculatedSelectedAmount += inputValue;
    
            return {
                ...record,
                inputValue: inputValueStr
            };
        });
        console.log('Final updated records:', JSON.stringify(updatedRecords));
        if (paymentAmount > recalculatedSelectedAmount && !this.createAdvance) {
            this.isLoading = false;
            this.showToast('Error', 'Advance Amount cannot be greater than Selected Amount.', 'error');
            return;
        }
        
    
        saveData({ updatedRecords, paymentReceiptId: this.recordId, createAdvance: this.createAdvance })
            .then(() => {
                this.showToast('Success', 'Data saved successfully.', 'success');
                window.location.reload();
            })
            .catch(error => {
                console.error('Save error:', error);
                this.showToast('Error', 'Error saving data: ' + error.body.message, 'error');
                this.isLoading = false;
            });
    }
    
    handlePaymentAmountChange(event) {
        this.paymentAmount = parseFloat(event.target.value) || 0;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant,
        }));
    }
}