import { LightningElement,api,track,wire } from 'lwc';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';
import submitChecklistItems from '@salesforce/apex/ChecklistQuestionController.submitChecklistItems';
import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import RegistrationChecklistURL from '@salesforce/label/c.RegistrationChecklistURL';
export default class RegistrationChecklist extends LightningElement {
    @api recordId;
    @track checklistItems = [];
    @track questions = [];
    @track welcomeCallQuestions = []; 
    @track categoryOptions = [
        { label: 'Critical', value: 'Critical' },
        { label: 'Non-Critical', value: 'Non-Critical' }
    ];
    @track statusOptions = [
        { label: 'Verified', value: 'Verified' },
        { label: 'Unverified', value: 'Unverified' }
    ];
    @track answers = {};
    disableFields = false;
    opportunityName;
    checkedBy
    userId = Id;
    userName;
    userRoleName;
    userProfile;
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
        // Make sure the recordId is available before calling getRecord
        if (this.recordId) {
            getOppRecord({ recordId: this.recordId })
                .then(result => {
                    // Access the Opportunity Name from the result
                    this.opportunityName = result.Name;
                    // if(result.IsRegistrationChecklistSubmitted__c == true){
                    //     console.log('Disable Wecome Call Checklist');
                    //     this.disableFields = true;
                    // }
                    console.log('this.userRoleName : '+this.userRoleName);
                    console.log('result.StageName : '+result.StageName);
                    console.log('result.IsRegistrationChecklistSubmitted__c '+result.IsRegistrationChecklistSubmitted__c);
                    console.log('this.userProfile : '+this.userProfile);
                    
                    
                    
                    
                    if( this.userRoleName != 'Relationship Manager' || result.IsRegistrationChecklistSubmitted__c == true ){
                        console.log('inside first If');
                        
                        this.disableFields = true; 
                     } 
                     if((this.userRoleName == 'Relationship Manager' || this.userRoleName == 'CRM TL') && result.EYI_Franking_status__c != 'Done'){
                        this.disableFields = true;
                     }
                     if((this.userRoleName == 'Relationship Manager' || this.userRoleName == 'CRM TL') && result.EYI_Franking_status__c == 'Done' && result.IsRegistrationChecklistSubmitted__c == false ){
                        console.log('Inside second if');
                         this.disableFields = false;
                     }
                     if(this.userProfile == 'System Administrator' || this.userName == 'CRM Admin'){
                        this.disableFields = false;  
                    }
                    this.checkedBy = result.EYI_Registration_Checklist_Checker__r.Name;
                    console.log('Opportunity Name: ', this.opportunityName);
                })
                .catch(error => {
                    console.error('Error fetching Opportunity: ', error);
                });
        }
    }

    fetchChecklistItems() {
        console.log('Calling Apex to fetch Checklist Items');
        
        getChecklistItemsByRecordId({ recordId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log('Checklist Items fetched:', JSON.stringify(result));

                    if (result.length === 0) {
                        console.log('No checklist items found, calling fetchDefaultQuestions');
                        this.fetchDefaultQuestions();
                    } else {
                        this.checklistItems = result.filter(item => item.Type__c === "Registration Checklist");
                        if(this.checklistItems.length === 0){
                            console.log('this.checklistItems.length : '+this.checklistItems.length);
                            
                            this.fetchDefaultQuestions();
                        }else{
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
                    console.log('getQuestion Data : ' + JSON.stringify(data));
                    this.questions = data.filter(question => 
                        question.Type__c === 'Registration Checklist',
                    );
                    this.processQuestionsAndAnswers();
                })
                .catch((error) => {
                    console.error('Error fetching default questions:', error);
                });
        }
    
        processQuestionsAndAnswers() {
        
            // Check if checklistItems or questions have data
            if (this.checklistItems.length > 0) {
                this.welcomeCallQuestions = this.checklistItems.filter(
                    (item) => item.Type__c === 'Registration Checklist'
                );
               
            } else if (this.questions.length > 0) {
                // If checklistItems is empty, use questions data
                this.welcomeCallQuestions = this.questions.filter(
                    (question) => question.Type__c === 'Registration Checklist'
                );
                
            } else {
                console.error('Neither checklistItems nor questions have data.');
            }
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
                if(this.checklistItems.length > 0){
                    this.updateChecklistItemsFromAnswers(isSubmit);
                }
                console.log(' this.answers #### '+ this.answers);
                
                if(this.questions.length > 0){
                    if (isSubmit == true) {
                        this.questions.forEach((question) => {
                            // Check if this.answers[question.Id] is not null before proceeding
                            const answer = this.answers[question.Id];
                            if (answer !== undefined) {
                                const status = answer.status;
                                const remark = answer.remark;
                               // const category = question.Category__c;;
                                // Check if status is not selected
                                if (!status) {
                                    isValid = false;
                                    this.showToast('Error', 'Please select the Status', 'warning');
                                }
                    
                                // If status is 'Invalid', check if remark is provided
                                if (status === 'Unverified'  && !remark) {
                                    isValid = false;
                                    this.showToast('Error', 'Please provide Remarks for Unverified Status', 'warning');
                                }
                            }else{
                                isValid = false;
                                this.showToast('Error', 'Please fill Status of all Fields', 'warning');
                            }
                        });
                    }
                if (isSubmit == false) {
                    this.questions.forEach((question) => {
                        // Check if this.answers[question.Id] is not null before proceeding
                        const answer = this.answers[question.Id];
                        console.log('answer : '+answer);
                        
                        if (answer !== undefined) {
                            const status = answer.status;
                            const remark = answer.remark;
                            //const category = answer.category;
                
                            if (status === 'Unverified'  && !remark) {
                                isValid = false;
                                this.showToast('Error', 'Please provide Remarks for Unverified Status', 'warning');
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
                                    Status__c: answer.status || '', 
                                    Remarks__c: answer.remark || '', 
                                    //Category__c: answer.category || question.Category__c, 
                                    Type__c: question.Type__c,
                                    EYI_Sequence_No__c: question.Sequence_No__c
                                };
                            });
                            console.log('checklistItems Before Save '+checklistItems);
                            
                
                            saveChecklistItems({ checklistItems, recordId: this.recordId,bookingFormStatus: '',bookingFormRejection:'',isSubmit:isSubmit,checklistName:'Registration Checklist'})
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
                console.log('Update isSubmit '+isSubmit);
                
                    let isValid = true;
                    Object.keys(this.answers).forEach((answerId) => {
                        const answer = this.answers[answerId];
                        this.checklistItems = this.checklistItems.map((item) => {
                            if (item.Id === answerId) {
                                return {
                                    ...item,
                                    Status__c: answer.status || item.Status__c,
                                    Remarks__c: answer.remark || item.Remarks__c
                                  //  Category__c: answer.category || item.Category__c
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
                        const status = question.Status__c;
                        const remark = question.Remarks__c;
                        //const category = question.Category__c;
                        console.log('status '+status);
                        console.log('remark '+remark);
                        if (!status) {
                            isValid = false;
                            this.showToast('Error', 'Please select the Status', 'warning');
                        }
            
                        if (status === 'Unverified' && !remark) {
                            isValid = false;
                            this.showToast('Error', 'Please provide Remarks for Unverified Status', 'warning');
                        }
                    }); 
                    if (isSubmit) {
                        this.checklistItems.forEach((question) => {
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
                    }
            
                    if (updatedItems.length > 0) {
                        if(isValid){
                            saveChecklistItems({ checklistItems: updatedItems, recordId: this.recordId,bookingFormStatus: '',bookingFormRejection:'',isSubmit:isSubmit,checklistName:'Registration Checklist' })
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
                        console.log('Direct Submit');
                        
                        this.checklistItems.forEach((question) => {
                            console.log('status : '+question.Status__c);
                            
                            if(question.Status__c == null){
                                isValid = false; 
                                this.showToast('Error', 'Please select the Status', 'warning');
                            }
                        });
                        console.log('Inside Sumbit checklist with no data');
                        if(isValid){
                            submitChecklistItems({ recordId: this.recordId,isSubmit:isSubmit,checkListLabel:'Registration Checklist'})
                            .then(() => {
                                this.showToast('Success', 'Checklist Sumitted successfully', 'success');
                                this.fetchOpportunityName();
                                this.fetchChecklistItems();
                                
                            })
                            .catch((error) => {
                                console.error('Error saving checklist items: ', error);
                            });
                        }
                        
                    } else{
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
                    handlePrint(){
                        console.log('You clicked on handle Print button');
                        const opportunityId = this.recordId; 

                    const serverUrl = '/';  
                    const oppName = 'Registration Checklist - '+this.opportunityName+ ' - ';
                    const opportunityName = encodeURIComponent(oppName); 
                    const todayDate = new Date();
                    const opportunityCreatedDate = encodeURIComponent(todayDate.toISOString()); 

                    // const url = `/apex/APXTConga4__Conga_Composer?SolMgr=1
                    // &serverUrl={!API.Partner_Server_URL_520}
                    // &Id=${opportunityId}&QueryId=[regCheck]0Q_031MAO177711,[oppo]0Q_026MAO975256
                    // &TemplateId=0T_019MAO850640
                    // &OFN=${opportunityName}+${opportunityCreatedDate}
                    // &DefaultPDF=1
                    // &PDFA=1a
                    // &DS7=11`;
                    const congaUrlTemplate = RegistrationChecklistURL;
                    console.log('congaUrlTemplate : '+congaUrlTemplate);
                    const url = congaUrlTemplate
                    .replace('${opportunityId}', opportunityId)   
                    .replace('${opportunityName}', opportunityName)  
                    .replace('${opportunityCreatedDate}', opportunityCreatedDate);
                    console.log('Generated URL: ' + url);
                    window.open(url, '_self');
                        
                    }
                    handleCancel(){
                        this.showCancelBtn = false;
                        this.answers = {};
                        this.checklistItems =[];
                        this.questions =[];
                        this.welcomeCallQuestions =[];
                         this.fetchChecklistItems();
                         this.fetchOpportunityDetails();
                    }

                    

}