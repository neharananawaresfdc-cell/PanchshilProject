import { LightningElement, api, wire, track } from 'lwc';
import getOpportunities from '@salesforce/apex/EYI_TowerUtility.getOpportunities';
import getTowerDocuments from '@salesforce/apex/EYI_TowerUtility.getTowerDocuments';
import sendEmails from '@salesforce/apex/EYI_TowerUtility.sendEmails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmailTemplates from '@salesforce/apex/EYI_TowerUtility.getEmailTemplates';

// import wizardLabel from '@salesforce/label/c.EYI_BrochureTitle' ;

export default class Eyi_TowerOpportunityEmailModal extends LightningElement {

    @api recordId;

    @track stepOne = true;
    @track stepTwo = false;
    @track opportunityData = [];
    @track documentData = [];
    @track selectedOppIds = [];
    @track selectedDocIds = [];
    @track isModalOpen = false;
    @track currentStep = 1;
    @track brochureTitle = 'Utility Emails';
    @track templatesMap = new Map();
    @track emailSubject = '';
    @track emailBody = '';
    selectedTemplateId;
    @track isNewEmail = false;
    @track istemplate =  false;
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'EYI_Email__c' }
    ];

    docColumns = [
        { label: 'Title', fieldName: 'title', type: 'text' },
        { label: 'File Type', fieldName: 'fileType', type: 'text' },
        { label: 'File Size', fieldName: 'fileSize', type: 'text' }

    ];
    get showTemplateSection() {
        return this.isNewEmail || this.istemplate;
    }
    get hasOpportunities() {
        return this.opportunityData && this.opportunityData.length > 0;
    }
    connectedCallback() {
        this.getEmailTemplates();
    }
    getEmailTemplates(){
        getEmailTemplates()
                .then(result => {
                    this.templateOptions = result.map(t => {
                        // Store full template data for later use
                        this.templatesMap.set(t.Id, t);
                        return { label: t.Name, value: t.Id };
                    });
                })
                .catch(error => {
                    console.error('Error fetching templates', error);
                });
    }
    handleEmailFolderChange(event) {
        this.selectedTemplateId = event.target.value;
        //this.istemplate = true;
        this.isNewEmail = true;
        const selectedTemplate = this.templatesMap.get(this.selectedTemplateId);

        if (selectedTemplate) {
            this.emailSubject = selectedTemplate.Subject;
            this.emailBody = selectedTemplate.HtmlValue || selectedTemplate.Body || '';
        }
    }
    handlenewEmailChange() {
        this.istemplate = false;
        this.isNewEmail = true;
        this.emailSubject = '';
        this.emailBody = '';
    }
    handleSubjectChange(event) {
        this.emailSubject = event.target.value;
    }

    handleBodyChange(event) {
        this.emailBody = event.target.value;
    }
    closeModal() {
        this.isModalOpen = false;
        this.emailBody = '';
        this.emailSubject = '';
        this.selectedDocIds = [];
        this.selectedOppIds = [];
        this.isNewEmail = false;
        this.istemplate = false;
        this.selectedTemplateId = '';
    }
    handleOpportunitySelection(event) {
        this.selectedOppIds = event.detail.selectedRows.map(row => row.Id);
    }

    handleDocumentSelection(event) {
        this.selectedDocIds = event.detail.selectedRows.map(row => row.ContentDocumentId);
    }

    goToStepTwo() {
        if (!this.selectedOppIds.length) {
            this.showToast('Please select at least one opportunity.', 'error');
            return;
        }
        this.stepOne = false;
        this.stepTwo = true;
    }

    goToStepOne() {
        this.stepTwo = false;
        this.stepOne = true;
    }
    formatFileSize(bytes) {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    fetchTowerDocuments() {
        getTowerDocuments({ towerIds: [this.recordId] })
            .then(result => {
                console.log('Tower Document Result:', JSON.stringify(result));
                this.documentData = result.map(item => {
                    const contentSize = item.ContentDocument?.ContentSize;
                    console.log('Raw ContentSize:', contentSize);

                    return {
                        ...item,
                        title: item.ContentDocument?.Title || '',
                        fileType: item.ContentDocument?.FileType || '',
                        fileSize: this.formatFileSize(contentSize || 0)
                    };
                });
            });
    }

    get isStepOne() {
        return this.currentStep === 1;
    }
    get isStepTwo() {
        return this.currentStep === 2;
    }
    get isStepThree() {
        return this.currentStep === 3;
    }

    handleNext() {
        if (this.currentStep === 1) {
            this.fetchTowerDocuments();
            if (!this.emailSubject || !this.emailBody) {
                this.showToast('Please enter both subject and body.', 'error');
                return;
            }
        }
        if(this.istemplate){
            if (this.currentStep === 2 && !this.selectedOppIds.length) {
                this.showToast('Please select at least one opportunity.', 'error');
                return;
            }
        }else{
            if (this.currentStep === 2 && !this.selectedOppIds.length) {
                this.showToast('Please select at least one opportunity.', 'error');
                return;
            }
        }
        this.currentStep++;
    }

    handleBack() {
        if (this.currentStep > 1) {
            this.currentStep--;
        }
    }
    handleGetOpportunitiesClick() {
        getOpportunities({ towerId: this.recordId })
            .then(result => {
                this.opportunityData = result;
            })
            .catch(error => {
                this.showError(error);
        });
    }


    sendEmail() {
         if (!this.selectedOppIds.length && this.template) {
            this.showToast('Please select at least one Opportunity.', 'error');
            return;
        }
        // if (!this.selectedDocIds.length && this.isNewEmail) {
        //     this.showToast('Please select at least one document.', 'error');
        //     return;
        // }
        sendEmails({
            opportunityIds: this.selectedOppIds,
            documentIds: this.selectedDocIds,
            subject: this.emailSubject,
            body: this.emailBody
        }).then(() => {
            this.showToast('Emails sent successfully!', 'success');
            this.closeModal();
            //this.dispatchEvent(new CloseActionScreenEvent());
        }).catch(error => {
            this.showError(error);
        });
    }

    openModal() {
        this.isModalOpen = true;
        this.handleGetOpportunitiesClick();
        console.log('recordid=========>',this.recordId);
        this.currentStep = 1;
    }

    showToast(message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Status',
                message: message,
                variant: variant
            })
        );
    }

    showError(error) {
        this.showToast(error.body.message || 'Unknown error', 'error');
    }
}