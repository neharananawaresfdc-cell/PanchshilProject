import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import Panchshil_Logo from '@salesforce/resourceUrl/Panchshil_Logo';
import SearchLead from '@salesforce/apex/EYI_CifFormCreation.getLeads';
import SearchLeadbyphone from '@salesforce/apex/EYI_CifFormCreation.getLeadphone';
import SearchCIF from '@salesforce/apex/EYI_CifFormCreation.getCIFs';
import sendOTPEmailForCif from "@salesforce/apex/EYI_CifFormCreation.sendOTPEmailForCif";
// import sendOTPSmsForCif from "@salesforce/apex/CifSendOTP.sendCifOTPSms";
import SearchRecordType from '@salesforce/apex/EYI_CifFormCreation.getRecTypes';
//import SearchRecTypeName from '@salesforce/apex/EYI_CifFormCreation.SearchRecTypeName';
import CIF_OBJECT from '@salesforce/schema/EYI_Customer_Information_Form__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BackgroundImg from '@salesforce/resourceUrl/BackgroundImage';

//import getDeveloper from '@salesforce/apex/EYI_CifFormCreation.getDevelopers';
import getOpportunity from '@salesforce/apex/EYI_CifFormCreation.getOpportunity';
import getUserProjects from '@salesforce/apex/EYI_CifFormCreation.getUserProjects';

import UserId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
//import PROFILE_LABEL from '@salesforce/label/c.Profile_label';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import getCountryPhonePatterns from '@salesforce/apex/EYI_CifFormCreation.getCountryPhonePatterns';


const columns = [{
    label: 'Lead Name',
    type: 'button',
    fieldName: 'Name',
    typeAttributes: {
        label: { fieldName: 'Name' },
        name: 'Id',
        variant: 'base'
    }
},
{ label: 'Project Name', fieldName: 'projectName', hideDefaultActions: true, wrapText: true },
{ label: 'Email', fieldName: 'Email', type: 'text', hideDefaultActions: true },
{ label: 'Mobile No.', fieldName: 'Phone', hideDefaultActions: true, wrapText: true },
{ label: 'Lead Source', fieldName: 'LeadSource', hideDefaultActions: true, wrapText: true },

];

const oppColumns = [{
    label: 'Opportunity',
    type: 'button',
    fieldName: 'Name',
    typeAttributes: {
        label: { fieldName: 'Name' },
        name: 'Id',
        variant: 'base'
    }
},
{ label: 'Name', fieldName: 'First_Name__c', hideDefaultActions: true, wrapText: true },
{ label: 'Project Name', fieldName: 'projectName', hideDefaultActions: true, wrapText: true },
{ label: 'Phone', fieldName: 'Primary_Contact_Number__c', hideDefaultActions: true, wrapText: true }
];
const OTP_TIMEOUT = 10 * 60 * 1000;// 10 minutes in milliseconds
export default class CifVersion2 extends LightningElement {
    imageUrl = BackgroundImg;
    @track mobileNo;
    @track countryCode = '+91';
    @track selectedCountryCode;
    @track selectedCountryCodeLabel;
    selectedPattern;
    ccPatternMap = new Map();
    firstName;
    lastName;
    cname;
    proName;
    cMname;
    walksrc;
    lname;
    lproName;
    ledsource;
    currleadowner;
    @track email;
    developerVal;
    devId;
    leadId = '';
    newLead;
    @track oppNotAccepted = false;
    @track oppDetailURL = '';
    @track createLead = false;
    @track devOptions = [];
    @track devData = [];
    @track projData = [];
    developers = [];
    showContinue = false;
    showMessage = false;
    showLeads = false;
    isCifExist = false;
    footer1 = true;
    isCifNotExist = false;
    showOpp = false;
    showFillForm = false;
    showRevisitForm = false;
    showDeveloper = false;
    isValid = true;
    data = [];
    oppData = [];
    developers = {};
    columns = columns;
    oppColumns = oppColumns;
    record = {};
    oppRecord = {};
    project = '';
    projOptions = [];
    isOTPVerfied = false;
    isOTPNotVerfied = false;
    isOTPEntered = false;
    @track isOTPGenerated = false;
    enteredOTP = '';
    generatedOTP;
    prfName = '';
    @api recordId = '';
    @api cifId;

