import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRECProjects from '@salesforce/apex/EYI_RECAccountUtility.getRECProjects';
import getRECProjectTypology from '@salesforce/apex/EYI_RECAccountUtility.getRECProjectTypology';
import getrecaccounts from '@salesforce/apex/EYI_RECAccountUtility.getRECAccounts';
import createVpVcRecord from '@salesforce/apex/EYI_RECAccountUtility.createVPVCRecord';
import createTaskSMModel from '@salesforce/apex/EYI_RECAccountUtility.createTaskSMModel';

import createjbpRecord from '@salesforce/apex/EYI_RECAccountUtility.createjbpRecord';
import getRECProjectMappings from '@salesforce/apex/EYI_RECAccountUtility.getRECProjectMappings';
import getJointBusinessPlans from '@salesforce/apex/EYI_RECAccountUtility.getJointBusinessPlans';

import sourcingRecordType from '@salesforce/label/c.EYI_SourcingTaskRecordType';

import getBookings from '@salesforce/apex/EYI_RECAccountUtility.getBookings';
import getFilteredBookings from '@salesforce/apex/EYI_RECAccountUtility.getFilteredBookings';

import getCIFs from '@salesforce/apex/EYI_RECAccountUtility.getCIFs';
import getFilteredCIFs from '@salesforce/apex/EYI_RECAccountUtility.getFilteredCIFs';

import getTasks from '@salesforce/apex/EYI_RECAccountUtility.getTasks';
import getFilteredTasks from '@salesforce/apex/EYI_RECAccountUtility.getFilteredTasks';

import getVPVCs from '@salesforce/apex/EYI_RECAccountUtility.getVPVCs';
import getFilteredVPVCs from '@salesforce/apex/EYI_RECAccountUtility.getFilteredVPVCs';

import JBP_OBJECT from '@salesforce/schema/EYI_Joint_Business_Plan__c';
import JBP_STATUS_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EYI_Activity_Status__c';
import SUPPORT_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EYI_Activity_Support_Required__c';
import JBPTYPE_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EYI_Activity_type__c';
import JBPINTLEVEL_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EYI_REC_Interest_Level__c';
import JBPRATING_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EYI_SM_Rating__c';
import JBPRESOURCETYPE_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EYI_Type_of_Resources__c';
import JBPENDUSER_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EY_End_User__c';
import JBPCOMMUNITY_FIELD from '@salesforce/schema/EYI_Joint_Business_Plan__c.EYI_Community__c';

import VPVC_OBJECT from '@salesforce/schema/EYI_VP_VC__c';
import REC_STATUS_FIELD from '@salesforce/schema/EYI_VP_VC__c.EYI_Status__c';
import TYPOLOGY_FIELD from '@salesforce/schema/EYI_VP_VC__c.EYI_Typology_of_Project__c';
import BUDGET_FIELD from '@salesforce/schema/EYI_VP_VC__c.EYI_Budget__c';

import TASK_OBJECT from '@salesforce/schema/Task';
import EYI_MEETING_STATUS_FIELD from '@salesforce/schema/Task.EYI_Meeting_Status__c';
import EYI_MEETING_REASON_FIELD from '@salesforce/schema/Task.EYI_Reason_for_meeting__c';
import EYI_MEETING_TYPE_FIELD from '@salesforce/schema/Task.EYI_Meeting_Type__c';
import EYI_INTERESTED_FIELD from '@salesforce/schema/Task.EYI_Interested_in_Event__c';
import EYI_MEETING_LOCATION_FIELD from '@salesforce/schema/Task.EYI_Meeting_Location__c';
import EYI_CALL_TYPE_FIELD from '@salesforce/schema/Task.EYI_Call_Type__c';
import EYI_CALL_STATUS_FIELD from '@salesforce/schema/Task.EYI_Call_Status__c';
import EYI_CALL_REASON_FIELD from '@salesforce/schema/Task.EYI_Calling_Reason__c';
import EYI_CALL_DISCONNECT_FIELD from '@salesforce/schema/Task.EYI_Call_Not_Connected_Reasons__c';
import EYI_NEXT_ACTIONS_FIELD from '@salesforce/schema/Task.EYI_Next_Action_Status__c';


export default class EYI_SM_ActivityModelComponent extends LightningElement {
    @track data = [];
    @track searchKey = '';
    @track filterStatus = '';
    @track isFilterable = true;
    @track recAccounts = [];
    @track initialRECAccounts = [];
    @track isDataAvailable = true;
    @track projects = [];
    @track selectedProject = '';
    @track isprojectSelected = true;
    //pagination  variables
    @track currentPage = 1;
    @track totalPages;
    @track isFirstPage = true;
    @track isLastPage = false;
    @track displayedAccounts = [];
    @track error;

    @track totalBookings = 0;
    @track totalWalkins = 0;
    @track totalActivities = 0;
    @track totalVPVC = 0;

    @track isCall = false;
    @track isJbp = false;
    @track isActivity = false;
    @track isVpvc = false;
    @track isMeeting = false;
    @track actionName = '';
    @track budgetOptions = [];
    @track recStatusOptions = [];
    @track typologyOptions = [];
    @track allTypologyOptions = [];

    //vp vc Details
    @track clientName = '';
    @track companyName = '';
    @track designation = '';
    @track email = '';
    @track mobileNumber = '';
    @track profile = '';
    @track recCode = '';
    @track recAccount = '';
    @track recMappingId = '';
    @track recStatus = '';
    @track typology = [];
    @track budget = '';
    @track vcDate = '';
    @track vpDate = '';
    @track isVcStatus = false;
    @track isVpStatus = false;
    @track isVcDateRequired = false;
    @track fileuploaded = false;
    @track fileuploadedName = '';
    //event
    @track recName = '';
    @track projectName = '';
    //Combined fields for task
    @track sourcingRecordTypeId = sourcingRecordType;
    @track meetingTypeOptions = [];
    @track selectedMeetingType = '';
    @track meetingReasonOptions = [];
    @track selectedMeetingReason = '';
    @track meetingRemarks = '';
    @track callRemarks = '';
  
    
    @track callStatusOptions = [];
    @track selectedCallStatus = '';
    @track isCallConnect = false;
    @track meetingStatusOptions = [];
    @track selectedMeetingStatus = '';
    @track interestedOptions = [];
    @track recInterest = '';
    @track isEventMeet = false;
    @track meetingLocationOptions = [];
    @track allMeetingLocationOptions = [];
    @track meetingLocation = '';
    @track latitude = 0;
    @track longitude = 0;
    @track activityStartDate = null;
    @track activityEndDate = null;
    @track isLocationEnabled = true;
    @track locationerrormessage='';
    ////
    @track callTypeOptions = [];
    @track selectedCallType = '';
    @track callReasonOptions = [];
    @track selectedCallReason = '';
    @track callNotConnectReasonOptions = [];
    @track selectedCallNotConnnectReason = '';
    @track nextActionOptions = [];
    @track nextAction = '';
    @track isFollowup = false;
    @track nextActionDate = null;

    //Task
    @track vpvcOptions = [];
    @track taskjbpName = '';
    @track selectedVpVc = '';
    @track taskSubject = '';
    @track taskDescription = '';
    @track taskPriority = '';
    @track taskDueDate = '';
    @track docId ='';
    //JBP
    @track jbpOptions = [];
    @track jbpStatusOptions = [];
    @track jbpTypeOptions = [];
    @track actionOptions = [];
    @track jbpAType = '';
    @track supportRequired = '';
    @track isSupportRequired = false;
    @track jbpStatus = '';
    @track jbpStartDate = '';
    @track jbpEndDate = '';
    @track costValue = 0;
    @track isModalOpen = false;
    @track jbpIntLevelOptions = [];
    @track jbpRatingOptions = [];
    @track jbpResourceTypeOptions = [];
    @track jbpEndUserOptions = [];
    @track jbpCommunityOptions = [];
    @track selectedInterestLevel = '';
    @track selectedTLRating = '';
    @track selectedSMRating = '';
    @track jbpName ='';

    @track selectedResourceType = '';
    @track selectedEndUser = '';
    @track selectedCommunity = '';
    @track isJBPDatabase = false;
    @track isOnRoads = false;
    @track investorName = '';
    @track jbpOthers = '';
    @track nriData = 0;
    @track osData = 0;
    @track relevantDatabase = 0;
    @track totalDatabase = 0;
    @track corporatePrivateOrg = '';
    @track club = '';
    @track association = '';
    @track society = '';
    @track governmentOrg = '';
    @track psu = '';
    @track religiousPlace = '';
    @track inroadExpectedReach = 0;

    @track isSummaryModalOpen = false;
    @track modalContent = '';
    @track dataList = [];
    @track dataColumns = [];
    @track bookings;
    @track filteredbookings;

