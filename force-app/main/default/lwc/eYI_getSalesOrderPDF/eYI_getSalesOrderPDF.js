import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import Account_ID from '@salesforce/schema/User.AccountId';
import getAccounts from '@salesforce/apex/EYI_GenerateBillingPDFController.getBooking';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import downloadPDF from '@salesforce/apex/EYI_GenerateBillingPDFController.getGeneratingFile';

export default class GetSalesOrderPDF extends LightningElement {
    userId = USER_ID;
    accid;
    @api recordId;
    @api isLoadedpdf = false;
    @api isSOA = false;
    @api isInterestLetter = false;
    @api indicator;
    @track accountList;
    @track singleaccountList;
    jsonString = '';
    @track columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Status', fieldName: 'EYI_Booking_Form_Status__c'},
        { label : 'Action',  type : 'button', typeAttributes:{ 
                                                            label: 'Get SOA PDF',
                                                            name: 'Get SOA PDF',
                                                            title: 'Get SOA PDF',
                                                            disabled: false,
                                                            value: 'Get SOA PDF',
                                                            iconPosition: 'left',
                                                            variant:'Brand'}}
    ];
    @track interestColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Status', fieldName: 'EYI_Booking_Form_Status__c'},
        { label : 'Action',  type : 'button', typeAttributes:{ 
                                                            label: 'Get Interest Letter PDF',
                                                            name: 'Get Interest Letter PDF',
                                                            title: 'Get Interest Letter PDF',
                                                            disabled: false,
                                                            value: 'Get Interest Letter PDF',
                                                            iconPosition: 'left',
                                                            variant:'Brand'}}
    ];

    @wire(getAccounts, { Accountid: '$accid' }) wiredAccounts({ data, error }) {
        if (data) {
            console.log('in get Account')
            if(this.indicator == 'SOA'){
                this.isSOA = true;
            }else if(this.indicator == 'INTEREST'){
                this.isInterestLetter = true;
            }
            if (this.recordId != undefined) {
                this.getDemands(data[0]);
            } else {
                this.accountList = data;
                console.log('this.accountList---->' + JSON.stringify(this.accountList));
            }
        } else if (error) {
            console.log(error);
        }
    }
    getDemands(data) {
        if(this.indicator == 'SOA'){
            this.singleaccountList = data.EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c;
        }
        else if(this.indicator == 'INTEREST'){
            this.singleaccountList = data.EYI_Opportunity_Name__r.EYI_SalesOrder_Number__c;
        }
    }
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [Account_ID]
    }) wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log(data);
            //   alert('this.data');

            console.log(data.fields.AccountId.value);
            if (this.recordId == null || this.recordId == undefined) {
                this.accid = data.fields.AccountId.value;
            } else {
                this.accid = this.recordId;
            }
            // console.log(this.recordId);
        }
    }
    handleRowAction(event){
        this.isLoadedpdf = true;
        console.log('In this event');
        if(event.detail.row.EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c == undefined){
            const evt = new ShowToastEvent({
                title: 'Data Error',
                message: 'Customer Number Not Present',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else if(event.detail.row.EYI_Opportunity_Name__r.EYI_SalesOrder_Number__c == undefined){
            const evt = new ShowToastEvent({
                title: 'Data Error',
                message: 'Sales Order Number Not Present',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else {
            console.log('in else part of handlerowaction')
            var requestData = [];
            if(this.indicator == 'SOA'){
                requestData.push({
                    TYPE: this.indicator,
                    BILLDOC: event.detail.row.EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c
                })
            }else if(this.indicator == 'INTEREST'){
                requestData.push({
                    TYPE: this.indicator,
                    BILLDOC: event.detail.row.EYI_Opportunity_Name__r.EYI_SalesOrder_Number__c
                })
            }
            console.log(JSON.stringify(requestData[0]));
            this.jsonString = JSON.stringify(requestData[0]);
            console.log('this.jsonString ' + this.jsonString);
            this.getPdf(this.jsonString);
        }
    }
    handleClick(event) {
        this.isLoadedpdf = true;
        if (this.singleaccountList == undefined) {
            const evt = new ShowToastEvent({
                title: 'Data Error',
                message: 'Customer Number or Sales Order Number Not Present',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            console.log('in else part of handleclick')
            var requestData = [];
            requestData.push({
                TYPE: this.indicator,
                BILLDOC: this.singleaccountList
            })
            console.log(JSON.stringify(requestData[0]));
            this.jsonString = JSON.stringify(requestData[0]);
            console.log('this.jsonString ' + this.jsonString);
            this.getPdf(this.jsonString);
        }
    }
    getPdf(data){
        downloadPDF({ requestJsonString: data,/*bookingId:this.idBooking*/ }).then(response => {
            console.log('response-->'+response);
            this.isLoadedpdf = false;
            if (response) {
                const byteCharacters = atob(response);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: 'application/pdf' });
                // Generate a URL for the blob
                const pdfURL = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = pdfURL;
                a.target = '_blank';
                a.rel = 'noopener noreferrer';
                a.click();
                //window.open(pdfURL);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Data Error',
                    message: 'No data from SAP',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        }).catch(error => {
            console.log('Error: ' + JSON.stringify(error));
            const evt = new ShowToastEvent({
                title: 'Data Error',
                message: 'Something Went wrong',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
    }
}