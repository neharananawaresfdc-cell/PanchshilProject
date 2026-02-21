import { LightningElement,track,wire,api } from 'lwc';
import hasPermission from '@salesforce/customPermission/View_Utility_Component';
import { CurrentPageReference } from 'lightning/navigation';
import { minimize, EnclosingUtilityId } from 'lightning/platformUtilityBarApi';
import getOppRecord from '@salesforce/apex/EYI_WelcomCallUtilityClass.getOppRec';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class WelcomeEmailContent extends LightningElement {
     oppRecordId;
     userId = USER_ID;
    userName;
    hasCustomPermission = hasPermission;
    @wire(getRecord, { recordId: '$userId', fields: [NAME_FIELD] })
    userRecord({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
        } else if (error) {
            console.error('Error retrieving user name:', error);
        }
    }
      @wire(EnclosingUtilityId) utilityId;
    @wire(CurrentPageReference)
        currentPageReference;
        @track oppDetails = []; 
    connectedCallback(){
        console.log('recordIDScript',this.currentPageReference.attributes.recordId);
        this.oppRecordId  = this.currentPageReference.attributes.recordId;
        console.log('recordIDScript2',this.oppRecordId);
        this.fetchOpportunity(this.oppRecordId);
        
    }
    fetchOpportunity(oppId) {
        getOppRecord({ recordId: oppId })
        .then(result => {
            console.log('result23',result);
            this.oppDetails.push({
                'Pancard': result?.EYI_Primary_Applicant__r?.hasOwnProperty('EYI_Pancard_Number__c') 
                    ? result.EYI_Primary_Applicant__r.EYI_Pancard_Number__c || '' 
                    : '',
                'AadharCard': result?.EYI_Primary_Applicant__r?.hasOwnProperty('EYI_Aadhar_Number__c') 
                    ? result.EYI_Primary_Applicant__r.EYI_Aadhar_Number__c || '' 
                    : '',
                    'DOB': result?.EYI_Primary_Applicant__r?.hasOwnProperty('EYI_Date_of_Birth__c') 
                        ? result.EYI_Primary_Applicant__r.EYI_Date_of_Birth__c || '' 
                        : '',
                    'AnniversaryDate': result?.EYI_Primary_Applicant__r?.hasOwnProperty('EYI_Anniversary_Date__c') 
                        ? result.EYI_Primary_Applicant__r.EYI_Anniversary_Date__c || '' 
                        : '',
                    'PrimaryName': result?.EYI_Primary_Applicant__r?.hasOwnProperty('Verified_AADHAR_Card_Name__c') 
                        ? result.EYI_Primary_Applicant__r.Verified_AADHAR_Card_Name__c || '' 
                        : '',
                    'Address': result?.EYI_Primary_Applicant__r?.hasOwnProperty('Verified_AADHAR_Card_Address__c') 
                        ? result.EYI_Primary_Applicant__r.Verified_AADHAR_Card_Address__c || '' 
                        : '',
                    'RM_Name': result?.EYI_Relationship_Manager__r?.hasOwnProperty('Name') 
                        ? result.EYI_Relationship_Manager__r.Name || '' 
                        : '',
                    'RM_Email': result?.EYI_Relationship_Manager__r?.hasOwnProperty('Email') 
                        ? result.EYI_Relationship_Manager__r.Email || '' 
                        : '',
                    'RM_Mobile': result?.EYI_Relationship_Manager__r?.hasOwnProperty('MobilePhone') 
                        ? result.EYI_Relationship_Manager__r.MobilePhone || '' 
                        : '',
                    'ProjectName': result?.EYI_Project_Enquired__r?.hasOwnProperty('Name') 
                        ? result.EYI_Project_Enquired__r.Name || '' 
                        : '',
                    'InventoryName': result?.EYI_Inventory__r?.hasOwnProperty('Name') 
                        ? result.EYI_Inventory__r.Name || '' 
                        : '',
                    'Company': result?.EYI_Primary_Applicant__r?.hasOwnProperty('EYI_Company_Name__c') 
                        ? result.EYI_Primary_Applicant__r.EYI_Company_Name__c || '' 
                        : '',
                    'Designation': result?.EYI_Primary_Applicant__r?.hasOwnProperty('EYI_Designation__c') 
                        ? result.EYI_Primary_Applicant__r.EYI_Designation__c || '' 
                        : '',
                    'Nationality': result?.EYI_Primary_Applicant__r?.hasOwnProperty('Nationality') 
                        ? result.EYI_Primary_Applicant__r.Nationality || '' 
                        : '',
                    'ConsultantName': result?.Owner?.hasOwnProperty('Name') 
                    ? result.Owner.Name || '' 
                    : '',
                    'AgreementValue': result?.hasOwnProperty('EYI_Agreement_Value__c') 
                    ? result.EYI_Agreement_Value__c || '' 
                    : '',
                    'Name':result?.hasOwnProperty('Name') 
                    ? result.Name || '' 
                    : '',
                    // 'Name':result?.hasOwnProperty('EYI_First_Name__c') ? result.EYI_First_Name__c || '':'' + ' ' + result?.hasOwnProperty('EYI_Last_Name__c') ? result.EYI_Last_Name__c || '' :'',
                    

            });
            console.log('oppDetails',JSON.stringify(this.oppDetails));
           // this.fetchApplicant(oppId);
        })
        .catch(error => {
            console.error('Error fetching Opportunity: ', error);
        });
    }
    fetchApplicant(oppId){
        getAppRecord({ recordId: oppId })
        .then(result => {
            console.log('result23',result.Verified_AADHAR_Card_Name__c);
            this.oppDetails.push({
                'SecondayName':result.Verified_AADHAR_Card_Name__c,
            });
    
        })
        .catch(error => {
            console.error('Error fetching Opportunity: ', error);
        });
    }
    
    get oppDetail() {
            return this.oppDetails[0] || {};
        }
    closeScript() {
        this.handleMinimize();
        // Close or hide the component here
        // For example, you can navigate away from the page or hide this component
        //console.log('Close button clicked');
    }
    async handleMinimize() {
        try {
            if (!this.utilityId) {
                return;
          }
        // Minimize the utility bar panel
        const isMinimized = await minimize(this.utilityId);
        console.log(`Minimize utility ${isMinimized ? 'successfully' : 'failed'}`);
        }
        catch (error) {
            // handle error
        }
    }
    // @wire(getRecord, { recordId: this.oppRecordId})
    // oppDetails({ error, data }) {
    //     console.log('datarecordIDScript',data);
    // }
    
}