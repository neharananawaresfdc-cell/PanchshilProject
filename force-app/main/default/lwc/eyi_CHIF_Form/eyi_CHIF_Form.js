import { LightningElement, api, wire, track } from 'lwc';
import getQuestion from '@salesforce/apex/ChecklistQuestionController.getQuestions';
import getOppRecord from '@salesforce/apex/ChecklistQuestionController.getOppRecord';

import saveChecklistItems from '@salesforce/apex/ChecklistQuestionController.saveChecklistItems';
import getChecklistItemsByRecordId from '@salesforce/apex/ChecklistQuestionController.getChecklistItemsByRecordId';
import getOpportunityDetails from '@salesforce/apex/ChecklistQuestionController.getOpportunityDetails';
import getCHIFDetails from '@salesforce/apex/ChecklistQuestionController.getCHIFDetails';
import createCHIFDetails from '@salesforce/apex/ChecklistQuestionController.createCHIFDetails';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPP_OBJECT from '@salesforce/schema/Opportunity';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import CHIF_OBJECT from '@salesforce/schema/EYI_CHIF__c';
import BEHALF_FIELD from '@salesforce/schema/EYI_CHIF__c.EYI_Visit_On_Behalf_Of__c';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import CHIFChecklistURL from '@salesforce/label/c.CHIF_URL';
import CHIFRESChecklistURL from '@salesforce/label/c.CHIF_ResidencialPossession';
import CHIFCOMChecklistURL from '@salesforce/label/c.CHIF_CommercialPossession';

export default class Eyi_CHIF_Form extends LightningElement {
    @api recordId;
    @track behalfOptions=[];
    @track chifQuestions = [];
    @track formSubmitted = false;
    @track chifOTP;
    @track oldCHIFOTP;
    @track ispossessionletter;
    questions = [];
    checklistItems = [];
    @track answers = {};
    @track wiredChecklistItemsResult;
    opportunityName;
    villaNo;
    towerName;
    segment;
    oppNo;
    @track dateOfInspection;
    formattedInspectionDate;
    villaType;
    salesManager;
    projectName;
    checkedBy;
    statusCount = 0;
    @track disableFields = false;   
    userId = Id;
    userName;
    userRoleName;
    userProfile;
    @track isCHIFPresent = false;
    @track isValidOTP = false;
    @track enteredOTP ;
    @track chifId;
    @track projectId;
    @track towerId;
    @track onbehalf;
    @track isCHIFSubmit = false;
    @track isUpdate = false;
    @track isAllValid = false;
    @track isLoading =false;

    @wire(getObjectInfo, { objectApiName: OPP_OBJECT })
    oppInfo;

    
    @wire(getObjectInfo, { objectApiName: CHIF_OBJECT })
    chifInfo;

