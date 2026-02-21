import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import UserId from '@salesforce/user/Id';

// import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import CIF from '@salesforce/schema/EYI_Customer_Information_Form__c';
// //import VisitingWith from '@salesforce/schema/Ud_Customer_Information_Form__c.Visiting_With__c';
// //import VisitingBehalf from '@salesforce/schema/Ud_Customer_Information_Form__c.Visiting_on_Behalf_of__c';
// import ResidentialStatus from '@salesforce/schema/Ud_Customer_Information_Form__c.Ud_Customer_residential_status__c';
// import AgeGroup from '@salesforce/schema/Ud_Customer_Information_Form__c.Age_Group__c';
// import Occupation from '@salesforce/schema/Ud_Customer_Information_Form__c.Occupation__c';
// import PurposeofBuying from '@salesforce/schema/Ud_Customer_Information_Form__c.Ud_Purpose_of_Purchase__c';
// import ConstructionStatus from '@salesforce/schema/Ud_Customer_Information_Form__c.Desired_Construction_Status__c';
// import Industry from '@salesforce/schema/Ud_Customer_Information_Form__c.Ud_Industry__c';
// import Designation from '@salesforce/schema/Ud_Customer_Information_Form__c.Ud_Designation__c';
// //import OfficeLoc from '@salesforce/schema/Ud_Customer_Information_Form__c.Office_Location__c';
// //import Nationality from '@salesforce/schema/Ud_Customer_Information_Form__c.Nationality__c';
// import Country from '@salesforce/schema/Ud_Customer_Information_Form__c.Ud_Residential_Address__c';
// import State from '@salesforce/schema/Ud_Customer_Information_Form__c.Ud_Residential_Address__c'
// import Location from '@salesforce/schema/Ud_Customer_Information_Form__c.Location__c';

import getLead from '@salesforce/apex/EYI_CifFormCreation.getLead';
import getProjects from '@salesforce/apex/EYI_CifFormCreation.getProjects';
import getSubProjects from '@salesforce/apex/EYI_CifFormCreation.getSubProjects';
import getTowers from '@salesforce/apex/EYI_CifFormCreation.getTowers';
import updateSMOnOpp from '@salesforce/apex/EYI_CifFormCreation.updateSMOnOpp';
import getProjectById from '@salesforce/apex/EYI_CifFormCreation.getProjectById';


// import getResiSiteHead from '@salesforce/apex/EYI_CifFormCreation.getResiSiteHead';
// import getCommSiteHead from '@salesforce/apex/EYI_CifFormCreation.getCommSiteHead';
// import getCpExecCode from '@salesforce/apex/EYI_CifFormCreation.getCpExecCode';
// import getCpExecName from '@salesforce/apex/EYI_CifFormCreation.getCpExecName';


// import getProject from '@salesforce/apex/EYI_CifFormCreation.getProject';   
// import createRecord from '@salesforce/apex/EYI_CifFormCreation.createCIF';
import SearchLead from '@salesforce/apex/EYI_CifFormCreation.getLeads';
import createLead from '@salesforce/apex/EYI_CifFormCreation.createLead';
import createREC from '@salesforce/apex/EYI_CifFormCreation.createrec';
import convertLeadEnquiryFromCIF from '@salesforce/apex/EYI_LeadConvertionClass.convertLeadEnquiryToOpp';
import updateLeadOnCIF from '@salesforce/apex/EYI_LeadConvertionClass.updateLeadOnCIF';
import updatesOnLeadEnquiry from '@salesforce/apex/EYI_LeadConvertionClass.updatesOnLeadEnquiry';

// import getSalesManager from '@salesforce/apex/EYI_CifFormCreation.getSalesManagers';
// import getSourcingManagers from'@salesforce/apex/EYI_CifFormCreation.getSourcingManagers';
// import getSourcingTLs from'@salesforce/apex/EYI_CifFormCreation.getSourcingTLs';
// import getClosingTLs from'@salesforce/apex/EYI_CifFormCreation.getClosingTLs';
// import getBusinessHeads from'@salesforce/apex/EYI_CifFormCreation.getBusinessHeads';
// import getClusterHeads from'@salesforce/apex/EYI_CifFormCreation.getClusterHeads';
// import getSiteHeads from '@salesforce/apex/EYI_CifFormCreation.getSiteHeads';
// import getCampaigns from '@salesforce/apex/EYI_CifFormCreation.getCampaigns';

export default class CifFillForm extends NavigationMixin(LightningElement) {
    @api recordId;
    @api custDetails;
    @api recordType;
    @api emailId;
    @api hideButtons;
    @api cifRecordId;
    @api property;
    recordTypeLabel
    @api cifRecord;
    @track ciffieldcloneinit = false;
    @track isShowModal = false;
    @track error;

