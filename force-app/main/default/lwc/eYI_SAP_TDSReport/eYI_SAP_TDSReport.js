import { LightningElement, api, track, wire } from 'lwc';
import getProjectList from '@salesforce/apex/EYI_SAP_ReportController.getAllProjects';
import getTowerList from '@salesforce/apex/EYI_InventoryMatrixController.getAllTowers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchTableData from'@salesforce/apex/EYI_SAP_ReportController.getTDSReport';
import { CurrentPageReference } from 'lightning/navigation';


const columns = [
    { label: 'Sales Organization', fieldName: 'SalesOrg', type: 'text' },
    { label: 'Segment', fieldName: 'segment', type: 'text' },
    { label: 'Profit Center', fieldName: 'profitCenter', type: 'text' }
];
export default class EYI_SAP_TDSReport extends LightningElement {
    @track fullData = []; // Holds complete dataset
    @track data = []; // Holds current paginated 
    @track exportData = [];
    @track columns = [];
    @track selectedValues = []; // Track selected values
    @track inputRowFilter
    @track keyValue = '';
    @track filteredProjectOptions = [];
    @track filteredTowerOptions = [];
    @api options = []; // List of available options
    @api recordId;
    @track tabTitle;
    @track customerNumber;
    @track cmpCode;
    @track sOrg;
    @track sOrder;
    @track mNumber;
    @track dchannel;
    @track isDropdownOpen = false;
    @track dropdownLeft; // to apply css left attribute dynamically
    filteredData = [];
    fieldNameSelected;
    
    showClearFilter = true
    inputOptions;
    isDisabledBooking = false;
    
    @track isData = false;
    inputFieldValues = new Map(); // to store user inputs and sending to apex
    filters;
    filterString = '';
    isDisabled = false;
    fromAction = false;
    fromTab = false;
    
    @track isAgeing = true; 
    pageSize = 3; // Number of records per page
    pageNumber = 1; // Current page number
    totalRecords = 0; // Total records count
    totalPages = 0; // Total number of pages

    companyCode = [];
    salesOrg = [];
    distChan = [];
    matCode = [];
    salesDoc = [];
    salesOrder = [];
    customerNo = [];
    keyDate = [];

    COLUMN_LABEL_MAP = {
        KUNNR: 'Customer No.',
        KUNNR_NAME: 'Customer Name',
        MATNR: 'Flat No',
        TEL_NUMBER: 'Mobile NO.',
        SMTP_ADDR: 'Email ID',
        VBELN: 'Sales Order No.',
        AGREEMENT_VALUE: 'Agreement Value',
        ZZAGRMT_REG_NO: 'Agreement Reg No.',
        REG_DATE: 'Agreement Reg. date',
        PER_AGR_VAL: '1% on Agreement Value',
        BASIC_BILL_VAL: 'Basic Billed Value',
        BASIC_BILL_TDS: 'Basic Bill TDS %',
        BILL_DATE: 'Bill Date',
        REC_VAL: 'Received Value',
        FIRST_BILL_DATE: 'First Bill Date',
        OUT_BASIC_BILL: 'Outstanding on Basic Bill',
        OUT_AGREE_VAL: 'Outstanding On 1% Agreement Value',
        INTEREST_BASIC: 'Interest Basic',
        PENALTY: 'Penalty 200 per Day',
        TOTAL_VAL: 'Total',
        MAX_DELAY_BASIC: 'Maximum Basic Delay NO. of Days',
        MAX_DELAY_AGRR: 'Maxmimum Delyed - Agreement Date'
    };

    connectedCallback() {
        this.keyvalue = '';
        console.log('this-->'+this.keyDate);
        this.keyDate ='';
        
       
    }

