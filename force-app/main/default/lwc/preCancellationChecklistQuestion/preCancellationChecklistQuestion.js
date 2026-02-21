import { LightningElement,api,track,wire } from 'lwc';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
// Fix: Change the import to match what you're using in the code
import submitChecklistItems from '@salesforce/apex/ChecklistQuestionController.submitChecklistCancellationItems';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItemsCancellation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getBankDetailsByREC from '@salesforce/apex/ChecklistQuestionController.getBankDetailsByREC';
import getRECDetails from '@salesforce/apex/ChecklistQuestionController.getRECDetails';
import getBrokerageDetails from '@salesforce/apex/ChecklistQuestionController.getBrokerageDetails';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';

const FIELDS = ['Opportunity.Name'];

export default class PreCancellationChecklistQuestion extends LightningElement {

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

    @track disableFields;
    @track disableSaveSubmit = false;
    @track isChecklistCompleted = false;
    @track EYI_IsPreCancellationChecklistSubmitted__c = false;
    userId = Id;
    userName;
    userRoleName;
    userProfile
    showCancelBtn = false;
    
    // Loading spinner properties
    @track isLoading = false;
    @track loadingMessage = '';

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
                     console.log('result.EYI_IsPreCancellationChecklistSubmitted__c : '+result.EYI_IsPreCancellationChecklistSubmitted__c);
                    
                    // Store the full opportunity details
                    this.opportunityDetails = result;
                    
                    if(result.StageName == 'Walk-in' || (!this.userRoleName.includes('Relationship Manager') && !this.userRoleName.includes('Sourcing Manager') ) ){
                        console.log('yes');
                        this.disableFields = true; 
                     } else if(this.userRoleName.includes('Relationship Manager') || this.userRoleName.includes('Sourcing Manager') ){
                         console.log('yes1');
                         this.disableFields = false;
                     }
                     if(this.userProfile == 'System Administrator' || this.userName == 'CRM Admin'){
                        console.log('yes2');
                        this.disableFields = false;  
                    }
                    
                    if(result.EYI_IsPreCancellationChecklistSubmitted__c == true){
                        console.log('Pre Cancellation checklist is already submitted - disabling submit');
                        this.EYI_IsPreCancellationChecklistSubmitted__c = true;
                    } else {
                        this.EYI_IsPreCancellationChecklistSubmitted__c = false;
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
                        this.recDetails = result; // Store full record
                        this.recId = result.Id; // <-- Set recId here for bank details wire
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
                        this.checklistItems = result.filter(item => item.Type__c === "Pre Cancellation");
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
                        question.Type__c === 'Pre Cancellation'
                    );
                    // For new questions, buttons should be enabled
                    this.disableSaveSubmit = false;
                    this.processQuestionsAndAnswers();
                })
                .catch((error) => {
                    console.error('Error fetching default questions:', error);
                });
        }
    
        processQuestionsAndAnswers() {
            if (this.checklistItems.length > 0) {
                this.welcomeCallQuestions = this.checklistItems.filter(
                    (item) => item.Type__c === 'Pre Cancellation'
                );
                
                // Check if all checkboxes are already checked (Valid__c = true)
                this.checkIfAllValidCheckboxesChecked();
               
            } else if (this.questions.length > 0) {
                this.questions.forEach(question => {
                            if (!question.CreatedBy) {
                                question.CreatedBy = { Name: '' }; // Replace 'desiredName' with the actual name
                            }
                        });
                this.welcomeCallQuestions = this.questions.filter(
                    (question) => question.Type__c === 'Pre Cancellation'
                );
                
                // For new questions, buttons should be enabled
                this.disableSaveSubmit = false;
                
            } else {
                console.error('Neither checklistItems nor questions have data.');
            }
            console.log('Pre Cancellation Questions:', JSON.stringify(this.welcomeCallQuestions));
        }

        // Same method as PostCancellationwithLoanChecklist with updated validation logic
        checkIfAllValidCheckboxesChecked() {
            if (this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0) {
                let allItemsValid = true;
                let hasAnyChanges = Object.keys(this.answers).length > 0;
                
                this.welcomeCallQuestions.forEach(item => {
                    const answer = this.answers[item.Id];
                    
                    // Get current valid state (from answer or original item)
                    const currentValid = answer && answer.isValid !== undefined ? answer.isValid : item.Valid__c;
                    
                    // If any item is not valid, set allItemsValid to false
                    if (currentValid !== true) {
                        allItemsValid = false;
                    }
                });
                
                // FIXED: Disable submit button when NOT all checkboxes are checked
                if (!allItemsValid) {
                    this.disableSaveSubmit = true; // Disable submit when not all are valid
                    this.isChecklistCompleted = false;
                    console.log('Not all checkboxes are checked - disabling submit button');
                } else {
                    this.disableSaveSubmit = false; // Enable submit when all are valid
                    this.isChecklistCompleted = true;
                    console.log('All checkboxes are checked - enabling submit button');
                }
                
                // Only disable if registration checklist is submitted AND all are valid from DATABASE (not user changes)
                if (this.EYI_IsPreCancellationChecklistSubmitted__c && allItemsValid && !hasAnyChanges) {
                    const allValidFromDatabase = this.welcomeCallQuestions.every(item => item.Valid__c === true);
                    
                    if (allValidFromDatabase) {
                        this.disableSaveSubmit = true;
                        console.log('All items are already valid in database and checklist is submitted - disabling submit button');
                    }
                }
            }
        }

        // Replace the existing updateSaveSubmitButtonState method  
