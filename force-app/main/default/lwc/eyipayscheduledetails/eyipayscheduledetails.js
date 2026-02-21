import { api, LightningElement, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import datatableStyles from '@salesforce/resourceUrl/datatableStyles';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// import { getListUi } from 'lightning/uiListApi';

// import EYI_PAYMENT_MILESTONE_USAGE_MAPPING_OBJECT from '@salesforce/schema/EYI_Payment_Milestone_Usage_Mapping__mdt';
import getUsageMappingMetadata from '@salesforce/apex/EYI_PaymentSchedulesUtility.getUsageMappingMetadata';
import getPaymentSchedules from '@salesforce/apex/EYI_PaymentSchedulesUtility.getPaymentSchedules';
import updatePaymentSchedules from '@salesforce/apex/EYI_PaymentSchedulesUtility.updatePaymentSchedules';
import deletePaymentSchedules from '@salesforce/apex/EYI_PaymentSchedulesUtility.deletePaymentSchedules';

export default class eyipayscheduledetails extends NavigationMixin(LightningElement){
    @api recordId;
    @api objectApiName;
    @track paymentSchedulesdata = [];
    @track error;
    @track draftValues = [];
    @track showAddRow = false;
    @track justcal = false;
    @track extendedPlan = false;
    @track quoteId;
    @track opportunityId;
    agreementValue = 0;
    customusageforeditabledate = 'Booking,Registration';
    npvper = 12;
    
    get npvTotal() {
        if (Array.isArray(this.paymentSchedulesdata) && this.paymentSchedulesdata.length == 0) {
            return 0;
        }
        else {
            let total = 0;
            this.paymentSchedulesdata.forEach(element => {
                total += parseFloat(element.EYI_NPV_Cal__c);
            });
            return this.formatToTwoDecimals(total);
        }

    }
    get basicTotal() {
        if (Array.isArray(this.paymentSchedulesdata) && this.paymentSchedulesdata.length == 0) {
            return 0;
        }
        else {
            let total = 0;
            this.paymentSchedulesdata.forEach(element => {
                total += parseFloat(element.EYI_Invoice_Percentage__c);
            });
            return this.formatToTwoDecimals(total);
        }
    }
    get outstandingTotal() {
        try{
        if (Array.isArray(this.paymentSchedulesdata) && this.paymentSchedulesdata.length == 0) {
            return 0;
        }
        else {
            let total = 0;
            this.paymentSchedulesdata.forEach(element => {
                // if(element.EYI_Actual_Date__c || element.Payment_Plan__r.EYI_Plan_Type__c != 'Construction Linked Payment'){
                //     total += parseFloat(element.EYI_Due_Amount__c);
                // }
                if(element.disabled){
                    total += parseFloat(element.EYI_Due_Amount__c);
                }
            });
            let final = this.paymentSchedulesdata[0].Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c - total;
            this.agreementValue = this.formatToTwoDecimals(this.paymentSchedulesdata[0].Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c) ;
            console.log('agreementValue',this.agreementValue);
            return this.formatToTwoDecimals(final);
        }
    }
    catch(e){
        return 0;
    }
    }
    get remainingActualTotal() {
        try{
        if (Array.isArray(this.paymentSchedulesdata) && this.paymentSchedulesdata.length == 0) {
            return 0;
        }
        else {
            let total = 0;
            this.paymentSchedulesdata.forEach(element => {
                if(element.EYI_Actual_Date__c || element.Payment_Plan__r.EYI_Plan_Type__c != 'Construction Linked Payment'){
                    total += parseFloat(element.EYI_Amount_to_be_paid__c? element.EYI_Amount_to_be_paid__c : 0);
                }
            });
            return this.formatToTwoDecimals(total);
        }
    }catch(e){
        return 0;
    }
    }
    get finaldiff(){
        try{
        if(this.extendedPlan == true && this.paymentSchedulesdata && this.paymentSchedulesdata[0] && this.paymentSchedulesdata[0].Payment_Plan__r && this.paymentSchedulesdata[0].Payment_Plan__r.EYI_Plan_Type__c == 'Construction Linked Payment'){
            return parseFloat(this.outstandingTotal) - parseFloat(this.remainingActualTotal);
        }
        else{
            return 0;
        }
        }
        catch(e){
            return 0;
        }
    }
    get finalremainingper(){
            return this.formatToTwoDecimals(100 - parseFloat(this.basicTotal));
    }
    get showsave() {
        return this.recordId  ? true : false;
    }
    get showsubmit(){
       // return this.opportunityId && this.quoteId && this.recordId && this.finaldiff == 0 && this.finalremainingper == 0? true : false;
        return this.opportunityId && this.quoteId && this.recordId && (this.outstandingTotal == this.remainingActualTotal) ? true : false;
    }
    @track pS;
    @track isSpinner = true;

    get usageoptions() {
        if (this.usageMappingdata.data) {
            return this.usageMappingdata.data.map(field => ({
                label: field.MasterLabel,
                value: field.DeveloperName
            }));
        }
        return [];
    }
    @track usageMappingdata;


    @wire(getUsageMappingMetadata)
    wiredUsageMapping(result){
        this.usageMappingdata = result;
        console.log('Core Mapping',result);
        if(this.usageMappingdata.data){
            console.log('metadata got',this.usageMappingdata.data);
        }
        else if(this.usageMappingdata.error){
            console.log('metadata error',this.usageMappingdata.error);
        }
        else{
            console.log('No Mapping found else');
        }
    }


    @wire(getPaymentSchedules, { recordId: '$recordId' })
    wiredPaymentSchedules(result) {
        this.pS = result
        if (this.pS.data) {
            this.paymentSchedulesdata = this.pS.data.map((item, index) => {
                // Ensure each item has a unique index if it doesn't have a unique Id
                return { ...item, index: index };
            });
            setTimeout(() => {
                this.updatecalculations();
            }, 100);

            this.error = undefined;
        }
        else if (this.pS.error) {
            console.error('payment schedule load error', this.pS.error);
            this.error = this.pS.error;
        }
        else {
            if (!this.showsave) {
                this.isSpinner = false;
            }

            // this.justcal = true;
        }
    }
    updatepercent(event){
        try{

        
        let index = event.target.dataset.index;
        this.paymentSchedulesdata[index][event.target.name] = event.target.value;
        let element = this.paymentSchedulesdata[index];
        if(element){
            this.paymentSchedulesdata[index].EYI_Invoice_Percentage__c = this.formatToTwoDecimals(this.paymentSchedulesdata[index].EYI_Amount_to_be_paid__c/this.paymentSchedulesdata[index].Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c * 100);
        }
        else{
            console.log('Error in updating percentage',index);
        }
        // this.paymentSchedulesdata.forEach((element, index) => {
        //     element.EYI_Invoice_Percentage__c = element.EYI_Amount_to_be_paid__c/element.Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c * 100;
        //     element.EYI_Invoice_Percentage__c = this.formatToTwoDecimals(element.EYI_Invoice_Percentage__c);
        // });
        }
        catch(err){
            console.log('not updating percent',err);
        }

    }
    updatecalculations() {
        let isPartialCLP = false;
        this.paymentSchedulesdata.forEach((element, index) => {
            try{
                this.quoteId = element.Payment_Plan__r.EYI_Quote__c;
                this.opportunityId = element.Payment_Plan__r.EYI_Quote__r.OpportunityId;
            }
            catch(e){
                console.log('No metadata found',e);
            }
            try {
                if (element.Payment_Plan__r.EYI_Is_Extended__c) {
                    
                    this.extendedPlan = true;
                    if (element.EYI_Actual_Date__c) {
                        element.EYI_Billing_Date__c = element.EYI_Actual_Date__c;
                    }

                }
                // if (element.EYI_Due_Amount__c && !element.EYI_Amount_to_be_paid__c) {
                //     element.EYI_Amount_to_be_paid__c = element.EYI_Due_Amount__c;
                // }
                if(element.Payment_Plan__r.Project__r.EYI_NPV_Percent__c){
                    this.npvper = element.Payment_Plan__r.Project__r.EYI_NPV_Percent__c/100;
                }
                else{
                this.npvper = 12/100;
                }
                let dateDiffToday = this.calculateDateDifferenceInDays(element.EYI_Billing_Date__c, new Date());
                
                

                console.log('Diff from today date', dateDiffToday);
                if (this.showsave) {
                    console.log('payable cal');
                    element.EYI_Due_Amount__c = element.EYI_Payable_Amount__c;
                }
                if (element.Payment_Plan__r && element.Payment_Plan__r.EYI_Plan_Type__c == 'Construction Linked Payment') {
                    //&& this.calculateDateDifferenceInDays(element.EYI_Actual_Date__c, new Date()) > 0
                    if (this.extendedPlan && element.EYI_Actual_Date__c ) {
                        element.disabled = false;
                        //isPartialCLP = true;
                    }else{
                        element.disabled = true;
                    }
                    
                    
                }
                else if (element.Payment_Plan__r && element.Payment_Plan__r.EYI_Plan_Type__c == 'CLP + Time bound' && this.calculateDateDifferenceInDays(element.EYI_Billing_Date__c, new Date()) < 0) {
                    element.disabled = true;
                }
                else {
                    element.disabled = false;
                }
                if (this.extendedPlan) {
                    let containsValue = false;
                    this.customusageforeditabledate.split(",").forEach(cItem => {
                        if (element.EYI_Usage_Description__c.includes(cItem)) {
                            containsValue = true;
                            return;
                        };
                    });
                    console.log(containsValue, '- matched usage name ', element.EYI_Usage_Description__c);
                    if (containsValue) {
                        element.datedisabled = false;
                    }
                    else {
                        element.datedisabled = element.disabled;
                    }
                }
                else {
                    element.datedisabled = element.disabled;
                }

                if (index == 0) {
                    element.DiffDays = 0;
                }
                else {
                    element.DiffDays = this.calculateDateDifferenceInDays(this.paymentSchedulesdata[index - 1].EYI_Billing_Date__c, element.EYI_Billing_Date__c);
                }
                console.log('PS --',index);
                let prevEl;
                if(index <= 0){
                    //prevEl = this.paymentSchedulesdata[index - 1];
                    element.amountDiff = this.outstandingTotal - element.EYI_Amount_to_be_paid__c;
                    element.EYI_Due_Diff__c = element.amountDiff;
                }
                else if(index && index >= 1){
                    
                    prevEl = this.paymentSchedulesdata[index - 1];
                    console.log(
                        'prev element',JSON.stringify(prevEl),
                        prevEl.EYI_Due_Diff__c,
                        'amount diff');
                    element.amountDiff = prevEl.EYI_Due_Diff__c - element.EYI_Amount_to_be_paid__c;
                    element.EYI_Due_Diff__c = element.amountDiff;
                }
                else{
                    console.log('PS data without inde --',index);
                }
                
                if(!element.amountDiff || element.EYI_Due_Diff__c < 0){
                    element.amountDiff = 0;
                    element.EYI_Due_Diff__c = 0;
                }
                let nextEl;
                try {
                    nextEl = this.paymentSchedulesdata[index + 1];
                    let daydiff = this.calculateDateDifferenceInDays(element.EYI_Billing_Date__c, nextEl.EYI_Billing_Date__c);
                    if (index == 0) {
                    daydiff = daydiff - 15 < 0 ? 0 : daydiff - 15;
                    }
                    element.EYI_NPV_Cal__c = this.formatToTwoDecimals(element.amountDiff * this.npvper * daydiff / 365);
                    element.EYI_NPV_Cal__c = element.EYI_NPV_Cal__c < 0 || element.disabled ? 0 : element.EYI_NPV_Cal__c;
                    console.log(index, element.DiffDays, element.amountDiff, element.EYI_NPV_Cal__c);

                }
                catch (err) {
                    element.EYI_NPV_Cal__c = 0;
                    console.log('Next Element is not available', err);
                    nextEl = null;
                }
                if (element.Payment_Plan__r.Project__r.EYI_GST_Pay_Schedule_Charge__c && element.EYI_Amount_to_be_paid__c) {
                    element.EYI_GST__c = this.formatToTwoDecimals((element.EYI_Due_Amount__c * element.Payment_Plan__r.Project__r.EYI_GST_Pay_Schedule_Charge__c) / 100);
                } else {
                    element.EYI_GST__c = 0;
                }
                if (element.disabled) {
                    element.EYI_Amount_to_be_paid__c = element.EYI_Due_Amount__c;
                }
                else{
                   // element.EYI_Invoice_Percentage__c = element.EYI_Amount_to_be_paid__c/element.Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c * 100;
                   // element.EYI_Invoice_Percentage__c = this.formatToTwoDecimals(element.EYI_Invoice_Percentage__c);
                }
                // if (element.EYI_Due_Amount__c) {
                //     element.EYI_Amount_to_be_paid__c = element.EYI_Due_Amount__c;
                // }
                

            }
            catch (err) {
                console.log('PP linking refreshing auto', err);
            }

        });
        this.showAddRow = !isPartialCLP;
        this.isSpinner = false
    }
    calculateDateDifferenceInDays(startDate, endDate) {
        let differenceInDays = 0;
        if (startDate && endDate) {
            const start = new Date(startDate);
            const end = new Date(endDate);
            const difference = end - start;
            differenceInDays = Math.ceil(difference / (1000 * 60 * 60 * 24));
        }
        return differenceInDays;
    }
    handlesubmit(){
        const fields = {};
      fields['Id'] = this.quoteId;
      fields['EYI_Is_Payment_Plan_Submitted__c'] = true;

      const recordInput = { fields };

      updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Quote updated",
              variant: "success",
            }),
          );
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opportunityId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
          // Display fresh data in the form
        })
        .catch((error) => {
          console.error(error, 'error while updating');
        });
    }
    onchangeinput(event) {
        let ind = event.target.dataset.index;
        this.paymentSchedulesdata[ind][event.target.name] = event.target.value;
        if(event.target.name == 'EYI_Usage__c' && event.target.value != null && event.target.value != '- None -' && event.target.value != '- None -'){
            this.paymentSchedulesdata[ind]['EYI_Usage_Description__c']  =  this.usageoptions.find(opt => opt.value === event.target.value).label;
        }
        else if (event.target.name == 'EYI_Billing_Date__c'){
            let daydiffFrmBook = this.calculateDateDifferenceInDays(this.paymentSchedulesdata[0]['EYI_Billing_Date__c'], event.target.value);
            console.log('day diff from booking',daydiffFrmBook);
            if( daydiffFrmBook< 0){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Invalid Date',
                        message: 'Billing date should be greater than booking date ',
                        variant: 'warning',
                    })
                );
                event.target.value = undefined;
            }
            else{
                this.paymentSchedulesdata[ind]['EYI_Actual_Date__c'] = event.target.value;
            }
            
        }
        console.log('current change row input',event.target.name,event.target.value, JSON.stringify(this.paymentSchedulesdata[ind]));
        this.updatecalculations();
        // setTimeout(() => {
        //         this.updatecalculations();
        //     }, 10000);
    }
    handleSave(event) {
        this.isSpinner = true;
        let btnname = event.target.name;
        let that = this;
        // const updatedValues = event.detail.draftValues;
        // console.log('updatedValues', updatedValues);
        // updatedValues.forEach(draft => {
        //     console.log('draftid', draft.id);
        //     //console.log('rowid', row.id);
        //     const rowIndex = this.rows.findIndex(row=>row.id === draft.id);
        //     console.log(rowIndex);
        //     if(rowIndex !== -1) {
        //         this.row[rowIndex] = {...this.rows[rowIndex], ...draft};
        //     }
        // })
        // this.draftValues = [];
        // let recupdates = [];
        // console.log('Payment Schedules - ',this.paymentSchedulesdata);
        //if (this.basicTotal <= 100.50) {
        if (this.remainingActualTotal <= this.outstandingTotal) {

            let paymentS = this.paymentSchedulesdata
            paymentS.forEach(element => {
                if (element.isNew) {
                    element['Payment_Plan__c'] = this.recordId;
                    element['EYI_Milestone_Type__c'] = 'Time Bound';
                    if (element.Payment_Plan__r && element.Payment_Plan__r.EYI_Plan_Type__c == 'Construction Linked Payment'){
                        element['EYI_Actual_Date__c'] = element['EYI_Billing_Date__c'];
                    }
                    delete element['Id'];
                    delete element['Payment_Plan__r'];
                    console.log('new el',element,JSON.stringify(element));
                }
                else {
                    if (element.Payment_Plan__r && element.Payment_Plan__r.EYI_Plan_Type__c != 'Construction Linked Payment'){
                        element['EYI_Milestone_Type__c'] = 'Time Bound';
                    }
                    delete element['Payment_Plan__r'];
                    console.log('old el',element,JSON.stringify(element));
                }
                element['EYI_AutomationBypassDatetime__c'] = new Date();
                console.log('Payment Schedule  - ', JSON.stringify(element));
            });
            console.log('Payment Schedules - ', paymentS);

            updatePaymentSchedules({ paymentSchedules: paymentS })
                .then(result => {
                    
                    console.log('Success -  ', result);
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Payment Schedules saved successfully',
                        variant: 'success',
                    })
                    );
                    try{
                        console.log('event d : ',btnname);
                        that.handleRefresh();
                        if(btnname == 'Submit'){
                            that.handlesubmit();
                        }
                        else{
                            that.handleRefresh();
                        }
                    }
                    catch(e){
                        console.error('going forward error',e);
                    }
                    
                    
                    
                })
                .catch(error => {
                    console.log('Error: ', error);
                })
                .finally(() => {
                    this.isSpinner = false;
                });
        }
        else {
            this.isSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please check Outstanding Amount and Actual Declared Amount',
                    variant: 'error'
                })
            );
        }
    }
    addRow() {
        if (this.basicTotal < 100) {
       // if (this.remainingActualTotal < this.outstandingTotal) {
            let av = 0;
            if(this.extendedPlan){
                av = this.paymentSchedulesdata[0].Payment_Plan__r.EYI_Quote__r.EYI_Agreement_Value__c;
            }
            const newRecord = {
                Id: this.paymentSchedulesdata.length + 1, // Assign a unique ID for the key
                EYI_Usage_Description__c: '', // Set default value or leave empty
                EYI_Invoice_Percentage__c: 0, // Set default value or leave empty
                Payment_Plan__r : {EYI_Quote__r : {EYI_Agreement_Value__c : av}},
                isNew: true
            };

            // Add the new record to the paymentSchedulesdata array
            this.paymentSchedulesdata = [...this.paymentSchedulesdata, newRecord];
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Payment Schedule total basic should be 100%',
                    variant: 'error'
                })
            );
        }

    }

    deleteRow(event) {
        const indexToDelete = event.currentTarget.dataset.index;
        let pid = event.currentTarget.dataset.id;
        console.log('event data', event.currentTarget.dataset)
        deletePaymentSchedules({ paymentScheduleId: pid })
            .then(result => {
                console.log('Success -  ', result);
                this.paymentSchedulesdata = this.paymentSchedulesdata.filter((item, index) => index.toString() !== indexToDelete);
            })
            .catch(error => {
                console.log('Error: ', error);
            })
            .finally(() => {
                this.isSpinner = false;
            });

    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.id;

        if (actionName === 'delete') {
            this.rows = this.rows.filter(row => row.id !== rowId);
        }
    }
    formatToTwoDecimals(number) {
        //return number;
        return parseFloat(number).toFixed(2);
    }
    
    handleRefresh() {
        refreshApex(this.pS);
        this.updatecalculations();
    }
}