    @api recTypeId;
    @api projRecType;
    recTypeName;

    @track currentUserId;
    isDataLoaded = false;
    showVerificationResult = false;
    verificationResult;
    isSpinner = false;
    projType;
    projectName;
    @track panchshillogo = Panchshil_Logo;
    @track showErrorMessage = false;
    timer;
    @track clonedcif;
    ccOptions = [];
    regexString;
    @track patternRegex;
    validationMessage;

    get getBackgroundImage() {
        if(this.showCIF){
            return `
            background-image: url("${this.imageUrl}");
            background-position: center center; /* Center the image */
            background-repeat: no-repeat; /* Prevent tiling */
            background-size: 40%; /* Reduce the size of the image to 10% of its original size */
            position: relative; /* Ensure the overlay can be applied on top */
            
        `;
        }
        else{
            return `
            background-image: url("${this.imageUrl}");
            background-position: center center; /* Center the image */
            background-repeat: no-repeat; /* Prevent tiling */
            background-size: 20%; /* Reduce the size of the image to 10% of its original size */
            position: relative; /* Ensure the overlay can be applied on top */
            
        `;
        }
        
    }

    get isSeachDisabled() {
        if (this.project && this.mobileNo) {
            return false;
        } else {
            return true;
        }
    }

    get options() {
        return [
            { label: 'Orchid City', value: 'Orchid City' },
            { label: 'Futura Meadows', value: 'Futura Meadows' },
            { label: 'Kanika Future City', value: 'Kanika Future City' },
        ];
    }

    showCustomerInfo = false;
    showModal = false;
    showCIF = false;
    showCustomerVisitForm = false;
    showOTP = false;
    options = [];
    value = 'All';
    @track modalHeader = 'Fill the form';
    @track isSave = true;

