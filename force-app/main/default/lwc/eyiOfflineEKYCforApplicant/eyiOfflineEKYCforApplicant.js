import { api, wire, track , LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import buttonPANandAadharforApplicant from '@salesforce/apex/EYI_PAN_AadharVerificationLwcController.buttonPANandAadharforApplicant';
import verifyPANdetails from '@salesforce/apex/EYI_PAN_AadharVerificationLwcController.verifyPANdetails';
import verifyDigilockerdetails from '@salesforce/apex/EYI_PAN_AadharVerificationLwcController.verifyDigilockerdetails';
import uploadDocument from '@salesforce/apex/EYI_PAN_AadharVerificationLwcController.uploadDocument';
import PanchShilLogo from '@salesforce/resourceUrl/PanchShilLogo'; // Import the static resource

export default class EyiOfflineEKYCforApplicant extends NavigationMixin(LightningElement) {
    @track confettiArray = [];
        containerClass = 'confetti-container';
        @api recordId;
        fileName;
        isrecordPageUpload = false;
        isLoading = false;
        errorMessage;
        currentUrl;
        imageUrl = PanchShilLogo ;
        recId;
        recAccount;//record details with field
        isError=false;
       isAadhar = false;
       isPAN = false;
       inputPAN = false;
       inputAadhar = false;
       aadharInProcess = false;
       aadharButtonLabel;
       panButtonLabel;
       panNumber ;
       fullName ;
       aadharfullName;
       aadhargender;
       dob;
       @api recAccId;
       isMessgaePAN = false;
       successMessagePAN;
       isMessgaeAadhar= false;
       aadharMessageDisplay;
       isredirect = false;
       digliLockerURL ;
       recAccountDetails = false;
       panKYCCompleted;
        aadharKYCCompleted ;
        fname ;
        lname ;
        companyCode ; 
        mobileNo; 
        emailId ; 
        sourcingManager;
        uploadSuccess = false;
        uploadError = false;
        isButtonDisabled = true; // Disable the proceed button by default
        filePreviewUrl = '/sfc/servlet.shepherd/document/download/068C4000004EWyhIAG'
        showPreview = false;
        contentDocumentID
        currentFileUploadName
        @track filesConDocID = {
            'aadhar' : '',
            'pan' : '',
            'address' : '',
            'other' : '',
            'company': ''
        }
        @track previewDisable={
            'aadhar' : true,
            'pan' : true
        }
       genderOptions = [
        { label: 'Male', value: 'M' },
        { label: 'Female', value: 'F' },
        { label: 'Transgender', value: 'T' }
    ];
       @wire(CurrentPageReference)
       setPageReference(currentPageReference) {
           // Retrieve the query parameters from the current page
           if (currentPageReference) {
            this.currentUrl = window.location.href;
            console.log('this.currentUrl-->'+this.currentUrl);
            this.recId = currentPageReference.state.recId;
               this.recAccId = currentPageReference.state.recAccId;
               this.recordId = currentPageReference.state.recordId;
               if(this.recordId) this.recAccId = this.recordId;
               console.log('this.recAccId-->'+this.recAccId);
               if (this.currentUrl.includes('EYI_Applicants__c')) {
                this.isrecordPageUpload= true;
                this.isAadhar = false;
                this.isPAN = false;
                this.recAccountDetails = false;
                }
    
               if(this.recAccId){
                  buttonPANandAadharforApplicant({appAccId:this.recAccId}).
                  then(result => {
                      console.log('result-->'+JSON.stringify(result));
                      console.log('result.is_PAN_E_KYC_Completed__c'+result.Is_PAN_EKYC_Completed__c);
                      if(result){
                        this.recAccountDetails = true;
                        if(result.Is_PAN_EKYC_Completed__c) this.panKYCCompleted = result.Is_PAN_EKYC_Completed__c;
                        if(result.Is_Aadhar_EKYC_Completed__c) this.aadharKYCCompleted = result.Is_Aadhar_EKYC_Completed__c;
                        if(result.EYI_First_Name__c){
                            this.fname = result.EYI_First_Name__c;
                        } else{
                            console.log('last name');
                            this.fname =  (result.Name).split(' ')[0];
                        }
                        if((result.Name).split(' ')[1]){
                            this.lname = (result.Name).split(' ')[1];
                        }else{
                            if(result.EYI_Last_Name__c) this.lname = result.EYI_Last_Name__c;
                        }
                        
                        this.fullName =  this.fname + ' ' + this.lname ;
                        this.aadhargender = result.EYI_Gender__c;
                        this.dob = result.EYI_Date_of_Birth__c;
                        this.aadharfullName = this.fname + ' ' + this.lname ;
                        this.aadhardob =  result.EYI_Date_of_Birth__c;
                        //if(result.Name) this.companyCode = result.Name; 
                        if(result.EYI_Mobile_Number__c) this.mobileNo = result.EYI_Mobile_Number__c; 
                        if(result.EYI_Email__c) this.emailId = result.EYI_Email__c; 
                        //if(result.Sourcing_Manager_Name__c) this.sourcingManager = result.Sourcing_Manager_Name__c;
                        if(result.EYI_Pancard_Number__c) this.panNumber = result.EYI_Pancard_Number__c;
                        if(result.EYI_Aadhar_Number__c) this.aadharNumber = result.EYI_Aadhar_Number__c;
                        if(this.panKYCCompleted){
                            
                            this.panButtonLabel =  'PAN Verified!';
                        }else{
                            this.panButtonLabel =  'PAN Verify';
                        }
                        if(this.aadharKYCCompleted){
                             this.aadharButtonLabel = 'AADHAR Verified!'
                        }else {
                            if(result.DigiLocker_Transaction_Id__c!=null){ this.aadharButtonLabel = 'AADHAR Verification Inprocess';this.aadharInProcess=true}
                            else this.aadharButtonLabel = 'AADHAR Verify'
                        }
                      }
                      //if(result.is_PAN_E_KYC_Completed__c) 
                    });
               }
               
               
           }
       }
       
       handlePreview(event){
        //this.showPreview = true;
        const field = event.target.dataset.id;
        let contentDocumentID = this.filesConDocID[field];
        console.log('let contentDocumentID: ' + contentDocumentID);
        this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'filePreview'
        },
        state: {
            selectedRecordId: contentDocumentID
        }
        }).then(() => {
            console.log('Navigation successful');
        }).catch(error => {
            console.error('Navigation error:', error);
        });
    }
    
       handlePANVerifyClick(event){
        this.isAadhar = false;
        this.isPAN = false;
        this.inputPAN= true;
        this.isMessgaePAN = false;
    
    
       }
       handleAadharVerifyClick(event){
        this.isAadhar = false;
        this.isPAN = false;
        this.inputAadhar= true;
    
    
       }
       connectedCallback(){
        
         console.log('this.recAccId-->'+this.recAccId);
         
        
       }
       renderedCallback() {
        
       }
       // Handle changes in input fields
       handleInputChange(event) {
        const field = event.target.dataset.id; // Get the field name (via data-id attribute)
        console.log('field-->'+field);
        if (field === 'panNumber') {
            this.panNumber = event.target.value.toUpperCase();
        } else if (field === 'fullName') {
            this.fullName = event.target.value.toUpperCase();
        } else if (field === 'dob') {
            this.dob = event.target.value;
        } else if(field ==='aadharNumber'){
            this.aadharNumber = event.target.value.replace(/,/g, '');;
        }else if(field === 'aadharfullName'){
            this.aadharfullName = event.target.value;
        }else if(field === 'aadhargender'){
            this.aadhargender = event.target.value;
        }else if(field === 'aadhardob'){
            this.aadhardob = event.target.value;
        }
        
    }
    
    
    // Handle form submission
      handleSubmit() {
        // You can add validation logic here if needed
        this.isLoading = true;
         this.isError = false;
        let messge = '';
        if(this.panNumber =='' || this.panNumber ==null || this.panNumber ==undefined || this.panNumber.length !== 10){
            messge = '10 Digit PAN Number is Required,';
            this.isError = true;
        }
        if(this.fullName =='' || this.fullName ==null || this.fullName ==undefined){
            messge = messge + '\n' + 'Full Name is Required,';
            this.isError = true;
        }if(this.dob =='' || this.dob ==null || this.dob ==undefined){
            messge = messge + '\n' + 'DOB is Required,';
            this.isError = true;
        }
        console.log('isErorr-->'+this.isError);
        console.log('messge-->'+messge);
        console.log('this.panNumber-->'+this.panNumber);
        console.log('this.fullName-->'+this.fullName);
        if(this.isError == true) {
            console.log('Inside error');
            this.isLoading = false;
            this.errorMessage = messge;
            this.isError=true;
            return;}
        else {this.errorMessage = '';this.isError=false;}
       
        /*if(isErorr == true){
            this.showErrorMessage(messge);
            this.isLoading = false;
            return;
        }*/
        
        if (this.panNumber && this.fullName && this.dob) {
            // Logic to handle the form submission (e.g., call an Apex method or another action)
            verifyPANdetails({recAccId: this.recAccId ,panCardNumber: this.panNumber, name: this.fullName, dob: this.dob})
            .then(result => {
                this.isLoading = false;
                console.log('result-->'+result);
                this.inputPAN = false;
                this.isMessgaePAN = true;
               this.successMessagePAN = 'PAN Card Verification Status is: '+result;
               this.isPAN = true;
               this.isAadhar = true;
               
               if(this.successMessagePAN.includes('Success')){this.panKYCCompleted = true;}
                 })
            .catch(error => {
                console.log('error-->'+error);
                this.isLoading = false;
              });;
            }
            else{
                this.isLoading = false;
            }
      }
      handleSubmitAadhar() {
        this.isLoading = true;
         this.isError = false;
        let messge = '';
        
        if(this.aadharNumber =='' || this.aadharNumber ==null || this.aadharNumber ==undefined || this.aadharNumber.length !== 12 || /[^0-9]/.test(this.aadharNumber)){
            messge = '12 Digit Aadhar Number is Required,';
            this.isError = true;
        }
        if(this.aadharfullName =='' || this.aadharfullName ==null || this.aadharfullName ==undefined){
            messge = messge + '\n' + 'Full Name is Required,';
            this.isError = true;
        }if(this.aadhardob =='' || this.aadhardob ==null || this.aadhardob ==undefined){
            messge = messge + '\n' + 'DOB is Required,';
            this.isError = true;
        }if(this.aadhargender =='' || this.aadhargender ==null || this.aadhargender ==undefined){
            messge = messge + '\n' + 'Gender is Required,';
            this.isError = true;
        }
        console.log('isErorr-->'+this.isError);
        console.log('messge-->'+messge);
        console.log('this.panNumber-->'+this.aadharNumber);
        console.log('this.fullName-->'+this.aadharfullName);
        console.log('this.aadhargender-->'+this.aadhargender);
        if(this.isError == true) {
            console.log('Inside error');
            this.isLoading = false;
            this.errorMessage = messge;
            this.isError=true;
            return;}
        else {this.errorMessage = '';this.isError=false;}
        if (this.aadharNumber && this.aadharfullName && this.aadhargender && this.aadhardob) {
            // Logic to handle the form submission (e.g., call an Apex method or another action)
            verifyDigilockerdetails({recAccId: this.recAccId ,aadharCardNumber: this.aadharNumber, name: this.aadharfullName,gender:this.aadhargender, dob: this.aadhardob,currentUrl:this.currentUrl})
            .then(result => {
                this.isLoading = false;
         
                console.log('before error-->'+result);
                console.log('result-->'+JSON.parse(result));
                let data = JSON.parse(result);
                if(data.isSuccess == true){
                    console.log('11');
                    this.aadharMessageDisplay= data.desRes;
                    this.inputAadhar = false;
                     this.digliLockerURL = data.redirectURL;
                     this.isredirect = true;
                     this.isMessgaeAadhar = true;
                }else{
                    this.aadharMessageDisplay= data.desRes;
                    this.inputAadhar = false;
                    this.isMessgaeAadhar = true;
                    this.isredirect = false;
                }
              
                })
            .catch(error => {
                console.log('error-->'+error);
                this.isLoading = false;
              });;
            }
            else{
                this.isLoading = false;
            }
      }
      showErrorMessage(message) {
        console.log('message in showtoast-->'+message);
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(event);
    }
    handleFileUpload(event) {
    const uploadedFiles = event.detail.files;
    let fileName = event.target.dataset.id;
    console.log('fileName-->'+fileName);
    this.previewDisable[fileName] = false;
    if (uploadedFiles.length > 0) {
        const contentDocumentID = uploadedFiles[0].documentId;
        this.filesConDocID[fileName] =  contentDocumentID;
    }
    this.isButtonDisabled = !Object.values(this.previewDisable).every(value => value === false);
    }
    
    
    uploadFile(file) {
        const reader = new FileReader();
        this.fileName = file.name;
        console.log('this.fileName-->'+this.fileName);
        reader.onloadend = () => {
            // Get the base64 encoded file content
            const base64Data = reader.result.split(',')[1]; // Remove the data URL prefix
            // Call Apex method to handle the document upload
            uploadDocument({ base64Data: base64Data, recordId: this.recordId , filename : this.fileName})
                .then((data) => {
                    this.contentDocumentID = data;
                    this.filesConDocID[this.currentFileUploadName] = this.contentDocumentID;
                    console.log('this.filesConDocID: ' + JSON.stringify(this.filesConDocID));
                    console.log('contentDocumentID:' + data);
                    this.uploadSuccess = true;
                    this.uploadError = false;
                    this.isButtonDisabled = false; // Enable the proceed button
                })
                .catch((error) => {
                    this.uploadError = true;
                    this.uploadSuccess = false;
                    console.error('Error in file upload: ', error);
                });
        };
        // Read the file as a data URL (base64 encoded)
        reader.readAsDataURL(file);
    }
    handleProceed() {
        // You can add any logic here when the proceed button is clicked
        // For example, you could navigate to another page or perform an action
        console.log('Proceeding with the uploaded document...');
        this.isAadhar = true;
        this.isPAN = true;
        this.recAccountDetails = true;
        this.isrecordPageUpload = false;
    }
}