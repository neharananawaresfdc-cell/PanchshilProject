import { LightningElement, track, wire,api } from 'lwc';
import getProjectList from '@salesforce/apex/EYI_InventoryMatrixController.getAllProjects';
import getTowerList from '@salesforce/apex/EYI_InventoryMatrixController.getAllTowers';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Demand_OBJECT from '@salesforce/schema/EYI_Demand__c';
import Demand_Type_FIELD from '@salesforce/schema/EYI_Demand__c.EYI_Demand_Type__c';
import USAGE_DESCRIPTION_FIELD from '@salesforce/schema/EYI_Demand__c.EYI_Usage_Description__c';
import Demand_Status_FIELD from '@salesforce/schema/EYI_Demand__c.EYI_Demand_Status__c';
import fetchDemands from '@salesforce/apex/EYI_InventoryMatrixController.fetchDemands';
import raiseDemandsFromLWC from '@salesforce/apex/EYI_InventoryMatrixController.raiseDemandsFromLWC';
import downloadPDF from '@salesforce/apex/EYI_GenerateBillingPDFController.getGeneratingFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import pageSizeForDemandList from "@salesforce/label/c.EYI_PageSizeForDemandList";

export default class EyiDemandListView extends LightningElement {
    @track demanddata = [];
    @track selectedDemandData = [];
    @track isBlockDemand = false;
    @track isSpinner = false;
    @track selectedDemandIds = [];


   // allcolumns = columns;
    //columns = columns;
    @track Action ='';
    @track towername=[];
    @track selectedProject='';
    @track selectedUsageDescription='';
    @track selectedDemandStatus='';
    @track selectedDemandrecord=[];
    @track towerOptions=[];
    @track filteredProjectOptions = [];
    @track filteredUsageDescription =[];
    @track filteredTowerOptions = [];
    @track filteredDemandTypeOptions = [];
    @track filteredDemandStatusOptions = [];
     isModalOpen = false;
    @track selectedDemandRecordList = {};
    billingDateFrom = '';
    billingDateTo = '';
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
    @track isLoading = false;
    @track isBlockDemandDisabled = true;
    @track isRaiseDemandDisabled = true;
    @track isSentDemandDisabled = true;
    @track isCancelDemandDisabled = true;
    @track isShowSpinner = false;

