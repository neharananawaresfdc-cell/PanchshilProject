import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import CUSTOMCSS from '@salesforce/resourceUrl/EYI_CheckboxClass';
import ERROR_MESSAGE from '@salesforce/label/c.EYI_InvMatrixGenericError';
import NORECORDS_MESSAGE from '@salesforce/label/c.EYI_InvMatrixNoRecordsFound';
import inventoryMatrixTitle from '@salesforce/label/c.EYI_InventoryMatrixTitle';
import noProjectSelectedMessage from '@salesforce/label/c.EYI_NoInventoryProjSelected';
import getPicklistValues2 from '@salesforce/apex/EYI_InventoryMatrixController.getPicklistValues2';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord , notifyRecordUpdateAvailable  } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import INVENTORY_OBJECT from '@salesforce/schema/EYI_Inventory__c';
import UNITSTATUS_FIELD from '@salesforce/schema/EYI_Inventory__c.EYI_Inventory_Status__c';
import UNITVIEW_FIELD from '@salesforce/schema/EYI_Inventory__c.EYI_View_based_on_Amenities__c';

import PROJECT_OBJECT from '@salesforce/schema/EYI_Project__c';
import PROJECTTYPE_FIELD from '@salesforce/schema/EYI_Project__c.EYI_Project_Type__c';

import getProjectList from '@salesforce/apex/EYI_InventoryMatrixController.getAllProjects';
import getSubProjectList from '@salesforce/apex/EYI_InventoryMatrixController.getAllSubProjects';
import getTowerList from '@salesforce/apex/EYI_InventoryMatrixController.getAllTowers';
import getFloorList from '@salesforce/apex/EYI_InventoryMatrixController.getAllFloors';
import getFilteredFloorList from '@salesforce/apex/EYI_InventoryMatrixController.getFilterdInventoryData';
import getOpptyProjects from '@salesforce/apex/EYI_InventoryMatrixController.getOpptyProjects';
import getTotalTokenAmt from '@salesforce/apex/EYI_InventoryMatrixController.getTotalTokenAmt';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getPicklistConfig from '@salesforce/apex/EYI_InventoryMatrixController.getPicklistConfig';
import savePaymentSchedules from '@salesforce/apex/EYI_InventoryMatrixController.savePaymentSchedules';
import blockInventory from '@salesforce/apex/EYI_InventoryMatrixController.blockInventory';

import { getRecord } from 'lightning/uiRecordApi';
import OWNERNAME from '@salesforce/schema/Opportunity.Owner.Name';
import OPPNAME from '@salesforce/schema/Opportunity.Name';
import { refreshApex } from '@salesforce/apex'
import OWNER_ID_FIELD from '@salesforce/schema/Opportunity.OwnerId';
import MANAGER_ID_FIELD from '@salesforce/schema/Opportunity.Owner.ManagerId';
import userId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

const FIELDS = [
    'EYI_Inventory__c.EYI_Opportunity__c'  // Replace with actual API name of the Inventory Record object and field
];
const FIELDSINV = ['Opportunity.EYI_Inventory__c', 'Opportunity.Id'];

const OPPTYFIELDS = [OWNER_ID_FIELD,MANAGER_ID_FIELD, OWNERNAME, OPPNAME];

const USERFIELDS = [PROFILE_NAME_FIELD];

export default class EyiInventoryMatrix extends NavigationMixin(LightningElement) {
    showTooltip;
    oppNameOwner;
    helpTextContent;
    reservedUnitOppName;
    oppOwnerId;
    ownerManagerId;
    inventoryColorCodeMap = new Map();
    @track paymentSchedulesdata = [];
    @track inventoryFields = FIELDS;
    @track oppFields = FIELDSINV;
    @track projectTypeOptions = [];
    @track projectOptions = [];
    @track filteredProjectOptions = [];
    @track subProjectOptions = [];
    @track filteredSubProjectOptions = [];
    @track towerOptions = [];
    @track filteredTowerOptions = [];
    @track floorOptions = [];
    @track unitStatusOptions = [];
    @track unitViewOptions = [];
    badgeData = [];
    @track selectedInvID;
    @track profileName;
    @track isAdminBlockOpen= false;
    @track reasonForBlock='';
    @track statusVal ='';
    @track modalName='';
    @track isVacant = true;
    @track inventorystatus = '';
    @track blockButton = 'Block';
    @track isCommercial = true;
    @track showBlockBtn = false;
    // filteredProjectOptions
    // filteredProjectOptions

    @track selectedProject = '';
    @track selectedProjectType = '';
    @track selectedSubProject = '';
    @track selectedTower = '';
    @track selectedFloor = '';
    @track selectedProjectTitle = '';
    @track selectedTowerTitle = '';
    @track selectedUnitStatus = [];
    @track selectedUnitView = [];
    @track statusAllSelected = false;
    @track viewAllSelected = false;
    @track groupedData = [];
    @track opptyId;
    @track isStatusLoading = true;
    @track oppProjectData;
    @track isPropertiesLoading = false;
    @track isModalOpen = false;
    @track objectApiName = '';
    @track modalTitle = '';
    @track isReserveOppModalOpen = false;
    @track isBlockInventoryModelOpen = false;
    @track modalReserveOppTitle = '';
    @track modalBlockInventoryModelTitle = '';
    @track modalReserveOppClass = '';
    @track modalBlockInventoryModelClass = '';
    @track isBookingForm = false;
    @track isGroupedData = false;
    @track showLegends = false;
    @track isCollapsed = false;
    @track isPlotting = false;
    @track modalClass = '';
    @track inventoryMatrixFinalTitle = '';
    noRecordsMSG = NORECORDS_MESSAGE;
    noProjMessage = noProjectSelectedMessage;
    value = [];
    @track showFilter = true;
    buttonLable = '';
    buttonIcon = ''
    showProperty = false;
    isBackButtonVisible = false;
    badgeClassMap = new Map();
    @track oppProjectSelected = true;
    @track quotefullpage = false
    @track sendquotevalues
    @track towername
    @track totalTokenAmtReceived;
    @track sapCustomerNumber;
    @track hasSapCustomerNumber = false;
    @wire(CurrentPageReference)
    currentPageReference;
    @track inventoryId;
    @track blockAmount;
    @track selectedOpptyId;
    @track paymentStatusOptions = [];
    @track paymentTypeOptions = [];
    @track modeOfPaymentOptions = [];
    @track bankNameOptions = [];
    hasOppId = false;
    disableProject = false;
    loggedInUserId = userId;
    showSpinner = false;
    reserveStatusDateTime = new Date().toISOString();
    //get inventory color code
    @wire(getPicklistConfig)
    wiredCustomSetting({ data, error }) {
        if (data) {
            console.log('datainventoryColor', data);
            this.badgeData = data;
            this.error = undefined;
            //this.badgeClassMap = new Map();
            this.badgeData = data.map(item => {
                const className = `background-color: ${item.EYI_ClassName__c};`; // Use fallback color

                // Populate the badgeClassMap separately outside the map()
                this.badgeClassMap.set(item.EYI_Label__c, className);

                return {
                    ...item,
                    className
                };
            });
        } else if (error) {
            this.error = error;
            this.badgeData = [];
        }
        console.log('badge', this.badgeClassMap);
    }

