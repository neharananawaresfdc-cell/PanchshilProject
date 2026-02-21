import { LightningElement,api,track,wire } from 'lwc';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
import submitChecklistItems from '@salesforce/apex/ChecklistQuestionController.submitChecklistItems';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItemsCancellation';
import getRECDetails from '@salesforce/apex/ChecklistQuestionController.getRECDetails';
import getBrokerageDetails from '@salesforce/apex/ChecklistQuestionController.getBrokerageDetails';

import getBankDetailsByREC from '@salesforce/apex/ChecklistQuestionController.getBankDetailsByREC';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import POST_REGISTER_LOAN_CHECKLIST_FIELD from '@salesforce/schema/Opportunity.EYI_Is_Post_Register_with_Loan_Checklist__c';

const FIELDS = ['Opportunity.Name'];

export default class PostCancellationwithLoanChecklist extends LightningElement {

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
    @track answers = {};

    @track disableFields = true;
    @track disableSaveSubmit = false;  // This will only control Save Draft button
    @track disableSubmitOnly = true;  // New property to control only Submit button
    @track isChecklistCompleted = false;
    @track isPostRegisterLoanChecklistSubmitted = false; // Add this property
    userId = Id;
    userName;
    userRoleName;
    userProfile
    showCancelBtn = false;

    // Add these properties for related information
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
                    console.log('result.IsWelcomeCallChecklistSubmitted : '+result.IsWelcomeCallChecklistSubmitted__c);
                    console.log('result.EYI_Is_Post_Register_with_Loan_Checklist__c : '+result.EYI_Is_Post_Register_with_Loan_Checklist__c);
                    
                    // Store the full opportunity details
                    this.opportunityDetails = result;
                    
                    // Check if Post Register with Loan Checklist is already submitted
                    if(result.EYI_Is_Post_Register_with_Loan_Checklist__c == true){
                        console.log('Post Register with Loan checklist is already submitted - disabling all fields');
                        this.isPostRegisterLoanChecklistSubmitted = true;
                        this.disableFields = true;
                        this.disableSaveSubmit = true;
                        this.disableSubmitOnly = true;
                    } else {
                        this.isPostRegisterLoanChecklistSubmitted = false;
                        
                        // Apply role-based permissions only if checklist is not submitted
                        if(result.StageName == 'Walk-in' || (!this.userRoleName.includes('Relationship Manager') &&  !this.userRoleName.includes('Sourcing Manager'))  ){
                           console.log('yes');
                            this.disableFields = true; 
                         } else if(this.userRoleName.includes('Relationship Manager') || this.userRoleName.includes('Sourcing Manager') ){
                             console.log('yes1');
                             this.disableFields = false;
                         }
                         if(!this.userRoleName.includes('System Administrator')  || !this.userRoleName.includes('CRM Admin') ){
                           console.log('yes2');
                            this.disableFields = false;  
                        }
                    }
                    