    @track bookingColumns = [
        { label: 'Customer Name', fieldName: 'customerName' },
        { label: 'REC Name', fieldName: 'recName' },
        { label: 'Project Name', fieldName: 'projectName' }
    ];
    @track cifForms;
    @track filteredcifForms;

    @track cifColumns = [
        { label: 'Customer Name', fieldName: 'customerName' },
        { label: 'REC Name', fieldName: 'recName' },
        { label: 'Project Name', fieldName: 'projectName' },
        { label: 'Visit Date', fieldName: 'visitDate' }
    ];

    @track tasks;
    @track filteredtasks;
    @track taskColumns = [
        { label: 'Subject', fieldName: 'taskSubject' },
        { label: 'REC Name', fieldName: 'recName' },
        // { label: 'Project Name', fieldName: 'taskProjectName' },
        { label: 'Status', fieldName: 'taskStatus' },
        { label: 'Description', fieldName: 'Description' },
        { label: 'Next Action Date', fieldName: 'nextactiondate' },
        { label: 'Created Date', fieldName: 'taskCreatedDate' }
    ];
    @track vpvcs=[];
    @track filteredvpvcs;
    @track jbps;

    @track vpvcColumns = [
        { label: 'Client Name', fieldName: 'clientName' },
        { label: 'REC Name', fieldName: 'recName' },
        { label: 'Project Name', fieldName: 'projectName' },
        { label: 'Visit Status', fieldName: 'status' },
        { label: 'Visit Proposed Date', fieldName: 'proposedDate' },
        { label: 'Visit Confirmed Date', fieldName: 'visitDate' }
    ];
    @track isLoading = true;
    @track selectedSummaryProject = ''; // Store selected project
    @track selectedDateRange = ''; // Store selected date range
    @track summaryStartDate = ''; // Store custom start date
    @track summaryEndDate = ''; // Store custom end date
    @track isCustomDateRange = false; // Flag to check if custom range is selected
    @track content = '';
    @track popupType = '';
    @track linkdinURL = '';

    // Example options for Date Range Combobox
    dateRangeOptions = [
        { label: 'Today', value: 'TODAY' },
        { label: 'Yesterday', value: 'YESTERDAY' },
        { label: 'This Week', value: 'THIS_WEEK' },
        { label: 'Last Week', value: 'LAST_WEEK' },
        { label: 'This Month', value: 'THIS_MONTH' },
        { label: 'Last Month', value: 'LAST_MONTH' },
        { label: 'Next 90 Days', value: 'NEXT_90_DAYS' },
        { label: 'Last 90 Days', value: 'LAST_90_DAYS' },
        { label: 'This Quarter', value: 'THIS_QUARTER' },
        { label: 'Last Quarter', value: 'LAST_QUARTER' },
        { label: 'Custom Range', value: 'custom' }
    ];

