import { LightningElement, api, wire, track } from 'lwc';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
import getBookingDetails from '@salesforce/apex/ChecklistQuestionController.getBookingDetails';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItems';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getOpportunityDetails from '@salesforce/apex/ChecklistQuestionController.getOpportunityDetails';
import submitChecklistItems from '@salesforce/apex/ChecklistQuestionController.submitChecklistItems';
import findBookingForm from '@salesforce/apex/ChecklistQuestionController.findBookingForm';
import saveRemark from '@salesforce/apex/ChecklistQuestionController.saveRemark';
import saveBookingStatus from '@salesforce/apex/ChecklistQuestionController.saveBookingStatus'
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import updateOppRecord from '@salesforce/apex/ChecklistQuestionController.updateOppRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues } from 'lightning/uiObjectInfoApi'; 
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; 
import OPP_OBJECT from '@salesforce/schema/Opportunity'; 
import BOOKINGFORMSTATUS from '@salesforce/schema/Opportunity.EYI_Booking_Form_Status__c';  
import BookingChecklistURL from '@salesforce/label/c.BookingChecklistURL';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import USER_ID from '@salesforce/user/Id';

export default class ChecklistQuestions extends LightningElement {
    @api recordId;
    questions = [];
    checklistItems = [];
    welcomeCallQuestions = []; 
    salesChecklistQuestions = [];
    answers = {};
    bookingDetails = {};
    isDirectChecked = false;
    isRECChecked = false;
    isNotCheque = false;
    isCheque = false;
    @track wiredChecklistItemsResult;
    wiredOppDetailsResult;
    picklistValues;  
    rejectionPicklistValues
    bookingFormStatus; 
    bookingFormRejection; 
    showReason = false
    opportunityName
    checkedBy;
    statusCount = 0;
    @track disableFields = false;
    @track disableRemarkFields = false;
    @track showUpdateButton = false;
    @track showBookingFormStatus = false;
    @track categoryOptions = [
        { label: 'Critical', value: 'Critical' },
        { label: 'Non-Critical', value: 'Non-Critical' }
    ];
    @track statusOptions = [
        { label: 'Verified', value: 'Verified' },
        { label: 'Not Verified', value: 'Not Verified' }
    ];
    @track rejectionPicklistValues = [
        { label: 'Critical Discrepancy', value: 'Critical Discrepancy' }
       
    ];
    userId = USER_ID;
    userName;
    userRoleName;
    userProfile;
    showCancelBtn = false;
    showSaveDraftBtn = true;
    showSubmitBtn = true;
    showPrintBtn = false
    @track disabledBookingFormStatus = true;
    showRemarkModal = false;
    closingManagerRemark = '';
    @track showSubmitButton = false;
    allPicklistOptions = [];
    @track pmuserId ='';

    connectedCallback() {
        console.log('Record Id : ' + this.recordId);
       
    }

