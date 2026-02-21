import { LightningElement, api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import oppCustomerNumber from '@salesforce/schema/Opportunity.EYI_SAP_Customer_Number__c';
import cmpCode from '@salesforce/schema/Opportunity.EYI_Project_Enquired__r.EYI_SAP_Company_Code__c';
import dChannel from '@salesforce/schema/Opportunity.EYI_Distribution_Channel__c';
import mtNumber from '@salesforce/schema/Opportunity.EYI_Inventory__r.EYI_Inventory_Number__c';
import sOrg from '@salesforce/schema/Opportunity.EYI_Project_Enquired__r.EYI_SAP_Salesorg__c';
import sOrder from '@salesforce/schema/Opportunity.EYI_SalesOrder_Number__c';

import { getRecord } from 'lightning/uiRecordApi';


export default class ParentLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    wireRecordId
    customerNumber;
    companyCode;
    salesOrg;
    distChannel;
    matNo;
    salesDoc;
    salesOrder;
    isMatchingApi;
    tabName;
    @api sapCustNumb;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.isMatchingApi = currentPageReference.attributes.apiName /*=== 'Opportunity.Generate_Ageing_Report'*/;
            this.wireRecordId = currentPageReference.state.recordId;
        }
    }
    @wire(getRecord, { recordId: '$wireRecordId', fields: [oppCustomerNumber,cmpCode,dChannel,mtNumber,sOrg,sOrder] })
        wiredRecord({ error, data }) {
            if (data) {
                console.log('data-->'+JSON.stringify(data));
                
                this.customerNumber = data.fields.EYI_SAP_Customer_Number__c.value;    
                this.companyCode = data.fields.EYI_Project_Enquired__r.value.fields.EYI_SAP_Company_Code__c.value;
                this.distChannel = data.fields.EYI_Distribution_Channel__c.value;
                console.log('distChannel-->'+this.distChannel);
                
                this.salesOrg = data.fields.EYI_Project_Enquired__r.value.fields.EYI_SAP_Salesorg__c.value;
                const inv = data.fields.EYI_Inventory__r;
                if(inv && inv.value && inv.value.fields.EYI_Inventory_Number__c){
                    this.matNo = inv.value.fields.EYI_Inventory_Number__c.value;
                }
                //this.matNo = data.fields.EYI_Inventory__r.value.fields.EYI_Inventory_Number__c.value;
                this.salesOrder = data.fields.EYI_SalesOrder_Number__c.value;
                if(this.isMatchingApi == 'Opportunity.Generate_Ageing_Report'){
                    this.tabName = 'Generate_Ageing_Report';

                }
                else if(this.isMatchingApi == 'Opportunity.Generate_Outstanding_Report'){
                    this.tabName = 'Generate_Outstanding_Report';

                }
                else if(this.isMatchingApi == 'Opportunity.Generate_TDS_Report'){
                    this.tabName = 'Generate_TDS_Report';

                }
                else if(this.isMatchingApi == 'Opportunity.Generate_Custome_Ledger_Report'){
                    this.tabName = 'Generate_Custome_Ledger_Report';

                }
                //this.tabName = this.isMatchingApi ? 'Generate_Ageing_Report' : 'Generate_Outstanding_Report';
                console.log('this.tabName-->'+this.tabName);
                
                this.navigation(this.tabName);

               
            } else if (error) {
                console.error('Error fetching record:', error);
            }
        }
    

    navigation(tabName) {
        // Open a Lightning App Tab inside a sub-tab
        console.log('distChannel-->59'+this.distChannel);
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: tabName // Use the API name of the Lightning Tab you created
            },
            state: {
                c__recordId: this.wireRecordId,
                c__sapCustNumb:this.customerNumber, 
                c__companyCode: this.companyCode,
                c__salesOrg: this.salesOrg,
                c__distChannel: this.distChannel,
                c__matNo: this.matNo,
                c__salesOrder: this.salesOrder
             },
            
        },true);
    }
}