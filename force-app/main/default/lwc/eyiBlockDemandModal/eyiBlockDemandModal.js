import { LightningElement, api, track } from 'lwc';
import saveDemand from '@salesforce/apex/EYI_InventoryMatrixController.saveDemand';
import getDemandDetails from '@salesforce/apex/EYI_InventoryMatrixController.getDemandDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EyiBlockDemandModal extends LightningElement {
    @track demanddata = []; // Use track to enable reactivity
    @api selectedDemandRecord = [];
    @api action='';
    @api isSpinner = false ;
    //@api hideDateField = true;
    @api date = new Date(); // creates a Date object for February 10, 2025
       formattedDate ;
    

    connectedCallback() {
        this.formattedDate = this.date.toISOString();
        console.log('recordIds in child component:', JSON.stringify(this.selectedDemandRecord));
        console.log('child action:', JSON.stringify(this.action));
        if (this.selectedDemandRecord) {
            this.handleFetchdata();
        } else {
            console.error('recordIds is undefined or empty in child component');
        }
    }

    handleFetchdata() {
        let SNO = 1;
        getDemandDetails({ recordIds: this.selectedDemandRecord })
            .then(result => {
                console.log('result:', JSON.stringify(result));
                this.demanddata = result.map((record, index) => ({
                    sno: SNO + index,
                    Id: record.Id,
                    EYI_Usage_Description__c: record.EYI_Usage_Description__c,
                    CustName: record.EYI_Opportunity__r.Name,
                    actualDate: record.EYI_Actual_Date__c 
                    ? new Date(record.EYI_Actual_Date__c).toISOString().split('T')[0] 
                    : '',
                    EYI_Billing_Date__c: record.EYI_Billing_Date__c || '',
                    EYI_Milestone_Block_Date__c: this.formattedDate,
                    EYI_Demand_Type__c:record.EYI_Demand_Type__c == 'CLP'?'Time Bound':record.EYI_Demand_Type__c,
                    
                }));
                console.log('demanddata:', JSON.stringify(this.demanddata));
            })
            .catch(error => {
                console.error('Error fetching data:', error);
            });
    }

    formatDateTo_DD_MMM_YYYY(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const day = String(date.getDate()).padStart(2, '0');
        const month = date.toLocaleString('en-US', { month: 'short' });
        const year = date.getFullYear();
        return `${day}-${month}-${year}`;
    }

    handleInputChange(event) {
        /*const inputCmp = event.target;
        const selectedDateStr = inputCmp.value;
        const selectedDate = new Date(selectedDateStr);
        const today = new Date(this.todaysDate);
        if (selectedDate < today) {
            inputCmp.setCustomValidity("Please select a date from today onwards.");
        } else {
            inputCmp.setCustomValidity(""); // Clear error
        }
        inputCmp.reportValidity();
        const recordId = inputCmp.dataset.id;
        const field = inputCmp.dataset.field;   
        this.demanddata = this.demanddata.map(item =>
            item.Id === recordId ? { ...item, [field]: selectedDateStr } : item
        );
        console.log('demanddata:', JSON.stringify(this.demanddata));*/
        const inputCmp = event.target;
    const inputValue = inputCmp.value;
    const field = inputCmp.dataset.field;
    const recordId = inputCmp.dataset.id;

    // If the field is a date, perform date validation
    if (inputCmp.type === 'date') {
        const selectedDate = new Date(inputValue);
        const today = new Date(this.todaysDate);

        // Validation: no past dates
        if (selectedDate < today) {
            inputCmp.setCustomValidity("Please select a date from today onwards.");
        } else {
            inputCmp.setCustomValidity(""); // Clear error
        }
        inputCmp.reportValidity();
    }

    // Update the demanddata list
    this.demanddata = this.demanddata.map(item =>
        item.Id === recordId ? { ...item, [field]: inputValue } : item
    );

    console.log('Updated demanddata:', JSON.stringify(this.demanddata));
    }
    
    
    
    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }
    get todaysDate() {
        const today = new Date();
        today.setHours(0, 0, 0, 0); // clear time
        const dd = String(today.getDate()).padStart(2, '0');
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const yyyy = today.getFullYear();
        return `${yyyy}-${mm}-${dd}`; // YYYY-MM-DD
    }
    
    handleSave() {
        console.log('handleSave demanddata:', JSON.stringify(this.demanddata));
        this.isSpinner = true;
        const todayStr = this.todaysDate;
        const today = new Date(todayStr);
        today.setHours(0, 0, 0, 0);
        
        const hasInvalidDate = this.demanddata.some(item => {
            const dateStr = item.EYI_Actual_Date__c; // 🛑 Replace with actual date field name
            console.log('Checking date:', dateStr);
    
            if (!dateStr || dateStr.trim() === '') {
                console.warn('Missing date in item:', item);
                return true;
            }
    
            const selectedDate = new Date(dateStr);
            selectedDate.setHours(0, 0, 0, 0);
            if (selectedDate < today) {
                console.warn('Date is in the past:', item);
                return true;
            }
    
            return false;
        });
    
        if (hasInvalidDate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'All dates must be filled and not in the past.',
                    variant: 'error'
                })
            );
            return;
        }
    
        // ✅ Save
        saveDemand({ demanddatalist: JSON.stringify(this.demanddata), Action: this.action })
            .then(result => {
                this.isSpinner = false;
                let toastVariant = 'Success';
                console.log('Data saved successfully:', result);
                console.log('Data saved successfully:', JSON.stringify(result));
                if (result.includes('Error:')) {
                        toastVariant = 'Error';  // Set variant to 'error' if 'Error:' is found
                    }
                    
                this.dispatchEvent(
                        new ShowToastEvent({
                            title: toastVariant,
                            message: JSON.stringify(result),
                            variant: toastVariant
                        })
                );
                
                this.handleCancel();
                if (toastVariant === 'Success') {
                    setTimeout(function() {
                        window.location.reload();
                    }, 3000); // 3000 milliseconds = 3 seconds
                }
            })
            .catch(error => {
                console.error('Error saving data:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to save demand data.',
                        variant: 'error'
                    })
                );
            });
    }
    
    

}