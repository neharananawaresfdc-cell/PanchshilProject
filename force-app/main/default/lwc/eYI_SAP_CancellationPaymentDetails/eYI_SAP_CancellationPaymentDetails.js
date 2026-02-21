import { LightningElement,api,track,wire } from 'lwc';
import fetchOppDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchOppDetails';
import getApiData from '@salesforce/apex/EYI_SAP_CancellationPaymentController.getApiData'
import { CurrentPageReference } from 'lightning/navigation';
import fetchQuoteDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchQuoteDetails'; // Apex method to fetch Quote details
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CANCELLATION_DETAILS_OBJECT from '@salesforce/schema/EYI_Cancellation_Detail__c';
import fetchBookingDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchBookingDetails';
import fetchOppId from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchOppId'; 
import fetchCancellationDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchCancellationDetails'; 
import fetchRecDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchRecDetails';
import fetchBrokerageDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchBrokerageDetails'; 
import fetchApplicantDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchApplicantDetails';
import getUserOptions from '@salesforce/apex/EYI_SAP_CancellationPaymentController.getUserOptions';
import cancellationRecStartWith from '@salesforce/label/c.Cancellation_RecordId';
//import fetchRECDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchRECDetails'; // Apex method to fetch REC details
//import fetchOpportunityDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchOpportunityDetails'; // Apex method to fetch Opportunity details
//import fetchCancellationDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.fetchCancellationDetails'; // Apex method to fetch data
import saveCancellationDetails from '@salesforce/apex/EYI_SAP_CancellationPaymentController.saveCancellationDetails'; // Apex method to save data

export default class EYI_SAP_CancellationPaymentDetails extends LightningElement {

