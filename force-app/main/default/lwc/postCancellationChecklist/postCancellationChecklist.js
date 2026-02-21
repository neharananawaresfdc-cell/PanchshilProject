import { LightningElement,api,track,wire } from 'lwc';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
import submitChecklistItems from '@salesforce/apex/ChecklistQuestionController.submitChecklistCancellationItems';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItemsCancellation';
import getRECDetails from '@salesforce/apex/ChecklistQuestionController.getRECDetails';
import getBrokerageDetails from '@salesforce/apex/ChecklistQuestionController.getBrokerageDetails';
import updateOpportunityPostCancellationFields from '@salesforce/apex/ChecklistQuestionController.updateOpportunityPostCancellationFields';

import getBankDetailsByREC from '@salesforce/apex/ChecklistQuestionController.getBankDetailsByREC';

import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';

const FIELDS = ['Opportunity.Name'];

export default class PostCancellationChecklist extends LightningElement {

    @api recordId;
    @track checklistItems = [];
    @track questions = [];
    @track welcomeCallQuestions = []; 
    @track showPrint = false;
    @track isLoading = true; // Add loading spinner property
    opportunityName
    checkedBy
    @track categoryOptions = [
        { label: 'Critical', value: 'Critical' },
        { label: 'Non-Critical', value: 'Non-Critical' }
    ];
    @track statusOptions = [
        { label: 'Valid', value: 'Valid' },
        { label: 'Invalid', value: 'Invalid' }
    ];
    @track answers = {};

    @track disableFields = true;
    @track disableSubmit = true;
    @track disableSaveSubmit = false;
    @track disableSave = true;

    userId = Id;
    userName;
    userRoleName;
    userProfile
    showCancelBtn = false;

    // Add new property to track if all boxes are already checked
    @track allBoxesAlreadyChecked = false;

    // Add this property to track if checklist is already submitted
    @track isChecklistSubmitted = false;

    // Add a new property to track submit button state separately
    @track disableSubmitButton = true;

    // Add these properties for related information
    @track opportunityDetails = null;
    @track recDetails = null;
    @track brokerageDetails = null;

    connectedCallback(){
        this.isLoading = true; // Start loading when component loads
    }
    
