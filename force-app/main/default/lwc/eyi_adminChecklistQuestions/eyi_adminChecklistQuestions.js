import { LightningElement,api,track,wire } from 'lwc';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
import submitChecklistItems from '@salesforce/apex/ChecklistQuestionController.submitChecklistInvoiceItems';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItems';
import saveInvoiceStatus from '@salesforce/apex/ChecklistQuestionController.saveInvoiceStatus'; // Add this import
import saveInvoiceSubmissionStatus from '@salesforce/apex/ChecklistQuestionController.saveInvoiceSubmissionStatus';

import getRECDetails from '@salesforce/apex/ChecklistQuestionController.getRECDetails';
import getBrokerageDetails from '@salesforce/apex/ChecklistQuestionController.getBrokerageDetails';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';

const FIELDS = ['Opportunity.Name'];

export default class Eyi_adminChecklistQuestions extends LightningElement {
    @api recordId;
    @track checklistItems = [];
    @track questions = [];
    @track welcomeCallQuestions = []; 
    @track showPrint = false;
    opportunityName
    checkedBy
    @track categoryOptions = [
        { label: 'Critical', value: 'Critical' },
        { label: 'Non-Critical', value: 'Non-Critical' }
    ];

    @track invoiceOptions = [
        { label: 'Approved', value: 'Approved' },
        { label: 'Rejected', value: 'Rejected' }
    ];

    @track answers = {};

    @track disableFields = true;
    userId = Id;
    userName;
    userRoleName;
    userProfile
    showCancelBtn = false;
    @track picklistValues = [];
    @track globalInvoiceStatus = '';
    @track isInvoiceSubmitted = false;

    // Add this property to track validation message
    @track showValidationMessage = false;

    // Add this property to track if Admin Checklist status was previously approved
    @track isInvoiceStatusApproved = false;

    // Add loading spinner property - ensure proper initialization
    @track isLoading = false;

    @track opportunityDetails = null;
    @track recDetails = null;
    @track brokerageDetails = null;

    connectedCallback(){
        
    }
    
    @wire(getRecord, { recordId: Id, fields: [Name, RoleName,ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Name.value != null) {
                this.userName = data.fields.Name.value;
            }
            if (data.fields.UserRole.value != null) {
                this.userRoleName = data.fields.UserRole.value.fields.Name.value;
            }
            if (data.fields.Profile.value != null) {
                console.log('Profile '+data.fields.Profile.value);
                console.log('Profile Name'+data.fields.Profile.value.fields.Name.value);
                
                this.userProfile = data.fields.Profile.value.fields.Name.value;
            }
            this.fetchOpportunityName();
            this.fetchChecklistItems();
        }
    }

    fetchOpportunityName() {
        if (this.recordId) {
            getOppRecord({ recordId: this.recordId })
                .then(result => {
                    this.opportunityDetails = result; // <-- Store full record
                    
                    console.log('result.IsWelcomeCallChecklistSubmitted : '+result.IsWelcomeCallChecklistSubmitted__c);
                    
                    // Default to disabled for all users
                    this.disableFields = true;

                    // Only enable for CEO and CRM Admin roles
                    if(this.userRoleName && (this.userRoleName.includes('CEO') || this.userRoleName.includes('CRM TL') || this.userRoleName.includes('CRM Admin'))) {
                        this.disableFields = false;
                        console.log('Admin user - enabling fields');
                    } else {
                        this.disableFields = true;
                        console.log('Non-admin user - disabling fields');
                    }
                    
                    this.opportunityName = result.Name;
                    
                    // Set the saved invoice status from Opportunity
                    if(result.EYI_Admin_Checklist_Status__c) {
                        this.globalInvoiceStatus = result.EYI_Admin_Checklist_Status__c;
                        console.log('Saved Invoice Status: ', this.globalInvoiceStatus);
                        
                        // Check if status is approved AND submitted - disable further changes
                        if(result.EYI_Admin_Checklist_Status__c === 'Approved' && result.EYI_Is_Admin_Checklist_Submitted__c === true) {
                            this.isInvoiceStatusApproved = true;
                            this.disableFields = true; // Disable all fields when approved and submitted
                            console.log('Invoice status is approved and submitted - disabling fields');
                        }
                    }
                    
                    // Set the saved submission status from Opportunity
                    if(result.EYI_Is_Admin_Checklist_Submitted__c) {
                        this.isInvoiceSubmitted = result.EYI_Is_Admin_Checklist_Submitted__c;
                        console.log('Admin Checklist Submission Status: ', this.isInvoiceSubmitted);
                    }

                    // Fetch REC and Brokerage details after Opportunity is loaded
                    this.fetchRECDetails();
                    this.fetchBrokerageDetails();
                })
                .catch(error => {
                    console.error('Error fetching Opportunity: ', error);
                });
        }
    }

