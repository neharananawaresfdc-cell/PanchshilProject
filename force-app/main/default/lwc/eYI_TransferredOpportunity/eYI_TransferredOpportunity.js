import { LightningElement, api, wire } from 'lwc';
import getOpportunity from '@salesforce/apex/EYI_DigitalSlotMatrixController.getOpportunity'; 

export default class EYI_TransferredOpportunity extends LightningElement {
    @api recordId; 
    isTransferred = false; 

    connectedCallback(){
        console.log('Transferred Opportunity recordId : '+this.recordId);
        
    }
    @wire(getOpportunity, { opportunityId: '$recordId' })
    opportunity({ error, data }) {
        if (data) {
            this.isTransferred = data.EYI_IsUnitTransferred__c;
        } else if (error) {
            console.error('Error fetching Opportunity data', error);
        }
    }
}