    @track isPerson = true;
    @track isOrganisation = false;

    fieldsForPincode = ["EYI_Pincode__c", "EYI_Locality__c"];
    displayFieldsForPincode = 'EYI_Pincode__c, EYI_Locality__c, EYI_City__c, EYI_Zone__c';
    fieldsForREC = ["EYI_First_Name__c","EYI_Last_Name__c", "EYI_Mobile__c","EYI_PAN_No__c","Verified_PAN_Number__c","EYI_SAP_ID__c"]; 
    displayFieldsForREC = 'EYI_REC_Full_Name__c, EYI_Mobile__c, EYI_SAP_ID__c, EYI_PAN_No__c';
    isFalse = false;
    cpname;
    leadId;
    firstName;
    middleName;
    lastName;
    companyName;
    birthDate;
    visitDate;
    eastWest;
    countryCode;
    mobileNum;
    mobileNumSecondary;
    email;
    passcode;
    projId;
    developer;
    developerId;
    compName;
    visitWith;
    visitBehalf;
    resideStatus;
    resideAddress;
    nationalityVal;
    countryVal;
    stateVal;
    cityVal;
    locationVal;
    otherLocation;
    locOther;
    typeOfArea;
    areaVal;
    pincode;
    pincodeError = '';
    localContactName;
    localContactReln;
    localContactPhone;
    ageGrp;
    empStatus;
    constructStat;
    purpBuy;
    loc;
    industryValue;
    officeLocn;
    designationValue;
    officePin;
    indianDefence = false;
    cpUnreg = false;
    cpConflict = false;
    cpConflictUnreg = false;
    showpicklist = false;
    showSpinner = false;
    showMessage = false;
    hideCampaign = false;
    hideChannelPartner = true;
    disableReferral = true;
    nationalityRequired = false;
    localRequired = false;
    phaseDisabled = false;
    disableLocalDetails = true;
    isValid = true;
    cpRequired = false;
    refName;
    refContact;
    refRequired = false;
    unRegChecked = false;
    unRegConflictChecked = false;
    unregCPFirm;
    unregCPName;
    unregCPMobile;
    unregCPReraId;
    unregConflictCPFirm;
    unregConflictCPName;
    unregConflictCPMobile;
    unregConflictCPReraId;
    subsourcePicklist;
    statePicklist;
    cityPicklist;
    locationPicklist;
    areaPicklist;

    sourceVal;
    subsourceVal;
    cpConf;
    cp;
    cmpgn;
    //presales;
    salesManager;
    sourceManager;
    errorMessage;
    salesMgrValue;
    sourcingMgrValue;
    conflictSourcingMgrValue;
    siteHeadValue;
    sourcingTlValue;
    closingTlValue;
    businessHeadValue;
    clusterHeadValue;
    source;
    subsource;
    wsource;
    wsubsource;
    leadsourcesamewalkin = false;
    // added by Rushikesh
    ResidentialAddressText;
    Ud_ResidentialAddressCountry;
    Ud_ResidentialAddressStreet;
    Ud_ResidentialAddressitys;
    Ud_ResidentialAddressPostalCode;
    Ud_ResidentialAddressState;
    // added by Rushikesh: Ended
    @track  isNewRec = false;
    @api resultCallback;

    @track sourceOptions = [];
    @track subSourceOptions = [];
    @track countryOptions = [];
    @track cityOptions = [];
    @track stateOptions = [];
    @track locationOptions = [];
    @track areaOptions = [];
    @track config = [];
    @track areaReq = [];
    @track budgetValues = [];
    @track eastWestOptions = [];
    showEOIForm = true;

    phaseOptions = [];
    //visitingBehalf = [];
    //visitingWith = [];
    residentStatus = [];
    occupation = [];
    constructStatus = [];
    purposeBuying = [];
    //ageGroup = [];
    configuration = [];
    budget = [];
    areaRequired = [];
    phaseVal = [];
    salesManagers = [];
    sourcingManagers = [];
    sourcingTls = [];
    closingTls = [];
    businessHeads = [];
    clusterHeadValues = [];
    siteHeads = [];
    Campaigns = [];

