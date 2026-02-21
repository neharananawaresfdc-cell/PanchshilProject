import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OBJECT from '@salesforce/schema/EYI_Customer_Visit_Information__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import OPPID_FIELD from '@salesforce/schema/EYI_Customer_Information_Form__c.EYI_Opportunity__c';
import OTP_FIELD from '@salesforce/schema/EYI_Customer_Information_Form__c.EYI_Backend_OTP__c';
import EMAIL_FIELD from '@salesforce/schema/EYI_Customer_Information_Form__c.EYI_Email_Id__c';
import MOB_FIELD from '@salesforce/schema/EYI_Customer_Information_Form__c.EYI_Mobile_number__c';
import sendOTPEmailForCif from "@salesforce/apex/EYI_CifFormCreation.sendOTPEmailForCif";
import createOpportunityTeams from "@salesforce/apex/EYI_CifFormCreation.createOpportunityTeams";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CifRevisitForm extends LightningElement {
    ojectApiName = OBJECT;
    // vistDate = VISIT_DATE;
    // visitTime = VISIT_TIME;
    // visitingWith = VISITING_WITH;
    defaultTimeValue;
    defaultDateValue;
    isSpinner = false;
    @api cifId;
    generatedOTP = '';
    isOTPGenerated = false;
    @track closingManager = '';
    get OpportunityId() {
        return getFieldValue(this.cif.data, OPPID_FIELD);
    }
    get backendOTP() {
        return getFieldValue(this.cif.data, OTP_FIELD);
    }
    get email(){
        return getFieldValue(this.cif.data, EMAIL_FIELD);
    }
    get mobileNo(){
        return getFieldValue(this.cif.data, MOB_FIELD);
    }
    // CifID;

    // Event to notify parent component that child component has loaded
    @wire(getRecord, { recordId: '$cifId', fields: [OPPID_FIELD,OTP_FIELD,MOB_FIELD,EMAIL_FIELD] })
    cif;

    
    connectedCallback() {
        // Set the default time value
        this.isSpinner = true;
        const now = new Date();
        const hours = now.getHours();
        const minutes = now.getMinutes();
        const seconds = now.getSeconds();
        this.defaultDateValue = new Date().toISOString();
        this.defaultTimeValue = `${this.formatNumber(hours)}:${this.formatNumber(minutes)}:${this.formatNumber(seconds)}`;

        setTimeout(() => {
            this.isSpinner = false;
        }, 2000)
    }

    formatNumber(value) {
        return value < 10 ? `0${value}` : `${value}`;
    }

    //visitingWithOptions;
    //recordTypeId;
    // date = new Date().toISOString();
    // time //= new Date().toLocaleTimeString();

    // newRecordDetails = {
    //     date: null,
    //     time: null,
    //     visitingWith: null,
    //     cifid: this.cifId
    // }


    // @wire(getObjectInfo, { objectApiName: OBJECT })
    // objectinfo({ data, error }) {
    //     if (data) {
    //         this.recordTypeId = data.defaultRecordTypeId;
    //         console.log('data', OBJECT, data);
    //         console.log('this.cifId', this.cifId);
    //     } else {
    //         console.log(error);
    //     }
    // }

    // @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: VISITING_WITH })
    // visitingWithValues({ data, error }) {
    //     if (data) {
    //         this.visitingWithOptions = [...data.values];
    //         console.log('visitingWithOptions', OBJECT, data.values);
    //     } else {
    //         console.log(error);
    //     }
    // }


    // handleChange(e) {
    //     this.newRecordDetails.cifid = this.cifId;
    //     if (e.target.fieldName === VISIT_DATE.fieldApiName) {
    //         this.newRecordDetails.date = e.target.value;
    //     } else if (e.target.fieldName === VISIT_TIME.fieldApiName) {
    //         this.newRecordDetails.time = e.target.value;
    //     } else if (e.target.name === "Visiting With") {
    //         this.newRecordDetails.visitingWith = e.target.value;
    //     }
    // }

    // handleSave() {
    //     const fields = {};
    //     console.log("time", this.newRecordDetails);
    //     fields[VISIT_DATE.fieldApiName] = this.newRecordDetails.date;
    //     fields[VISIT_TIME.fieldApiName] = this.newRecordDetails.time;
    //     fields[VISITING_WITH.fieldApiName] = this.newRecordDetails.visitingWith;
    //     fields[CIF.fieldApiName] = this.newRecordDetails.cifid;

    //     console.log("fields", fields);
    //     //4. Prepare config object with object and field API names 
    //     const recordInput = {
    //         apiName: OBJECT.objectApiName,
    //         fields: fields
    //     };

    //     //5. Invoke createRecord by passing the config object
    //     createRecord(recordInput).then((record) => {
    //             console.log("saved", record);
    //             // Publish a toast message
    //             const toastEvent = new ShowToastEvent({
    //                 title: 'Success',
    //                 message: 'Record Saved Successfully',
    //                 variant: 'success'
    //             });
    //             this.dispatchEvent(toastEvent);
    //             window.location.reload(); // Reload the form
    //         })
    //         .catch(error => {
    //             // Handle error
    //             console.error('Error saving record', error);
    //             const toastEvent = new ShowToastEvent({
    //                 title: 'Error',
    //                 message: 'An error occurred while saving the record',
    //                 variant: 'error'
    //             });
    //             this.dispatchEvent(toastEvent);
    //         });
    // }
    sendOTPEmail() {
        console.log('inside sendOTPEmail');
        console.log('email --> ', this.email);
        console.log('Phone --> ', this.mobileNo);
        console.log('cifId --> ', this.cifId);
        this.isSpinner = true;
        sendOTPEmailForCif({ email: this.email, phNo: this.mobileNo, cifId:  this.cifId })
            .then(result => {
                // Handle success
                if (result != '' && result != 0) {
                    this.isOTPGenerated = true;
                    this.generatedOTP = result;
                    console.log('result --> ', result);
                    console.log('OTP sent successfully');
                    const toastEvent = new ShowToastEvent({
                        title: 'OTP Sent',
                        message: 'OTP sent successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(toastEvent);
                    //this.sendOTPSms();
                    this.isSpinner = false;
                }

            })
            .catch(error => {
                // Handle error
                console.error('Error sending OTP:', error);
                this.isSpinner = false;
            });
    }
    handleCreateTeam() {
        
        console.log('this.OpportunityId --> ', this.OpportunityId);
        console.log('this.closingManager --> ', this.closingManager);
        debugger;
        createOpportunityTeams({ OppId: this.OpportunityId, userId: this.closingManager })
            .then(result => {
                // Handle success
                console.log('Opportunity Team created successfully',result);
            })
            .catch(error => {
                // Handle error
                console.error('Error creating Opportunity Team: ', error);
            });
    }
    handleSubmit(event) {
        event.preventDefault();
        console.log("CIF ID : ", this.cifId);
        this.isSpinner = true;
        if(this.validateSubmit()){
            this.handleCreateTeam();
            const fields = event.detail.fields;
            console.log("fields handleSubmit", fields);
            fields.EYI_Customer_Information_Form__c = this.cifId;
            console.log('Customer Information ID : ' + JSON.stringify(fields.EYI_Customer_Information_Form__c));
            console.log('Visiting With : ' + JSON.stringify(fields.EYI_Visiting_With__c));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        else{
            setTimeout(() => {
            this.isSpinner = false;
        }, 1000)
        }
    }
    validateSubmit(){
		let isValid = true;
		let unfilledField = [];
		// let unfilledAccSecForm = [];
        //&& field.fieldName != 'EYI_Lead_Enquiry__c'
		const requiredFields = this.template.querySelectorAll("lightning-input-field , lightning-combobox");
		requiredFields.forEach(field => {
			console.log('inside foreach');
			if (!field.value && field.required && field.fieldName != 'isKYCDone__c' ) {
				console.log('inside field: ' , field.fieldName,field.value,field,field.parentElement);
				isValid = false;
				field.reportValidity();
				unfilledField.push(field);
			}
            if(field.fieldName == 'EYI_Secondary_Closing_Manager__c'){
                this.closingManager = field.value;
            }
            if(field.fieldName == 'EYI_Revisiting_OTP__c'){
                try{
                    if(field.value != this.backendOTP && field.value != this.generatedOTP){
                        console.log('in OTP', field.value, this.backendOTP);
                        field.reportValidity();
                        isValid = false;
                        unfilledField.push(field);
                        const toastEvent = new ShowToastEvent({
                            title: 'OTP Invalid',
                            message: 'Please enter valid OTP',
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                    }
                }
                catch(err){
                    isValid = false;
                    unfilledField.push(field);
                    console.log('in OTP catch', JSON.stringify(err),err);
                }               
            }
		});
		setTimeout(()=>{
            try{
                unfilledField[0].focus();
            }
            catch(e){
                console.log(e);
            }
			
		},100);			
		return isValid;
	}
    handleSuccess(event) {
        console.log("saved", event);
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Record Saved Successfully',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
        window.location.reload();
    }

    handleError(event) {
        console.error('Error saving record', event.detail.detail);
        console.error('Error saving record', JSON.stringify(event.detail));
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'An error occurred while saving the record',
            variant: 'error'
        });
        this.dispatchEvent(toastEvent);
    }

}