    @wire(getRecord, { recordId: Id, fields: [Name, RoleName,ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            console.log('this.error - 82 '+ JSON.stringify(error));

        } else if (data) {
            
            if (data.fields.Name.value != null) {
                this.userName = data.fields.Name.value;
            }
            if (data.fields.UserRole.value != null) {
                this.userRoleName = data.fields.UserRole.value.fields.Name.value;
            }
            if (data.fields.Profile.value != null) {
                this.userProfile = data.fields.Profile.value.fields.Name.value;
            }
            this.fetchOpportunityName();
            this.fetchOpportunityDetails();
            this.fetchChecklistItems();
            this.filterPicklistOptions();
        }
    }
    
    handleupdateChecklist(){
        console.log('inside handleupdateChecklist');
        this.showUpdateButton = false;
        //this.showSubmitBtn = true;
        this.disabledBookingFormStatus = false;
        updateOppRecord({ recordId: this.recordId,checklistName:'Booking Checklist' })
                .then(result => {
                    
                })
                .catch(error => {
                    console.error('Error updateOppRecord Opportunity: ', error);
                });
    }
    
    fetchOpportunityName() {
        console.log('fetchOpportunityName : '+this.recordId);

        if (this.recordId) {
            getOppRecord({ recordId: this.recordId })
                .then(result => {
                    console.log('getOppRecord result : '+JSON.stringify(result));
                    this.pmuserId = result.EYI_Primary_Closing_Manager__c;
                    if(result.StageName != 'Booked' || this.userRoleName != 'Onboarding Manager' || result.IsBookingChecklistSubmitted__c == true ){
                       this.disableFields = true;
                       this.disableRemarkFields = true; 
                       this.showSaveDraftBtn = false;
                       this.showSubmitBtn = false;
                       this.disabledBookingFormStatus= true;
                    }
                     if(this.userRoleName == 'Onboarding Manager' && (result.StageName == 'Booked' || result.EYI_Booking_Form_Status__c == 'Discrepancy Resolved' || result.EYI_Booking_Form_Status__c == 'Booking Form Check on Hold') && result.IsBookingChecklistSubmitted__c == false ){
                        this.disableFields = false;
                        this.disableRemarkFields = false;
                        this.disabledBookingFormStatus = false;
                        this.showSaveDraftBtn = true;
                        this.showSubmitBtn = true;
                    }
                    if(this.userRoleName == 'Onboarding Manager' && result.IsBookingChecklistSubmitted__c == true && (result.EYI_Booking_Form_Status__c == 'Accept With Non-Critical Discrepancy' || result.EYI_Booking_Form_Status__c == 'Booking Form Accepted')){
                        this.disableFields = true;
                        this.disableRemarkFields = true;
                        this.disabledBookingFormStatus = true;
                        this.showPrintBtn = true;
                    }
                    if(this.userRoleName == 'Onboarding Manager' && result.IsBookingChecklistSubmitted__c == true){
                        this.showPrintBtn = true;
                    }
                    if(this.userProfile == 'System Administrator' || this.userName == 'CRM Admin'){
                        this.disableFields = false;  
                        this.disableRemarkFields = false;
                        this.showSaveDraftBtn = true;
                        this.showSubmitBtn = true;
                        this.disabledBookingFormStatus = false;
                        if(result.IsBookingChecklistSubmitted__c == true && result.StageName == 'Booking Form Submitted'){
                            this.showPrintBtn = true;
                        }
                    }
                    if( result.EYI_Booking_Form_Status__c == 'Booking Form Rejected' && (this.pmuserId == this.userId) && result.IsBookingChecklistSubmitted__c == true){
                        console.log('insise showUpdateButton true if');
                        this.disableRemarkFields = false;
                        this.showUpdateButton = true;
                        this.showSaveDraftBtn = false;
                        this.showSubmitBtn = false;
                        this.showPrintBtn = false;
                        
                    }
                    if( result.EYI_Booking_Form_Status__c == 'Booking Form Rejected' && 
                        (this.pmuserId == this.userId)){
                        this.disabledBookingFormStatus = false;
                    }

                    // Access the Opportunity Name from the result
                    this.opportunityName = result.Name;
                    if(result.IsBookingChecklistSubmitted__c == true){
                        this.checkedBy = result.Booking_Checklist_Checker__r.Name;
                        console.log('result.EYI_Booking_Form_Status__c '+result.EYI_Booking_Form_Status__c);
                    }
                })
                .catch(error => {
                    console.error('Error fetching Opportunity: ', error);
                });
        }
    }

      
    @wire(getObjectInfo, { objectApiName: OPP_OBJECT })     
    oppInfo;      
    
    @wire(getPicklistValues, { 
        recordTypeId: '$oppInfo.data.defaultRecordTypeId', fieldApiName: BOOKINGFORMSTATUS })     
       wiredPicklistValues({ error, data }) {         
           if (data) {   
                this.allPicklistOptions = data.values;
                this.filterPicklistOptions();
            }           
            else if (error) {             
               console.error('Error retrieving picklist values: ', error);  
           }  
        }   
    
    filterPicklistOptions(){
        if (!this.userRoleName || this.allPicklistOptions.length === 0) return;

        

        if (this.userRoleName === 'Onboarding Manager') {
            this.picklistValues = this.allPicklistOptions.filter(opt =>
                ['Accept With Non-Critical Discrepancy', 'Booking Form Accepted', 'Booking Form Rejected','Booking Form Check on Hold'].includes(opt.value)
            );
        } else if (this.pmuserId == this.userId) {
            this.picklistValues = this.allPicklistOptions.filter(opt =>
                opt.value === 'Discrepancy Resolved'
            );
        } else {
            this.picklistValues = this.allPicklistOptions;
        }
    
    }
    
    

    @wire(getBookingDetails, { recordId: '$recordId' })
    wiredProjectResult({ error, data }) {
        if (data) {
            console.log('Booking details fetched successfully:', data);
            this.bookingDetails = data;
            this.handleCheckboxLogic();
        } else if (error) {
            console.error('Error fetching booking details:', error);
        }
    }

    handleCheckboxLogic() {
        if (this.bookingDetails) {
            if (!this.bookingDetails.rec) {
                this.isDirectChecked = true;
                this.isRECChecked = false;
            } else {
                this.isRECChecked = true;
                this.isDirectChecked = false;
            }
            if(this.bookingDetails.modeOfPayment == 'Cheque' && this.bookingDetails.modeOfPayment != null){
                this.isCheque = true
            }else if(this.bookingDetails.modeOfPayment != 'Cheque' && (this.bookingDetails.modeOfPayment != undefined || this.bookingDetails.modeOfPayment != null)){
                this.isNotCheque = true
            }
        }
    }

    
fetchChecklistItems() {
    console.log('Calling Apex to fetch Checklist Items');
    
    getChecklistItemsByRecordId({ recordId: this.recordId })
        .then((result) => {
            if (result) {
                if (result.length === 0) {
                    this.fetchDefaultQuestions();
                } else {
                    this.checklistItems = result.filter(item => item.Type__c === "Duly Filled Booking Form" || item.Type__c === "Duly Signed Booking Form & Proposal");

                    console.log('Filtered Checklist Items:', JSON.stringify(this.checklistItems));
                    if(this.checklistItems.length === 0){
                        this.fetchDefaultQuestions();
                    }else{
                        this.checklistItems.forEach(record => {
                            if (record.Valid__c === "true" || record.Invalid__c === "true") {
                              this.statusCount++;
                            }
                          });
                          if(this.statusCount == this.checklistItems.length){
                            this.showBookingFormStatus = true;
                          }
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

fetchOpportunityDetails() {
    getOpportunityDetails({ recordId: this.recordId })
        .then(result => {
            this.bookingFormStatus = result.EYI_Booking_Form_Status__c;
            if (this.bookingFormStatus === 'Booking Form Rejected') {
                this.showReason = true;
                this.bookingFormRejection = result.EYI_Reason_for_Booking_Form_Rejection__c;
            }else{
                this.showReason = false;
            }
        })
        .catch(error => {
            console.error('Error fetching Opportunity details:', error);
            this.fetchDefaultQuestions(); 
        });
}

    fetchDefaultQuestions() {
        getQuestion()
            .then((data) => {
                console.log('getQuestion Data : ' + JSON.stringify(data));
                this.questions = data.filter(question => 
                    question.Type__c === 'Duly Filled Booking Form' || 
                    question.Type__c === 'Duly Signed Booking Form & Proposal'
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
                (item) => item.Type__c === 'Duly Filled Booking Form'
            );
            this.salesChecklistQuestions = this.checklistItems.filter(
                (item) => item.Type__c === 'Duly Signed Booking Form & Proposal'
            );
        } else if (this.questions.length > 0) {
            this.welcomeCallQuestions = this.questions.filter(
                (question) => question.Type__c === 'Duly Filled Booking Form'
            );
        
            this.salesChecklistQuestions = this.questions.filter(
                (question) => question.Type__c === 'Duly Signed Booking Form & Proposal'
            );
        } else {
            console.error('Neither checklistItems nor questions have data.');
        }
    }

    handleInputChange(event) {
        this.showCancelBtn = true;
        const { name, value, dataset, checked, type } = event.target;
        const questionId = dataset.id;
        
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
        console.log('this.answers '+JSON.stringify(this.answers));
         
        let okCount = 0      
        if(this.questions.length > 0 && this.checklistItems.length == 0){
            for (let key in this.answers) {
                if (this.answers[key].Valid__c === "true" || this.answers[key].Invalid__c === "Not true" ) {
                  okCount++;
                }
            }
            if(this.questions.length == okCount){
                this.showBookingFormStatus = true;
            }
        }
        if(this.checklistItems.length > 0 && this.statusCount != this.checklistItems.length){
            for (let key in this.answers) {
                let checklistItem = this.checklistItems.find(item => item.Id === key);
        if (checklistItem && (checklistItem.Valid__c !== "true" && checklistItem.Invalid__c !== "true")) {
            if (this.answers[key].Valid__c === "true" || this.answers[key].Invalid__c === "true" ) {
                okCount++;
              }
        }    
            }
            let totalcount = okCount + this.statusCount
            if(totalcount == this.checklistItems.length){
                this.showBookingFormStatus = true;
            }
        } 
        
    }

    handleSave(event) {
        this.showCancelBtn = false;
        let isValid = true;
        const label = event.target.label;
        let isSubmit = false;
        if(label == 'Submit'){
            console.log('inside Submit if');
            isSubmit = true;
        }
        console.log('====>  ',this.checklistItems.length);
        if(this.checklistItems.length > 0){
            console.log('Data is present in checklistItems===> ');
            this.updateChecklistItemsFromAnswers(isSubmit);
        }
        console.log('questions====>  ',this.questions.length);

        if(this.questions.length > 0 && this.checklistItems.length == 0){
            if (isSubmit == true) {
                this.questions.forEach((question) => {
                    const answer = this.answers[question.Id];
                    if (answer !== undefined) {
                        //const status = '';
                        const valid = answer.valid;
                        const invalid = answer.invalid;
                        const remark = answer.remark;
                        const category = question.Category__c;
                        console.log('category ==>'+category);
                        if (!valid && !invalid) {
                            isValid = false;
                            this.showToast('Error', 'Please Mark Valid or Invalid', 'warning');
                        }
                        if(valid && invalid){
                            isValid = false;
                            this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning');
                        }
                        if (invalid && category === 'Critical' && !remark) {
                            isValid = false;
                            this.showToast('Error', 'Please provide Remarks if Invalid option is Checked and Critical Category', 'warning');
                        }
                        if (invalid && ( category === 'Critical' || category === 'Non-Critical') && this.bookingFormStatus == 'Booking Form Accepted') {
                            isValid = false;
                            this.showToast('Error', 'Please solved the Invalid Checked of Critical and Non-Critical Category', 'error');
                        }
                        if (invalid === 'true' && category === 'Critical' && this.bookingFormStatus == 'Accept With Non-Critical Discrepancy') {
                            isValid = false;
                            this.showToast('Error', 'Please solved the Invalid Checked of Critical Category', 'error');
                         }
                     }else if( answer === undefined /*&& this.bookingFormStatus != 'Booking Form Rejected' && !this.bookingFormRejection*/){
                         isValid = false;
                         this.showToast('Error', 'Please fill Status of all Fields', 'warning');
                     }
                });
            }
        if (isSubmit == false) {
            this.questions.forEach((question) => {
                const answer = this.answers[question.Id];
                console.log('answer : '+answer);
                
                if (answer !== undefined) {
                    const valid = answer.valid;
                    const invalid = answer.invalid;
                    const remark = answer.remark;
                    const category = question.Category__c;

                    if(valid === 'true' && invalid === 'true'){
                        isValid = false;
                        this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning');
                    }
        
                    if (invalid === 'true' && category === 'Critical' && !remark) {
                        isValid = false;
                        this.showToast('Error', 'Please provide Remarks for Invalid Checked and Critical Category', 'warning');
                    }
                }
            });
        }


        if(isSubmit){
            if(!this.bookingFormStatus){
                isValid = false;
                this.showToast('Error', 'Please select Booking Form Status', 'Error');
            }
            if(this.bookingFormStatus == 'Booking Form Rejected' && !this.bookingFormRejection){
                isValid = false;
                this.showToast('Error', 'Please select Booking Form Rejection Reason', 'Error');
            }
            if(this.bookingFormStatus == 'Booking Form Check on Hold'){
                isValid = false;
                this.showToast('Error', 'You can not submit form when status is Booking Form Check on Hold', 'Error');
            }

        }
        if(this.bookingFormStatus == 'Discrepancy Resolved' && this.userRoleName == 'Onboarding Manager'){
            isValid = false;
            this.showToast('Error', 'Please change status to Accept, Reject or Hold', 'Error');  
        }
        if(this.bookingFormStatus != 'Discrepancy Resolved' && (this.pmuserId == this.userId)){
        //if(this.bookingFormStatus != 'Discrepancy Resolved' && (this.userId == this.pmuserId)){
            isValid = false;
            this.showToast('Error', 'You can select only Discrepancy Resolved Status', 'Error');  
        }
        
        if (isValid) {
            console.log('Inside isValid True');
            
            const checklistItems = this.questions.map((question) => {
                const answer = this.answers[question.Id] || {}; 
                return {
                    Opportunity__c: this.recordId,
                    Question__c: question.Question__c,
                    Status__c: '', 
                    Valid__c : answer.valid, 
                    Invalid__c: answer.invalid,
                    Remarks__c: answer.remark || '', 
                    Category__c: answer.category || question.Category__c, 
                    Type__c: question.Type__c,
                    EYI_Sequence_No__c: question.Sequence_No__c
                };
            });
            console.log('checklistItems Before Save '+checklistItems);
            

            saveChecklistItems({ checklistItems, recordId: this.recordId,bookingFormStatus: this.bookingFormStatus, bookingFormRejection:this.bookingFormRejection,isSubmit:isSubmit,checklistName:'Booking Checklist' })
                .then(() => {
                    console.log('Checklist items saved successfully');
                    this.showToast('Success', 'Checklist saved successfully', 'success');
                    this.questions =[];
                    this.checklistItems =[];
                    this.welcomeCallQuestions =[];
                    this.salesChecklistQuestions = [];
                    this.answers ={};
                    this.bookingFormStatus ='';
                    this.bookingFormRejection = '';
                    this.fetchOpportunityName();
                    this.fetchOpportunityDetails();
                    this.fetchChecklistItems();
                    
                })
                .catch((error) => {
                    console.error('Error saving checklist items: ', error);
                });
        }
        }

        
    }

    updateChecklistItemsFromAnswers(isSubmit) {
        let isValid = true;
        // Object.keys(this.answers).forEach((answerId) => {
        //     const answer = this.answers[answerId];
        //     this.checklistItems = this.checklistItems.map((item) => {
        //         if (item.Id === answerId) {
        //             console.log('item : '+JSON.stringify(item));
        //             console.log('answer :'+JSON.stringify(answer));
        //             return {
        //                 ...item,
        //                 Valid__c: answer.valid,
        //                 Invalid__c:answer.invalid,
        //                 Remarks__c: answer.remark || item.Remarks__c,
        //                 Category__c: answer.category || item.Category__c
        //             };
        //         }
        //         return item;
        //     });
        // });
        Object.keys(this.answers).forEach((answerId) => {
            const answer = this.answers[answerId];
            this.checklistItems = this.checklistItems.map((item) => {
                if (item.Id === answerId) {
                    console.log('item : ' + JSON.stringify(item));
                    console.log('answer :' + JSON.stringify(answer));
                    
                    const updatedItem = { ...item };
        
                    if ('valid' in answer) {
                        updatedItem.Valid__c = answer.valid;
                    }else{
                        updatedItem.Valid__c = item.Valid__c;
                    }
                    if ('invalid' in answer) {
                        updatedItem.Invalid__c = answer.invalid;
                    }else{
                        updatedItem.Invalid__c = item.Invalid__c; 
                    }
                    if ('remark' in answer) {
                        updatedItem.Remarks__c = answer.remark;
                    }else{
                        updatedItem.Remarks__c = item.Remarks__c;
                    }
                    if ('category' in answer) {
                        updatedItem.Category__c = answer.category;
                    }else{
                        updatedItem.Category__c = item.Category__c;  
                    }
        
                    return updatedItem;
                }
                return item;
            });
        });
        console.log('Updated checklist items: ' + JSON.stringify(this.checklistItems));
        const updatedItems = this.checklistItems.filter((item) => {
            return this.answers.hasOwnProperty(item.Id);
        });
        console.log('Updated items before save: ' + JSON.stringify(updatedItems));


        if(updatedItems.length > 0){
            updatedItems.forEach((question) => {
                const valid = question.Valid__c;
                const invalid = question.Invalid__c;
                const remark = question.Remarks__c;
                const category = question.Category__c;
                console.log('category : '+category);
                console.log('valid : '+valid);
                console.log('invalid : '+invalid);
                console.log('remark : '+remark);
                
                
                
                if(valid && invalid){
                    isValid = false;
                    this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning'); 
                }
                console.log('**');
                
                if (invalid && category === 'Critical' && !remark) {
                    console.log('Inside firat validation ');
                    
                    isValid = false;
                    this.showToast('Error', 'Please provide Remarks for Invalid Checked and Critical Category', 'warning');
                }
                if(isSubmit){
                    if (!valid && !invalid) {
                        isValid = false;
                        this.showToast('Error', 'Please mark the Valid or Invalid', 'warning');
                    }

                    if (invalid && (category === 'Critical' || category === 'Non-Critical') && this.bookingFormStatus == 'Booking Form Accepted') {
                       isValid = false;
                       this.showToast('Error', 'Please solved the Invalid Checked of Critical and Non-Critical Category', 'error');
                    }
                    if (invalid && category === 'Critical' && this.bookingFormStatus == 'Accept With Non-Critical Discrepancy') {
                        isValid = false;
                        this.showToast('Error', 'Please solved the Invalid Checked of Critical Category', 'error');
                     }
                }
                
            });
        }
        

        if(isSubmit){
            if(!this.bookingFormStatus){
                isValid = false;
                this.showToast('Error', 'Please select Booking Form Status', 'Error');
            }
            if(this.bookingFormStatus == 'Booking Form Rejected' && !this.bookingFormRejection){
                isValid = false;
                this.showToast('Error', 'Please select Booking Form Rejection Reason', 'Error');
            }
            if(this.bookingFormStatus == 'Booking Form Check on Hold'){
                isValid = false;
                this.showToast('Error', 'You can not submit form when status is Booking Form Check on Hold', 'Error');
            }
           /* this.checklistItems.forEach((question) => {
                const isInUpdatedItems = updatedItems.some(item => item.Id === question.Id);
                if (!isInUpdatedItems ) {
                    console.log('Inside ****');
                    
                    const valid = question.Valid__c;
                    const invalid = question.Invalid__c;;
                    const category = question.Category__c;
                    if (!valid && !invalid) {
                        isValid = false;
                        this.showToast('Error', 'Please mark the Valid or Invalid', 'warning');
                    }
                    if(valid && invalid){
                        isValid = false;
                        this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning'); 
                    }
                    if (Invalid === 'true' && (category === 'Critical' || category === 'Non-Critical') && this.bookingFormStatus == 'Booking Form Accepted') {
                       isValid = false;
                       this.showToast('Error', 'Please solved the Invalid Checked of Critical and Non-Critical Category', 'error');
                    }
                    if (invalid === 'true' && category === 'Critical' && this.bookingFormStatus == 'Accept With Non-Critical Discrepancy') {
                        isValid = false;
                        this.showToast('Error', 'Please solved the Invalid Checked of Critical Category', 'error');
                     }
                }
            });*/
        }
        if(this.bookingFormStatus == 'Discrepancy Resolved' && this.userRoleName == 'Onboarding Manager'){
            isValid = false;
            this.showToast('Error', 'Please change status to Accept, Reject or Hold', 'Error');  
        }
        if(this.bookingFormStatus != 'Discrepancy Resolved' && (this.pmuserId == this.userId)){
            isValid = false;
            this.showToast('Error', 'You can select only Discrepancy Resolved Status', 'Error');  
        }

        console.log('updatedItems.length : '+updatedItems.length);
        
        if (updatedItems.length > 0 && ((this.bookingFormStatus &&  isSubmit) || (!isSubmit || this.bookingFormStatus))) {
            if(isValid){
                console.log('Inside updatedItems.length > 0');
                
                saveChecklistItems({ checklistItems: updatedItems, recordId: this.recordId, bookingFormStatus: this.bookingFormStatus, bookingFormRejection:this.bookingFormRejection,isSubmit:isSubmit,checklistName:'Booking Checklist' })
                .then(() => {
                    console.log('Checklist items saved successfully');
                    this.showToast('Success', 'Checklist updated successfully', 'success');
                    this.questions =[];
                    this.checklistItems =[];
                    this.welcomeCallQuestions =[];
                    this.salesChecklistQuestions = [];
                    this.answers ={};
                    this.bookingFormStatus ='';
                    this.bookingFormRejection ='';
                    this.fetchOpportunityName();
                    this.fetchOpportunityDetails();
                    this.fetchChecklistItems();
                    
                })
                .catch((error) => {
                    console.error('Error saving checklist items: ', error);
                });
            } 
        }else if( updatedItems.length === 0 && isValid == true && isSubmit ==true){
            console.log('Inside Sumbit checklist with no data');
            this.checklistItems.forEach((question) => {
                console.log('status : '+question.Status__c);                
                if(question.Valid__c == false && question.Invalid__c == false){
                    isValid = false; 
                    this.showToast('Error', 'Please Mark the Valid or Invalid', 'warning');
                }
                if (question.Invalid__c && (question.Category__c === 'Critical' || question.Category__c === 'Non-Critical') && this.bookingFormStatus == 'Booking Form Accepted') {
                    isValid = false;
                    this.showToast('Error', 'Please solved the Invalid Checked', 'error');
                }
                if (question.Invalid__c && question.Category__c === 'Critical' && this.bookingFormStatus == 'Accept With Non-Critical Discrepancy') {
                    isValid = false;
                    this.showToast('Error', 'Please solved the Invalid Checked', 'error');
                 }
            });
            if(isValid){
                submitChecklistItems({ recordId: this.recordId,isSubmit:isSubmit,checkListLabel:'Booking Checklist'})
                .then(() => {
                    console.log('Checklist items saved successfully');
                    this.showToast('Success', 'Checklist Sumitted successfully', 'success');
                    this.fetchOpportunityName();
                    this.fetchChecklistItems();
                    this.fetchOpportunityDetails();
                })
                .catch((error) => {
                    console.error('Error saving checklist items: ', error);
                });
            }
            
        } else{
            this.showToast('Info', 'No changes to save', 'info');
        }
    }

    refreshBothWireResults() {
        // Refresh the first wire result
        refreshApex(this.wiredChecklistItemsResult)
            .then(() => {
                console.log('Opportunity details refreshed');
            })
            .catch((error) => {
                console.error('Error refreshing Opportunity details:', error);
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

    handlePrint() {
        console.log('You clicked on Print Button');
        const opportunityId = this.recordId;  
        const serverUrl = '/';  
        const oppName = 'Booking Checklist - '+this.opportunityName+ ' - ';
        const opportunityName = encodeURIComponent(oppName); 
        const todayDate = new Date();
        const opportunityCreatedDate = encodeURIComponent(todayDate.toISOString()); 

        // const url = `/apex/APXTConga4__Conga_Composer?SolMgr=1
        // &serverUrl={!API.Partner_Server_URL_520}
        // &Id=${opportunityId}&QueryId=[Duly]0Q_027MAO582348,
        // [DulyProposal]0Q_028MAO361486,
        // [oppo]0Q_026MAO975256,[OppoAmt]0Q_029MAO813965,[opBook]0Q_030MAO697219
        // &TemplateId=0T_018MAO558085
        // &OFN=${opportunityName}+${opportunityCreatedDate}
        // &DefaultPDF=1
        // &PDFA=1a
        // &DS7=11`;
        const congaUrlTemplate = BookingChecklistURL;
        console.log('congaUrlTemplate : '+congaUrlTemplate);
        const url = congaUrlTemplate
        .replace('${opportunityId}', opportunityId)   
        .replace('${opportunityName}', opportunityName)  
        .replace('${opportunityCreatedDate}', opportunityCreatedDate);  
        console.log('Generated URL: ' + url);
        window.open(url, '_self');
        
    }

    handleBookingFormChange(event){
        this.showCancelBtn = true;
        console.log('handleBookingFormChange '+event.target.value);
        this.bookingFormStatus = event.target.value
        if(this.bookingFormStatus == 'Booking Form Rejected'){
            this.showReason = true;
        }else{
            this.showReason = false;
            this.bookingFormRejection='';
        }
        if(this.bookingFormStatus == 'Discrepancy Resolved' && (this.pmuserId == this.userId)){
            //this.showRemarkModal = true;
            this.showSubmitButton = true;
        }
        
    }

    handleBookingRejection(event){
        this.showCancelBtn = true;
        console.log('handleBookingRejection '+event.target.value);
        this.bookingFormRejection = event.target.value;
    }
    handleCancel(){
        this.showCancelBtn = false;
        this.answers = {};
        this.checklistItems =[];
        this.questions =[];
        this.welcomeCallQuestions =[];
        this.salesChecklistQuestions =[];
        this.bookingFormRejection ='';
        this.bookingFormStatus='';
         this.fetchChecklistItems();
         this.fetchOpportunityDetails();
    }

    handleRemarkChange(event) {
        this.closingManagerRemark = event.target.value;
    }

    saveRemark() {
        saveRemark({ recordId: this.recordId, remark: this.closingManagerRemark,checklistName:'Booking Checklist' }) 
        .then(() => {
            this.closeModal();
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            }));
        });
    }

    closeModal() {
        this.showRemarkModal = false;
    }

    handleSubmitStatus(){
        
        if(this.bookingFormStatus != 'Discrepancy Resolved'){ 
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'You can select only Descrepancy Resolved Status',
                variant: 'error',
            }));
        }else{
            saveBookingStatus({ recordId: this.recordId, bookingFormStatus: this.bookingFormStatus,checklistName:'Booking Checklist' }) // Call Apex method
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Booking Status Updated Successfully',
                variant: 'success',
            })); 
            this.showSubmitButton = false;
             this.showCancelBtn = false;
            this.fetchOpportunityName();
            this.fetchOpportunityDetails();
            this.fetchChecklistItems();
        })
        .catch(error => {
            this.showSubmitButton = true;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            }));
        });
        }
        
    }

    handleButtonClick(){
        findBookingForm({ oppId: this.recordId })
        .then(result => {
            if (result) {
                // If file is found, open in a new tab
                window.open(result, '_blank');
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'File Not Found',
                        message: 'Booking Form not found for this Opportunity',
                        variant: 'warning',
                    }),
                );
                //this.errorMessage = 'Booking Form not found for this Opportunity.';
            }
        })
        .catch(error => {
            // Handle Apex errors
            console.log('error while fetching Booking form: '+error);
            
        });
    }
}