import { LightningElement, api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NAME_FIELD from '@salesforce/schema/EYI_Applicants__c.Name';
import AADHAR_NUMBER_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Aadhar_Number__c';
import DOB_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Date_of_Birth__c';
import DesignationType_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Designation_Type__c';
import EMAIL_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Email__c';
import GENDER_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Gender__c';
import PHONE_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Mobile_Number__c';
import PAN_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Pancard_Number__c';
import APPLICANTTYPE_FIELD from '@salesforce/schema/EYI_Applicants__c.EYI_Applicant_Type__c';
export default class CreateApplicant extends LightningElement {
    objectApiName = 'EYI_Applicants__c';
    @api recordId;
    @track oppyData
    bookingId;
    salutation = true;
    CustomerResStatus = true;
    showButton = false;
    isLoading =  false;
    fields = [NAME_FIELD, APPLICANTTYPE_FIELD, EMAIL_FIELD,PHONE_FIELD,PAN_FIELD, AADHAR_NUMBER_FIELD, DOB_FIELD,GENDER_FIELD, DesignationType_FIELD]
    opptyFields = ['Id', 'Opportunity.EYI_Booking__c', 'Opportunity.AccountId'];

    @wire(getRecord, { recordId: '$recordId', fields:'$opptyFields'})
    wiredOppty({ error, data }) {
        if (data) {
            console.log('Opp data: ' + JSON.stringify(data))
            this.bookingId = data.fields.EYI_Booking__c.value;
        } else if (error) {
            console.error('Error: ' + error);
        }
    }

    // handleSubmit(event){
    //     event.preventDefault();
    //     const fields = event.detail.fields;
    //     console.log('submitFields:' + JSON.stringify(fields));
    //     fields.EYI_Booking__c = this.bookingId;
    //     fields.Opportunity__c = this.recordId;
    //     fields.EYI_Last_Name__c = fields.Name;
    //     this.template.querySelector('lightning-record-form').submit(fields);
    // }

    handleSubmit(event){

        event.preventDefault();
        const fields = event.detail.fields;
        fields.EYI_Booking__c = this.bookingId;
        fields.Opportunity__c = this.recordId;
        fields.EYI_Last_Name__c = fields.Name;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showButton =  true;
        this.isLoading = true;
    }
     get isIndividual() {
        // Return true if salutation is not 'Company'
        return this.salutation !== 'Company' && this.salutation !== 'M/s.' && this.CustomerResStatus !== 'NRI';
    }
    handleSalutationChange(event){
        this.salutation = event.detail.value;
    }
    handleCustomerResStatusChange(event){
        this.CustomerResStatus = event.detail.value;
    }
    handleSuccess(event){
        this.closeQuickAction();
        this.showToast('Success!', 'success', 'Applicant record created successfully !');
    }


    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant : variant,
            message:message
        });
        this.dispatchEvent(event);
    }

}