    @wire(getRecord, { recordId: Id, fields: [Name, RoleName, ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            console.log('this.error - 82 ' + JSON.stringify(error));

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
            // this.fetchOpportunityName();
            // this.fetchOpportunityDetails();
            // this.fetchChecklistItems();
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$chifInfo.data.defaultRecordTypeId',
        fieldApiName: BEHALF_FIELD
    })
    picklistValues({ data, error }) {
        if (data) {
            this.behalfOptions = data.values;
        } else if (error) {
            console.error('Error loading StageName picklist: ', error);
        }
    }
    connectedCallback() {
        console.log('Record Id : ' + this.recordId);
        this.fetchCHIFDetails();
        this.fetchOpportunityName();
    }
    handleUpdate(){
        this.disableFields = false;
        this.isUpdate = true;
        this.fetchOpportunityDetails();
    }
    fetchOpportunityName() {
        console.log('fetchOpportunityName : ' + this.recordId);

        if (this.recordId) {
            // getOppRecord({ recordId: this.recordId })
            //     .then(result => {
            //         console.log('getOppRecord result : ' + JSON.stringify(result));
            //         // Access the Opportunity Name from the result
            //         this.opportunityName = result.Name;
            //         this.villaNo = result.EYI_Inventory__r.Name;
            //         //this.villaType = 'V3';
            //         this.salesManager = result.EYI_Primary_Closing_Manager__r.Name;
            //         const today = new Date();
            //         this.formattedInspectionDate = today.toISOString().split('T')[0];
            //         const day = String(today.getDate()).padStart(2, '0');
            //         const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
            //         const year = today.getFullYear();
            //         this.dateOfInspection = `${day}-${month}-${year}`;;
            //         this.projectName = result.EYI_Project_Enquired__r.Name;
            //         this.towerName = result.EYI_Project_Tower_Enquired__r.Name;
            //         this.oldCHIFOTP = result.EYI_CHIF_OTP__c;
            //         console.log('fetchOpportunityName Called : '+this.oldCHIFOTP);
            //         this.oppNo = result.EYI_Opportunity_Number__c;
            //         this.villaType = result.EYI_Inventory__r.EYI_Typology__c;
            //         this.ispossessionletter = result.EYI_Possession_Letter_Generated__c;
            //         this.segment = result.EYI_Segment__c;
            //         this.projectId = result.EYI_Project_Enquired__c;
            //         this.towerId = result.EYI_Project_Tower_Enquired__c;
            //         if(result.EYI_IsCHIFSubmitted__c == true){
            //             this.formSubmitted = true;
            //             this.disableFields = true;
            //             this.fetchChecklistItems();
            //         }else{
            //             this.formSubmitted = false;
            //             this.disableFields = false;
            //             console.log('fetchDefaultQuestions Called : ');
            //             this.fetchDefaultQuestions();
            //         }
            //     //

            //     })
            //     .catch(error => {
            //         console.error('Error fetching Opportunity: ', JSON.stringify(error));
            //     });
            getOppRecord({ recordId: this.recordId })
            .then(result => {
                console.log('getOppRecord result : ' + JSON.stringify(result));

                this.opportunityName = result?.Name || '';
                this.villaNo = result?.EYI_Inventory__r?.Name || '';
                // this.villaType = 'V3'; // you commented this out
                this.salesManager = result?.EYI_Primary_Closing_Manager__r?.Name || '';

                const today = new Date();
                this.formattedInspectionDate = today.toISOString().split('T')[0];
                const day = String(today.getDate()).padStart(2, '0');
                const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
                const year = today.getFullYear();
                this.dateOfInspection = `${day}-${month}-${year}`;

                this.projectName = result?.EYI_Project_Enquired__r?.Name || '';
                this.towerName = result?.EYI_Project_Tower_Enquired__r?.Name || '';
                this.oldCHIFOTP = result?.EYI_CHIF_OTP__c || '';
                console.log('fetchOpportunityName Called : ' + this.oldCHIFOTP);

                this.oppNo = result?.EYI_Opportunity_Number__c || '';
                this.villaType = result?.EYI_Inventory__r?.EYI_Typology__c || '';
                this.ispossessionletter = result?.EYI_Possession_Letter_Generated__c || false;
                this.segment = result?.EYI_Segment__c || '';
                this.projectId = result?.EYI_Project_Enquired__c || '';
                this.towerId = result?.EYI_Project_Tower_Enquired__c || '';

                if (result?.EYI_IsCHIFSubmitted__c === true) {
                this.formSubmitted = true;
                this.disableFields = true;
                this.fetchChecklistItems();
                } else {
                this.formSubmitted = false;
                this.disableFields = false;
                console.log('fetchDefaultQuestions Called : ');
                this.fetchDefaultQuestions();
                }
            })
            .catch(error => {
                console.error('Error fetching Opportunity: ', JSON.stringify(error));
            });
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
                        this.checklistItems = result.filter(item => item.Type__c == 'CHIF');
                        this.checklistItems.forEach(item => {
                        this.answers[item.Id] = {
                            valid: item.Valid__c, // from your data
                            remark: item.Remarks__c ,  
                            invalid: item.Invalid__c,
                            question: item.Question__c,
                            area: item.EYI_Area__c      // default empty, or populate if needed
                        };
                        this.chifQuestions = this.checklistItems.map(item => ({
                            Id: item.Id,
                            Question__c: item.Question__c
                        }));
                    });
                        console.log('Filtered Checklist Items:', JSON.stringify(this.checklistItems));
                    }
                }
            })
            .catch((error) => {
                console.error('Error fetching checklist items:', error);
                this.fetchDefaultQuestions();
            });
    }
    
    fetchCHIFDetails() {
        getCHIFDetails({ oppId: this.recordId })
            .then(result => {
                console.log('CHIF Details : ', result); // Don't stringify
                if (!result || result.length === 0) {
                    this.isCHIFSubmit = false;
                } else {
                    // No need to parse — result is already an array of objects
                    this.chifId = result[0].Id;
                    this.isCHIFSubmit = true;
                }
                console.log('this.chifId: ', this.chifId);
            })
            .catch(error => {
                console.error('Error fetching Opportunity details:', error);
            });
    }

    fetchOpportunityDetails() {
        getOpportunityDetails({ recordId: this.recordId })
            .then(result => {
                this.bookingFormStatus = result.EYI_Booking_Form_Status__c;
                this.oldCHIFOTP = result.EYI_CHIF_OTP__c;
                this.ispossessionletter = result.EYI_Possession_Letter_Generated__c;
                this.segment = result.EYI_Segment__c;
                if (this.bookingFormStatus === 'Booking Form Rejected') {
                    this.showReason = true;
                    this.bookingFormRejection = result.EYI_Reason_for_Booking_Form_Rejection__c;
                } else {
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
                this.chifQuestions = data.filter(question =>
                    question.Type__c == 'CHIF');
                console.log('this.chifQuestions ===>', JSON.stringify(this.chifQuestions));
            })
            .catch((error) => {
                console.error('Error fetching default questions:', error);
            });
    }
    handleNumberChange(event){
        try {
            this.chifOTP = event.target.value;
        } catch (error) {
            console.error('Error fetching default questions:', error);
        }
    }
    handleBehalfChange(event){
        try {
            this.onbehalf = event.target.value;
        } catch (error) {
            console.error('Error fetching default questions:', error);
        }
    }
    handleOTPChange(event){
        try {
            this.enteredOTP = event.target.value;
        } catch (error) {
            console.error('Error fetching default questions:', error);
        }
    }

    handleInputChange(event) {
        this.showCancelBtn = true;
        const { name, value, dataset, checked, type } = event.target;
        console.log('event.target===>', event.target);
        const questionId = dataset.id;
        console.log('event.questionId===>', questionId);
        console.log('this.answers[questionId]===>', this.answers[questionId]);

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
        console.log('this.answers ' + JSON.stringify(this.answers));
    }

    handleSave(event) {
        this.showCancelBtn = false;
        let isValid = false; 

        this.fetchCHIFDetails();

        if(!this.chifOTP){
            this.showToast('Error', 'Please enter Token Number', 'warning');
            return;
        }      
        if(this.oldCHIFOTP != this.chifOTP){
            this.showToast('Error', 'Token Number does not match', 'warning');
            this.isLoading = false;
            return;
        }
        console.log('this.answers===>'+JSON.stringify(this.answers));
        console.log('this.answers===>'+Object.keys(this.answers).length);
        console.log('this.chifQuestions.length'+this.chifQuestions.length);

        if ((Object.keys(this.answers).length < this.chifQuestions.length) && !this.isUpdate) {
            this.showToast('Error', 'Please Mark Valid or Invalid for all questions', 'warning');
        }else{
            this.isAllValid = true;
            for (const question of this.chifQuestions) {
                const answer = this.answers[question.Id];
                console.log('answer ===> ' + JSON.stringify(answer));
                if (answer !== undefined) {
                    const valid = answer.valid;
                    const invalid = answer.invalid;
                    const category = question.Category__c;
                    const remark = answer.remark;
                    console.log('category ' + category);
                    if (!valid && !invalid) {
                        this.isAllValid = false;
                        this.showToast('Error', 'Please Mark Valid or Invalid', 'warning');
                        return; // this will exit your function here in LWC too
                    } else if (valid && invalid) {
                        this.isAllValid = false;
                        this.showToast('Error', 'You can not check the Valid and Invalid for same question', 'warning');
                        return;
                    } else if (invalid && !remark) {
                        this.showToast('Error', 'Please enter remark for invalid items', 'warning');
                        this.isAllValid = false;
                        return;
                    } else {
                        this.isAllValid = true;
                    }
                } else {
                    this.isAllValid = false;
                    this.showToast('Error', 'Please fill Status of all Fields', 'warning');
                    return;
                }
            }
        }

        if (this.isAllValid) {
            console.log('Inside isValid True');
            this.isLoading = true;
            const checklistItems = this.chifQuestions.map((question) => {
                const answer = this.answers[question.Id] || {};
                console.log('Inside isValid True this.chifId',this.chifId);

                return {
                    Opportunity__c: this.recordId,
                    Question__c: question.Question__c,
                    Remarks__c: answer.remark,
                    Valid__c: answer.valid,
                    Invalid__c: answer.invalid,
                    EYI_Area__c: question.Area__c || '',
                    Type__c: question.Type__c,
                    EYI_Sequence_No__c: question.Sequence_No__c,
                    EYI_CHIF__c: this.chifId
                };
            });
            console.log('checklistItems Before Save ===> ' + JSON.stringify(checklistItems));
            saveChecklistItems({ checklistItems, recordId: this.recordId, bookingFormStatus: '', bookingFormRejection: '', isSubmit: '', checklistName: 'CHIF' })
                .then(() => {
                    console.log('Checklist items saved successfully');
                    this.showToast('Success', 'Checklist saved successfully', 'success');
                    this.questions = [];
                    this.checklistItems = [];
                    this.answers = {};
                    this.isUpdate = false;
                    this.chifOTP = '';
                    this.enteredOTP  = '';
                    this.fetchOpportunityName();
                    this.fetchOpportunityDetails();
                    this.fetchChecklistItems();
                })
                .catch((error) => {
                    console.error('Error saving checklist items: ', error);
                });

            this.isLoading = false; 
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

    handleCancel() {
        this.showCancelBtn = false;
        this.answers = {};
        this.checklistItems = [];
        this.questions = [];
        this.fetchChecklistItems();
        this.fetchOpportunityDetails();
    }
    
    handlePrint(){
        const opportunityId = this.recordId;  
        const oppName = 'CHIF - '+this.opportunityName+ ' - ';
        const opportunityName = encodeURIComponent(oppName); 
        const congaUrl = CHIFChecklistURL
            .replace('{!Opportunity.Id}', opportunityId)
            .replace('{!Opportunity.EYI_Opportunity_Name__c}', opportunityName)
            .replace('{!Opportunity.EYI_Opportunity_Number__c}', this.oppNo);       
            window.open(congaUrl, '_self');
    }

    handleMerge(){
        console.log('In handleMerge');
        console.log('this.ispossessionletter',this.ispossessionletter);

        if (!this.ispossessionletter) {
            this.showToast('Error', 'Please Generate Possession Letter First', 'warning');
            return;
        }

        const opportunityId = this.recordId;  
        const oppName = 'CHIF - Possession - '+this.opportunityName+ ' - ';
        const opportunityName = encodeURIComponent(oppName); 
        console.log('this.segment ==> ',this.segment);
        console.log('this.CHIFCOMChecklistUR ==> ',CHIFCOMChecklistURL);
        console.log('this.CHIFRESChecklistURL ==> ',CHIFRESChecklistURL);

        if (this.segment =='Commercial Sales') {
          const congaUrl = CHIFCOMChecklistURL
            .replace('{!Opportunity.Id}', opportunityId)
            .replace('{!Opportunity.EYI_Opportunity_Name__c}', opportunityName)
            .replace('{!Opportunity.EYI_Opportunity_Number__c}', this.oppNo);       
            window.open(congaUrl, '_self');
        }else if (this.segment =='Residential Sales') {
            const congaUrl = CHIFRESChecklistURL
            .replace('{!Opportunity.Id}', opportunityId)
            .replace('{!Opportunity.EYI_Opportunity_Name__c}', opportunityName)
            .replace('{!Opportunity.EYI_Opportunity_Number__c}', this.oppNo);       
            window.open(congaUrl, '_self');
        }
    }
    handleVerifyOTP() {
        this.isLoading = true;
        // Replace this with your real OTP verification logic
        if(this.enteredOTP == '' || this.enteredOTP == null || this.enteredOTP == undefined) {
            this.isValidOTP = false;
            this.showToast('Error', 'Please enter valid token number', 'warning');
            return;
        }
         console.log('this.oldCHIFOTP==>'+this.oldCHIFOTP);
            console.log('this.enteredOTP==>'+this.enteredOTP);

        if (this.oldCHIFOTP == this.enteredOTP) {
            this.isValidOTP = true;
        } else {
            this.isValidOTP = false;
            this.showToast('Error', 'Token Number does not match', 'warning');
            this.isLoading = false;
            return;
        }
        this.isLoading = false;
    }

    handleCHIFSubmit() {
        console.log('CHIF ID: 1');
        createCHIFDetails({ 
            oppId: this.recordId, 
            towerId: this.towerId, 
            projectId: this.projectId,
            onBehalf: this.onbehalf,
            type: this.villaType
        })
        .then((result) => {
            if (result) {
                console.log('CHIF ID: 3',result);
                this.isAllValid = false;
                this.chifId = result.id;
                console.log('CHIF ID: 3', this.chifId);
                this.isCHIFSubmit = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'CHIF Submitted Successfully',
                    variant: 'success'
                }));
            } 
        })
        .catch(error => {
            console.error('Error submitting CHIF form:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }
}