    @wire(getPicklistValues2)
    wiredPicklistValues2({ error, data }) {
        if (data) {
            // Map the returned data to an array of options for combobox
            this.paymentStatusOptions = data['EYI_Payment_Status__c'].map(value => ({
                label: value,    // Display label in the combobox
                value: value     // Value of the combobox option
            }));

            this.paymentTypeOptions = data['EYI_Transaction_Type__c'].map(value => ({
                label: value,    // Display label in the combobox
                value: value     // Value of the combobox option
            }));
            this.modeOfPaymentOptions = data['EYI_Mode_of_Payment__c'].map(value => ({
                label: value,    // Display label in the combobox
                value: value     // Value of the combobox option
            }));
            this.bankNameOptions = data['EYI_Bank_Name__c'].map(value => ({
                label: value,    // Display label in the combobox
                value: value     // Value of the combobox option
            }));
            console.log('paymentStatusOptions', JSON.stringify(this.paymentStatusOptions));
            console.log('modeOfPaymentOptions', this.modeOfPaymentOptions);
            console.log('paymentTypeOptions', this.paymentTypeOptions);
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }


    @wire(getObjectInfo, { objectApiName: PROJECT_OBJECT })
    projectObjectInfo;

    @wire(getTotalTokenAmt, { oppId: '$opptyId' })
    totalTokenAmtR({ error, data }) {
        console.log('data23',data);
        this.totalTokenAmtReceived = data;
        //this.sapCustomerNumber = data.sapCustomerNumber;
        console.log('totalTokenAmtReceived', this.totalTokenAmtReceived);
        //console.log('SAP Customer Number:', this.sapCustomerNumber);
    }
    // Get Picklist Values for unit Status  
    @wire(getPicklistValues, { recordTypeId: '$projectObjectInfo.data.defaultRecordTypeId', fieldApiName: PROJECTTYPE_FIELD })
    wiredProjectTypePicklist({ error, data }) {
        if (data) {
            this.projectTypeOptions = data.values.map(option => ({
                ...option,
                checked: false
            }));
            //this.selectedUnitStatus = this.unitStatusOptions.map(option => option.value);
        } else if (error) {
            this.showToast(ERROR_MESSAGE);
        }
    }
    @wire(getObjectInfo, { objectApiName: INVENTORY_OBJECT })
    inventoryObjectInfo;
    // Get Picklist Values for unit Status  
    @wire(getPicklistValues, { recordTypeId: '$inventoryObjectInfo.data.defaultRecordTypeId', fieldApiName: UNITSTATUS_FIELD })
    wiredUnitStatusPicklist({ error, data }) {
        if (data) {
            this.unitStatusOptions = data.values.map(option => ({
                ...option,
                checked: false
            }));
            //this.selectedUnitStatus = this.unitStatusOptions.map(option => option.value);
        } else if (error) {
            this.showToast(ERROR_MESSAGE);
        }
    }
    addRow() {
        const newRecord = {
            Id: this.paymentSchedulesdata.length + 1, // Assign a unique ID for the key
            EYI_Usage_Description__c: '', // Set default value or leave empty
            EYI_Invoice_Percentage__c: 0, // Set default value or leave empty
            isNew: true
        };

        // Add the new record to the paymentSchedulesdata array
        this.paymentSchedulesdata = [...this.paymentSchedulesdata, newRecord];
    }
    deleteRow(event) {
        const indexToDelete = event.currentTarget.dataset.index;
        this.paymentSchedulesdata = this.paymentSchedulesdata.filter((item, index) => index.toString() !== indexToDelete);

    }
    // Get Picklist Values for unit view  
    @wire(getPicklistValues, { recordTypeId: '$inventoryObjectInfo.data.defaultRecordTypeId', fieldApiName: UNITVIEW_FIELD })
    wiredUnitViewPicklist({ error, data }) {
        if (data) {
            this.unitViewOptions = data.values.map(option => ({
                ...option,
                checked: false
            }));
            //this.selectedUnitView = this.unitViewOptions.map(option => option.value);
            console.log('this.selectedUnitView ==>', this.selectedUnitView);
            this.isStatusLoading = false;
        } else if (error) {
            this.isStatusLoading = false;
            this.showToast(ERROR_MESSAGE);
        }
    }
    // Get Project List
    @wire(getProjectList)
    getProjectList({ error, data }) {
        if (data) {
            this.projectOptions = [
                { label: 'None', value: '', projectType: null }, // Add "none" option first
                ...data.map(proj => ({
                    label: proj.Name,
                    value: proj.Id,
                    projectType: proj.EYI_Project_Type__c
                }))
            ];
            this.filteredProjectOptions = this.projectOptions;
        } else if (error) {
            this.projectOptions = [
                { label: 'None', value: '', projectType: null }, 
            ];
            this.showToast(ERROR_MESSAGE);
        }
    }
    // Get Subproject List
    @wire(getSubProjectList)
    getSubProjectList({ error, data }) {
        if (data) {
            this.subProjectOptions = [
                // Add "none" option first
                ...data.map(proj => ({
                    label: proj.Name,
                    value: proj.Id,
                    projectId: proj.EYI_Project_Name__c
                }))
            ];
            this.filteredSubProjectOptions = this.subProjectOptions.filter(subProj =>
                subProj.projectId === this.selectedProject
            );
        } else if (error) {
            this.showToast(ERROR_MESSAGE);
        }
    }
    // Get Tower List
    @wire(getTowerList)
    getTowerList({ error, data }) {
        if (data) {
            this.towerOptions = [
                // Add "none" option first
                ...data.map(towr => ({
                    label: towr.Name,
                    value: towr.Id,
                    projectId: towr.EYI_SubProject_Name__c
                }))
            ];
            this.filteredTowerOptions = this.towerOptions.filter(subTower =>
                subTower.projectId === this.selectedSubProject);
        } else if (error) {
            this.showToast(ERROR_MESSAGE);
        }
    }
    // get Floor List
    @wire(getFloorList)
    getFloorList({ error, data }) {
        if (data) {
            console.log('floors', data);
            console.log('floors2', this.selectedProject);
            // Create a Set to track unique floor numbers
            const uniqueFloors = new Set();
            // Filter the data to get unique floor numbers
            this.floorOptions = data
                .filter(floor => floor.EYI_Floor_No__c != null && // Check for null or undefined

                    floor.EYI_Project__c == this.selectedProject
                )
                .map(floor => ({
                    label: String(floor.EYI_Floor_No__c), // Convert to string for label
                    value: String(floor.EYI_Floor_No__c),
                    projectId: floor.EYI_Tower__c  // Convert to string for value
                }));
            // this.floorOptions.unshift({
            //     label: 'None',
            //     value: '' // Use an empty string or any value that signifies "None"
            // });
            console.log('floorOptions ====>', JSON.stringify(this.floorOptions));
            // Optionally set the initial selected floor to "None"
            this.selectedFloor = '';
            this.filteredFloorOptions = this.floorOptions.filter(subFloor =>
                subFloor.projectId === this.selectedTower &&
                !uniqueFloors.has(subFloor.EYI_Floor_No__c) &&
                uniqueFloors.add(subFloor.EYI_Floor_No__c));
            console.log('floorOptions2 ====>', this.selectedTower);
            console.log('floorOptions3 ====>', JSON.stringify(this.filteredFloorOptions));
        } else if (error) {
            this.showToast(ERROR_MESSAGE);
        }
    }
    // ConnectedCallBack
    connectedCallback() {
        this.buttonLable = 'Hide Filter';
        this.buttonIcon = 'utility:hide';
        this.inventoryMatrixFinalTitle = inventoryMatrixTitle;
        this.opptyId = this.currentPageReference.state.c__oppid;
        if (this.opptyId) {
            this.hasOppId = true;
            this.loadOpptyProjectData(this.opptyId);
            this.isBackButtonVisible = true;
            this.disableProject = true;
        }
        if(this.profileName === 'System Administrator' || this.profileName ==	'Business Admin'){
            this.showBlockBtn=true;
        }
    
        //this.filterProjects();
        //this.filterSubProjects();

    }
    //renderedCallback
    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true;
        loadStyle(this, CUSTOMCSS).then(() => {
            console.log('loaded');
        })
            .catch(error => {
                console.log('error to load', error);
            });
    }