    //record-edit-form fields
    firstName;
    lastName;
    middleName;
    mobileNumber;
    //emailId;
    subProject;
    project;
    tower;
    residentialAddress;
    residentialStatus = '';
    activeSectionsMessage = '';
    sourcingManager;
    preSales;
    purposeOfPurchase;
    areaReq;
    budget;
    desiredConstruction;
    desiredConfiguration;
    //designation;
    industry;
    ageGroup;
    location;
    //residentialAddress;
    DOB;
    secondaryMobileNumber;
    cpCode;
    isNonIndian = false;
    visitingOnBehalf = false;
    isCP = false;
    @track isCPExist = false;
    @track isCPNotExist = false;
    isRef = false;
    isOther = false;
    isComm = false;
    resReq = false;
    salutation;
    @track optionProjects;
    @track projList;
    @track optionSubprojects;
    @track subProjList;
    @track optionTowers;
    //@api prId;
    isSpinner = false;
    cpExecCode;
    cpName
    @track optionCpExecCode;
    nriFields = false;
    passport;
    ssn;
    oci;
    activeAccordions = ['A'];
    @track createLead = false;
    @track leadEnquiryId = '';
    @track currentCifId ='';
    recId;
    isEmployeeRef = false;
    isCustomerRef = false;
    isCorporateRef = false;
    isOtherRef = false;
    //Is SubSource Required
    @track is

    addressType;
    locality;
    addressTypeVal;
    localityVal;
    occupationType;
    authenticate;
    property;
    isSalaried = false;
    isOS = false;
    isNRI = false;
    natureroflead = 'Outright';
    @track isleasing = false;

    @api functionhandler(funName,createLead){
        console.log('childCalled');
        if(funName == 'handleSubmit'){
            this.createLead = createLead;
            this.handleSubmit();
        }
    }

    @wire(getObjectInfo, { objectApiName: CIF })
    objectInfo({ data, error }) {
        if (data) {
            //this.recordType = data.defaultRecordTypeId;
            this.recordTypeLabel = data.recordTypeInfos[this.recordType].name;
        } else if (error) {
            // Handle error
            console.error('Error retrieving object information:', error);
        }
    }

    @wire(getRecord, { recordId: UserId, fields: ['User.Profile.Name','User.UserRole.Name'] })
        wireuser({ error, data }) {
            if (error) {
                console.error('User detail error in data',error);
                this.error = error;
            } else if (data) {
                console.log('Stage fill form getting user details1');
                let prfName = data.fields.Profile.value.fields.Name.value;
                let rolename = data.fields.UserRole.value.fields.Name.value;
                if(prfName.includes('Leasing')){
                    console.log('Leasing',rolename);
                    this.natureroflead = 'Leasing';
                    this.isleasing = true;
                    this.preSales = '';
                    this.addressType = 'pune'; 
                }else{
                    this.isleasing = false;
                    this.natureroflead = 'Outright';

                }
                console.log('prfName ' + prfName);
                console.log('currentUserId1 ' + UserId);    
            }
            console.log('isleasing====> ' , this.isleasing);
        }
        get isNotLeasing() {
        return !this.isleasing;
    }
    handleOccupationChange(event) {
        this.occupationType = event.detail.value;
        console.log('occupationType', this.occupationType);
        if(this.occupationType === 'Salaried'){
            this.isSalaried = true;
        }
        else{
            this.isSalaried = false;
        }
        
    }

    handleChange(event) {
        this.addressTypeVal = event.detail.value;
        console.log('AddresType', this.addressTypeVal);
        
        if(this.addressTypeVal == 'OS (Rest of India)') {
            this.isOS = true;
            this.isNRI = false;
        }
        else if(this.addressTypeVal == 'NRI') {
            this.isNRI = true;
            this.isOS = false;
        }
        else{
            this.isOS = false;
            this.isNRI = false;
        }
        this.localityVal = event.detail.value;
    }

