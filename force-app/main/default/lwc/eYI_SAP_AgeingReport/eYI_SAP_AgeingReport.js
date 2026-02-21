import { LightningElement, wire, track } from 'lwc';
import getProjectList from '@salesforce/apex/EYI_SAP_ReportController.getAllProjects';
import fetchTableData from'@salesforce/apex/EYI_SAP_ReportController.getAgeingReport';
import { CurrentPageReference } from 'lightning/navigation';
import Longitude from '@salesforce/schema/Asset.Longitude';


export default class EYI_SAP_AgeingReport extends LightningElement {

@track isDropdownOpen = false;
@track dropdownLeft; // to apply css left attribute dynamically
@track selectedValues = [];
filteredData = [];
companyCode = [];
salesOrg = [];
distChan = [];
matCode = [];
salesDoc = [];
salesOrder = [];
customerNo = [];
keyDate = [];
//@track columns = [];
data = [];
filters;
filterString = '';
@track isDisabled;
@track isData = false;
inputOptions; // store project rec data
@track customerNumber;
@track cmpCode;
@track pageRecordId;
@track sOrder;
@track sOrg;
@track dchannel;
@track isDisabledBooking;
@track isLoading = false;

 @track columns = [
        //{ label: 'Sales Org', fieldName: 'VKORG' },
        //{ label: 'Distribution Channel', fieldName: 'VTWEG' },
        { label: 'Customer Name', fieldName: 'NAME1' },
        { label: 'Customer Number', fieldName: 'KUNNR' },
        { label: 'Not Due', fieldName: 'NOT_DUE' },
        { label: 'Billing Doc No', fieldName: 'BILL_DOC' },
        { label: 'Delay days', fieldName: 'DELAY_DAYS' },
        { label: 'Posting Date', fieldName: 'POSTING_DATE' }, 
        { label: 'Document Date', fieldName: 'DOCUMENT_DATE' },
        { label: 'Ref Doc No', fieldName: 'XBLNR' },
        { label: 'Document Type', fieldName: 'DOCUMENT_TYPE' },
        { label: 'Tax Code', fieldName: 'MWSKZ' },
        { label: 'Agreement Value', fieldName: 'AGREEMENT_VAL' },
        { label: 'Billed Amount', fieldName: 'AMOUNT' }, 
        
        
        //{ label: 'Due Date', fieldName: 'DUE_DATE' },
       // ,
        
        //{ label: 'Company Code', fieldName: 'BUKRS' },
        //{ label: 'Company Name', fieldName: 'BUKRS_DESC' },
        
        
        //{ label: 'Agreement Value', fieldName: 'AGREEMENT_VAL' },
       // { label: 'Customer Name', fieldName: 'NAME1' },
        //{ label: 'Carpet Area', fieldName: 'CARPET_AREA' },
        //{ label: 'Segment', fieldName: 'SEGMENT' }, 
        { label: 'SO Number', fieldName: 'VBELN' }, 
        { label: 'Line Item Number', fieldName: 'LINE_NO' }, 
        { label: 'Material Number', fieldName: 'MATNR' }, 
       // { label: 'Profit Center', fieldName: 'PRCTR' }, 
       // { label: 'Profit Center Description', fieldName: 'PRCTR_DESC' }, 
        
        
       
        
        { label: 'BRACKET1', fieldName: 'BRACKET1' },
        { label: 'BRACKET2', fieldName: 'BRACKET2' },
        { label: 'BRACKET3', fieldName: 'BRACKET3' },
        { label: 'BRACKET4', fieldName: 'BRACKET4' },
        { label: 'BRACKET5', fieldName: 'BRACKET5' },
        { label: 'BRACKET6', fieldName: 'BRACKET6' },
        { label: 'BRACKET7', fieldName: 'BRACKET7' },
        { label: 'BRACKET8', fieldName: 'BRACKET8' },
        { label: 'BRACKET9', fieldName: 'BRACKET9' }

    ];