    loadData() {
         this.fullData = [
            { id: '1', SalesOrg: 'Org A', segment: 'Retail', profitCenter: 'Center 1' },
            { id: '2', SalesOrg: 'Org B', segment: 'Wholesale', profitCenter: 'Center 2' },
            { id: '3', SalesOrg: 'Org C', segment: 'E-Commerce', profitCenter: 'Center 3' },
            { id: '4', SalesOrg: 'Org D', segment: 'B2B', profitCenter: 'Center 4' },
            { id: '5', SalesOrg: 'Org E', segment: 'Manufacturing', profitCenter: 'Center 5' }
        ];
        try {
            fetchTableData({ filterString: this.filterString })
                .then(result => {
                    console.log('Raw Result:', result);
                    this.columns = columns;
                    this.isData = true;
                    this.totalRecords = this.fullData.length;
                    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                    this.updatePagination();
                    this.exportData = this.fullData;
                    
                })
                .catch(fetchError => {
                    this.showToast('Error', 'Error fetching data', 'error');
                    console.error('Error fetching data:', fetchError);
                });
        } catch (outerError) {
            this.showToast('Error', 'Unexpected error occurred', 'error');
            console.error('Outer Error:', outerError);
        }
            //     console.log('result-->'+result);
                
            //     if (result) {
            //         console.log('inside-->fetch');
                    
            //         this.columns = result.columns;
            //         this.fullData = result.data;
            //         this.isData = this.fullData.length > 0;
            //         this.totalRecords = this.fullData.length;
            //         this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            //         this.updatePagination();
            //     }
            // })
            // .catch(error => {
            //     console.error('Error fetching data: ', error);
            // })
        
    }