    @track currentPage = 1;
    @track pageSize = pageSizeForDemandList;//100;
    @track totalPages = 0;
    @track paginatedData = [];
    columns = [
        // { label: 'Sr. No.', fieldName: 'sno' },
        
         { 
             label: 'Demand Name', 
             fieldName: 'recordLink', 
             type: 'url', 
             cellAttributes: {
                 class: { fieldName: 'cellClass' }   
             },
             typeAttributes: { label: { fieldName: 'invoiceDemand' }, target: '_blank', } 
         },
         { label: 'Sales Order Number', fieldName: 'salesOrderNumber', type: 'text',wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         }},
         { label: 'Customer Code', fieldName: 'customerCode', type: 'text', wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         }},
         { label: 'Customer Name', fieldName: 'customerName', type: 'text',wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         } },
         { label: 'Unit No.', fieldName: 'unitNo', type: 'text',wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         } },
         { label: 'Usage Description', fieldName: 'usageDescription', type: 'text' ,wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         }},
         { label: 'Demand Amount', fieldName: 'demandAmount', type: 'currency', wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         } },
         
         
         
         //{ label: 'Milestone Name', fieldName: 'milestoneName', type: 'text' },
         
         //{ label: 'Booking Status', fieldName: 'bookingStatus', type: 'text' },
         { label: 'Demand Status', fieldName: 'demandTrigger', type: 'text',wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         }},
         { label: 'Actual Date', fieldName: 'trackingDate', type: 'date',wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         } },
        //  { label: 'Usage Code', fieldName: 'demandCode', type: 'text',wrapText: true, cellAttributes: {
        //      class: { fieldName: 'cellClass' }
        //  }},
         { label: 'E-Sign', fieldName: 'esignChecked', type: 'checkbox',wrapText: true, cellAttributes: {
             class: { fieldName: 'cellClass' }
         }},
         { 
             label: 'Invoice/Demand', 
             fieldName: 'invoiceDemand', // URL is stored here
             type: 'button', 
             
            cellAttributes: {
                class: { fieldName: 'cellClass' }
            },
            
             typeAttributes: {  
                 label: 'View Demand', // Static display value
                 name: 'open_invoice',  
                 variant: 'base',  
                 iconName: 'utility:new_window',  
                 iconPosition: 'right',
                 disabled: { fieldName: 'disableInvoiceButton' }
                
             }  
         }
     ];

    
    @track requestData = {
        GetSapDocument:{
            DocumentNo: null,
            CompanyCode: null,
            AccountingDocNo: null,
            FiscalYear: null,
            DocumentType: null
        }
    }
    @track recordData;
    connectedCallback() {
        const data = this.generateData({ amountOfRecords: 100 });
        this.data = data;
        this.selectedDemandIds = [];
    }

    @wire(getProjectList)
    getProjectList({ error, data }) {
        if (data) {
            this.projectOptions = [
                { label: 'None', value: '', projectType: null },
                { label: 'All', value: 'All', projectType: null }, // Add "none" option first
                ...data.map(proj => ({
                    label: proj.Name,
                    value: proj.Id,
                    projectType: proj.EYI_Project_Type__c
                }))
            ];
            this.filteredProjectOptions = this.projectOptions;
        } else if (error) {
            this.showToast(ERROR_MESSAGE);
        }
    }
    @wire(getObjectInfo, { objectApiName: Demand_OBJECT })
    objectInfo;
     // Fetch Picklist Values
     @wire(getPicklistValues, { 
        fieldApiName: Demand_Type_FIELD, 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId' 
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
        
            this.filteredDemandTypeOptions = [
                { label: 'All', value: 'All' }, // Add this at the beginning
                ...data.values.map(item => ({
                    label: item.label,
                    value: item.value
                }))
            ];
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }
    @wire(getPicklistValues, {
        fieldApiName: USAGE_DESCRIPTION_FIELD,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId'
    })
    wiredCollectibleStatus({ error, data }) {
        if (data) {
            this.filteredUsageDescription = [
                { label: 'All', value: 'All' },
                ...data.values.map(item => ({
                    label: item.label,
                    value: item.value
                }))
            ];
        } else if (error) {
            console.error('Error fetching Collectible Status:', error);
        }
    }

    @wire(getPicklistValues, { 
        fieldApiName: Demand_Status_FIELD, 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId' 
    })
    wiredPicklistValue({ error, data }) {
        if (data) {
            this.filteredDemandStatusOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }
    

    @wire(getTowerList)
    getTowerList({ error, data }) {
        if (data) {
            this.towerOptions = [
                { label: 'None', value: '', projectId: null },
                { label: 'All', value: 'All', projectType: null }, // Add "none" option first
                ...data.map(towr => ({
                    label: towr.Name,
                    value: towr.Id,
                     projectId: towr.EYI_Project_Name__c
                }))
            ];
            this.filteredTowerOptions =this.towerOptions;
           
        } else if (error) {
            this.showToast(ERROR_MESSAGE);
        }
    }
    filterTowers(){
        this.demanddata = [];
        let filtered = this.towerOptions.filter(subTower =>
            subTower.projectId === this.selectedProject
        );
        this.filteredTowerOptions = [
            { label: 'All', value: 'All' },
            ...filtered.map(tower => ({
                label: tower.label,
                value: tower.value
            }))
        ];

    }

    handleChange(event) {
        try {
            let field = event.target.name;
            let value = event.target.value;
            console.log('this.field '+field);
            console.log('this.value '+value);
            if (field === 'project') {
                this.selectedProject = value;
                this.selectedDemand ='';
                this.selectedDemandStatus ='';
                this.filterTowers();
                const selectedOption = this.projectOptions.find(option => option.value === value);
                this.selectedProjectTitle = selectedOption ? selectedOption.label : '';
            }else if(field === 'usageDescription'){
                this.selectedUsageDescription = value;  
            } else if (field === 'projectType') {
                this.selectedProjectType = value;
                this.showProperty = false;
                this.groupedData = [];
                this.selectedTower = '';
                this.selectedFloor = '';
                this.selectedSubProject = '';
                this.selectedDemand ='';
                this.selectedDemandStatus ='';
                this.filterProjects();
                if (this.selectedProjectType == 'Plot') {
                    this.isPlotting = true;
                } else {
                    this.isPlotting = false;
                }
            } else if (field === 'subProject') {
                this.selectedSubProject = value;
                this.filteredTowerOptions = [];
                this.demanddata = []; // clear previous data if any
                this.filterTowers();
                this.filterFloors();
            } else if (field === 'tower') {
                this.selectedTower = value;
                this.selectedDemand ='';
                this.selectedDemandStatus ='';
                this.demanddata = []; // clear previous data if any
                const selectedOption = this.filteredTowerOptions.find(option => option.value === value);
                this.selectedTowerTitle = selectedOption ? selectedOption.label : '';
            }else if (field === 'demand') {
                this.demanddata = []; // clear previous data if any
                this.selectedDemand = value;
                const selectedOption = this.filteredDemandTypeOptions.find(option => option.value === value);
                this.selectedDemandTitle = selectedOption ? selectedOption.label : '';

            }else if (field === 'demandStatus') {
                this.demanddata = []; // clear previous data if any
                this.selectedDemandStatus = value;
                const selectedOption = this.filteredDemandStatusOptions.find(option => option.value === value);
                this.selectedDemandTitle = selectedOption ? selectedOption.label : '';
                this.demanddata = []; // clear previous data if any
            }
            else if (field === 'input1') {
                    this.billingDateFrom = value;
                //console.log('this.billingDateFrom =>', this.billingDateFrom);
            } else if (field === 'input2') {
                    this.billingDateTo = value;
                //console.log('this.billingDateTo =>', this.billingDateTo);
            }else if (field === 'floor') {
                     this.selectedFloor = value;
            } else if (field === 'unitStatus') {
                this.selectedUnitStatus = event.detail.value; // For multi-select or dual listbox
            } else if (field === 'unitView') {
                this.selectedUnitView = event.detail.value; // For multi-select or dual listbox
            }else if(field === 'Customer Number'){
                this.custNumber = event.detail.value;
            }
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    generateData() { }
    // Display tast message for given error message
    showErrorToast(message) {
        try {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    handleClick() {
        console.log('inside handleClick');
        
        this.demanddata = []; // clear previous data if any
        if (!this.validateFields()) {
            this.demanddata = []; // clear previous data if any
            return;
        }

        
        let SNO = 1; 
        fetchDemands({
            project: this.selectedProject || null,
            usageDescription: this.selectedUsageDescription || null, 
            tower: this.selectedTower || null,
            demandType: this.selectedDemand || null,
            demandStatus: this.selectedDemandStatus || null,
           billingDateFrom: this.billingDateFrom || null,
           billingDateTo: this.billingDateTo || null,
           customerNumber: this.custNumber || null

        })
        .then(result => {
            console.log('fetch data result::', JSON.stringify(result));
        
            
           /* this.demanddata*/ const allData = result.map((record, index) => ({
                 

                    cellClass: this.selectedDemandStatus === 'Open' ? (
                        record.EYI_Opportunity__r?.EYI_Total_Pending_Booking_Amount_in_Per__c < 99.99 &&
                        record.EYI_Opportunity__r?.EYI_Registration_Status__c !== 'Registration Completed'
                    ) ? 'slds-box slds-theme_error hoverable-cell' : '' :'',

                   
                    sno: SNO + index,
                    id: record.Id,
                    recordLink: '/' + record.Id, 
                    customerCode: record.EYI_Opportunity__r?.EYI_SAP_Customer_Number__c || '',
                    salesOrderNumber: record.EYI_Booking__r?.EYI_SAP_Sales_Order_Number__c || '',  // Correct field name
                    usageDescription:record.EYI_Usage_Description__c,
                    invoiceDemand: record.Name,
                    customerName: record.EYI_Opportunity__r?.Name || '',
                    unitNo: record.EYI_Opportunity__r?.EYI_Inventory__r?.EYI_Inventory_Number__c || '',
                    milestoneName: record.EYI_SAP_Milestone_Code__c,
                    demandAmount: record.EYI_Amount_to_be_paid__c || 0,
                    bookingStatus: record.EYI_Opportunity__r?.StageName || '',
                    demandTrigger: record.EYI_Demand_Status__c || '',
                    trackingDate: record.EYI_Actual_Date__c || '',
                    demandCode: record.EYI_Usage__c || '',
                    EYI_SAP_Demand_Number__c: record.EYI_SAP_Demand_Number__c || '',
                    disableInvoiceButton: record.EYI_Demand_Status__c === 'Open',
                    esignChecked: record.EYI_ESIGN_FLAG__c
                   // isWarning: isWarning,
                   // cellClass: 'slds-text-color_error slds-theme_shade'
                   
                    
                }));

                if(this.selectedDemandStatus == 'Demand Sent'){
                this.isBlockDemandDisabled = true;
                this.isRaiseDemandDisabled = true;
                this.isSentDemandDisabled = true; 
                this.isCancelDemandDisabled = false; 
                }else if(this.selectedDemandStatus == 'Demand Raised'){
                    this.isBlockDemandDisabled = true;
                    this.isRaiseDemandDisabled = true;  
                    this.isSentDemandDisabled = false; 
                    this.isCancelDemandDisabled = true;
                }else if(this.selectedDemandStatus == 'In progress'){
                    this.isBlockDemandDisabled = true;
                    this.isRaiseDemandDisabled = false;  
                    this.isSentDemandDisabled = false; 
                    this.isCancelDemandDisabled = true;
                }else{
                    this.isBlockDemandDisabled = false;
                    this.isRaiseDemandDisabled = false;
                    this.isSentDemandDisabled = true; 
                    this.isCancelDemandDisabled = true;
                }  
                console.log('demand data ::', JSON.stringify(this.demanddata));
                 this.demanddata = allData;
                 this.totalPages = Math.ceil(this.demanddata.length / Number(this.pageSize));

                 this.currentPage = 1;
                 this.setPaginatedData();
        })
        .catch(error => {
            console.error('Error fetching data:', error);
        });
    }
    setPaginatedData() {
    const start = (this.currentPage - 1) * Number(this.pageSize);
    const end = start + Number(this.pageSize);
    console.log('start : '+start);
    console.log('end : '+end);
    this.paginatedData = this.demanddata.slice(start, end);
    console.log('this.paginatedData: '+this.paginatedData.length);
    
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.setPaginatedData();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.setPaginatedData();
        }
    }
    get isFirstPage() {
    return this.currentPage <= 1;
}

get isLastPage() {
    return this.currentPage >= this.totalPages;
}

    validateFields() {
        let isValid = true;
        let firstInvalid = null;
        const requiredFields = ['project', 'tower', 'demand', 'status'];
        requiredFields.forEach(fieldId => {
            const input = this.template.querySelector(`[data-id="${fieldId}"]`);
            if (input && !input.checkValidity()) {
                input.reportValidity();
                if (!firstInvalid) firstInvalid = input;
                isValid = false;
            }
        });
        if (firstInvalid) firstInvalid.focus();
        return isValid;
    }
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows.map(row => row.id);
        // If no rows are selected, clear the array
        if (selectedRows.length === 0) {
            this.selectedDemandrecord = [];
            return;
        }
        this.selectedDemandrecord = this.selectedDemandrecord.filter(id => selectedRows.includes(id));
        selectedRows.forEach(id => {
            if (!this.selectedDemandrecord.includes(id)) {
                this.selectedDemandrecord.push(id);
                this.selectedDemandIds.push(id);
            }
        });
        console.log('selectedrows==>',JSON.stringify(this.selectedDemandrecord));
    }
    async handleClickRaiseDemand(){
        console.log('selectedDemandIds==>:', JSON.stringify(this.selectedDemandIds));

        this.Action='RAISE';
        if (!this.selectedDemandrecord || this.selectedDemandrecord.length === 0) { 
            this.showErrorToast('Please select a demand record first.');
            return;
        }
        this.isModalOpen = true;
       // this.isSpinner = true;
        if (this.selectedDemandIds) {
            await this.raiseDemands();
        } else {
            console.error('recordIds is undefined or');
        }
    }
    async handleClickSendDemand(){
        this.Action='SENT';
        if (!this.selectedDemandrecord || this.selectedDemandrecord.length === 0) { 
            this.showErrorToast('Please select a demand record first.');
            return;
        }
        this.isModalOpen = true;
       // this.isSpinner = true;
        if (this.selectedDemandIds) {
           await this.raiseDemands();
        } else {
            console.error('recordIds is undefined or');
        }
    }
    handleClickBlockDemand() {
        this.isBlockDemand = true;
        this.Action='BLOCK';
        if (!this.selectedDemandrecord || this.selectedDemandrecord.length === 0) { 
            this.showErrorToast('Please select a demand record first.');
            return;
        }
        this.isModalOpen = true;
    }
    async handleClickCancelDemand() {
        this.Action='CANCEL';
        if (!this.selectedDemandrecord || this.selectedDemandrecord.length === 0) { 
            this.showErrorToast('Please select a demand record first.');
            return;
        }
        this.isModalOpen = true;
        this.isSpinner = true;
        if (this.selectedDemandIds) {
            await this.raiseDemands();
        } else {
            console.error('recordIds is undefined or');
        }
    }
    closeModal() {
        this.isModalOpen = false;
        this.isSpinner = false;
        this.isBlockDemand = false;
        //window.location.reload();
    }
    handleRowAction(event) {
        //Define Demand letter method call here
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'open_invoice') {
            this.isShowSpinner = true;
            console.log('this.isShowSpinner : '+this.isShowSpinner);
            
            // Set recordData to the selected row
            console.log('demand data in action ',JSON.stringify(this.demanddata));
            console.log('row data in action ',row.invoiceDemand);
            this.recordData = this.demanddata.find(demand => demand.invoiceDemand === row.invoiceDemand);
    
            console.log('Selected Record Data:', JSON.stringify(this.recordData));
    
            // Call the demand letter method
            this.generateDemandLetter();
        }
    }
    generateDemandLetter(){
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
                        console.log('insideif')
                        this.requestData.GetSapDocument.DocumentNo = this.recordData.EYI_SAP_Demand_Number__c,
                        
                        this.requestData.GetSapDocument.DocumentType  = 'DEMAND'
                    console.log(JSON.stringify(this.requestData));
                    this.jsonString = JSON.stringify(this.requestData);
                    console.log('this.jsonString-->' + this.jsonString);
                    //this.isShowSpinner = false;
                    this.getPdf(this.jsonString);
                }

    }
    getPdf(data){
        
        downloadPDF({ requestJsonString: data,/*bookingId:this.idBooking*/ }).then(response => {
            console.log('response-->'+response);
            if (response) {
                this.isShowSpinner = false;                
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
                this.isShowSpinner = false;
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
            this.isShowSpinner = false;
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

    
    
    raiseDemands() {

         let confirmMessage = '';
    let toastTitle = '';
    
    if (this.Action === 'RAISE') {
        confirmMessage = 'Are you sure you want to raise demands for the selected records?';
        toastTitle = 'Demand Raised';
    } else if (this.Action === 'SENT') {
        confirmMessage = 'Are you sure you want to send the selected demands?';
        toastTitle = 'Demand Sent';
    }

    
    return LightningConfirm.open({
        message: confirmMessage,
        variant: 'header',
        label: 'Confirmation Required'
    })
    .then((result) => {
        if (result) {
            console.log('Inside true of lightning confirmation');
            
            this.isSpinner = true;

            return new Promise((resolve, reject) => {
                raiseDemandsFromLWC({ demandIds: this.selectedDemandIds, Action: this.Action })
                    .then(result => {
                        this.isSpinner = false;

                        let toastVariant = 'success';

                        if (result.includes('Error:')) {
                            toastVariant = 'error';
                            toastTitle = 'Error';
                        } else {
                            this.selectedDemandrecord = [];
                            this.selectedDemandIds = [];
                        }

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: toastTitle,
                                message: JSON.stringify(result),
                                variant: toastVariant
                            })
                        );
                        this.closeModal();
                        this.handleClick();
                        resolve(result);
                    })
                    .catch(error => {
                        this.isSpinner = false;
                        console.error('Error saving data:', error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Failed to raise demand data.',
                                variant: 'error'
                            })
                        );
                        this.closeModal();
                        reject(error);
                    });
            });

        } else {
            console.log('inside Cancel of Lightning Confirmantion');
            
            // User cancelled
             this.isSpinner = false;
             this.closeModal();
            return Promise.resolve('Cancelled by user');
        }
    });

        
    }
}