import { LightningElement,api,track,wire } from 'lwc';
import fetchOppDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchOppDetails';
import fetchBrokerDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchBrokerDetails'
import getApiData from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.getApiData'
import { CurrentPageReference } from 'lightning/navigation';
import getQuoteDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchQuoteDetails'; // Apex method to fetch Quote details
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CANCELLATION_DETAILS_OBJECT from '@salesforce/schema/Case';
import fetchBookingDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchBookingDetails';
import fetchOppId from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchOppId'; 
import fetchCancellationDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchCancellationDetails'; 
import fetchRecDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchRecDetails';
import fetchBrokerageDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchBrokerageDetails'; 
//import getApplicantDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchApplicantDetails';
import getUserOptions from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.getUserOptions';
import cancellationRecStartWith from '@salesforce/label/c.Cancellation_RecordId';
import checkCancellationFetchedDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.checkCancellationFetchedDetails'; // Apex method to fetch REC details
//import fetchOpportunityDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchOpportunityDetails'; // Apex method to fetch Opportunity details
//import fetchCancellationDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.fetchCancellationDetails'; // Apex method to fetch data
import saveCancellationDetails from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.saveCancellationDetails'; // Apex method to save data
import { NavigationMixin } from 'lightning/navigation';
import Longitude from '@salesforce/schema/Asset.Longitude';

//import { loadScript } from 'lightning/platformResourceLoader';
//import html2canvasLib from '@salesforce/resourceUrl/html2canvas';
//import uploadFile from '@salesforce/apex/EYI_SAP_CaseCancellationPayController.uploadFile';
import html2canvas from '@salesforce/resourceUrl/html2canvas';
import jsPDF from '@salesforce/resourceUrl/jspdf';

import { loadScript } from 'lightning/platformResourceLoader';


export default class EYI_SAP_CancellationPaymentDetails3 extends NavigationMixin(LightningElement) {
    @api recordId;
    @track cancellationId;
    @track recordTypeId;
    @track customerNumber;
    @track companyCode;
    @track showData = false;
    @track showError = false;
    @track apiData = {};
    @track debitChargeCust;
    @track creditChargeCust;
    @track CREDIT_CTC = 0;
    @track DEBIT_CTC = 0;
    @track Demand_CTC = 0;
    @track interestWaiver = 0;
    @track totalInterestCharged = 0;
    @track totaBrokerageCharged = 0;
    @track brokerageWaiver = 0;
    @track forfeitedAmount = '';
    @track otherAdjustment ='';
    @track showOtherAdjustmentValue = false;
    @track showForfeitedAmount = false;
    @track totalReceivedAmount = 0;
    @track totalAmountCharged =0;
    @track amountToCustofAdjustment =0;
    @track totalRefundtoCustomer =0;
    @track reversalToCustomer;
    @track otherAdjustmentRefund = 0;
    @track amountForfeitedRefund = 0; 
    @track DEMAND_P;
    @track DEMAND_P_R;
    @track DEMAND_T;
    @track DEMAND_T_R;
    @track DEBIT_P;
    @track CREDIT_P;
    @track DEBIT_T;
    @track CREDIT_T;
    @track DEBIT_P_R;
    @track CREDIT_P_R;
    @track DEBIT_T_R;
    @track CREDIT_T_R;
    @track INTEREST_C;
    @track BROKERAGE;
    @track retainedUser;
    @track PAID_P;
    @track REFUND_P = 0;
    @track userOptions = [];
    @track isCancellationSubmit = false;
    @track showREC = false;
    @track dateOfCancellationRequested;
// as 
// Add these new tracked properties at the beginning of the class
    @track cancellationType;
    @track cancellationSubtype;
    @track cancellationReason;
   // @track cancellationStatus;
    //@track cancellationCommencement;
    //@track registrationStatus;
    @track cancellationRemarks;
    @track financeRemarks;
    @track dateOfCancellationInitiated;
    @track agreementValue;
    @track totalCost;
    @track salesOrderNumber;
    @track stampDuty;
    @track recName;
    @track reraNumber;
    @track recCode;
    @track brokrageTotalAmount;
    @track retentionEnablers;
    @track retentionRemarks;
    @track retainedByUser;
    @track retentionDate;
    @track approvalRetentionHierarchy;
    @track approvalCancellationHierarchy;
    @track sourcingManager;
    @track closingManager;
    @track relationshipManager;
    @track bookingSource;
    //@track bankName;
    //@track otherBankName;
    @track cheque;
    //@track instumentDetails;
    //@track ifscCode;
   // @track applicant;
    //@track accountNumber;
    @track showSaveButton = false; 
    //@track branchName;
    //@track beneficiaryName;
    //@track checkNumber;
    @track stageName;
    @track modeofFund;
    //Add these picklist options arrays
    @track cancellationTypeOptions = [];
    @track cancellationSubtypeOptions = [];
    @track cancellationReasonOptions = [];
    //@track cancellationStatusOptions = [];
    //@track cancellationCommencementOptions = [];
    //@track registrationStatusOptions = [];
    @track retentionEnablersOptions = [];
    //@track bankNameOption = [];
    @track showSearchBtn = false;
    //@track showOtherBank = false;
    @track isShowSpinner = false;
    @track LIFNR;
    @track SAP_PONumber;
    @track DOWNPAYMENT_P;
    @track DOWNPAYMENT_P_R;
    @track DOWNPAYMENT_T;
    @track DOWNPAYMENT_T_R;
    @track DOWNPAYMENT_CTC;
    @track tdsAmount = 0;
    @track otherAdjustmentRemark;
    @track forfeitedRemark;
    @track interestChargedRemark;
    @track brokerageChargedRemarks;
    @track customerName;
    @track  quoteUrl;
    @track isValid = false;
    @track isDataLoaded = false;
    //html2canvasInitialized = false;
//    @track cancellationFields = []; // Fields for Cancellation Details
//     @track paymentFields = []; // Fields for Payment Information
//     @track brokrageFields = []; // Fields for Brokrage Details
//     @track retentionFields = []; // Fields for Retention Information
//     @track sourceFields = []; // Fields for Source Details
//     @track refundFields = []; // Fields for Refund Bank Details

//Add these new handler methods
   

    picklistOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    connectedCallback(){
        console.log('ConnectedCallback Opp recordId : '+this.recordId);  
    //     getUserOptions().then(result => {
    //     this.userOptions = result;
    // });
    }
    /*renderedCallback() {
        if (this.html2canvasInitialized) {
            return;
        }
        this.html2canvasInitialized = true;

        loadScript(this, html2canvasLib)
            .then(() => {
                console.log('html2canvas loaded');
            })
            .catch(error => {
                console.error('Error loading html2canvas', error);
            });
    }
    
handlePrint() {
    console.log('Inside handlePrint');
    
    const element = this.template.querySelector('.print-area');
        window.html2canvas(element).then(canvas => {
            const imageData = canvas.toDataURL('image/png');
            this.uploadToCase(imageData);
        });
}

uploadToCase(imageData) {
    uploadFile({ base64Data: imageData, caseId: this.cancellationId })
        .then(() => {
            // Show success toast
            console.log('Page is Printed');
            
        })
        .catch(error => {
            console.log('Erro :: '+error);
            
            // Handle error
        });
}*/
html2canvasInitialized = false;
jsPdfInitialized = false;

renderedCallback() {
if (this.html2canvasInitialized && this.jsPdfInitialized) return;

Promise.all([
loadScript(this, html2canvas),
loadScript(this, jsPDF)
])

.then(() => {
this.html2canvasInitialized = true;
this.jsPdfInitialized = true;
})

.catch(error => {
console.error('Failed to load libraries', error);
});
}

handleGeneratePdf() {
    console.log('236');  
const content = this.template.querySelector('#pdf-content');
console.log('238');
console.log('content '+content);

window.html2canvas(content).then(canvas => {
    console.log('240'); 
const imgData = canvas.toDataURL('image/png');
console.log('242'); 
const pdf = new window.jspdf.jsPDF('p', 'mm', 'a4');
console.log('244'); 
const imgProps = pdf.getImageProperties(imgData);
console.log('246'); 
const pdfWidth = pdf.internal.pageSize.getWidth();
console.log('248'); 
const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight);
pdf.save('Invoice.pdf');
});
}


    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef && pageRef.state) {
            if(pageRef.state.c__recordId.startsWith('006')){
                console.log('inside opportunity of wire');
                this.recordId = pageRef.state.c__recordId;
                this.recordId = pageRef.state.recordId || pageRef.state.c__recordId;
                //this.fetchOpportunityDetails();
                // this.fetchQuoteDetails();
                // this.fetchBookingDetails();
                // this.fetchRecDetails();
                // this.fetchApplicantDetails();
                this.callCommonMethods();
                this.fetchCancellationPaymentDetails(this.recordId);
                
            }
            if(pageRef.state.c__recordId && pageRef.state.c__recordId.startsWith(cancellationRecStartWith)){
                
                console.log('inside Cancellation of wire');
                if(pageRef.state.c__recordId){
                    this.cancellationId = pageRef.state.c__recordId;
                    
                }
                if(pageRef.state.recordId){
                   this.cancellationId = pageRef.state.recordId;
                }
                
                //this.cancellationId = pageRef.state.recordId || pageRef.state.c__recordId;
                this.fetchCancellationPaymentDetails(this.cancellationId);
                this.fetchOpportunityId();
                //this.checkCancellationFetched();
                
            }
            console.log('Received recordId:', this.recordId);
            
        }

    }
    checkCancellationFetched(){
       checkCancellationFetchedDetails({ recordId: this.cancellationId })
                        .then(result => {
                            console.log('checkCancellationFetchedDetails result : '+result);
                            
                            if(result.EYI_IsCancellationFetched__c){
                                this.showSearchBtn = false;
                                this.showSaveButton = true;
                            }
                        }) 
                        .catch(error => {
                            console.error('Error in fetching fetchOpportunityId: ', error);
                        });
    }
    fetchOpportunityId(){
        fetchOppId({ recordId: this.cancellationId })
                        .then(result => {
                            console.log('fetchOppId result : '+result);
                            this.recordId = result;
                            console.log('this.recordId @@ '+this.recordId);
                            this.callCommonMethods();
                        })
                        .catch(error => {
                            console.error('Error in fetching fetchOpportunityId: ', error);
                        });

    }
    callCommonMethods(){
        this.fetchOpportunityDetails(); 
        this.getBrokerDetails();
        this.fetchQuoteDetails();
        this.fetchBookingDetails();
        this.fetchRecDetails();
       // this.fetchApplicantDetails();
        this.fetchBrokerageDetails();
    }
    fetchCancellationPaymentDetails(recordId){
        console.log('fetchCancellationPaymentDetails this.cancellationId : '+this.cancellationId);
        fetchCancellationDetails({ recordId:  recordId})
                        .then(result => {
                            if (result) {
                               // this.showData = true;
                            console.log('fetchCancellationDetails result : ' + JSON.stringify(result));
                            console.log('this.retainedByUser 201: '+result.EYI_Retained_By_User__c);
                            this.retainedByUser = result.EYI_Retained_By_User__c;
                            console.log('this.retainedByUser 203: '+this.retainedByUser);
                            this.tdsAmount = result.EYI_TDS_Amount__c;
                            console.log('this.tdsAmount : '+this.tdsAmount);
                            this.cancellationType=  result.EYI_Cancellation_Type__c;
                            this.cancellationSubtype = result.EYI_Sub_Type__c;
                            this.cancellationReason = result.EYI_Cancellation_Reason__c;
                           // this.cancellationStatus = result.EYI_Cancellation_Status__c;
                            //this.cancellationCommencement = result.EYI_Cancellation_Commencement__c;
                           // this.registrationStatus = result.EYI_Registration_Status__c;
                            this.cancellationRemarks = result.EYI_Cancellation_Remarks__c;
                            this.financeRemarks = result.EYI_Remark_For_Finance__c;
                            this.retentionEnablers = result.EYI_Retention_Enablers__c;
                            this.retentionRemarks = result.EYI_Retention_Remarks__c;
                            
                            this.retentionDate = result.EYI_Retention_Date__c;
                            this.isCancellationSubmit = result.IsCancellationSubmitted__c;
                            
                            //add below fields in quesry
                           // this.bankName = result.Bank_Name__c;
                           // this.instumentDetails = result.EYI_Instrument_Details__c;
                           // this.ifscCode = result.EYI_IFSC_Code__c;
                            //this.accountNumber = result.EYI_Account_No__c;
                           // this.checkNumber = result.EYI_Cheque__c;
                            this.totalReceivedAmount = result.EYI_Total_Received_Amount__c;
                            console.log('Assigned totalReceivedAmount:', this.totalReceivedAmount);
                            this.totalAmountCharged = result.EYI_TotalAmountCharged__c != null ? result.EYI_TotalAmountCharged__c : 0;
                            this.amountToCustofAdjustment = result.EYI_Amount_to_Cust_of_Other_Adjustment__c;
                            this.totalRefundtoCustomer = result.EYI_Total_Refund_Given__c;
                            this.DEMAND_P = result.EYI_Demanded_Amount_Principal__c;
                            this.DEMAND_P_R = result.EYI_Reversal_Demanded_Amount_Principal__c;
                            this.DEMAND_T = result.EYI_Demanded_Amount_Tax__c;
                            this.DEMAND_T_R = result.EYI_Reversal_Demanded_Amount_Tax__c;
                            this.Demand_CTC = result.EYI_Demand_Amount_Charged_to_Customer__c;
                            this.REFUND_P = result.EYI_Reversal_to_Customer__c;
                            this.PAID_P = result.EYI_Payment_Done__c;
                            this.DEBIT_P = result.EYI_Debit_Note_Principal__c;
                            this.CREDIT_P = result.EYI_Credit_Note_Principal__c;
                            this.DEBIT_T = result.EYI_Debit_Note_Tax__c;
                            this.CREDIT_T = result.EYI_Credit_Note_Tax__c;
                            this.DEBIT_P_R = result.EYI_Reversal_Debit_Note_Principal__c;
                            this.CREDIT_P_R = result.EYI_Reversal_Credit_Note_Principal__c;
                            this.DEBIT_T_R = result.EYI_Reversal_Debit_Note_Tax__c;
                            this.CREDIT_T_R = result.EYI_Reversal_Credit_Note_Tax__c;
                            this.DEBIT_CTC = result.EYI_Debit_Note_Charged_to_Customer__c ? result.EYI_Debit_Note_Charged_to_Customer__c : 0;
                            this.CREDIT_CTC = result.EYI_Credit_Note_Charged_to_Customer__c ? result.EYI_Credit_Note_Charged_to_Customer__c : 0; 
                            this.DOWNPAYMENT_P = result.EYI_Down_Payment_Amount_Principal__c;
                            this.DOWNPAYMENT_T = result.EYI_Down_Payment_Amount_Tax__c;
                            this.DOWNPAYMENT_P_R = result.EYI_Reversal_Down_Payment_Amt_Principal__c;
                            this.DOWNPAYMENT_T_R = result.EYI_Reversal_Down_Payment_Amt_Tax__c;
                            console.log('result.EYI_Down_Payment_Amt_Charged_To_Customer__c : '+result.EYI_Down_Payment_Amt_Charged_To_Customer__c);
                            this.DOWNPAYMENT_CTC = result.EYI_Down_Payment_Amt_Charged_To_Customer__c ? result.EYI_Down_Payment_Amt_Charged_To_Customer__c : 0;
                            console.log('this.DOWNPAYMENT_CTC : '+this.DOWNPAYMENT_CTC );
                            console.log('####');
                            
                            this.INTEREST_C = result.EYI_Total_Interest_Accured__c != null ? result.EYI_Total_Interest_Accured__c : 0;
                            this.interestWaiver = result.EYI_Interest_Waiver__c != null ? result.EYI_Interest_Waiver__c : 0;
                            this.totalInterestCharged = result.EYI_Total_Interest_Charged__c;
                            this.BROKERAGE = result.EYI_Brokerage_Amount__c;
                            this.brokerageWaiver = result.EYI_Brokerage_Waiver__c != null ? result.EYI_Brokerage_Waiver__c : 0;
                            this.totaBrokerageCharged =result.EYI_Total_Brokerage_Charged__c != null ? result.EYI_Total_Brokerage_Charged__c : 0;
                            this.otherAdjustment = result.EYI_Other_Adjustments_Included__c;
                            this.otherAdjustmentRefund = result.EYI_Other_Adjustments__c;
                            this.forfeitedAmount = result.EYI_Amount_be_Forfeited__c;
                            this.amountForfeitedRefund = result.EYI_Forfeit_Amount__c; 
                            
                            this.otherAdjustmentRemark = result.EYI_Adjustment_Remarks__c;
                            this.forfeitedRemark = result.EYI_Forfeiture_Remarks__c;
                            this.interestChargedRemark = result.EYI_Interest_Charged_Remarks__c;
                            this.brokerageChargedRemarks = result.EYI_Brokerage_Charged_Remarks__c;
                            //this.branchName = result.EYI_Branch_Name__c;
                            this.dateOfCancellationRequested = result.EYI_Cancellation_Request_Date__c;
                            //this.beneficiaryName = result.EYI_Beneficiary_Name__c;
                            // Mrinal Tripathi (EYI) change starts
                            this.companyCode = result.EYI_Opportunity__r != null && result.EYI_Opportunity__r.EYI_Project_Enquired__r != null ? result.EYI_Opportunity__r.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c : null;
                            this.customerNumber = result.EYI_Opportunity__r != null ? result.EYI_Opportunity__r.EYI_SAP_Customer_Number__c : null;
                            console.log('########');
                            // Mrinal Tripathi (EYI) change ends
                            if(this.otherAdjustment == 'Yes'){
                                this.showOtherAdjustmentValue = true;
                            } 
                            if(this.forfeitedAmount == 'Yes'){
                                this.showForfeitedAmount = true;
                            }
                            // if(this.bankName == 'Other'){
                            //     this.showOtherBank = true;
                            //     this.otherBankName = result.EYI_Bank_Name__c;
                            // }
                            console.log('this.EYI_IsCancellationFetched__c : '+result.EYI_IsCancellationFetched__c);
                            this.cancellationId = result.Id;
                            console.log('this.cancellationId ** : '+this.cancellationId);
                            console.log('result.EYI_Date_of_Cancellation_initiated__c :: '+result.EYI_Date_of_Cancellation_initiated__c);
                            
                            
                            if(this.cancellationId != null && result.EYI_Date_of_Cancellation_initiated__c != null){ 
                                this.dateOfCancellationInitiated = result.EYI_Date_of_Cancellation_initiated__c;
                            }else{
                                console.log('inside else to set todays date ');
                                
                                const today = new Date();
                                const yyyy = today.getFullYear();
                                const mm = String(today.getMonth() + 1).padStart(2, '0'); // Month is 0-based
                                const dd = String(today.getDate()).padStart(2, '0');
                                console.log('today '+today);
                                
                                this.dateOfCancellationInitiated = `${yyyy}-${mm}-${dd}`;
                                console.log('this.dateOfCancellationInitiated : '+this.dateOfCancellationInitiated);
                                
                            }
                            if(this.cancellationId == null && result.EYI_IsCancellationFetched__c == true){
                                console.log('Inside EYI_IsCancellationFetched__c true');
                                
                               // this.cancellationId = result.Id;
                                this.showSearchBtn = false;
                                this.showSaveButton = true;
                                this.showData = true;
                            }else if(this.cancellationId != null && result.EYI_IsCancellationFetched__c == true){
                                this.showSearchBtn = false;
                                this.showSaveButton = true;
                                this.showData = true;
                            }else{
                                 console.log('Inside else EYI_IsCancellationFetched__c true');
                                this.showSearchBtn = true;
                                this.showSaveButton = false;
                            }
                            
                            this.totalReceivedAmount = this.formattedTotalRefund(this.totalReceivedAmount);
                            this.totalAmountCharged = this.formattedTotalRefund(this.totalAmountCharged);
                            this.amountToCustofAdjustment = this.formattedTotalRefund(this.amountToCustofAdjustment);
                            this.totalRefundtoCustomer = this.formattedTotalRefund(this.totalRefundtoCustomer);
                            this.updateSubType();
                                // You can display details in the template
                            } else {
                                this.updateSubType();
                                const today = new Date();
                                const yyyy = today.getFullYear();
                                const mm = String(today.getMonth() + 1).padStart(2, '0'); // Month is 0-based
                                const dd = String(today.getDate()).padStart(2, '0');
                                console.log('today '+today);
                                
                                this.dateOfCancellationInitiated = `${yyyy}-${mm}-${dd}`;
                                console.log('this.dateOfCancellationInitiated : '+this.dateOfCancellationInitiated);
                                // No cancellation case found
                                this.showSearchBtn = true;
                                this.showSaveButton = false;
                                this.showToast('Info', 'No cancellation details found for this record.', 'info');
                            }
                            if(this.isCancellationSubmit){
                                this.isDataLoaded = true;
                                this.showSaveButton = false;
                            }
                         console.log('this.cancellationId : '+this.cancellationId);   
                            
                            
                        })
                        .catch(error => {
                            console.error('Error in fetching Cancellation Details: ', JSON.stringify(error) );
                            console.error('Error message:', error.message);
                            console.error('Stack trace:', error.stack);
                        });
                        
    }

    updateSubType(){
        console.log('this.cancellationSubtype :: '+this.cancellationSubtype+' this.stageName :  '+this.stageName);
        
        if(this.cancellationSubtype == null || this.cancellationSubtype =='' || this.cancellationSubtype== undefined){
            if(this.stageName){
                console.log('inside if ');
                
                if(this.stageName == 'Walk-in' || this.stageName == 'Booking' || this.stageName == 'Block'){
                    this.cancellationSubtype = 'Pre Onboarding';
                    console.log('this.cancellationSubtype '+this.cancellationSubtype);   
                }else if(this.stageName == 'Booked' || this.stageName == 'Booking Form Submitted' || this.stageName == 'Welcome Call Submitted' || this.stageName == 'Sold' || this.stageName == 'SD'){
                    this.cancellationSubtype = 'Post Onboarding and Pre Registration';
                    console.log('this.cancellationSubtype '+this.cancellationSubtype);
                }else if(this.stageName == 'Registration Completed' && this.modeofFund == 'Self'){
                    this.cancellationSubtype = 'Post-registration (by self-funded)';
                    console.log('this.cancellationSubtype '+this.cancellationSubtype);
                }else if(this.stageName == 'Registration Completed' && this.modeofFund == 'Bank'){
                    this.cancellationSubtype = 'Post-registration (by bank-funded)';
                    console.log('this.cancellationSubtype '+this.cancellationSubtype);
                }
            }
        }
    }
    isValidCurrency(value) {
        return (typeof value === 'number' && !isNaN(value)) ? value : 0;
    }

    fetchOpportunityDetails(){
        fetchOppDetails({ recordId: this.recordId })
                        .then(result => {
                            console.log('fetchOppDetails result : '+JSON.stringify(result));
                            this.customerNumber = result.EYI_SAP_Customer_Number__c;
                            this.customerName = result.Name;
                            this.bookingSource = result.EYI_Walk_in_Source__c;
                            this.stageName = result.StageName;
                            this.modeofFund = result.EYI_Mode_of_Funding__c;
                            if(this.bookingSource == 'PREC'){
                                this.showREC = true;
                            }
                            this.companyCode = result.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
                            this.LIFNR = result.EYI_REC__r ? result.EYI_REC__r.EYI_REC_Vendor_Code__c : null;
                            this.relationshipManager = result.EYI_Relationship_Manager__r ? result.EYI_Relationship_Manager__r.Name : '';
                            this.closingManager = result.EYI_Primary_Closing_Manager__r ? result.EYI_Primary_Closing_Manager__r.Name : '';
                            this.sourcingManager = result.EYI_Sourcing_Manager__r ? result.EYI_Sourcing_Manager__r.Name : '';

                        })
                        .catch(error => {
                            console.error('Error in fetching Opportunity Details: ', error);
                        });
                    
    }
    getBrokerDetails(){
        fetchBrokerDetails({ recordId: this.recordId })
                        .then(result => {
                            console.log('fetchBrokerDetails result : '+JSON.stringify(result));
                            this.SAP_PONumber = result.EYI_SAP_PO_Number__c;
                        })
                        .catch(error => {
                            console.error('Error in fetching fetchBrokerDetails Details: ', error);
                        });
    }

    handleSearch(){
        console.log('Inside handleSearch');
        if (!this.companyCode && !this.customerNumber) {
            this.showToast('Missing Fields', 'Customer Number and Company Code are required.', 'error');
            return;
        }
        if (!this.companyCode) {
            this.showToast('Missing Field', 'Company Code is required.', 'error');
            return;
        }
        if (!this.customerNumber) {
            this.showToast('Missing Field', 'Customer Number is required.', 'error');
            return;
        }
        // const requestPayload = {
        //     CompanyCode: this.companyCode,
        //     CustomerNo: this.customerNumber
        // };
        const requestPayload = {
            FetchCancellationPaymentDetails: {
                CompanyCode: this.companyCode ? this.companyCode : '',
                CustomerNo: this.customerNumber ? this.customerNumber : '',
                LIFNR: this.LIFNR ? this.LIFNR : '',
                EBELN: this.SAP_PONumber ? this.SAP_PONumber : ''
            }
        };
        console.log('Sending JSON to Apex:', JSON.stringify(requestPayload));
        try {
            getApiData({ filterString: JSON.stringify(requestPayload)})
    .then(result => {
        console.log('Raw API result:', result);
        const outer = JSON.parse(result);
        const parsedResult = outer["n0:ZSD_CUST_CANCEL_DET_TO_SFDCResponse"]?.EX_OUTPUT;

        console.log('parsedResult:', parsedResult);

        if (!parsedResult?.EX_MESSAGE) {
            this.apiData = parsedResult;
            this.DEMAND_P = parsedResult.DEMAND_P;
            this.DEMAND_P_R = parsedResult.DEMAND_P_R;
            this.DEMAND_T = parsedResult.DEMAND_T;
            this.DEMAND_T_R = parsedResult.DEMAND_T_R;
            this.DEBIT_P = parsedResult.DEBIT_P;
            this.CREDIT_P = parsedResult.CREDIT_P;
            this.DEBIT_T = parsedResult.DEBIT_T;
            this.CREDIT_T = parsedResult.CREDIT_T;
            this.DEBIT_P_R = parsedResult.DEBIT_P_R;
            this.CREDIT_P_R = parsedResult.CREDIT_P_R;
            this.DEBIT_T_R = parsedResult.DEBIT_T_R;
            this.CREDIT_T_R = parsedResult.CREDIT_T_R;
            this.INTEREST_C = parsedResult.INTEREST_C;
            this.BROKERAGE = parsedResult.BROKERAGE;
            this.REFUND_P = parsedResult.REFUND_P;
            this.PAID_P = parsedResult.PAID_P;
            this.DOWNPAYMENT_P = parsedResult.DOWNPAYMENT_P;
            this.DOWNPAYMENT_P_R = parsedResult.DOWNPAYMENT_P_R;
            this.DOWNPAYMENT_T = parsedResult.DOWNPAYMENT_T;
            this.DOWNPAYMENT_T_R = parsedResult.DOWNPAYMENT_T_R;
            this.DOWNPAYMENT_CTC = parsedResult.DOWNPAYMENT_CTC;
            this.showData = true;
            this.showError = false;
            //this.DEBIT_CTC = Number(parsedResult.DEBIT_T_R) + Number(parsedResult.DEBIT_P_R);
            this.DEBIT_CTC = parsedResult.DEBIT_CTC;
            // this.creditChargeCust = Number(parsedResult.CREDIT_P_R) + Number(parsedResult.CREDIT_T_R);
            this.CREDIT_CTC = parsedResult.CREDIT_CTC;
            //this.demandAmountCustCharge = Number(parsedResult.DEMAND_T) - Number(parsedResult.DEMAND_T_R);
            this.Demand_CTC  = parsedResult.DEMAND_CTC;
            this.tdsAmount = parsedResult.TDS;
            this.totalInterestCharged = Number(this.INTEREST_C) - Number(this.interestWaiver);
            this.totaBrokerageCharged = Number(this.BROKERAGE) - Number(this.brokerageWaiver);

            this.mainRowCalculation();
            this.showToast('Success', 'Data fetched Successfully', 'success');
        } else {
            this.showError = true;
            this.showData = false;
            this.showToast('Error', parsedResult.EX_MESSAGE, 'error');
        }
    })
    .catch(fetchError => {
        this.showToast('Error', 'Error fetching data', 'error');
        console.error('Error fetching data:', fetchError);
    });
            }
            catch (outerError) {
                this.showToast('Error', 'Unexpected error occurred', 'error');
                console.error('Outer Error:', outerError);
            }
            //as
            this.showSaveButton = true; 
           
    }

    mainRowCalculation(){
        this.totalReceivedAmount = 0;
        this.totalAmountCharged = 0
        this.amountToCustofAdjustment = 0;
        this.totalRefundtoCustomer = 0;
        
        this.totalReceivedAmount = parseFloat(this.REFUND_P) + parseFloat(this.DOWNPAYMENT_P) + parseFloat(this.DOWNPAYMENT_T);
    
        console.log('this.Demand_CTC : '+this.Demand_CTC);
        console.log('this.DEBIT_CTC : '+this.DEBIT_CTC);
        console.log('this.CREDIT_CTC : '+this.CREDIT_CTC);
        console.log('this.totalInterestCharged : '+this.totalInterestCharged);
        console.log('this.totaBrokerageCharged : '+this.totaBrokerageCharged);
        

        this.totalAmountCharged = parseFloat(this.Demand_CTC)+ parseFloat(this.DEBIT_CTC) + parseFloat(this.CREDIT_CTC) + parseFloat(this.totalInterestCharged) + parseFloat(this.totaBrokerageCharged) + parseFloat(this.DOWNPAYMENT_CTC);
        console.log('this.totalAmountCharged : '+this.totalAmountCharged);
        
        if(this.forfeitedAmount == 'Yes'){
            this.totalAmountCharged = this.totalAmountCharged + parseFloat(this.amountForfeitedRefund)
        }else{
            this.totalAmountCharged = this.totalAmountCharged + 0;
        }

        if(this.otherAdjustment == 'Yes'){
            this.amountToCustofAdjustment = parseFloat(this.otherAdjustmentRefund);
        }
        console.log('this.tdsAmount : '+this.tdsAmount);
        // this.totalReceivedAmount += (this.DOWNPAYMENT_P + this.DOWNPAYMENT_T);
        console.log('* parseFloat(this.totalReceivedAmount) '+parseFloat(this.totalReceivedAmount));
        console.log('* parseFloat(this.tdsAmount) '+parseFloat(this.tdsAmount));
        console.log('* parseFloat(this.totalAmountCharged) '+parseFloat(this.totalAmountCharged));
        console.log('* parseFloat(this.amountToCustofAdjustment) '+parseFloat(this.amountToCustofAdjustment));
        
        
        this.totalRefundtoCustomer = (parseFloat(this.totalReceivedAmount) + parseFloat(this.tdsAmount )) - parseFloat(this.totalAmountCharged)+ parseFloat(this.amountToCustofAdjustment);
        console.log('Before this.totalRefundtoCustomer : '+this.totalRefundtoCustomer);
        this.totalReceivedAmount = this.formattedTotalRefund(this.totalReceivedAmount);
        this.totalAmountCharged = this.formattedTotalRefund(this.totalAmountCharged);
        this.amountToCustofAdjustment = this.formattedTotalRefund(this.amountToCustofAdjustment);
        this.totalRefundtoCustomer = this.formattedTotalRefund(this.totalRefundtoCustomer);
        this.formattedTdsAmount = this.formattedTotalRefund(this.tdsAmount);
        console.log('this.totalReceivedAmount : '+this.totalReceivedAmount);
        console.log('this.totalAmountCharged : '+this.totalAmountCharged);
        console.log('this.amountToCustofAdjustment : '+this.amountToCustofAdjustment);
        console.log('After this.totalRefundtoCustomer : '+this.totalRefundtoCustomer);
        
    }

     formattedTotalRefund(inputCurrencyField) {
        if (inputCurrencyField != null) {
            const formattedValue = new Intl.NumberFormat('en-IN', {
                style: 'currency',
                currency: 'INR',
            }).format(inputCurrencyField);

            return formattedValue;
        }
        return '₹0'; // Default value if the value is null
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handleInterestWaiverChange(event){
        this.interestWaiver = event.target.value;
        this.totalInterestCharged = this.INTEREST_C - this.interestWaiver;
        this.mainRowCalculation();
    }

    handleBrokerageWaiverChange(event){
        this.brokerageWaiver = event.target.value;
        this.totaBrokerageCharged = this.BROKERAGE - this.brokerageWaiver;
        this.mainRowCalculation();
    }
    handleOtherAdjustmentRefund(event){
        this.otherAdjustmentRefund = event.target.value;
        this.mainRowCalculation();
    }
    handleAmountForfeitedRefund(event){
        this.amountForfeitedRefund = event.target.value;
        this.mainRowCalculation();
    }


    handleForfeitedAmountChange(event) {
        this.forfeitedAmount = event.detail.value;
        console.log('Selected:', this.forfeitedAmount);
        if(this.forfeitedAmount == 'Yes'){
            this.showForfeitedAmount = true;
        }else{
            this.showForfeitedAmount = false;
        }  
        this.mainRowCalculation();  
    }

    handleOtherAdjustment(event){
        this.otherAdjustment = event.detail.value;
        if(this.otherAdjustment == 'Yes'){
            this.showOtherAdjustmentValue = true;
        }else{
            this.showOtherAdjustmentValue = false;
        } 
        this.mainRowCalculation();
    }
//as

@wire(getObjectInfo, { objectApiName: CANCELLATION_DETAILS_OBJECT })
    wiredObjectInfo({ data, error }) {
        console.info("object info :: ", data);
        if (data) {
            const recordTypes = data.recordTypeInfos;
            for (const rtId in recordTypes) {
                if (recordTypes[rtId].name === 'Cancellation') {
                    this.recordTypeId = rtId;
                    console.log('Record Type "Cancellation" ID:', this.recordTypeId);
                    break;
                }
            }

            if (!this.recordTypeId) {
                console.log('Record type "Cancellation" not found.');
            }
        } else if (error) {
            console.log('Error loading object info:', error);
        }
    }

// Add this wire adapter after the existing wires
@wire(getPicklistValuesByRecordType, {
    objectApiName: CANCELLATION_DETAILS_OBJECT,
    recordTypeId: '$recordTypeId',
})
wiredCancellationPicklists({ data, error }) {
    console.info('picklist data :: ', data);
    if (data) {
        this.cancellationTypeOptions = data.picklistFieldValues.EYI_Cancellation_Type__c?.values || [];
        this.cancellationSubtypeOptions = data.picklistFieldValues.EYI_Sub_Type__c?.values || [];
        this.cancellationReasonOptions = data.picklistFieldValues.EYI_Cancellation_Reason__c?.values || [];
        //this.cancellationStatusOptions = data.picklistFieldValues.EYI_Cancellation_Status__c?.values || [];
        //this.cancellationCommencementOptions = data.picklistFieldValues.EYI_Cancellation_Commencement__c?.values || [];
        //this.registrationStatusOptions = data.picklistFieldValues.EYI_Registration_Status__c?.values || [];
        this.retentionEnablersOptions = data.picklistFieldValues.EYI_Retention_Enablers__c?.values || [];
       // this.bankNameOption = data.picklistFieldValues.Bank_Name__c?.values || [];
        console.log('this.cancellationSubtypeOptions :: '+this.cancellationSubtypeOptions);
        
    } else if (error) {
        console.error('Error loading cancellation picklists:', error);
    }
}

fetchQuoteDetails() {
        
        console.info('Fetching Quote details for recordId:', this.recordId);

        getQuoteDetails({ opportunityId: this.recordId })
            .then((result) => {
                if (result) {
                    this.agreementValue = result.EYI_Agreement_Value__c;
                    this.totalCost = result.EYI_Quoatation_Grand_Total__c;
                    this.stampDuty = result.Stamp_Duty__c;
                    if(result.Id){
                                this[NavigationMixin.GenerateUrl]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: result.Id,
                                        objectApiName: 'Quote',
                                        actionName: 'view'
                                    }
                                }).then(url => {
                                    this.quoteUrl = url;
                                });
                            }
                } else {
                   // this.showToast('Error', 'No Quotation data found for the given recordId ID: ' + this.recordId, 'error');
                   console.log('No Quotation data found for the given recordId ID: ');
                }
            })
            .catch((error) => {
                console.log('error : '+error);
                
            });
    }

     fetchBookingDetails() {
        fetchBookingDetails({ bookingId: this.recordId })
            .then((result) => {
                if (result) {
                    this.salesOrderNumber = result.EYI_SAP_Sales_Order_Number__c;
                    
                } else {
                    this.showToast('Error', 'No data found for the given bookingId', 'error');
                }
            })
            .catch((error) => {
                console.error('Error fetching Booking details:', error);
            });
    }
    /*fetchApplicantDetails() {
        console.log('Inside fetchApplicantDetails : '+this.recordId);
    getApplicantDetails({ opportunityId: this.recordId })
        .then(result => {
            console.log('fetchApplicantDetails result: '+result);
            if (result && result.Name) {
                console.log('Applicant Name: '+result.Name);
               this.applicant =  result.Name;
            } else {
                //this.applicant = '';
            }
        })
        .catch(error => {
            //this.applicant = null;
            console.log('error : '+error);
            
        });
}*/
        fetchBrokerageDetails() {
            fetchBrokerageDetails({ opportunityId: this.recordId }) //make this dynamic
                .then(result => {
                    if(result){
                        this.brokrageTotalAmount = result.EYI_Brokerage_Amount__c;
                    }else{
                        console.log('No Brokerage data found');
                    }
                })
                .catch(error => {
                    console.log('error : '+error);
                });
        }

        fetchRecDetails() {
            fetchRecDetails({ opportunityId: this.recordId })
                .then(result => {
                    if (result) {
                        console.log('fetchRecDetails result: '+JSON.stringify(result));
                        this.recName = result.Name;
                        this.reraNumber = result.EYI_RERA_Certificate_No__c;
                        this.recCode = result.EYI_REC_Vendor_Code__c;
                        console.log('this.recCode :'+this.recCode);
                    } else {
                        this.recName = null;
                        this.reraNumber = null;
                        this.recCode = null;  
                    }
                })
                .catch(error => {
                    this.recName = null;
                    this.reraNumber = null;
                    this.recCode = null;
                    console.log('error : '+error);    
                });
        }
        
        
  handleSave() {
    console.log('Inside handleSave', this.recordId);
    console.log('Inside handleSave this.RetentionDate', this.retentionDate);
    console.log('RetainedByUser '+this.retainedByUser);
        this.isShowSpinner = true;
        console.log('this.cancellationId: Before Save '+this.cancellationId);
        const fieldsToSave = {  
            Id:this.cancellationId,
            EYI_Opportunity__c: this.recordId,
            EYI_Cancellation_Type__c: this.cancellationType,
            Type:'Cancellation',
            EYI_Sub_Type__c: this.cancellationSubtype,
            EYI_Cancellation_Reason__c: this.cancellationReason,
            //EYI_Cancellation_Status__c: this.cancellationStatus,
            //EYI_Cancellation_Commencement__c: this.cancellationCommencement,
            //EYI_Registration_Status__c: this.registrationStatus,
            EYI_Cancellation_Remarks__c: this.cancellationRemarks,
            EYI_Remark_For_Finance__c: this.financeRemarks,
            EYI_Date_of_Cancellation_initiated__c: this.dateOfCancellationInitiated,
            EYI_Cancellation_Request_Date__c: this.dateOfCancellationRequested,
            // EYI_Retention_Enablers__c: this.retentionEnablers,
            // EYI_Retention_Remarks__c: this.retentionRemarks,
            // EYI_Retained_by_User__c: this.retainedByUser,
            // EYI_Retention_Date__c: this.retentionDate,
            IsCancellationSubmitted__c: this.isCancellationSubmit,
            //EYI_Bank_Name__c: this.otherBankName,
            //Bank_Name__c: this.bankName,
            //EYI_Instrument_Details__c:this.instumentDetails,
            //EYI_IFSC_Code__c:this.ifscCode,
            //EYI_Account_No__c:this.accountNumber,
           // EYI_Cheque__c:this.checkNumber,

            EYI_Total_Received_Amount__c: this.totalReceivedAmount,
            EYI_TotalAmountCharged__c: this.totalAmountCharged,
            EYI_Amount_to_Cust_of_Other_Adjustment__c:this.amountToCustofAdjustment,
            
            EYI_Total_Refund_Given__c: this.totalRefundtoCustomer,
            EYI_Demanded_Amount_Principal__c: this.DEMAND_P,
            EYI_Reversal_Demanded_Amount_Principal__c: this.DEMAND_P_R,
            EYI_Demanded_Amount_Tax__c: this.DEMAND_T,
            EYI_Reversal_Demanded_Amount_Tax__c: this.DEMAND_T_R,
            EYI_Demand_Amount_Charged_to_Customer__c:this.Demand_CTC,
            EYI_Reversal_to_Customer__c: this.REFUND_P,
            EYI_Payment_Done__c: this.PAID_P,
            EYI_Debit_Note_Principal__c: this.DEBIT_P,
            EYI_Credit_Note_Principal__c: this.CREDIT_P,
            EYI_Debit_Note_Tax__c: this.DEBIT_T,
            EYI_Credit_Note_Tax__c: this.CREDIT_T,
            EYI_Reversal_Debit_Note_Principal__c: this.DEBIT_P_R,
            EYI_Reversal_Credit_Note_Principal__c: this.CREDIT_P_R,
            EYI_Reversal_Debit_Note_Tax__c: this.DEBIT_T_R,  
            EYI_Reversal_Credit_Note_Tax__c: this.CREDIT_T_R,
            EYI_Debit_Note_Charged_to_Customer__c:this.DEBIT_CTC,
            EYI_Credit_Note_Charged_to_Customer__c:this.CREDIT_CTC,
            EYI_Total_Interest_Accured__c:this.INTEREST_C,
            EYI_Interest_Waiver__c:this.interestWaiver,
            EYI_Total_Interest_Charged__c:this.totalInterestCharged,
            EYI_Brokerage_Amount__c:this.BROKERAGE,
            EYI_Brokerage_Waiver__c:this.brokerageWaiver,
            EYI_Total_Brokerage_Charged__c:this.totaBrokerageCharged,
            EYI_Other_Adjustments_Included__c:this.otherAdjustment,
            EYI_Other_Adjustments__c:this.otherAdjustmentRefund,
            EYI_Amount_be_Forfeited__c:this.forfeitedAmount,
            EYI_Forfeit_Amount__c:this.amountForfeitedRefund,
            EYI_Down_Payment_Amount_Principal__c:this.DOWNPAYMENT_P,
            EYI_Down_Payment_Amount_Tax__c:this.DOWNPAYMENT_T,
            EYI_Reversal_Down_Payment_Amt_Principal__c:this.DOWNPAYMENT_P_R,
            EYI_Reversal_Down_Payment_Amt_Tax__c:this.DOWNPAYMENT_T_R,
            EYI_Down_Payment_Amt_Charged_To_Customer__c:this.DOWNPAYMENT_CTC,
            EYI_TDS_Amount__c : this.tdsAmount,
            EYI_Adjustment_Remarks__c : this.otherAdjustmentRemark,
            EYI_Forfeiture_Remarks__c : this.forfeitedRemark,
            EYI_Interest_Charged_Remarks__c : this.interestChargedRemark,
            EYI_Brokerage_Charged_Remarks__c : this.brokerageChargedRemarks
            //EYI_Branch_Name__c: this.branchName,
            //EYI_Beneficiary_Name__c: this.beneficiaryName
        };
        console.log('Data to save:', JSON.stringify(fieldsToSave));
        const textarea = this.template.querySelector('[data-id="cancellationRemarks"]');
        const value = this.cancellationRemarks ? this.cancellationRemarks.trim() : '';
        textarea.setCustomValidity('');
        if (!value || value.length < 40) {
            textarea.setCustomValidity('Cancellation Remarks must be at least 40 characters.');
            textarea.reportValidity();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please enter at least 40 characters in Cancellation Remarks.',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }
        if(this.brokerageWaiver > this.BROKERAGE){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Brokerage Waiver should not be greater than Total Brokerage Paid',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }
        if(this.interestWaiver > this.INTEREST_C){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Interest Waiver should not be greater than Total Interest Accrued',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }
        if(this.brokerageWaiver > 0 && this.brokerageChargedRemarks == null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please add Remarks for Brokerage Waiver',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }
        
        if(this.interestWaiver > 0 && this.interestChargedRemark == null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please add Remarks for Interest Waiver',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }

        if(this.otherAdjustment == 'Yes' && this.otherAdjustmentRefund <= 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Other Adjustment amount should be grater than zero',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }
        if(this.forfeitedAmount == 'Yes' && this.amountForfeitedRefund <= 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Forfeited Amount should be greater than zero',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }

        if(this.otherAdjustment == 'Yes' && this.otherAdjustmentRefund > 0 && this.otherAdjustmentRemark == null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please add Remarks for Other Adjustment',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }
        if(this.forfeitedAmount == 'Yes' && this.amountForfeitedRefund > 0 && this.forfeitedRemark == null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please add Remarks for Forfeited Adjustment',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            this.isShowSpinner = false;
            return;
        }

        // if(this.bankName =='Other' && !this.otherBankName){
        //     this.isShowSpinner = false;
        //     this.showToast('Error', 'Please Enter Bank Name', 'error');
        // }else{
            this.showSaveButton = false;
            saveCancellationDetails({ data: fieldsToSave })
            .then(result => {
                this.isShowSpinner = false;
                console.log('Save result:', result);
                this.showToast('Success', 'Data saved successfully.', 'success');
                
                this.cancellationId = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Data saved successfully.',
                        variant: 'success'
                    })
                );
                this.handleCancel();
            })
            .catch((error) => {
                this.isShowSpinner = false;
                this.showSaveButton = true;
                console.error('Error saving data:', error);
                this.showToast('Error', error.body.message || 'Failed to save data.', 'error');
            });
        //}
        
    }
 parseDecimal(input) {
  if (!input || typeof input !== 'string') return null;

  // Remove everything except digits, dot, and minus sign
  const cleaned = input.replace(/[^0-9.-]/g, '');

  // Convert to number
  const number = parseFloat(cleaned);

  return isNaN(number) ? null : number;
}

    // Example handler for combobox change
    handleCancellationTypeChange(event) {
        this.cancellationType = event.target.value;
    }
    handleCancellationSubtypeChange(event) {
        this.cancellationSubtype = event.target.value;
    }

    handleCancellationReasonChange(event) {
        this.cancellationReason = event.target.value;
    }

    handleCancellationRemarksChange(event) {
        this.cancellationRemarks = event.target.value;
    }

    handleFinanceRemarksChange(event) {
        this.financeRemarks = event.target.value;
    }

    handleDateOfCancellationInitiatedChange(event) {
        this.dateOfCancellationInitiated = event.target.value;
    }
     handleDateOfCancellationRequested(event) {
        this.dateOfCancellationRequested = event.target.value;
    }

    handleRetentionEnablers(event) {
        this.retentionEnablers = event.target.value;
    }

    handleRetentionRemarks(event) {
        this.retentionRemarks = event.target.value;
    }
    handleRetainedByUserMethod(event) {
        this.retainedByUser = event.target.value;
        console.log('this.retainedByUser :: '+this.retainedByUser);
    }

    handleRetainedByUser(event) {
        //this.retainedByUser = event.target.value;

        console.log('retainedByUser event.target.value : ' + event.detail);
        this.retainedByUser = event.detail.recordId;
        console.log('this.retainedByUser : '+this.retainedByUser);
    }

    handleRetentionDate(event) {
        this.retentionDate = event.target.value; 
    }

    handleApprovalRetentionHierarchy(event) {
        this.approvalRetentionHierarchy = event.target.value;
    }

    handleApprovalCancellationHierarchy(event) {
        this.approvalCancellationHierarchy = event.target.value;
    }
    // handlebeneficiaryName(event){
    //     this.beneficiaryName = event.target.value;
    // }

    // handleBankName(event) {
    //     this.bankName = event.target.value;
    //     if(this.bankName == 'Other'){
    //         this.showOtherBank = true;
    //     }else{
    //         this.showOtherBank = false;
    //         this.otherBankName = ''; 
    //     }
    // }
    // handleOtherBankName(event){
    //     this.otherBankName = event.target.value;
    // }

    // handleCheque(event) {
    //     this.checkNumber = event.target.value;
    // }

    // handleIfscDetails(event) {
    //     this.ifscCode = event.target.value;
    // }

    // handleBranchName(event) {
    //     this.branchName = event.target.value;
    // }
    // beneficiaryName(event) {
    //     this.beneficiaryName = event.target.value;
    // }
    // handleaccountNumber(event) {
    //     this.accountNumber = event.target.value;
    // }

    handleCancellationSubmit(event){
        this.isCancellationSubmit = event.target.checked;
    }  
    handleotherAdjustmentRemark(event){
        this.otherAdjustmentRemark = event.target.value;
    }
    handleotherForfeitedRemark(event){
        this.forfeitedRemark = event.target.value;
    }
    handleInterestChargedRemark(event){
        this.interestChargedRemark = event.target.value;
    }
    handleBrokerageChargedRemarks(event){
        this.brokerageChargedRemarks = event.target.value;
    }
    handleCancel(){
        console.log('handleCancel this.cancellationId : '+this.cancellationId);
        
        if (this.cancellationId) {
            console.log('this.cancellationId @@ :  '+this.cancellationId);
            
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.cancellationId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
        }else{
            this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
        }
    }
}