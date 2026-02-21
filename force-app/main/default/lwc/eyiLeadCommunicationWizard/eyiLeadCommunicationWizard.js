import { api, LightningElement,track,wire } from 'lwc';
import getLeadInfo from '@salesforce/apex/EYI_LeadEnquiryUtility.getLeadInfo';
import getFilesByProjectId from '@salesforce/apex/EYI_LeadEnquiryUtility.getFilesByProjectId';
import getDMSByProjectId from '@salesforce/apex/EYI_LeadEnquiryUtility.getDMSByProjectId';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmail from '@salesforce/apex/EYI_EmailService.sendEmailAddActivity';
import getEmailTemplates from '@salesforce/apex/EYI_LeadEnquiryUtility.getEmailTemplates';
import getEmailTemplateDetails from '@salesforce/apex/EYI_LeadEnquiryUtility.getEmailTemplateDetails';
import getMessageTemplates from '@salesforce/apex/EYI_SMSWhatsAppUtility.getMessageTemplatesPresales';
import sendMessage from '@salesforce/apex/EYI_SMSService.sendSMSBrochure';
import sendWhatsAppMessage from '@salesforce/apex/EYI_WhatsAppService.sendWhatsAppBrochure';

import noProjectFilesMessage from '@salesforce/label/c.EYI_No_Files_for_Selected_Project';
import dndMessageLabel from '@salesforce/label/c.EYI_DND_Message';
import wizardLabel from '@salesforce/label/c.EYI_BrochureTitle' ;
import sendEmailLabel from '@salesforce/label/c.EYI_SendEmailTitle' ;
import sendSMSLabel from '@salesforce/label/c.EYI_SendSMSTitle' ;
import sendWPLabel from '@salesforce/label/c.EYI_SendWhatupTitle' ;
import selectfilesLabel from '@salesforce/label/c.EYI_SelectFilesTitle' ;
import selectTitle from '@salesforce/label/c.EYI_Select_Title' ;
import fileNameLabel from '@salesforce/label/c.EYI_File_Name' ;
import selectedfilesLabel from '@salesforce/label/c.EYI_SelectedFilesTitle' ;
import selectfilesToSendLabel from '@salesforce/label/c.EYI_SelectFilesToSendMessage' ;
import select10filesLabel from '@salesforce/label/c.EYI_SelectMax10FilesMessage' ;
import entermessagebodyLabel from '@salesforce/label/c.EYI_Enter_Message_to_Send' ;
import enternumberLabel from '@salesforce/label/c.EYI_Select_Number_For_SMS' ;

// Opportunity==>
import getOpportunityInfo from '@salesforce/apex/EYI_OpportunityUtility.getOpportunityInfo';
import getFilesByOpportunityId from '@salesforce/apex/EYI_OpportunityUtility.getFilesByOpportunityId';
import getOpportunityEmailTemplates from '@salesforce/apex/EYI_OpportunityUtility.getOpportunityEmailTemplates';
import updateOppNCFSentDate from '@salesforce/apex/EYI_OpportunityUtility.updateOppNCFSentDate';

import EMAIL_TEMPLATE_FOLDERS from '@salesforce/label/c.EYI_Brochure_Email_Templates';
import Opportunity_Brochure_title from '@salesforce/label/c.EYI_Opp_Brochure_Title';

import {NavigationMixin} from 'lightning/navigation'


export default class EyiLeadCommunicationWizard extends NavigationMixin(LightningElement) {