    @track errorMessage ='';
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg', '.docx'];
    @wire(getObjectInfo, { objectApiName: TASK_OBJECT })
    taskObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_MEETING_TYPE_FIELD })
    wiredMeetingTypePicklist({ error, data }) {
        if (data) {
            this.meetingTypeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.meetingTypeOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_CALL_TYPE_FIELD })
    wiredCallTypePicklist({ error, data }) {
        if (data) {
            this.callTypeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.meetingTypeOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_MEETING_REASON_FIELD })
    wiredMeetingReasonPicklist({ error, data }) {
        if (data) {
            this.meetingReasonOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.meetingReasonOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_CALL_REASON_FIELD })
    wiredTaskMeetingReasonPicklist({ error, data }) {
        if (data) {
            this.callReasonOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.meetingReasonOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_CALL_STATUS_FIELD })
    wiredTaskCallStatusPicklist({ error, data }) {
        if (data) {
            this.callStatusOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.meetingReasonOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_INTERESTED_FIELD })
    wiredTaskInterestedStatusPicklist({ error, data }) {
        if (data) {
            this.interestedOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('interestedOptions values:', JSON.stringify(this.interestedOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_MEETING_STATUS_FIELD })
    wiredTaskMeetingStatusPicklist({ error, data }) {
        if (data) {
            this.meetingStatusOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('interestedOptions values:', JSON.stringify(this.interestedOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_MEETING_LOCATION_FIELD })
    wiredMeetingLocationPicklist({ error, data }) {
        console.log('Picklist values event:', JSON.stringify(data));
        if (data) {
            this.meetingLocationOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            this.allMeetingLocationOptions = this.meetingLocationOptions;
            console.log('Picklist values:', JSON.stringify(this.meetingLocationOptions));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_CALL_DISCONNECT_FIELD })
    wiredNotCallReasonPicklist({ error, data }) {
        console.log('Picklist values event:', JSON.stringify(data));
        if (data) {
            this.callNotConnectReasonOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$sourcingRecordTypeId', fieldApiName: EYI_NEXT_ACTIONS_FIELD })
    wiredNextActionPicklist({ error, data }) {
        console.log('Picklist values event:', JSON.stringify(data));
        if (data) {
            this.nextActionOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values event', error);
        }
    }


    handleCallTypeChange(event){
        try {
            this.selectedCallType = event.target.value; // Assume this is an array for multiple values
        } catch (error) {
            console.error('Error in handleMeetingTypeChange:', error);
        }
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('Uploaded file Id: ' + uploadedFiles[0].documentId);
        this.docId = uploadedFiles[0].documentId;
        const fileNames = uploadedFiles.map(file => file.name).join(', ');
        this.fileuploaded = true;
        this.fileuploadedName = fileNames;
        console.log('Uploaded file: ' + this.fileuploaded);
        console.log('fileuploadedName  ' + this.fileuploadedName);

        console.log('recName',this.recAccount);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: `File(s) uploaded successfully: ${fileNames}`,
                variant: 'success',
            })
        );

        // You can also call Apex to link files to related objects if needed
    }
    handleMeetingTypeChange(event){
        try {
            this.selectedMeetingType = event.target.value; 
            console.log('this.selectedMeetingType==>',this.selectedMeetingType);
        if (this.selectedMeetingType === "Inbound Meeting") {
            this.meetingLocationOptions = this.allMeetingLocationOptions.filter(option =>
            option.label === "Project Site" || option.label === "Office Site"
            );
        } else if (this.selectedMeetingType === "Outbound Meeting") {
            this.meetingLocationOptions = this.allMeetingLocationOptions.filter(option =>
            option.label === "REC Office" || option.label === "Other"
            );
        }else{
            this.meetingLocationOptions = this.allMeetingLocationOptions;
        }

            // Assume this is an array for multiple values
        } catch (error) {
            console.error('Error in handleMeetingTypeChange:', error);
        }
    }
    handleMeetingReasonChange(event){
        try {
            this.selectedMeetingReason = event.target.value; // Assume this is an array for multiple values
            console.log('===>',this.selectedMeetingReason);
                this.isEventMeet = this.selectedMeetingReason.includes('Event');
        } catch (error) {
            console.error('Error in handleMeetingReasonChange:', error);
        }
    }
    handleCallReasonChange(event){
        try {
            this.selectedCallReason = event.target.value; // Assume this is an array for multiple values
            console.log('===>',this.selectedMeetingReason);
                this.isEventMeet = this.selectedMeetingReason.includes('Event');
        } catch (error) {
            console.error('Error in handleMeetingReasonChange:', error);
        }
    }
    
    handleCallStatusChange(event){
        try {
            this.selectedCallStatus = event.target.value; // Assume this is an array for multiple values
            this.isCallConnect = this.selectedCallStatus.includes('Not Connected');
        } catch (error) {
            console.error('Error in handleCallStatusChange:', error);
        }
    }
    handleCallNotConnectChange(event){
        try {
            this.selectedCallNotConnnectReason = event.target.value; // Assume this is an array for multiple values
        } catch (error) {
            console.error('Error in handleCallStatusChange:', error);
        }
    }
    handleCallRemarksChange(event){
        try {
            this.callRemarks = event.target.value; // Assume this is an array for multiple values
        } catch (error) {
            console.error('Error in handleMeetingReasonChange:', error);
        }
    }
    handleNextActionChange(event){
        try {
            this.nextAction = event.target.value; // Assume this is an array for multiple values
            this.isFollowup = this.nextAction.includes('Follow Up');
        } catch (error) {
            console.error('Error in handleMeetingReasonChange:', error);
        }
    }
    handlenextActionDateChange(event){
        try {
            this.nextActionDate = event.target.value; // Assume this is an array for multiple values
        } catch (error) {
            console.error('Error in handleMeetingReasonChange:', error);
        }
    }
    handleMeetingRemarksChange(event){
        try {
            this.meetingRemarks = event.target.value; // Assume this is an array for multiple values
        } catch (error) {
            console.error('Error in handleMeetingReasonChange:', error);
        }
    }
    handleMeetingLocationChange(event){
        this.meetingLocation = event.target.value;
    }

    handleJBPResourceChange(event) {
        try {
            this.selectedResourceType = event.target.value; // Assume this is an array for multiple values
            // Check if 'Database' or 'InRoads' is selected (array case)
            this.isJBPDatabase = this.selectedResourceType.includes('Database');
            this.isOnRoads = this.selectedResourceType.includes('Inroads');
        } catch (error) {
            console.error('Error in handleJBPResourceChange:', error);
        }
    }

    handleEndUserOptionChange(event) {
        try {
            this.selectedEndUser = event.target.value;
        } catch (error) {
            console.error('Error in handleDateRangeChange:', error);
        }
    }
    handleInvestorChange(event) {

        try {
            this.investorName = event.target.value;
        } catch (error) {
            console.error('Error in handleDateRangeChange:', error);
        }
    }
    handleCommunityChange(event) {

        try {
            this.selectedCommunity = event.target.value;
        } catch (error) {
            console.error('Error in handleDateRangeChange:', error);
        }
    }
    handleJBPOthersChange(event) {
        try {
            this.jbpOthers = event.target.value;
        } catch (error) {
            console.error('Error in handleDateRangeChange:', error);
        }
    }
    handleNriDataChange(event) {
        this.nriData = event.target.value;
    }
    handleJbpNameChange(event){
        this.jbpName = event.target.value;
    }
    handleOsDataChange(event) {
        this.osData = event.target.value;
    }

    handleRelevantDatabaseChange(event) {
        this.relevantDatabase = event.target.value;
    }
    handleCommunityChange(event) {
        this.selectedCommunity = event.target.value;
    }
    handleTotalDatabaseChange(event) {
        this.totalDatabase = event.target.value;
    }
    handleCorporateChange(event) {
        this.corporatePrivateOrg = event.target.value;
    }
    handleClubChange(event) {
        this.club = event.target.value;

    }
    handleAssociationChange(event) {
        this.association = event.target.value;
    }
    handleSocietyChange(event) {
        this.society = event.target.value;
    }
    handleGovOrgChange(event) {
        this.governmentOrg = event.target.value;

    }
    handlePSUChange(event) {
        this.psu = event.target.value;

    }
    handleRelPlaceChange(event) {
        this.religiousPlace = event.target.value;

    }
    handleInroadReachhange(event) {
        this.inroadExpectedReach = event.target.value;

    }
    handleJBPIntLevelChange(event){
        this.selectedInterestLevel = event.target.value;

    }
    handleSMRatingChange(event){
        this.selectedSMRating = event.target.value;

    }
    handleTLRatingChange(event){
        this.selectedTLRating = event.target.value;

    }
    handleinterestChange(event) {
        this.recInterest = event.target.value;
    }
    getCurrentLocation() {
        if (!navigator.geolocation) {
            // Geolocation is not supported
            this.showToast('Geolocation is not supported by your browser');
            return;
        }else{
            navigator.geolocation.getCurrentPosition(
                function (position) {
                    this.isLocationEnabled = true;
                    this.latitude = position.coords.latitude;
                    this.longitude = position.coords.longitude;
                    console.log('this.latitude==> ',this.latitude);
                    console.log('this.longitude==> ',this.longitude);
                    console.log("Accuracy:", position.coords.accuracy, "meters");

                }.bind(this),
                function (e) {
                    console.log('this.error ==>  ',e.message);
                    this.locationerrormessage = e.message;
                    this.isLocationEnabled = false;
                }.bind(this),
                {
                    enableHighAccuracy: true,
                }
            );
        }
    }
  
    handleMeetingStatusChange(event) {
        try {
            this.selectedMeetingStatus = event.target.value;
            console.log('this.selectedMeetingStatus==>', this.selectedMeetingStatus);
        } catch (error) {
            console.error('Error in handleDateRangeChange:', error);
        }
    }

   
    handleDateRangeChange(event) {
        try {
            this.selectedDateRange = event.target.value;
            console.log('selectedDateRange===>',this.selectedDateRange);
            if (this.selectedDateRange == 'custom') {
                this.isCustomDateRange = true;
                const { startDate, endDate } = this.getCurrentWeekDates();
                console.log('startDate===>',startDate);
                console.log('endDate===>',endDate);

                this.summaryStartDate = startDate;
                this.summaryEndDate = endDate;
            } else {
                this.isCustomDateRange = false;
            }
        } catch (error) {
            console.error('Error in handleDateRangeChange:', error);
        }
    }
    getCurrentWeekDates() {
        let today = new Date();
    
        // Get the current day of the week (0 for Sunday, 6 for Saturday)
        let currentDay = today.getDay();
    
        // Calculate the difference between today and Sunday (start of the week)
        let diffToStartOfWeek = currentDay; // Adjust if Sunday is not your start day
        let diffToEndOfWeek = 6 - currentDay; // Saturday is the end of the week
    
        // Set the current week start (Sunday) and end (Saturday)
        let startOfWeek = new Date(today);
        startOfWeek.setDate(today.getDate() - diffToStartOfWeek);
        startOfWeek.setHours(0, 0, 0, 0); // Set to 00:00:00 of the start date
    
        let endOfWeek = new Date(today);
        endOfWeek.setDate(today.getDate() + diffToEndOfWeek);
        endOfWeek.setHours(23, 59, 59, 999); // Set to 23:59:59 of the end date
    
        // Convert to YYYY-MM-DD format
        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0'); // Add leading zero
            const day = String(date.getDate()).padStart(2, '0'); // Add leading zero
            return `${year}-${month}-${day}`;
        };
    
        return {
            startDate: formatDate(startOfWeek),
            endDate: formatDate(endOfWeek)
        };
    }
    
    
    handleSummaryStartDate(event) {
        try {
            const dateValue = event.target.value;
            if (dateValue) {
                // Convert the date to a DateTime string in ISO 8601 format
                const dateTimeValue = new Date(dateValue).toISOString();
                this.summaryStartDate = dateTimeValue;
            } else {
                this.summaryStartDate = null;
            }
        } catch (error) {
            console.error('Error in handleSummaryStartDate:', error);
        }
    }

    handleActivityStartDate(event) {
        try {
            const selectedDate = event.target.value;
            const today = new Date();
            const selectedDateObj = new Date(selectedDate);

            // Remove time from both dates for fair comparison
            today.setHours(0, 0, 0, 0);
            selectedDateObj.setHours(0, 0, 0, 0);

            if (selectedDateObj <= today) {
                this.errorMessage = 'The start date must be after today.';
                alert(this.errorMessage);
                this.activityStartDate = null;
            } else {
                this.activityStartDate = selectedDate;
                this.errorMessage = '';
            }
        } catch (error) {
            this.errorMessage = 'Invalid start date.';
        }
    }

    handleActivityEndDate(event) {
        try {
            const selectedEndDate = event.target.value;
            const endDateObj = new Date(selectedEndDate);

            if (!this.activityStartDate) {
                this.errorMessage = 'Please select the start date first.';
                alert(this.errorMessage);
                this.activityEndDate = null;
                return;
            }

            const startDateObj = new Date(this.activityStartDate);

            // Remove time parts
            endDateObj.setHours(0, 0, 0, 0);
            startDateObj.setHours(0, 0, 0, 0);

            if (endDateObj <= startDateObj) {
                this.errorMessage = 'The end date must be after the start date.';
                alert(this.errorMessage);
                this.activityEndDate = null;
            } else {
                this.activityEndDate = selectedEndDate;
                this.errorMessage = '';
            }
        } catch (error) {
            this.errorMessage = 'Invalid end date.';
        }
    }
    
    handleSummaryEndDate(event) {
        try {
            const dateValue = event.target.value;
            if (dateValue) {
                // Convert the date to a DateTime string in ISO 8601 format
                const dateTimeValue = new Date(dateValue).toISOString();
                this.summaryEndDate = dateTimeValue;
            } else {
                this.summaryStartDate = null;
            }
        } catch (error) {
            console.error('Error in handleSummaryEndDate:', error);
        }
    }

    handlelinkdinURLChange(event) {
        try {
            this.linkdinURL = event.target.value;
        } catch (error) {
            console.error('Error in handleSummaryProjectChange:', error);
        }
    }
    handleSummaryProjectChange(event) {
        try {
            this.selectedSummaryProject = event.target.value;
        } catch (error) {
            console.error('Error in handleSummaryProjectChange:', error);
        }
    }

    handleApplyFilters() {
        console.log('project:', this.selectedSummaryProject);
        console.log('dateRange:', this.selectedDateRange);
        console.log('startDate:', this.summaryStartDate);
        console.log('endDate:', this.summaryEndDate);

        try {
            if (this.popupType == 'bookings') {
                getFilteredBookings({
                    project: this.selectedSummaryProject,
                    dateRange: this.selectedDateRange,
                    startDate: this.summaryStartDate || null,
                    endDate: this.summaryEndDate || null
                })
                    .then(result => {
                        this.filteredbookings = result;
                        this.dataList = this.filteredbookings;
                        console.log('Bookings:', JSON.stringify(this.bookings));
                    })
            } else if (this.popupType == 'walkins') {
                getFilteredCIFs({
                    project: this.selectedSummaryProject,
                    dateRange: this.selectedDateRange,
                    startDate: this.summaryStartDate || null,
                    endDate: this.summaryEndDate || null
                })
                    .then(result => {
                        this.filteredcifForms = result;
                        this.dataList = this.filteredcifForms;
                        console.log('cifForms:', JSON.stringify(this.cifForms));
                    })
            } else if (this.popupType == 'activities') {
                getFilteredTasks({
                    project: this.selectedSummaryProject,
                    dateRange: this.selectedDateRange,
                    startDate: this.summaryStartDate || null,
                    endDate: this.summaryEndDate || null,
                    recId : this.searchKey 
                })
                    .then(result => {
                        this.filteredtasks = result;
                        this.dataList = this.filteredtasks;
                        console.log('tasks:', JSON.stringify(this.tasks));
                    })
            } else if (this.popupType == 'vpvc') {
                getFilteredVPVCs({
                    project: this.selectedSummaryProject,
                    dateRange: this.selectedDateRange,
                    startDate: this.summaryStartDate || null,
                    endDate: this.summaryEndDate || null
                })
                    .then(result => {
                        this.filteredvpvcs = result;
                        this.dataList = this.filteredvpvcs;
                        console.log('vpvcs:', JSON.stringify(this.vpvcs));
                    })
            }
        } catch (error) {
            console.error('Error in handleApplyFilters:', error);
        }
    }
    handleClearFilters() {
        this.summaryStartDate = null;
        this.summaryEndDate = null;
        this.selectedSummaryProject = '';
        this.selectedDateRange = '';

        if (this.popupType == 'bookings') {
            this.dataList = this.bookings;
            console.log('bookings',JSON.stringify(this.bookings));
        } else if (this.popupType == 'walkins') {
            this.dataList = this.cifForms;
            console.log('cifForms',JSON.stringify(this.cifForms));

        } else if (this.popupType == 'activities') {
            this.dataList = this.tasks;
            console.log('cifForms',JSON.stringify(this.tasks));

        } else if (this.popupType == 'vpvc') {
            this.dataList = this.vpvcs;
            console.log('cifForms',JSON.stringify(this.vpvcs));

        }

    }
    handleItemClick(event) {
        try {
            this.popupType = event.currentTarget.dataset.popup;

            switch (this.popupType) {
                case 'bookings':
                    this.content = 'Booking ';
                    this.dataColumns = this.bookingColumns;
                    this.dataList = this.bookings;
                    break;
                case 'walkins':
                    this.content = 'Walk-in ';
                    this.dataColumns = this.cifColumns;
                    this.dataList = this.cifForms;
                    break;
                case 'activities':
                    this.content = 'Activity ';
                    this.dataColumns = this.taskColumns;
                    this.dataList = this.tasks;
                    break;
                case 'vpvc':
                    this.content = 'VP/VC ';
                    this.dataColumns = this.vpvcColumns;
                    this.dataList = this.vpvcs;
                    break;
                default:
                    this.content = '';
            }
            this.isSummaryModalOpen = true;
        } catch (error) {
            console.error('Error in handleApplyFilters:', error);
        }
    }

    closeSummaryModal() {
        try {
            this.isSummaryModalOpen = false;
            this.content = '';
            this.searchKey ='';
            this.dataColumns = [];
            this.dataList = [];
            this.recName = '';
            this.isCustomDateRange = false;
            this.selectedSummaryProject ='';
            this.selectedDateRange = '';
            this.summaryStartDate = null;
            this.summaryEndDate = null;
            this.searchKey = '';
        } catch (error) {
            console.error('Error in handleApplyFilters:', error);
        }
    }


    formatDateToISO(date) {
        if (!date) return null;
        return date.toISOString();
    }

    @wire(getBookings)
    wiredBookings({ error, data }) {
        if (data) {
            console.log('Bookings===>', JSON.stringify(data));
            this.bookings = data;
        } else if (error) {
            this.bookings = undefined;
            console.error('Error retrieving bookings:', error);
        }
    }
    @wire(getCIFs)
    wiredCustomers({ error, data }) {
        if (data) {
            this.cifForms = data;
        } else if (error) {
            this.cifForms = undefined;
            console.error('Error retrieving customers:', error);
        }
    }
    @wire(getTasks)
    wiredTasks({ error, data }) {
        if (data) {
            this.tasks = data;
        } else if (error) {
            this.tasks = undefined;
            console.error('Error retrieving tasks:', error);
        }
    }
    fetchVPVCs() {
        getVPVCs()
            .then(data => {
                console.log('this.vpvcs data===>', JSON.stringify(data));
                this.vpvcs = data;
                this.vpvcOptions = this.vpvcs.map(vpvc => ({
                    label: vpvc.vpvcName,
                    value: vpvc.Id
                }));
                console.log('1111this.vpvcs===>', JSON.stringify(this.vpvcs));
            })
            .catch(error => {
                this.vpvcs = [];
                this.error = error;
                console.error('Error retrieving VP/VCs:', error);
            });
    }

    @wire(getJointBusinessPlans)
    wiredJBPs({ error, data }) {
        if (data) {
            this.jbps = data;
            this.jbpOptions = this.jbps.map(jbp => ({
                label: `${jbp.Name} : ${jbp.EYI_JBP_Name__c}`,
                value: jbp.Id
            }));
        } else if (error) {
            this.jbps = undefined;
            console.error('Error retrieving VP/VCs:', error);
        }
    }

    @wire(getRECProjects)
    wiredProjects({ error, data }) {
        if (data) {
            this.projects = data.map(project => {
                return { label: project.Name, value: project.Id };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.projects = [];
        }
    }

    @wire(getrecaccounts)
    wiredRECAccount({ error, data }) {
        if (data) {
            // Remove duplicates based on recCode
            this.initialRECAccounts = data;
            this.recAccounts = data; 
            console.log('this.recAccounts==>', JSON.stringify(this.recAccounts));
            // Update the total pages for pagination
            this.totalPages = Math.ceil(this.recAccounts.length / this.pageSize);
            this.updatePage();
            this.calculateTotals();
        } else if (error) {
            this.error = error;
            this.recAccounts = [];
        }
    }

    @wire(getObjectInfo, { objectApiName: VPVC_OBJECT })
    vpVCObjectInfo;

    @wire(getObjectInfo, { objectApiName: JBP_OBJECT })
    jbpObjectInfo;
      

    @wire(getPicklistValues, { recordTypeId: '$vpVCObjectInfo.data.defaultRecordTypeId', fieldApiName: REC_STATUS_FIELD })
    wiredRecStatusPicklist({ error, data }) {
        console.log('Picklist values:', JSON.stringify(data));
        if (data) {
            this.recStatusOptions = data.values
            .filter(item => item.value =="Visit Confirmed" || item.value == "Visit Proposed")
            .map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.recStatusOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$vpVCObjectInfo.data.defaultRecordTypeId', fieldApiName: BUDGET_FIELD })
    wiredBudgetPicklist({ error, data }) {
        console.log('Picklist values:', JSON.stringify(data));
        if (data) {
            this.budgetOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.budgetOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    handleBudgetChange(event) {
        try {
            this.budget = event.target.value;
        } catch (error) {
            console.error('Error in handleTypologyChange:', error);
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '$vpVCObjectInfo.data.defaultRecordTypeId', fieldApiName: TYPOLOGY_FIELD })
    wiredTypologyPicklist({ error, data }) {
        console.log('Picklist values:', JSON.stringify(data));
        if (data) {
            this.typologyOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            this.allTypologyOptions = this.typologyOptions; 
            console.log('Picklist values:', JSON.stringify(this.typologyOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: JBP_STATUS_FIELD })
    wiredJBPStatusPicklist({ error, data }) {
        console.log('Picklist values:', JSON.stringify(data));
        if (data) {
            this.jbpStatusOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            this.jbpStatus = 'Planned';
            console.log('Picklist values:', JSON.stringify(this.recStatusOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: JBPTYPE_FIELD })
    wiredjbpTypePicklist({ error, data }) {
        console.log('Picklist values:', JSON.stringify(data));
        if (data) {
            this.jbpTypeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.typologyOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: SUPPORT_FIELD })
    wiredactionTypePicklist({ error, data }) {
        console.log('Picklist values:', JSON.stringify(data));
        if (data) {
            this.actionOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Picklist values:', JSON.stringify(this.typologyOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: JBPINTLEVEL_FIELD })
    wiredJbpIntLevelPicklist({ error, data }) {
        if (data) {
            this.jbpIntLevelOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error retrieving Interest Level picklist values', error);
        }
    }

    // Fetch picklist values for the EYI_SM_Rating__c field
    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: JBPRATING_FIELD })
    wiredJbpRatingPicklist({ error, data }) {
        if (data) {
            this.jbpRatingOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error retrieving Rating picklist values', error);
        }
    }

    // Fetch picklist values for the EYI_Type_of_Resources__c field
    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: JBPRESOURCETYPE_FIELD })
    wiredJbpResourceTypePicklist({ error, data }) {
        if (data) {
            this.jbpResourceTypeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error retrieving Resource Type picklist values', error);
        }
    }

    // Fetch picklist values for the EY_End_User__c field
    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: JBPENDUSER_FIELD })
    wiredJbpEndUserPicklist({ error, data }) {
        if (data) {
            this.jbpEndUserOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error retrieving End User picklist values', error);
        }
    }

    // Fetch picklist values for the EYI_Community__c field
    @wire(getPicklistValues, { recordTypeId: '$jbpObjectInfo.data.defaultRecordTypeId', fieldApiName: JBPCOMMUNITY_FIELD })
    wiredJbpCommunityPicklist({ error, data }) {
        if (data) {
            this.jbpCommunityOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error retrieving Community picklist values', error);
        }
    }

    // Pagination Start
    get pageSize() {
        return 5; // Adjust the page size as needed
    }
    get recOptions() {
        return this.recAccounts.map(item => ({
            label: item.recName,
            value: item.recId
        }));
    }
    updatePage() {
        let filteredAccounts = [];
        console.log('In this.selectedProjectId ===>', this.selectedProject);
        console.log('In this.searchKey ===>', this.searchKey);
        if (this.selectedProject != '' && this.searchKey != '') {
            filteredAccounts = this.recAccounts.filter(account =>
                (account.recProjectId || '').toLowerCase().includes((this.selectedProject || '').toLowerCase())
                && (
                    (account.recCode || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                    (account.recMobile || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                    (account.recProjLifetimeCat || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                    (account.recProjCurrentCat || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                    (account.recName || '').toLowerCase().includes((this.searchKey || '').toLowerCase())
                )
            );
        } else if (this.searchKey != '') {
            filteredAccounts = this.recAccounts.filter(account =>
                (account.recCode || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                (account.recMobile || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                (account.recLifetimeCategory || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                (account.recCurrentCategory || '').toLowerCase().includes((this.searchKey || '').toLowerCase()) ||
                (account.recName || '').toLowerCase().includes((this.searchKey || '').toLowerCase())
            );
        } else {
            filteredAccounts = this.recAccounts;
        }


        const start = (this.currentPage - 1) * this.pageSize;
        const end = this.currentPage * this.pageSize;
        this.displayedAccounts = filteredAccounts.slice(start, end);
        this.totalPages = Math.ceil(filteredAccounts.length / this.pageSize);
        this.isFirstPage = this.currentPage === 1;
        this.isLastPage = this.currentPage === this.totalPages;
        this.isDataAvailable = this.displayedAccounts.length > 0 ? true : false;
        this.isLoading = false;

    }
    calculateTotals() {
        this.totalBookings = 0;
        this.totalWalkins = 0;
        this.totalActivities = 0;
        this.totalVPVC = 0;
    
            this.recAccounts.forEach(account => {
                console.log('account.recActivities ==> ', account.recActivities);
                if (account.recBookings > 0) {
                    this.totalBookings += account.recBookings;
                }
                if (account.recWalkins > 0) {
                    this.totalWalkins += account.recWalkins;
                }
                if (account.recActivities > 0) {
                    this.totalActivities += account.recActivities;
                }
                if (account.recSitevisits > 0) {
                    this.totalVPVC += account.recSitevisits;
                }
            });
       
    
        console.log('Total Bookings: ', this.totalBookings);
        console.log('Total Walkins: ', this.totalWalkins);
        console.log('Total Activities: ', this.totalActivities);
        console.log('Total VPVC: ', this.totalVPVC);
    }
    // Pagination start

    handleFirstPage() {
        try {
            this.currentPage = 1;
            this.updatePage();
        } catch (error) {
            console.error('Error in handleFirstPage:', error);
        }
    }

    handlePrevious() {
        try {
            if (this.currentPage > 1) {
                this.currentPage -= 1;
                this.updatePage();
            }
        } catch (error) {
            console.error('Error in handlePrevious:', error);
        }
    }

    handleNext() {
        try {
            if (this.currentPage < this.totalPages) {
                this.currentPage += 1;
                this.updatePage();
            }
        } catch (error) {
            console.error('Error in handleNext:', error);
        }
    }

    handleLastPage() {
        try {
            this.currentPage = this.totalPages;
            this.updatePage();
        } catch (error) {
            console.error('Error in handleLastPage:', error);
        }
    }
    // Pagination End

    handleProjectChange(event) {
        try {
            this.isLoading = true;
            this.selectedProject = event.target.value;
            const selectedOption = this.projects.find(option => option.value === this.selectedProject);
            if (selectedOption) {
                this.projectName = selectedOption.label;
            }
            if(this.selectedProject){
                this.getRECProjectTypology();
            }  
            // this.projectName = event.target.label;
            console.log('this.selectedProject ===>', this.selectedProject);
            console.log('this.selectedProject ===>', this.projectName);

            this.isprojectSelected = false;
            this.fetchRECProjectMappings();
            // Handle filter change logic here
        } catch (error) {
            console.error('Error in handleProjectChange:', error);
        } finally {
            this.isLoading = false;
        }
    }

    fetchRECProjectMappings() {
        getRECProjectMappings({ projectId: this.selectedProject })
            .then(result => {
                this.recAccounts = result;
                console.log('this.recAccounts==>', JSON.stringify(this.recAccounts));
                // Update the total pages for pagination
                this.totalPages = Math.ceil(this.recAccounts.length / this.pageSize);
                this.updatePage();
                this.calculateTotals();
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.recAccountWrappers = undefined;
            });
    }
    getRECProjectTypology() {
    getRECProjectTypology({ projectId: this.selectedProject })
        .then(result => {
            console.log('result===>', JSON.stringify(result));

            if (result && result.EYI_Configuration_Types__c) {
               const values = result.EYI_Configuration_Types__c
                    .split(';')
                    .filter((item, index, self) => item && self.indexOf(item) === index); // removes duplicates

                this.typology = values; // ✅ set all values

                //this.typology = values.slice(0, 2); // Or use full list if needed
                this.typologyOptions = values.map(item => ({
                    label: item,
                    value: item
                }));
            } else {
                this.typologyOptions = this.allTypologyOptions || [];
                this.typology = [];
            }

            console.log('this.typology===>', this.typology);
            console.log('this.typologyOptions===>', this.typologyOptions);
        })
        .catch(error => {
            console.error('Error fetching typology:', error);
            this.error = error;
        });
    }

    handleSearchKeyChange(event) {
        try {
            this.searchKey = event.target.value;
        } catch (error) {
            console.error('Error in handleSearchKeyChange:', error);
        }
    }

    handleSearch() {
        try {
            this.isLoading = true;
            this.currentPage = 1; // Reset to first page on search
            this.updatePage();
        } catch (error) {
            let errorMsg = 'Unknown error occurred';

            if (error instanceof TypeError) {
                // Likely something like calling .toLowerCase() on undefined
                errorMsg = `TypeError: ${error.message}`;
            } else if (error.message) {
                errorMsg = error.message;
            } else {
                errorMsg = JSON.stringify(error);
            }
            console.error('Root Cause of Search Error:', errorMsg);
        } finally {
            this.isLoading = false;
        }
    }

    handleRefresh() {
        try {
            this.searchKey = '';
            this.selectedProject = '';
            this.isprojectSelected = true;
            this.recAccounts = this.initialRECAccounts;
            this.calculateTotals();
            console.log('this.initialRECAccounts==>', JSON.stringify(this.initialRECAccounts));
            console.log('this.recAccounts==>', JSON.stringify(this.recAccounts));
            this.updatePage();
        } catch (error) {
            console.error('Error in handleRefresh:', error);
        }
    }

    handleMeeting(event) {
        try {
            this.getCurrentLocation();
            this.actionName = 'Meeting';
            const accountName = event.currentTarget.getAttribute('data-id');
            const mappingId = event.currentTarget.dataset.mappingid;
            const reNames = event.currentTarget.dataset.recname;
            this.recName = reNames;
            console.log('Call button clicked for this.recName:', this.recName);
            this.recMappingId = mappingId;
            console.log('Call button clicked for recId:', accountName, 'and mappingId:', mappingId);
            this.isMeeting = true;
            this.isJbp = false;
            this.isActivity = false;
            this.isVpvc = false;
            this.isCall = false;
            this.isModalOpen = true;
            this.recAccount = accountName;
        } catch (error) {
            console.error('Error in handleMeeting:', error);
        }
    }

    showToast(title, message, variant) {
        try {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(event);
        } catch (error) {
            console.error('Error in showToast:', error);
        }
    }

    handleCall(event) {
        // isCall
        try {
            const recAccId = event.currentTarget.getAttribute('data-id');
            this.recAccount = recAccId;
            const mappingId = event.currentTarget.dataset.mappingid;
            this.recMappingId = mappingId;
            const reNames = event.currentTarget.dataset.recname;
            this.recName = reNames;
            this.actionName = 'Call';
            this.isMeeting = false;
            this.isJbp = false;
            this.isActivity = false;
            this.isVpvc = false;
            this.isCall = true;
            this.isModalOpen = true;
        } catch (error) {
            console.error('Error in showToast:', error);
        }
    }

    closeModal() {
        try {
            this.isModalOpen = false;
            this.isLocationEnabled = false;
            this.locationerrormessage = '';
            this.getCurrentLocation();
        } catch (error) {
            console.error('Error in showToast:', error);
        }
    }

    connectedCallback() {
        this.fetchVPVCs();
        const today = new Date();
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        const year = today.getFullYear();

        // Format the date as yyyy-mm-dd
        this.taskDueDate = `${year}-${month}-${day}`;
    }

    handleJbp(event) {
        try {
            this.isModalOpen = true;
            this.actionName = 'JBP';
            this.isJbp = true;
            const recAccId = event.currentTarget.getAttribute('data-id');
            const mappingId = event.currentTarget.dataset.mappingid;
            this.recMappingId = mappingId;
            this.recAccount = recAccId;
            const reNames = event.currentTarget.dataset.recname;
            this.recName = reNames;
            this.isActivity = false;
            this.isVpvc = false;
            this.isMeeting = false;
            this.isCall= false;
        } catch (error) {
            console.error('Error in showToast:', error);
        }
    }
    handleJbpActivityType(event) {
        try {
            this.jbpAType = event.target.value;
        } catch (error) {
            console.error('Error in handleJbpActivityType:', error);
        }
    }

    handleJbpActionRequired(event) {
        try {
            this.supportRequired = event.target.value;
            if(this.supportRequired=='Yes'){
                this.isSupportRequired = true;
            }
            else{
                this.isSupportRequired = false;
            }
        } catch (error) {
            console.error('Error in handleJbpActionRequired:', error);
        }
    }

    handleJBPStatusChange(event) {
        try {
            this.jbpStatus = event.target.value;
        } catch (error) {
            console.error('Error in handleJBPStatusChange:', error);
        }
    }

    // handleJBPStartDate(event) {
    //     try {
    //         this.jbpStartDate = event.target.value;
    //     } catch (error) {
    //         console.error('Error in handleJBPStartDate:', error);
    //     }
    // }
    handleJBPStartDate(event) {
        try {
            const selectedDate = event.target.value; // This is a string in YYYY-MM-DD format
            const today = new Date();
            // Format today's date to YYYY-MM-DD
            const todayString = today.getFullYear() + '-' 
                                + String(today.getMonth() + 1).padStart(2, '0') + '-' 
                                + String(today.getDate()).padStart(2, '0');
            console.log('selectedDate:', selectedDate);
            console.log('todayString:', todayString);
            // Compare the selected date with today's date
            if (selectedDate < todayString) {
                this.errorMessage = 'The start date must be greater than today.';
                alert('The start date must be greater than today.');
                this.jbpStartDate =null;
            } else {
                this.jbpStartDate = selectedDate;
                this.errorMessage = ''; // Clear the error if the date is valid
            }
        } catch (error) {
            console.error('Error in handleJBPStartDate:', error);
            this.errorMessage = 'Invalid date format.';
        }
    }
    

    // handleJBPEndDate(event) {
    //     try {
    //         this.jbpEndDate = event.target.value;
    //     } catch (error) {
    //         console.error('Error in handleJBPEndDate:', error);
    //     }
    // }
    handleJBPEndDate(event) {
        try {
            const selectedEndDate = event.target.value; // This is the end date string in YYYY-MM-DD format
            const startDate = this.jbpStartDate; // Get the start date from the component's state
    
            if (!startDate) {
                console.error('Start date is not set');
                this.errorMessage = 'Please select a valid start date first.';
                return;
            }
    
            // Compare end date with start date
            if (selectedEndDate <= startDate) {
                this.errorMessage = 'The end date must be greater than the start date.';
                alert('The end date must be greater than the start date.');
                this.jbpEndDate =null;
            } else {
                this.jbpEndDate = selectedEndDate;
                this.errorMessage = ''; // Clear the error if the end date is valid
            }
        } catch (error) {
            console.error('Error in handleJBPEndDate:', error);
            this.errorMessage = 'Invalid date format.';
        }
    }
    
    handleCostChange(event) {
        try {
            this.costValue = event.target.value;
            console.log('costValue:', this.costValue);
        } catch (error) {
            console.error('Error in handleJBPEndDate:', error);
        }
    }

    handleActivity(event) {
        try {
            this.isJbp = false;
            this.isActivity = true;
            this.actionName = 'Activity';
            this.isMeeting = false;
            this.isVpvc = false;
            this.isCall = false;
            const mappingId = event.currentTarget.dataset.mappingid;
            this.recMappingId = mappingId;
            const reNames = event.currentTarget.dataset.recname;
            this.recName = reNames;

            const recAccId = event.currentTarget.getAttribute('data-id');
            this.recAccount = recAccId;
            this.isModalOpen = true;
        } catch (error) {
            console.error('Error in handleActivity:', error);
        }
    }

    handleTaskSubject(event) {
        try {
            this.taskSubject = event.target.value;
        } catch (error) {
            console.error('Error in handleTaskSubject:', error);
        }
    }

    handleTaskDescription(event) {
        try {
            this.taskDescription = event.target.value;
        } catch (error) {
            console.error('Error in handleTaskDescription:', error);
        }
    }

    handlePriority(event) {
        try {
            this.taskPriority = event.target.value;
        } catch (error) {
            console.error('Error in handlePriority:', error);
        }
    }

    handleDueDate(event) {
        try {
            this.taskDueDate = event.target.value;
        } catch (error) {
            console.error('Error in handleDueDate:', error);
        }
    }

    handleVcvp(event) {
        try {
            this.isJbp = false;
            this.isActivity = false;
            this.actionName = 'VP/VC';
            this.isVpvc = true;
            this.isCall = false;
            this.isMeeting = false;
            this.isModalOpen = true;
            const mappingId = event.currentTarget.dataset.mappingid;
            this.recMappingId = mappingId;
            const reNames = event.currentTarget.dataset.recname;
            this.recName = reNames;
            const recCode = event.currentTarget.getAttribute('data-reccode');
            this.recCode = recCode;
            const recAccId = event.currentTarget.getAttribute('data-id');
            this.recAccount = recAccId;
        } catch (error) {
            console.error('Error in handleVcvp:', error);
        }
    }

    handleClientNameChange(event) {
        try {
            this.clientName = event.target.value;
        } catch (error) {
            console.error('Error in handleClientNameChange:', error);
        }
    }

    handleCompanyNameChange(event) {
        try {
            this.companyName = event.target.value;
        } catch (error) {
            console.error('Error in handleCompanyNameChange:', error);
        }
    }

    handleDesignationChange(event) {
        try {
            this.designation = event.target.value;
        } catch (error) {
            console.error('Error in handleDesignationChange:', error);
        }
    }

    handleEmailChange(event) {
        try {
            this.email = event.target.value;
        } catch (error) {
            console.error('Error in handleEmailChange:', error);
        }
    }

    handleRecStatusChange(event) {
        try {
            this.recStatus = event.target.value;
            if (this.recStatus == 'Visit Proposed') {
                this.isVpStatus = true;
                this.isVcStatus = false;
            } else if (this.recStatus == 'Visit Confirmed') {
                this.isVpStatus = false;
                this.isVcStatus = true;
            } else {
                this.isVpStatus = false;;
                this.isVcStatus = false;
            }
        } catch (error) {
            console.error('Error in handleRecStatusChange:', error);
        }
    }

    handleMobileNumberChange(event) {
        try {
            this.mobileNumber = event.target.value;
        } catch (error) {
            console.error('Error in handleMobileNumberChange:', error);
        }
    }

    handleVcDateChange(event) {
        try {
            const selectedVcDate = event.target.value; // This is the datetime-local value (YYYY-MM-DDTHH:MM)
            const today = new Date();
            
            // Get today's date in YYYY-MM-DD format
            const todayString = today.getFullYear() + '-' 
                                + String(today.getMonth() + 1).padStart(2, '0') + '-' 
                                + String(today.getDate()).padStart(2, '0');
            
            // Extract only the date part from the selected date
            const selectedDate = selectedVcDate.split('T')[0];
    
            console.log('selectedVcDate:', selectedVcDate);
            console.log('todayString:', todayString);
    
            // Compare the selected date with today's date (only the date part)
            if (selectedDate < todayString) {
                alert('The VC date must be greater than or equal to today.');
                this.vcDate = null; // Reset the VC date if invalid
            } else {
                this.vcDate = selectedVcDate;
                this.errorMessage = ''; // Clear the error if the VC date is valid
            }
        } catch (error) {
            console.error('Error in handleVcDateChange:', error);
            this.errorMessage = 'Invalid date format.';
        }
    }
    
    handleVpDateChange(event) {
        try {
            const selectedVpDate = event.target.value; // This is the datetime-local value (YYYY-MM-DDTHH:MM)
            const today = new Date();
            
            // Get today's date in YYYY-MM-DD format
            const todayString = today.getFullYear() + '-' 
                                + String(today.getMonth() + 1).padStart(2, '0') + '-' 
                                + String(today.getDate()).padStart(2, '0');
            
            // Extract only the date part from the selected date
            const selectedDate = selectedVpDate.split('T')[0];
    
            console.log('selectedVpDate:', selectedVpDate);
            console.log('todayString:', todayString);
    
            // Compare the selected date with today's date (only the date part)
            if (selectedDate < todayString) {
                alert('The VP date must be greater than or equal to today.');
                this.vpDate = null; // Reset the VP date if invalid
            } else {
                this.vpDate = selectedVpDate;
                this.errorMessage = ''; // Clear the error if the VP date is valid
            }
        } catch (error) {
            console.error('Error in handleVpDateChange:', error);
            this.errorMessage = 'Invalid date format.';
        }
    }
    
    handleProfileChange(event) {
        try {
            this.profile = event.target.value;
        } catch (error) {
            console.error('Error in handleProfileChange:', error);
        }
    }

    handleRecCodeChange(event) {
        try {
            this.recCode = event.target.value;
        } catch (error) {
            console.error('Error in handleRecCodeChange:', error);
        }
    }

    handleRecAccountChange(event) {
        try {
            this.recAccount = event.target.value;
        } catch (error) {
            console.error('Error in handleRecAccountChange:', error);
        }
    }

    handleTypologyChange(event) {
        try {
            this.typology = event.target.value;
        } catch (error) {
            console.error('Error in handleTypologyChange:', error);
        }
    }
    handleSaveAndNew(){
        if (this.taskSubject == '') {
                    this.showToast('Error', 'Please enter Activity Name', 'error');
                    return;
                }else if (this.taskDescription == '') {
                    this.showToast('Error', 'Please enter Activity Remarks', 'error');
                    return;
                }else if (new Date(this.activityEndDate) <= new Date(this.activityStartDate)) {
                    this.showToast('Error', 'Activity End Date must be after Activity Start Date', 'error');
                    return;
                }
        const jsonInputString = {
            taskSubject: this.taskSubject || '',
            taskDescription: this.taskDescription || '', 
            activityType : this.selectedMeetingType || '',
            recAccount: this.recAccount || '',
            taskJBP: this.taskjbpName || '',
            recMapping: this.recMappingId || '',
            projectName: this.selectedProject || '',
            activityStartDate: this.activityStartDate || null,
            activityEndDate: this.activityEndDate || null
        };
        console.log('jsonInputString==>', JSON.stringify(jsonInputString));
        createTaskSMModel({ jsonInput: JSON.stringify(jsonInputString) })
            .then(result => {
                // Handle success
                this.showToast('Success', 'Activity Record created successfully!', 'success');
                console.log(result); // Handle response from Apex
            })
            .catch(error => {
                // Handle error
                this.showToast('Error', error.body.message, 'error');
                console.error(error); // Handle error response
            });
            this.taskSubject = '';
            this.taskDescription = '';
            this.taskjbpName || '';
            this.activityStartDate = null;
            this.activityEndDate = null;
            this.selectedMeetingType = '';
    }
    handleSave() {
        try {
                if (this.isCall) {
                    if(this.selectedCallType == '') {
                        this.showToast('Error', 'Please enter Call Type', 'error');
                        return;
                    }if(this.callRemarks == '') {
                        this.showToast('Error', 'Please enter Call Remarks', 'error');
                        return;
                    }else if (this.selectedCallReason == '') {
                        this.showToast('Error', 'Please enter Call Reason', 'error');
                        return;
                    }else if (this.selectedCallStatus == '') {
                        this.showToast('Error', 'Please enter Call Status', 'error');
                        return;
                    } else if(this.isCallConnect && this.selectedCallNotConnnectReason == ''){
                        this.showToast('Error', 'Please enter Call Not Connected Reason', 'error');
                        return;
                    }else if(this.isFollowup && this.nextActionDate == null){
                        this.showToast('Error', 'Please enter Next Action Date', 'error');
                        return;
                    }else if (this.isFollowup && new Date(this.nextActionDate) <= new Date()) {
                        this.showToast('Error', 'Next Action Date must be a future date', 'error');
                        return;
                    }
                    const jsonInputString = {
                        taskSubject: 'Call with ' + this.recName,
                        taskCallType: this.selectedCallType || '',
                        taskCallReason: this.selectedCallReason || '',
                        taskCallStatus: this.selectedCallStatus || '',
                        callRemarks: this.callRemarks || '',
                        recAccount: this.recAccount || '',
                        recMapping: this.recMappingId || '',
                        projectName: this.selectedProject || '',
                        nextAction: this.nextAction || '',
                        nextActionDateTime: this.nextActionDate || null,
                        taskNotConnectReason: this.selectedCallNotConnnectReason || '',
                        recName: this.recName
                    };
                    console.log('result==>',JSON.stringify(jsonInputString));
                    createTaskSMModel({ jsonInput: JSON.stringify(jsonInputString) })
                    .then(result => {
                        // Handle success
                        this.showToast('Success', 'Call Record created successfully!', 'success');
                        console.log(result); // Handle response from Apex
                    })
                    .catch(error => {
                        // Handle error
                        this.showToast('Error', error.body.message, 'error');
                        console.error(error); // Handle error response
                    });
                    this.isModalOpen = false;
                this.clearTaskVariables();
                } else if (this.isVpvc) {
                if (this.clientName == '') {
                    this.showToast('Error', 'Please enter Client Name', 'error');
                    return;
                }else if (this.recStatus == '') {
                    this.showToast('Error', 'Please select Visit Status', 'error');
                    return;
                // }else if (this.recStatus == 'Visit Proposed' && this.vpDate == '') {
                //     this.showToast('Error', 'Please enter Visit Proposed Date', 'error');
                //     return;
                }
                else if (this.recStatus == 'Visit Confirmed' && this.vcDate == '') {
                    this.showToast('Error', 'Please enter Visit Confirmed Date', 'error');
                    return;
                }
                const jsonInputString = {
                    clientName: this.clientName || '',
                    companyName: this.companyName || '',
                    designation: this.designation || '',
                    email: this.email || '',
                    mobileNumber: this.mobileNumber || '',
                    profile: this.profile || '',
                    recCode: this.recCode || '',
                    recMapping: this.recMappingId || '',  // Ensure this matches the Apex class field name (recMapping or recMappingId)
                    recAccount: this.recAccount || '',
                    recStatus: this.recStatus || '',
                    linkdin: this.linkdinURL || '',
                    typology: this.typology || [],
                    budget: this.budget || '',
                    docId: this.docId || '',
                    projectName:this.selectedProject || '',
                    vcDate: this.vcDate ? this.vcDate : null, // Handle Datetime properly
                    vpDate: this.vpDate ? this.vpDate : null  // Handle Datetime properly
                };

                console.log('jsonInput:', JSON.stringify(jsonInputString));

                createVpVcRecord({ jsonInput: JSON.stringify(jsonInputString) })
                    .then(result => {
                        // Handle success
                        this.showToast('Success', 'VPVC Record created successfully!', 'success');
                        console.log(result); // Handle response from Apex
                    })
                    .catch(error => {
                        // Handle error
                        this.showToast('Error', error.body.message, 'error');
                        console.error(error); // Handle error response
                    });
                this.clearVpvcValues();
            } else if (this.isMeeting) {
                if (this.selectedMeetingType == '') {
                    this.showToast('Error', 'Please enter Meeting Type', 'error');
                    return;
                }else if (this.selectedMeetingReason == '') {
                    this.showToast('Error', 'Please enter Meeting Reason', 'error');
                    return;
                }else if (this.meetingRemarks == '') {
                    this.showToast('Error', 'Please enter Meeting Remarks', 'error');
                    return;
                }else if(this.isFollowup && this.nextActionDate == null){
                    this.showToast('Error', 'Please enter Next Action Date', 'error');
                    return;
                }else if (this.isFollowup && new Date(this.nextActionDate) <= new Date()) {
                    this.showToast('Error', 'Next Action Date must be a future date', 'error');
                    return;
                }
                const jsonInputString = {
                    taskSubject: 'Meeting with ' + this.recName,
                    taskMeetingType: this.selectedMeetingType || '',
                    taskMeetingReason: this.selectedMeetingReason || '',
                    meetingRemarks: this.meetingRemarks || '',
                    meetingStatus: this.selectedMeetingStatus || '',
                    recAccount: this.recAccount || '',
                    recMapping: this.recMappingId || '',
                    meetingInterest: this.recInterest || '',
                    meetingLocation: this.meetingLocation || '',
                    meetingLatitude: this.latitude || 0,
                    meetingLongitude: this.longitude || 0,
                    recInterest: this.recInterest || '',
                    projectName: this.selectedProject || '',                
                    nextAction: this.nextAction || '',
                    nextActionDateTime: this.nextActionDate || null,
                    recName: this.recName
                };
                createTaskSMModel({ jsonInput: JSON.stringify(jsonInputString) })
                    .then(result => {
                        // Handle success
                        this.showToast('Success', 'Meeting Record created successfully!', 'success');
                        console.log('Success==>', result); // Handle response from Apex
                    })
                    .catch(error => {
                        // Handle error
                        this.showToast('Error', error.body.message, 'error');
                        console.error(error); // Handle error response
                    });
                this.clearTaskVariables();
            } else if (this.isActivity) {
                if (this.taskSubject == '') {
                    this.showToast('Error', 'Please enter Activity Name', 'error');
                    return;
                }else if (this.taskDescription == '') {
                    this.showToast('Error', 'Please enter Activity Remarks', 'error');
                    return;
                }else if (new Date(this.activityEndDate) <= new Date(this.activityStartDate)) {
                    this.showToast('Error', 'Activity End Date must be after Activity Start Date', 'error');
                    return;
                }

                const jsonInputString = {
                    taskSubject: this.taskSubject || '',
                    taskDescription: this.taskDescription || '', 
                    activityType : this.selectedMeetingType || '',
                    recAccount: this.recAccount || '',
                    taskJBP: this.taskjbpName || '',
                    recMapping: this.recMappingId || '',
                    projectName: this.selectedProject || '',
                    activityStartDate: this.activityStartDate || null,
                    activityEndDate: this.activityEndDate || null
                };
                console.log('jsonInputString==>', JSON.stringify(jsonInputString));
                createTaskSMModel({ jsonInput: JSON.stringify(jsonInputString) })
                    .then(result => {
                        // Handle success
                        this.showToast('Success', 'Activity Record created successfully!', 'success');
                        console.log(result); // Handle response from Apex
                    })
                    .catch(error => {
                        // Handle error
                        this.showToast('Error', error.body.message, 'error');
                        console.error(error); // Handle error response
                    });
                    this.clearTaskVariables();
                } else if (this.isJbp) {
                console.log('selectedProject==>', this.selectedProject);
                if(this.jbpName == '') {
                    this.showToast('Error', 'Please enter the JBP Name.', 'error');
                    return;
                }else if(this.jbpAType == '') {
                    this.showToast('Error', 'Please select the Activity Type.', 'error');
                    return;
                }else if(this.supportRequired == '') {
                    this.showToast('Error', 'Please select the Activity Support Required', 'error');
                    return;
                }else if(this.jbpStartDate == '') {
                    this.showToast('Error', 'Please enter the Start Date', 'error');
                    return;
                }else if(this.jbpEndDate == '') {
                    this.showToast('Error', 'Please enter the End Date', 'error');
                    return;
                } else if (new Date(this.jbpEndDate) <= new Date(this.jbpStartDate)) {
                    this.showToast('Error', 'End Date must be after Start Date', 'error');
                    return;
                }


                const jsonInputString = {
                    jbpStatus: this.jbpStatus || '',
                    jbpActivityType: this.jbpAType || '',
                    jbpActionSupport: this.supportRequired || '',
                    jbpName: this.jbpName || '',
                    startDate: this.jbpStartDate || null,
                    endDate: this.jbpEndDate || null,
                    jbpProject: this.selectedProject || '',
                    recMapping: this.recMappingId || '',
                    recAccount: this.recAccount || '',
                    cost: this.costValue || 0,
                    jbpResourceTypes: this.selectedResourceType || [],
                    jbpEndUsers: this.selectedEndUser || [],
                    jbpCommunities: this.selectedCommunity || [],
                    investorName: this.investorName || '',
                    jbpOthers: this.jbpOthers || '',
                    jbpTotalDatabase: this.totalDatabase || 0,
                    jbpRelavantDatabase: this.relevantDatabase || 0,
                    nriDatabase: this.nriData || 0,
                    osDatabase: this.osData || 0,
                    corporatePrivateOrg: this.corporatePrivateOrg || 0,
                    club: this.club || '',
                    association: this.association || '',
                    society: this.society || '',
                    governmentOrg: this.governmentOrg || '',
                    psu: this.psu || '',
                    religiousPlace: this.religiousPlace || '',
                    inroadExpectedReach: this.inroadExpectedReach || 0,
                    jbpInterest : this.selectedInterestLevel || '',
                    tlRating : this.selectedTLRating || '',
                    smRating : this.selectedSMRating || ''                
                };
                console.log('jsonInputString==>', JSON.stringify(jsonInputString));
                createjbpRecord({ jsonInput: JSON.stringify(jsonInputString) })
                    .then(result => {
                        // Handle success
                        this.showToast('Success', 'JBP Record created successfully!', 'success');
                        console.log(result); // Handle response from Apex
                    })
                    .catch(error => {
                        // Handle error
                        this.showToast('Error', error.body.message, 'error');
                        console.error(error); // Handle error response
                    });
                this.clearJBPVariables();
            }
            this.isModalOpen = false;
            this.isJbp = false;
            this.isActivity = false;
            this.isVpvc = false;
            this.isMeeting = false;
        } catch (error) {
            console.error('Error in handleSave:', error);
            this.showToast('Error', 'An unexpected error occurred', 'error');
        }
    }
    clearMeetingVariables() {
        this.selectedMeetingStatus = '';
        this.latitude = '';
        this.longitude = '';
        this.recAccount = '';
        this.recMappingId = '';
        this.eventLocation = '';
        this.meetingStatus = '';
        this.actionName = '';
        this.isEventMeet = false;
    }
    clearTaskVariables() {
        this.recName = '';
        this.selectedCallType = '';
        this.selectedCallReason = '';
        this.selectedCallStatus = '';
        this.callRemarks = '';
        
        this.selectedProject = '';
        this.nextAction = '';
        this.nextActionDate = null;
        this.isFollowup = false;
        this.isCallConnect = false;
        this.selectedCallNotConnnectReason = '';
        this.taskSubject = '';
        this.taskDescription = '';
        this.taskjbpName || '';
        this.activityStartDate = null;
        this.activityEndDate = null;
        this.selectedMeetingType = '';
        this.selectedMeetingType = '';
        this.selectedMeetingReason = '';
        this.selectedCallStatus = '';
        this.meetingRemarks = '';
        this.recAccount = '';
        this.recMappingId = '';
        this.recInterest = '';
        this.meetingLocation = '';
        this.latitude = 0;
        this.longitude = 0;
        this.selectedMeetingStatus = '';
    }
    clearVpvcValues() {
        this.clientName = '';
        this.companyName = '';
        this.designation = '';
        this.email = '';
        this.mobileNumber = '';
        this.profile = '';
        this.recCode = '';
        this.recMappingId = '';
        this.recAccount = '';
        this.recStatus = '';
        this.typology = '';
        this.vcDate = '';
        this.budget = '';
        this.vpDate = '';
        this.docId = '';
        this.linkdinURL = '';
        this.isVpStatus = false;
        this.isVcStatus = false;
        this.fileuploadedName = '';
        this.fileuploaded = false;
    }
    clearJBPVariables() {
        this.jbpStatus = '';
        this.jbpName = '';
        this.jbpAType = '';
        this.supportRequired = '';
        this.jbpStartDate = '';
        this.jbpEndDate = '';
        // this.selectedProject = '';
        this.recMappingId = '';
        this.recAccount = '';
        this.costValue = '';
        this.selectedResourceType = [];  // Assuming it's an array
        this.selectedEndUser = [];       // Assuming it's an array
        this.selectedCommunity = [];     // Assuming it's an array
        this.investorName = '';
        this.jbpOthers = '';
        this.totalDatabase = 0;
        this.relevantDatabase = 0;
        this.nriData = 0;
        this.osData = 0;
        this.corporatePrivateOrg = 0;
        this.club = '';
        this.association = '';
        this.society = '';
        this.governmentOrg = '';
        this.psu = '';
        this.religiousPlace = '';
        this.inroadExpectedReach = 0;
        this.selectedInterestLevel = '';
        this.selectedTLRating = '';
        this.selectedSMRating = '';
        this.isOnRoads = false;
        this.isJBPDatabase = false;
    }
}