    handlePincode(event) {
        this.pincode = event.target.value;
        this.pincodeError = '';
        if(this.pincode.length !== 6) {
            this.pincodeError = 'Pincode must be 6 digits';
        }
        console.log('pincode len', this.pincode.length);
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        //this.isSpinner = true;
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
    navtorecord(recId){
        this.callParentFunction();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                actionName: 'view'
            }

        });
    }
    callParentFunction() {
        const event = new CustomEvent('childevent', {
            detail: { data: 'some data' } // Optional: Pass any data to the parent
        });
        this.dispatchEvent(event);
    }
    callHandleSave() {
            const event = new CustomEvent('saveaction', {
                detail: { data: 'some data' } // Optional: Pass any data to the parent
            });
            this.dispatchEvent(event);
    }
    handlepincodeLookup(event){
        console.log('In pincode lookup',event,event.target,event.target.value);
        this.pincode = event.target.value;
    }

    handleSuccess(event) {
        console.log('In cmp Success', event.detail);
        //this.isSpinner = false;
        console.log(event);
        
        this.currentCifId = event.detail.id;
        if(this.cifRecordId){
            const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'CIF record updated successfully',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);
        window.location.reload();
        }
        else{
            const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'CIF record created successfully, processing Opportunity creation....',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);
            this.convertLeadEn(event.detail.id);
        }
        
        // if (this.custDetails) {
        //     console.log('Sucess 2');
        //     this.resultCallback();
        // }
        this.hideModalBox();
    }
    // update lead enqury
    updateLeadOnCIF(currcifId,oppId){
        console.log('In update Lead');
        console.log('In update currcifId ',currcifId);
        console.log('In update recId',this.recId);
        console.log('In update leadEnquiryId',this.leadEnquiryId);
 
        updateLeadOnCIF({cifId : this.currentCifId,recId:this.recId ,leadEnquiryId:this.leadEnquiryId,opptId:oppId})
        .then(result => {
            console.log('Result: Lead Updated' ,result);
        })
        .catch(error => {
            console.log('Error: ', error);
        });
    }
    updatesOnLeadEnquiry(opptyId){
        console.log('In update opptyId',opptyId);
        console.log('In update recId',this.recId);
        console.log('In update leadEnquiryId',this.leadEnquiryId);
 
        updatesOnLeadEnquiry({oppId : opptyId,leadEnquiryId:this.leadEnquiryId,recId:this.recId})
        .then(result => {
            console.log('Result: Lead Updated' ,result);
        })
        .catch(error => {
            console.log('Error: ', error);
        });
    }
    
    updateSMOnOpp(opptId){
        console.log('opptId', opptId);
        updateSMOnOpp({oppId : opptId})
        .then(result=> {
            console.log('opp updated', result);
        })
        .catch(error=> {
            console.log('Error', error);
        })
    }

    convertLeadEn(currcifId){
 
        convertLeadEnquiryFromCIF({CIFId: currcifId})
        .then(result => {
            console.log('Result: Converted Opp Id ', result);
            this.updateLeadOnCIF(currcifId,result);
            this.updatesOnLeadEnquiry( result);
            this.updateSMOnOpp(result);
            this.isSpinner = false;
            this.navtorecord(result);
        })
        .catch(error => {
            console.log('Error: ', error);
            this.isSpinner = false;
        });
    }

    handleError(event) {
        console.log('error');
        console.log('errordetail',JSON.stringify(event.detail));
        console.log(event);
        console.log('In cmp Error', event.detail.output.errors);
        console.log('error ==> ', JSON.stringify(event.detail.error));
        this.isSpinner = false;

        let errorDetailMessage = '';
        if (event.detail && event.detail.error) {
            errorDetailMessage = errorMessage = JSON.stringify(event.detail.error);
            console.log('error final ==> ', errorDetailMessage);
        } else {
            errorDetailMessage = 'An unknown error occurred';
        }
        const ERROR_MESSAGE = `An error occurred while saving the record: ${errorDetailMessage}`;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: ERROR_MESSAGE,
                variant: 'error',
            })
        );
        //this.resultCallback();
    }

    handleSubmit(event) {
        if(this.validateSubmit()){
            this.isSpinner = true;
            let inFormFields = this.template.querySelectorAll('lightning-input-field');

            let cifOb ={};
            console.log('lead create cifOb: 362 ',cifOb);
            try{
            inFormFields.forEach(field => {
                    cifOb[field.fieldName] = field.value;
            });

                if(this.custDetails.get("projType")){
                    cifOb['EYI_Project_Type__c'] = this.custDetails.get("projType");
                }
            }
            catch(pterr){
                console.log('Error Project Type: ',pterr);
            }
            
            
            console.log('cifOb: 369==>',JSON.stringify(cifOb));
            console.log('this.recordId==>',this.recordId);
            console.log('this.isCP ==>',this.isCP);
            console.log('this.isCPExist ==>',this.isCPExist);
            console.log('this.isCPNotExist ==>',this.isCPNotExist);

            if(this.recordId && this.isCP && this.isCPExist){
                console.log('C 1 --------');
                this.submitCIF();
            }else  if(!this.recordId && this.isCP && this.isCPNotExist){
                console.log('C 2 --------');
                this.recCreation(cifOb);
            }else if(this.recordId && this.isCP && this.isCPNotExist){
                this.recCreation(cifOb);
            }
            
            else  if(!this.recordId && this.isCP && this.isCPExist){
                console.log('C 3 --------');
                this.leadCreation(cifOb);
            }else if(this.recordId && !this.isCP){
                console.log('C 4 --------');
                this.submitCIF();
            }else if(!this.recordId && !this.isCP ){
                console.log('C 5 --------');
                this.leadCreation(cifOb);
            }
        }else{
            console.log('else of validate submit --------');
            this.callHandleSave();     
        }  
    }

    recCreation(cifOb){
        console.log('In rec creation');
        createREC({ cifRec : cifOb })
            .then(result => {
                // Handle success
                //this.isSpinner = false;
                this.recId = result;
                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'REC record created successfully, processing Lead Enquiry creation....',
                    variant: 'success',
                });
                this.dispatchEvent(toastEvent);
                console.log('rec result:',result);
                if(this.recordId){
                    this.submitCIF();
                }else if(!this.recordId){
                    this.leadCreation(cifOb);
                }
            })
            .catch(error => {
                // Handle error
                console.error('Error REC creation:', error.body.message);
                this.isSpinner = false;
                if(error.body.message.includes('DUPLICATES')) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Duplicate REC found',
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvent);
                }
                else{
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter valid values for REC',
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvent);
                }
            });
    }
    
    leadCreation(cifOb){
        const toastEvent = new ShowToastEvent({
            title: 'Please wait',
            message : 'Lead Enquiry creation is in progress, please don\'t close the window',
        });
        this.dispatchEvent(toastEvent);
        createLead({ cif : cifOb , projectName : this.custDetails.get("projectName") })
            .then(result => {
                // Handle success
                console.log('Lead created',result);
                this.recordId = result;
                this.leadEnquiryId = result;
                //this.isSpinner = false;
                if(this.recordId){
                    this.submitCIF();
                }
                else{
                    console.log('Lead Enquiry Not found');
                    this.retryLeadEnquiry(cifOb);
                }
            })
            .catch(error => {
                // Handle error
                console.error('Error Lead creation:', error);
                this.isSpinner = false;
            });
    }
    retryLeadEnquiry(cif) {
        console.log('In retryLeadEnquiry');
        setTimeout(async () => {
            const email = cif.EYI_Email_Id__c;
            const phone = cif.EYI_Mobile_number__c;
            const project = cif.EYI_Project_Enquired__c;
            const countrycode = cif.EYI_Country_code__c;
            try {
                 await this.queryLeadEnquiry(email, phone, project, countrycode);
            } catch (error) {
                console.log('Error in queryLeadEnquiry:', error);
            }
        }, 5000); // 30 seconds delay
    }
    queryLeadEnquiry(email, phone, project, countrycode) {
        return SearchLead({ cont: phone, proj: project, cc: countrycode, emailid: email })
            .then(result => {
                this.recordId = result[0].Id;
                this.leadEnquiryId = result[0].Id;
                console.log('this.recordId==> ', this.recordId);
                console.log('this.leadEnquiryId==> ', this.leadEnquiryId);
                this.isSpinner = false;
                setTimeout(()=>{
                    this.submitCIF();
                },2000)
                
                console.log('queryLeadEnquiry result==>', JSON.stringify(result));
            })
            .catch(error => {
                console.log('lead enquiry not found',error);
            });
    }
    
    // retryLeadEnquiry(cif) {
    //     console.log('In retryLeadEnquiry');
    //     setTimeout(() => {
    //         const email = cif.EYI_Email_Id__c;
    //         const phone = cif.EYI_Mobile_number__c;
    //         const project = cif.EYI_Project_Enquired__c;
    //         const countrycode = cif.EYI_Country_code__c;

    //         const resultLead = this.queryLeadEnquiry(email, phone, project,countrycode);
    //         console.log('result==> 490', JSON.stringify(resultLead));

    //         if (resultLead ) {
    //             this.recordId = resultLead[0].Id;
    //             this.leadEnquiryId = resultLead[0].Id;
    //             this.submitCIF();
    //         } else {
    //             console.log('Lead Enquiry still not found');
    //             this.retryLeadEnquiry(cif);
    //         }
    //     }, 35000); // 35 seconds delay
    // }
    // queryLeadEnquiry(email, phone, project,countrycode) {
    //     SearchLead({ cont: phone, proj: project, cc: countrycode, emailid : email })
    //     .then(result => {
    //         console.log('result==>', JSON.stringify(result));
    //         return result;
    //     })
    //     .catch(error => {
    //         console.log(error);
    //     })
    // }
    submitCIF(){
        const toastEvent = new ShowToastEvent({
            title: 'Please wait',
            message: 'CIF Form submitted successfully, please don\'t close the window',
        });
        this.dispatchEvent(toastEvent);
        this.isSpinner = true;
        let inForm = this.template.querySelector('lightning-record-edit-form');
        console.log('inForm==>',JSON.stringify(inForm));
        console.log('Form Element data:', inForm);
        inForm.submit();
        //let fields = {};
            //this.isSpinner = false;
            //fields.LeadSource = this.Ud_Lead_Source__c;    
        // console.log('Fields to submit:', JSON.stringify(fields));
    }
    validateSubmit(){
		let isValid = true;
		let unfilledField = [];
		let unfilledAccSecForm = [];
        const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/; // PAN format regex

        //&& field.fieldName != 'EYI_Lead_Enquiry__c'
		const requiredFields = this.template.querySelectorAll("lightning-input-field , lightning-combobox");
        console.log('inside foreach requiredFields 482', requiredFields);

        const inputField = this.template.querySelector('lightning-input-field[field-name="Pincode__c"]');
        //console.log('ip', this.inputField);
        if (this.pincodeError) {
            try{
			inputField.focus();
            }
            catch(err){
                console.log('h focus 715',err);
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter valid Pincode',
                    variant: 'error',
                })
            );
            isValid = false;
        }

        requiredFields.forEach(field => {
			console.log('inside foreach');
            if (field.fieldName == 'EYI_Walk_in_Sub_source__c' && (this.isCP || this.isOther || this.isRef)) {
                // Skip this field
                return;
            }
             if(field.fieldName == 'EYI_Leasing_Manager__c' && (!this.isleasing)) {
                 console.log('checkLeasing');
                return;
             }
            if (field.fieldName == 'EYI_REC_PAN_No_Non_Registered__c' && !panRegex.test(field.value)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter valid PAN Number',
                        variant: 'error',
                    })
                );
                isValid = false;
            }
			if (!field.value && field.required && field.fieldName != 'isKYCDone__c' ) {
				console.log('inside field: ' , field.fieldName,field.value,field,field.parentElement);
				isValid = false;
				field.reportValidity();
				unfilledField.push(field);
				if(field.parentElement.localName == 'lightning-accordion-section'){
					unfilledAccSecForm.push(field.parentElement.name);
				}
			}
		});
		this.activeAccordions = unfilledAccSecForm;
        if(this.isleasing){
            isValid=true;
        }
		setTimeout(()=>{
			try{
			unfilledField[0].focus();
            }
            catch(err){
                console.log('h focus 754',err);
            }
		},100);			
		return isValid;
	}
    hideModalBox() {
        this.isShowModal = false;
        //this.resultCallback();
    }

    onchangeProject(event) {
        this.project = event.target.value;
        console.log('Project : ', this.project);
        //this.prId = this.project;
        //console.log('PrId : ', this.prId);
    }
    onchangeSubProject(event) {
        this.subProject = event.target.value;
    }
    onchangeTower(event) {
        this.tower = event.target.value;
    }
    onchangeCpExCode(event) {
        this.cpExecCode = event.target.value;
    }
    
    @wire(getProjects, {})
    wiredgetProjects({ error, data }) {
        if (data) {
            this.projList = data;
            let options = [];
            for (var key in data) {
                // Here key will have index of list of records starting from 0,1,2,....
                options.push({ label: data[key].Name, value: data[key].Id });

                // Here Name and Id are fields from sObject list. 
            }
            this.optionProjects = options;
            //this.optionProjects = data;
            console.log('data Projects: ' + JSON.stringify(data));
        }
        else {
            console.log(error);
        }
    }

    @wire(getSubProjects, { projectId: '$project' })
    wiredgetSubProjects({ error, data }) {
        if (data) {
            this.subProjList = data;
            let options = [];
            for (var key in data) {
                options.push({ label: data[key].Name, value: data[key].Id });
            }
            this.optionSubprojects = options;
            console.log('data Subprojects ' + JSON.stringify(data));
        }
        else {
            console.log(error);
        }
    }

    @wire(getTowers, { projectId: '$project', subProjId: '$subProject' })
    wiredgetTowers({ error, data }) {
        if (data) {
            //this.subProjList = data; 
            let options = [];
            for (var key in data) {
                options.push({ label: data[key].Name, value: data[key].Id });
            }
            this.optionTowers = options;
            console.log('data Tower : ' + JSON.stringify(data));
        }
        else {
            console.log(error);
        }
    }
    onchangeRecCode(event) {
        console.log(event,event.target,event.target.value);
        this.recId = event.target.value;
        console.log('this.recId :', this.recId);

    }
    createManualRec(){
        this.isCPExist = false;
        this.isCPNotExist = true;
        this.isNewRec = true;
        console.log('this.isCPExist :856', this.isCPExist);
    }
    cancelManualRec() {
        this.isCPNotExist = false;
         this.isNewRec = false;
        this.isCPExist = true;
    }
    onchangeCpCode(event) {
        this.cpCode = event.target.value;

        console.log('this.cpCode :', this.cpCode);
        getCpExecName({ cpCompanyName: this.cpCode }).then(result => {
            console.log('code' + result);
            if (result.length != 0) {
                this.cpName = result[0].Ud_Channel_Partner_Account_Name__c;
                console.log('this.cpName: ' + this.cpName);
            } else {
                this.cpName = null;
            }
        })

    }

    handleResiStatusChange(event) {
        console.log('You selected an residential Status: ' + event.detail.value);

        this.residentialStatus = event.detail.value;
        if (this.residentialStatus != '' && this.residentialStatus != 'Indian') {
            this.isNonIndian = true;
            this.visitingOnBehalf = true;
            console.log('isNonIndian ' + this.isNonIndian);
        }
        if (this.residentialStatus == 'Indian') {
            this.visitingOnBehalf = false;
            this.isNonIndian = false;
        }
        if (this.residentialStatus == 'NRI') {
            this.nriFields = true;
        }
        if (this.residentialStatus != 'NRI') {
            this.nriFields = false;
        }
    }
    handleSourceChange(event) {
        console.log('You selected an Source: ' + event.detail.value);
        console.log('leadsourcewalkin', this.leadsourcesamewalkin);
        console.log('wsource', this.wsource);
        if (event.detail.value == 'PREC') {
            this.isCP = true;
            this.isCPExist = true;
            this.isRef = false;
            this.isOther = false;
        } else if (event.detail.value == 'Referral') {
            this.isRef = true;
            this.isCP = false;
            this.isOther = false;
        } else if (event.detail.value == 'Other') {
            this.isOther = true;
            this.isRef = false;
            this.isCP = false;
        } else {
            this.isCP = false;
            this.isRef = false;
            this.isOther = false;
        }
        if(this.leadsourcesamewalkin){
            this.source = event.detail.value;
            //this.subsource = this.wsubsource;
        }
        console.log('lead source', this.source);
    }
    handleSubSourceChange(event) {
        this.isEmployeeRef = false;
        this.isCustomerRef = false;
        this.isCorporateRef = false;
        this.isOtherRef = false;
        if (event.detail.value == 'Employee') {
            this.isEmployeeRef = true;
        }
        else if(event.detail.value == 'Existing Client'){
            this.isCustomerRef = true;
        }
        else if(event.detail.value == 'Corporate'){
            this.isCorporateRef = true;
        }
        else if(event.detail.value == 'Other') {
            console.log('other', event.detail.value);
            this.isOtherRef = true;
        }
        else{}
        if(this.leadsourcesamewalkin){
            //this.source = this.wsource;
            this.subsource = event.detail.value;
        }
    }
    renderedCallback(){
        const fields = this.template.querySelectorAll('lightning-input-field');
        fields.forEach(field => {
            if (field.fieldName === 'EYI_Walk_in_Source__c') {
                if(field.value == 'PREC' &&  this.isNewRec != true){
                    this.isCP = true;
                    this.isCPExist = true;
                }
                if( this.isNewRec == true){
                    this.isCP = true;
                    this.isCPExist = false;
                }
               console.log('sourceField2'+field.value);
            }
        });
        if(this.ciffieldcloneinit){
            this.template.querySelectorAll('lightning-input-field').forEach(field => {
                console.log('CIF Cloning',field.fieldName,field)
                try{
                    if(field.fieldName != 'EYI_Project_Enquired__c' && field.fieldName != 'EYI_Property__c' ){
                        field.value = this.cifRecord[field.fieldName];
                    }
                    
                }
                catch(e){
                    console.error('err populating',field,field.fieldName,e);
                }
                
            });
            this.ciffieldcloneinit = false;
        }
        
    }
    leadFieldPopInCIF(result){
        try{
        console.log('$$$$$$$$$$$ result[0].Address.countryCode:', result,result[0],JSON.stringify(result[0]));
                    //console.log('--Address-- : ', result[0].Address);
                    this.leadId = result[0].Id;
                    this.leadEnquiryId = result[0].Id;
                    this.firstName = result[0].EYI_Parent_Record__r.FirstName;
                    this.lastName = result[0].EYI_Parent_Record__r.LastName;
                    this.middleName = result[0].EYI_Parent_Record__r.MiddleName;
                    this.companyName = result[0].EYI_Company__c;
                    this.emailId = result[0].EYI_Parent_Record__r.Email;
                    this.mobileNumber = result[0].EYI_Parent_Record__r.Phone;
                    //this.residentialAddress = result[0].EYI_Parent_Record__r.Address;
                    //this.residentialAddress = { ...this.residentialAddress, Ud_Residential_Address__c: result[0].Address };
                    this.desiredConfiguration = result[0].EYI_Unit_Configuration__c;
                    this.budget = result[0].Ud_Budget__c;
                    this.areaReq = result[0].EYI_Area_Requirement_sq_ft__c;
                    this.purposeOfPurchase = result[0].EYI_Purpose_of_Purchase__c;
                    if(!this.isleasing){
                        this.preSales = result[0].OwnerId;
                    }
                    this.salesManager = result[0].EYI_Closing_Manager__c;
                    if(this.project!=null)
                        this.project = this.project;
                    else
                        this.project = result[0].EYI_Project_Enquired__c;
                    this.source = result[0].EYI_Lead_Source__c;
                    this.subsource = result[0].EYI_Lead_Sub_Source__c;
                    this.secondaryMobileNumber = result[0].EYI_Parent_Record__r.MobilePhone;
                    this.Ud_ResidentialAddressCountry = result[0].EYI_Parent_Record__r.Address.countryCode;
                    this.Ud_ResidentialAddressStreet = result[0].EYI_Parent_Record__r.Address.street;
                    this.Ud_ResidentialAddressitys = result[0].EYI_Parent_Record__r.Address.city;
                    this.Ud_ResidentialAddressPostalCode = result[0].EYI_Parent_Record__r.Address.postalCode;
                    this.Ud_ResidentialAddressState = result[0].EYI_Parent_Record__r.Address.stateCode;
                    if (this.residentialStatus != '' && this.residentialStatus != 'Indian') {
                        this.isNonIndian = true;
                    }

                    console.log('Check correct Lead');
                    //console.log(this.developer);
                }
                catch(err){
                    console.log('Error: 594',err,JSON.stringify(err));
                }


    }
    getLeadEn(init){
        getLead({ recId: this.recordId })
                .then(result => {
                    if(init){
                        console.log(result[0]);
                        console.log('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
                        this.leadFieldPopInCIF(result);
                    }else{
                        this.leadId = result[0].Id;
                        this.leadEnquiryId = result[0].Id;
                    }
                    console.log('$$$$$$$$$$$ result', result[0]);  
                })
                .catch(error => {
                    console.log(JSON.stringify(error),error);
                });
    }
    connectedCallback() {
        console.log('recordId -->', this.recordId);
        console.log('recordType', this.recordType);
        console.log('recordTypeLabel', this.recordTypeLabel);
        
        console.log('Email ConnectedCallback ', this.emailId);
        this.residentialStatus = 'Indian';
        this.typeOfArea = 'Carpet Area';
        if(this.cifRecord){
            if(this.custDetails!=null){
                this.project = this.custDetails.get("Project");
            }
            console.log('cif found for diff proj',this.cifRecord);
            this.ciffieldcloneinit = true;
        }
        else if (this.recordId && this.recordId != '') {
            this.leadEnquiryId = this.recordId;
            console.log('Calling Get Lead from EYI_CifFormCreation');
            this.getLeadEn(true);
            console.log('tet');
            console.log(this.recordId);
            console.log(this.custDetails);
            if(this.custDetails!=null)
                this.project = this.custDetails.get("Project");
            
        } else {
            console.log('custDetails ', JSON.stringify(this.custDetails),this.custDetails.get("Project"),this.custDetails.get("Phone"),this.custDetails.get("projType"));
            this.project = this.custDetails.get("Project");
            this.mobileNumber = this.custDetails.get("Phone");
            this.leadsourcesamewalkin = true;
            // this.source = 'Direct Client';
            // this.subsource = 'Direct walk-in at site';
            // this.handleProject();

        }
        this.getPropertyName(this.project);
    }

    getPropertyName(proj) {
        console.log('projectId in func', proj);
        getProjectById({projId : proj})
        .then(result => {
            console.log('property' , result);
            this.property = result;
        })
        .catch(error => {
            console.log('Error getting project Name' , error);
        })
    }

    handleLocationChange(event) {
        this.location = event.target.value;
        if (this.location === 'Other') {
            this.locOther = true;
        }else{
            this.locOther = false;
        }
    }

    handleDateChange(event) {
        const selectedDate = new Date(event.target.value);
        const today = new Date();

        if (selectedDate > today) {
            console.log('Date incorrect');
            this.error = 'Date of Birth cannot be greater than today.';
        } else {
            console.log('Date correct');
            this.error = null;
        }
    }
    handleClientType(event) {
        console.log('Selected Client type : ' + event.target.value);
        if (event.target.value == 'Person') {
            this.isPerson = true;
            this.isOrganisation = false;
        } else if (event.target.value == 'Organisation') {
            this.isPerson = false;
            this.isOrganisation = true;
        }
    }

}