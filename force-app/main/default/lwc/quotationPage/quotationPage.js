import { LightningElement, track, api,wire } from 'lwc';
import searchRecords from '@salesforce/apex/QuotationPageController.searchRecords'
import getPlanType from '@salesforce/apex/QuotationPageController.getPlanType'
import getQuoteValues from '@salesforce/apex/QuotationPageController.getQuoteValues'
import getInventory from '@salesforce/apex/QuotationPageController.getInventory'
import getDummyOpportunity from '@salesforce/apex/QuotationPageController.getDummyOpportunity'
import { NavigationMixin } from 'lightning/navigation';
import State from '@salesforce/schema/Asset.State';
import {CurrentPageReference} from 'lightning/navigation';

//export default class QuotationPage extends LightningElement {
export default class QuotationPage extends NavigationMixin(LightningElement) {
    inventoryNumber;
    temp = true;
    @track selectedPlanId = null;
    @track plans = [];
    @track qObj = {};
    @track isLoading = false;
    @track errorMessage = null;
    @api inventoryid   //='a0RC4000000UTB3MAO'
    @api recordId; // Account ID
    @track opportunities = [];
    @track searchResults = [];
    @track searchKey = '';
    @track showDropdown = false;
    @track selectedOpportunity = null;
    @track hasResults = false;
    @track objname;

    @track objnameproject
    @track planTypeValue = ''
    @api planTypeData
    @track showplanType = false;
    @track projectValue = '';
    @track projdata = [];
    @track showproject = false;
    @track isNoResults = false;
    @api sendquotevalues;
    @track showuqotation = true
    @track quoteflag = false
    @track inventoryDataValues;
    @track inevntorydefaultvalues;
    isIphone;
    isAndroid;
    @track projectId;
    @track towerId;
    @track opportunityId = '';

    get tower() {
        return this.sendquotevalues?.Tower;
    }