    @api recordId;
    @track cancellationId;
    @track recordTypeId;
    @track customerNumber;
    @track companyCode;
    @track showData = false;
    @track showError = false;
    @track apiData = {};
    @track  debitChargeCust;
    @track creditChargeCust;
    @track demandAmountCustCharge = 0;
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
    @track reversalToCustomer = 1120000;
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
    @track userOptions = [];
       
// as 
// Add these new tracked properties at the beginning of the class
    @track cancellationType;
    @track cancellationSubtype;
    @track cancellationReason;
    @track cancellationStatus;
    @track cancellationCommencement;
    @track registrationStatus;
    @track cancellationRemarks;
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
    @track bankName;
    @track otherBankName;
    @track cheque;
    //@track instumentDetails;
    @track ifscCode;
    @track applicant;
    @track accountNumber;
    @track showSaveButton = false; 
    @track cancellationType;
    @track cancellationTypeOptions = []; 
    @track checkNumber;
    //Add these picklist options arrays
    @track cancellationTypeOptions = [];
    @track cancellationSubtypeOptions = [];
    @track cancellationReasonOptions = [];
    @track cancellationStatusOptions = [];
    @track cancellationCommencementOptions = [];
    @track registrationStatusOptions = [];
    @track retentionEnablersOptions = [];
    @track bankNameOption = [];
    @track showSearchBtn = true;
    @track showOtherBank = false;

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
        getUserOptions().then(result => {
        this.userOptions = result;
    });
    }
    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef && pageRef.state) {
            if(pageRef.state.c__recordId && pageRef.state.c__recordId.startsWith('006')){
                console.log('inside opportunity of wire');
                this.recordId = pageRef.state.c__recordId;
                this.recordId = pageRef.state.recordId || pageRef.state.c__recordId;
                // this.fetchOpportunityDetails();
                // this.fetchQuoteDetails();
                // this.fetchBookingDetails();
                // this.fetchRecDetails();
                // this.fetchApplicantDetails();
                this.fetchCancellationPaymentDetails(this.recordId);
                this.callCommonMethods();
            }
            if(pageRef.state.c__recordId && pageRef.state.c__recordId.startsWith(cancellationRecStartWith)){
                this.showSearchBtn = false;
                console.log('inside Cancellation of wire');
                this.cancellationId = pageRef.state.c__recordId;
                this.cancellationId = pageRef.state.recordId || pageRef.state.c__recordId;
                this.fetchCancellationPaymentDetails(this.cancellationId);
                this.fetchOpportunityId()
                
            }
            console.log('Received recordId:', this.recordId);
            
        }
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
        this.fetchQuoteDetails();
        this.fetchBookingDetails();
        this.fetchRecDetails();
        this.fetchApplicantDetails();
        this.fetchBrokerageDetails();
    }
    fetchCancellationPaymentDetails(recordId){
        console.log('fetchCancellationPaymentDetails this.cancellationId : '+this.cancellationId);
        fetchCancellationDetails({ recordId:  recordId})
                        .then(result => {
                            
                            this.showData = true;
                            console.log('fetchCancellationDetails result : ' + JSON.stringify(result));
                            this.cancellationType=  result.EYI_Cancellation_Type__c;
                            this.cancellationSubtype = result.EYI_Cancellation_Subtype__c;
                            this.cancellationReason = result.EYI_Cancellation_Reason__c;
                            this.cancellationStatus = result.EYI_Cancellation_Status__c;
                            this.cancellationCommencement = result.EYI_Cancellation_Commencement__c;
                            this.registrationStatus = result.EYI_Registration_Status__c;
                            this.cancellationRemarks = result.EYI_Cancellation_Remarks__c;
                            this.dateOfCancellationInitiated = result.EYI_Date_of_Cancellation_initiated__c;
                            this.retentionEnablers = result.EYI_Retention_Enablers__c;
                            this.retentionRemarks = result.EYI_Retention_Remarks__c;
                            this.retainedByUser = result.EYI_Retained_by_User__c;
                            this.retentionDate = result.EYI_Retention_Date__c;
                            //add below fields in quesry
                            this.bankName = result.Bank_Name__c;
                           // this.instumentDetails = result.EYI_Instrument_Details__c;
                            this.ifscCode = result.EYI_IFSC_Code__c;
                            this.accountNumber = result.EYI_Account_No__c;
                            this.checkNumber = result.EYI_Cheque__c;
                            this.totalReceivedAmount = result.EYI_Total_Received_Amount__c;
                            console.log('Assigned totalReceivedAmount:', this.totalReceivedAmount);
                            this.totalAmountCharged = result.EYI_TotalAmountCharged__c;
                            this.amountToCustofAdjustment = result.EYI_Amount_to_Cust_of_Other_Adjustment__c;
                            this.totalRefundtoCustomer = result.EYI_Total_Refund_Given__c;
                            this.DEMAND_P = result.EYI_Demanded_Amount_Principal__c;
                            this.DEMAND_P_R = result.EYI_Reversal_Demanded_Amount_Principal__c;
                            this.DEMAND_T = result.EYI_Demanded_Amount_Tax__c;
                            this.DEMAND_T_R = result.EYI_Reversal_Demanded_Amount_Tax__c;
                            this.demandAmountCustCharge = result.EYI_Demand_Amount_Charged_to_Customer__c;
                            this.reversalToCustomer = result.EYI_Reversal_to_Customer__c;
                            this.DEBIT_P = result.EYI_Debit_Note_Principal__c;
                            this.CREDIT_P = result.EYI_Credit_Note_Principal__c;
                            this.DEBIT_T = result.EYI_Debit_Note_Tax__c;
                            this.CREDIT_T = result.EYI_Credit_Note_Tax__c;
                            this.DEBIT_P_R = result.EYI_Reversal_Debit_Note_Principal__c;
                            this.CREDIT_P_R = result.EYI_Reversal_Credit_Note_Principal__c;
                            this.DEBIT_T_R = result.EYI_Reversal_Debit_Note_Tax__c;
                            this.CREDIT_T_R = result.EYI_Reversal_Credit_Note_Tax__c;
                            this.debitChargeCust = result.EYI_Debit_Note_Charged_to_Customer__c;
                            this.creditChargeCust = result.EYI_Credit_Note_Charged_to_Customer__c;
                            this.INTEREST_C = result.EYI_Total_Interest_Accured__c;
                            this.interestWaiver = result.EYI_Interest_Waiver__c;
                            this.totalInterestCharged = result.EYI_Total_Interest_Charged__c;
                            this.BROKERAGE = result.EYI_Brokerage_Amount__c;
                            this.brokerageWaiver = result.EYI_Brokerage_Waiver__c;
                            this.totaBrokerageCharged =result.EYI_Total_Brokerage_Charged__c;
                            this.otherAdjustment = result.EYI_Other_Adjustments_Included__c;
                            this.otherAdjustmentRefund = result.EYI_Other_Adjustments__c;
                            this.forfeitedAmount = result.EYI_Amount_be_Forfeited__c;
                            this.amountForfeitedRefund = result.EYI_Forfeit_Amount__c; 
                            if(this.otherAdjustment == 'Yes'){
                                this.showOtherAdjustmentValue = true;
                            } 
                            if(this.forfeitedAmount == 'Yes'){
                                this.showForfeitedAmount = true;
                            }
                            if(this.bankName == 'Other'){
                                this.showOtherBank = true;
                                this.otherBankName = result.EYI_Bank_Name__c;
                            }
                            if(this.cancellationId == null){

                                this.cancellationId = result.Id;
                                this.showSearchBtn = false;
                            }
                            this.showSaveButton = true;
                            this.totalReceivedAmount = this.formattedTotalRefund(this.totalReceivedAmount);
                            this.totalAmountCharged = this.formattedTotalRefund(this.totalAmountCharged);
                            this.amountToCustofAdjustment = this.formattedTotalRefund(this.amountToCustofAdjustment);
                            this.totalRefundtoCustomer = this.formattedTotalRefund(this.totalRefundtoCustomer);
                            
                        })
                        .catch(error => {
                            console.error('Error in fetching Cancellation Details: ',+error);
                            console.error('Error message:', error.message);
                            console.error('Stack trace:', error.stack);
                        });
    }
    isValidCurrency(value) {
        return (typeof value === 'number' && !isNaN(value)) ? value : 0;
    }

    fetchOpportunityDetails(){
        fetchOppDetails({ recordId: this.recordId })
                        .then(result => {
                            console.log('fetchOppDetails result : '+JSON.stringify(result));
                            this.customerNumber = result.EYI_SAP_Customer_Number__c;
                            this.companyCode = result.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c;
                            this.sourcingManager = result.EYI_Sourcing_Manager__r.Name;
                            this.relationshipManager = result.EYI_Relationship_Manager__r.Name;
                            this.closingManager = result.EYI_Primary_Closing_Manager__r.Name;  
                        })
                        .catch(error => {
                            console.error('Error in fetching Opportunity Details: ', error);
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
        const requestPayload = {
            CompanyCode: this.companyCode,
            CustomerNo: this.customerNumber
        };
        console.log('Sending JSON to Apex:', JSON.stringify(requestPayload));
        try {
            getApiData({ filterString: JSON.stringify(requestPayload)})
                .then(result => {
                    console.log('result :: '+result);
                    console.log(' Stringify result :: '+JSON.stringify(result));
                    //this.apiData = JSON.parse(result);
                    this.showToast('Success', 'Data fetched Successfully', 'success');
                    const parsedResult = JSON.parse(result);
                    this.apiData = parsedResult;
                    this.DEMAND_P = this.apiData.DEMAND_P;
                    this.DEMAND_P_R = this.apiData.DEMAND_P_R;
                    this.DEMAND_T = this.apiData.DEMAND_T;
                    this.DEMAND_T_R = this.apiData.DEMAND_T_R;
                    this.DEBIT_P = this.apiData.DEBIT_P;
                    this.CREDIT_P = this.apiData.CREDIT_P;
                    this.DEBIT_T = this.apiData.DEBIT_T;
                    this.CREDIT_T = this.apiData.CREDIT_T;
                    this.DEBIT_P_R = this.apiData.DEBIT_P_R;
                    this.CREDIT_P_R =this.apiData.CREDIT_P_R;
                    this.DEBIT_T_R = this.apiData.DEBIT_T_R;
                    this.CREDIT_T_R = this.apiData.CREDIT_T_R;
                    this.INTEREST_C = this.apiData.INTEREST_C;
                    this.BROKERAGE = this.apiData.BROKERAGE;
                    console.log('this.apiData : '+JSON.stringify(this.apiData));
                    
                    console.log(' parsedResult.EX_MESSAGE : '+ parsedResult.EX_MESSAGE);
                    if (!parsedResult.EX_MESSAGE) {
                        console.log('inside !parsedResult.EX_MESSAGE');
                       
                        this.showData = true;
                        this.showError = false;
                        this.debitChargeCust = parsedResult.DEBIT_T_R + parsedResult.DEBIT_P_R;
                        this.creditChargeCust = parsedResult.CREDIT_P_R + parsedResult.CREDIT_T_R;
                        this.demandAmountCustCharge=  parsedResult.DEMAND_T - parsedResult.DEMAND_T_R;
                        this.totalInterestCharged = this.INTEREST_C - this.interestWaiver;
                        this.totaBrokerageCharged = this.BROKERAGE - this.brokerageWaiver;
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

        this.totalReceivedAmount = this.reversalToCustomer;

        this.totalAmountCharged = this.demandAmountCustCharge + this.debitChargeCust + this.creditChargeCust + this.totalInterestCharged + this.totaBrokerageCharged;
        if(this.forfeitedAmount == 'Yes'){
            this.totalAmountCharged = this.totalAmountCharged + parseFloat(this.amountForfeitedRefund)
        }else{
            this.totalAmountCharged = this.totalAmountCharged + 0;
        }

        if(this.otherAdjustment == 'Yes'){
            this.amountToCustofAdjustment = this.otherAdjustmentRefund;
        }else{
            this.amountToCustofAdjustment =  0;
        }

        this.totalRefundtoCustomer = (this.totalReceivedAmount - this.totalAmountCharged) + parseFloat(this.amountToCustofAdjustment);
        
        this.totalReceivedAmount = this.formattedTotalRefund(this.totalReceivedAmount);
        this.totalAmountCharged = this.formattedTotalRefund(this.totalAmountCharged);
        this.amountToCustofAdjustment = this.formattedTotalRefund(this.amountToCustofAdjustment);
        this.totalRefundtoCustomer = this.formattedTotalRefund(this.totalRefundtoCustomer);
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
            // Use default record type or handle orgs without record types
            this.recordTypeId = data.defaultRecordTypeId || '';
            console.log('Master Record Type ID:', this.recordTypeId);
        } else if (error) {
            console.error('Error loading object info:', error);
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
        this.cancellationSubtypeOptions = data.picklistFieldValues.EYI_Cancellation_Subtype__c?.values || [];
        this.cancellationReasonOptions = data.picklistFieldValues.EYI_Cancellation_Reason__c?.values || [];
        this.cancellationStatusOptions = data.picklistFieldValues.EYI_Cancellation_Status__c?.values || [];
        this.cancellationCommencementOptions = data.picklistFieldValues.EYI_Cancellation_Commencement__c?.values || [];
        this.registrationStatusOptions = data.picklistFieldValues.EYI_Registration_Status__c?.values || [];
        this.retentionEnablersOptions = data.picklistFieldValues.EYI_Retention_Enablers__c?.values || [];
        this.bankNameOption = data.picklistFieldValues.Bank_Name__c?.values || [];
    } else if (error) {
        console.error('Error loading cancellation picklists:', error);
    }
}

fetchQuoteDetails() {
        
        console.info('Fetching Quote details for recordId:', this.recordId);

        fetchQuoteDetails({ opportunityId: this.recordId })
            .then((result) => {
                if (result) {
                    this.agreementValue = result.EYI_Agreement_Value__c;
                    this.totalCost = result.TotalPrice;
                    this.stampDuty = result.Stamp_Duty__c;
                } else {
                    this.showToast('Error', 'No data found for the given recordId ID: ' + this.recordId, 'error');
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
                    this.bookingSource = result.EYI_Source_of_Booking__c;
                } else {
                    this.showToast('Error', 'No data found for the given bookingId', 'error');
                }
            })
            .catch((error) => {
                console.error('Error fetching Booking details:', error);
            });
    }
    fetchApplicantDetails() {
        console.log('Inside fetchApplicantDetails : '+this.recordId);
    fetchApplicantDetails({ opportunityId: this.recordId })
        .then(result => {
            console.log('fetchApplicantDetails result: '+result);
            if (result && result.Name) {
               this.applicant =  result.Name;
            } else {
                this.applicant = '';
            }
        })
        .catch(error => {
            this.applicant = null;
            console.log('error : '+error);
            
        });
}
        fetchBrokerageDetails() {
            fetchBrokerageDetails({ opportunityId: this.recordId })
                .then(result => {
                    this.brokrageTotalAmount = result.EYI_Brokerage_Amount__c;
                })
                .catch(error => {
                    console.log('error : '+error);
                });
        }

        fetchRecDetails() {
            fetchRecDetails({ opportunityId: this.recordId })
                .then(result => {
                    if (result) {
                        this.recName = result.Name;
                        this.reraNumber = result.EYI_RERA_Number__c;
                        this.recCode = result.EYI_REC_Code__c;
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
    //as

    // parseNumber(val) {
    //     if (typeof val === 'string') {
    //         // Remove currency symbols, commas, and handle NaN
    //         let cleaned = val.replace(/[^\d.-]/g, '');
    //         if (cleaned === '' || isNaN(cleaned)) return 0;
    //         return Number(cleaned);
    //     }
    //     return val || 0;
    // }
    handleRecordChange(event){
        console.log('Inside handleRecordChange');
        this.retainedByUser = event.target.value;
    }
        
        
  handleSave() {
    console.log('Inside handleSave', this.recordId);
    console.log('Inside handleSave this.RetentionDate', this.retentionDate);
    console.log('RetainedByUser '+this.retainedByUser);
    
        const fieldsToSave = {  
            Id:this.cancellationId,
            EYI_Opportunity__c: this.recordId,
            EYI_Cancellation_Type__c: this.cancellationType,
            EYI_Cancellation_Subtype__c: this.cancellationSubtype,
            EYI_Cancellation_Reason__c: this.cancellationReason,
            EYI_Cancellation_Status__c: this.cancellationStatus,
            EYI_Cancellation_Commencement__c: this.cancellationCommencement,
            EYI_Registration_Status__c: this.registrationStatus,
            EYI_Cancellation_Remarks__c: this.cancellationRemarks,
            EYI_Date_of_Cancellation_initiated__c: this.dateOfCancellationInitiated,
            EYI_Retention_Enablers__c: this.retentionEnablers,
            EYI_Retention_Remarks__c: this.retentionRemarks,
            EYI_Retained_by_User__c: this.retainedByUser,
            EYI_Retention_Date__c: this.retentionDate,
            EYI_Bank_Name__c: this.otherBankName,
            Bank_Name__c: this.bankName,
            //EYI_Instrument_Details__c:this.instumentDetails,
            EYI_IFSC_Code__c:this.ifscCode,
            EYI_Account_No__c:this.accountNumber,
            EYI_Cheque__c:this.checkNumber,

            EYI_Total_Received_Amount__c: this.totalReceivedAmount,
            EYI_TotalAmountCharged__c: this.totalAmountCharged,
            EYI_Amount_to_Cust_of_Other_Adjustment__c:this.amountToCustofAdjustment,
            EYI_Total_Refund_Given__c: this.totalRefundtoCustomer,
            EYI_Demanded_Amount_Principal__c: this.DEMAND_P,
            EYI_Reversal_Demanded_Amount_Principal__c: this.DEMAND_P_R,
            EYI_Demanded_Amount_Tax__c: this.DEMAND_T,
            EYI_Reversal_Demanded_Amount_Tax__c: this.DEMAND_T_R,
            EYI_Demand_Amount_Charged_to_Customer__c:this.demandAmountCustCharge,
            EYI_Reversal_to_Customer__c: this.reversalToCustomer,
            EYI_Debit_Note_Principal__c: this.DEBIT_P,
            EYI_Credit_Note_Principal__c: this.CREDIT_P,
            EYI_Debit_Note_Tax__c: this.DEBIT_T,
            EYI_Credit_Note_Tax__c: this.CREDIT_T,
            EYI_Reversal_Debit_Note_Principal__c: this.DEBIT_P_R,
            EYI_Reversal_Credit_Note_Principal__c: this.CREDIT_P_R,
            EYI_Reversal_Debit_Note_Tax__c: this.DEBIT_T_R,  
            EYI_Reversal_Credit_Note_Tax__c: this.CREDIT_T_R,
            EYI_Debit_Note_Charged_to_Customer__c:this.debitChargeCust,
            EYI_Credit_Note_Charged_to_Customer__c:this.creditChargeCust,
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
        };
        console.log('Data to save:', JSON.stringify(fieldsToSave));
        if(this.bankName =='Other' && !this.otherBankName){
            this.showToast('Error', 'Please Enter Bank Name', 'error');
        }else{
            saveCancellationDetails({ data: fieldsToSave })
            .then(() => {
                this.showToast('Success', 'Data saved successfully.', 'success');
            })
            .catch((error) => {
                console.error('Error saving data:', error);
                this.showToast('Error', error.body.message || 'Failed to save data.', 'error');
            });
        }
        
    }

    // Example handler for combobox change
    handleCancellationTypeChange(event) {
        this.cancellationType = event.target.value;
    }
    handleCancellationTypeChange(event) {
        this.cancellationType = event.target.value;
    }

    handleCancellationSubtypeChange(event) {
        this.cancellationSubtype = event.target.value;
    }

    handleCancellationReasonChange(event) {
        this.cancellationReason = event.target.value;
    }

    handleCancellationStatusChange(event) {
        this.cancellationStatus = event.target.value;
    }

    handleCancellationCommencementChange(event) {
        this.cancellationCommencement = event.target.value;
    }

    handleRegistrationStatusChange(event) {
        this.registrationStatus = event.target.value;
    }

    handleCancellationRemarksChange(event) {
        this.cancellationRemarks = event.target.value;
    }

    handleDateOfCancellationInitiatedChange(event) {
        this.dateOfCancellationInitiated = event.target.value;
    }

    handleAgreementValue(event) {
        this.agreementValue = event.target.value;
    }

    handleTotalCost(event) {
        this.totalCost = event.target.value;
    }

    handleSalesOrderNumber(event) {
        this.salesOrderNumber = event.target.value;
    }

    handlestampDuty(event) {
        this.stampDuty = event.target.value;
    }

    handleRecName(event) {
        this.recName = event.target.value;
    }

    handleReraNumber(event) {
        this.reraNumber = event.target.value;
    }

    handleRecCode(event) {
        this.recCode = event.target.value;
    }

    handleBrokrageTotalAmount(event) {
        this.brokrageTotalAmount = event.target.value;
    }

    handleRetentionEnablers(event) {
        this.retentionEnablers = event.target.value;
    }

    handleRetentionRemarks(event) {
        this.retentionRemarks = event.target.value;
    }

    handleRetainedByUser(event) {
        this.retainedByUser = event.target.value;
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

    handleSourcingManager(event) {
        this.sourcingManager = event.target.value;
    }

    handleClosingManager(event) {
        this.closingManager = event.target.value;
    }

    handleRelationshipManager(event) {
        this.relationshipManager = event.target.value;
    }

    handleBookingSource(event) {
        this.bookingSource = event.target.value;
    }

    handleBankName(event) {
        this.bankName = event.target.value;
        if(this.bankName == 'Other'){
            this.showOtherBank = true;
        }else{
            this.showOtherBank = false;
            this.otherBankName = ''; 
        }
    }
    handleOtherBankName(event){
        this.otherBankName = event.target.value;
    }

    handleCheque(event) {
        this.checkNumber = event.target.value;
    }

    handleIfscDetails(event) {
        this.ifscCode = event.target.value;
    }

    handleapplicant(event) {
        this.applicant = event.target.value;
    }

    handleaccountNumber(event) {
        this.accountNumber = event.target.value;
    }
    
      
}