                    this.opportunityName = result.Name;
                    
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
                        this.recDetails = result;
                        this.recId = result.Id; // <-- Set recId here for bank details wire
                        console.log('REC Details fetched:', JSON.stringify(this.recDetails));
                    }
                })
                .catch(error => {
                    console.error('Error fetching REC details:', error);
                });
        }
    }

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
                        this.checklistItems = result.filter(item => item.Type__c === "Post Registration with Loan");
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
                this.disableSubmitOnly = true; // Disable submit on error
                this.fetchDefaultQuestions();
            });
    }

    fetchDefaultQuestions() {
        getQuestion()
            .then((data) => {
                this.questions = data.filter(question => 
                    question.Type__c === 'Post Registration with Loan'
                );
                this.processQuestionsAndAnswers();
            })
            .catch((error) => {
                console.error('Error fetching default questions:', error);
                this.disableSubmitOnly = true; // Disable submit on error
            });
    }
    
    processQuestionsAndAnswers() {
        if (this.checklistItems.length > 0) {
            this.welcomeCallQuestions = this.checklistItems.filter(
                (item) => item.Type__c === 'Post Registration with Loan'
            );
            
            // Check initial checkbox status
            this.checkAllCheckboxesStatus();
           
        } else if (this.questions.length > 0) {
            
            this.questions.forEach(question => {
                if (!question.CreatedBy) {
                    question.CreatedBy = { Name: '' };
                }
            });

            this.welcomeCallQuestions = this.questions.filter(
                (question) => question.Type__c === 'Post Registration with Loan'
            );
            
            // For new questions, check initial status
            this.checkAllCheckboxesStatus();
            
        } else {
            console.error('Neither checklistItems nor questions have data.');
            this.disableSubmitOnly = true; // Disable submit if no data
        }
        console.log('Welcome Call Questions:', JSON.stringify(this.questions));
    }

    handleInputChange(event) {
        this.showCancelBtn = true;
        const { name, value, dataset, checked, type } = event.target;
        const questionId = dataset.id;
        console.log('questionId : '+questionId);
        
        if (!this.answers[questionId]) {
            this.answers[questionId] = {};
        }
        if (type === 'checkbox') {
            this.answers[questionId][name] = checked;
        } else if (type === 'select') {
            this.answers[questionId][name] = value;
        } else {
            this.answers[questionId][name] = value;
        }
        
        // Check if all checkboxes are checked after any input change
        this.checkAllCheckboxesStatus();
        
        console.log('this.answers : '+JSON.stringify(this.answers));
    }

    // New method to check if all checkboxes are checked
    checkAllCheckboxesStatus() {
        let allCheckboxesChecked = true;
        
        // If checklist is already submitted, disable submit button
        if(this.isPostRegisterLoanChecklistSubmitted) {
            this.disableSubmitOnly = true;
            console.log('Checklist already submitted - Submit button disabled');
            return;
        }
        
        if (this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0) {
            this.welcomeCallQuestions.forEach(question => {
                const answer = this.answers[question.Id];
                
                // Get current valid state (from answer or original item)
                const currentValid = answer && answer.valid !== undefined ? answer.valid : question.Valid__c;
                
                // If any checkbox is not checked (false or undefined), disable submit
                if (currentValid !== true) {
                    allCheckboxesChecked = false;
                }
            });
        } else {
            // If no questions, disable submit
            allCheckboxesChecked = false;
        }
        
        // Update only the Submit button disable state (considering checklist submission status)
        this.disableSubmitOnly = !allCheckboxesChecked || this.isPostRegisterLoanChecklistSubmitted;
        
        console.log('All checkboxes checked:', allCheckboxesChecked);
        console.log('Is checklist submitted:', this.isPostRegisterLoanChecklistSubmitted);
        console.log('Disable Submit Only:', this.disableSubmitOnly);
    }

    handleSave(event) {
        // Check if checklist is already submitted
        if(this.isPostRegisterLoanChecklistSubmitted) {
            this.showToast('Warning', 'This checklist has already been submitted and cannot be modified.', 'warning');
            return;
        }
        
        let isValid = true;
        const label = event.target.label;
        let isSubmit = false;
        if(label == 'Submit'){
            console.log('inside Submit if');
            isSubmit = true;
        }
        
        // Enhanced validation for submit
        if(isSubmit) {
            isValid = this.validateAllFields();
            if(!isValid) {
                return; // Exit early if validation fails
            }
        }
        
        if(this.checklistItems.length > 0 ){
            this.updateChecklistItemsFromAnswers(isSubmit);
        }
        if(this.questions.length > 0){
            if (isSubmit == true) {
                isValid = this.validateNewQuestions();
                if(!isValid) {
                    return;
                }
            }

            if (isValid) {
                const checklistItems = this.questions.map((question) => {
                    const answer = this.answers[question.Id] || {};
                    return {
                        Opportunity__c: this.recordId,
                        Question__c: question.Question__c,
                        Remarks__c: answer.remark || '', 
                        Category__c: answer.category || question.Category__c,
                        Valid__c: answer.valid !== undefined ? answer.valid : false,
                        Type__c: question.Type__c
                    };
                });
                
                console.log('Calling saveChecklistItems with checklistName: Post Registration with Loan');
                console.log('isSubmit:', isSubmit);
                
                this.saveChecklistData(checklistItems, isSubmit);
            }
        } 
    }

    // New method for validating all fields
    validateAllFields() {
        let isValid = true;
        let errorMessages = [];
        
        // Check if there are any questions/items to validate
        if(this.welcomeCallQuestions.length === 0) {
            this.showToast('Error', 'No checklist items found to validate', 'error');
            return false;
        }
        
        this.welcomeCallQuestions.forEach((question, index) => {
            const answer = this.answers[question.Id];
            const valid = answer && answer.valid !== undefined ? answer.valid : question.Valid__c;
            const remark = answer && answer.remark !== undefined ? answer.remark : question.Remarks__c;
            const category = answer && answer.category !== undefined ? answer.category : question.Category__c;
            
            // Validation 1: Valid checkbox must be checked or remarks must be provided
            if (valid === false && (!remark || remark.trim() === '')) {
                isValid = false;
                errorMessages.push(`Item ${index + 1}: Please provide remarks when the item is marked as invalid`);
            }
            
            // Validation 2: Each item must have either valid=true or valid=false with remarks
            if (valid === undefined || valid === null) {
                isValid = false;
                errorMessages.push(`Item ${index + 1}: Please mark the item as valid or invalid`);
            }
            
            // // Validation 3: Category should be selected
            // if (!category || category.trim() === '') {
            //     isValid = false;
            //     errorMessages.push(`Item ${index + 1}: Please select a category`);
            // }
        });
        
        if (!isValid) {
            this.showToast('Validation Error', errorMessages.join('; '), 'error');
        }
        
        return isValid;
    }

    // New method for validating new questions
    validateNewQuestions() {
        let isValid = true;
        let errorMessages = [];
        
        this.questions.forEach((question, index) => {
            const answer = this.answers[question.Id];
            if (answer !== undefined) {
                const remark = answer.remark;
                const category = answer.category;
                const valid = answer.valid;

                // Validation: If Valid checkbox is not checked, remark is mandatory
                if (valid === false && (!remark || remark.trim() === '')) {
                    isValid = false;
                    errorMessages.push(`Question ${index + 1}: Please provide remarks when the item is not valid`);
                }
                
            } else {
                isValid = false;
                errorMessages.push(`Question ${index + 1}: Please fill all required fields`);
            }
        });
        
        if (!isValid) {
            this.showToast('Validation Error', errorMessages.join('; '), 'error');
        }
        
        return isValid;
    }

    // Enhanced method for saving checklist data
    saveChecklistData(checklistItems, isSubmit) {
        saveChecklistItems({ 
            checklistItems, 
            recordId: this.recordId,
            bookingFormStatus: '',
            bookingFormRejection:'',
            isSubmit:isSubmit,
            checklistName:'Post Registration with Loan'
        })
        .then(() => {
            console.log('Checklist items saved successfully');
            
            // If it's a submit action, also call submitChecklistItems
            if(isSubmit) {
                console.log('Calling submitChecklistItems for Post Registration with Loan');
                return submitChecklistItems({
                    recordId: this.recordId,
                    isSubmit: true,
                    checkListLabel: 'Post Registration with Loan'
                });
            }
        })
        .then(() => {
            // If it's a submit action, update the Opportunity record
            if(isSubmit) {
                console.log('Updating Opportunity record - EYI_Is_Post_Register_with_Loan_Checklist__c to true');
                return this.updateOpportunityRecord();
            }
        })
        .then(() => {
            // If submitted, update the local status
            if(isSubmit) {
                this.isPostRegisterLoanChecklistSubmitted = true;
                this.disableFields = true;
                this.disableSaveSubmit = true;
                this.disableSubmitOnly = true;
            }
            
            const successMessage = isSubmit ? 'Checklist submitted successfully' : 'Checklist saved successfully';
            this.showToast('Success', successMessage, 'success');
            this.resetComponentState();
            this.refreshData();
        })
        .catch((error) => {
            console.error('Error saving/submitting checklist items: ', error);
            const errorMessage = error.body ? error.body.message : error.message;
            this.showToast('Error', 'Error processing checklist: ' + errorMessage, 'error');
        });
    }

    updateChecklistItemsFromAnswers(isSubmit) {
        console.log('isSubmit '+isSubmit);
        
        let isValid = true;
        let errorMessages = [];
        
        // Enhanced validation for existing checklist items
        if(isSubmit) {
            isValid = this.validateExistingChecklistItems();
            if(!isValid) {
                return;
            }
        }
        
        Object.keys(this.answers).forEach((answerId) => {
            const answer = this.answers[answerId];
            this.checklistItems = this.checklistItems.map((item) => {
                if (item.Id === answerId) {
                    return {
                        ...item,
                        Remarks__c: answer.remark || item.Remarks__c,
                        Category__c: answer.category || item.Category__c,
                        Valid__c: answer.valid !== undefined ? answer.valid : item.Valid__c
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
        
        // Validate updated items
        if(isSubmit) {
            updatedItems.forEach((question, index) => {
                const remark = question.Remarks__c;
                const valid = question.Valid__c;

                if (valid === false && (!remark || remark.trim() === '')) {
                    isValid = false;
                    errorMessages.push(`Updated item ${index + 1}: Please provide remarks when the item is not valid`);
                }
            });
        }

        if (updatedItems.length > 0) {
            if(isValid){
                console.log('Inside Update Item');
                this.saveUpdatedItems(updatedItems, isSubmit);
            } else {
                this.showToast('Validation Error', errorMessages.join('; '), 'error');
            }
        } else if(updatedItems.length == 0 && isValid == true && isSubmit == true){
            console.log('Inside Submit checklist with no data');
            this.submitExistingChecklist();
        } else {
            this.showToast('Info', 'No changes to save', 'info');
        }
    }

    // New method for validating existing checklist items
    validateExistingChecklistItems() {
        let isValid = true;
        let errorMessages = [];
        
        this.checklistItems.forEach((question, index) => {
            const valid = question.Valid__c;
            const remark = question.Remarks__c;

            if (valid === false && (!remark || remark.trim() === '')) {
                isValid = false;
                errorMessages.push(`Existing item ${index + 1}: Please provide remarks when the item is not valid`);
            }
            
            if (valid === undefined || valid === null) {
                isValid = false;
                errorMessages.push(`Existing item ${index + 1}: Please mark the item as valid or invalid`);
            }
        });
        
        if (!isValid) {
            this.showToast('Validation Error', errorMessages.join('; '), 'error');
        }
        
        return isValid;
    }

    // New method for saving updated items
    saveUpdatedItems(updatedItems, isSubmit) {
        saveChecklistItems({ 
            checklistItems: updatedItems, 
            recordId: this.recordId,
            bookingFormStatus: '',
            bookingFormRejection:'',
            isSubmit:isSubmit,
            checklistName:'Post Registration with Loan'
        })
        .then(() => {
            console.log('Checklist items saved successfully');
            
            // If it's a submit action, update the Opportunity record
            if(isSubmit) {
                console.log('Updating Opportunity record - EYI_Is_Post_Register_with_Loan_Checklist__c to true');
                return this.updateOpportunityRecord();
            }
        })
        .then(() => {
            // If submitted, update the local status
            if(isSubmit) {
                this.isPostRegisterLoanChecklistSubmitted = true;
                this.disableFields = true;
                this.disableSaveSubmit = true;
                this.disableSubmitOnly = true;
            }
            
            const successMessage = isSubmit ? 'Checklist submitted successfully' : 'Checklist updated successfully';
            this.showToast('Success', successMessage, 'success');
            this.resetComponentState();
            this.refreshData();
        })
        .catch((error) => {
            console.error('Error saving checklist items: ', error);
            const errorMessage = error.body ? error.body.message : error.message;
            this.showToast('Error', 'Error saving checklist: ' + errorMessage, 'error');
        });
    }

    // Update the submitExistingChecklist method
    submitExistingChecklist() {
        let isValid = this.validateExistingChecklistItems();
        
        if(isValid){
            submitChecklistItems({ 
                recordId: this.recordId,
                isSubmit: true,
                checkListLabel:'Post Registration with Loan'
            })
            .then(() => {
                console.log('Checklist items submitted successfully');
                console.log('Updating Opportunity record - EYI_Is_Post_Register_with_Loan_Checklist__c to true');
                return this.updateOpportunityRecord();
            })
            .then(() => {
                // Update the local status
                this.isPostRegisterLoanChecklistSubmitted = true;
                this.disableFields = true;
                this.disableSaveSubmit = true;
                this.disableSubmitOnly = true;
                
                this.showToast('Success', 'Checklist submitted successfully', 'success');
                this.resetComponentState();
                this.refreshData();
            })
            .catch((error) => {
                console.error('Error submitting checklist items: ', error);
                const errorMessage = error.body ? error.body.message : error.message;
                this.showToast('Error', 'Error submitting checklist: ' + errorMessage, 'error');
            });
        }
    }

    // New method to update Opportunity record
    updateOpportunityRecord() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[POST_REGISTER_LOAN_CHECKLIST_FIELD.fieldApiName] = true;

        const recordInput = { fields };

        return updateRecord(recordInput)
            .then(() => {
                console.log('Opportunity record updated successfully');
            })
            .catch(error => {
                console.error('Error updating Opportunity record: ', error);
                throw error; // Re-throw to be caught by the calling method
            });
    }

    // New method to reset component state
    resetComponentState() {
        this.questions = [];
        this.checklistItems = [];
        this.welcomeCallQuestions = [];
        this.answers = {};
        this.showCancelBtn = false;
        this.disableSubmitOnly = true; // Default to disabled
    }

    // New method to refresh data
    refreshData() {
        this.fetchOpportunityName();
        this.fetchChecklistItems();
        // Remove location.reload() as it's not recommended in LWC
    }

    // Enhanced showToast method with better error handling
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleCancel(){
        this.showCancelBtn = false;
        this.answers = {};
        this.resetComponentState();
        this.fetchChecklistItems();
    }

    // Opportunity display info getter
    get opportunityDisplayInfo() {
        if (this.opportunityDetails && this.opportunityDetails.Id) {
            return {
                name: this.opportunityDetails.Name || 'Opportunity Record',
                stageName: this.opportunityDetails.StageName || '',
                amount: this.opportunityDetails.Amount || '',
                closeDate: this.opportunityDetails.CloseDate ? new Date(this.opportunityDetails.CloseDate).toLocaleDateString() : '',
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

    // Add click handlers for navigation links
    handleOpportunityLinkClick(event) {
        event.preventDefault();
        window.open(this.opportunityDisplayInfo.url, '_blank');
    }

    handleRECLinkClick(event) {
        event.preventDefault();
        window.open(this.recDisplayInfo.url, '_blank');
    }

    handleBrokerageLinkClick(event) {
        event.preventDefault();
        window.open(this.brokerageDisplayInfo.url, '_blank');
    }

    // Add getter methods to show/hide buttons based on submission status
    get showSaveButton() {
        return !this.disableFields && !this.isPostRegisterLoanChecklistSubmitted;
    }

    get showSubmitButton() {
        return !this.disableFields && !this.isPostRegisterLoanChecklistSubmitted;
    }

    get showCancelBtn() {
        return this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0 && !this.disableFields && !this.isPostRegisterLoanChecklistSubmitted;
    }


    @api recId; // Set this from parent or after fetching REC Id
    bankDetails = [];
    bankError;

    @wire(getBankDetailsByREC, { recId: '$recId' })
    wiredBankDetails({ error, data }) {
        if (data) {
            // Add url property dynamically for each bank
            this.bankDetails = data.map(bank => ({
                ...bank,
                url: `/${bank.Id}`
            }));
            this.bankError = undefined;
            console.log('Bank details fetched:', JSON.stringify(this.bankDetails));
        } else if (error) {
            this.bankError = error;
            this.bankDetails = undefined;
            console.error('Error fetching bank details:', error);
        }
    }

    getBankUrl() {
        return (bankId) => `/${bankId}`;
    }

    get activeBankNames() {
        if (this.bankDetails && this.bankDetails.length > 0) {
            return this.bankDetails
                .filter(bank => !!bank.EYI_Bank_Name__c)
                .map(bank => ({
                    name: bank.EYI_Bank_Name__c,
                    url: '/' + bank.Id
                }));
        }
        return [];
    }

    get hasBankDetails() {
        return Array.isArray(this.bankDetails) && this.bankDetails.length > 0;
    }

    // Bank details display info getter
    get bankDetailsDisplayInfo() {
        if (this.hasBankDetails) {
            return this.bankDetails.map(bank => ({
                name: bank.EYI_Bank_Name__c || 'Bank Record',
                accountNumber: bank.EYI_Account_Number__c || '',
                ifscCode: bank.EYI_IFSC_Code__c || '',
                bankBranch: bank.EYI_Bank_Branch__c || '',
                accountType: bank.EYI_Account_Type__c || '',
                branchAddress: bank.EYI_Branch_Address__c || '',
                createdDate: bank.CreatedDate ? new Date(bank.CreatedDate).toLocaleDateString() : '',
                url: `/${bank.Id}`
            }));
        }
        return [];
    }

    // Add click handler for bank links
    handleBankLinkClick(event) {
        event.preventDefault();
        const bankId = event.target.dataset.bankId;
        if (bankId) {
            window.open(`/${bankId}`, '_blank');
        }
    }

    // Add method to get formatted bank names for display (similar to invoice checklist)
    get formattedBankNames() {
        if (this.activeBankNames && this.activeBankNames.length > 0) {
            const bankNames = this.activeBankNames.map(bank => bank.name);
            let formattedBanks = '';
            
            for (let i = 0; i < bankNames.length; i += 2) {
                const bank1 = bankNames[i];
                const bank2 = bankNames[i + 1];
                
                if (bank2) {
                    formattedBanks += `${bank1}, ${bank2}\n`;
                } else {
                    formattedBanks += `${bank1}`;
                }
            }
            
            return formattedBanks.trim();
        }
        return 'Not Available';
    }
}