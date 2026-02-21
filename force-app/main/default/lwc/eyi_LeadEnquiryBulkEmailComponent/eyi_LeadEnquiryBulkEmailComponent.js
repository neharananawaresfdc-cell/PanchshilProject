import { LightningElement, api, wire, track } from 'lwc';
import getLeadEnquiries from '@salesforce/apex/EYI_LeadEnquiryUtility.getLeadEnquiries';
import getTowerDocuments from '@salesforce/apex/EYI_LeadEnquiryUtility.getLeadDocuments';
import queryObjectsByFields from '@salesforce/apex/EYI_LeadEnquiryUtility.queryObjectsByFields';
import sendEmails from '@salesforce/apex/EYI_LeadEnquiryUtility.sendEmails';
import getGroupedFieldOptions from '@salesforce/apex/EYI_LeadEnquiryUtility.getGroupedValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmailTemplates from '@salesforce/apex/EYI_LeadEnquiryUtility.getBulkEmailTemplates';

export default class Eyi_LeadEnquiryBulkEmailComponent extends LightningElement {

    @track stepOne = true;
    @track stepTwo = false;
    @track leadData = [];
    @track documentData = [];
    @track selectedLeadIds = [];
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
    @api filterColumnsAPINames=["EYI_Campaign_Name__c", "EYI_Lead_Status__c"];
    @api filterColumnLabels=["Campaign", "Status"];
    @track fieldwiseoptions = {};
    filterData = [];
    @track filterfieldValuesMap = {};
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'EYI_Email__c' }
    ];

    docColumns = [
        { label: 'Title', fieldName: 'title', type: 'text' }
    ];
    get showTemplateSection() {
        return this.isNewEmail || this.istemplate;
    }
    get hasLeads() {
        return this.leadData && this.leadData.length > 0;
    }
    get hasLeadDocs() {
        return this.documentData && this.documentData.length > 0;
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
                    this.getPicklistValues();
                })
                .catch(error => {
                    console.error('Error fetching templates', error);
                });
    }
    getPicklistValues(){
        this.filterColumnsAPINames.forEach((currentElement, index) => {
            this.getFieldOptions(currentElement)
        });
        setTimeout(() => {
            this.updatePicklistValues();
        }, 2000);
    }
    updatePicklistValues() {
        // Logic to populate the filter picklists.
        this.filterColumnsAPINames.forEach((currentElement, index) => {
            this.filterData = [
                ...this.filterData,
                {
                    fieldIndex: index,
                    fieldName: currentElement,
                    fieldLabel: this.filterColumnLabels[index],
                    fieldValue: "",
                    fieldOptions:  this.fieldwiseoptions[currentElement]
                }
            ];
            console.log(currentElement,this.filterData);
        });
        // console.log('this.filterData ===> ' + JSON.stringify(this.filterData));
    }
    getFieldOptions(fieldApiName) {
        getGroupedFieldOptions({ objectName: 'EYI_Lead_Enquiry__c' , fieldName: fieldApiName })
                .then(result => {
                    console.log('group options1',result);
                    let options = [];
                    if (result) {
                        try{
                        //     result.forEach((value,key) => {
                        //     options.push({ label: key, value: value });
                        // });
                        
                        
                        for(let key in result) {
                            console.log('key',key);
                            options.push({ label: key , value: result[key] });
                        }
                        // options = result.map(t => {
                        //     console.log(t,JSON.stringify(t));
                        //     return { label: t.key, value: t.value };
                        // });
                        }catch(e){
                            console.log('cannot gen opts',e,JSON.stringify(e));
                        }
                        console.log('group options2',result,options,JSON.stringify(options));
                        this.fieldwiseoptions[fieldApiName] = options;
                        console.log('field option',this.fieldwiseoptions,JSON.stringify(this.fieldwiseoptions));
                        // this.fieldwiseoptions.set(fieldApiName,options);)
                    }
                    
                })
                .catch(error => {
                    console.error('Error fetching templates', error);
                })
                .finally(() => {
                    
                    // this.isLoading = false;
                });
    }
    changeHandler (event) {
        // Logic to update the data inside the datatable based on the values selected in the picklist.
        let currentFieldName = event.target.name;
        let currentFieldValue = event.target.value;
        let currentFieldLabel = event.target.label;
        console.log('filter field value maps ',currentFieldName);
        let selvals = this.filterfieldValuesMap[currentFieldName];
        if(!selvals){
            selvals = [];
        }
        selvals.push(currentFieldValue);
        this.filterfieldValuesMap[currentFieldName] = selvals;
        console.log('filter field value maps ',this.filterfieldValuesMap,JSON.stringify(this.filterfieldValuesMap));
        this.getfilteredData();

    }
    getfilteredData(){
        queryObjectsByFields({objectApiName: 'EYI_Lead_Enquiry__c',fieldValuesMap: this.filterfieldValuesMap})
                .then(result => {
                    this.leadData = result;
                })
                .catch(error => {
                    console.error('Error fetching templates', error);
                });
    }
    handleEmailFolderChange(event) {
        this.selectedTemplateId = event.target.value;
        this.istemplate = true;
        this.isNewEmail = false;
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
        this.selectedLeadIds = [];
        this.isNewEmail = false;
        this.istemplate = false;
        this.selectedTemplateId = '';
    }
    handleOpportunitySelection(event) {
        this.selectedLeadIds = event.detail.selectedRows.map(row => row.Id);
    }

    handleDocumentSelection(event) {
        this.selectedDocIds = event.detail.selectedRows.map(row => row.ContentDocumentId);
    }

    goToStepTwo() {
        if (!this.selectedLeadIds.length) {
            this.showToast('Please select at least one Lead.', 'error');
            return;
        }
        this.stepOne = false;
        this.stepTwo = true;
    }

    goToStepOne() {
        this.stepTwo = false;
        this.stepOne = true;
    }

    fetchTowerDocuments() {
        getTowerDocuments({ leadIds: [this.selectedLeadIds] })
            .then(result => {
                // Flatten ContentDocument.Title into a top-level property
                this.documentData = result.map(item => ({
                    ...item,
                    title: item.ContentDocument?.Title || ''
            }));
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
            if (this.currentStep === 2 && !this.selectedLeadIds.length) {
                this.showToast('Please select at least one Lead.', 'error');
                return;
            }
        }else{
            if (this.currentStep === 2 && !this.selectedLeadIds.length) {
                this.showToast('Please select at least one Lead.', 'error');
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
    handlegetLeadEnquiriesClick() {
        getLeadEnquiries()
            .then(result => {
                this.leadData = result;
            })
            .catch(error => {
                this.showError(error);
        });
    }


    sendEmail() {
         if (!this.selectedLeadIds.length && this.template) {
            this.showToast('Please select at least one Lead.', 'error');
            return;
        }
        // if (!this.selectedDocIds.length && this.isNewEmail) {
        //     this.showToast('Please select at least one document.', 'error');
        //     return;
        // }
        sendEmails({
            leadEnquiryIds: this.selectedLeadIds,
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
        this.handlegetLeadEnquiriesClick();
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