    @api recordId;
    @track sendEmail = sendEmailLabel;
    @track sendSMS = sendSMSLabel;
    @track sendWapp = sendWPLabel;
    selectfilestosend = selectfilesToSendLabel;
    selectnoOfFiles = select10filesLabel;
    selectfiles = selectfilesLabel;
    selectTitle = selectTitle;
    fileName = fileNameLabel;
    selectedfiles = selectedfilesLabel;
    @track brochureTitle = wizardLabel;
    noProjFilesMessage = noProjectFilesMessage;
    dndMessage = dndMessageLabel;
    selectmsgbody = entermessagebodyLabel;
    selectphonenumber = enternumberLabel;
    @track leadName='';
    @track ownerName ='';
    @track ownerPhone = '';
    @track isSmsModalOpen = false;
    @track isWhatsappModalOpen = false;
    @track isEmailModalOpen = false;
    @track isFirstScreen = true;
    @track primaryPhoneNumber = '';
    @track secondaryPhoneNumber = '';
    @track phoneNumber = '';
    @track messageBody = '';
    @track leadEmail = '';
    @track maskedEmail = '';
    @track maskedNumber = '';
    @track leadId = '';
    @track projectId = '';
    @track filesData = [];
    @track selectedFileNames = [];
    @track selectedFileIds = [];
    @track emailTemplateOptions = [];
    @track selectedTemplateId = '';
    @track selectedTemplateName = '';
    @track isNewEmail = '';
    @track istemplate = false;
    @track emailSubject = '';
    @track isSpinner = false;
    @track isProjectFiles = false;
    @track dndEnabled = false;
    @track communicationPreference = '';
    @track disableEmailBtn = true;
    @track disableSMSBtn = true;
    @track disableWappBtn = true;
    @track selectedNumberType ='primary';
    @track ccEmails = '';
    @track selectedTemplateFolder = '';
    @track folderOptions = [];
    get showTemplateSection() {
        return this.selectedTemplateId || this.isNewEmail;
    }
    dmsCOLUMNS = [
        { label: 'Document Name', fieldName: 'EYI_Document_Name__c', type: 'text' },
        { label: 'Link', fieldName: 'EYI_Document_Link__c', type: 'url', typeAttributes: { label: { fieldName: 'EYI_Document_Link__c' }, target: '_blank' } }
    ];  
    columns = [
        {
            label: 'Select',
            fieldName: 'select',
            type: 'checkbox',
            fixedWidth: 50,
            sortable: false,
            wrapText: true
        },
        {
            label: 'File Name',
            fieldName: 'title',
            type: 'text',
            sortable: true,
            wrapText: true
        },
        {
            label: 'Preview',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:preview',
                name: 'preview',
                variant: 'brand',
                alternativeText: 'Preview',
                disabled: false
        },
        cellAttributes: {
            alignment: 'center'
        }
        }
    ];

    numberOptions = [
        { label: 'Primary', value: 'primary' },
        { label: 'Secondary', value: 'secondary' }
    ];

    @track smsTemplateOptions = []; 
    @track smsTemplates = [];
    @track filteredSMSTemplates = [];
    @track selectedSMSTemplate = '';

    @track isOpportunity = false;
    @track oppProjectId ='';
    @track towerId ='';

    @track isNCFEmailTemplate = false;
    @track dmsLinks = [];
    @track selectedDMSRows = [];
    @track textBody = '';
    connectedCallback() {
        console.log('this.recordId===> ',this.recordId);
        this.isOpportunity = (this.recordId.startsWith('006') ? true : false);
        console.log('this.isOpportunity===> ',this.isOpportunity);
        if(this.isOpportunity){
            this.disableEmailBtn = false;
            this.brochureTitle= Opportunity_Brochure_title;
            this.createFolderOptions();
            this.fetchOpportunityData();
        }else{
            this.fetchLeadData();
            this.fetchEmailTemplates();
        }
    }
    createFolderOptions() {
        const folderNames = EMAIL_TEMPLATE_FOLDERS.split(',');
        this.folderOptions = folderNames.map(folder => {
            return { label: folder.trim(), value: folder.trim() };
        });
    }
    fetchLeadData() {
        getLeadInfo({ leadEnqId: this.recordId })
            .then(data => {
                if (data) {
                    console.log('data==> ', JSON.stringify(data));

                    this.leadName = data.Name;
                    this.ownerName = data.Owner.Name;
                    this.ownerPhone = data.Owner.Phone;
                    console.log('leadName==> ', this.leadName);
                    console.log('ownerName==> ', this.ownerName);
                    console.log('ownerPhone==> ', this.ownerPhone);

                    this.leadEmail = data.EYI_Email__c;
                    this.primaryPhoneNumber = data.EYI_Phone__c;
                    this.secondaryPhoneNumber = data.EYI_Mobile__c;
                    this.projectId = data.EYI_Project_Enquired__c;
                    this.dndEnabled = data.EYI_DND__c;
                    this.communicationPreference = data.EYI_Client_Communication_Preference__c;

                    if (this.communicationPreference.includes('All')) {
                        this.disableEmailBtn = false;
                        this.disableSMSBtn = false;
                        this.disableWappBtn = false;
                    } else {
                        this.disableEmailBtn = !this.communicationPreference.includes('Email');
                        this.disableSMSBtn = !this.communicationPreference.includes('SMS');
                        this.disableWappBtn = !this.communicationPreference.includes('WhatsApp');
                    }

                    this.maskedEmail = this.getMaskedEmail();
                    this.phoneNumber = this.primaryPhoneNumber !== '' ? this.primaryPhoneNumber : (this.secondaryPhoneNumber !== '' ? this.secondaryPhoneNumber : '');
                    console.log('Lead Data:', data);
                    this.maskedNumber = this.getMaskedPhone();
                    this.fetchFiles();
                    this.fetchDMSData();
                } else {
                    this.leadEmail = '';
                    this.primaryPhoneNumber = '';
                    this.secondaryPhoneNumber = '';
                    this.phoneNumber = '';
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    handlenew(event){
        this.isNewEmail = true;
        this.ccEmails ='';
        this.Subject = '';
        this.messageBody = '';
    }
    fetchOpportunityData() {
        getOpportunityInfo({ oppId: this.recordId })
            .then(data => {
                if (data) {
                    console.log('Opportunity Data:', JSON.stringify(data));
                    this.oppProjectId = data.EYI_Project_Enquired__c;
                    this.towerId = data.EYI_Project_Tower_Enquired__c;
                    this.maskedEmail = data.EYI_Email__c;
                    this.fetchOpportunityFiles();
                } else {
                   
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    
    @wire(getEmailTemplates)
    wiredTemplates({ error, data }) {
        if (data) {
            this.emailTemplateOptions = data.map(template => {
                return { label: template.Name, value: template.Id };
            });
        } else if (error) {
            console.error('Error fetching email templates:', error);
        }
    }
    fetchEmailTemplates() {
        getEmailTemplates()
            .then(data => {
                this.emailTemplateOptions = data.map(template => {
                    return { label: template.Name, value: template.Id };
                });
            })
            .catch(error => {
                console.error('Error fetching email templates:', error);
            });
    }
    @wire(getMessageTemplates)
    messageTemplates({ data, error }) {
        if (data) {
            this.smsTemplates = data; // Store the data into templates property
            this.setSMSTemplateOptions(); // Update the second dropdown options based on templates
            console.log('this.smsTemplates==>',JSON.stringify(this.smsTemplates));
        } else if (error) {
            // Handle the error
            console.error('Error fetching templates:', error);
        }
    }
    fetchFiles() {
        getFilesByProjectId({ projectId: this.projectId })
            .then((data) => {
                this.filesData = data;  // Store the files in the filesData array
                console.log('File data:', JSON.stringify(data));
                if (data && data.length > 0) {
                    this.isProjectFiles = true;  // Set isProjectFiles to true if there are files
                } else {
                    this.isProjectFiles = false;  // Set isProjectFiles to false if no files
                }
            })
            .catch((error) => {
                console.error('Error fetching files:', error);
            });
    }
    fetchDMSData() {
        getDMSByProjectId({ projectId: this.projectId })
            .then((data) => {
                this.dmsLinks = data;  // Store the files in the filesData array
                console.log('File data:', JSON.stringify(data));
                if (data && data.length > 0) {
                    this.isProjectFiles = true;  // Set isProjectFiles to true if there are files
                } else {
                    this.isProjectFiles = false;  // Set isProjectFiles to false if no files
                }
            })
            .catch((error) => {
                console.error('Error fetching files:', error);
            });
    }
    fetchOpportunityFiles() {
        getFilesByOpportunityId({ oppId: this.recordId, oppProjectId:this.oppProjectId })
            .then((data) => {
                this.filesData = data;  // Store the files in the filesData array
                console.log('File data:', JSON.stringify(data));
                if (data && data.length > 0) {
                    this.isProjectFiles = true;  // Set isProjectFiles to true if there are files
                } else {
                    this.isProjectFiles = false;  // Set isProjectFiles to false if no files
                }
            })
            .catch((error) => {
                console.error('Error fetching files:', error);
            });
    }
    getOpportunityEmailTemplates() {
        getOpportunityEmailTemplates({templateName:this.selectedTemplateFolder})
            .then((data) => {   
                console.log('Email template data:', JSON.stringify(data));

                this.emailTemplateOptions = data.map(template => {
                    return { label: template.Name, value: template.Id };   
                });
                console.log('Email template options:', JSON.stringify(this.emailTemplateOptions));
            }) 
            .catch((error) => {
                console.error('Error fetching email templates:', error);
            });
    }
    updateOppNCFSentDate(){

        updateOppNCFSentDate({oppId:this.recordId})
            .then((data) => {
                console.log('Updated successfully',this.recordId);
            })
            .catch((error) => {
                console.error('Error updating the Opportunity:', error);
            });
    }

    handleSmsClick() {
        console.log('this.recordId 1==>',this.recordId);
        this.isSmsModalOpen = true;
        console.log('this.phoneNumber 1==>',this.phoneNumber);
        this.maskedNumber = this.getMaskedPhone();
        //this.setSMSTemplateOptions();
    }

    handleWhatsappClick() {
        this.isWhatsappModalOpen = true;
        this.maskedNumber = this.getMaskedPhone();
       // this.setSMSTemplateOptions();
    }

    handleEmailClick() {
        this.isEmailModalOpen = true;
        this.isSpinner = true;

        if (this.emailTemplateOptions.length > 0) {
           // this.selectedTemplateId = this.emailTemplateOptions[0].value;
            console.log('Selected template:', this.selectedTemplateId);
            // this.selectedTemplateName = this.emailTemplateOptions[0].label;
            const selectedTemplate = this.emailTemplateOptions.find(template => template.value === this.selectedTemplateId);
            this.selectedTemplateName = selectedTemplate ? selectedTemplate.label : '';
    
            console.log('Selected selectedTemplateName:', this.selectedTemplateName);

            if(this.selectedTemplateName.includes('NCF')){
                this.isNCFEmailTemplate = true;
            }else{
                this.isNCFEmailTemplate = false;
            }
            
            console.log('Selected selectedTemplateName:', this.selectedTemplateName);

            getEmailTemplateDetails({ templateId: this.selectedTemplateId })
            .then(result => {
                this.emailSubject = result.Subject;
                this.messageBody = result.Body;
                console.log('this.emailSubject==>',this.emailSubject);
                console.log('this.messageBody==>',this.messageBody);

                if(this.isOpportunity){
                }else{
                    this.messageBody = this.messageBody
                    .replace('{!EYI_Lead_Enquiry__c.Name}', this.leadName)
                    .replace('{!EYI_Lead_Enquiry__c.OwnerFullName}', this.ownerName)
                    .replace('{!EYI_Lead_Enquiry__c.OwnerPhone}', this.ownerPhone);
                }
                this.isSpinner = false;
            })
            .catch(error => {
                console.error('Error fetching template details:', error);
            });
        }
    }
    handleNumberChange(event) {
        try{
            this.selectedNumberType = event.target.value;
            if(this.selectedNumberType == 'primary'){
                this.phoneNumber = this.primaryPhoneNumber;
                if(this.primaryPhoneNumber == '' && this.secondaryPhoneNumber != ''){
                    this.phoneNumber = this.secondaryPhoneNumber;
                }
                // else if(this.primaryPhoneNumber.startsWith('+')){
                this.maskedNumber = this.getMaskedPhone();
            }
            else{
                this.phoneNumber = this.secondaryPhoneNumber;
                if(this.secondaryPhoneNumber == ''){
                    this.phoneNumber = this.primaryPhoneNumber;
                }
                this.maskedNumber = this.getMaskedPhone();
            }
        }catch(e){
            console.log('Error:',e);
        }
       
    }
    
    closeModal() {
        this.isSmsModalOpen = false;
        this.isWhatsappModalOpen = false;
        this.isEmailModalOpen = false;
        this.selectedFileNames = [];
        this.selectedFileIds = [];
        this.isFirstScreen = true;
        this.emailSubject = '';
        this.messageBody = '';
        this.selectedTemplateId = '';
        this.selectedNumberType ='';
        this.phoneNumber ='';
        //this.maskedEmail = '';
        this.textBody = '';
        this.maskedNumber = '';
        this.sendEmail = sendEmailLabel;
        this.sendSMS = sendSMSLabel;
        this.sendWapp = sendWPLabel;
        this.isNCFEmailTemplate  = false;
        this.selectedTemplateFolder = '';
        this.ccEmails = '';
        this.isSpinner = false;
        this.isNewEmail = false;
         this.istemplate = false;
        // this.isProjectFiles = false;
    }

    // handleprimaryPhoneNumberChange(event) {
    //     this.primaryPhoneNumber = event.target.value;
    // }

    handleMessageChange(event) {
        try {
            this.messageBody = event.target.value;
        } catch (error) {
            console.error('Error handling message change:', error);
        }
    }
    
    handleSubjectChange(event) {
        try {
            this.emailSubject = event.target.value;
        } catch (error) {
            console.error('Error handling subject change:', error);
        }
    }
    
    handleEmailChange(event) {
        try {
            this.leadEmail = event.target.value;
            if(this.isOpportunity){
                this.maskedEmail = event.target.value;
            }
        } catch (error) {
            console.error('Error handling email change:', error);
        }
    }
    
    handleCCEmailChange(event) {
        try {
            this.ccEmails = event.target.value;
            console.log('ccEmails:', this.ccEmails);
        } catch (error) {
            console.error('Error handling CC email change:', error);
        }
    }
    
    handleEmailFolderChange(event) {
        try {
            this.selectedTemplateFolder = event.target.value;
            console.log('selectedTemplateFolder ==>', this.selectedTemplateFolder);
            this.istemplate = true;
            this.getOpportunityEmailTemplates();
        } catch (error) {
            console.error('Error handling email folder change:', error);
        }
    }
    
    handleNext() {
        if(this.ccEmails != '' && this.ccEmails != null && this.ccEmails != undefined){
                // alert('Please enter cc email address to send in the email.');)
            let validEmail = this.validateCCEmails();
            if(validEmail){
                this.isFirstScreen = false;
                this.sendEmail = this.selectfiles;
                this.sendSMS = this.selectfiles;
                this.sendWapp = this.selectfiles;
            }else{
                this.showToast('Please enter valid cc email address', '', 'error');
            }
        }else{
            this.isFirstScreen = false;
            this.sendEmail = this.selectfiles;
            this.sendSMS = this.selectfiles;
            this.sendWapp = this.selectfiles;
        }
        // Load project options based on lead details
    }
    validateCCEmails() {
        const emails = this.ccEmails.split(',');
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        let allValid = true;
    
        emails.forEach(email => {
            if (!emailPattern.test(email.trim())) {
                allValid = false;
            }
        });
    
        return allValid;

    }
    handlePrevious() {
        this.isFirstScreen = true;
        this.sendEmail = sendEmailLabel;
        this.sendSMS = sendSMSLabel;
        this.sendWapp = sendWPLabel;
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'preview':
                this.previewFile(row);
                break;
            default:
        }
    }

    previewFile(row) {
        // Implement your file preview logic here
        // this.dispatchEvent(
        //     new ShowToastEvent({
        //         title: 'Preview File',
        //         message: `Previewing file: ${row.fileName}`,
        //         variant: 'info'
        //     })
        // );
        console.log('event.target.dataset.id==>',row.fileid);

        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: row.fileid
            }
        })
    }

    handleRowSelection(event) {
        // Get selected rows
        try{
            const selectedRows = event.detail.selectedRows;
            selectedRows.forEach(row => {
                this.selectedFileIds.push(row.fileid);      // Store fileid in selectedFileIds
                this.selectedFileNames.push(row.title);     // Store title in selectedFileNames
            });
            console.log('File filename:', filename);
            console.log('File ID:', fileId);
        }catch(e){
            console.log('Error in handleRowSelection:', e);
        }
        // this.selectedRows = selectedRows;
    }

    handleDMSRowSelection(event) {
        try {
            const selectedRows = event.detail.selectedRows; // correct: get from event
            if (!selectedRows || selectedRows.length === 0) {
                this.textBody = '';
            } else {
                this.textBody = ''; // clear previous content
                selectedRows.forEach(row => {
                    this.textBody += `${row.EYI_Document_Name__c}: ${row.EYI_Document_Link__c}\n`;
                });
            }
            console.log('Generated Email Body:\n', this.textBody);
        } catch (e) {
            console.error('Error in handleDMSRowSelection:', e);
        }
    }

    handleSendEmail() {
        try{
            if(this.isOpportunity){
                const emailRequest = {
                    leadId: this.recordId,             // Lead ID
                    projectName: this.projectName,     // Project name
                    projectId: this.oppProjectId,         // Project ID
                    senderEmail: this.maskedEmail,       // Sender email
                    ccEmails : this.ccEmails,
                    senderPhone: this.phoneNumber,     // Sender phone
                    selectedFileIds: this.selectedFileIds, // List of selected file IDs
                    messageBody: this.messageBody,
                    emailSubject: this.emailSubject
                };
                
                // Ensure selectedFiles is an array of valid IDs
                console.log('Selected Files: ', this.selectedFiles);
                console.log('Email Request Wrapper: ', JSON.stringify(emailRequest));
                
                sendEmail({ emailRequestJson: JSON.stringify(emailRequest) })
                    .then(() => {
                        this.showToast('Success', 'Email sent successfully!', 'success');
                    })
                    .catch((error) => {
                        console.error('Error:', error);  // Log the error to see what's happening
                        this.showToast('Error', 'There was an error sending the email: ' + error.body.message, 'error');
                    });
                // Implement send logic
                if(this.isNCFEmailTemplate){
                    this.updateOppNCFSentDate();
                }
                this.closeModal();
            }else{
                if(this.messageBody === '') {
                    // alert('Please enter message to send in the email.');
                    this.showToast('Error', selectmsgbody, 'error');
                    return;
                }
                if (this.textBody === '') {
                    // alert('Please select files to send in the email.');
                    this.showToast('Error', 'Please Select docunemt Links', 'error');
                    return;
                } else{
                    this.messageBody = this.messageBody
                    .replace('{!EYI_Project__c.EYI_Brochure_Link__c}', this.textBody);

                    const emailRequest = {
                        leadId: this.recordId,             // Lead ID
                        projectName: this.projectName,     // Project name
                        projectId: this.projectId,         // Project ID
                        senderEmail: this.leadEmail,       // Sender email
                        senderPhone: this.phoneNumber,     // Sender phone
                        selectedFileIds: this.selectedFileIds, // List of selected file IDs
                        messageBody: this.messageBody,
                        emailSubject: this.emailSubject
                    };
                    
                    // Ensure selectedFiles is an array of valid IDs
                    console.log('Selected Files: ', this.selectedFiles);
                    console.log('Email Request Wrapper: ', JSON.stringify(emailRequest));
                    
                    sendEmail({ emailRequestJson: JSON.stringify(emailRequest) })
                        .then(() => {
                            this.showToast('Success', 'Email sent successfully!', 'success');
                        })
                        .catch((error) => {
                            console.error('Error:', error);  // Log the error to see what's happening
                            this.showToast('Error', 'There was an error sending the email: ' + error.body.message, 'error');
                        });
                    // Implement send logic
                    this.closeModal();
                }
            }
        } catch (error) {
                
        }
    }


    handleSendSMS(){
        if(this.messageBody === '') {
            // alert('Please enter message to send in the email.');
            this.showToast('Error', selectmsgbody, 'error');
            return;
        }
        if(this.phoneNumber === '') {
            // alert('Please enter phone number to send in the SMS.');
            this.showToast('Error', selectphonenumber, 'error');
            return;
        }
        try{
            sendMessage({ phonenumber: this.phoneNumber, message: this.messageBody, recId: this.recordId })
                .then(() => {
                    this.showToast('Success', 'SMS sent successfully!', 'success');
                })
                .catch((error) =>{
                    console.error('Error:', error);  // Log the error to see what's happening
                    this.showToast('Error', 'There was an error sending the SMS: ' + error.body.message, 'error');
                });
                this.closeModal();

        }catch(error){

        }
    }

    handleSendWhatsApp(){
        if(this.messageBody === '') {
            // alert('Please enter message to send in the email.');
            this.showToast('Error', selectmsgbody, 'error');
            return;
        }
        if(this.phoneNumber === '') {
            // alert('Please enter phone number to send in the SMS.');
            this.showToast('Error', selectphonenumber, 'error');
            return;
        }
        // let prm1 = this.recordId + ',' + 'EYI_Phone__c' + ',' + '' + ',' 
        // + this.senderNumber + ',' + this.documentId;
        try{
            sendWhatsAppMessage({ phonenumber: this.phoneNumber, message: this.messageBody, recId: this.recordId })
                .then(() => {
                    this.showToast('Success', 'WhatsApp message sent successfully!', 'success');
                })
                .catch((error) =>{
                    console.error('Error:', error);  // Log the error to see what's happening
                    this.showToast('Error', 'There was an error sending the SMS: ' + error.body.message, 'error');
                });
                this.closeModal();

        }catch(error){

        }
    }
   
    getMaskedPhone() {
        if (this.phoneNumber && this.phoneNumber.length >= 6) {
            console.log('this.phoneNumber ==> ',this.phoneNumber);
            return '********' + this.phoneNumber.slice(8);  // Mask first 8 digits, show the rest
        }
        return this.phoneNumber;
    }

    // Masking the email (before @)
    getMaskedEmail() {
        if (this.leadEmail && this.leadEmail.includes('@')) {
            const [localPart, domain] = this.leadEmail.split('@');
            return '*******' + '@' + domain;  // Mask local part, leave domain
        }
        return this.leadEmail;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
 
    // handleCheckboxChange(event) {
    //     const filename = event.target.dataset.filename;
    //     const fileId = event.target.dataset.fileid;
    //     console.log('File filename:', filename);
    //     console.log('File ID:', fileId);
    
    //     // Check if the checkbox is checked or unchecked
    //     if (event.target.checked) {
    //         // Add fileId to selectedFileIds and filename to selectedFileNames if checked
    //         this.selectedFileNames = [...this.selectedFileNames, filename];
    //         this.selectedFileIds = [...this.selectedFileIds, fileId];
    //     } else {
    //         // Remove fileId from selectedFileIds and filename from selectedFileNames if unchecked
    //         this.selectedFileNames = this.selectedFileNames.filter(name => name !== filename);
    //         this.selectedFileIds = this.selectedFileIds.filter(id => id !== fileId);
    //     }
    // }

    handleEmailTemplateChange(event) {
        this.isSpinner = true;
        console.log('event.detail==> ', event.detail);
        console.log('event.detail.Label==> ', event.detail.label);
        // this.selectedTemplateName = event.detail.label;;
        this.selectedTemplateId = event.detail.value;
        const selectedTemplate = this.emailTemplateOptions.find(template => template.value === this.selectedTemplateId);
        this.selectedTemplateName = selectedTemplate ? selectedTemplate.label : '';
    
        if(this.selectedTemplateName.includes('NCF')){
            this.isNCFEmailTemplate = true;
        }else{
            this.isNCFEmailTemplate = false;
        }
        getEmailTemplateDetails({ templateId: this.selectedTemplateId })
            .then(result => {
                this.emailSubject = result.Subject;
                this.messageBody = result.Body;
                if(this.opprtunity){
                    this.messageBody = this.messageBody;
                }else{
                    this.messageBody = this.messageBody
                    .replace('{!EYI_Lead_Enquiry__c.Name}', this.leadName)
                    .replace('{!EYI_Lead_Enquiry__c.OwnerFullName}', this.ownerName)
                    .replace('{!EYI_Lead_Enquiry__c.OwnerPhone}', this.ownerPhone);
                }
                this.isSpinner = false;
            })
            .catch(error => {
                console.error('Error fetching template details:', error);
            });
    }

    setSMSTemplateOptions() {

        // if (this.smsTemplates.length > 0) {
        //     this.templateOptions = this.smsTemplates
        //         .filter(template => template.tdc_tsw__Channel__c === this.selectedType) // Filter templates by selected type
        //         .map(template => ({
        //             label: template.Template_Name__c,
        //             value: template.Id
        //         }));
        // }
        if (this.smsTemplates.length > 0) {
            if(this.isSmsModalOpen){
                console.log('in if ');

                this.filteredSMSTemplates = this.smsTemplates.filter(template => template.tdc_tsw__Channel__c == 'SMS/MMS');
            }else if(this.isWhatsappModalOpen){
                console.log('in else if ');

                this.filteredSMSTemplates = this.smsTemplates.filter(template => template.tdc_tsw__Channel__c == 'WhatsApp');
            }else{
                this.filteredSMSTemplates = this.smsTemplates;
            }

            this.smsTemplateOptions = this.filteredSMSTemplates.map(template => ({
                label: template.Name,
                value: template.Id
            }));
            console.log('this.smsTemplateOptions3==> ',JSON.stringify(this.smsTemplateOptions));
        }else{
            console.log('no template exists');
        }
    }

    handleSMSTemplateChange(event) {
        const selectedTemplateId = event.target.value;
        const selectedTemplate = this.smsTemplates.find(template => template.Id === selectedTemplateId);
        console.log('selectedTemplate12',selectedTemplate);
        if (selectedTemplate) {
            this.messageBody = selectedTemplate.tdc_tsw__SMSBodyNew__c;
        }
    }
}