    updatePagination() {
        const startIndex = (this.pageNumber - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.data = this.fullData.slice(startIndex, endIndex);

        // Disable buttons based on page number
        this.isDisablePrev = this.pageNumber === 1;
        this.isDisableNext = this.pageNumber === this.totalPages;
    }

    firstPage() {
        this.pageNumber = 1;
        this.updatePagination();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.updatePagination();
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

    @wire(getProjectList)
    getProjectList({ error, data }) {
        if (data) {
            console.log(JSON.stringify(data));
            this.inputOptions = data;
            console.log(JSON.stringify(this.inputOptions));
            
           /* this.projectOptions = [
                { label: 'None', value: '', projectType: null },
                ...data.map(proj => ({
                    label: proj.EYI_SAP_Company_Code__c,
                    value: proj.EYI_SAP_Company_Code__c,
                    projectType: proj.EYI_Project_Type__c
                }))
            ];
            this.filteredProjectOptions = this.projectOptions;
            this.options = this.projectOptions;*/
        } else if (error) {
            this.showToast('Error', 'Error fetching projects', 'error');
            
        }
    }

    @wire(getTowerList)
    getTowerList({ error, data }) {
        if (data) {
            this.towerOptions = [
                { label: 'None', value: '', projectId: null },
                ...data.map(towr => ({
                    label: towr.Name,
                    value: towr.Id,
                    projectId: towr.EYI_SubProject_Name__c
                }))
            ];
            this.filteredTowerOptions = this.towerOptions.filter(subTower =>
                subTower.projectId === this.selectedSubProject
            );
        } else if (error) {
            this.showToast('Error fetching towers');
        }
    }
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {

            console.log('currPageRef-->');
            this.handleReset();
            this.keyDate =[];
            this.companyCode = [];
            this.salesOrg = [];
            this.distChan = [];
            this.matCode = [];
            this.salesDoc = [];
            this.salesOrder = [];
            this.customerNo = [];
            this.keyValue = '';   
            console.log('currPageRef-->322'+JSON.stringify(this.keyDate));
            console.log('currPageRef-->323'+this.keyValue);
            this.tabTitle = currentPageReference.attributes.apiName === 'Generate_Outstanding_Report' 
            ? 'Outstanding Report' 
            : 'Ageing Report';
            console.log('results-->126', this.isAgeing);
            this.isAgeing = this.tabTitle === 'Ageing Report';
            console.log('results-->126', this.isAgeing);
            
            this.pageRecordId = currentPageReference.state?.c__recordId;
            this.customerNumber = currentPageReference.state?.c__sapCustNumb;
            this.cmpCode = currentPageReference.state?.c__companyCode;
            this.sOrg = currentPageReference.state?.c__salesOrg;
            this.sOrder = currentPageReference.state?.c__salesOrder;
            this.dchannel = currentPageReference.state?.c__distChannel;
            this.isData = false;
            this.isDisabled = !!this.pageRecordId; // Disabling SAP customer no. field if open from action button
            this.isDisabledBooking = !!this.pageRecordId;
            this.showClearFilter = !!this.pageRecordId;
            this.fromAction = !!this.pageRecordId;
            this.fromTab = !!this.pageRecordId;
            console.log('recordid', this.pageRecordId);
            this.mNumber = currentPageReference.state?.c__matNo;
           
            if(this.pageRecordId){
                this.customerNumber = currentPageReference.state?.c__sapCustNumb ?? 'Not available' ;
                this.cmpCode = currentPageReference.state?.c__companyCode ?? 'Not available' ;
                this.sOrg = currentPageReference.state?.c__salesOrg ?? 'Not available' ;
                this.sOrder = currentPageReference.state?.c__salesOrder ?? 'Not available' ;
                this.dchannel = currentPageReference.state?.c__distChannel ?? 'Not available' ;
                this.mNumber = currentPageReference.state?.c__matNo ?? 'Not available' ;
                this.companyCode = this.cmpCode !== 'Not available' ? [...this.companyCode, this.cmpCode] : [...this.companyCode];
                this.customerNo = this.customerNumber !== 'Not available' ? [...this.customerNo, this.customerNumber] : [...this.customerNo];
                this.salesOrder = this.sOrder !== 'Not available' ? [...this.salesOrder, this.sOrder] : [...this.salesOrder];
                this.salesOrg = this.sOrg !== 'Not available' ? [...this.salesOrg, this.sOrg] : [...this.salesOrg];
                this.matCode = this.mNumber !== 'Not available' ? [...this.matCode, this.mNumber] : [...this.matCode];
               
                this.filters = {CompanyCode : this.companyCode,
                    CustomerNo: this.customerNo,
                    SalesOrderNo: this.salesOrder,
                    UnitCode: this.matCode,
                    SalesOrg: this.salesOrg
                    
                };
                //this.filterString = JSON.stringify(this.filters);
             console.log('filters-->194'+ JSON.stringify(this.filters) );
            }

            
          
        }
    }


    // @wire(getRecord, { recordId: '$recordId', fields: [oppCustomerNumber] })
    // wiredRecord({ error, data }) {
    //     if (data) {
    //         this.customerNumber = data.fields.EYI_Opp_Customer_Number__c.value;
    //     } else if (error) {
    //         console.error('Error fetching record:', error);
    //     }
    // }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    handleClick(){
          this.filterString = JSON.stringify(this.filters);
          console.log('filters-->228'+ JSON.stringify(this.filters) );
        //  console.log('filters-->'+ JSON.stringify(this.filters) );
         this.loadData();
    }
    handleChange(event){
        console.log('event-->'+ JSON.stringify(event.target.value));
        if (event.target.dataset.id === 'keyDate') {
            if (event.target.value) {
                this.keyDate = [event.target.value]; // Replace the old value with the new one
            } else {
                this.keyDate = []; // Clear the array if input is erased
            }
            console.log('output-->'+this.keyDate);
            this.filters = {
                ...this.filters,
                KeyDate: this.keyDate
            };
            
            
        }
        if (event.target.dataset.id === 'distChan' && event.target.value){
            console.log('output-->'+this.distChan);
            let value = event.target.value;
            console.log('output-->'+this.distChan);
            this.distChan = value.split(',').map(item => item.trim());
            console.log('output-->'+this.distChan);
            this.filters = {
                ...this.filters,
                DistributionChannel: this.distChan
            };

        }
        if(event.target.dataset.id === 'salesDoc' && event.target.value){
            let value = event.target.value;
            this.salesDoc = value.split(',').map(item => item.trim());
            console.log('output-->'+this.salesDoc);
            this.filters = {
                ...this.filters,
                SalesDocType: this.salesDoc
            };

        }
        if(event.target.dataset.id === 'customerNo' && event.target.value){
            let value = event.target.value;
            this.customerNo = value.split(',').map(item => item.trim());
            console.log('output-->'+this.customerNo);
            this.filters = {
                ...this.filters,
                CustomerNo: this.customerNo
            };

        }
        if(event.target.dataset.id === 'matCode' && event.target.value){
            let value = event.target.value;
            this.matCode = value.split(',').map(item => item.trim());
            console.log('output-->'+this.matCode);
            this.filters = {
                ...this.filters,
                UnitCode: this.matCode
            };

        }
        if(event.target.dataset.id === 'salesOrder' && event.target.value){
            let value = event.target.value;
            this.salesOrder = value.split(',').map(item => item.trim());
            console.log('output-->'+this.salesOrder);
            this.filters = {
                ...this.filters,
                SalesOrderNo: this.salesOrder
            };

        }
        
    }

