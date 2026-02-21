import { LightningElement,api } from 'lwc';

export default class EyiRECProgressStatus extends LightningElement {
    @api recordId;
    
    connectedCallback(){
        console.log('recordId',this.recordId);
    }
}