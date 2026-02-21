import { LightningElement, api, track, wire } from 'lwc';
import getProjectList from '@salesforce/apex/EYI_SAP_ReportController.getAllProjects';
import getTowerList from '@salesforce/apex/EYI_InventoryMatrixController.getAllTowers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchTableData from'@salesforce/apex/EYI_SAP_ReportController.getApiData';
import { CurrentPageReference } from 'lightning/navigation';


/*const columns = [
    { label: 'Sales Organization', fieldName: 'SalesOrg', type: 'text' },
    { label: 'Segment', fieldName: 'segment', type: 'text' },
    { label: 'Profit Center', fieldName: 'profitCenter', type: 'text' }
];*/
export default class EYI_SAP_OutstandingReport extends LightningElement {
    @api options = []; // List of available options
    @api recordId;
    @track inputRowFilter
    @track keyValue = '';
    @track customerNumber;
    @track cmpCode;
    @track sOrg;
    @track sOrder;
    @track mNumber;
    @track dchannel;
    @track isDropdownOpen = false;
    @track dropdownLeft; // to apply css left attribute dynamically
    @track filteredProjectOptions = [];
    @track filteredTowerOptions = [];
    @track fullData = []; // Holds complete dataset
    @track data = []; // Holds current paginated 
    @track exportData = [];
    @track columns = [];
    @track selectedValues = []; // Track selected values
    @track isLoading = false;
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
    fromTab = false;
    pageSize = 50; // Number of records per page
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
        VBELN: 'Sales Document',
        POSNR: 'SO Line Item',
        KUNNR: 'Customer No.',
        CUST_NAME: 'Customer Name',
        MATNR: 'Material',
        ARKTX: 'Material Description',
       // AKONT: 'Recon Account',
       // TXT50: 'Recon Account Description',
        NETWR: 'Total Consideration',
        BILL_AMT_EX_TX: 'Actual Basic Bill Amount',
        V_DEBIT: 'Debit Amount',
        TOT_TAX: 'Tax Amount',
        BILLD_AMT: 'Billed Amt + Debit Note Amt.',
        RECVD_AMT: 'Received Amt',
        OUTSTAND_AMT: 'Outstanding Amt',
        //PRCTR: 'Profit Center',
        //TEXT: 'Reason For Rejection',
        WERKS: 'Plant',
        FLAT_NAME: 'Flat',
        VKORG: 'Sales Org.',
       // VTEXT: 'Sales Org Desc.',
        BUKRS: 'Company Code',
       // VTWEG: 'Distribution Channel',
        //KWMENG: 'Area',
        ERDAT: 'Booking Date',
        //ABGRU: 'Rejection',
        //VPRCTR_LTEXT: 'Profit Center Name',
        //BUILD_NAME: 'Building Name',
        V_CREDIT: 'Credit Amount',
        V_BBILL: 'After Deduction Basic Bill',
        ZZAGRMT_DT: 'Agreement Execution Date',
        ZZAGRMT_HND_DT: 'Agreement Handover Date',
        ZZAGRMT_RECV_DT: 'Agreement Received Date',
        ZZAGRMT_REG_NO: 'Agreement Reg No.',
        ZZSALES_DEED_NO: 'Sales Deed No.',
        ZZSALES_DEED_DT: 'Registration Date',
        ZZCANL_DT: 'Cancellation Date',
        ZZCANL_INIT_BY: 'Cancellation Initiated By',
        ZZ_SALES: 'Sales Type',
        ZZ_PROPERTY_TAX_NUMBER: 'Property Tax Number',
        ZZ_FRANKING_DATE: 'Franking Date',
        ZZ_STAMP_DUTY: 'Stamp Duty Amount (SD)',
        ZZ_SD_FI: 'Stamp Duty Amount (FI)',
        ZZ_PAY_PROJECT: 'Payment Project',
        LIFNR: 'CRM Mapped',
        LIFNR_NAME: 'Name of CRM Mapped'
    };

    connectedCallback() {
    }

    loadData() {
        // this.fullData = [
        //     { id: '1', SalesOrg: 'Org A', segment: 'Retail', profitCenter: 'Center 1' },
        //     { id: '2', SalesOrg: 'Org B', segment: 'Wholesale', profitCenter: 'Center 2' },
        //     { id: '3', SalesOrg: 'Org C', segment: 'E-Commerce', profitCenter: 'Center 3' },
        //     { id: '4', SalesOrg: 'Org D', segment: 'B2B', profitCenter: 'Center 4' },
        //     { id: '5', SalesOrg: 'Org E', segment: 'Manufacturing', profitCenter: 'Center 5' }
        // ];
        console.log('inside load data 1', this.isLoading );
        this.isLoading = true;
        console.log('inside load data 2', this.isLoading );
        try {
            
            fetchTableData({ filterString: this.filterString })
                .then(result => {
                    console.log('Raw Result:', result);
                    
                    try {
                        const jsonResponse = JSON.parse(result);
                        const data = jsonResponse["n0:ZSD_OUTSTANDING_BALANCE_SFResponse"]["EX_OUTPUT"]["item"];
        
                        console.log('Parsed Data:', data);
                        const currencyFields = ['V_DEBIT','TOT_TAX','OUTSTAND_AMT', 'RECVD_AMT', 'BILLD_AMT','ZZ_SD_FI'];
                        // Build columns
                        if (this.COLUMN_LABEL_MAP) {
                            this.columns = Object.keys(this.COLUMN_LABEL_MAP).map(key => ({
                                label: this.COLUMN_LABEL_MAP[key],
                                fieldName: key,
                                initialWidth: 200, // Adjust column width
                                wrapText: true, 
                               // type: 'text'
                               type: currencyFields.includes(key) ? 'currency' : 'text',
                               typeAttributes: currencyFields.includes(key) ? { currencyCode: 'INR', minimumFractionDigits: 2 } : null
                            }));
                            this.columns.push({
                                label: 'Final Total',
                                fieldName: 'FINAL_TOTAL',
                                initialWidth: 200,
                                type: 'text',
                                wrapText: true
                            });
                            console.log('Columns:', JSON.stringify(this.columns));
                        } else {
                            this.showToast('Error', 'COLUMN_LABEL_MAP is undefined', 'error');
                            console.error('COLUMN_LABEL_MAP is undefined');
                        }
                        
        
                        // Build table data
                        let groupedData = {};
                    data.forEach(item => {
                        const docId = item.VBELN;
                        if (!docId) return;

                        if (!groupedData[docId]) {
                            groupedData[docId] = [];
                        }
                        groupedData[docId].push(item);
                    });

                    // Calculate totals and build table data
                    let finalData = [];
                    Object.keys(groupedData).forEach(docId => {
                        let columnSums = {
                            NETWR: 0,
                            BILL_AMT_EX_TX: 0,
                            V_DEBIT: 0,
                            TOT_TAX: 0,
                            BILLD_AMT: 0,
                            RECVD_AMT: 0,
                            OUTSTAND_AMT: 0
                        };
                        let finalTotal = 0;

                        groupedData[docId].forEach(item => {
                            finalData.push(item);

                            // Calculate sum for each column
                            Object.keys(columnSums).forEach(key => {
                                columnSums[key] += parseFloat(item[key] || 0);
                            });
                        });

                        // Final total (sum of all column sums)
                        finalTotal = Object.values(columnSums).reduce((a, b) => a + b, 0);

                        // Add a total row below the group
                        let totalRow = {
                            VBELN: `Sub-Total`,
                            NETWR: columnSums.NETWR.toFixed(2),
                            BILL_AMT_EX_TX: columnSums.BILL_AMT_EX_TX.toFixed(2),
                            V_DEBIT: columnSums.V_DEBIT.toFixed(2),
                            TOT_TAX: columnSums.TOT_TAX.toFixed(2),
                            BILLD_AMT: columnSums.BILLD_AMT.toFixed(2),
                            RECVD_AMT: columnSums.RECVD_AMT.toFixed(2),
                            OUTSTAND_AMT: columnSums.OUTSTAND_AMT.toFixed(2),
                            FINAL_TOTAL: finalTotal.toFixed(2) // Last cell to display final total
                        };

                        finalData.push(totalRow);
                    });

                    this.fullData = finalData;
                    this.isData = true;
                    this.totalRecords = this.fullData.length;
                    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                    this.updatePagination();

                    // Prepare export data
                    this.exportData = this.fullData.map(row => {
                        let displayRow = {};
                        Object.keys(this.COLUMN_LABEL_MAP).forEach(key => {
                            displayRow[this.COLUMN_LABEL_MAP[key]] = row[key] || '';
                        });
                        return displayRow;
                    });
                        console.log('this.exportData-->'+this.exportData);
                        this.isLoading = false;
                        this.showToast('Success', 'Data loaded successfully', 'success');
    
                    } catch (dataParseError) {
                        this.isLoading = false;
                        this.showToast('Error', 'Error parsing data', 'error');
                        console.error('Error parsing data:', dataParseError);
                    }
                })
                .catch(fetchError => {
                    this.isLoading = false;
                    this.showToast('Error', 'Error fetching data', 'error');
                    console.error('Error fetching data:', fetchError);
                });
        } catch (outerError) {
            this.isLoading = false;
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
            console.log('recordid', this.pageRecordId);
            this.mNumber = currentPageReference.state?.c__matNo;
           
            if(this.pageRecordId){
                this.customerNumber = currentPageReference.state?.c__sapCustNumb ?? 'Not available' ;
                this.cmpCode = currentPageReference.state?.c__companyCode ?? 'Not available' ;
                this.sOrg = currentPageReference.state?.c__salesOrg ?? 'Not available' ;
                this.sOrder = currentPageReference.state?.c__salesOrder ?? 'Not available' ;
                this.dchannel = currentPageReference.state?.c__distChannel ?? 'Not available' ;
                this.mNumber = currentPageReference.state?.c__matNo ?? 'Not available' ;
                this.companyCode = [...this.companyCode, this.cmpCode];
                this.customerNo = [...this.customerNo, this.customerNumber];
                console.log('array-->'+ JSON.stringify(this.companyCode) );
                this.filters = {CompanyCode : this.companyCode,
                    CustomerNo: this.customerNo
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
        const rawDate = this.template.querySelector('[data-id="keyDate"]').value;
       
        this.isLoading = true;
        console.log('loading var 22 ', this.isLoading);
        let formattedDate = '';
        if (rawDate) {
            const d = new Date(rawDate);
            formattedDate = `${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`;
        }
        this.filters['KeyDate'] = [formattedDate];
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
        this.handleReset();
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
            const fieldIds = ["keyDate", "matCode", "distChan", "customerNo", "salesDoc", "salesOrder"];

            fieldIds.forEach(id => {
                const inputField = this.template.querySelector(`[data-id="${id}"]`);
                if (inputField) {
                    inputField.value = '';
                }
            });


    }

 

    

}