    get floor() {
        return this.sendquotevalues?.floor;
    }
    @wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    console.log('CurrentPageRef', currentPageReference.state.recordId);
    if (currentPageReference) {
        this.recordId = currentPageReference.state.c__oppid;
    }
    console.log('Record opp Id', this.recordId);
}

    connectedCallback() {
        this.getAllquotevalues();
        
        console.log('Received Tower:', this.tower);
        console.log('Received Floor:', this.floor);
        console.log('inventoryvalues::', JSON.stringify(this.sendquotevalues))
        const js = JSON.stringify(this.sendquotevalues);
        console.log(JSON.parse(js))
        console.log('Identifying recordId', this.recordId);
        console.log('InventoryId', this.inventoryId);
        this.detectDevice();
        if(this.recordId == null)
            this.getDummyOppty();

    }
    detectDevice() {
        const userAgent = navigator.userAgent;

        // Check for iPhone (also includes iPod)
        this.isIphone = /iPhone|iPod/.test(userAgent);

        // Check for Android
        this.isAndroid = /Android/.test(userAgent);

        console.log(`Is iPhone: ${this.isIphone}`);
        console.log(`Is Android: ${this.isAndroid}`);
    }
    getDummyOppty() {
        getDummyOpportunity().then(res=>{
            console.log('res' , res);
            this.dummyOppId = res;

        }).catch(error=>{
            console.log('Error', error);
        })
    }
    getAllquotevalues() {

        getInventory({ inventoryId: this.inventoryid }).then(res => {
            console.log('result of inv ::', res);
            this.inevntorydefaultvalues = res;
            //console.log('result of inv opp name ::', res.EYI_Opportunity__r.Name);
            //console.log('result of inv opp id ::', res.EYI_Opportunity__r.Id);
            console.log('result of inv proj id ::', res.EYI_Project__c);
            console.log('result of inv proj name ::', res.EYI_Project__r.Name);
            
            /*if(res.EYI_Opportunity__r.Id && res.EYI_Opportunity__r.Name) {
                console.log('result of inv opp name ::', res.EYI_Opportunity__r.Name);
                console.log('result of inv opp id ::', res.EYI_Opportunity__r.Id);
                this.opportunityId = res.EYI_Opportunity__r.Id;
                this.searchKey = res.EYI_Opportunity__r.Name;
            }*/
            this.towerId = res.EYI_Tower__c;
            this.projectId = res.EYI_Project__c;
            this.projectValue = res.EYI_Project__r.Name;
            this.inventoryNumber = res.EYI_Inventory_Number__c;

            console.log('this.inventoryNumber' + this.inventoryNumber);
            console.log('project', this.projectId);


            //this.searchResults = { ...this.searchResults, Id: res.EYI_Opportunity__r.Id }
            //this.projdata = { ...this.projdata, Id: res.EYI_Project__c }
            console.log('inv line 92',res);
            this.fetchPlantype();

        }).catch(error => console.error('error line 94 ', error.message));


    }

    openquotefullpage() {
        console.log('Inside open quote full page');
        getQuoteValues({ inventoryId: this.inventoryid }).then(res => {
            console.log('inventory values:: quotation page::;', res);
            this.inventoryDataValues = res;
        }).catch(error => console.error('error of inventory', error));

        console.log('inventId from parent ::', this.inventoryid)
        this.showuqotation = false
        this.quoteflag = true;
        //JG ADDED
        console.log('redirect to page 3');

        if (this.inventoryid) {
            console.log('Navigate');
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__navItemPage', // Type for a custom tab
            //     attributes: {
            //         apiName: 'Quotation',
                    
            //     }, state: {
            //         apiName: 'Quotation',
            //         inventoryrecordid: this.inventoryid,
            //         paymentPlanId : this.selectedPlanId,
            //         placeholderOppId : this.dummyOppId,
            //         selectedOppId : this.recordId
            //     }
            // });
            
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Quotation',
                    },
                    state: {
                        c__inventoryrecordid: this.inventoryid,
                        c__paymentPlanId: this.selectedPlanId,
                        c__placeholderOppId: this.dummyOppId,
                        c__selectedOppId: this.recordId
                    }
                });
            
        }
        // const customTabUrl = '/lightning/n/Quotation?inventoryid='+this.inventoryid;  // Salesforce URL for your custom tab
        // console.log('customTabUrl-->'+customTabUrl);
        //  window.open(customTabUrl, '_blank');  // Open the URL in a new tab
        //JG ADDED


    }



    handleSearch(event) {
        this.searchKey = event.target.value;
    }
    handleproject(event) {
        this.projectValue = event.target.value;
        console.log(' this.projectValue::', this.projectValue);
    }
    handleplantype(event) {
        this.planTypeValue = event.target.value;

    }


    searchProject(event) {
        this.showproject = true;


        this.objnameproject = event.currentTarget.dataset.name;

        searchRecords({ searchKey: this.projectValue, objName: this.objnameproject })
            .then((result) => {
                this.projectData = result.map(project => ({
                    label: project.Name,
                    value: project.Id
                }));

                this.projdata = JSON.parse(JSON.stringify(this.projectData));

                if (this.projdata.length === 0) {
                    this.isNoResults = true;
                } else {
                    this.isNoResults = false;
                }

                this.showproject = true;
            })
            .catch((error) => {
                console.error('Error fetching Projects:', error);
                this.searchResults = [];
            });
    }

    // } else {
    //     this.projectData = [];
    //     this.showproject = false;

    // }


    searchopportunity(event) {
        this.objname = event.currentTarget.dataset.name
        //   if (this.searchKey.length >= 2) {
        // Fetch filtered opportunities
        searchRecords({ searchKey: this.searchKey, objName: this.objname })
            .then((result) => {

                if (this.objname == 'opportunity') {
                    this.searchResults = result.map(opportunity => ({
                        label: opportunity.Name,
                        value: opportunity.Id
                    }));
                }
                this.showDropdown = true;
                this.showproject = false;
                this.hasResults = true
            })
            .catch((error) => {
                console.error('Error fetching opportunities:', error);
                this.searchResults = [];
            });
        // } else {
        //     this.searchResults = [];
        //     this.showDropdown = false;
        // }
    }




    searchPlanType(event) {
        this.plantypeKey = event.currentTarget.dataset.name
        //   if (this.planTypeValue.length >= 2) {
        // Fetch filtered opportunities
        searchRecords({ searchKey: this.planTypeValue, objName: this.plantypeKey })
            .then((result) => {
                if (this.plantypeKey == 'planType') {
                    this.planTypeData = result.map(project => ({
                        label: project.Name,
                        value: project.Id
                    }));
                }
                console.log('this.planTypeData :::', this.planTypeData)
                this.showproject = false;
                this.showDropdown = false;
                this.showplanType = true;
            })
            .catch((error) => {
                console.error('Error fetching PlanTypes:', error);
                this.planTypeData = [];
            });
    }

    selectPlanType(event) {
        const selectedValue = event.detail.value;
        console.log('Selected Plan Type:', selectedValue);
        this.selectedPlanId = selectedValue;
        // Handle the selected value logic here
    }

    selectProject(event) {
        const selectedProjectId = event.currentTarget.dataset.id;
        const selectedProjectLabel = event.currentTarget.dataset.label;

        // Update the input field with the selected project
        this.projectValue = selectedProjectLabel;
        this.showproject = false; // Hide dropdown after selection
    }
    handleInputFocus() {
        this.showDropdown = false;
    }

    // Hide dropdown when input field loses focus, if no selection has been made
    handleInputBlur() {
        setTimeout(() => {
            this.showDropdown = false;  // Hide dropdown after a short delay to allow click event
        }, 200);  // Adjust timeout if needed
    }

    handleSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedLabel = event.currentTarget.dataset.label;
        this.searchKey = event.currentTarget.dataset.label
        this.showDropdown = false;
        this.searchResults = [];
    }

    cancelQuoationHandler() {
        this.showuqotation = false;
        this.quoteflag = false;

    }


    //fetch plan types record /
    fetchPlantype() {
        getPlanType({projId : this.projectId,towerId : this.towerId})
            .then((res) => {
                this.planTypeData = res.map((plantype) => ({
                    label: plantype.Name,
                    value: plantype.Id
                }));
                console.log('Plan Type Data:', JSON.stringify(this.planTypeData));
                this.showplanType = true;
            })
            .catch((error) => {
                console.error('Error fetching Plan Types:', error);
            });
    }

    hidefullPageHandler() {

        this.quoteflag = false;
    }


}