        fetchRECDetails() {
        if (this.recordId) {
            getRECDetails({ opportunityId: this.recordId })
                .then(result => {
                    if (result) {
                        this.recDetails = result; // <-- Store full record
                        console.log('REC Details fetched:', JSON.stringify(this.recDetails));
                        
                        // Update static questions with dynamic values
                        this.updateStaticQuestionsWithDynamicValues();
                    }
                })
                .catch(error => {
                    console.error('Error fetching REC details:', error);
                });
        }
    }

    // Add new method to fetch Brokerage details
    fetchBrokerageDetails() {
        if (this.recordId) {
            getBrokerageDetails({ opportunityId: this.recordId })
                .then(result => {
                    if (result) {
                        this.brokerageDetails = result;
                    } else {
                        this.brokerageDetails = null;
                    }
                })
                .catch(error => {
                    this.brokerageDetails = null;
                });
        }
    }


    fetchChecklistItems() {
        getChecklistItemsByRecordId({ recordId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log('Checklist Items fetched:', JSON.stringify(result));
                    if (result.length === 0) {
                        console.log('No checklist items found, calling fetchDefaultQuestions');
                        this.fetchDefaultQuestions();
                    } else {
                        this.checklistItems = result.filter(item => item.Type__c === "Admin Checklist");
                        if(this.checklistItems.length === 0){
                            console.log('this.checklistItems.length : '+this.checklistItems.length);
                            
                            this.fetchDefaultQuestions();
                        }else{
                            this.showPrint = true;
                            this.processQuestionsAndAnswers();
                        } 
                    }
                }
            })
            .catch((error) => {
                console.error('Error fetching checklist items:', error);
                this.fetchDefaultQuestions();
            });
    }

    fetchDefaultQuestions() {
            getQuestion()
                .then((data) => {
                    this.questions = data.filter(question => 
                        question.Type__c === 'Admin Checklist'
                    );
                    this.processQuestionsAndAnswers();
                })
                .catch((error) => {
                    console.error('Error fetching default questions:', error);
                });
        }
    
        processQuestionsAndAnswers() {
            if (this.checklistItems.length > 0) {
                this.welcomeCallQuestions = this.checklistItems.filter(
                    (item) => item.Type__c === 'Admin Checklist'
                );
               
            } else if (this.questions.length > 0) {
                
                this.questions.forEach(question => {
                            if (!question.CreatedBy) {
                                question.CreatedBy = { Name: '' };
                            }
                        });
    
                this.welcomeCallQuestions = this.questions.filter(
                    (question) => question.Type__c === 'Admin Checklist'
                );
                
            } else {
                console.error('Neither checklistItems nor questions have data.');
            }
            console.log('Welcome Call Questions:', JSON.stringify(this.questions));
        }

        handleInputChange(event) {
            const questionId = event.target.dataset.id;
            const fieldName = event.target.name;
            const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
            
            console.log('Input change - ID:', questionId, 'Field:', fieldName, 'Value:', value);
            
            // Update the question data in welcomeCallQuestions array
            this.welcomeCallQuestions = this.welcomeCallQuestions.map(question => {
                if (question.Id === questionId || question.Question__c === questionId) {
                    const updatedQuestion = { ...question };
                    if (fieldName === 'remark') {
                        updatedQuestion.Remarks__c = value;
                    } else if (fieldName === 'valid') {
                        updatedQuestion.Valid__c = value;
                    } else if (fieldName === 'status') {
                        updatedQuestion.Status__c = value;
                    } else if (fieldName === 'Admin Checklist') {
                        updatedQuestion.Admin_Checklist__c = value;
                    }
                    return updatedQuestion;
                }
                return question;
            });

            // Also update the answers object to maintain consistency
            if (!this.answers[questionId]) {
                this.answers[questionId] = {};
            }
            
            if (fieldName === 'remark') {
                this.answers[questionId].remark = value;
            } else if (fieldName === 'valid') {
                this.answers[questionId].valid = value;
            } else if (fieldName === 'status') {
                this.answers[questionId].status = value;
            } else if (fieldName === 'Admin Checklist') {
                this.answers[questionId].invoice = value;
            }
            
            // Show cancel button when user starts making changes
            this.showCancelBtn = true;

            // Clear validation message when questions are updated
            if (this.showValidationMessage && this.areAllQuestionsValid) {
                this.showValidationMessage = false;
            }
        }

        handleSave(event) {
            let isValid = true;
            const label = event.target.label;
            let isSubmit = false;
            
            if(label == 'Submit'){
                console.log('inside Submit if');
                isSubmit = true;
                // Show loading spinner when Submit is clicked
                this.isLoading = true;
            }
            
            // Validate required globalInvoiceStatus field FIRST
            if (!this.globalInvoiceStatus || this.globalInvoiceStatus === '') {
                isValid = false;
                this.isLoading = false; // Hide spinner on validation error
                this.showToast('Error', 'Please select Eligibility to raise Admin Checklist', 'error');
                return;
            }
            
            // Add loading for save operations too
            if (!isSubmit) {
                this.isLoading = true;
            }
            
            if(this.checklistItems.length > 0 ){
                this.updateChecklistItemsFromAnswers(isSubmit);
            }
            
            if(this.questions.length > 0){
                if (isSubmit == true) {
                    // Check each question for valid/remark combination
                    this.welcomeCallQuestions.forEach((question) => {
                        const valid = question.Valid__c;
                        const remark = question.Remarks__c;

                        // If Valid checkbox is NOT checked (false, null, undefined), remark is mandatory
                        if (!valid && (!remark || remark.trim() === '')) {
                            isValid = false;
                            this.isLoading = false; // Hide spinner on validation error
                            this.showToast('Error', 'Please enter remarks for items not marked as Valid', 'warning');
                        }
                    });
                }

                if (isValid) {
                    // Save Admin Checklist status and submission status for both save and submit
                    if (this.globalInvoiceStatus) {
                        this.saveInvoiceStatusToOpportunity();
                        if (isSubmit) {
                            this.saveInvoiceSubmissionStatusToOpportunity(true);
                        }
                    }
                    
                    // Use welcomeCallQuestions for creating checklist items
                    const checklistItems = this.welcomeCallQuestions.map((question) => {
                        return {
                            Opportunity__c: this.recordId,
                            Question__c: question.Question__c,
                            Remarks__c: question.Remarks__c || '', 
                            Category__c: question.Category__c, 
                            Type__c: question.Type__c,
                            Valid__c: question.Valid__c || false,
                            Status__c: question.Status__c || '',
                            Invoice_Status__c: question.Invoice_Status__c || ''
                        };
                    });
                    console.log('checklistItems Before Save '+JSON.stringify(checklistItems));
                    
                    saveChecklistItems({ 
                        checklistItems, 
                        recordId: this.recordId,
                        isSubmit:isSubmit,
                        checklistName:'Admin Checklist'
                    })
                    .then(() => {
                        console.log('Checklist items saved successfully');
                        this.showToast('Success', 'Checklist saved successfully', 'success');
                        this.questions =[];
                        this.checklistItems =[];
                        this.welcomeCallQuestions =[];
                        this.answers ={};
                        this.fetchOpportunityName();
                        this.fetchChecklistItems();  
                        // Reset loading state before reload
                        this.isLoading = false;
                        location.reload();
                    })
                    .catch((error) => {
                        console.error('Error saving checklist items: ', error);
                        this.isLoading = false; // Hide spinner on error
                        this.showToast('Error', 'Error saving checklist items', 'error');
                    });
                } else {
                    this.isLoading = false; // Hide spinner if validation fails
                }
            } 
        }

        // Add this new method to save invoice status to Opportunity
        saveInvoiceStatusToOpportunity() {
            saveInvoiceStatus({
                recordId: this.recordId,
                invoiceStatus: this.globalInvoiceStatus,
                checklistName: 'Admin Checklist'
            })
            .then(() => {
                console.log('Admin Checklist status saved to Opportunity successfully');
            })
            .catch((error) => {
                console.error('Error saving Admin Checklist status to Opportunity: ', error);
                this.showToast('Error', 'Error saving Admin Checklist status', 'error');
            });
        }

            saveInvoiceSubmissionStatusToOpportunity(isSubmitted) {
                saveInvoiceSubmissionStatus({
                    recordId: this.recordId,
                    isSubmitted: isSubmitted
                })
                .then(() => {
                    console.log('Admin Checklist submission status saved to Opportunity successfully');
                    this.isInvoiceSubmitted = isSubmitted;
                })
                .catch((error) => {
                    console.error('Error saving Admin Checklist submission status to Opportunity: ', error);
                    this.showToast('Error', 'Error saving submission status', 'error');
                });
            }

            updateChecklistItemsFromAnswers(isSubmit) {
                console.log('isSubmit '+isSubmit);

                let isValid = true;
                
                // Add loading state for update operations
                if (!this.isLoading && isSubmit) {
                    this.isLoading = true;
                }
                
                // Validate required globalAdmin ChecklistStatus field
                if (!this.globalInvoiceStatus || this.globalInvoiceStatus === '') {
                    isValid = false;
                    this.isLoading = false; // Hide spinner on validation error
                    this.showToast('Error', 'Please select Eligibility to raise Admin Checklist', 'error');
                    return;
                }
                
                Object.keys(this.answers).forEach((answerId) => {
                    const answer = this.answers[answerId];
                    this.checklistItems = this.checklistItems.map((item) => {
                        if (item.Id === answerId) {
                            return {
                                ...item,
                                Remarks__c: answer.remark || item.Remarks__c,
                                Category__c: answer.category || item.Category__c,
                                Valid__c: answer.valid !== undefined ? answer.valid : item.Valid__c,
                                Status__c: answer.status || item.Status__c,
                                Invoice_Status__c: answer.invoice || item.Invoice_Status__c
                            };
                        }
                        return item;
                    });
                });
                
                console.log('Updated checklist items: ' + JSON.stringify(this.checklistItems));
                const updatedItems = this.checklistItems.filter((item) => {
                    return this.answers.hasOwnProperty(item.Id);
                });
                console.log('Updated items before save: ' + JSON.stringify(updatedItems));
                
                updatedItems.forEach((question) => {
                    const valid = question.Valid__c;
                    const remark = question.Remarks__c;
                    const category = question.Category__c;
                    console.log('valid '+valid);
                    console.log('remark '+remark);
                        
                    // Check if Valid checkbox is NOT checked and remark is empty for submit
                    if (isSubmit && !valid && (!remark || remark.trim() === '')) {
                        isValid = false;
                        this.isLoading = false; // Hide spinner on validation error
                        this.showToast('Error', 'Please enter remarks for items not marked as Valid', 'warning');
                    }
                });

                if (isSubmit) {
                    this.checklistItems.forEach((question) => {
                        // Only check items that are not in updatedItems
                        const isInUpdatedItems = updatedItems.some(item => item.Id === question.Id);
                        if (!isInUpdatedItems) {
                            const valid = question.Valid__c;
                            const remark = question.Remarks__c;

                            // Check if Valid checkbox is NOT checked and remark is empty
                            if (!valid && (!remark || remark.trim() === '')) {
                                isValid = false;
                                this.isLoading = false; // Hide spinner on validation error
                                this.showToast('Error', 'Please enter remarks for items not marked as Valid', 'warning');
                            }
                        }
                    });
                }

                if (updatedItems.length > 0) {
                    if(isValid){
                        // Save invoice status and submission status for both save and submit
                        if (this.globalInvoiceStatus) {
                            this.saveInvoiceStatusToOpportunity();
                            if (isSubmit) {
                                this.saveInvoiceSubmissionStatusToOpportunity(true);
                            }
                        }
                        
                        saveChecklistItems({ 
                            checklistItems: updatedItems, 
                            recordId: this.recordId,
                            isSubmit:isSubmit,
                            checklistName:'Admin Checklist'
                        })
                        .then(() => {
                            console.log('Checklist items saved successfully');
                            this.showToast('Success', 'Checklist updated successfully', 'success');
                            this.questions =[];
                            this.checklistItems =[];
                            this.welcomeCallQuestions =[];
                            this.answers ={};
                            this.fetchOpportunityName();
                            this.fetchChecklistItems();
                            // Reset loading state before reload
                            this.isLoading = false;
                            location.reload();
                        })
                        .catch((error) => {
                            console.error('Error saving checklist items: ', error);
                            this.isLoading = false; // Hide spinner on error
                            this.showToast('Error', 'Error saving checklist items', 'error');
                        });
                    } else {
                        this.isLoading = false; // Hide spinner if validation fails
                    }
                } else if( updatedItems.length == 0 && isValid == true && isSubmit ==true){
                    // Save opportunity fields before submitting
                    if (this.globalInvoiceStatus) {
                        this.saveInvoiceStatusToOpportunity();
                        this.saveInvoiceSubmissionStatusToOpportunity(true);
                    }
                    
                    // Call submitChecklistItems with the Admin Checklist status
                    submitChecklistItems({ 
                        recordId: this.recordId,
                        isSubmit: isSubmit,
                        checkListLabel: 'Admin Checklist',
                        invoiceStatus: this.globalInvoiceStatus
                    })
                    .then(() => {
                        console.log('Checklist items saved successfully');
                        this.showToast('Success', 'Checklist Submitted successfully', 'success');
                        this.fetchOpportunityName();
                        this.fetchChecklistItems();
                        // Reset loading state before reload
                        this.isLoading = false;
                        location.reload();
                    })
                    .catch((error) => {
                        console.error('Error saving checklist items: ', error);
                        this.isLoading = false; // Hide spinner on error
                        this.showToast('Error', 'Error submitting checklist', 'error');
                    });
                } else {
                    this.isLoading = false; // Hide spinner when no changes to save
                    this.showToast('Info', 'No changes to save', 'info');
                }
            }
                showToast(title, message, variant) {
                        const event = new ShowToastEvent({
                            title: title,
                            message: message,
                            variant: variant
                        });
                        this.dispatchEvent(event);
                    }
                    handleCancel(){
                        this.showCancelBtn = false;
                        this.answers = {};
                        this.checklistItems =[];
                        this.questions =[];
                        this.welcomeCallQuestions =[];
                        this.fetchChecklistItems();
                    }

                    // Add this getter to show cancel button when questions are loaded
                get showCancelBtn() {
                    return this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0 && !this.disableFields;
                }

                // Update the getter to check Valid__c instead of Status__c
                get isSubmitDisabled() {
                    try {
                        if (!this.welcomeCallQuestions || this.welcomeCallQuestions.length === 0) {
                            return true;
                        }
                        
                        // Check if global Admin Checklist status is selected
                        if (!this.globalInvoiceStatus || this.globalInvoiceStatus === '') {
                            return true;
                        }
                        
                        // Disable when loading or when fields are disabled by user role/permissions
                        return this.disableFields || this.isLoading;
                    } catch (error) {
                        console.error('Error in isSubmitDisabled getter:', error);
                        return true;
                    }
                }

                // Also update showSubmitBtn for consistency
                get showSubmitBtn() {
                    try {
                        return this.welcomeCallQuestions && 
                            this.welcomeCallQuestions.length > 0 && 
                            !this.disableFields &&
                            this.globalInvoiceStatus; // Removed the Valid__c check
                    } catch (error) {
                        console.error('Error in showSubmitBtn getter:', error);
                        return false;
                    }
                }

                // Add a getter for showCancelButton to avoid conflicts
                get showCancelButton() {
                    try {
                        return this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0 && !this.disableFields;
                    } catch (error) {
                        console.error('Error in showCancelButton getter:', error);
                        return false;
                    }
                }

                // Add this property to track validation message
                @track showValidationMessage = false;

                // Add this getter to check if all questions are valid
                get areAllQuestionsValid() {
                    if (!this.welcomeCallQuestions || this.welcomeCallQuestions.length === 0) {
                        return false;
                    }
                    return this.welcomeCallQuestions.every(question => question.Valid__c === true);
                }

                handleGlobalInvoiceChange(event) {
                    const selectedValue = event.detail.value;
                    
                    // Check if Admin Checklist status was already approved - prevent any changes
                    if (this.isInvoiceStatusApproved) {
                        this.showToast('Warning', 'Admin Checklist status cannot be changed once it has been approved.', 'warning');
                        // Keep the current approved status
                        event.target.value = this.globalInvoiceStatus;
                        return;
                    }
                    
                    // Check if user is trying to select "Approved" when not all questions are valid
                    if (selectedValue === 'Approved' && !this.areAllQuestionsValid) {
                        this.showValidationMessage = true;
                        // Reset the selection
                        this.globalInvoiceStatus = '';
                        return;
                    }
                    
                    // Clear validation message if valid selection
                    this.showValidationMessage = false;
                    this.globalInvoiceStatus = selectedValue;
                    
                    // Update all questions with the same Admin Checklist status
                    this.welcomeCallQuestions = this.welcomeCallQuestions.map(question => {
                        return {
                            ...question,
                            Invoice_Status__c: this.globalInvoiceStatus
                        };
                    });
                    
                    // Update answers object for all questions
                    this.welcomeCallQuestions.forEach(question => {
                        if (!this.answers[question.Id]) {
                            this.answers[question.Id] = {};
                        }
                        this.answers[question.Id].invoice = this.globalInvoiceStatus;
                    });
                    
                    this.showCancelBtn = true;
                }
                
                // Opportunity display info getter
                get opportunityDisplayInfo() {
                    if (this.opportunityDetails && this.opportunityDetails.Id) {
                        return {
                            name: this.opportunityDetails.Name || 'Opportunity Record',
                            stageName: this.opportunityDetails.StageName || '',
                            amount: this.opportunityDetails.Amount || '',
                            closeDate: this.opportunityDetails.CloseDate ? new Date(this.opportunityDetails.CloseDate).toLocaleDateString() : '',
                            invoiceStatus: this.opportunityDetails.EYI_Admin_Checklist_Status__c || '',
                            createdDate: this.opportunityDetails.CreatedDate ? new Date(this.opportunityDetails.CreatedDate).toLocaleDateString() : '',
                            url: `/${this.opportunityDetails.Id}`
                        };
                    }
                    return null;
                }

                // REC display info getter
                get recDisplayInfo() {
                    if (this.recDetails && this.recDetails.Id) {
                        return {
                            name: this.recDetails.Name || 'REC Record',
                            sapCode: this.recDetails.EYI_SAP_ID__c || '',
                            reraRegistered: this.recDetails.EYI_RERA_Registered__c || '',
                            reraCertificateNo: this.recDetails.EYI_RERA_Certificate_No__c || '',
                            panNumber: this.recDetails.Verified_PAN_Number__c || '',
                            panUploaded: this.recDetails.EYI_Pan_Uploaded__c ? 'Yes' : 'No',
                            createdDate: this.recDetails.CreatedDate ? new Date(this.recDetails.CreatedDate).toLocaleDateString() : '',
                            url: `/${this.recDetails.Id}`
                        };
                    }
                    return null;
                }

                // Brokerage display info getter
                get brokerageDisplayInfo() {
                    if (this.brokerageDetails && this.brokerageDetails.Id) {
                        return {
                            name: this.brokerageDetails.Name || 'Brokerage Record',
                            amount: this.brokerageDetails.EYI_Brokerage_Amount__c || '',
                            percentage: this.brokerageDetails.EYI_Brokerage_Percentage__c || '',
                            status: this.brokerageDetails.EYI_Status__c || '',
                            paymentStatus: this.brokerageDetails.EYI_Payment_Status__c || '',
                            is20BookingReceived: this.brokerageDetails.EYI_Is_20_Booking_Received__c ? 'Yes' : 'No',
                            createdDate: this.brokerageDetails.CreatedDate ? new Date(this.brokerageDetails.CreatedDate).toLocaleDateString() : '',
                            lastModifiedDate: this.brokerageDetails.LastModifiedDate ? new Date(this.brokerageDetails.LastModifiedDate).toLocaleDateString() : '',
                            url: `/${this.brokerageDetails.Id}`
                        };
                    }
                    return null;
                }

                get hasOpportunityDetails() {
                    return this.opportunityDetails && this.opportunityDetails.Id;
                }

                get hasRECDetails() {
                    return this.recDetails && this.recDetails.Id;
                }

                get hasBrokerageDetails() {
                    return this.brokerageDetails && this.brokerageDetails.Id;
                }
}