import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import PanchShilLogo from '@salesforce/resourceUrl/PanchShilLogo';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import verifyPANdetails from '@salesforce/apex/EYI_PAN_AadharVerificationLwcController.verifyPANdetails';
import verifyDigilockerdetails from '@salesforce/apex/EYI_PAN_AadharVerificationLwcController.verifyDigilockerdetails';
import getApplicantData from '@salesforce/apex/EYI_PAN_AadharVerificationLwcController.getApplicantData';
export default class EKYCVerification extends LightningElement {
    @api recordId
    panCardBtnLabel = 'Verify PAN'
    aadharCardBtnLable = 'Verify AADHAR'
    panNumber
    panFullName
    panDOB
    isPanVerified = false
    isAadharVerified = false
    aadharNumber
    aadharfullName
    aadharGender
    aadharDOB
    currentUrl
    digiLockerRedirect = false
    digliLockerURL
    imageUrl = PanchShilLogo
    showPANAadharButtons = true
    showPanSection = false
    showAadharSection = false
    showPanError = false
    showAadharError = false
    errorMessages = ''
    isrecordPageUpload = false
    applicantFields = ['EYI_Applicants__c.EYI_Aadhar_Number__c', 'EYI_Applicants__c.EYI_Pancard_Number__c', 'EYI_Applicants__c.Is_PAN_EKYC_Completed__c', 'EYI_Applicants__c.Is_Aadhar_EKYC_Completed__c', 'EYI_Applicants__c.DigiLocker_Transaction_Id__c'];
    genderOptions = [
        { label: 'Male', value: 'M' },
        { label: 'Female', value: 'F' },
        { label: 'Transgender', value: 'T' }
    ];
    @wire(CurrentPageReference)
    setPageReference(currentPageReference) {
       if (currentPageReference) {
            this.currentUrl = window.location.href;
            console.log('currentUrl:'+ this.currentUrl);
            this.recordId = currentPageReference.state.appid;
            console.log('this.recordId2: ' + this.recordId);
            if (this.currentUrl.includes('EYI_Applicants__c')) {
                this.isrecordPageUpload= true;
            }
       }
    }
    connectedcallback(){
        console.log('recordID',this.recordId);
        //this.recordId = 'a0dC4000002Dw8HIAS';
    }

    @wire(getApplicantData, { applicantId: '$recordId'})
    applicantData({ error, data }) {
        if (data) {
            console.log('App data: ' + JSON.stringify(data));
            this.panNumber = data.EYI_Pancard_Number__c;
            this.aadharNumber = data.EYI_Aadhar_Number__c;
            this.isPanVerified= data.Is_PAN_EKYC_Completed__c;
            this.isAadharVerified = data.Is_Aadhar_EKYC_Completed__c;
            if(this.isAadharVerified){
                this.aadharCardBtnLable = 'AADHAR Verified';
            }else{
                this.aadharCardBtnLable = data.DigiLocker_Transaction_Id__c != null ? 'AADHAR IN Procees' : 'Verify AADHAR';
            }
            this.panCardBtnLabel = this.isPanVerified ? 'PAN Verified' : 'Verify PAN';
            
        } else if (error) {
            console.error('Error2: ' + JSON.stringify(error));
        }
    }

    

    handleButtonClick(event){
        const field = event.target.dataset.id;
        if(field === 'panButton'){
            this.showPANAadharButtons = false;
            this.showPanSection = true;
        }else{
            this.showPANAadharButtons = false;
            this.showAadharSection = true;
        }
    }

    handlePanSubmit(event){
        console.log('Nilesh')
        this.panFullName= this.refs.panFullName.value.trim().toUpperCase();
        this.panDOB = this.refs.panDOB.value;
        console.log('PAN Inputs: ' + this.panFullName + this.panDOB);  
        let isValidated = this.panValidations();
        console.log('PAN Validations: ' + isValidated + this.showPanError + this.errorMessages.length);
        if(isValidated){
           this.showPANAadharButtons =  this.verifyPanDetails();
        }
    }

