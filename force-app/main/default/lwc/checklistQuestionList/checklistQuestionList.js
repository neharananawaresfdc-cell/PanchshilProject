import { LightningElement,api,track,wire } from 'lwc';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
import submitChecklistItems from '@salesforce/apex/ChecklistQuestionController.submitChecklistItems';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import WelcomeChecklistURL from '@salesforce/label/c.WelcomeChecklistURL';

const FIELDS = ['Opportunity.Name'];

export default class ChecklistQuestionList extends LightningElement {

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
    @track statusOptions = [
        { label: 'Valid', value: 'Valid' },
        { label: 'Invalid', value: 'Invalid' }
    ];
    @track answers = {};

    @track disableFields = false;
    userId = Id;
    userName;
    userRoleName;
    userProfile
    showCancelBtn = false;

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
                    
                    if(result.StageName != 'Booking Form Submitted' || this.userRoleName != 'Onboarding Manager' || result.IsWelcomeCallChecklistSubmitted__c == true ){
                        this.disableFields = true; 
                     }
                     if(this.userRoleName == 'Onboarding Manager' && (result.StageName == 'Booking Form Submitted' || result.StageName == 'Welcome Call Submitted') && result.IsWelcomeCallChecklistSubmitted__c == false ){
                         this.disableFields = false;
                     }
                     if(this.userProfile == 'System Administrator' || this.userName == 'CRM Admin'){
                        this.disableFields = false;  
                    }
                    this.opportunityName = result.Name;
                    this.checkedBy = result.EYI_Welcome_Call_Checklist_Checker__r.Name;
                })
                .catch(error => {
                    console.error('Error fetching Opportunity: ', error);
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
                        this.checklistItems = result.filter(item => item.Type__c === "Welcome Call Checklist");
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
                        question.Type__c === 'Welcome Call Checklist'
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
                    (item) => item.Type__c === 'Welcome Call Checklist'
                );
               
            } else if (this.questions.length > 0) {
                this.welcomeCallQuestions = this.questions.filter(
                    (question) => question.Type__c === 'Welcome Call Checklist'
                );
                
            } else {
                console.error('Neither checklistItems nor questions have data.');
            }
            console.log('Welcome Call Questions:', JSON.stringify(this.welcomeCallQuestions));
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
            console.log('this.answers : '+JSON.stringify(this.answers));
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
                if(this.checklistItems.length > 0 ){
                    this.updateChecklistItemsFromAnswers(isSubmit);
                }
                if(this.questions.length > 0){
                    if (isSubmit == true) {
                        this.questions.forEach((question) => {
                            // Check if this.answers[question.Id] is not null before proceeding
                            const answer = this.answers[question.Id];
                            if (answer !== undefined) {
                                //const status = answer.status;
                                const valid = answer.valid;
                                const invalid = answer.invalid;
                                const remark = answer.remark;
                                const category = question.Category__c;
                    
                                // Check if status is not selected
                                if (!valid && !invalid) {
                                    isValid = false;
                                    this.showToast('Error', 'Please Mark Valid or Invalid', 'warning');
                                }
                                if(valid === 'true' && invalid === 'true'){
                                    isValid = false;
                                    this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning');
                                }
                    
                                // If status is 'Invalid', check if remark is provided
                                if (invalid && category === 'Critical' &&!remark) {
                                    isValid = false;
                                    this.showToast('Error', 'Please provide Remarks if Invalid option is Checked and Critical Category', 'warning');
                                }
                                if (invalid && category === 'Critical' && remark) {
                                    isValid = false;
                                    this.showToast('Error', 'Please solve the Invalid checked with Critical category', 'warning');
                                }
                            }else{
                                isValid = false;
                                this.showToast('Error', 'Please fill Valid or Invalid option of all questions', 'warning');
                            }
                        });
                    }
                if (isSubmit == false) {
                    this.questions.forEach((question) => {
                        // Check if this.answers[question.Id] is not null before proceeding
                        const answer = this.answers[question.Id];
                        console.log('answer : '+answer);
                        
                        if (answer !== undefined) {
                            //const status = answer.status;
                            const valid = answer.valid;
                            const invalid = answer.invalid;
                            const remark = answer.remark;
                            const category = answer.category;

                            if(valid === 'true' && invalid === 'true'){
                                isValid = false;
                                this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning');
                            }
                
                            if (invalid && category === 'Critical' &&!remark) {
                                isValid = false;
                                this.showToast('Error', 'Please provide Remarks for Invalid Checked and Critical Category', 'warning');
                            }
                        }
                    });
                }
    
        
                if (isValid) {
                    const checklistItems = this.questions.map((question) => {
                        const answer = this.answers[question.Id] || {}; // Fallback to an empty object if not found
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
                    
        
                    saveChecklistItems({ checklistItems, recordId: this.recordId,bookingFormStatus: '',bookingFormRejection:'',isSubmit:isSubmit,checklistName:'Welcome Call Checklist'})
                        .then(() => {
                            console.log('Checklist items saved successfully');
                            this.showToast('Success', 'Checklist saved successfully', 'success');
                            this.questions =[];
                            this.checklistItems =[];
                            this.welcomeCallQuestions =[];
                            this.answers ={};
                            this.fetchOpportunityName();
                            this.fetchChecklistItems();  
                        })
                        .catch((error) => {
                            console.error('Error saving checklist items: ', error);
                        });
                }
                } 
            }

            updateChecklistItemsFromAnswers(isSubmit) {
                console.log('isSubmit '+isSubmit);
                
                
                    let isValid = true;
                    // Object.keys(this.answers).forEach((answerId) => {
                    //     const answer = this.answers[answerId];
                    //     this.checklistItems = this.checklistItems.map((item) => {
                    //         if (item.Id === answerId) {
                    //             return {
                    //                 ...item,
                    //                 Status__c: answer.status || item.Status__c,
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
                    
                    updatedItems.forEach((question) => {
                        //const status = question.Status__c;
                        const valid = question.Valid__c;
                        const invalid = question.Invalid__c;
                        const remark = question.Remarks__c;
                        const category = question.Category__c;
                        console.log('remark '+remark);
                        
                        
                        if(valid && invalid){
                            isValid = false;
                            this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning'); 
                        }
            
                
            
                        if (invalid && category ==='Critical' && !remark) {
                            isValid = false;
                            this.showToast('Error', 'Please provide Remarks for Invalid Checked and Critical Category', 'warning');
                        }
                        if(isSubmit){
                            if (!valid && !invalid) {
                                isValid = false;
                                this.showToast('Error', 'Please mark the Valid or Invalid', 'warning');
                            }
                            if (invalid && category === 'Critical' && remark) {
                                isValid = false;
                                this.showToast('Error', 'Please solve the Invalid checked with Critical category', 'warning');
                            }
                        }
                    });

                    /*if (isSubmit) {
                        this.checklistItems.forEach((question) => {
                            // Only check items that are not in updatedItems
                            const isInUpdatedItems = updatedItems.some(item => item.Id === question.Id);
                            if (!isInUpdatedItems) {
                                const status = question.Status__c;
                    
                                // Check if status is blank
                                if (!status) {
                                    isValid = false;
                                    this.showToast('Error', 'Please select the Status for all items', 'warning');
                                }
                            }
                        });
                    }*/
            
                    if (updatedItems.length > 0) {
                        if(isValid){
                            console.log('Inside Update Item');
                            
                            saveChecklistItems({ checklistItems: updatedItems, recordId: this.recordId,bookingFormStatus: '',bookingFormRejection:'',isSubmit:isSubmit,checklistName:'Welcome Call Checklist'})
                            .then(() => {
                                console.log('Checklist items saved successfully');
                                this.showToast('Success', 'Checklist updated successfully', 'success');
                                this.questions =[];
                                this.checklistItems =[];
                                this.welcomeCallQuestions =[];
                                this.answers ={};
                                this.fetchOpportunityName();
                                this.fetchChecklistItems();
                                
                            })
                            .catch((error) => {
                                console.error('Error saving checklist items: ', error);
                            });
                        } 
                    }else if( updatedItems.length == 0 && isValid == true && isSubmit ==true){
                        console.log('Inside Sumbit checklist with no data');
                        this.checklistItems.forEach((question) => {
                            
                            if(question.Valid__c == false && question.Invalid__c == false){
                                isValid = false; 
                                this.showToast('Error', 'Please Mark the Valid or Invalid', 'warning');
                            }
                            if (question.Invalid__c == true && question.Category__c === 'Critical' && question.Remarks__c) {
                                isValid = false;
                                this.showToast('Error', 'Please solve the Invalid checked with Critical category', 'warning');
                            }
                        });
                        if(isValid){
                            submitChecklistItems({ recordId: this.recordId,isSubmit:isSubmit,checkListLabel:'Welcome Call Checklist'})
                            .then(() => {
                                console.log('Checklist items saved successfully');
                                this.showToast('Success', 'Checklist Sumitted successfully', 'success');
                                this.fetchOpportunityName();
                                this.fetchChecklistItems();
                                
                            })
                            .catch((error) => {
                                console.error('Error saving checklist items: ', error);
                            });
                        }
                        
                    }else{
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
                       // this.processQuestionsAndAnswers();
                         //this.fetchOpportunityName();
                         this.fetchChecklistItems();
                         this.fetchOpportunityDetails();
                    }

                    handlePrint(){

                        const opportunityId = this.recordId;  
                        const oppName = 'Welcome Call Checklist - '+this.opportunityName+ ' - ';
                        const opportunityName = encodeURIComponent(oppName); 
                        const todayDate = new Date();
                        const opportunityCreatedDate = encodeURIComponent(todayDate.toISOString()); 
                        // const url = `/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!API.Partner_Server_URL_520}&Id=${opportunityId}&QueryId=[oppo]0Q_026MAO975256,[WelcomeCheck]0Q_025MAO879955&TemplateId=0T_017MAO726164&OFN=${opportunityName}+${opportunityCreatedDate}&DefaultPDF=1&PDFA=1a&DS7=11`;
                        const congaUrlTemplate = WelcomeChecklistURL;
                        console.log('congaUrlTemplate : '+congaUrlTemplate);
                        const url = congaUrlTemplate
                        .replace('${opportunityId}', opportunityId)   
                        .replace('${opportunityName}', opportunityName)  
                        .replace('${opportunityCreatedDate}', opportunityCreatedDate);  
                        console.log('Generated URL: ' + url);
                        window.open(url, '_self');
                                            }

}