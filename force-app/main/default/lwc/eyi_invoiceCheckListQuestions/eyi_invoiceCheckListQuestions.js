import { LightningElement,api,track,wire } from 'lwc';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItems';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import saveInvoiceStatus from '@salesforce/apex/ChecklistQuestionController.saveInvoiceStatus';
import saveInvoiceSubmissionStatus from '@salesforce/apex/ChecklistQuestionController.saveInvoiceSubmissionStatus';
import getRECDetails from '@salesforce/apex/ChecklistQuestionController.getRECDetails';
import getBrokerageDetails from '@salesforce/apex/ChecklistQuestionController.getBrokerageDetails';
import getChecklistItems from '@salesforce/apex/ChecklistQuestionController.getChecklistItems';
import getBankDetailsByREC from '@salesforce/apex/ChecklistQuestionController.getBankDetailsByREC';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';

export default class Eyi_invoiceCheckListQuestions extends LightningElement {
    @api recordId;
    @track recDetails = null;
    @track opportunityDetails = null;
    @track brokerageDetails = null;
    
    // Static questions array - this is now the only questions list
    @track staticQuestions = [
        {
            id: 'sq1',
            label: 'SAP Code',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq2',
            label: 'RERA Registered',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq3',
            label: 'If RERA registered then RERA Number',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq4',
            label: 'Sales Approval',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq5',
            label: 'Bank Detail confirmation',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq6',
            label: 'GST number & scanned copy of certificate',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq7',
            label: 'In case the REC is not GST registered <br/> a declaration letter should be uploaded.',
            //sublabel: ' a declaration letter should be uploaded <br/> (Mandatory in case GST is not there)',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq8',
            label: 'PAN number & scanned copy',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq9',
            label: 'Registration completed',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq10',
            label: '20% Received',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        },
        {
            id: 'sq11',
            label: 'Verify invoice with REC master data',
            valid: false,
            remark: '',
            checkedBy: '',
            currentValue: ''
        }
    ];

    opportunityName;
    @track invoiceOptions = [
        { label: 'Approved', value: 'Approved' },
        { label: 'Rejected', value: 'Rejected' }
    ];

    @track staticAnswers = {};
    @track disableFields = false;
    // Add a new property to track invoice picklist access
    @track disableInvoicePicklist = true;

    userId = Id;
    userName;
    userRoleName;
    userProfile;
    @track globalInvoiceStatus = '';
    @track isInvoiceSubmitted = false;
    @track showValidationMessage = false;
    @track isInvoiceStatusApproved = false;
    @track isLoading = false;
    @track showReason = false;
    @track InvoiceChecklistRejection = '';
    @track rejectionPicklistValues = [];
    @track disabledInvoiceChecklistRejection = false;

    connectedCallback(){
        this.initializeStaticQuestions();
    }

    // Initialize static questions - don't set checkedBy here
    initializeStaticQuestions() {
        this.staticQuestions = this.staticQuestions.map(question => ({
            ...question,
            checkedBy: '' // Initialize as empty, will be set based on checklist record existence
        }));
    }
    
    @wire(getRecord, { recordId: Id, fields: [Name, RoleName, ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Name.value != null) {
                this.userName = data.fields.Name.value;
                this.updateStaticQuestionsCheckedBy();
            }
            if (data.fields.UserRole.value != null) {
                this.userRoleName = data.fields.UserRole.value.fields.Name.value;
            }
            if (data.fields.Profile.value != null) {
                this.userProfile = data.fields.Profile.value.fields.Name.value;
            }
            // Call the enhanced method instead
            this.fetchOpportunityDetails();
        }
    }

    // Update static questions with current user name
    updateStaticQuestionsCheckedBy() {
        // Only update if no checker is already set from the opportunity record
        if (!this.opportunityDetails?.EYI_Invoice_Checklist_Checker__c) {
            this.staticQuestions = this.staticQuestions.map(question => ({
                ...question,
                checkedBy: this.userName || ''
            }));
        }
    }

    // Enhanced method to fetch complete Opportunity details
    fetchOpportunityDetails() {
        if (this.recordId) {
            getOppRecord({ recordId: this.recordId })
                .then(result => {
                    if (result) {
                        // Store complete opportunity details
                        this.opportunityDetails = result;
                        console.log('Opportunity Details fetched:', JSON.stringify(this.opportunityDetails));
                        
                        // Update checkedBy field based on checklist checker
                        this.updateCheckedByField(result);
                        
                        // Handle user access control
                        this.handleUserAccess(result);
                        
                        // Fetch REC details after getting opportunity details
                        this.fetchRECDetails();
                        
                        // Fetch Brokerage details after getting opportunity details
                        this.fetchBrokerageDetails();
                        
                        // Fetch saved checklist items
                        this.fetchSavedChecklistItems();
                    }
                })
                .catch(error => {
                    console.error('Error fetching Opportunity details:', error);
                });
        }
    }