    get computedStyle() {
        return this.dropdownLeft;
    }
  
    toggleDropdown(event) {
        console.log('event-->'+ JSON.stringify(event.target.dataset.id));
        this.isDropdownOpen = !this.isDropdownOpen;
        if(event.target.dataset.id === 'salesOrg') {
            this.dropdownLeft = 'dropdownSalesOrg';
            this.projectValues = [
                { label: 'None', value: '', projectType: null },
                ...this.inputOptions
                .filter(proj => proj.EYI_SAP_Salesorg__c && proj.EYI_SAP_Salesorg__c.trim() !== '')
                .map(proj => ({
                    label: proj.EYI_SAP_Salesorg__c,
                    value: proj.EYI_SAP_Salesorg__c
                }))
            ];
            this.fieldNameSelected = 'EYI_SAP_Salesorg__c'
            this.options = this.projectValues;
           
        }
        if(event.target.dataset.id === 'companyCode') {
            this.dropdownLeft = 'dropdownCompanyCode';
            this.projectValues = [
                { label: 'None', value: '', projectType: null },
                ...[...new Set(
                    this.inputOptions
                        .filter(proj => proj.EYI_SAP_Company_Code__c && proj.EYI_SAP_Company_Code__c.trim() !== '')
                        .map(proj => proj.EYI_SAP_Company_Code__c) // Extract values and make them unique
                )].map(value => ({
                    label: value,
                    value: value
                }))
            
            ];
            this.fieldNameSelected = 'EYI_SAP_Company_Code__c'
            this.options = this.projectValues;
           
        }
        // if(event.target.dataset.id === 'matCode') {
        //     this.projectValues = [
        //         { label: 'None', value: '', projectType: null },
        //         ...this.inputOptions.map(proj => ({
        //             label: proj.EYI_SAPMaterial_Code__c,
        //             value: proj.EYI_SAPMaterial_Code__c
        //         }))
        //     ];
        //     this.fieldNameSelected = 'EYI_SAPMaterial_Code__c'
        //     this.options = this.projectValues;
           
        // }  

    }

    