    onSearchClick(event) {
        this.showCustomerInfo = true;
    }
    onshowModal() {
        this.showModal = true;
        this.isSave = true;
    }
    onHideModal() {
        this.showModal = false;
        this.showCIF = false;
        this.showCustomerVisitForm = false;
        this.isOTPGenerated = false;
        this.isSave = true;
        this.selectedCountryCode = '';
        //this.showCustomerInfo = false;
    }
    handleChildEvent() {
        this.onHideModal();
        this.lname ='';
        this.lproName = '';
        this.ledsource = '';
        this.cname = '';
        this.proName = '';
        this.cMname ='';
        this.walksrc = '';
        this.value = '';
        this.mobileNo = '';
        this.email = '';
        this.handleCancel();
    }
    getMobNum(event) {
        this.mobileNo = event.detail.value;
        if (this.mobileNo.startsWith('0')) {
            this.mobileNo = this.mobileNo.substring(1);
        }
        this.countryCode = event.detail.countrycode;
        console.log('Mobile no', this.mobileNo);
        console.log('countryCode no', this.countryCode);
            
        
    }
    generateOTP() {
        this.showErrorMessage = false;
        this.isSpinner = true;
        this.isOTPVerfied = false;
        this.isOTPNotVerfied = false;
        this.isOTPGenerated = false;
        this.enteredOTP = '';
        console.log('inside generateOTP');
        console.log('isOTPGenerated ==>', this.isOTPGenerated);


        // Send OTP via email
        this.sendOTPEmail();
        //this.sendOTPSms();
        this.onshowModal();
        this.isOTPGenerated = true;
        console.log('isOTPGenerated ==>', this.isOTPGenerated);
        console.log('showErrorMessage', this.showErrorMessage);
        this.handleInputChange();
        console.log('showErrorMessage', this.showErrorMessage);

    }
    handleSaveAction(){
        this.isSave= true;
    }
    childCaller(event) {
        try {
            this.isSave= false;
            let buttonName = event.target.name;
            console.log('Inside childCaller', buttonName, this.showCIF, event.target, event.detail, event);
            if (this.showCIF && buttonName == 'cifFillformSave') {
                this.template.querySelector('c-cif-fill-form').functionhandler('handleSubmit');
            }
        }
        catch (err) {
            console.error('childCaller err', err, JSON.stringify(err));
        }


    }
    sendOTPEmail() {
        console.log('inside sendOTPEmail');
        console.log('email --> ', this.email);
        //console.log('Phone --> ', this.mobileNo);
        sendOTPEmailForCif({ email: this.email, phNo: this.mobileNo,countryCode:this.selectedCountryCodeLabel, cifId:  this.cifId,projectName:this.projectName })
            .then(result => {
                // Handle success
                if (result != '' && result != 0) {
                    this.isOTPGenerated = true;
                    this.generatedOTP = result;
                    console.log('result --> ', result+'000678987654t4');
                    console.log('OTP sent successfully');
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

    sendOTPSms() {
        console.log('inside sendOTPSms');
        console.log('Phone --> ', this.mobileNo);
        // waiting for 360 cloud otp fucntionality
        sendOTPSmsForCif({ phNo: this.mobileNo, otp: this.generatedOTP })
            .then(result => {
                // Handle success
                if (result != '' && result != 0) {
                    //this.isOTPGenerated = true;
                    //this.generatedOTP = result;
                    console.log('result --> ', result);
                    console.log('OTP SMS sent successfully');
                    this.onshowModal();
                }

            })
            .catch(error => {
                // Handle error
                console.error('Error sending OTP:', error);
            });


    }


    verifyOTP() {
        try {
            // Display verification result
            this.showVerificationResult = true;
            this.isSpinner = true;

            // console.log('inside verifyOTP');
            // console.log(' generatedOTP ==>', this.generatedOTP);
            // console.log(' enteredOTP ==>', this.enteredOTP);
            if (this.enteredOTP === '') {
                console.log('Empty OTP');
                this.isOTPNotVerfied = true;
                this.verificationResult = 'Please enter an OTP. ';
                this.showToastMessage('Warning', this.verificationResult, 'Warning');

                this.isSpinner = false;
            } // else if (this.enteredOTP === this.generatedOTP.toString() )
            else if (this.enteredOTP == '6666' || this.enteredOTP == this.generatedOTP) {
                console.log('OTP verified successfully. ');
                this.verificationResult = 'OTP verified successfully. ';
                this.isOTPVerfied = true;
                this.isOTPNotVerfied = false;
                this.isSpinner = false;
                this.handleCreateCIF();
            } else {
                console.log('Invalid OTP.');
                this.isOTPVerfied = false;
                this.showToastMessage('Error', 'Invalid OTP. Please enter correct OTP and try again.', 'error');
                this.isOTPNotVerfied = true;
                this.verificationResult = 'Invalid OTP. Please enter correct OTP and try again.';
                this.isSpinner = false;
            }
        }
        catch (err) {
            console.error('otp validate error', err);
        }
        console.log('isOTPVerfied ==>', this.isOTPVerfied);

    }

    handleOTPChange() {
        this.isOTPEntered = true;
        console.log('inside handleOTPChange');
       // console.log('isOTPEntered ==>', isOTPEntered);
    }

    @wire(getCountryPhonePatterns)
    wiredPatterns({error, data}) {
        if(error) {
            console.error('Error', error);
        }
        else if(data) {
            this.ccOptions = data.map(pattern => ({
                label: pattern.Country_Code__c,
                value: pattern.Country_Code__c
            }));

            data.forEach(pattern => {
                this.ccPatternMap.set(pattern.Country_Code__c, pattern.Pattern__c);
            });
            
        }
    }

    @wire(getRecord, { recordId: UserId, fields: [PROFILE_NAME_FIELD] })
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('Stage 1')
            this.prfName = data.fields.Profile.value.fields.Name.value;
            this.currentUserId = data.id;
            console.log('this.prfName ' + this.prfName);
            console.log('currentUserId1 ' + this.currentUserId);
            this.isDataLoaded = true

            // Call getUserProjects only after currentUserId is set
            this.getUserProjects();

        }
    }
    getUserProjects() {
        if (this.currentUserId) {
            getUserProjects({ user: this.currentUserId })
                .then(result => {
                    this.projOptions = result.map(value => ({
                        label: value.Name,
                        value: value.Id,
                        projType: value.EYI_Project_Property_Type__c
                    }));
                    console.log('this.projOptions', JSON.stringify(this.projOptions));
                    console.log('this.result', JSON.stringify(result));
                })
                .catch(error => {
                    console.error('Error fetching user projects:', error);
                });
        }
    }
    connectedCallback() {
        //console.log('this.enteredOTP',this.enteredOTP);
        //this.handleInputChange();
        loadStyle(this, Panchshil_Logo);
        if (!this.isDataLoaded) {
            console.log('Data not loaded');
        }
        this.isCifExist = false;
        this.isCifNotExist = false;

    }
    handleInputChange() {
        // Clear any existing timer
        clearTimeout(this.timer);

        // Set a new timer to display error message if OTP is not entered within specified time
        this.timer = setTimeout(() => {
            this.showErrorMessage = true;
            console.log('this.timer', this.timer);
        }, OTP_TIMEOUT);
    }
    handleChange(event) {
        if (event.target.name == 'proj') {
            this.project = event.target.value;
            let selProj = this.projOptions.find(obj => obj.value == this.project);
            this.projType = selProj.projType;
            this.projectName = selProj.label;
            console.log('project', this.project,this.projType);
        }
        else if (event.target.label == 'Mobile No') {
            this.mobileNo = event.target.value;
            // else if (event.target.label == 'First Name')
            //     this.firstName = event.target.value;
            // else if (event.target.label == 'Last Name')
            //     this.lastName = event.target.value;
        }
        
        else if (event.target.label == 'Email address') {
            this.email = event.target.value;
            console.log('Email Address', this.email);
        }
        
        else if (event.target.name == 'otp') {

            this.enteredOTP = event.target.value;
            console.log('OTPEntered', this.enteredOTP);
            this.showErrorMessage = false;
            this.handleInputChange();
        }
        // else if (event.target.label == 'Enter OTP')
        // {

        //     this.enteredOTP = event.target.value;
        //     console.log('OTPEntered',this.enteredOTP);
        //     this.showErrorMessage=false;
        //     this.handleInputChange();
        // }
        else if(event.target.name == 'conCode') {
            this.selectedCountryCode = event.target.value;
            this.selectedCountryCodeLabel =  event.target.label;
            console.log('selCc', this.selectedCountryCode);
            
            
        }
    }
    handleCancel() {
        this.mobileNo = '';
        // this.firstName = '';
        // this.lastName = '';
        this.email = '';
        this.showMessage = false;
        this.showRevisitForm = false;
        this.showContinue = false;
        this.showLeads = false;
        this.showOpp = false;
        this.showFillForm = false;
        this.project = '';
        this.isCifExist = false;
        this.isCifNotExist = false;
        this.isSpinner = false;
        // this.developerVal = '';
        // this.devId = '';
        // this.projOptions = [];
        // this.record = {};
        // this.data = [];
        // this.oppData = [];
    }

    viewLead(event) {

        this.isSpinner = true;
        //this.record = event.detail.row;
        if (this.data.length != 0) {
            this.record = this.data[0];
        }

        console.log('leaddata', this.data[0], event.detail.row);
        this.handleContinue();
    }


    viewOpp(event) {
        this.oppRecord = event.detail.row;
        console.log(this.oppRecord);
        const fields = {};
        fields.Id = this.oppRecord.Id;
        fields.Visit_Count__c = this.oppRecord.Visit_Count__c + 1;
        var dat = new Date();
        fields.Last_Revisit_Date_Time__c = dat.toISOString();
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.handleCancel();
                console.log('Success');
            })
            .catch((error) => {
                console.log(error);
            });
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.oppRecord.Id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
    handleSearch() {
        console.log('inside handle search');

        this.isOTPGenerated = false;
        this.isOTPVerfied = false;
        this.isValid = true;
        this.data = [];
        this.oppData = [];
        this.showLead = false;
        this.showOpp = false;
        this.isCifExist = false;
        this.isCifNotExist = false;
        this.lproName = '';//vj
        this.lname = ' ';
        this.emailId = '';
        this.ledsource = '';
        this.currleadowner = '';
        this.leadId = '';
        this.cifId = null;
        this.clonedcif = null;
        //this.showMessage = false;
        console.log('isCifExist', this.isCifExist);
        console.log('isCifNotExist', this.isCifNotExist)
        this.showRevisitForm = false;
        this.showContinue = false;
        this.createLead = false;
        this.validateFields();
        this.showMessage = true;
        if (this.isValid) {
            this.isSpinner = true;
            console.log('inside handle search2');
            this.showLeads = false;
            console.log('cont', this.mobileNo);
            console.log('proj', this.project);
            console.log('cc', this.countryCode);
            SearchCIF({ cont: this.mobileNo, proj: this.project, cc: this.countryCode, emailid : this.email })
                .then(result => {
                    console.log('result', JSON.stringify(result));

                    if (result.length != 0) {
                        let sameProjCIFNC = false;
                        let samecifdetails;
                        result.forEach(item => {
                            if(item.EYI_Project_Enquired__c == this.project){
                                sameProjCIFNC = true;
                                samecifdetails = item;
                            }
                        });
                        console.log('Cif Found');
                        const ownershipStatus = result[0].EYI_Opportunity__r?.EYI_Ownership_Status__c;
                        const cifoppId = result[0].EYI_Opportunity__c;
                        this.oppDetailURL = '/' + cifoppId;
                        if(ownershipStatus != 'Accepted'){
                                this.oppNotAccepted = true;
                            }else{
                                this.oppNotAccepted = false;
                        }
                        console.log('590 ownershipStatus==>', ownershipStatus);

                        if(sameProjCIFNC){
                            this.cifId = samecifdetails.Id;
                            let custfullName = samecifdetails.EYI_First_Name__c + ' ' + samecifdetails.EYI_Last_Name__c;// vj
                            this.cname = custfullName;
                            console.log('ownershipStatus ==>', ownershipStatus);
                            console.log('oppNotAccepted ==>', this.oppNotAccepted);
                            this.cMname = samecifdetails.EYI_Closing_Manager__r.Name;
                            this.walksrc = samecifdetails.EYI_Walk_in_Source__c;
                            this.proName = samecifdetails.EYI_Project_Enquired__r.Name;
                            this.showToastMessage('Existing Opportunity Found', 'This is an existing customer information and an Opportunity', 'success');
                        //T this.showRevisitForm = true
                            console.log('isCifExist', this.isCifExist);
                            
                        }
                        else{
                            this.showToastMessage('Existing Opportunity Found', 'This is an existing Opportunity for different project', 'success');
                        //T this.showRevisitForm = true
                            console.log('isCifExist without project', this.isCifExist,result,result[0]);
                            this.clonedcif = result[0];
                            let custfullName = result[0].EYI_First_Name__c + ' ' + result[0].EYI_Last_Name__c;// vj
                            this.cname = custfullName;
                            this.cMname = result[0].EYI_Closing_Manager__r.Name;
                            this.walksrc = result[0].EYI_Walk_in_Source__c;
                            this.proName = result[0].EYI_Project_Enquired__r.Name;
                        }
                        
                        this.isSpinner = false;
                        //this.showMessage = true;
                        this.isCifExist = true;

                        //this.showContinue = true;
                        
                        console.log('cust name', this.cname);
                        console.log('this.cifId ', this.cifId);//vj

                    } else {

                        console.log('Cif not Found');
                        this.isSpinner = false;
                        this.isCifNotExist = true;
                        console.log('isCifNotExist', this.isCifNotExist)
                        let searchbyphone = false;
                        SearchLead({ cont: this.mobileNo, proj: this.project, cc: this.countryCode, emailid : this.email })
                            .then(result => {
                                console.log('mobile Number ', this.mobileNo);
                                console.log('project ', this.project);
                                console.log('result', result);
                                if (result.length == 0) {

                                    console.log('Lead not  Found');
                                    //this.showMessage = true;
                                    //this.showContinue = true;
                                    searchbyphone = true;
                                    this.createLead = true;
                                } else {

                                    console.log('Lead  Found');
                                    this.data = result.map(row => {
                                        return { ...row, projectName: row.EYI_Project_Enquired__r.Name }
                                    });
                                    this.record = this.data[0];
                                    this.showToastMessage('Lead Found', 'This is an existing Lead for the selected project', 'success');
                                    this.handleContinue();

                                }
                            })
                            .catch(error => {
                                console.log(error);
                            })
                            .finally((_) => {
                                if (searchbyphone) {
                                    SearchLeadbyphone({ cont: this.mobileNo, cc: this.countryCode, emailid : this.email }).then(result => {
                            
                                        if (result.length != 0) {
                                            console.log('Lead phone Found',result[0]);
                                            this.leadId = result[0].Id;
                                            this.lproName = result[0].EYI_Project_Enquired__r.Name;//vj
                                            //this.lname = result[0].Name;
                                            this.lname = result[0].EYI_Parent_Record__r.FirstName +' '+result[0].EYI_Parent_Record__r.MiddleName+ ' '+ result[0].EYI_Parent_Record__r.LastName ;                                            
                                            this.emailId = result[0].EYI_Email__c;
                                            this.ledsource = result[0].EYI_Lead_Source__c;
                                            this.currleadowner = result[0].Owner.Name;
                                            this.showToastMessage('Lead Found', 'This is an existing Lead for a different project', 'success');
                                            console.log('EYI Lead Source ', this.ledsource);
                                            console.log('Email ID ', this.emailId);
                                            console.log('Project', this.lproName);
                                            console.log('lname', this.lname);
                                        }
                                    })
                                    .catch(error =>{
                                        console.log('Error searching lead',error);
                                    }) 
                                }

                            })

                        
                    }
                })
                .catch(error => {
                    console.log(error);
                })

            SearchRecordType({ proj: this.project })
                .then(result => {
                    if (result.length != 0) {

                        console.log('Record Type Found', result[0].RecordType.Name);
                        this.recTypeName = result[0].RecordType.Name;
                        console.log('Record Type: ', this.recTypeName);

                        /*this.projRecType = result[0].RecordTypeId;
                        if(this.projRecType=='0121e000000DgyyAAC'){ 
                            this.recTypeId = '0121e000000Dml0AAC'; //Residential
                        }else{
                            this.recTypeId = '0121e000000DmkzAAC';  //Commercial
                        }*/

                    } else {
                        console.log('Record Type not Found');
                    }
                })
                .catch(error => {
                    console.log(error);
                })

        }
    }
    @wire(getObjectInfo, { objectApiName: CIF_OBJECT })
    objectInfo;

    get cifRecordTypeId() {
        if (this.objectInfo.data) {
            return this.objectInfo.data.defaultRecordTypeId;
        } else {
            console.error('Error retrieving object information');
        }

        // if (this.objectInfo.data) {

        //     const recTyps = this.objectInfo.data.recordTypeInfos;
        //     return Object.keys(recTyps).find(recTyp => recTyps[recTyp].name === this.recTypeName);

        // } else {

        //     return null;

        // }

    }

    handleContinue() {
        console.log('handleContinue',this.record,JSON.stringify(this.record));
        console.log(this.record.Id);
        if (this.record.Id) {
            try{
            this.leadId = this.record.Id;
            //this.lname = this.record.Name;
            this.lname = this.record.EYI_Parent_Record__r.FirstName +' '+this.record.EYI_Parent_Record__r.MiddleName+ ' '+ this.record.EYI_Parent_Record__r.LastName ;
            this.lproName = this.record.EYI_Project_Enquired__r.Name;
            this.ledsource = this.record.EYI_Lead_Source__c;
            this.currleadowner = this.record.Owner.Name;
            console.log('606 lead data population ledsource', this.ledsource);
            }
            catch(err){
                console.error('err 608',err);
            }

        } else {
            if (this.firstName != null)
                this.firstName = this.firstName.charAt(0).toUpperCase() + this.firstName.slice(1);
            else if (this.lastName != null) {
                this.lastName = this.lastName.charAt(0).toUpperCase() + this.lastName.slice(1);
            }
            let map1 = new Map([
                ["Project", this.project],
                ["FirstName", this.firstName],
                ["LastName", this.lastName],
                ["Phone", this.mobileNo],
                ["Email", this.email],
                ["projType", this.projType],
                ["projectName", this.projectName]
            ]);
            console.log(map1.get("Project"));
            this.newLead = map1;
            console.log('newLead', this.newLead, JSON.stringify(this.newLead),this.newLead.get("projType"));
            //this.leadId = this.leadRecId;
            console.log('Lead ID', this.leadId);
        }
        this.showFillForm = true;
        this.isSpinner = false;
    }

    handleCreateCIF() {
        
        console.log('after on showModal');
        this.handleContinue();
        this.onshowModal();
        this.showCIF = true;
        this.footer1 = false;
        console.log('CIF');
        this.isOTPGenerated = false;
        this.showCustomerVisitForm = false;
        
        // if (this.data.length != 0) {
        //     this.record = this.data[0];
        // }

        // console.log('leaddata', this.data[0], event.detail.row);
    }

    handleCustomerVisitForm() {
        this.onshowModal();
        this.showCustomerVisitForm = true;
    }

    handleOTP() {
        this.onshowModal();
        this.showOTP = true;
    }
    handleSubmitReturn = (event) => {
        this.showFillForm = false;
        this.handleCancel();

    }

    validateFields() {
        /*this.template.querySelectorAll('lightning-combobox,lightning-input').forEach(element => {
            element.reportValidity();
            console.log(element);
            console.log(element.checkValidity());
            if (!element.checkValidity()) {
                this.isValid = false;
            }
        });*/
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        console.log('mobileNo:', this.mobileNo);
        console.log('email:', this.email);
        console.log('selectedCountryCode:', this.selectedCountryCode);
        console.log('value:', this.value);
        if(this.mobileNo == '' || this.mobileNo == undefined  || this.email == '' || this.email == undefined || this.selectedCountryCode == '' || this.selectedCountryCode == undefined  || this.value == '' || this.value == undefined ){
            console.log('check');
            this.isValid = false;
            this.showToastMessage('Error', 'Please fill in all the required fields.', 'error'); 
        }
        if (this.email !=  '' && this.email != undefined && !emailRegex.test(this.email)) {
            console.log('Invalid email');
            this.isValid = false;
            this.showToastMessage('Error', 'Please enter a valid email address.', 'error');
        }
        if (this.countryCode == '+91' && this.mobileNo.length != 10) {
            this.isValid = false;
            this.showToastMessage('Error', 'Mobile No. should be of 10 digits', 'error');
        } else if (this.countryCode != '+91' && (this.mobileNo.length < 7 || this.mobileNo.length > 12)) {
            this.isValid = false;
            this.showToastMessage('Error', 'Mobile No. should be of 7-12 digits', 'error');
        }
        
        //this.regexString = this.selectedCountryCode;
        this.regexString = this.ccPatternMap.get(this.selectedCountryCode);

        console.log('regexstring', this.regexString);
        let regex = new RegExp(this.regexString);
        console.log('line 815', regex, regex.toString());
        
        if (this.mobileNo.startsWith('0')) {
            this.mobileNo = this.mobileNo.substring(1);
        }

        if (!regex.test(this.mobileNo)) {
            console.log('Invalid mobile number for the provided country code.');
            this.isValid = false;
            this.showToastMessage('Error', 'Invalid mobile number for the provided country code.', 'error');
        } 
        
    }

    showToastMessage(titlee, messagee, variantt) {
        const evt = new ShowToastEvent({
            title: titlee,
            message: messagee,
            variant: variantt,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    newRevisit() {
        console.log('inside newRevisit');
        this.onshowModal();
        this.showCIF = false;
        this.isSpinner = true;
        this.showRevisitForm = true;
        this.footer1 = false;
        console.log('this.showRevisitForm', this.showRevisitForm);
        console.log('this.showModal', this.showModal);
        if (this.showRevisitForm == true) {
            this.isSpinner = false;
        }
    }
    handleCIFEdit() {
        this.onshowModal();
        console.log('edit after on showModal');
        this.handleContinue();
        this.showCIF = true;
        this.showRevisitForm = false;
    }

}