    @wire(getProjectList)
        getProjectList({ error, data }) {
            if(data){
                console.log(JSON.stringify(data));
                this.inputOptions = data;
                console.log(JSON.stringify(this.inputOptions));

            }else if (error){
                this.showToast('Error', 'Error fetching projects', 'error');

            }
    }
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference){
        if (currentPageReference) {
        
            
            this.pageRecordId = currentPageReference.state?.c__recordId;
            this.customerNumber = currentPageReference.state?.c__sapCustNumb;
            this.cmpCode = currentPageReference.state?.c__companyCode;
            this.sOrg = currentPageReference.state?.c__salesOrg;
            this.sOrder = currentPageReference.state?.c__salesOrder;
            this.dchannel = currentPageReference.state?.c__distChannel;
            this.isData = false;
            this.isDisabled = !!this.pageRecordId; // Disabling SAP customer no. field if open from action button
            this.isDisabledBooking = !!this.pageRecordId;
            //this.showClearFilter = !!this.pageRecordId;
           // this.fromAction = !!this.pageRecordId;
            //this.fromTab = !!this.pageRecordId;
            console.log('recordid', this.pageRecordId);
            this.mNumber = currentPageReference.state?.c__matNo;
           
            if(this.pageRecordId){
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

    toggleDropdown(event){
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



    }
    get computedStyle() { // For dynamic css
        return this.dropdownLeft;
    }

    handleCheckboxChange(event) {
        const value = event.target.value;
        console.log('event-->'+ JSON.stringify((event.target.value)));
        this.isDisabled = true;
        //this.inputRowFilter = this.inputOptions;
        if (event.target.checked) {
            this.selectedValues = [...this.selectedValues, value];
            this.filteredData = this.inputOptions.filter(item => event.target.value.includes(item[this.fieldNameSelected]));
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
            console.log('insideElse'+this.selectedValues);
            this.filteredData = this.inputOptions.filter(item => event.target.value.includes(item[this.fieldNameSelected]));
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
        
    }

    handleChange(event){
        console.log('event-->'+ JSON.stringify(event.target.value));
        const field = event.target.dataset.id;
        const value = event.target.value;
    
        if (!field || !value) return;
    
        console.log(`Field: ${field}, Value: ${value}`);
    
        switch (field) {
            case 'keyDate':
                this.keyDate = [...(this.keyDate || []), value];
                this.filters = { ...this.filters, KeyDate: this.keyDate };
                console.log('Updated keyDate:', this.keyDate);
                break;
    
            case 'distChan':
                this.distChan = value.split(',').map(item => item.trim());
                this.filters = { ...this.filters, DistributionChannel: this.distChan };
                console.log('Updated distChan:', this.distChan);
                break;
    
            case 'salesDoc':
                this.salesDoc = value.split(',').map(item => item.trim());
                this.filters = { ...this.filters, SalesDocType: this.salesDoc };
                console.log('Updated salesDoc:', this.salesDoc);
                break;
    
            case 'customerNo':
                this.customerNo = value.split(',').map(item => item.trim());
                this.filters = { ...this.filters, CustomerNo: this.customerNo };
                console.log('Updated customerNo:', this.customerNo);
                break;
    
            default:
                // Handle DueDays fields dynamically
                if (field.startsWith('range')) {
                    const dueDaysKey = `DueDays${field.replace('range', '')}`;
                    this.filters = { ...this.filters, [dueDaysKey]: value };
                    console.log(`Updated ${dueDaysKey}:`, value);
                }
                break;
        }
        
    }

    handleClick(){

        const rawDate = this.template.querySelector('[data-id="keyDate"]').value;
       
        let formattedDate = '';
        if (rawDate) {
            const d = new Date(rawDate);
            formattedDate = `${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`;
        }
         this.filters['KeyDate'] = [formattedDate];
        this.filterString = JSON.stringify(this.filters);
        console.log('filters-->228'+ JSON.stringify(this.filters) );
        this.loadData();

    }
    loadData(){
        this.isLoading = true;
        console.log('this.filterString : '+this.filterString);
        
        fetchTableData({ filterString: this.filterString })
        .then(result => {
            this.isLoading = false;
             this.isData = true;

            // this.columns = result.columns;
            // this.data = result.data;

            console.log('result-->'+result);
            const jsonResponse = JSON.parse(result);
            const data = jsonResponse["n0:ZSD_CUSTOMER_AGEING_SFResponse"]["EX_OUTPUT"]["item"];
            
            //const items = result?.['n0:ZSD_CUSTOMER_AGEING_SFResponse']?.EX_OUTPUT?.item || [];
            console.log('Parsed Data:'+JSON.stringify(data));
            const responseKey = Object.keys(jsonResponse).find(key => key.includes("ZSD_CUSTOMER_AGEING_SFResponse"));
            console.log('responseKey :: '+responseKey);
            
            this.data = data;
            
        })
        .catch(fetchError => {
                // this.showToast('Error', 'Error fetching data', 'error');
                this.isLoading = false;
                console.error('Error fetching data:', fetchError);

            });


    }






    
}