    // New method to update checkedBy field based on checklist record existence
    updateCheckedByField(opportunityRecord) {
        let checkedByValue = '';
        
        // Check if EYI_Invoice_Checklist_Checker__c field has a value
        // if (opportunityRecord.EYI_Invoice_Checklist_Checker__c) {
        //     checkedByValue = opportunityRecord.EYI_Invoice_Checklist_Checker__r.Name;
        // }
        
        // Update all static questions with the checker name or empty string
        this.staticQuestions = this.staticQuestions.map(question => ({
            ...question,
            checkedBy: checkedByValue
        }));
    }

    // Handle user access control
    handleUserAccess(opportunityRecord) {
        // Only enable for CEO and CRM Admin roles
        if(this.userRoleName && (this.userRoleName.includes('CEO') || this.userRoleName.includes('CRM Admin'))) {
            this.disableFields = false;
            this.disableInvoicePicklist = false;
            console.log('Admin user - enabling fields and invoice picklist');
        } else {
            this.disableFields = true;
            this.disableInvoicePicklist = true;
            console.log('Non-admin user - disabling fields and invoice picklist');
        }
        
        this.opportunityName = opportunityRecord.Name;
        
        // Set the saved invoice status from Opportunity
        if(opportunityRecord.EYI_Invoice_Checklist_Status__c) {
            this.globalInvoiceStatus = opportunityRecord.EYI_Invoice_Checklist_Status__c;
            console.log('Saved Invoice Status: ', this.globalInvoiceStatus);
            
            // Check if status is already approved and disable further changes
            if(opportunityRecord.EYI_Invoice_Checklist_Status__c === 'Approved') {
                this.isInvoiceStatusApproved = true;
                this.disableFields = true;
                console.log('Invoice status is approved - disabling fields');
            }
        }
        
        // Set the saved submission status from Opportunity
        if(opportunityRecord.EYI_Is_InvoiceChecklist_Submitted__c) {
            this.isInvoiceSubmitted = opportunityRecord.EYI_Is_InvoiceChecklist_Submitted__c;
            console.log('Invoice Submission Status: ', this.isInvoiceSubmitted);
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
                        console.log('Brokerage Details fetched:', JSON.stringify(this.brokerageDetails));
                        
                        // Update static questions with dynamic values after fetching brokerage
                        this.updateStaticQuestionsWithDynamicValues();
                    } else {
                        console.log('No Brokerage details found for this opportunity');
                        this.brokerageDetails = null;
                    }
                })
                .catch(error => {
                    console.error('Error fetching Brokerage details:', error);
                    this.brokerageDetails = null;
                });
        }
    }

    // Update method to include brokerage data in dynamic values
    updateStaticQuestionsWithDynamicValues() {
        this.staticQuestions = this.staticQuestions.map(question => {
            let currentValue = '';
            
            switch(question.id) {
                case 'sq1': // SAP Code
                    currentValue = this.recDetails?.EYI_REC_Vendor_Code__c || 'Not Available';
                    break;
                case 'sq2': // RERA Registered
                    currentValue = this.recDetails?.EYI_RERA_Registered__c || 'Not Available';
                    break;
                case 'sq3': // RERA Number
                    currentValue = this.recDetails?.EYI_RERA_Certificate_No__c || 'Not Available';
                    break;
                case 'sq4': // Sales Approval
                    currentValue = ' ';
                    break;
                case 'sq5': // Bank Detail confirmation
                    // Format bank names: 2 per line, then new line
                    if (this.activeBankNames && this.activeBankNames.length > 0) {
                        const bankNames = this.activeBankNames.map(bank => bank.name);
                        let formattedBanks = '';
                        
                        for (let i = 0; i < bankNames.length; i += 2) {
                            const pair = bankNames.slice(i, i + 2);
                            formattedBanks += pair.join(', ');
                            
                            // Add line break if there are more banks to display
                            if (i + 2 < bankNames.length) {
                                formattedBanks += '<br/>';
                            }
                        }
                        
                        currentValue = formattedBanks;
                    } else {
                        currentValue = 'Not Available';
                    }
                    break;
                case 'sq6': // GST number & scanned copy of certificate 
                    currentValue = this.recDetails?.EYI_GSTIN__c || 'Not Available';
                    break;
                case 'sq7': // In case the REC is not GST registered a declaration letter should be uploaded
                    currentValue = ' ';
                    break;
                case 'sq8': // PAN number & scanned copy
                    const panValue = this.recDetails?.EYI_PAN_No__c;
                    console.log('PAN Value for sq8:', panValue);
                    currentValue = panValue || 'Not Available';
                    break;
                case 'sq9': // Registration completed
                    currentValue = this.opportunityDetails?.EYI_Registration_Status__c || 'Not Available';
                    break;
                case 'sq10': // 20% Received
                    // Use EYI_Is_20_Booking_Received__c checkbox from Brokerage object
                    if (this.brokerageDetails?.EYI_Is_20_Booking_Received__c !== undefined) {
                        currentValue = this.brokerageDetails.EYI_Is_20_Booking_Received__c ? 'Yes' : 'No';
                    } else {
                        currentValue = 'Not Available';
                    }
                    break;
                case 'sq11': // Verify invoice with REC master 
                    currentValue = ' ';
                    break;
                default:
                    currentValue = 'Not Available';
            }
            
            return {
                ...question,
                currentValue: currentValue,
                isBankDetails: question.id === 'sq5'
            };
        });
    }

    // Add method to handle Brokerage hyperlink clicks
    handleBrokerageLinkClick(event) {
        event.preventDefault();
        if (this.brokerageDetails && this.brokerageDetails.Id) {
            window.open(`/${this.brokerageDetails.Id}`, '_blank');
        }
    }

    // Add getter to check if Brokerage details are available
    get hasBrokerageDetails() {
        return this.brokerageDetails && this.brokerageDetails.Id;
    }

    // Update getter for Brokerage display info to include the checkbox
    get brokerageDisplayInfo() {
        if (this.hasBrokerageDetails) {
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

    // Add method to handle Opportunity hyperlink clicks
    handleOpportunityLinkClick(event) {
        event.preventDefault();
        if (this.recordId) {
            window.open(`/${this.recordId}`, '_blank');
        }
    }

    // Add getter to check if Opportunity details are available
    get hasOpportunityDetails() {
        return this.opportunityDetails && this.opportunityDetails.Id;
    }

    // Add getter for Opportunity display info
    get opportunityDisplayInfo() {
        if (this.hasOpportunityDetails) {
            return {
                name: this.opportunityDetails.Name || 'Opportunity Record',
                stageName: this.opportunityDetails.StageName || '',
                amount: this.opportunityDetails.Amount || '',
                closeDate: this.opportunityDetails.CloseDate ? new Date(this.opportunityDetails.CloseDate).toLocaleDateString() : '',
                invoiceStatus: this.opportunityDetails.EYI_Invoice_Checklist_Status__c || '',
                createdDate: this.opportunityDetails.CreatedDate ? new Date(this.opportunityDetails.CreatedDate).toLocaleDateString() : '',
                url: `/${this.opportunityDetails.Id}`
            };
        }
        return null;
    }

    // Add getter to check if REC details are available
    get hasRECDetails() {
        return this.recDetails && this.recDetails.Id;
    }

    // Add getter for REC display info
    get recDisplayInfo() {
        if (this.hasRECDetails) {
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

    handleSave(event) {
        let isValid = true;
        const label = event.target.label;
        let isSubmit = false;

        // Check remarks for all questions
        const missingRemark = this.staticQuestions.some(q => !q.remark || q.remark.trim() === '');
        if (missingRemark) {
            this.showToast('Error', 'Remark is mandatory for all questions.', 'error');
            return;
        }

        if(label === 'Submit') {
            // Additional validation for submit
            if (!this.areAllCheckboxesChecked) {
                this.showToast('Error', 'Please check all checkboxes before submitting', 'error');
                return;
            }
            isSubmit = true;
            this.isLoading = true;
        }
        
        // Validate required globalInvoiceStatus field FIRST
        // if (!this.globalInvoiceStatus || this.globalInvoiceStatus === '') {
        //     isValid = false;
        //     this.isLoading = false;
        //     this.showToast('Error', 'Please select Eligibility to raise Invoice', 'error');
        //     return;
        // }

        if (!isSubmit) {
            this.isLoading = true;
        }

        // Additional validation for "Approved" status
        if (this.globalInvoiceStatus === 'Approved' && !this.areAllQuestionsValid) {
            isValid = false;
            this.isLoading = false;
            this.showToast('Error', 'All questions must be checked as valid before approving', 'error');
            return;
        }

        if (isValid) {
            // First save the invoice status
            saveInvoiceStatus({
                recordId: this.recordId,
                invoiceStatus: this.globalInvoiceStatus,
                checklistName: 'Invoice'
            })
            .then(() => {
                // After status is saved, save the checklist items
                const checklistItems = this.staticQuestions.map((question) => ({
                    Opportunity__c: this.recordId,
                    Question__c: question.label,
                    Remarks__c: question.remark || '', 
                    Type__c: 'Invoice',
                    Valid__c: question.valid || false
                }));
                
                // Call the save method
                this.saveChecklistItemsWithUpsert(checklistItems, isSubmit);
            })
            .catch((error) => {
                this.isLoading = false;
                console.error('Error updating invoice status:', error);
                this.showToast('Error', 'Failed to update invoice status', 'error');
            });
        } else {
            this.isLoading = false;
        }
    }

    // Save invoice status to Opportunity
    saveInvoiceStatusToOpportunity() {
        this.isLoading = true;
        saveInvoiceStatus({
            recordId: this.recordId,
            invoiceStatus: this.globalInvoiceStatus,
            checklistName: 'Invoice'
        })
        .then(() => {
            this.isLoading = false;
            this.showToast('Success', 'Invoice status updated successfully', 'success');
            
            // Reload the page to reflect changes
            setTimeout(() => {
                window.location.reload();
            }, 1000);
        })
        .catch((error) => {
            this.isLoading = false;
            console.error('Error updating invoice status:', error);
            this.showToast('Error', 'Failed to update invoice status', 'error');
        });
    }

    saveInvoiceSubmissionStatusToOpportunity(isSubmitted) {
        saveInvoiceSubmissionStatus({
            recordId: this.recordId,
            isSubmitted: isSubmitted
        })
        .then(() => {
            console.log('Invoice submission status saved to Opportunity successfully');
            this.isInvoiceSubmitted = isSubmitted;
        })
        .catch((error) => {
            console.error('Error saving invoice submission status to Opportunity: ', error);
            this.showToast('Error', 'Error saving submission status', 'error');
        });
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
        this.staticAnswers = {};
        this.initializeStaticQuestions();
    }

    // Show cancel button when fields are enabled
    get showCancelBtn() {
        return !this.disableFields && !this.isInvoiceStatusApproved;
    }

    // Add this getter to check if all checkboxes are checked
    get areAllCheckboxesChecked() {
        return this.staticQuestions.every(question => question.valid === true);
    }

    // Check if submit should be disabled
    get isSubmitDisabled() {
        try {
            // Disable submit for non-admin users
            if(this.disableInvoicePicklist) {
                return true;
            }
            
            // Check if global invoice status is selected
            if (!this.globalInvoiceStatus || this.globalInvoiceStatus === '') {
                return true;
            }
            
            // Check if all checkboxes are checked for submit
            if (!this.areAllCheckboxesChecked) {
                return true;
            }
            
            // Disable when loading or when fields are disabled by user role/permissions
            return this.isLoading;
        } catch (error) {
            console.error('Error in isSubmitDisabled getter:', error);
            return true;
        }
    }

    // Add getter for invoice picklist disabled state
    get isInvoicePicklistDisabled() {
        return this.disableInvoicePicklist || this.isInvoiceStatusApproved;
    }

    // Check if all questions are valid
    get areAllQuestionsValid() {
        return this.staticQuestions.every(question => question.valid === true);
    }

    // Modify handleGlobalInvoiceChange method
    handleGlobalInvoiceChange(event) {
        const selectedValue = event.detail.value;
        
        // Check if invoice status was already approved - prevent any changes
        if (this.isInvoiceStatusApproved) {
            this.showToast('Error', 'Cannot modify approved status', 'error');
            return;
        }
        
        // Check if user is trying to select "Approved" when not all questions are valid
        if (selectedValue === 'Approved' && !this.areAllQuestionsValid) {
            this.showValidationMessage = true;
            this.showToast('Error', 'All questions must be checked as valid before approving', 'error');
            // Reset the picklist to previous value
            this.globalInvoiceStatus = '';
            return;
        }
        
        // Clear validation message if valid selection
        this.showValidationMessage = false;
        this.globalInvoiceStatus = selectedValue;
        
        // Show/hide rejection reason and clear it when switching to Approved
        this.showReason = selectedValue === 'Rejected';
        if (selectedValue === 'Approved') {
            this.InvoiceChecklistRejection = '';
        }
    }

    handleInvoiceChecklistRejection(event) {
        this.InvoiceChecklistRejection = event.detail.value;
    }

    // Add this new method to handle checkbox changes
    handleValidCheckboxChange(event) {
        try {
            const questionId = event.target.dataset.id;
            const isChecked = event.target.checked;
            
            // Find and update the specific question
            this.staticQuestions = this.staticQuestions.map(question => {
                if (question.id === questionId) {
                    return {
                        ...question,
                        valid: isChecked
                    };
                }
                return question;
            });
            
            console.log(`Question ${questionId} valid status updated to: ${isChecked}`);
            
            // Clear validation message if all questions become valid
            if (this.areAllQuestionsValid) {
                this.showValidationMessage = false;
            }
            
        } catch (error) {
            console.error('Error handling checkbox change:', error);
            this.showToast('Error', 'Error updating checkbox status', 'error');
        }
    }

    // Add this method to handle remark changes
    handleRemarkChange(event) {
        try {
            const questionId = event.target.dataset.id;
            const remarkValue = event.target.value;
            
            // Find and update the specific question's remark
            this.staticQuestions = this.staticQuestions.map(question => {
                if (question.id === questionId) {
                    return {
                        ...question,
                        remark: remarkValue
                    };
                }
                return question;
            });
            
            console.log(`Question ${questionId} remark updated to: ${remarkValue}`);
            
        } catch (error) {
            console.error('Error handling remark change:', error);
            this.showToast('Error', 'Error updating remark', 'error');
        }
    }

    // Add new method to fetch saved checklist items
    fetchSavedChecklistItems() {
        if (this.recordId) {
            getChecklistItems({ 
                opportunityId: this.recordId, 
                checklistType: 'Invoice' 
            })
            .then(result => {
                if (result && result.length > 0) {
                    console.log('Saved checklist items:', JSON.stringify(result));
                    this.populateStaticQuestionsWithSavedData(result);
                } else {
                    console.log('No saved checklist items found');
                }
            })
            .catch(error => {
                console.error('Error fetching saved checklist items:', error);
            });
        }
    }

    // Update the populateStaticQuestionsWithSavedData method to store the record IDs
    populateStaticQuestionsWithSavedData(savedItems) {
        this.staticQuestions = this.staticQuestions.map(question => {
            // Find matching saved item by question label
            const savedItem = savedItems.find(item => item.Question__c === question.label);
            
            if (savedItem) {
                return {
                    ...question,
                    valid: savedItem.Valid__c || false,
                    remark: savedItem.Remarks__c || '',
                    checkedBy: savedItem.CreatedBy ? savedItem.CreatedBy.Name : question.checkedBy,
                    checkedDate: savedItem.CreatedDate ? new Date(savedItem.CreatedDate).toLocaleDateString() : '',
                    checklistItemId: savedItem.Id // Store the record ID for updates
                };
            }
            
            return question;
        });
        
        console.log('Static questions updated with saved data:', JSON.stringify(this.staticQuestions));
    }

    // New method to handle upsert operations with page reload
    saveChecklistItemsWithUpsert(checklistItems, isSubmit) {
        saveChecklistItems({ 
            checklistItems: checklistItems, 
            recordId: this.recordId,
            bookingFormStatus: this.globalInvoiceStatus || '', // Pass the invoice status
            bookingFormRejection: this.InvoiceChecklistRejection || '', // Pass rejection reason
            isSubmit: isSubmit,
            checklistName: 'Invoice'
        })
        .then(() => {
            console.log('Checklist items saved successfully');
            this.showToast('Success', 'Checklist saved successfully', 'success');
            this.staticAnswers = {};
            this.isLoading = false;
            
            // Add page reload after successful save/submit
            setTimeout(() => {
                window.location.reload();
            }, 1500); // 1.5 second delay to show the success toast
        })
        .catch((error) => {
            console.error('Error saving checklist items: ', error);
            console.error('Error details: ', JSON.stringify(error));
            this.isLoading = false;
            
            // Show more detailed error message
            let errorMessage = 'Error saving checklist items';
            if (error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error.message) {
                errorMessage = error.message;
            }
            
            this.showToast('Error', errorMessage, 'error');
        });
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
            this.updateStaticQuestionsWithDynamicValues();
        } else if (error) {
            this.bankError = error;
            this.bankDetails = undefined;
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

    // Add getter to check if current question is bank details
    get isBankDetailsQuestion() {
        return question => question.id === 'sq5';
    }

}