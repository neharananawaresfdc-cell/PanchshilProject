import { LightningElement,api } from 'lwc';

export default class EYI_RedirectToRecord extends LightningElement {
    @api recordIdToRedirect;
    @api isLoading=false;

    connectedCallback(){
        console.log('recordIdToRedirect :: '+this.recordIdToRedirect);
        
        this.isLoading=true;
        //window.location.href = "/"+this.recordIdToRedirect;
        window.open('/' + this.recordIdToRedirect, '_blank');
        this.isLoading=false;

    }
}