    handleCheckboxChange(event) {
        const value = event.target.value;
        console.log('event-->'+ JSON.stringify((event.target.value)));
        /*this.selectedValues = [...this.selectedValues, value];
        console.log('selectedvaluess-->'+this.selectedValues);*/
        
        this.isDisabled = true;
        this.inputRowFilter = this.inputOptions;
        
        
        if (event.target.checked) {
            this.selectedValues = [...this.selectedValues, value];
            this.filteredData = this.inputRowFilter.filter(item => event.target.value.includes(item[this.fieldNameSelected]));
            console.log('Filtered Data:', JSON.stringify(this.filteredData));
            console.log('this.sOrg-->before'+this.sOrg);
            this.salesOrg = [
                ...new Set([
                ...(this.salesOrg || []), // Keep existing values if present
                ...this.filteredData
                    .map(item => item.EYI_SAP_Salesorg__c?.trim())
                    .filter(Boolean) // Remove falsy values like null/undefined/empty string
                 ])
            ];
        
        // Join into a string
            this.sOrg = this.salesOrg.join(', ');
            console.log('this.sOrg-->after'+this.sOrg);
        
            this.cmpCode = [
                ...new Set([
                    ...(this.cmpCode ? this.cmpCode.split(', ').filter(Boolean) : []), // Keep existing values
                        ...this.filteredData
                        .map(item => item.EYI_SAP_Company_Code__c)
                        .filter(Boolean) // Remove null/undefined values
                    ])
                    ].join(', ');

            this.companyCode = [
                ...(this.companyCode || []),
                ...this.filteredData
                .map(item => item.EYI_SAP_Company_Code__c?.trim())
                .filter(Boolean)
            ];;

            this.filters = {...this.filters,
                CompanyCode : this.companyCode,
                SalesOrg: this.salesOrg
            };
            console.log('array-->cmpCode'+ JSON.stringify(this.companyCode) );
            console.log('array-->salesOrg'+ JSON.stringify(this.salesOrg) );
        } else {
            //this.selectedValues = this.selectedValues.filter(item => item !== value);
            console.log('insideElse'+this.selectedValues);
            this.filteredData = this.inputRowFilter.filter(item => event.target.value.includes(item[this.fieldNameSelected]));
            console.log('Filtered Data:', JSON.stringify(this.filteredData));
            const removeSalesOrg = this.filteredData.map(item => item.EYI_SAP_Salesorg__c?.trim()).filter(Boolean);
            const removeCompanyCode = this.filteredData.map(item => item.EYI_SAP_Company_Code__c?.trim()).filter(Boolean);

            //  Remove existing values from salesOrg
            this.salesOrg = this.salesOrg.filter(org => !removeSalesOrg.includes(org));
            this.sOrg = this.salesOrg.join(', ');

            //  Remove existing values from companyCode
            this.companyCode = this.companyCode = removeCompanyCode.reduce((acc, code) => {
                const index = acc.findIndex(c => c === code);
                if (index !== -1) {
                    return [...acc.slice(0, index), ...acc.slice(index + 1)];
                }
                return acc;
            }, this.companyCode);

            this.cmpCode = [...new Set(this.companyCode)].join(', ');
            
            
            console.log('array-->cmpCode'+ JSON.stringify(this.companyCode) );
            console.log('array-->salesOrg'+ JSON.stringify(this.salesOrg) );
            
        }
        this.dispatchSelectionEvent();
    }

    handleClear(){
        this.sOrg = '';
        this.cmpCode = '';
        this.inputRowFilter='';
        this.companyCode = [];
        this.salesOrg = [];
        this.distChan = [];
        this.matCode = [];
        this.salesDoc = [];
        this.salesOrder = [];
        this.customerNo = [];
        this.keyDate = [];
        this.filteredData = [];
        this.selectedValues = [];
        this.isDisabled = false;
        this.filterString = ''
        this.filters = ''
    }

    dispatchSelectionEvent() {
        this.dispatchEvent(new CustomEvent('change', {
            detail: { selectedValues: this.selectedValues }
        }));
    }
    get selectedLabels() {
        return this.options
            .filter(option => this.selectedValues.includes(option.value))
            .map(option => option.label)
            .join(', ') || 'Select...';
    }
    handleReset(){

        console.log('insideclear');
        
        //this.template.querySelectorAll('lightning-input').forEach(element => {
            const inputField = this.template.querySelector('[data-id="keyDate"]');
            if (inputField) {
                inputField.value = '';
            }

    }

 

    

}