    @wire(getRecord, { recordId: Id, fields: [Name, RoleName,ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
            this.isLoading = false; // Stop loading on error
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
                    // Store the full opportunity details
                    this.opportunityDetails = result;
                    this.opportunityName = result.Name;
                    
                    // Check if checklist is already submitted
                    this.isChecklistSubmitted = result.EYI_IsPostCancellationChecklistSubmitted__c || false;
                    
                    // Set form disabled state based on submission status
                    this.disableSaveSubmit = this.isChecklistSubmitted;
                    this.disableFields = this.isChecklistSubmitted;
                    
                    console.log('Opportunity Name:', this.opportunityName);
                    console.log('Is Checklist Submitted:', this.isChecklistSubmitted);
                    
                    // Fetch REC and Brokerage details after Opportunity is loaded
                    this.fetchRECDetails();
                    this.fetchBrokerageDetails();
                    
                    // Fetch checklist items after getting opportunity details
                    this.fetchChecklistItems();
                })
                .catch(error => {
                    console.error('Error fetching opportunity record:', error);
                    this.isLoading = false; // Stop loading on error
                    // If error fetching opportunity, still try to fetch checklist items
                    this.fetchChecklistItems();
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
                    console.log('All Checklist Items fetched:', JSON.stringify(result));
                    
                    // Filter for Post Cancellation type items
                    const postCancellationItems = result.filter(item => item.Type__c === "Post Cancellation");
                    
                    if (postCancellationItems.length === 0) {
                        console.log('No Post Cancellation checklist items found, calling fetchDefaultQuestions');
                        this.fetchDefaultQuestions();
                    } else {
                        // Store ALL Post Cancellation items, regardless of Valid__c status
                        this.checklistItems = postCancellationItems;
                        console.log('Post Cancellation checklist items found:', this.checklistItems.length);
                        this.showPrint = true;
                        this.processQuestionsAndAnswers();
                    } 
                } else {
                    console.log('No checklist items result, calling fetchDefaultQuestions');
                    this.fetchDefaultQuestions();
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
                        question.Type__c === 'Post Cancellation'
                    );
                    this.processQuestionsAndAnswers();
                })
                .catch((error) => {
                    console.error('Error fetching default questions:', error);
                    this.isLoading = false; // Stop loading on error
                });
        }
    
        processQuestionsAndAnswers() {
            if (this.checklistItems.length > 0) {
                // Show ALL checklist items of the correct type, regardless of Valid__c status
                this.welcomeCallQuestions = this.checklistItems.filter(
                    (item) => item.Type__c === 'Post Cancellation'
                );
                
                console.log('Processed checklist items (all):', JSON.stringify(this.welcomeCallQuestions));
               
            } else if (this.questions.length > 0) {
                
                this.questions.forEach(question => {
                    if (!question.CreatedBy) {
                        question.CreatedBy = { Name: '' };
                    }
                });

                // Show ALL questions of the correct type
                this.welcomeCallQuestions = this.questions.filter(
                    (question) => question.Type__c === 'Post Cancellation'
                );
                
                console.log('Processed questions (all):', JSON.stringify(this.welcomeCallQuestions));
                
            } else {
                console.error('Neither checklistItems nor questions have data.');
            }
            
            // Check if all boxes are already checked from existing records
            this.checkIfAllBoxesAlreadyChecked();
            
            // Check submit button state after processing questions
            this.checkSubmitButtonState();
            
            // Stop loading after processing is complete
            this.isLoading = false;
        }

        // Add new method to check if all boxes are already checked
        checkIfAllBoxesAlreadyChecked() {
            if (this.welcomeCallQuestions.length > 0) {
                // Only check for existing checklist items (not new questions)
                if (this.checklistItems.length > 0) {
                    // Check if all items have Valid__c as true (already checked)
                    this.allBoxesAlreadyChecked = this.welcomeCallQuestions.every(question => 
                        question.Valid__c === true
                    );
                } else {
                    // For new questions (not existing checklist items), don't mark as already checked
                    this.allBoxesAlreadyChecked = false;
                }
                
                console.log('All boxes already checked:', this.allBoxesAlreadyChecked);
                
                // If checklist is already submitted, keep form disabled
                if (this.isChecklistSubmitted) {
                    this.disableSaveSubmit = true;
                    this.disableFields = true;
                }
                // If all boxes are checked but not submitted, show info but don't disable
                else if (this.allBoxesAlreadyChecked) {
                    // Don't disable buttons, just track the state
                    console.log('All boxes checked but not submitted yet');
                }
            } else {
                this.allBoxesAlreadyChecked = false;
                // Only enable if checklist is not submitted
                if (!this.isChecklistSubmitted) {
                    this.disableSaveSubmit = false;
                }
            }
        }

        // Update checkSubmitButtonState method
        checkSubmitButtonState() {
            // If checklist is already submitted, keep buttons disabled
            if (this.isChecklistSubmitted) {
                this.disableSubmit = true;
                this.disableSave = true;
                this.disableSaveSubmit = true;
                this.disableSubmitButton = true;
                return;
            }
            
            // Check if all checkboxes are checked
            let allCheckboxesChecked = true;
            let hasExistingItems = this.welcomeCallQuestions.length > 0;
            
            if (hasExistingItems) {
                this.welcomeCallQuestions.forEach(question => {
                    const answer = this.answers[question.Id];
                    const isChecked = answer ? answer.valid : question.Valid__c;
                    
                    if (!isChecked) {
                        allCheckboxesChecked = false;
                    }
                });
                
                // Enable/disable Save Draft button (always allow save if there are items)
                this.disableSaveSubmit = false;
                
                // Enable/disable Submit button based on all checkboxes being checked
                this.disableSubmitButton = !allCheckboxesChecked;
                
                console.log('All checkboxes checked:', allCheckboxesChecked);
                console.log('Disable Submit Button:', this.disableSubmitButton);
            } else {
                this.disableSaveSubmit = true;
                this.disableSubmitButton = true;
            }
        }

        handleInputChange(event) {
            // If checklist is already submitted, prevent any changes
            if (this.isChecklistSubmitted) {
                this.showToast('Info', 'Checklist has already been submitted. No changes allowed.', 'info');
                return;
            }
            
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
            console.log('this.answers : '+JSON.stringify(this.answers));
            
            // Check if submit button should be enabled after each change
            this.checkSubmitButtonState();
        }

        // Update the handleSave method
        handleSave(event) {
            this.isLoading = true;
            
            let isValid = true;
            const label = event.target.label;
            let isSubmit = false;
            
            if(label == 'Submit'){
                console.log('inside Submit if');
                isSubmit = true;
                
                // Additional validation for submit - ensure all checkboxes are checked
                let allCheckboxesChecked = true;
                this.welcomeCallQuestions.forEach(question => {
                    const answer = this.answers[question.Id];
                    const isChecked = answer ? answer.valid : question.Valid__c;
                    
                    if (!isChecked) {
                        allCheckboxesChecked = false;
                    }
                });
                
                if (!allCheckboxesChecked) {
                    this.showToast('Error', 'All items must be checked before submitting the checklist.', 'error');
                    this.isLoading = false;
                    return;
                }
            }
            
            // Check if there are any changes made
            const hasChanges = Object.keys(this.answers).length > 0;
            
            // For new questions (no existing checklist items), require changes for save draft
            if (!hasChanges && this.checklistItems.length === 0 && !isSubmit) {
                this.showToast('Warning', 'No changes detected. Please make changes before saving.', 'warning');
                this.isLoading = false;
                return;
            }
            
            // Add validation for unchecked boxes requiring remarks
            if (isSubmit) {
                this.welcomeCallQuestions.forEach((question) => {
                    const answer = this.answers[question.Id];
                    const isChecked = answer ? answer.valid : question.Valid__c;
                    const remark = answer ? answer.remark : question.Remarks__c;
                    
                    // If checkbox is not checked, remark is mandatory
                    if (!isChecked && (!remark || remark.trim() === '')) {
                        isValid = false;
                        this.showToast('Error', 'Please provide remarks for unchecked items', 'error');
                    }
                });
            }

            if(this.checklistItems.length > 0 ){
                this.updateChecklistItemsFromAnswers(isSubmit, isValid);
            }
            else if(this.questions.length > 0 && isValid){
                // Validation for new questions
                if (isSubmit == true) {
                    this.questions.forEach((question) => {
                        const answer = this.answers[question.Id];
                        if (answer !== undefined) {
                            const isChecked = answer.valid;
                            const remark = answer.remark;
                            
                            // If checkbox is not checked, remark is mandatory
                            if (!isChecked && (!remark || remark.trim() === '')) {
                                isValid = false;
                                this.showToast('Error', 'Please provide remarks for unchecked items', 'error');
                            }
                        }
                    });
                }

                if (isValid) {
                    // Process ALL questions, not just those with answers
                    const checklistItems = this.questions.map((question) => {
                        const answer = this.answers[question.Id] || {};
                        return {
                            Opportunity__c: this.recordId,
                            Question__c: question.Question__c,
                            Status__c: (answer.valid !== undefined ? answer.valid : false) ? 'Valid' : 'Invalid',
                            Remarks__c: answer.remark || '', 
                            Category__c: answer.category || question.Category__c, 
                            Type__c: question.Type__c,
                            Valid__c: answer.valid !== undefined ? answer.valid : false
                        };
                    });
                    
                    console.log('checklistItems Before Save (ALL questions):', checklistItems);

                    saveChecklistItems({ 
                        checklistItems, 
                        recordId: this.recordId,
                        bookingFormStatus: '',
                        bookingFormRejection:'',
                        isSubmit:isSubmit,
                        checklistName:'Post Cancellation Checklist'
                    })
                    .then(() => {
                        console.log('Checklist items saved successfully');
                        const successMessage = isSubmit ? 'Checklist submitted successfully' : 'Checklist saved successfully';
                        this.showToast('Success', successMessage, 'success');
                        
                        // Only disable form and update opportunity record if it's a submit action
                        if (isSubmit) {
                            this.disableSaveSubmit = true;
                            this.disableFields = true;
                            this.disableSubmitButton = true;
                            this.updateOpportunityRecord();
                        }
                        
                        // Clear answers but don't clear questions/items until refresh
                        this.answers = {};
                        this.showCancelBtn = false;
                        
                        // Stop loading before fetching new data
                        this.isLoading = false;
                        
                        // Refresh the data to show updated items
                        this.fetchOpportunityName();
                        
                        // Only reload on submit
                        if (isSubmit) {
                            setTimeout(() => {
                                location.reload();
                            }, 1000);
                        }
                    })
                    .catch((error) => {
                        console.error('Error saving checklist items: ', error);
                        const errorMessage = isSubmit ? 'Error submitting checklist' : 'Error saving checklist';
                        this.showToast('Error', errorMessage, 'error');
                        this.isLoading = false;
                    });
                } else {
                    this.isLoading = false;
                }
            } else if (!isValid) {
                this.isLoading = false;
            } else {
                // No conditions met
                this.isLoading = false;
            }
        }

        // Update the updateChecklistItemsFromAnswers method
        updateChecklistItemsFromAnswers(isSubmit, isValid = true) {
            console.log('isSubmit '+isSubmit);
            
            // Check if there are any changes made
            const hasChanges = Object.keys(this.answers).length > 0;
            
            // For existing checklist items, allow submission even without changes if it's a submit action
            if (!hasChanges && !isSubmit) {
                this.showToast('Warning', 'No changes detected. Please make changes before saving.', 'warning');
                this.isLoading = false;
                return;
            }

            // Add validation for unchecked boxes requiring remarks
            if (isSubmit) {
                // Validate ALL items, not just those with changes
                this.checklistItems.forEach((question) => {
                    const answer = this.answers[question.Id];
                    const isChecked = answer && answer.valid !== undefined ? answer.valid : question.Valid__c;
                    const remark = answer && answer.remark !== undefined ? answer.remark : question.Remarks__c;
                    
                    // If checkbox is not checked, remark is mandatory
                    if (!isChecked && (!remark || remark.trim() === '')) {
                        isValid = false;
                        this.showToast('Error', 'Please provide remarks for unchecked items', 'error');
                    }
                });
            }

            if (!isValid) {
                this.isLoading = false;
                return;
            }

            // If there are changes, update the items
            if (hasChanges) {
                Object.keys(this.answers).forEach((answerId) => {
                    const answer = this.answers[answerId];
                    this.checklistItems = this.checklistItems.map((item) => {
                        if (item.Id === answerId) {
                            return {
                                ...item,
                                Status__c: answer.valid ? 'Valid' : 'Invalid',
                                Remarks__c: answer.remark !== undefined ? answer.remark : item.Remarks__c,
                                Category__c: answer.category !== undefined ? answer.category : item.Category__c,
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

                saveChecklistItems({ 
                    checklistItems: updatedItems, 
                    recordId: this.recordId, 
                    bookingFormStatus: '', 
                    bookingFormRejection: '', 
                    isSubmit: isSubmit, 
                    checklistName: 'Post Cancellation'
                })
                .then(() => {
                    console.log('Checklist items saved successfully');
                    const successMessage = isSubmit ? 'Checklist submitted successfully' : 'Checklist updated successfully';
                    this.showToast('Success', successMessage, 'success');
                    
                    // Only disable form and update opportunity record if it's a submit action
                    if (isSubmit) {
                        this.disableSaveSubmit = true;
                        this.disableFields = true;
                        this.updateOpportunityRecord();
                    }
                    
                    // Clear answers but keep the checklist items for display
                    this.answers = {};
                    this.showCancelBtn = false;
                    
                    // Stop loading and refresh data
                    this.isLoading = false;
                    this.fetchOpportunityName();
                    
                    // Only reload on submit
                    if (isSubmit) {
                        setTimeout(() => {
                            location.reload();
                        }, 1000);
                    }
                })
                .catch((error) => {
                    console.error('Error saving checklist items: ', error);
                    const errorMessage = isSubmit ? 'Error submitting checklist' : 'Error updating checklist';
                    this.showToast('Error', errorMessage, 'error');
                    this.isLoading = false;
                });
            } else if (isSubmit) {
                // No changes but submitting - save ALL existing items as they are
                console.log('Inside Submit checklist with no data changes - saving all items');
                
                saveChecklistItems({ 
                    checklistItems: this.checklistItems, // Save ALL items
                    recordId: this.recordId, 
                    bookingFormStatus: '', 
                    bookingFormRejection: '', 
                    isSubmit: true, 
                    checklistName: 'Post Cancellation'
                })
                .then(() => {
                    console.log('Checklist items submitted successfully');
                    this.showToast('Success', 'Checklist submitted successfully', 'success');
                    
                    // Disable form and update opportunity record after successful submit
                    this.disableSaveSubmit = true;
                    this.disableFields = true;
                    this.updateOpportunityRecord();
                    
                    this.isLoading = false;
                    this.fetchOpportunityName();
                    
                    setTimeout(() => {
                        location.reload();
                    }, 1000);
                })
                .catch((error) => {
                    console.error('Error submitting checklist items: ', error);
                    this.showToast('Error', 'Error submitting checklist', 'error');
                    this.isLoading = false;
                });
            } else {
                // This shouldn't happen, but just in case
                this.isLoading = false;
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
                this.isLoading = true; // Start loading when cancel is clicked
                this.showCancelBtn = false;
                this.answers = {};
                this.checklistItems =[];
                this.questions =[];
                this.welcomeCallQuestions =[];
               // this.processQuestionsAndAnswers();
                 //this.fetchOpportunityName();
                 this.fetchChecklistItems();
                 this.fetchOpportunityDetails();
            }


                updateOpportunityRecord() {
                    console.log('Starting updateOpportunityRecord via Apex...');
                    console.log('Record ID:', this.recordId);
                    console.log('User ID:', this.userId);
                    
                    updateOpportunityPostCancellationFields({ 
                        opportunityId: this.recordId, 
                        userId: this.userId 
                    })
                    .then(() => {
                        console.log('Opportunity record updated successfully via Apex');
                        this.isChecklistSubmitted = true; // Update local state
                    })
                    .catch(error => {
                        console.error('Error updating opportunity via Apex:', error);
                        console.error('Error details:', JSON.stringify(error));
                        
                        let errorMessage = 'Unknown error occurred';
                        if (error && error.body && error.body.message) {
                            errorMessage = error.body.message;
                        } else if (error && error.message) {
                            errorMessage = error.message;
                        }
                        
                        this.showToast('Error', 'Error updating opportunity: ' + errorMessage, 'error');
                        // Re-enable form if update fails
                        this.disableSaveSubmit = false;
                        this.disableFields = false;
                    });
                }

                // Also add the missing fetchOpportunityDetails method that's called in handleCancel:
                fetchOpportunityDetails() {
                    this.fetchOpportunityName();
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
}