    handleAadharSubmit(event){
        this.aadharfullName = this.refs.aadharFullName.value.trim().toUpperCase();
        this.aadharGender = this.refs.aadharGender.value;
        this.aadharDOB = this.refs.aadharDOB.value;
        console.log('Aadhar Inputs: ' + this.aadharfullName + this.aadharGender + this.aadharDOB);
        let isValidated = this.aadharValidations();
        if(isValidated){
            this.showPANAadharButtons = this.verifyAadharDetails();
        }
    }

    panValidations(){
        this.errorMessages = '';
        this.showPanError = false;
        let todayDate = new Date();
        let panDobValue = new Date(this.panDOB);
        if(this.panNumber == '' || this.panNumber == null || this.panNumber == undefined || this.panNumber.length !== 10){
            this.errorMessages += '10 Digit PAN Number is Required, ';
        }if(this.panFullName =='' || this.panFullName ==null || this.panFullName ==undefined){
            this.errorMessages += 'Full Name is Required, ';
        }if(this.panDOB =='' || this.panDOB ==null || this.panDOB ==undefined){
            this.errorMessages += 'DOB is Required, ';
        }if(panDobValue > todayDate){
            this.errorMessages  += 'DOB cannot be the future date, '
        }

        if(this.errorMessages != ''){
            this.errorMessages = this.errorMessages.slice(0, -2);
            this.showPanError = true;
        }
        return !this.showPanError;
    }

    aadharValidations(){
        this.errorMessages = '';
        this.showAadharError = false;
        if(this.aadharNumber =='' || this.aadharNumber ==null || this.aadharNumber ==undefined || this.aadharNumber.length !== 12 || /[^0-9]/.test(this.aadharNumber)){
            this.errorMessages += '12 Digit Aadhar Number is Required, ';
        }if(this.aadharfullName =='' || this.aadharfullName ==null || this.aadharfullName ==undefined){
            this.errorMessages += 'Full Name is Required, ';
        }if(this.aadharDOB =='' || this.aadharDOB ==null || this.aadharDOB ==undefined){
            this.errorMessages += 'DOB is Required, ';
        }if(this.aadharGender =='' || this.aadharGender ==null || this.aadharGender ==undefined){
            this.errorMessages += 'Gender is Required, ';
        }

        if(this.errorMessages != ''){
            this.errorMessages = this.errorMessages.slice(0, -2);
            this.showAadharError = true;
        }

        return !this.showAadharError;
    }

    verifyPanDetails(){
        verifyPANdetails({recAccId: this.recordId, panCardNumber: this.panNumber, name: this.panFullName, dob: this.panDOB})
        .then(result => {
            console.log('PanResponse:'+ result);
            if(result.includes('Success')){
                this.panKYCCompleted = true;
                this.isPanVerified = true;
                this.panCardBtnLabel = 'PAN Verified'
                this.showPANAadharButtons = true;
                this.showPanSection = false;
                this.showToastMessage('Success', 'success', 'PAN Verified Successfully!')
            }
        })
        .catch(error => {
            console.log('Pan Response Error: ' + error);
        });
    }

    verifyAadharDetails(){
        verifyDigilockerdetails({recAccId: this.recordId ,aadharCardNumber: this.aadharNumber, name: this.aadharfullName,gender:this.aadharGender, dob: this.aadharDOB,currentUrl:this.currentUrl})
        .then(result => {
            let data = JSON.parse(result);
            if(data.isSuccess == true){
                console.log('11');
                 this.digliLockerURL = data.redirectURL;
                 this.digiLockerRedirect = true;
                 this.aadharCardBtnLable = 'AADHAR In Process';
            }else{
                this.digiLockerRedirect = false;
            }
        })
        .catch(error =>{
            console.log('Aadhar Error: '+error);
        });
    }


    showToastMessage(title,variant, message){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
          });
          this.dispatchEvent(evt);
    }
}