updateSaveSubmitButtonState() {
    if (this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0) {
        let allItemsValid = true;
        let hasAnyChanges = Object.keys(this.answers).length > 0;
        
        this.welcomeCallQuestions.forEach(item => {
            const answer = this.answers[item.Id];
            
            // Get current valid state (from answer or original item)
            const currentValid = answer && answer.isValid !== undefined ? answer.isValid : item.Valid__c;
            
            // Check if item is valid
            if (currentValid !== true) {
                allItemsValid = false;
            }
        });
        
        console.log('All items valid:', allItemsValid);
        console.log('Has changes:', hasAnyChanges);
        console.log('Pre Cancellation checklist submitted:', this.EYI_IsPreCancellationChecklistSubmitted__c);
        
        // FIXED: Disable submit button when NOT all checkboxes are checked
        if (!allItemsValid) {
            this.disableSaveSubmit = true; // Disable submit when not all are checked
            this.isChecklistCompleted = false;
            console.log('Not all checkboxes are checked - disabling submit button');
        } else {
            // All checkboxes are checked - check other conditions
            if (this.EYI_IsPreCancellationChecklistSubmitted__c && !hasAnyChanges) {
                const allValidFromDatabase = this.welcomeCallQuestions.every(item => item.Valid__c === true);
                
                if (allValidFromDatabase) {
                    this.disableSaveSubmit = true;
                    this.isChecklistCompleted = true;
                    console.log('All items were already valid in database and checklist is submitted - disabling submit button');
                    return;
                }
            }
            
            // Enable submit when all checkboxes are checked
            this.disableSaveSubmit = false;
            this.isChecklistCompleted = true;
            console.log('All checkboxes are checked - enabling submit button');
        }
    }
}

        handleInputChange(event) {
            this.showCancelBtn = true;
            const { name, value, dataset, checked, type } = event.target;
            const questionId = dataset.id;
            console.log('questionId : '+questionId);
            console.log('name: ', name, 'value: ', value, 'checked: ', checked, 'type: ', type);
            
            if (!this.answers[questionId]) {
                this.answers[questionId] = {};
            }
            
            if (type === 'checkbox') {
                // Fix: Use consistent naming for the checkbox field
                this.answers[questionId]['isValid'] = checked;
                console.log('Checkbox updated - isValid:', checked);
            } else if (type === 'select') {
                this.answers[questionId][name] = value;
            } else {
                this.answers[questionId][name] = value;
            }
            
            // IMPORTANT: Call the validation method after any input change
            this.updateSaveSubmitButtonState();
            
            console.log('Updated answers: ', JSON.stringify(this.answers));
        }

        // Same method as PostCancellationwithLoanChecklist with improved validation logic
        updateSaveSubmitButtonState() {
            if (this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0) {
                let allItemsComplete = true;
                let allItemsValid = true;
                let hasAnyChanges = Object.keys(this.answers).length > 0;
                
                this.welcomeCallQuestions.forEach(item => {
                    const answer = this.answers[item.Id];
                    
                    // Get current valid state (from answer or original item)
                    const currentValid = answer && answer.isValid !== undefined ? answer.isValid : item.Valid__c;
                    
                    // Get current remark (from answer or original item)
                    const currentRemark = answer && answer.remark !== undefined ? answer.remark : item.Remarks__c;
                    
                    // Check if item is valid
                    if (currentValid !== true) {
                        allItemsValid = false;
                    }
                    
                    // Check if item is complete (valid OR invalid with remarks)
                    if (currentValid === false && (!currentRemark || currentRemark.trim() === '')) {
                        allItemsComplete = false;
                    }
                });
                
                console.log('All items valid:', allItemsValid);
                console.log('All items complete:', allItemsComplete);
                console.log('Has changes:', hasAnyChanges);
                console.log('Registration checklist submitted:', this.EYI_IsPreCancellationChecklistSubmitted__c);
                
                // UPDATED: Only check registration submission restriction if all are valid from database (not user changes)
                if (this.EYI_IsPreCancellationChecklistSubmitted__c && allItemsValid && hasAnyChanges) {
                    // Check if all items were already valid in database before user changes
                    const allValidFromDatabase = this.welcomeCallQuestions.every(item => item.Valid__c === true);
                    
                    if (allValidFromDatabase) {
                        this.disableSaveSubmit = true;
                        this.isChecklistCompleted = true;
                        console.log('All items were already valid in database and registration checklist is submitted - disabling save/submit buttons');
                        this.showToast('Info', 'Cannot modify - Registration checklist has already been submitted and all items are already marked as valid', 'info');
                        return;
                    }
                }
                
                // Standard button state logic - allow users to make changes normally
                if (hasAnyChanges) {
                    // If user is making changes, enable the buttons
                    this.disableSaveSubmit = false;
                    this.isChecklistCompleted = false;
                } else if (allItemsValid || allItemsComplete) {
                    // If all items are complete and no changes, disable buttons
                    this.disableSaveSubmit = true;
                    this.isChecklistCompleted = true;
                    console.log('All items are complete and no changes - disabling save/submit buttons');
                } else {
                    this.disableSaveSubmit = false;
                    this.isChecklistCompleted = false;
                }
            }
        }

        handleSave(event) {
            let isValid = true;
            const label = event.target.label;
            let isSubmit = false;
            
            // Check if buttons are disabled due to Valid checkbox being true
            if (this.disableSaveSubmit) {
                this.showToast('Error', 'Cannot save or submit when all checklist items are marked as valid', 'error');
                return;
            }
            
            // Check if fields are disabled - if so, don't allow save/submit
            if (this.disableFields) {
                this.showToast('Error', 'You do not have permission to save or submit this checklist', 'error');
                return;
            }
            
            // REMOVE this validation from here as it's now handled in the checkbox validation methods
            // if(label == 'Submit' && this.isRegistrationChecklistSubmitted){
            //     this.showToast('Error', 'Cannot submit - Registration checklist has already been submitted', 'error');
            //     return;
            // }
            
            if(label == 'Submit'){
                console.log('inside Submit if');
                isSubmit = true;
                
                this.isLoading = true;
                this.loadingMessage = 'Submitting checklist...';
            } else {
                this.isLoading = true;
                this.loadingMessage = 'Saving checklist...';
            }
            
            // Handle existing checklist items first
            if(this.checklistItems.length > 0 ){
                this.updateChecklistItemsFromAnswers(isSubmit);
                return; // Exit here to prevent processing questions as well
            }
            
            // Only process questions if there are no existing checklist items
            if(this.questions.length > 0){
                if (isSubmit == true) {
                    // Enhanced validation for submit
                    let hasAnyAnswer = false;
                    
                    this.questions.forEach((question) => {
                        const answer = this.answers[question.Id];
                        if (answer !== undefined) {
                            hasAnyAnswer = true;
                            const remark = answer.remark;
                            const isValidCheckbox = answer.isValid;

                            if (!isValidCheckbox && !remark) {
                                isValid = false;
                                this.isLoading = false;
                                this.showToast('Error', 'Please provide Remarks when item is not valid', 'warning');
                                return;
                            }
                        } else {
                            isValid = false;
                            this.isLoading = false;
                            this.showToast('Error', 'Please fill all required fields', 'warning');
                            return;
                        }
                    });
                    
                    // Check if at least one question has been answered
                    if (!hasAnyAnswer) {
                        isValid = false;
                        this.isLoading = false;
                        this.showToast('Error', 'Please answer at least one question before submitting', 'warning');
                        return;
                    }
                }
                
                if (isSubmit == false) {
                    // Enhanced validation for save
                    let hasValidData = false;
                    
                    this.questions.forEach((question) => {
                        const answer = this.answers[question.Id];
                        
                        if (answer !== undefined) {
                            const remark = answer.remark;
                            const isValidCheckbox = answer.isValid;
                            
                            // Check if there's any meaningful data to save
                            if (remark !== undefined || isValidCheckbox !== undefined) {
                                hasValidData = true;
                            }

                            if (!isValidCheckbox && !remark) {
                                isValid = false;
                                this.isLoading = false;
                                this.showToast('Error', 'Please provide Remarks when item is not valid', 'warning');
                                return;
                            }
                        }
                    });
                    
                    // Check if there's any data to save
                    if (!hasValidData) {
                        this.isLoading = false;
                        this.showToast('Info', 'No changes to save', 'info');
                        return;
                    }
                }

                if (isValid) {
                    const checklistItems = this.questions.map((question) => {
                        const answer = this.answers[question.Id] || {}; // Fallback to an empty object if not found
                        return {
                            Opportunity__c: this.recordId,
                            Question__c: question.Question__c,
                            Valid__c: answer.isValid || false, // Add Valid__c checkbox field
                            Remarks__c: answer.remark || '', 
                            Type__c: question.Type__c
                        };
                    });
                    console.log('checklistItems Before Save: ', JSON.stringify(checklistItems));

                    // Check if all checkboxes will be true after save/submit
                    const allCheckboxesWillBeTrue = checklistItems.every(item => item.Valid__c === true);
                    console.log('All checkboxes will be true:', allCheckboxesWillBeTrue);

                    saveChecklistItems({ 
                        checklistItems, 
                        recordId: this.recordId,
                        isSubmit:isSubmit,
                        checklistName:'Pre Cancellation Checklist',
                        updateRegistrationFlag: isSubmit && allCheckboxesWillBeTrue // Only update if submitting AND all checkboxes are true
                    })
                    .then((result) => {
                        console.log('Checklist items saved successfully', result);
                        const successMessage = isSubmit ? 'Checklist submitted successfully' : 'Checklist saved successfully';
                        this.showToast('Success', successMessage, 'success');
                        
                        // After successful save, refetch the data to get the newly created records
                        this.answers = {};
                        this.showCancelBtn = false;
                        this.isLoading = false;
                        this.fetchChecklistItems();
                    })
                    .catch((error) => {
                        console.error('Error saving checklist items: ', error);
                        this.isLoading = false;
                        this.showToast('Error', 'Error saving checklist items: ' + (error.body?.message || error.message), 'error');
                    });
                } else {
                    this.isLoading = false;
                }
            } else {
                this.isLoading = false;
            }
        }

        updateChecklistItemsFromAnswers(isSubmit) {
            console.log('isSubmit '+isSubmit);
            let isValid = true;
            let validationErrors = [];
            
            // Check if buttons are disabled due to Valid checkbox being true
            if (this.disableSaveSubmit) {
                this.isLoading = false;
                this.showToast('Error', 'Cannot save or submit when all checklist items are marked as valid', 'error');
                return;
            }
            
            // Check if fields are disabled - if so, don't allow save/submit
            if (this.disableFields) {
                this.isLoading = false;
                this.showToast('Error', 'You do not have permission to save or submit this checklist', 'error');
                return;
            }
            
            // REMOVE this validation from here as it's now handled in the checkbox validation methods
            // if (isSubmit && this.isRegistrationChecklistSubmitted) {
            //     this.isLoading = false;
            //     this.showToast('Error', 'Cannot submit - Registration checklist has already been submitted', 'error');
            //     return;
            // }
            
            // Create a map to avoid duplicates
            const itemsToUpdate = new Map();
            
            Object.keys(this.answers).forEach((answerId) => {
                const answer = this.answers[answerId];
                const existingItem = this.checklistItems.find(item => item.Id === answerId);
                
                if (existingItem) {
                    const updatedItem = {
                        ...existingItem,
                        Valid__c: answer.isValid !== undefined ? answer.isValid : existingItem.Valid__c,
                        Remarks__c: answer.remark !== undefined ? answer.remark : existingItem.Remarks__c,
                    };
                    itemsToUpdate.set(answerId, updatedItem);
                    console.log('Updated item for ID ' + answerId + ': ', JSON.stringify(updatedItem));
                }
            });
            
            const updatedItems = Array.from(itemsToUpdate.values());
            console.log('Updated items before save: ', JSON.stringify(updatedItems));
            
            // Enhanced validation logic for submit
            if (isSubmit) {
                let hasChanges = false;
                
                this.checklistItems.forEach((question) => {
                    const updatedItem = itemsToUpdate.get(question.Id);
                    const remark = updatedItem ? updatedItem.Remarks__c : question.Remarks__c;
                    const isValidCheckbox = updatedItem ? updatedItem.Valid__c : question.Valid__c;

                    // Check if there are any changes or existing data
                    if (remark || isValidCheckbox !== undefined) {
                        hasChanges = true;
                    }

                    if (!isValidCheckbox && !remark) {
                        isValid = false;
                        validationErrors.push('Please provide Remarks when item is not valid');
                    }
                });
                
                // Check if there are any changes to submit
                if (!hasChanges) {
                    isValid = false;
                    validationErrors.push('Please make changes before submitting');
                }
            } else {
                // Enhanced validation logic for save only
                let hasValidChanges = false;
                
                updatedItems.forEach((question) => {
                    const remark = question.Remarks__c;
                    const isValidCheckbox = question.Valid__c;

                    // Check if there are meaningful changes
                    if (remark || isValidCheckbox !== undefined) {
                        hasValidChanges = true;
                    }

                    if (!isValidCheckbox && !remark) {
                        isValid = false;
                        validationErrors.push('Please provide Remarks when item is not valid');
                    }
                });
                
                // Check if there are valid changes to save
                if (!hasValidChanges) {
                    this.isLoading = false;
                    this.showToast('Info', 'No changes to save', 'info');
                    return;
                }
            }

            if (!isValid) {
                this.isLoading = false;
                this.showToast('Error', validationErrors[0], 'warning');
                return;
            }

            // Check if all checkboxes will be true after the update
            const allCheckboxesWillBeTrue = this.checkIfAllCheckboxesWillBeTrue(itemsToUpdate);
            console.log('All checkboxes will be true after update:', allCheckboxesWillBeTrue);

            if (isSubmit) {
                console.log('Inside Submit checklist');
                
                // First save any updated items, then submit
                if (updatedItems.length > 0) {
                    saveChecklistItems({ 
                        checklistItems: updatedItems, 
                        recordId: this.recordId,
                        isSubmit: false, // Save first, don't submit yet
                        checklistName:'Pre Cancellation Checklist',
                        updateRegistrationFlag: false // Don't update flag on save
                    })
                    .then((result) => {
                        console.log('Checklist items saved before submit', result);
                        // Now submit the checklist
                        return submitChecklistItems({ 
                            recordId: this.recordId,
                            isSubmit: true,
                            checkListLabel: 'Pre Cancellation',
                            updateRegistrationFlag: allCheckboxesWillBeTrue // Only update if all checkboxes are true
                        });
                    })
                    .then((result) => {
                        console.log('Checklist items submitted successfully', result);
                        this.showToast('Success', 'Checklist Submitted successfully', 'success');
                        
                        this.disableFields = true;
                        this.answers = {};
                        this.showCancelBtn = false;
                        this.isLoading = false;
                        // Force reload after submit
                        window.location.reload();
                    })
                    .catch((error) => {
                        console.error('Error submitting checklist items: ', error);
                        this.isLoading = false;
                        this.showToast('Error', 'Error submitting checklist items: ' + (error.body?.message || error.message), 'error');
                    });
                } else {
                    // No updates needed, just submit directly
                    submitChecklistItems({ 
                        recordId: this.recordId,
                        isSubmit: true,
                        checkListLabel: 'Pre Cancellation',
                        updateRegistrationFlag: allCheckboxesWillBeTrue // Only update if all checkboxes are true
                    })
                    .then((result) => {
                        console.log('Checklist items submitted successfully', result);
                        this.showToast('Success', 'Checklist Submitted successfully', 'success');
                        
                        this.disableFields = true;
                        this.answers = {};
                        this.showCancelBtn = false;
                        this.isLoading = false;
                        // Force reload after submit
                        window.location.reload();
                    })
                    .catch((error) => {
                        console.error('Error submitting checklist items: ', error);
                        this.isLoading = false;
                        this.showToast('Error', 'Error submitting checklist items: ' + (error.body?.message || error.message), 'error');
                    });
                }
            } else {
                // Save logic
                if (updatedItems.length > 0) {
                    console.log('Inside Update Item');
                    
                    saveChecklistItems({ 
                        checklistItems: updatedItems, 
                        recordId: this.recordId,
                        isSubmit: false,
                        checklistName:'Pre Cancellation Checklist',
                        updateRegistrationFlag: false // Never update flag on save, only on submit
                    })
                    .then((result) => {
                        console.log('Checklist items saved successfully', result);
                        this.showToast('Success', 'Checklist updated successfully', 'success');
                        
                        this.answers = {};
                        this.showCancelBtn = false;
                        this.isLoading = false;
                        // Force reload after save
                        window.location.reload();
                    })
                    .catch((error) => {
                        console.error('Error saving checklist items: ', error);
                        this.isLoading = false;
                        this.showToast('Error', 'Error saving checklist items: ' + (error.body?.message || error.message), 'error');
                    });
                } else {
                    this.isLoading = false;
                    this.showToast('Info', 'No changes to save', 'info');
                }
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
        
        // Reset form fields to their original values by re-processing the data
        this.processQuestionsAndAnswers();
    }

    // Update the existing getter method
    get isButtonDisabled() {
        // Only disable when Pre Cancellation checklist is submitted
        return this.EYI_IsPreCancellationChecklistSubmitted__c || this.disableFields;
    }
    
    // Add a separate getter for submit button specifically
    get isSubmitButtonDisabled() {
        // Disable submit if fields are disabled for this user
        if (this.disableFields) {
            return true;
        }
        
        // Check if all checkboxes are checked
        let allCheckboxesChecked = false;
        
        if (this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0) {
            allCheckboxesChecked = this.welcomeCallQuestions.every(item => {
                const answer = this.answers[item.Id];
                const currentValid = answer && answer.isValid !== undefined ? answer.isValid : item.Valid__c;
                return currentValid === true;
            });
        }
        
        // FIXED: Disable submit button if NOT all checkboxes are checked
        if (!allCheckboxesChecked) {
            return true; // Disable when not all are checked
        }
        
        // Check if registration checklist is submitted and all are valid from database
        if (this.EYI_IsPreCancellationChecklistSubmitted__c && this.welcomeCallQuestions && this.welcomeCallQuestions.length > 0) {
            const allValidFromDatabase = this.welcomeCallQuestions.every(item => item.Valid__c === true);
            const hasAnyChanges = Object.keys(this.answers).length > 0;
            
            // Only disable if all are valid from database and no user changes
            if (allValidFromDatabase && !hasAnyChanges) {
                return true;
            }
        }
        
        // Enable submit when all checkboxes are checked
        return false;
    }

    // handlePrint(){

    //     const opportunityId = this.recordId;  
    //     const oppName = 'Pre Cancellation - '+this.opportunityName+ ' - ';
    //     const opportunityName = encodeURIComponent(oppName); 
    //     const todayDate = new Date();
    //     const opportunityCreatedDate = encodeURIComponent(todayDate.toISOString()); 
    //     const url = `/apex/APXTConga4__Conga_Composer?SolMgr=1
    //     &serverUrl={!API.Partner_Server_URL_520}
    //     &Id=${opportunityId}&QueryId=[BookingApp]0Q_056MAG472677,
    //     [oppo]0Q_058MAG111577,
    //     [WelcomeCheck]0Q_059MAG370188
    //     &TemplateId=0T_058MAG897287
    //     &OFN=${opportunityName}+${opportunityCreatedDate}
    //     &DefaultPDF=1
    //     &PDFA=1a
    //     &DS7=11`;
    //     console.log('Generated URL: ' + url);
    //     window.open(url, '_self');
    //                         }

    // Add new method to check if all checkboxes are checked
    areAllCheckboxesChecked() {
        if (this.checklistItems.length > 0) {
            // Check existing checklist items
            return this.checklistItems.every(item => {
                const answer = this.answers[item.Id];
                const currentValid = answer && answer.isValid !== undefined ? answer.isValid : item.Valid__c;
                return currentValid === true;
            });
        } else if (this.questions.length > 0) {
            // Check new questions
            return this.questions.every(question => {
                const answer = this.answers[question.Id];
                return answer && answer.isValid === true;
            });
        }
        return false;
    }

    // Add new method to check if all checkboxes will be true after update
    checkIfAllCheckboxesWillBeTrue(itemsToUpdateMap) {
        if (this.checklistItems.length > 0) {
            return this.checklistItems.every(item => {
                // Check if this item is being updated
                const updatedItem = itemsToUpdateMap.get(item.Id);
                if (updatedItem) {
                    // Use the updated value
                    return updatedItem.Valid__c === true;
                } else {
                    // Use the existing value
                    return item.Valid__c === true;
                }
            });
        }
        return false;
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
        // You can add custom navigation logic here if needed
        window.open(this.opportunityDisplayInfo.url, '_blank');
    }

    handleRECLinkClick(event) {
        event.preventDefault();
        // You can add custom navigation logic here if needed
        window.open(this.recDisplayInfo.url, '_blank');
    }

    handleBrokerageLinkClick(event) {
        event.preventDefault();
        // You can add custom navigation logic here if needed
        window.open(this.brokerageDisplayInfo.url, '_blank');
    }

    // Bank details properties
    @api recId; // Set this from parent or after fetching REC Id
    bankDetails = [];
    bankError;

    // Wire service for bank details
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

    // Bank details helper methods
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
                accountHolderName: bank.EYI_Account_Holder_Name__c || '',
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

    // Add method to get formatted bank names for display
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

    // Add this method if it doesn't exist (referenced in fetchRECDetails)
    updateStaticQuestionsWithDynamicValues() {
        // Add any logic needed to update questions with dynamic values from REC
        console.log('Updating static questions with dynamic values from REC');
        
        // Example: Update questions with REC and bank data if needed
        if (this.recDetails) {
            console.log('REC details available for dynamic updates');
        }
        
        if (this.hasBankDetails) {
            console.log('Bank details available for dynamic updates');
        }
    }

}