    handleCollapse(event) {
        try {
            const floorNumber = event.currentTarget.dataset.floornumber;
            console.log('floorNumber==>', floorNumber);
            this.groupedData = this.groupedData.map(inv => {
                if (inv.floorNumber == floorNumber) {
                    inv.showInventories = !inv.showInventories;
                    // Change the icon based on collapse state                
                    inv.icon = inv.showInventories ? 'utility:chevrondown' : 'utility:chevronright';
                }
                return inv;
            });
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    //This function is used to set values of status and background Color
    handleStatusChange(event) {
        try {
            const value = event.target.dataset.value;
            const checked = event.target.checked;
            this.unitStatusOptions = this.unitStatusOptions.map(option => {
                if (option.value === value) {
                    option.checked = checked;
                }
                return option;
            });

            if (checked) {
                this.selectedUnitStatus.push(value);
            } else {
                this.selectedUnitStatus = this.selectedUnitStatus.filter(item => item !== value);
            }
            this.statusAllSelected = this.unitStatusOptions.every(option => option.checked);
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }

    filterProjects() {
        if (this.selectedProjectType) {
            this.filteredProjectOptions = [
                { label: 'None', value: '', projectType: null }, // Add "none" option first
                ...this.projectOptions.filter(proj =>
                    proj.projectType === this.selectedProjectType
                )
            ];
        } else {
            this.filteredProjectOptions = [
                { label: 'None', value: '', projectType: null }, // Reset with "none" option
                ...this.projectOptions // Include all options
            ];
        }
    }
    filterSubProjects() {

        if (this.selectedProject) {
            console.log('test34', this.selectedProject);
            this.filteredSubProjectOptions = [
                { label: 'None', value: '', projectId: null }, // Add "none" option first
                ...this.subProjectOptions.filter(subProj =>
                    subProj.projectId === this.selectedProject
                )
            ];
        } else {
            this.filteredSubProjectOptions = [
                { label: 'None', value: '', projectId: null }, // Reset with "none" option
                ...this.subProjectOptions // Include all options
            ];
        }
    }
    filterTowers() {
        if (this.selectedSubProject) {
            this.filteredTowerOptions = [
                { label: 'None', value: '', projectId: null }, // Add "none" option first
                ...this.towerOptions.filter(tower =>
                    tower.projectId === this.selectedSubProject
                )
            ];
        } else {
            this.filteredTowerOptions = [
                { label: 'None', value: '', projectId: null }, // Reset with "none" option
                ...this.towerOptions // Include all options
            ];
        }
    }
    filterFloors() {
        const uniqueFloors = new Set();
        console.log('floors', this.selectedTower);
        if (this.selectedTower) {
            this.filteredFloorOptions = [
                { label: 'None', value: '', projectId: null }, // Add "none" option first
                ...this.floorOptions.filter(floor =>
                    floor.projectId === this.selectedTower &&
                    !uniqueFloors.has(floor.EYI_Floor_No__c) &&
                    uniqueFloors.add(floor.EYI_Floor_No__c)
                )
            ];
            console.log('floors123', this.filteredFloorOptions);
        } else {
            this.filteredFloorOptions = [
                { label: 'None', value: '', projectId: null }, // Reset with "none" option
                ...this.floorOptions // Include all options
            ];
        }
    }
    //This function is used to set values of status List
    handleStatusAllChange(event) {
        try {
            const checked = event.target.checked;
            this.statusAllSelected = checked;

            this.unitStatusOptions = this.unitStatusOptions.map(option => ({
                ...option,
                checked: checked
            }));

            if (checked) {
                this.selectedUnitStatus = this.unitStatusOptions.map(option => option.value);
            } else {
                this.selectedUnitStatus = [];
            }
            console.log('Status ==>', JSON.stringify(this.selectedUnitStatus));
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    //This function is used to set values of unit view
    handleViewChange(event) {
        try {
            const value = event.target.dataset.value;
            const checked = event.target.checked;
            this.unitViewOptions = this.unitViewOptions.map(option => {
                if (option.value === value) {
                    option.checked = checked;
                }
                return option;
            });

            if (checked) {
                this.selectedUnitView.push(value);
            } else {
                this.selectedUnitView = this.selectedUnitView.filter(item => item !== value);
            }
            this.viewAllSelected = this.unitViewOptions.every(option => option.checked);
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    //This function is used to set values of all units in list
    handleViewAllChange(event) {
        try {
            const checked = event.target.checked;
            this.viewAllSelected = checked;

            this.unitViewOptions = this.unitViewOptions.map(option => ({
                ...option,
                checked: checked
            }));

            if (checked) {
                this.selectedUnitView = this.unitViewOptions.map(option => option.value);
            } else {
                this.selectedUnitView = [];
            }
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    //This function is used to set values of all units in list
    handleFetchData() {
        this.isPropertiesLoading = true;
        const comboboxes = Array.from(this.template.querySelectorAll('lightning-combobox'))
            .filter(combobox => combobox.required);
        var allValid = true;
        if (!this.opptyId) {
            comboboxes.forEach(combobox => {
                if (combobox.required) {
                    // Check validity
                    if (!combobox.checkValidity()) {
                        // Report validity error
                        combobox.reportValidity();
                        allValid = false; // Set allValid to false if any combobox is invalid
                        console.log('AllValid 333', allValid);
                    }
                }
            });
        }
        console.log('AllValid 338 ', allValid);

        if (allValid) {
            const params = {
                selectedProjectType: this.selectedProjectType,
                selectedProject: this.selectedProject,
                selectedSubProject: this.selectedSubProject,
                selectedTower: this.selectedTower,
                selectedFloor: this.selectedFloor,
                selectedUnitStatus: this.selectedUnitStatus,
                selectedUnitView: this.selectedUnitView
            };
            console.log('listofunitstatus', this.selectedUnitStatus);
            console.log('Params==>', JSON.stringify(params));
            this.inventoryMatrixFinalTitle = this.isPlotting ? inventoryMatrixTitle + (this.selectedProjectTitle != ''?' - ' + this.selectedProjectTitle: '')
                : inventoryMatrixTitle + (this.selectedProjectTitle != ''?' - ' + this.selectedProjectTitle: '')  + (this.selectedTowerTitle != ''?' - ' + this.selectedTowerTitle: '');
                
            this.showHideFilter();
            this.handleRetrieveData(params);

        } else {
            // this.showErrorToast(inventoryMatrixReqFields);
        }
    }
    // This method pass parameters to Apex controller for inventories
    handleRetrieveData(params) {
        try {
            getFilteredFloorList({ jsonParams: JSON.stringify(params) })
                .then(result => {
                    console.log('Result from Apex:', JSON.stringify(result));
                    if (result && result.length > 0) {
                        
                        const updatedResult = result.map(item => {
                            const oppOwner = item.EYI_Opportunity__r?.Owner?.Name || 'Unknown Owner';
                            const oppOwnerID = item.EYI_Opportunity__r?.Owner?.Id;
                            const oppOwnerManagerID = item.EYI_Opportunity__r?.Owner?.ManagerId;
                            const oppName = item.EYI_Opportunity__r?.Name || 'Unknown Opportunity';
                            
                            if(item.EYI_Project__r.EYI_Project_Property_Type__c == 'Residential'){
                                this.isCommercial = false;
                            }else{
                                this.isCommercial = true;
                            }
                        
                            // Add a new property with the custom message
                            return {
                                ...item,
                                reservedMessage: `This unit is reserved by ${oppOwner}`,
                                oppOwnerId : `${oppOwnerID}`,
                                oppOwnerManagerID: `${oppOwnerManagerID}`
                            };
                        });

                        this.isGroupedData = true;
                        this.showLegends = true;
                        this.groupData(updatedResult);
                        this.showProperty = true;



                        console.log('badgeData', this.badgeData);
                    } else {
                        this.showProperty = true;
                        this.showFilter = true;
                        this.isPropertiesLoading = false;
                        this.isGroupedData = false;
                    }

                })
                .catch(error => {
                    this.showErrorToast(ERROR_MESSAGE);
                });
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    // This method is used to group the inventory data by floor numbers
    groupData(result) {
        try {
            // Parse JSON data if it's a string
            const parsedData = typeof result === 'string' ? JSON.parse(result) : result;
            console.log('parseddata:::', parsedData)
            // Group data by floor number
            if (this.isPlotting) {
                this.groupedData = parsedData.map(item => ({
                    ...item,
                    isReserved: item.EYI_Inventory_Status__c == 'Vacant' ? true : false,
                    isBlocked: item.EYI_Inventory_Status__c == 'Reserve' ? true : false,
                    className: this.badgeClassMap.get(item.EYI_Inventory_Status__c) // Use fallback color

                }));
                // You can keep the sorting if needed, based on a specific field
                this.groupedData.sort((a, b) => {
                    return parseInt(a.name, 10) - parseInt(b.name, 10);
                });
            } else {
                const grouped = parsedData.reduce((inv, item) => {
                    const floor = item.EYI_Floor_No__c;
                    if (!inv[floor]) {
                        inv[floor] = [];
                    }
                    // Create a new object with additional className property
                    const recordWithClass = {
                        ...item,
                        isReserved: item.EYI_Inventory_Status__c == 'Vacant' ? true : false,
                        isBlocked: item.EYI_Inventory_Status__c == 'Reserve' ? true : false,
                        className: this.badgeClassMap.get(item.EYI_Inventory_Status__c)   // Use fallback color

                    };

                    inv[floor].push(recordWithClass);
                    return inv;
                }, {});

                this.groupedData = Object.keys(grouped)
                    .map(floorNumber => ({
                        floorNumber: floorNumber,
                        icon: 'utility:chevrondown',
                        showInventories: true,
                        records: grouped[floorNumber]
                    }))
                    .sort((a, b) => {
                        // Convert floor numbers to integers for proper numeric sorting
                        return parseInt(a.floorNumber, 10) - parseInt(b.floorNumber, 10);
                    });
            }
            console.log('groupedData==>', JSON.stringify(this.groupedData));

            this.isPropertiesLoading = false;
            if ((this.isBackButtonVisible || (this.isBackButtonVisible == false)) && (this.selectedUnitStatus.length < 1)
                && (this.selectedUnitView.length < 1)) {
                this.initializeCheckBox();
            }
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    // This method is used to open the inventory detail page
    handleRecordClick(event) {
        try {
            const recordId = event.target.dataset.recordId;
            this.navigateToRecord(recordId);
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'EYI_Inventory__c',
                actionName: 'view'
            }
        });
    }
    // This method is used to update the unit status and unit view values
    initializeCheckBox() {
        try {
            this.viewAllSelected = true;
            this.statusAllSelected = true;
            this.unitStatusOptions = this.unitStatusOptions.map(option => {
                option.checked = true;
                this.selectedUnitStatus.push(option.value);
                return option;
            });
            this.unitViewOptions = this.unitViewOptions.map(option => {
                option.checked = true;
                this.selectedUnitView = this.unitViewOptions.map(option => option.value);
                return option;
            });
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    // This method is used to dynamically select the classess of the inventory for status color
    getRecordClass(status) {
        switch (status) {
            case 'Available':
                return 'record-item Available';
            case 'Booked':
                return 'record-item Booked';
            case 'Blocked':
                return 'record-item Blocked';
            case 'Sold':
                return 'record-item Sold';
            case 'Hold For Booking':
                return 'record-item HoldforBooking';
            case 'Refuge':
                return 'record-item Refuge';
            case 'Possession Given':
                return 'record-item Possessiongiven';
            case 'EOI Blocked':
                return 'record-item EOIBlocked';
            case 'Payment In Progress':
                return 'record-item PaymentInProgress';
            case 'Quotation Is Sent':
                return 'record-item QuotationIsSent';
            case 'Not Sanctioned':
                return 'record-item under_maintenance';
            default:
                return 'record-item Available';
        }
    }
    // This method is used to handle the filter button 
    showHideFilter() {
        this.showFilter = !this.showFilter;
        this.buttonLable = this.showFilter ? 'Hide Filter' : 'Show Filter';
        this.buttonIcon = this.showFilter ? 'utility:hide' : 'utility:preview'//preview
        this.quotefullpage = false
        this.isModalOpen = false
    }
    // This method is used to display the property section after filter button is clicked
    handleClick() {
        try {
            this.showProperty = true;
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    handleStandardSave(event) {
        try {
            let btn = this.template.querySelectorAll('lightning-button');
            btn.forEach(elem => {
                //console.log('np',elem,JSON.stringify(elem));
                try {
                    //console.log('np',btn[elem],JSON.stringify(btn[elem]),btn[elem].label,btn[elem].name);
                    console.log('np1', elem, JSON.stringify(elem), elem.label, elem.name);
                    if (elem.label == 'Save') {
                        console.log('save', btn[elem], JSON.stringify(btn[elem]));
                        //btn[elem].click();
                    }
                } catch (err) {
                    console.log('test btns', err);
                }

            });

            //btn.click();
        }
        catch (err) {
            console.error('stan save error', err);
        }
    }
    // This method is used to reset the filters of inventory matrix
    handleClearFilter() {
        try {
            this.showProperty = false;
            this.groupedData = [];
            this.selectedFloor = '';
            this.selectedProject = '';
            this.selectedSubProject = '';
            this.selectedTower = '';
            this.selectedUnitStatus = [];
            this.selectedUnitView = [];
            this.statusAllSelected = false;
            this.viewAllSelected = false;
            this.inventoryMatrixFinalTitle = inventoryMatrixTitle;
            this.selectedProjectTitle = '';
            this.selectedTowerTitle = '';
            this.selectedProjectType = '';
            this.unitStatusOptions = this.unitStatusOptions.map(option => {
                option.checked = false; // Uncheck all options
                return option;
            });
            this.unitViewOptions = this.unitViewOptions.map(option => {
                option.checked = false; // Uncheck all options
                return option;
            });
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    // This method is used to redirect to the opportunity detail page
    handleBack() {
        try {
            if (this.opptyId) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.opptyId,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });
            } else {
                console.error('No recordId to navigate back to.');
            }
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    // This method is used to update the values of the selected project, tower, floor, unit status and unit view.
    handleChange(event) {
        try {
            let field = event.target.name;
            let value = event.target.value;
            let filterTowerNames = this.towerOptions
            filterTowerNames.filter(res => {
                if (value == res.value) {
                    this.towername = res.label
                }
            })
            // this.towername = event.target.name;
            if (field === 'project') {
                this.selectedProject = value;
                this.filteredTowerOptions = [];
                this.filterSubProjects();
                this.filterTowers();
                this.filterFloors()
                const selectedOption = this.projectOptions.find(option => option.value === value);
                this.selectedProjectTitle = selectedOption ? selectedOption.label : '';
                console.log('this.selectedProject =>', this.selectedProject);
            } else if (field === 'projectType') {
                this.selectedProjectType = value;
                this.showProperty = false;
                this.groupedData = [];
                this.selectedTower = '';
                this.selectedFloor = '';
                this.selectedSubProject = '';
                this.filterProjects();
                if (this.selectedProjectType == 'Plot') {
                    this.isPlotting = true;
                } else {
                    this.isPlotting = false;
                }
                console.log('this.selectedProject =>', this.selectedProjectType);
            } else if (field === 'subProject') {
                this.selectedSubProject = value;
                console.log('this.selectedSubProject2 =>', this.selectedSubProject);
                this.filteredTowerOptions = [];
                this.filterTowers();
                this.filterFloors();
            } else if (field === 'tower') {
                this.selectedTower = value;
                const selectedOption = this.filteredTowerOptions.find(option => option.value === value);
                this.selectedTowerTitle = selectedOption ? selectedOption.label : '';
                this.filterFloors();
                console.log('this.selectedTower =>', this.selectedTower);
            } else if (field === 'floor') {

                this.selectedFloor = value;
                console.log('this.selectedFloor =>', this.selectedFloor);
            } else if (field === 'unitStatus') {
                this.selectedUnitStatus = event.detail.value; // For multi-select or dual listbox
            } else if (field === 'unitView') {
                this.selectedUnitView = event.detail.value; // For multi-select or dual listbox
            }
        } catch (error) {
            // this.showErrorToast(ERROR_MESSAGE);
        }
    }


    // This method is used to fetch the opportunity details to open the inventory matrix from opportunity detail page button
    loadOpptyProjectData(oppId) {
        getOpptyProjects({ oppId: oppId })
            .then(result => {
                this.oppProjectData = result;
                console.log('Opportunity Data: ', JSON.stringify(result));
                if (this.oppProjectData && this.oppProjectData.length > 0) {
                    let data = this.oppProjectData[0];
                    this.sapCustomerNumber = data.EYI_SAP_Customer_Number__c ? data.EYI_SAP_Customer_Number__c : '';
                    this.hasSapCustomerNumber = !!this.sapCustomerNumber;
                    console.log('this.hasSapCustomerNumber',this.hasSapCustomerNumber);
                    this.selectedProject = data.EYI_Project_Enquired__c ? data.EYI_Project_Enquired__c : '';
                    console.log('Opportunity Data: 1', JSON.stringify(result));
                    if (this.selectedProject) {
                        // this.filterSubProjects();
                        this.selectedProjectType = data.EYI_Project_Enquired__r.EYI_Project_Type__c ? data.EYI_Project_Enquired__r.EYI_Project_Type__c : '';
                        console.log('Opportunity Data: 2', JSON.stringify(result));

                        if (this.selectedProjectType == 'Plot') {
                            this.isPlotting = true;
                        }
                        console.log('this.selectedProject =>', this.selectedProjectType);

                        this.selectedTower = data.EYI_Project_Tower_Enquired__c ? data.EYI_Project_Tower_Enquired__c : '';
                        console.log('this.selectedTower =>', this.selectedTower);
                        this.selectedSubProject = data.EYI_SubProject_Name__c ? data.EYI_SubProject_Name__c : '';

                        this.selectedProjectTitle = data.EYI_Project_Enquired__r.Name;
                        console.log('this.selectedProjectTitle =>', this.selectedProjectTitle);

                        if (!this.isPlotting) {
                            this.selectedTowerTitle = data.EYI_Project_Tower_Enquired__r.Name;
                            this.inventoryMatrixFinalTitle = inventoryMatrixTitle +  (this.selectedProjectTitle != ''?' - ' + this.selectedProjectTitle: '')  + (this.selectedTowerTitle != ''?' - ' + this.selectedTowerTitle: '');
                        } else {
                            this.inventoryMatrixFinalTitle = inventoryMatrixTitle + ' - ' + this.selectedProjectTitle;
                        }
                        console.log('this.inventoryMatrixFinalTitle =>', this.inventoryMatrixFinalTitle);

                        this.showProperty = true;
                        console.log('this.selectedProject =>', this.showProperty);
                        //this.filterSubProjects();
                        this.handleFetchData();

                    } else {
                        this.oppProjectSelected = false;
                        this.inventoryMatrixFinalTitle = inventoryMatrixTitle;

                        console.log('Property not found');
                    }
                }
            })
            .catch(error => {
                //this.showErrorToast(ERROR_MESSAGE);
            });
    }
    //Navigate to paymentreceipt
    handlePRNav(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Payment_Receipt_Creation' // Use the API name of the Lightning Tab you created
            },
            state: {
                c__recordId: this.opptyId // Pass parameters if needed
            }
        });
    }

    //Naviaget to QuotePage
    quotePageHandler() {

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Quote_Page',
            },
            state: {
                c__recordId: '001XXXXXXXXXXXXXXX', // Pass the recordId as a parameter
                c__otherParam: 'SampleValue', // Optional: Additional parameters
            },
        }).then((url) => {
            // Navigate to the constructed URL
            window.open(url, '_self');
        });
    }


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
    // This method is used to open the parking list view
    navigateToAllParkings() {
        try {
            // Redirect to the All Parkings List view
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'EYI_Inventory__c',
                    actionName: 'list'
                },
                state: {
                    filterName: 'Available_Parking'
                }
            });
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    @wire(getRecord, { recordId: '$opptyId', fields: '$oppFields' })
    opportunityUpdateData;

    //this method will map the invenoty against opportunity
    reserveUnit(event) {
        //refreshApex(this.opportunityUpdateData);
        //notifyRecordUpdateAvailable([{ recordId: this.opportunityUpdateData.data.fields.Id.value }]);
        const recordId = event.target.dataset.recordId;
        console.log('tags1', this.opportunityUpdateData);
        if (this.opportunityUpdateData.data.fields.EYI_Inventory__c.value != undefined || this.opportunityUpdateData.data.fields.EYI_Inventory__c.value != null) {
            // const tags = this.opportunity.data.fields.EYI_Inventory__c.value;
            //  console.log('tags',tags);
            this.showErrorToast('Opportunity already has the inventory tag.');
            // Show error message


        } else {
            console.log('tags2');
            // Proceed with reservation
            this.reserveUnitForFreshOpp(recordId);
        }
        //this.reserveUnitForFreshOpp(recordId)
    }
    reserveUnitForFreshOpp(recordId) {
        console.log('test1');
        if (this.opptyId) {
            console.log('test2');

            this.handleUpdate(this.opptyId, recordId);

        } else {
            try {
                this.selectedInvID = recordId;
                this.modalReserveOppTitle = 'Select Opp to Reserve the Inventory';
                this.modalReserveOppClass = 'slds-modal__container modal_New';
                this.isReserveOppModalOpen = true; // Open the modal
            } catch (error) {
                this.showErrorToast(ERROR_MESSAGE);
            }
        }
    }

    //getting opportunity ownerId
    @wire(getRecord, { recordId: '$opptyId', fields: OPPTYFIELDS })
    opportunityRec({ error, data }) {
        if (data) {
            console.log('data 1087', data);
            this.oppNameOwner = data.fields.Owner.displayValue;
            this.reservedUnitOppName = data.fields.Name.value;
            this.oppOwnerId = data.fields.OwnerId.value;
            this.ownerManagerId = data.fields.Owner.value.fields.ManagerId.value;
            this.helpTextContent = 'This unit is reserved by' +' '+ this.oppNameOwner + ' ';
        } else if (error) {
            this.error = error;
        }
    };

    //getting profileName
    @wire(getRecord, { recordId: '$loggedInUserId', fields: PROFILE_NAME_FIELD })
    userProfile({ error, data }) {
        if (data) {
            this.profileName = data.fields.Profile.value.fields.Name.value;
            if(this.profileName === 'System Administrator' || this.profileName ==	'Business Admin'){
                this.showBlockBtn=true;
            }
        } else if (error) {
            this.error = error;
        }
    }

    unReserveUnit(event) {
        notifyRecordUpdateAvailable([{ recordId: this.opptyId }]);
        const recordId = event.target.dataset.recordId;
        console.log('recid', recordId);
        console.log('oppId', this.opptyId);
        //console.log('opportunityRec', this.opportunityRec.data);
        console.log('profilename', this.profileName);

        if (this.opptyId && (this.loggedInUserId === this.oppOwnerId || this.profileName === 'System Administrator')) {
            const fields = {};
            fields['Id'] = recordId;
            fields['EYI_Inventory_Status__c'] = 'Vacant';

            this.groupedData.forEach(group => {
                group.records.forEach(record => {
                    if (record.Id === recordId) {
                        record.className = `background-color: green;`;
                        record.EYI_Inventory_Status__c = 'Vacant';
                        record.isReserved = true;
                        record.isBlocked = false;
                    }
                });
                this.showSpinner = true;
            });
            const recordInput = { fields };
            //console.log('checking opp owner', this.opportunityRec.data.fields.OwnerId.value);
            console.log('checking userId', this.loggedInUserId);

            updateRecord(recordInput)
                .then(() => {
                    console.log('Inventory Released');
                    notifyRecordUpdateAvailable([{ recordId: this.opptyId }]);
                    refreshApex(this.opportunityUpdateData);
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.error('Error updating record:', error);
                })


        }
        else {
            console.log('You do not have permission to release this unit');
            this.showErrorToast('You do not have permission to release this unit');
        }

    }

    @wire(getRecord, { recordId: '$inventoryId', fields: '$inventoryFields' })
    wiredRecord({ error, data }) {
        console.log('data23', data);
        if (data) {
            this.selectedOpptyId = data.fields.EYI_Opportunity__c.value;
        } else if (error) {
            console.error('Error retrieving record:', error);
        }
    }
    blockUnit(event) {
        if (this.opptyId && (this.loggedInUserId === this.oppOwnerId || this.loggedInUserId === this.ownerManagerId ||  this.profileName === 'System Administrator')) {
            this.inventoryId = event.target.dataset.recordId;
            this.blockAmount = event.target.dataset.minimumTokenamt;

            const recordId = event.target.dataset.recordId;
            this.modalBlockInventoryTitle = 'Please enter the payment details';
            this.modalBlockInventoryClass = 'slds-modal__container modal_New slds-size_large custom-modal-width';
            this.isBlockInventoryModelOpen = true; // Open the modal
        }
        else {
            console.log('You do not have permission to block this unit');
            this.showErrorToast('You do not have permission to block this unit');
        }
    }
    handleUpdate(opptyId, selectedInventoryId) {
        console.log('test3');
        console.log('opptyId::', opptyId);
        console.log('selectedInventoryId', selectedInventoryId);

        const fields = {};
        fields['Id'] = selectedInventoryId; // Replace with the actual record ID
        fields['EYI_Opportunity__c'] = opptyId;
        //fields['EYI_Reserver_Date__c'] = this.reserveStatusDateTime;
        fields['EYI_Inventory_Status__c'] = 'Reserve'; // Replace with the actual field API name and value

        const recordInput = { fields };
        let date = new Date(); // creates a Date object for February 10, 2025
        let formattedDate = date.toISOString();
        //     const fields2 = {};
        //     fields2['Id'] = opptyId; // Replace with the actual record ID
        //     fields2['EYI_Inventory__c'] = selectedInventoryId;
        //     fields2['EYI_AutomationBypassDatetime__c'] = formattedDate;
        //    // fields['EYI_Inventory_Status__c'] = 'Reserve'; // Replace with the actual field API name and value

        //     const recordInput2 = { fields2 };
        console.log('updateOpp', JSON.stringify(recordInput));
        this.updateInventoryRecord(recordInput);
        // this.updateOppRecord(recordInput2); //can we try by apex?
        this.groupedData.forEach(group => {
            group.records.forEach(record => {
                if (record.Id === selectedInventoryId) {
                    record.className = `background-color: grey;`;
                    record.EYI_Inventory_Status__c = 'Reserve';
                    record.isReserved = false;
                    record.isBlocked = true;
                }
            });
        });

        // console.log('selectedInventoryId',selectedInventoryId);
        // const divname = '#a0RC4000000UTB3MAO-133';
        // console.log('divname',divname);
        // const divElement = this.template.querySelector(divname);
        // console.log('divElement',divElement);
        //         divElement.style.backgroundColor = 'Grey';

    }

    closeReserveModal() {
        this.isReserveOppModalOpen = false;
        // this.selectedOpportunityId = ''; // Reset the selected opportunity
    }
    closeBlockInventoryModel() {
        this.isBlockInventoryModelOpen = false;
        // this.selectedOpportunityId = ''; // Reset the selected opportunity
    }
    handleSuccess(event) {
        this.groupedData.forEach(group => {
            group.records.forEach(record => {
                if (record.Id === this.selectedInvID) {
                    record.className = `background-color: grey;`;
                    record.EYI_Inventory_Status__c = 'Reserve';
                    record.isReserved = false;
                    record.isBlocked = true;
                }
            });
        });
        const fields = {};
        let date = new Date(); // creates a Date object for February 10, 2025
        let formattedDate = date.toISOString();
        fields['Id'] = this.opptyId; // Replace with the actual record ID
        //fields['EYI_Opportunity__c'] = this.selectedOpptyId;
        fields['StageName'] = 'Reserve';
        //fields['EYI_Token_Amount__c'] = amount;// Replace with the actual field API name and value
        fields['EYI_AutomationBypassDatetime__c'] = formattedDate;
        const recordInput = { fields };
        console.log('recordInput', JSON.stringify(recordInput));
        //this.updateOppRecord(recordInput);

        this.isReserveOppModalOpen = false;
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Inventory updated successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);

    }
    handleSubmitPaymentReceipt(event) {
        event.preventDefault();

        // Get form fields' values
        const fields = event.detail.fields;
        console.log('test1223', fields);
        console.log('check', fields.EYI_Amount__c);
        console.log('test123', this.blockAmount);
        if (parseInt(fields.EYI_Amount__c) < parseInt(this.blockAmount)) {
            console.log('test1234');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Minimum amount required as per project level',
                    variant: 'Error'
                })
            );
            //this.showError('Minimum amount required as per project level');
            return;
        }
        event.target.submit();
    }
    handlePaymentSuccess(event) {
        const amount = event.detail.fields.EYI_Amount__c;
        const fields = {};
        let date = new Date(); // creates a Date object for February 10, 2025
        let formattedDate = date.toISOString();
        fields['Id'] = this.selectedOpptyId; // Replace with the actual record ID
        //fields['EYI_Opportunity__c'] = this.selectedOpptyId;
        fields['StageName'] = 'Block';
        fields['EYI_Token_Amount__c'] = amount;// Replace with the actual field API name and value
        fields['EYI_AutomationBypassDatetime__c'] = formattedDate;
        const recordInput = { fields };
        console.log('recordInput', JSON.stringify(recordInput));
        this.updateInventoryRecord(recordInput);


    }
    handleError(event) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Error updating the data',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }


    // This method is used to open the EOI modal poupup
    createEOI() {
        try {
            this.objectApiName = 'EYI_Expression_Of_Interest__c'
            this.modalTitle = 'Create new EOI';
            this.modalClass = ' slds-modal__container modal_New';
            this.isModalOpen = false;
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }
    closeAdminBlock(){
        this.isAdminBlockOpen = false;
        this.inventoryId = '';
        this.reasonForBlock = '';
        this.statusVal = '';
    }
    handleBlock(event){
        if(this.profileName === 'System Administrator' || this.profileName ==	'Business Admin'){
            this.inventorystatus = event.currentTarget.dataset.invstatus;
            this.inventoryId = event.target.dataset.id;
            console.log('inventorystatus==>  ',this.inventorystatus);
            if(this.inventorystatus == 'Vacant'){
                this.blockInputLabel = "Reason For Block";
                this.modalName = 'Block Inventory';
                this.statusVal= 'Blocked';
                this.isVacant = true;
                this.blockButton = 'Block'
                this.isAdminBlockOpen = true;
            }else if(this.inventorystatus == 'Blocked'){
                this.blockInputLabel = 'Reason For Block';
                this.statusVal= 'Vacant';
                this.reasonForBlock = event.target.dataset.blockreason;
                this.modalName = 'Vacant Inventory';
                this.isVacant = false;
                this.blockButton = 'Vacant'
                this.isAdminBlockOpen = true;

            }
        }else{
            this.showErrorToast('You do not have permission to Block/Vaccant this unit');

        }
    }
    updateCurrentInventory(){
        this.groupedData.forEach(group => {
            group.records.forEach(record => {
                if (record.Id === this.inventoryId) {
                    if(this.statusVal ==='Vacant'){
                        record.className = `background-color: green;`;
                        record.isBlocked = false;
                        record.EYI_Inventory_Status__c = 'Vacant';
                        record.Remarks_for_Block__c = '';
                        console.log('Current Inv=> Vacant ',JSON.stringify(record));

                    }else if(this.statusVal === 'Blocked'){
                        record.className = `background-color: #ffb700;`;
                        record.isBlocked = true;
                        record.Remarks_for_Block__c = this.reasonForBlock;
                        record.EYI_Inventory_Status__c = 'Blocked';
                        console.log('Current Inv=> Blocked',JSON.stringify(record));
                    }
                   
                }
            });
        });
    }
    handleRasonChange(event){
        this.reasonForBlock = event.target.value;
    }
    updateStatus() {
        console.log('blockreason',this.reasonForBlock);
        console.log('Id' , this.inventoryId);
        if ((!this.reasonForBlock || !this.inventoryId) && this.statusVal!= 'Vacant') {
             const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please enter block reason',
                    variant: 'Warning',
                });
                this.dispatchEvent(evt);
            return;
        }
        blockInventory({
            invId: this.inventoryId,
            blockReason: this.reasonForBlock,
            status: this.statusVal
        })
        .then(result => {
            if (result) {
                this.updateCurrentInventory();
                this.closeAdminBlock();
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Inventory updated successfully',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                // Optional: show success toast
            } else {
                // Optional: show error toast
            }
        })
        .catch(error => {
            console.error('Error calling blockInventory:', error);
            // Optional: show error toast
        });
    }
    // This method is used to open the Quote modal poupup
    createQuote(event) {
         const oppOwnerManagerID = event.currentTarget.dataset.oppownermanagerid;
          const ownerid = event.currentTarget.dataset.ownerid;
          let inventorystatus = event.currentTarget.dataset.invstatus;
          console.log('event this inv status::', inventorystatus);
         console.log('event id::', oppOwnerManagerID);
         console.log('event id2:', ownerid);
          console.log('event id2:', this.ownerid);
         console.log('event id3:', this.loggedInUserId);
        if (inventorystatus == 'Vacant' || (this.loggedInUserId === ownerid || this.loggedInUserId === oppOwnerManagerID ||  this.profileName === 'System Administrator' || this.profileName ==	'Business Admin')) {
            console.log('You have permission');
            this.isModalOpen = true;
            console.log('event id::', event.target.dataset.id)

            this.sendquotevalues = {
                ...this.sendquotevalues,
                Tower: this.towername, floor: this.selectedFloor
            }

            console.log(' this.sendquotevalues:::', this.sendquotevalues)

            this.inventoryId = event.target.dataset.id
            try {
                this.objectApiName = 'Quote';
                this.modalTitle = 'Create New Quote';
                this.modalClass = ' slds-modal__container modal_New';
                this.isModalOpen = true;
            } catch (error) {
                this.showErrorToast(ERROR_MESSAGE);
            }
        }
        else {
            console.log('You do not have permission to create quote on this unit');
            this.showErrorToast('You do not have permission to create quote on this unit');
        }
    }
    // This method is used to open the booking modal poupup
    createBooking() {
        try {
            this.isBookingForm = true;
            this.objectApiName = 'EYI_Booking__c';
            this.modalTitle = 'Create New Booking';
            this.modalClass = 'slds-modal__container modal_Booking';
            this.isModalOpen = false;
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }

    openfullpage(event) {
        this.quotefullpage = event.detail;
        this.isModalOpen = false
    }
    hidefullPageHandler() {
        this.quotefullpage = false;
        this.isModalOpen = true;
    }
    hidequotationHandler() {
        this.quotefullpage = false;
        this.isModalOpen = false;
    }

    handleTableValues(event) {
        this.quotefullpage = true;
        alert()
        this.tower = event.detail.tower;
        this.floor = event.detail.floor;

        // Log the received values
        console.log('Tower:', this.tower);
        console.log('Floor:', this.floor);
    }

    // This method is used to close the modal popup
    closeModal() {
        try {
            this.objectApiName = '';
            this.isBookingForm = false;
            this.isModalOpen = false;
            //this.handleClearFilter();
        } catch (error) {
            this.showErrorToast(ERROR_MESSAGE);
        }
    }


    handleFieldChange(event) {
        let ind = event.target.dataset.index;
        console.log('ind', ind);
        console.log('name', event.target.name);
        console.log('value', event.target.value);
        this.paymentSchedulesdata[ind][event.target.name] = event.target.value;
        console.log('current change row input', JSON.stringify(this.paymentSchedulesdata[ind]));
        
        // If Mode of Payment is changed, update the visibility flag
            if (event.target.name === 'EYI_Mode_of_Payment__c') {
                this.paymentSchedulesdata[ind].showInstrumentFields = (event.target.value === 'Cheque' || event.target.value === 'DD');
            }
        console.log('current change row input2', JSON.stringify(this.paymentSchedulesdata[ind]));
        //this.updatecalculations();
    }
    handleSubmitInv() {
        let paymentS = this.paymentSchedulesdata
        let totalAmount = 0;
        console.log('Success:', totalAmount);
        paymentS.forEach(element => {

            delete element['Id'];
            element['EYI_Opportunity__c'] = this.opptyId;
            element['EYI_Token_Amount__c'] = true;
            totalAmount += parseFloat(element.EYI_Amount__c.replace(/,/g, ''));
        });
        console.log('Success:', JSON.stringify(paymentS));

        // Call Apex method
        savePaymentSchedules({ paymentSchedules: this.paymentSchedulesdata, totalAmount })
            .then(result => {
                if (result.includes("Error saving payment schedules:")) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Payment Failed',
                            message: result,
                            variant: 'error'
                        })
                    );
                }else{
                    console.log('Success:', totalAmount);
                    //let amount  = parseFloat(totalAmount.replace(/,/g, ''))  + parseFloat(this.totalTokenAmtReceived) ;
                    this.totalTokenAmtReceived += totalAmount;
                    const fields = {};
                    let date = new Date(); // creates a Date object for February 10, 2025
                    let formattedDate = date.toISOString();
                    fields['Id'] = this.selectedOpptyId; // Replace with the actual record ID
                    //fields['EYI_Opportunity__c'] = this.selectedOpptyId;
                    console.log('Success1:', this.totalTokenAmtReceived);
                    console.log('Success2:', this.blockAmount);
                    this.paymentSchedulesdata = [];
                    if (this.totalTokenAmtReceived >= this.blockAmount) {
                        fields['StageName'] = 'Block';
                    }

                    fields['EYI_Token_Amount__c'] = this.totalTokenAmtReceived;// Replace with the actual field API name and value
                    fields['EYI_AutomationBypassDatetime__c'] = formattedDate;
                    const recordInput = { fields };
                    console.log('recordInput', JSON.stringify(recordInput));
                    //here updating opportunity and changing the color of inventory to yellow so have used this method
                    this.updateInventoryRecord(recordInput, this.totalTokenAmtReceived);

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Payment Success Message',
                            message: result,
                            variant: 'success'
                        })
                    );
                    this.isBlockInventoryModelOpen = false;
                    // Handle success message
                }
                
            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error While Inserting Record',
                        message: 'Record not updated successfully',
                        variant: 'Error'
                    })
                );
                this.isBlockInventoryModelOpen = false;
                // Handle error message
            });
    }

    updateInventoryRecord(recordInput, amount) {
        updateRecord(recordInput)
            .then(() => {
                console.log('checkBlocked');
                this.groupedData.forEach(group => {
                    group.records.forEach(record => {
                        if (record.Id === this.inventoryId && amount >= parseFloat(this.blockAmount)) {
                            console.log('checkBlocked1', record.Id);
                            console.log('checkBlocked1', parseFloat(this.blockAmount));
                            record.className = `background-color: #ffb700;`;
                            record.reservedMessage = `This unit is reserved by `+ this.oppNameOwner;
                            record.EYI_Inventory_Status__c = 'Blocked';
                            record.isReserved = false;
                            record.isBlocked = false;
                        }
                    });
                });

                this.isBlockInventoryModelOpen = false;
                notifyRecordUpdateAvailable([{ recordId: recordInput }]);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record updated successfully',
                        variant: 'success'
                    })
                );
                // const evt = new ShowToastEvent({
                //     title: 'Success',
                //     message: 'Inventory updated successfully',
                //     variant: 'success',
                // });
                // this.dispatchEvent(evt);

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record1',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


    updateOppRecord(recordInput2) {
        updateRecord(recordInput2)
            .then(() => {
                console.log('checkBlocked22');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record updated successfully',
                        variant: 'success'
                    })
                );
                // const evt = new ShowToastEvent({
                //     title: 'Success',
                //     message: 'Inventory updated successfully',
                //     variant: 'success',
                // });
                // this.dispatchEvent(evt);

            })
            .catch(error => {
                console.log('checkBlocked232');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}